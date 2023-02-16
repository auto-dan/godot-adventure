extends KinematicBody2D


const ACCELERATION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 125
const FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}


var state
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	animation_tree.active = true
	state = MOVE


func _physics_process(delta):
	match state:
		MOVE: 
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)


func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("roll")
	move()
	
func roll_finished():
	# enable/disable this for no slide
	velocity = velocity / 2
	state = MOVE


func attack_state(delta):
	velocity = Vector2.ZERO
	animation_state.travel("attack")


func attack_finished():
	state = MOVE


func move():
	velocity = move_and_slide(velocity)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		# only setting roll vector here so it can't be zero, don't wanna roll in place!
		# additionally, after playing, the vector will be saved as the roll vector so we know which way the player is facing
		roll_vector = input_vector
		# animation
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/run/blend_position", input_vector)
		animation_tree.set("parameters/attack/blend_position", input_vector)
		animation_tree.set("parameters/roll/blend_position", input_vector )
		# setting final velocity
		animation_state.travel("run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("idle")
		# friction stop
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# physical movement
	move()

	if Input.is_action_just_pressed("roll"):
		state = ROLL

	if Input.is_action_just_pressed("attack"):
		state = ATTACK

