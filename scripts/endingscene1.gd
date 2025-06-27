extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label
@onready var yes_button: Button = $GridContainer/VBoxContainer/yes
@onready var no_button: Button = $GridContainer/VBoxContainer/no
@onready var nothing_button: Button = $GridContainer/VBoxContainer/nothing

var text_finished: bool = false
var selected_path: String = "res://scenes/main_menu.tscn"
var choice_made: bool = false

func _ready() -> void:
	yes_button.visible = false
	no_button.visible = false
	nothing_button.visible = false
	animation_player.connect("animation_finished", Callable(self, "_on_animation_player_animation_finished"))

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "typewriter_text":
		text_finished = true
		if not choice_made:
			yes_button.visible = true
			no_button.visible = true
			nothing_button.visible = true
		_check_and_transition()

func _hide_buttons() -> void:
	yes_button.visible = false
	no_button.visible = false
	nothing_button.visible = false

func _play_new_text(new_text: String) -> void:
	label.text = new_text
	text_finished = false
	animation_player.stop()
	animation_player.play("typewriter_text")

func _check_and_transition() -> void:
	if text_finished and choice_made:
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file(selected_path)

func _on_yes_pressed() -> void:
	if choice_made:
		return
	choice_made = true
	_hide_buttons()
	label.text = ""
	_play_new_text(
		"\"If we confess our sins, He is faithful and just to forgive us...\"\n— 1 John 1:9\n\nThe gate opens, and light takes you home."
	)

func _on_no_pressed() -> void:
	if choice_made:
		return
	choice_made = true
	_hide_buttons()
	label.text = ""
	_play_new_text(
		"\"My grace is sufficient for you, for my power is made perfect in weakness.\"\n— 2 Corinthians 12:9\n\nYou turn away, and find the strength to fly."
	)

func _on_nothing_pressed() -> void:
	if choice_made:
		return
	choice_made = true
	_hide_buttons()
	label.text = ""
	_play_new_text(
		"\"Be still, and know that I am God.\"\n— Psalm 46:10\n\nYou remain in silence, as Heaven waits with you."
	)
