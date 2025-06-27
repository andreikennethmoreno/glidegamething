extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var text_finished: bool = false
var timer_started: bool = false
var elapsed_time: float = 0.0
const WAIT_DURATION: float = 0.5

func _ready() -> void:
	animation_player.play("typewriter_text")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "typewriter_text":
		text_finished = true
		timer_started = true  # Start the artificial timer
	print("Number of goals: ", Save.goal_count)

func _process(delta: float) -> void:
	if timer_started:
		print("Timer started... elapsed:", elapsed_time)
		elapsed_time += delta
		if elapsed_time >= WAIT_DURATION:
			print("Changing scene to main_game.tscn")
			get_tree().change_scene_to_file("res://scenes/main_game.tscn")
