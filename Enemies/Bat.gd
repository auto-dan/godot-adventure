extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_RANGE = 6

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocty = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE
var collison_force = 400  # <-- the higher the value the less lightly they overlap

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController
onready var animation_player = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

	match state:
		IDLE:
			velocty = velocty.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_and_switch_state()
			if wander_controller.get_time_left() == 0:
				update_wander()

		WANDER:
			seek_and_switch_state()
			if wander_controller.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= WANDER_RANGE:
				update_wander()

		CHASE:
			var player = player_detection_zone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
				var direction = global_position.direction_to(player.global_position)
				velocty = velocty.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			# sprite.flip_h = velocty.x < 0
	if soft_collision.is_colliding():
		velocty += soft_collision.get_push_vector() * delta * collison_force
	velocty = move_and_slide(velocty)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocty = velocty.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocty.x < 0

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(rand_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func seek_and_switch_state():
	seek_player()
	if wander_controller.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wander_controller.start_wander_timer(rand_range(1, 3))

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_started():
	animation_player.play("start")

func _on_Hurtbox_invincibility_ended():
	animation_player.play("stop")
