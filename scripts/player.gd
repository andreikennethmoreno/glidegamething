extends CharacterBody2D

# === CONSTANTS ===
const SPEED = 100.0
const JUMP_VELOCITY = -560.0
const SPLAT_FALL_THRESHOLD = 150.0
const WALL_JUMP_PUSH = -100
const NORMAL_GRAVITY_SCALE = 1.0
const GLIDE_GRAVITY_SCALE = 0.2
const JUMP_COOLDOWN_TIME := 1.0  # Seconds

# === STATE VARIABLES ===
var input_enabled := true
var is_dead := false
var is_hit := false
var knockback_timer := 0.3
var _suffocating := false
var can_grab := false
var is_grabbing := false
var splat_timer := 0.0
var gravity_scale := NORMAL_GRAVITY_SCALE
var jumped_from_grab := false
var last_wall_direction := 0
var can_regrab := true
var is_gliding := false
var can_jump := true

# === JUMP COOLDOWN TRACKING ===
var jump_in_cooldown := false
var current_jump_cooldown := 0.0

# === NODES ===
@onready var animated_sprite: AnimatedSprite2D = $CharacterSprite
@onready var jump_timer: Timer = $JumpTimer
@onready var jump_progress_bar: TextureProgressBar = $JumpProgressBar
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var h = total_seconds / 3600
	var m = (total_seconds % 3600) / 60
	var s = total_seconds % 60
	return "%02d:%02d:%02d" % [h, m, s]

func _ready():
	Save.is_playing = true

func _physics_process(delta: float) -> void:
	Save.current_y_position = global_position.y
	var formatted_time = format_time(Save.play_timer)
	var height_meters = "%.2f" % abs(Save.current_y_position)

	var was_on_floor = is_on_floor()

	if not input_enabled or is_dead or _suffocating:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if splat_timer > 0.0:
		splat_timer -= delta
		move_and_slide()
		return

	# === JUMP ===
	if Input.is_action_just_pressed("jump") and can_jump:
		if is_grabbing:
			velocity = Vector2.ZERO
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSH * last_wall_direction
			jumped_from_grab = true
			is_grabbing = false
			can_regrab = false
			_enable_grab_delay()
			print("Wall jump from grab!")
			Save.jump_count += 1
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
			print("Jumped")
			Save.jump_count += 1

		can_jump = false
		Save.flap_count += 1

		# Start cooldown manually
		jump_in_cooldown = true
		current_jump_cooldown = JUMP_COOLDOWN_TIME

	# === UPDATE JUMP PROGRESS BAR ===
	if jump_in_cooldown:
		current_jump_cooldown -= delta
		if current_jump_cooldown <= 0:
			current_jump_cooldown = 0
			jump_in_cooldown = false
			can_jump = true

		var progress = (1.0 - (current_jump_cooldown / JUMP_COOLDOWN_TIME)) * 100.0
		jump_progress_bar.value = progress
	else:
		jump_progress_bar.value = 100.0

	# === GRAB LOGIC ===
	if can_grab and can_regrab and not jump_in_cooldown and Input.is_action_pressed("grab_hold"):
		if not is_grabbing:
			print("Grabbing!")
			Save.grab_count += 1
		is_grabbing = true
		velocity = Vector2.ZERO
		move_and_slide()
		animated_sprite.play("grab")
		return
	else:
		if is_grabbing:
			print("Released grab.")
		is_grabbing = false

	# === APPLY GRAVITY ===
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	# === GLIDE LOGIC ===
	if not is_on_floor():
		var falling = velocity.y > 0 and not is_grabbing and not jumped_from_grab
		if falling:
			if not is_gliding:
				print("Gliding!")
			gravity_scale = GLIDE_GRAVITY_SCALE
			is_gliding = true
		else:
			gravity_scale = NORMAL_GRAVITY_SCALE
			is_gliding = false
	else:
		if is_gliding:
			print("Landed - reset glide")
		gravity_scale = NORMAL_GRAVITY_SCALE
		is_gliding = false

	# === HORIZONTAL MOVEMENT ===
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, SPEED)

	# === SPRITE FLIP ===
	if direction != 0:
		animated_sprite.flip_h = direction < 0

	# === ANIMATION ===
	if not is_grabbing:
		if is_on_floor():
			animated_sprite.play("idle" if direction == 0 else "run")
		else:
			animated_sprite.play("jump")

	# === MOVE CHARACTER ===
	var previous_vertical_velocity = velocity.y
	move_and_slide()

	# === LANDING & SPLAT ===
	if is_on_floor() and not was_on_floor:
		if previous_vertical_velocity > SPLAT_FALL_THRESHOLD:
			animated_sprite.play("splat")
			splat_timer = 0.3
			print("SPLAT!")
			Save.fall_count += 1
			hit_sound.play()
		else:
			print("Safe landing.")
		print("Landed")

	# === RESET jumped_from_grab ===
	if was_on_floor and not is_on_floor():
		jumped_from_grab = false

# === DELAY RE-GRAB AFTER WALL JUMP ===
func _enable_grab_delay() -> void:
	await get_tree().create_timer(0.2).timeout
	can_regrab = true

# (Removed _on_jump_timer_timeout — no longer needed)

func _on_grab_area_body_entered(body: Node2D) -> void:
	if body.name == "Grab":
		can_grab = true
		last_wall_direction = sign(global_position.x - body.global_position.x)
		print("Entered grab area, wall direction:", last_wall_direction)

func _on_grab_area_body_exited(body: Node2D) -> void:
	if body.name == "Grab":
		can_grab = false
		is_grabbing = false
		print("Exited grab area")
