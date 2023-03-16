extends KinematicBody2D

onready var _animation_player = $AnimationPlayer
onready var _walking_sprite = $Walking
onready var _idle_sprite = $Idle

func _process(_delta):
	if Input.is_action_pressed("ui_right"):
		_idle_sprite.hide()
		_walking_sprite.show()
		_animation_player.play("run")
	else:
		_walking_sprite.hide()
		_idle_sprite.show()
		_animation_player.play("idle")
