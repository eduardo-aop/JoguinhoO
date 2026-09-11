class_name RiftArena
extends Node3D

var settings := TrainingSettings.new()
var batch_decoration_enabled := true
var sound: RiftSound
var fighters: Array[RiftFighter] = []
var runes: Array[RiftRune] = []
var obstacles: Array[Rect2] = []
var effects: Node3D
var actors: Node3D
var player: RiftFighter
var rig: ThirdPersonRig
var spectator: RiftFighter
var hud: RiftHUD
var overview: Camera3D
var practice_mode := false
var active := false
var elapsed := 0.0
var countdown := -1.0
var round_number := 0
var score := [0,0]
var result := ""
var selected_hero := "warrior"
var win_queued := false
var grid := AStarGrid2D.new()
var zone_half := RiftRules.MAP_HALF
var zone_visuals: Array[MeshInstance3D] = []
var zone_floors: Array[MeshInstance3D] = []
var rune_sites := [Vector3(-13,0,-12),Vector3(13,0,12),Vector3(-13,0,12),Vector3(13,0,-12),Vector3(-3,0,0),Vector3(3,0,0)]
var rune_markers: Array[MeshInstance3D] = []
var next_runes := RiftRules.RUNE_FIRST
var rune_wave := 0
var round_stats: Array[Dictionary] = []

func _ready() -> void:
	randomize()
	TrainingSettings.register_movement_actions()
	settings.load_preferences()
	build_world()
	sound = RiftSound.new()
	sound.arena = self
	add_child(sound)
	actors = Node3D.new()
	actors.name = "Combatants"
	add_child(actors)
	effects = Node3D.new()
	effects.name = "RoundEffects"
	add_child(effects)
	hud = RiftHUD.new()
	hud.arena = self
	add_child(hud)

func build_world() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var mat := ProceduralSkyMaterial.new()
	mat.sky_top_color = Color("253746")
	mat.sky_horizon_color = Color("8ba3a7")
	mat.ground_bottom_color = Color("253734")
	mat.ground_horizon_color = Color("8ba3a7")
	sky.sky_material = mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("b6c6d6")
	env.ambient_light_energy = .48
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-38,0)
	sun.light_energy = .85
	sun.light_color = Color("ffe3b8")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 90
	add_child(sun)
	var floor_mesh := TrainingVisuals.box(self,Vector3(49,.8,41),Vector3(0,-.4,0),Color("445d57"),true)
	var floor_mat := ShaderMaterial.new()
	floor_mat.shader = load("res://shaders/courtyard.gdshader")
	floor_mesh.material_override = floor_mat
	for x in [-24.5,24.5]:
		TrainingVisuals.box(self,Vector3(1,3.2,42),Vector3(x,1.6,0),Color("485952"),true)
	for z in [-20.5,20.5]:
		TrainingVisuals.box(self,Vector3(50,3.2,1),Vector3(0,1.6,z),Color("485952"),true)
	for x in range(-24,25,6):
		for z in [-20,20]:
			TrainingVisuals.box(self,Vector3(.7,4.5,.7),Vector3(x,2.25,z),Color("6d7260"))
	FantasyWorld.decorate(self)
	grid.region = Rect2i(-24,-20,49,41)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for x in [-8,8]:
		for z in [-7,7]:
			var rect := Rect2(x-1.75,z-2.5,3.5,5)
			obstacles.append(rect)
			var cover := TrainingVisuals.box(self,Vector3(3.5,2.7,5),Vector3(x,1.35,z),Color("53675e"),true)
			var stone_material := ShaderMaterial.new()
			stone_material.shader = load("res://shaders/ruin_stone.gdshader")
			cover.material_override = stone_material
			TrainingVisuals.box(self,Vector3(3.65,.12,5.15),Vector3(x,2.76,z),Color("92856a"))
			for gx in range(x-3,x+4):
				for gz in range(z-4,z+5):
					grid.set_point_solid(Vector2i(gx,gz))
	for side in [-1,1]:
		TrainingVisuals.ring(self,3,Vector3(side*18,.04,0),RiftRules.team_color(0 if side == -1 else 1))
	for point in rune_sites:
		rune_markers.append(TrainingVisuals.ring(self,1.3,point+Vector3.UP*.03,Color("918c68")))
	for i in 4:
		var wall := TrainingVisuals.box(self,Vector3.ONE,Vector3.ZERO,Color(.85,.2,.12,.15))
		wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		wall.hide()
		zone_visuals.append(wall)
		var danger_floor := TrainingVisuals.box(self,Vector3.ONE,Vector3.ZERO,Color(.9,.15,.08,.22))
		danger_floor.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		danger_floor.hide()
		zone_floors.append(danger_floor)
	overview = Camera3D.new()
	add_child(overview)
	overview.position = Vector3(0,28,30)
	overview.look_at(Vector3.ZERO)
	overview.current = true

