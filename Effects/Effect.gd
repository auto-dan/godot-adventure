extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	play("animate") # for some reason this is required??


func _on_animation_finished():
	queue_free()
