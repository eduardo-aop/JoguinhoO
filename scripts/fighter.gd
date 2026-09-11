class_name RiftFighter
extends CharacterBody3D

var animator: RiftAnimation
var team_plate: MeshInstance3D
var shield_mesh: MeshInstance3D
var buffer_time := 0.0
var footstep_time := 0.0
var arena: Node3D
var team := 0
var hero := "warrior"
var human := false
var alive := true
var stats: Dictionary
var max_hp := 240.0
var hp := 240.0
var cooldowns := [0.0,0.0,0.0]
var basic_clock := 0.0
var windup := 0.0
var basic_pending := false
var attack_count := 0
var guard_time := 0.0
var slow_time := 0.0
var slow_power := 0.0
var passive := -1
var passive_time := 0.0
var active_rune := -1
var active_time := 0.0
var preparing := -1
var dash_time := 0.0
var dash_direction := Vector3.ZERO
var ability_lock := 0.0
var aim_point := Vector3.ZERO
var aim_obstructed := false
var move_axis_world := Vector3.ZERO
var bot: RiftBot
var model: Node3D
var weapon_pivot: Node3D
var caption: Label3D
var hp_bar: MeshInstance3D
var nameplate: Node3D
var aim_indicator: MeshInstance3D
var guard_visual: MeshInstance3D
var attack_visual: MeshInstance3D
var path_indicator: MeshInstance3D
var movement_preview_blocked := false
var cloth_materials: Array[ShaderMaterial] = []
var animation_clock := 0.0
var hit_flash := 0.0
var reaction_clock := 0.0
var damage_dealt := 0.0
var damage_taken := 0.0
var eliminations := 0
var runes_collected := 0
var abilities_used: Array[int] = [0,0,0,0]
var limb_nodes: Array[Node3D] = []

func _ready() -> void:
	stats = RiftRules.HEROES[hero].duplicate(true)
	max_hp = stats.hp
	hp = max_hp
	collision_layer = 2
	collision_mask = 3
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = .44
	# Match the head beneath the decorative crown/hood tips of the current models.
	capsule.height = 2.1
	shape.shape = capsule
	shape.position.y = capsule.height*.5
	add_child(shape)
	build_visual()
	bot = RiftBot.new(self)

func build_visual() -> void:
	var asset := "res://assets/%s_animated.glb" % hero
	if not ResourceLoader.exists(asset):
		asset = "res://assets/sentinel.glb"
	model = load(asset).instantiate()
	add_child(model)
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var material = mesh.get_active_material(surface)
			if material is StandardMaterial3D:
				var is_cloth: bool = "cloth" in material.resource_name.to_lower()
				var painted := RiftAppearance.painted_material(material,is_cloth,team)
				mesh.set_surface_override_material(surface,painted)
				if is_cloth:
					cloth_materials.append(painted)
		if mesh.name.begins_with("Caster"):
			mesh.hide()
		if mesh.name.begins_with("Leg"):
			limb_nodes.append(mesh)
	team_plate = TrainingVisuals.box(model,Vector3(.20,.28,.055),Vector3(0,1.25,.39),RiftRules.team_color(team))
	weapon_pivot = RiftAppearance.weapon(model,hero)
	if hero == "warrior":
		shield_mesh = RiftAppearance.shield(model,team)
	TrainingVisuals.ring(self,.73,Vector3(0,.04,0),RiftRules.team_color(team))
	guard_visual = TrainingVisuals.arc(self,1.25,deg_to_rad(65))
	guard_visual.position.y = .1
	guard_visual.material_override = TrainingVisuals.mat(Color(.5,.85,1,.5),.4)
	guard_visual.hide()
	attack_visual = TrainingVisuals.arc(self,2.9,deg_to_rad(50))
	attack_visual.hide()
	aim_indicator = TrainingVisuals.arc(self,1,PI)
	aim_indicator.hide()
	path_indicator = TrainingVisuals.box(self,Vector3.ONE,Vector3.ZERO,Color(.35,.85,.8,.6))
	path_indicator.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	path_indicator.hide()
	nameplate = Node3D.new()
	add_child(nameplate)
	nameplate.visible = not human
	caption = TrainingVisuals.label(nameplate,"",Vector3(0,2.75,0),28)
	caption.modulate = RiftRules.team_color(team)
	var health_background := TrainingVisuals.box(nameplate,Vector3(1.02,.09,.065),Vector3(0,2.45,0),Color("253331"))
	hp_bar = TrainingVisuals.box(nameplate,Vector3(1,.07,.08),Vector3(0,2.45,0),RiftRules.team_color(team))
	for bar in [health_background,hp_bar]:
		var material: StandardMaterial3D = bar.material_override
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		material.billboard_keep_scale = true
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	animator = RiftAnimation.new()
	animator.actor = self
	add_child(animator)

