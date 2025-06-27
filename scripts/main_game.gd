extends Node2D

@onready var goal_label: Label = $Goal/GoalLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_goal_body_entered(body: Node2D) -> void:
	print("Player entered the goal zone!")



func _on_goal_body_exited(body: Node2D) -> void:
	print("Player exited the goal zone!")
