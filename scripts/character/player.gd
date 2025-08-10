extends CharacterBody2D

@export var walk_speed = 200
@export var run_speed = 400
@export var max_health = 100
var current_speed = 200
var current_health = max_health
var score: int = 0

var last_direction = "front"
var is_moving = false
var is_attacking = false
var is_running = false
var is_mining = false
var is_taking_damage = false
var can_mine = false
var current_minable = null
var current_enemy = false

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var sprite_action = $Sprite2D2
@onready var score_label = $Camera2D/score_int
@onready var health_bar = $Camera2D/TextureProgressBar

@onready var bg_music = $"../music_cave"
@onready var sfx_attack = $"../sfx_attack"
@onready var sfx_take_dm = $"../sfx_damage"
@onready var sfx_mine = $"../sfx_mine"

func _ready() -> void:
	add_to_group("player")
	sprite_action.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	current_speed = walk_speed
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	if Global.pending_load_data:
		apply_saved_data(Global.pending_load_data)
		Global.pending_load_data = null
		
	bg_music.play()

func _physics_process(_delta) -> void:
	if is_mining:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	is_moving = false
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_d") - Input.get_action_strength("ui_a")
	input_vector.y = Input.get_action_strength("ui_s") - Input.get_action_strength("ui_w")
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		is_moving = true
	
	velocity = input_vector * current_speed
	
	move_and_slide()
	update_animation()


func _input(event):
	if event.is_action_pressed("ui_r"):
		toggle_run_mode()
	
	if event.is_action_pressed("ui_m") && !is_mining && !is_attacking && can_mine && current_minable:
		start_action("mining")
		sfx_mine.play()
	
	if event.is_action_pressed("ui_n") && !is_mining && !is_attacking:
		start_action("attack")
		sfx_attack.play()
	
	if event.is_action_pressed("ui_c"):
		load_data()
		
	if event.is_action_pressed("ui_v"):
		save_data()


func toggle_run_mode():
	is_running = !is_running
	current_speed = run_speed if is_running else walk_speed


func start_action(action_type):
	is_mining = (action_type == "mining")
	is_attacking = (action_type == "attack")
	
	sprite.visible = false
	sprite_action.visible = true
	
	if last_direction == "side":
		sprite_action.flip_h = !sprite.flip_h
	else:
		sprite_action.flip_h = false

	var anim_direction = last_direction

	if last_direction == "side":
		anim_direction = "side"
	
	animation_player.play(action_type + "_" + anim_direction)


func update_animation() -> void:
	if is_mining || is_attacking:
		return
	
	var animation_name: String = ""
	
	if is_moving:
		if abs(velocity.x) > abs(velocity.y):
			animation_name = "walk_side"
			sprite.flip_h = velocity.x < 0
			last_direction = "side"
		else:
			sprite.flip_h = false
			if velocity.y < 0:
				animation_name = "walk_back" 
				last_direction = "back"
			else:
				animation_name = "walk_front"
				last_direction = "front"
	else:
		match last_direction:
			"back":
				animation_name = "idle_back"
			"front":
				animation_name = "idle_front"
			"side":
				animation_name = "idle_side"
	
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)


func _on_animation_finished(anim_name):
	if anim_name.begins_with("mining_") || anim_name.begins_with("attack_"):
		if anim_name.begins_with("mining_") && current_minable:
			mine_mineral()
		
		is_mining = false
		is_attacking = false
		
		sprite.visible = true
		sprite_action.visible = false
		
		call_deferred("update_animation")


func mine_mineral():
	if current_minable:
		score += 1
		update_label()
		current_minable.queue_free()
		current_minable = null
		can_mine = false


func _on_healt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		is_taking_damage = true
		take_damage()

func _on_healt_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		is_taking_damage = false
		take_damage()

func take_damage():
	while is_taking_damage:
		sfx_take_dm.play()
		current_health -= 25
		health_bar.value = current_health
		
		if current_health == 0:
			get_tree().reload_current_scene()
			return
		
		if is_taking_damage == false:
			return
		await get_tree().create_timer(1.5).timeout
   
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		current_enemy = true
		damage_to_enemy(body)

func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		current_enemy = false
		damage_to_enemy(body)

func damage_to_enemy(body):
	while current_enemy:
		if is_attacking:
			body.is_died = true
			await get_tree().create_timer(.5).timeout
			body.queue_free()
			return
		await get_tree().create_timer(.5).timeout


func _on_next_scene_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/maps/level_2.tscn")


func update_label():
	score_label.text = str(score)


func save_data():
	var data = {
		"player": {
			"score": score,
			"health": current_health,
			"position": {
				"x": global_position.x,
				"y": global_position.y
			},
			"scene": get_tree().current_scene.scene_file_path
		}
	}

	Global.last_save_data = data
	
	var json_string = JSON.stringify(data, "\t")
	var file = FileAccess.open("res://data/data_player.json", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	print("Datos guardados correctamente")

func load_data():
	if FileAccess.file_exists("res://data/data_player.json"):
		var file = FileAccess.open("res://data/data_player.json", FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_text)
		
		if error == OK:
			process_loaded_data(json.get_data())
			return
		else:
			print("Error parseando JSON: ", json.get_error_message(), " en línea ", json.get_error_line())
	
	if Global.last_save_data:
		print("Usando datos de memoria")
		process_loaded_data(Global.last_save_data)
		return
	
	print("No se encontraron datos de guardado")

func process_loaded_data(data):
	if not data or not data.has("player"):
		print("Datos inválidos")
		return
		
	var player_data = data["player"]
	
	if get_tree().current_scene.scene_file_path != player_data["scene"]:
		Global.pending_load_data = player_data
		print("Cambiando a escena: ", player_data["scene"])
		get_tree().change_scene_to_file(player_data["scene"])
	else:
		apply_saved_data(player_data)


func apply_saved_data(player_data):
	print("Aplicando datos guardados...")
	global_position = Vector2(
		player_data["position"]["x"],
		player_data["position"]["y"]
	)
	current_health = player_data["health"]
	score = player_data["score"]
	update_label()
	health_bar.value = current_health
	print("Datos aplicados correctamente")