func _unhandled_input(event: InputEvent) -> void:
	if not human or not alive or get_tree().paused:
		return
	if not arena.active:
		return
	if event is InputEventMouseButton and event.pressed:
		arena.rig.cursor_position = event.position.clamp(Vector2.ZERO,get_viewport().get_visible_rect().size)
		refresh_cursor_aim()
		if event.button_index == MOUSE_BUTTON_LEFT:
			request_basic()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_prepare()
	if event is InputEventKey and not event.echo:
		move_axis_world = arena.rig.movement_direction(Input.get_vector("move_left","move_right","move_forward","move_back"))
		if event.physical_keycode == KEY_SPACE and event.pressed:
			refresh_cursor_aim()
			player_cast(0 if hero == "warrior" else 1)
			return
		if event.physical_keycode == KEY_SHIFT and not event.pressed:
			cancel_prepare()
		var slot := [KEY_Q,KEY_E,KEY_R,KEY_F].find(event.physical_keycode)
		if slot >= 0:
			if not event.pressed:
				if preparing == slot: cancel_prepare()
				return
			refresh_cursor_aim()
			if event.shift_pressed:
				begin_prepare(slot)
			else:
				cancel_prepare()
				player_cast(slot)

func player_cast(slot: int) -> bool:
	if basic_pending or ability_lock > 0:
		arena.hud.notify("AÇÃO EM ANDAMENTO",.6)
		return false
	if slot < 3 and cooldowns[slot] > 0:
		arena.hud.notify("%s · RECARGA %.1fs" % [stats.skills[slot],cooldowns[slot]],.6)
		return false
	if slot == 3 and active_rune < 0:
		arena.hud.notify("SEM RUNA ATIVA · COLETE UMA RUNA",.8)
		return false
	return cast(slot)

func can_act() -> bool:
	return alive and arena.active and not get_tree().paused

func begin_prepare(slot: int) -> bool:
	if not can_act() or basic_pending or ability_lock > 0 or (slot < 3 and cooldowns[slot] > 0) or (slot == 3 and active_rune < 0):
		return false
	buffer_time = 0
	preparing = slot
	return true

func cancel_prepare() -> void:
	buffer_time = 0
	preparing = -1
	if aim_indicator:
		aim_indicator.hide()
	if path_indicator:
		path_indicator.hide()
	movement_preview_blocked = false

func damage_scale() -> float:
	return 1.35 if passive == 1 else 1.0

func request_basic() -> bool:
	if human and can_act() and preparing < 0 and ability_lock <= 0 and basic_clock > 0 and basic_clock <= arena.settings.input_buffer_window:
		buffer_time = arena.settings.input_buffer_window+0.02
		return false
	if not can_act() or basic_clock > 0 or preparing >= 0 or ability_lock > 0:
		return false
	basic_clock = stats.interval
	windup = stats.windup
	basic_pending = true
	attack_count += 1
	animator.strike()
	arena.sound.play("swing" if hero == "warrior" else "cast",global_position,-3)
	return true

func forward_flat() -> Vector3:
	return -global_basis.z

