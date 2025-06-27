extends Node2D

@onready var goal_label: Label = $Goal/GoalLabel
@onready var how_to_play: Label = $HowTo/HowToPlay
@onready var bg_music: AudioStreamPlayer = $BgMusic


func _ready() -> void:
	goal_label.visible = false  # Hide it initially
	how_to_play.visible = false
	bg_music.play()
func _on_goal_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Optional: make sure only the player triggers this
		print("Player entered the goal zone!")
		goal_label.visible = true
		#how_to_play.text = "Space – Jump (when halo is lit)\nShift – Grab walls\nGlide after jump.\nFalling hurts.\nWait ~2s to flap again."


func _on_goal_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("Player exited the goal zone!")
		goal_label.visible = false


func _on_how_to_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		how_to_play.visible = true


func _on_how_to_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		how_to_play.visible = false
