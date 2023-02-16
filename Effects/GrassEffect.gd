extends Node2D

onready var animatedSprite = $AnimatedSprite

func _ready():
	animatedSprite.frame = 0
	animatedSprite.play("Animate") # for some reason this is required??

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		animatedSprite.play("Animate")


func _on_AnimatedSprite_animation_finished():
	queue_free()