func clear_round() -> void:
	sound.reset()
	active = false
	countdown = -1
	get_tree().paused = false
	if is_instance_valid(rig):
		rig.get_parent().remove_child(rig)
		rig.queue_free()
		rig = null
	for node in actors.get_children():
		actors.remove_child(node)
		node.queue_free()
	for node in effects.get_children():
		effects.remove_child(node)
		node.queue_free()
	fighters.clear()
	runes.clear()
	player = null
	spectator = null
	zone_half = RiftRules.MAP_HALF
	for v in zone_visuals+zone_floors:
		v.hide()
	for marker in rune_markers:
		marker.material_override.albedo_color = Color("918c68")
		marker.scale = Vector3.ONE
	win_queued = false

func start_round(hero_choice: String = "warrior", skip_countdown: bool = false, practice: bool = false) -> void:
	clear_round()
	practice_mode = practice
	selected_hero = hero_choice
	round_number += 1
	elapsed = 0
	next_runes = RiftRules.RUNE_FIRST
	rune_wave = 0
	result = ""
	for team in 2:
		for index in 3:
			var f := RiftFighter.new()
			f.arena = self
			f.team = team
			f.human = team == 0 and index == 1
			f.hero = hero_choice if f.human else ("warrior" if index != 2 else "mage")
			actors.add_child(f)
			f.position = Vector3(-18 if team == 0 else 18,.01,(index-1)*4)
			f.rotation.y = -PI/2 if team == 0 else PI/2
			fighters.append(f)
			if f.human:
				player = f
	if practice_mode:
		player.position = Vector3(0,.01,6)
		for i in fighters.size():
			var f := fighters[i]
			if not f.human:
				f.set_physics_process(false)
				f.position = Vector3((i-4)*4,.01,-2) if f.team == 1 else Vector3(-15,.01,(i-1)*4)
				f.rotation.y = PI
	rig = ThirdPersonRig.new()
	rig.settings = settings
	rig.actor = player
	add_child(rig)
	overview.current = false
	rig.camera.current = true
	countdown = -1.0 if skip_countdown else 3.0
	active = skip_countdown
	hud.close_menu()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(dt: float) -> void:
	if countdown >= 0:
		countdown -= dt
		if countdown < 0:
			active = true
	if not active:
		return
	elapsed += dt
	if elapsed >= next_runes:
		spawn_runes()
		next_runes += RiftRules.RUNE_INTERVAL
	update_rune_warning()
	if not practice_mode:
		update_zone(dt)
	if is_instance_valid(rig) and is_instance_valid(rig.actor):
		rig.actor.model.visible = rig.model_visible
	if not practice_mode and elapsed >= RiftRules.ROUND_LIMIT:
		adjudicate()

func update_rune_warning() -> void:
	for i in rune_markers.size():
		var occupied := runes.any(func(existing): return existing.site == i)
		var warning := next_runes-elapsed <= RiftRules.RUNE_WARNING and not occupied
		rune_markers[i].material_override.albedo_color = Color("ffe394") if warning else Color("918c68")
		rune_markers[i].scale = Vector3.ONE*(1.0+sin(elapsed*6)*.12) if warning else Vector3.ONE

func spawn_runes() -> void:
	for i in rune_sites.size():
		if runes.any(func(existing): return existing.site == i):
			continue
		var r := RiftRune.new()
		r.arena = self
		r.site = i
		r.category = 0 if i < 4 else 1
		r.kind = (int(i/2.0)+rune_wave)%3 if r.category == 0 else rune_wave%2
		effects.add_child(r)
		r.position = rune_sites[i]
		runes.append(r)
	rune_wave += 1
	hud.notify("RUNAS DISPONÍVEIS · DISPUTE OS PONTOS",2)

