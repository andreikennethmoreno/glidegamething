extends Area2D

var player_inside := false  # track if player is inside the finish zone

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("f"):
		Save.is_playing = false
		print("____________________________")
		print("Time taken: ", Save.play_timer)
		print("Current Y: ", Save.current_y_position)
		print("Number of falls: ", Save.fall_count)

		print("Number of grabs: ", Save.grab_count)
		print("____________________________")
		#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		get_tree().change_scene_to_file("res://scenes/endingscene1.tscn")

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player":
		player_inside = true
		print("Player reached the finish zone!")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