func _physics_process(dt: float) -> void:
	if not alive or not arena.active:
		return
	for i in 3:
		cooldowns[i] = maxf(0,cooldowns[i]-dt)
	basic_clock = maxf(0,basic_clock-dt)
	if buffer_time > 0:
		buffer_time = maxf(0,buffer_time-dt)
		if basic_clock <= 0 and buffer_time > 0:
			buffer_time = 0
			request_basic()
	ability_lock = maxf(0,ability_lock-dt)
	guard_time = maxf(0,guard_time-dt)
	slow_time = maxf(0,slow_time-dt)
	if slow_time <= 0:
		slow_power = 0
	passive_time = maxf(0,passive_time-dt)
	active_time = maxf(0,active_time-dt)
	if passive_time <= 0:
		passive = -1
	if active_time <= 0:
		if preparing == 3:
			cancel_prepare()
		active_rune = -1
	if human:
		refresh_cursor_aim()
		var axis := Input.get_vector("move_left","move_right","move_forward","move_back")
		move_axis_world = arena.rig.movement_direction(axis)
	else:
		move_axis_world = bot.direction(dt)
	var speed: float = stats.speed * (1.25 if passive == 0 else 1.0) * (1.0-slow_power)
	if guard_time > 0:
		speed *= .7
	var dash_ending := dash_time > 0 and dash_time <= dt
	if dash_time > 0:
		var dash_fraction := minf(dash_time,dt)/dt
		dash_time = maxf(0,dash_time-dt)
		velocity = dash_direction*23*dash_fraction
	else:
		var acceleration: float = arena.settings.stopping_rate if move_axis_world.length() < .1 else arena.settings.acceleration_rate
		if Vector3(velocity.x,0,velocity.z).dot(move_axis_world) < 0:
			acceleration = maxf(acceleration,100.0)
		var horizontal := Vector2(velocity.x,velocity.z)
		var target_velocity := Vector2(move_axis_world.x,move_axis_world.z)*speed
		horizontal = horizontal.move_toward(target_velocity,acceleration*dt)
		velocity.x = horizontal.x
		velocity.z = horizontal.y
	velocity.y = -1.0 if is_on_floor() else velocity.y-24*dt
	move_and_slide()
	if dash_ending:
		velocity.x = move_axis_world.x*speed
		velocity.z = move_axis_world.z*speed
	if basic_pending:
		windup -= dt
		if windup <= 0:
			basic_pending = false
			resolve_basic()
	animation_clock += dt
	hit_flash = maxf(0,hit_flash-dt)
	reaction_clock = maxf(0,reaction_clock-dt)
	guard_visual.visible = guard_time > 0
	attack_visual.visible = hero == "warrior" and basic_clock > float(stats.interval)-.4
	footstep_time -= dt
	if Vector2(velocity.x,velocity.z).length() > 1 and is_on_floor() and footstep_time <= 0:
		footstep_time = .3
		arena.sound.play("step",global_position,-13)
	caption.text = ("VOCÊ · " if human else "") + stats.name + "  %d" % ceili(hp)
	hp_bar.scale.x = maxf(.001,hp/max_hp)
	hp_bar.material_override.albedo_color = Color("fff1cb") if hit_flash > 0 else RiftRules.team_color(team)
	update_indicator()

func can_melee(target: Node3D, reach: float = 2.9) -> bool:
	var offset: Vector3 = target.global_position-global_position
	if offset.length() > reach or offset.length() < .01:
		return false
	if forward_flat().dot(offset.normalized()) < cos(deg_to_rad(50)):
		return false
	return arena.line_clear(global_position+Vector3.UP,target.global_position+Vector3.UP)

func resolve_basic() -> void:
	if hero == "warrior":
		arena.combat_fx(global_position,"slash",Color("ecd9a4"),2.0,rotation.y)
	if hero == "mage":
		arena.shoot(self,aim_point,float(stats.basic)*damage_scale(),false)
		return
	var hits := 0
	for enemy in arena.fighters:
		if enemy.team != team and enemy.alive and can_melee(enemy):
			enemy.take_damage(float(stats.basic)*damage_scale(),self,global_position)
			arena.burst(enemy.global_position,RiftRules.team_color(team),.45)
			hits += 1
	if hits > 0 and human:
		arena.hud.notify("GOLPE CONFIRMADO",.6)

func refresh_cursor_aim() -> void:
	aim_point = arena.rig.aim_query().position
	var origin := global_position+Vector3.UP*1.2
	var query := PhysicsRayQueryParameters3D.create(origin,aim_point,1,[get_rid()])
	var cover := get_world_3d().direct_space_state.intersect_ray(query)
	aim_obstructed = not cover.is_empty() and cover.position.distance_to(aim_point) > .2
	var facing := aim_point-global_position
	if Vector2(facing.x,facing.z).length() > .25:
		rotation.y = atan2(-facing.x,-facing.z)

func ground_target(max_range: float) -> Dictionary:
	var point := aim_point
	if human:
		point = arena.rig.cursor_ground()
	point.y = 0
	var offset := point-global_position
	if offset.length() > max_range:
		point = global_position+offset.normalized()*max_range
	point.x = clampf(point.x,-23,23)
	point.z = clampf(point.z,-19,19)
	return {"valid":arena.line_clear(global_position+Vector3.UP,point+Vector3.UP*.15),"point":point}