func update_zone(dt: float) -> void:
	if elapsed < RiftRules.ZONE_START:
		return
	var t := clampf((elapsed-RiftRules.ZONE_START)/(RiftRules.ZONE_END-RiftRules.ZONE_START),0,1)
	zone_half = RiftRules.MAP_HALF.lerp(Vector2(2.5,2.5),t)
	for i in 4:
		zone_visuals[i].show()
		zone_floors[i].show()
	for i in 2:
		var sign_value := -1 if i == 0 else 1
		zone_visuals[i].position = Vector3(sign_value*zone_half.x,1.5,0)
		zone_visuals[i].scale = Vector3(.06,3,zone_half.y*2)
		zone_visuals[i+2].position = Vector3(0,1.5,sign_value*zone_half.y)
		zone_visuals[i+2].scale = Vector3(zone_half.x*2,3,.06)
		zone_floors[i].position = Vector3(sign_value*(24+zone_half.x)*.5,.025,0)
		zone_floors[i].scale = Vector3(maxf(.001,24-zone_half.x),.012,40)
		zone_floors[i+2].position = Vector3(0,.025,sign_value*(20+zone_half.y)*.5)
		zone_floors[i+2].scale = Vector3(zone_half.x*2,.012,maxf(.001,20-zone_half.y))
	for f in fighters:
		if f.alive and not inside_zone(f.global_position):
			f.take_damage((12+t*12)*dt,null,Vector3.ZERO,true)

func inside_zone(point: Vector3, margin: float = 0.0) -> bool:
	return absf(point.x) <= zone_half.x-margin and absf(point.z) <= zone_half.y-margin

func route(from: Vector3,to: Vector3) -> Array[Vector3]:
	var start := closest_free(Vector2i(roundi(from.x),roundi(from.z)))
	var end := closest_free(Vector2i(roundi(to.x),roundi(to.z)))
	var result_path: Array[Vector3] = []
	for point in grid.get_id_path(start,end,true):
		result_path.append(Vector3(point.x,0,point.y))
	if result_path.size() > 1:
		result_path.pop_front()
	return result_path

func closest_free(point: Vector2i) -> Vector2i:
	point.x = clampi(point.x,-23,23)
	point.y = clampi(point.y,-19,19)
	if not grid.is_point_solid(point):
		return point
	for radius in range(1,8):
		for x in range(-radius,radius+1):
			for y in range(-radius,radius+1):
				var p := point+Vector2i(x,y)
				if grid.is_in_boundsv(p) and not grid.is_point_solid(p):
					return p
	return Vector2i.ZERO

func line_clear(from: Vector3,to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from,to,1)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func nearest_enemy(actor: Node3D) -> RiftFighter:
	var best: RiftFighter = null
	var distance := INF
	for f in fighters:
		if f.alive and f.team != actor.team:
			var d := actor.global_position.distance_squared_to(f.global_position)
			if d < distance:
				best = f
				distance = d
	return best

func useful_rune(actor: Node3D) -> RiftRune:
	var best: RiftRune = null
	for rune in runes:
		if (rune.category == 0 and actor.passive_time > 3) or (rune.category == 1 and actor.active_rune >= 0):
			continue
		if not inside_zone(rune.global_position,1):
			continue
		if best == null or actor.global_position.distance_squared_to(rune.global_position) < actor.global_position.distance_squared_to(best.global_position):
			best = rune
	return best

func shoot(source: RiftFighter,target: Vector3,damage: float,explosive: bool) -> RiftProjectile:
	var bolt := RiftProjectile.new()
	bolt.arena = self
	bolt.owner_fighter = source
	if not explosive:
		sound.play("bolt",source.global_position,-4)
	bolt.damage = damage
	bolt.explosive = explosive
	bolt.remaining = 18 if explosive else 17
	var origin := source.global_position+Vector3.UP*1.2
	bolt.direction = (target-origin).normalized()
	if bolt.direction.length() < .01:
		bolt.direction = source.forward_flat()
	# Start at the body, not beyond it: close walls are checked on first travel.
	effects.add_child(bolt)
	bolt.global_position = origin
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = .22 if explosive else .12
	sphere.height = sphere.radius*2
	mesh.mesh = sphere
	mesh.material_override = TrainingVisuals.mat(Color("b698ef") if explosive else RiftRules.team_color(source.team),.5)
	bolt.add_child(mesh)
	return bolt

