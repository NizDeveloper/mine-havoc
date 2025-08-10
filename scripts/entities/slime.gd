extends CharacterBody2D

@export var healt = 50
@export var speed = 2

var player = null
var move = Vector2.ZERO
var is_died = false

@onready var animation = $AnimationPlayer

func _ready() -> void:
	add_to_group("enemy")

func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func _physics_process(delta):
	if player != null && is_died == false:
		animation.play("walk")
		move = position.direction_to(player.position)
	else:
		move = Vector2.ZERO
	
	move = move.normalized() * speed
	move = move_and_collide(move)
	
	if is_died:
		move = Vector2.ZERO
		animation.play("die")
