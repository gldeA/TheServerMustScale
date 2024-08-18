extends Area2D

@export var good_file: PackedScene
@export var bad_file: PackedScene

var collision_count: int = 0
var timer: float = 5.0
var timer_enabled: float = 0.0

func _process(delta):
	timer -= timer_enabled * delta

func _on_moveable_item_empty() -> void:
	var i = randi() % len($/root/Root.input_pipes)
	position = $/root/Root/TopTileMapLayer.map_to_local($/root/Root.input_pipes[i])
	timer = 5.0
	$MoveableItem.stop = false

func _on_moveable_item_deleter() -> void:
	$/root/Root.spawn_counts["download"] -= 1
	$/root/Root.add_coins(-40)
	queue_free()

func _on_moveable_item_output() -> void:
	$/root/Root.spawn_counts["download"] -= 1
	$/root/Root.add_coins(-40)
	queue_free()

func _on_moveable_item_server() -> void:
	$/root/Root.spawn_counts["download"] -= 1
	$/root/Root.add_coins(-40)
	queue_free()

func _on_moveable_item_storage() -> void:
	$MoveableItem.stop = true
	
	if collision_count > 0:
		timer = 7.0
		timer_enabled = 0.0
		return
	timer_enabled = 1.0
	if timer > 0.0:
		return
	
	$/root/Root.spawn_counts["download"] -= 1
	
	var randval = randi() % 4
	var instance
	if randval != 0:
		instance = good_file.instantiate()
		instance.modulate = Color(0.8, 0.8, 0.8)
		instance.value = 40
		$/root/Root.spawn_counts["return"] += 1
	else:
		instance = bad_file.instantiate()
		$/root/Root.spawn_counts["bad"] += 1
	instance.position = position
	$/root/Root/Requests.add_child(instance)
	
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bad") or area.is_in_group("return"):
		collision_count += 1

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("bad") or area.is_in_group("return"):
		collision_count -= 1