func area_damage(source: RiftFighter,center: Vector3,radius: float,damage: float,slow: float,duration: float) -> void:
	for f in fighters:
		if not f.alive or f.team == source.team:
			continue
		var target := f.global_position+Vector3.UP*.6
		var origin := center+Vector3.UP*.2
		if Vector2(f.global_position.x-center.x,f.global_position.z-center.z).length() <= radius and line_clear(origin,target):
			f.take_damage(damage,source,center)
			if slow > 0 and f.alive:
				f.apply_slow(slow,duration)

func spawn_field(source: RiftFighter,point: Vector3) -> RiftField:
	var field := RiftField.new()
	field.arena = self
	field.owner_fighter = source
	field.dps *= source.damage_scale()
	effects.add_child(field)
	field.global_position = point
	return field

func combat_fx(point: Vector3,kind: String,color: Color,radius: float,yaw: float = 0) -> RiftCombatFX:
	# Bound short-lived visual effects even during repeated area damage.
	var live := get_tree().get_nodes_in_group("transient_combat_fx")
	if live.size() >= 48:
		return null
	var fx := RiftCombatFX.new()
	fx.kind = kind
	fx.tint = color
	fx.radius = maxf(.15,radius)
	effects.add_child(fx)
	fx.global_position = point
	fx.rotation.y = yaw
	return fx

func burst(point: Vector3,color: Color,radius: float) -> void:
	combat_fx(point,"impact",color,radius)

func on_death(dead: RiftFighter) -> void:
	if dead == player or dead == spectator:
		cycle_spectator()
	if not win_queued:
		win_queued = true
		check_winner.call_deferred()

func cycle_spectator() -> void:
	var living: Array[RiftFighter] = []
	for f in fighters:
		if f.team == 0 and f.alive:
			living.append(f)
	if living.is_empty():
		return
	var old: RiftFighter = rig.actor
	var index := living.find(spectator)
	spectator = living[(index+1)%living.size()]
	if is_instance_valid(old):
		old.model.show()
	rig.actor = spectator
	rig.snap_to_actor()

func check_winner() -> void:
	win_queued = false
	if not active:
		return
	var living := living_counts()
	if living[0] == 0 or living[1] == 0:
		finish(-1 if living[0] == living[1] else (0 if living[0] > 0 else 1),"Eliminação")

func living_counts() -> Array[int]:
	var result_counts: Array[int] = [0,0]
	for f in fighters:
		if f.alive:
			result_counts[f.team] += 1
	return result_counts

func adjudicate() -> void:
	var living := living_counts()
	var health := [0.0,0.0]
	for f in fighters:
		if f.alive:
			health[f.team] += f.hp/f.max_hp
	var winner := -1
	if living[0] != living[1]:
		winner = 0 if living[0] > living[1] else 1
	elif absf(health[0]-health[1]) > .001:
		winner = 0 if health[0] > health[1] else 1
	finish(winner,"Limite de tempo: sobreviventes e vida proporcional")

func finish(winner: int,reason: String) -> void:
	if not active:
		return
	active = false
	if winner >= 0:
		score[winner] += 1
	result = "EMPATE" if winner < 0 else ("VITÓRIA" if winner == 0 else "DERROTA")
	var participants: Array[Dictionary] = []
	for f in fighters:
		participants.append({"team":f.team,"hero":f.hero,"human":f.human,"alive":f.alive,"hp":snappedf(f.hp,.1),"damage":snappedf(f.damage_dealt,.1),"damage_taken":snappedf(f.damage_taken,.1),"kills":f.eliminations,"runes":f.runes_collected,"abilities":f.abilities_used.duplicate()})
	round_stats.append({"round":round_number,"seconds":snappedf(elapsed,.1),"winner":winner,"reason":reason,"participants":participants})
	for f in fighters:
		f.cancel_prepare()
		f.guard_visual.hide()
		f.attack_visual.hide()
	hud.show_result(reason)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
