extends Node2D

@onready var hitbox = $Area2D
# Referencia al jugador cuando entra en el área
var player_ref = null

func _ready():
	hitbox.connect("body_entered", _on_body_entered)
	hitbox.connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.name == "player":  # Asegúrate que el nombre de tu jugador sea "player"
		player_ref = body
		player_ref.can_mine = true
		player_ref.current_minable = self

func _on_body_exited(body):
	if body == player_ref:
		player_ref.can_mine = false
		player_ref.current_minable = null
		player_ref = null
