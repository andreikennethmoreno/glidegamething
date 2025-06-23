extends CharacterBody2D

# === CONSTANTS ===
const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const SPLAT_FALL_THRESHOLD = 150.0
const WALL_JUMP_PUSH = -100  # ← Horizontal push force

# === STATE VARIABLES ===
var input_enabled := true
var is_dead := false
var is_hit := false
var knockback_timer := 0.3
var _suffocating := false
var can_grab := false
var is_grabbing := false
var splat_timer := 0.0
var gravity_scale := 1.0
var jumped_from_grab := false
var last_wall_direction := 0  # -1 = right wall, 1 = left wall
var can_regrab := true  # ← Cooldown to prevent insta-grab after wall jump

# === NODES ===
@onready var animated_sprite: AnimatedSprite2D = $CharacterSprite
@onready var hit_sound: AudioStreamPlayer2D = $hit_sound
@onready var jump_timer: Timer = $JumpTimer

func _physics_process(delta: float) -> void:
	var was_on_floor = is_on_floor()

	# === Skip logic if can't move ===
	if not input_enabled or is_dead or _suffocating:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# === Splat timer pause ===
	if splat_timer > 0.0:
		splat_timer -= delta
		move_and_slide()
		return

	# === JUMP ===
	if Input.is_action_just_pressed("jump"):
		if is_grabbing:
			velocity = Vector2.ZERO
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSH * last_wall_direction
			jumped_from_grab = true
			is_grabbing = false
			can_regrab = false
			_enable_grab_delay()
			print("Wall jump from grab!")
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
			print("Jumped")

	# === GRAB LOGIC ===
	if can_grab and can_regrab and Input.is_action_pressed("grab_hold"):
		if not is_grabbing:
			print("Grabbing!")
		is_grabbing = true
		velocity = Vector2.ZERO
		move_and_slide()
		return
	else:
		if is_grabbing:
			print("Released grab.")
		is_grabbing = false

	# === GRAVITY ===
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	# === HORIZONTAL MOVEMENT ===
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, SPEED)

	# === SPRITE FLIP ===
	if direction != 0:
		animated_sprite.flip_h = direction < 0

	# === ANIMATION ===
	if is_on_floor():
		animated_sprite.play("idle" if direction == 0 else "run")
	else:
		animated_sprite.play("jump")

	# === SPLAT CHECK ===
	var is_falling = velocity.y > 0 and not is_on_floor()
	if is_falling:
		if is_on_floor() and velocity.y > SPLAT_FALL_THRESHOLD:
			animated_sprite.play("splat")
			splat_timer = 0.3
			print("SPLAT!")
		elif is_on_floor():
			print("Safe landing.")

	# === MOVE CHARACTER ===
	move_and_slide()

	# === LANDING RESET ===
	if is_on_floor() and not was_on_floor:
		print("Landed")

	# === RESET jumped_from_grab once off the ground ===
	if was_on_floor and not is_on_floor():
		jumped_from_grab = false

# === DELAY RE-GRAB AFTER WALL JUMP ===
func _enable_grab_delay() -> void:
	await get_tree().create_timer(0.2).timeout
	can_regrab = true

# === TIMERS ===
func _on_jump_timer_timeout() -> void:
	pass

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
