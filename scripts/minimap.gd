class_name RiftMinimap
extends Control
var arena: Node3D
func map_point(point: Vector3) -> Vector2:
	return Vector2(10,24)+(Vector2(point.x,point.z)+RiftRules.MAP_HALF)/(RiftRules.MAP_HALF*2)*Vector2(size.x-20,size.y-34)
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(.025,.05,.07,.9))
	draw_rect(Rect2(Vector2(10,24),Vector2(size.x-20,size.y-34)),Color("334b43"))
	for rect in arena.obstacles:
		draw_rect(Rect2(map_point(Vector3(rect.position.x,0,rect.position.y)),rect.size/(RiftRules.MAP_HALF*2)*Vector2(size.x-20,size.y-34)),Color("899384"))
	if arena.elapsed >= RiftRules.ZONE_START:
		var begin := map_point(Vector3(-arena.zone_half.x,0,-arena.zone_half.y))
		var end := map_point(Vector3(arena.zone_half.x,0,arena.zone_half.y))
		draw_rect(Rect2(begin,end-begin),Color("f6a87d"),false,2)
	for rune in arena.runes:
		draw_circle(map_point(rune.global_position),3,Color("e2cf8d") if rune.category == 0 else Color("91bcff"))
	for f in arena.fighters:
		if f.alive:
			var point := map_point(f.global_position)
			draw_circle(point,4.0 if f.human else 3.0,Color.WHITE if f.human else RiftRules.team_color(f.team))
			if f.human:
				var forward: Vector3 = f.forward_flat()
				draw_line(point,point+Vector2(forward.x,forward.z)*8,Color.WHITE,1)