func cast(slot: int) -> bool:
	if not can_act() or basic_pending or ability_lock > 0:
		return false
	if slot < 3 and cooldowns[slot] > 0:
		return false
	if slot == 3:
		if active_rune < 0:
			return false
		if active_rune == 0:
			hp = minf(max_hp,hp+65)
			arena.combat_fx(global_position,"heal",Color("81ecb5"),1.0)
		else:
			arena.area_damage(self,global_position,4.2,24*damage_scale(),.45,2.5)
			arena.combat_fx(global_position,"shock",Color("88c7ff"),4.2)
		abilities_used[3] += 1
		active_rune = -1
		active_time = 0
		cancel_prepare()
		ability_lock = .15
		animator.cast()
		arena.sound.play("rune",global_position)
		return true
	if hero == "warrior":
		match slot:
			0:
				dash_direction = forward_flat()
				dash_time = .27
			1:
				guard_time = 2.5
			2:
				arena.area_damage(self,global_position,3.8,38*damage_scale(),.35,2.5)
				arena.combat_fx(global_position,"shock",Color("e2bd7c"),3.8)
	else:
		match slot:
			0:
				arena.shoot(self,aim_point,27*damage_scale(),true)
			1:
				var direction := move_axis_world.normalized() if move_axis_world.length() > .1 else forward_flat()
				var before := global_position
				var hit := KinematicCollision3D.new()
				var travel := direction*5.5
				if test_move(global_transform,travel,hit):
					travel = hit.get_travel()
				global_position += travel
				arena.combat_fx(before,"teleport",Color("a49ce8"),.8)
				arena.combat_fx(global_position,"teleport",Color("a49ce8"),.8)
			2:
				var target := ground_target(14)
				if not target.valid:
					if human:
						arena.hud.notify("MIRE NO CHÃO, SEM OBSTÁCULOS",1)
					return false
				arena.spawn_field(self,target.point)
	abilities_used[slot] += 1
	cooldowns[slot] = stats.cooldowns[slot]
	ability_lock = .18
	if hero != "warrior" or slot != 1:
		animator.cast()
	var skill_sound: String = ["dash","block","seismic"][slot] if hero == "warrior" else ["orb","blink","frost"][slot]
	arena.sound.play(skill_sound,global_position)
	cancel_prepare()
	return true

func update_indicator() -> void:
	path_indicator.hide()
	movement_preview_blocked = false
	if preparing < 0:
		aim_indicator.hide()
		if human or basic_pending:
			show_basic_aim()
		return
	aim_indicator.show()
	aim_indicator.position = Vector3(0,.05,0)
	aim_indicator.scale = Vector3.ONE
	var color := Color(.35,.85,.8,.22)
	if preparing == 3:
		aim_indicator.scale = Vector3(4.2,1,4.2)
	elif hero == "mage" and preparing == 2:
		var ground := ground_target(14)
		aim_indicator.global_position = ground.point+Vector3.UP*.05
		aim_indicator.scale = Vector3(3.6,1,3.6)
		if not ground.valid:
			color = Color(1,.25,.2,.25)
	elif (hero == "warrior" and preparing == 0) or (hero == "mage" and preparing == 1):
		var dir := forward_flat()
		if hero == "mage" and move_axis_world.length() > .1:
			dir = move_axis_world.normalized()
		var motion := dir*(6.2 if hero == "warrior" else 5.5)
		var collision := KinematicCollision3D.new()
		if test_move(global_transform,motion,collision):
			motion = collision.get_travel()
		aim_indicator.global_position = global_position+motion+Vector3.UP*.05
		aim_indicator.scale = Vector3(.7,1,.7)
		movement_preview_blocked = motion.length() < .2
		if movement_preview_blocked:
			color = Color(1,.25,.2,.35)
		show_path_preview(global_position,global_position+motion,color)
	elif hero == "warrior":
		aim_indicator.scale = Vector3(3.8,1,3.8)
	else:
		# Projection of orb path, shortened by nearby cover from the cast origin.
		var from := global_position+Vector3.UP*1.2
		var point := from+(aim_point-from).normalized()*18
		var excluded: Array[RID] = []
		for friend in arena.fighters:
			if friend.team == team:
				excluded.append(friend.get_rid())
		var hit := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,point,3,excluded))
		if not hit.is_empty():
			point = hit.position
		aim_indicator.global_position = Vector3(point.x,.05,point.z)
		aim_indicator.scale = Vector3(2.6,1,2.6)
		show_path_preview(global_position,Vector3(point.x,global_position.y,point.z),color)
	aim_indicator.material_override.albedo_color = color

