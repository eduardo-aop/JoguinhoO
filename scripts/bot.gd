class_name RiftBot
extends RefCounted

var actor: Node3D
var timer := 0.0
var path: Array[Vector3] = []
var target: Node3D
var destination := Vector3.ZERO
var side := 1.0
var decision_offset := 0.0
var threat_clock := 0.0
var dodge_clock := 0.0
var dodge_direction := Vector3.ZERO

func _init(fighter: Node3D) -> void:
	actor = fighter
	side = -1.0 if randf() < .5 else 1.0
	decision_offset = randf()*0.25

func direction(dt: float) -> Vector3:
	timer -= dt
	if timer <= 0:
		timer = 0.25 + decision_offset
		target = choose_target()
		if not is_instance_valid(target):
			return Vector3.ZERO
		var offset: Vector3 = target.global_position-actor.global_position
		var dist := offset.length()
		var visible_target: bool = actor.arena.line_clear(actor.global_position+Vector3.UP,target.global_position+Vector3.UP)
		var facing_target := absf(angle_difference(actor.rotation.y,atan2(-offset.x,-offset.z))) < .3
		actor.aim_point = target.global_position+Vector3.UP*1.2
		destination = target.global_position
		if not actor.arena.inside_zone(actor.global_position,1.5):
			destination = Vector3.ZERO
		else:
			var rune: Node3D = actor.arena.useful_rune(actor)
			if rune != null and actor.global_position.distance_to(rune.global_position) < 8 and dist > 4:
				destination = rune.global_position
			elif actor.hero == "mage" and visible_target:
				if dist < 7 or (dist < 12 and actor.hp < actor.max_hp*.4):
					destination = choose_kite_position(target)
				elif dist < 12:
					var lateral := actor.global_position+offset.normalized().cross(Vector3.UP)*side*2.5
					destination = lateral if safe_destination(lateral) else choose_kite_position(target)
			elif actor.hero == "warrior" and visible_target and dist < 2.5:
				destination = actor.global_position
		path = actor.arena.route(actor.global_position,destination)
		if visible_target:
			# Survival tools take priority over a fresh attack or offensive spell.
			if actor.hero == "mage" and dist < 4 and actor.cooldowns[1] <= 0:
				var escape := choose_kite_position(target)-actor.global_position
				if escape.length() > .1:
					actor.move_axis_world = escape.normalized()
					actor.cast(1)
			elif actor.hero == "warrior" and facing_target and dist < 5 and actor.hp < actor.max_hp*.6:
				actor.cast(1)
		if visible_target and facing_target:
			if dist < float(actor.stats.range):
				actor.request_basic()
			if actor.hero == "warrior":
				if dist > 3.5 and dist < 9:
					actor.cast(0)
				if dist < 7 and actor.hp < actor.max_hp*0.75:
					actor.cast(1)
				if dist < 3.7:
					actor.cast(2)
			else:
				if dist < 18:
					actor.cast(0)
				if dist < 14:
					actor.cast(2)
		if actor.active_rune == 0 and actor.hp < actor.max_hp*0.7:
			actor.cast(3)
		elif actor.active_rune == 1 and dist < 4:
			actor.cast(3)
	if is_instance_valid(target) and target.alive:
		var offset: Vector3 = target.global_position-actor.global_position
		actor.rotation.y = rotate_toward(actor.rotation.y,atan2(-offset.x,-offset.z),dt*10)
		actor.aim_point = target.global_position+Vector3.UP*1.2
	while not path.is_empty() and actor.global_position.distance_to(path[0]) < .35:
		path.pop_front()
	var movement: Vector3 = (path[0]-actor.global_position).normalized() if not path.is_empty() else Vector3.ZERO
	movement.y = 0
	if movement.length() > .1:
		var route_direction := movement.normalized()
		for ally in actor.arena.fighters:
			if ally == actor or not ally.alive or ally.team != actor.team:
				continue
			var away: Vector3 = actor.global_position-ally.global_position
			away.y = 0
			if away.length() > .05 and away.length() < 1.35:
				movement += away.normalized()*(1.35-away.length())*.65
				# Passing on the right breaks symmetric head-on blocking between allies.
				if route_direction.dot(-away.normalized()) > .4:
					var tangent := Vector3(-route_direction.z,0,route_direction.x)
					if safe_destination(actor.global_position+tangent*.9):
						movement += tangent*1.1
	threat_clock -= dt
	dodge_clock = maxf(0,dodge_clock-dt)
	if threat_clock <= 0:
		threat_clock = .18+decision_offset*.2
		var escape := hazard_escape()
		if escape.length_squared() > .1:
			dodge_direction = escape
			dodge_clock = .25
	if dodge_clock > 0 and safe_destination(actor.global_position+dodge_direction):
		return dodge_direction
	return movement.normalized()