func show_basic_aim() -> void:
	var reach: float = stats.range
	var color := Color("ff946d") if aim_obstructed else Color("8be8df")
	if not human:
		color = RiftRules.team_color(team)
	if hero == "warrior":
		show_path_preview(global_position,global_position+forward_flat()*reach,color)
		return
	var origin := global_position+Vector3.UP*1.2
	var point := origin+(aim_point-origin).normalized()*reach
	var excluded: Array[RID] = []
	for ally in arena.fighters:
		if ally.team == team: excluded.append(ally.get_rid())
	var hit := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,point,3,excluded))
	if not hit.is_empty(): point = hit.position
	show_path_preview(origin,point,color)
	# Projectiles and this guide share the same launch plane.
	path_indicator.global_position.y = origin.y
	path_indicator.material_override.albedo_color.a = .22 if human else .65

func show_path_preview(from: Vector3,to: Vector3,color: Color) -> void:
	from.y = .07
	to.y = .07
	var length := from.distance_to(to)
	if length < .05:
		return
	path_indicator.show()
	path_indicator.global_position = (from+to)*.5
	path_indicator.look_at(to,Vector3.UP)
	path_indicator.scale = Vector3(.055,.015,length)
	path_indicator.material_override.albedo_color = Color(color,.65)

func apply_slow(strength: float, duration: float) -> void:
	# Strongest slow wins; durations refresh instead of multiplying effects.
	slow_power = maxf(slow_power,strength)
	slow_time = maxf(slow_time,duration)

func take_damage(amount: float, source: Node3D, origin: Vector3, environmental: bool = false) -> void:
	if not alive or not arena.active:
		return
	var blocked := false
	if not environmental:
		if source != null and source.team == team:
			return
		if guard_time > 0:
			var offset := origin-global_position
			offset.y = 0
			if offset.length() > .01 and forward_flat().dot(offset.normalized()) >= cos(deg_to_rad(65)):
				amount *= .25
				blocked = true
		if passive == 2:
			amount *= .7
	var applied := minf(hp,maxf(0,amount))
	damage_taken += applied
	if not environmental and source is RiftFighter:
		source.damage_dealt += applied
	hp = maxf(0,hp-applied)
	hit_flash = .12
	if not environmental and reaction_clock <= 0:
		reaction_clock = .22
		# Damage feedback must not visually cancel an attack or a cast.
		if not blocked and basic_clock <= 0 and ability_lock <= 0:
			animator.hurt()
		arena.sound.play("block" if blocked else "hit",global_position)
	if not environmental:
		if source != null and source.human:
			arena.hud.hit_confirm(blocked)
	if hp <= 0 and arena.practice_mode and not human:
		hp = max_hp
		arena.hud.notify("ALVO RESTAURADO",.6)
	if arena.practice_mode and not human:
		hp_bar.scale.x = maxf(.001,hp/max_hp)
		caption.text = "ALVO · %d" % ceili(hp)
	if hp <= 0:
		if not environmental and source is RiftFighter:
			source.eliminations += 1
		alive = false
		collision_layer = 0
		collision_mask = 0
		cancel_prepare()
		basic_pending = false
		guard_time = 0
		dash_time = 0
		passive = -1
		active_rune = -1
		passive_time = 0
		active_time = 0
		nameplate.hide()
		guard_visual.hide()
		attack_visual.hide()
		animator.die()
		arena.sound.play("death",global_position)
		arena.on_death(self)

func collect_rune(category: int, kind: int) -> void:
	if not alive:
		return
	runes_collected += 1
	if category == 0:
		passive = kind
		passive_time = RiftRules.RUNE_DURATION
	else:
		if preparing == 3:
			cancel_prepare()
		active_rune = kind
		active_time = RiftRules.RUNE_HOLD
	arena.sound.play("rune",global_position)
	if human:
		arena.hud.notify("RUNA: "+(RiftRules.PASSIVES[kind] if category == 0 else RiftRules.ACTIVES[kind]),2)