func choose_target() -> Node3D:
	var best: Node3D
	var best_score := INF
	for enemy in actor.arena.fighters:
		if not enemy.alive or enemy.team == actor.team:
			continue
		var score: float = actor.global_position.distance_to(enemy.global_position)
		if not actor.arena.line_clear(actor.global_position+Vector3.UP,enemy.global_position+Vector3.UP):
			score += 6
		score -= (1-enemy.hp/enemy.max_hp)*2
		if enemy == target:
			score -= 1.2
		if score < best_score:
			best = enemy
			best_score = score
	return best

func safe_destination(point: Vector3) -> bool:
	if absf(point.x) > 22.5 or absf(point.z) > 18.5 or not actor.arena.inside_zone(point,1):
		return false
	var cell := Vector2i(roundi(point.x),roundi(point.z))
	return actor.arena.grid.is_in_boundsv(cell) and not actor.arena.grid.is_point_solid(cell)

func choose_kite_position(enemy: Node3D) -> Vector3:
	var best: Vector3 = actor.global_position
	var best_score := -INF
	var away: Vector3 = actor.global_position-enemy.global_position
	var base_angle := atan2(away.z,away.x)
	for i in 12:
		var angle := base_angle+i*TAU/12*side
		var point: Vector3 = actor.global_position+Vector3(cos(angle),0,sin(angle))*3.5
		if not safe_destination(point):
			continue
		if not actor.arena.line_clear(actor.global_position+Vector3.UP,point+Vector3.UP):
			continue
		var distance: float = point.distance_to(enemy.global_position)
		var score := -absf(distance-8)
		var visible: bool = actor.arena.line_clear(point+Vector3.UP,enemy.global_position+Vector3.UP)
		if actor.hp < actor.max_hp*.4 and not visible:
			score += 3
		elif not visible:
			score -= 3
		if distance < 4:
			score -= 8
		if score > best_score:
			best_score = score
			best = point
	return best

func hazard_escape() -> Vector3:
	# Sample visible hazards on a reaction cadence, not every physics tick.
	for hazard in actor.arena.effects.get_children():
		if not (hazard is RiftField or hazard is RiftProjectile): continue
		if not is_instance_valid(hazard.owner_fighter) or hazard.owner_fighter.team == actor.team: continue
		var offset: Vector3 = actor.global_position-hazard.global_position
		offset.y = 0
		if hazard is RiftField:
			if offset.length() < hazard.radius+.45:
				var away := offset.normalized() if offset.length() > .1 else Vector3.RIGHT
				return clear_escape(away)
		elif offset.length() < 9 and actor.arena.line_clear(actor.global_position+Vector3.UP,hazard.global_position):
			var travel: Vector3 = hazard.direction*hazard.speed
			travel.y = 0
			var relative := travel-Vector3(actor.velocity.x,0,actor.velocity.z)
			if relative.length_squared() < .01: continue
			var impact_time := offset.dot(relative)/relative.length_squared()
			if impact_time < .08 or impact_time > .65 or impact_time*hazard.speed > hazard.remaining: continue
			if (offset-relative*impact_time).length() > .85: continue
			var lateral := Vector3(-travel.z,0,travel.x).normalized()*side
			var escape := clear_escape(lateral)
			if escape.length_squared() > .1: return escape
	return Vector3.ZERO

func clear_escape(escape_direction: Vector3) -> Vector3:
	for candidate in [escape_direction,-escape_direction]:
		var point: Vector3 = actor.global_position+candidate*1.8
		if safe_destination(point) and actor.arena.line_clear(actor.global_position+Vector3.UP,point+Vector3.UP):
			return candidate
	return Vector3.ZERO
