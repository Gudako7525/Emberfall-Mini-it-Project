class_name Player
extends CharacterBody2D


@export var speed : float = 150.0
@export var sprint_multiplier : float = 3.0
@export var animation_tree : AnimationTree

@export var inv: Inv

var bow_equiped = false
var bow_cooldown = true
var arrow = preload("res://scenes/arrow.tscn")

var input : Vector2
var playback : AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = animation_tree.get("parameters/playback")

func _physics_process(_delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down")
	
	var is_sprinting = Input.is_action_pressed("Run")
	
	var current_speed = speed
	if is_sprinting:
		current_speed *= sprint_multiplier

	var iso_input = Vector2(input.x * 2.0, input.y)
	
	velocity = iso_input.normalized() * current_speed

	move_and_slide()
	
	if Input.is_action_just_pressed("b"):
		if bow_equiped:
			bow_equiped = false
		else:
			bow_equiped = true	
	
	
	var mouse_pos = get_global_mouse_position()
	$Marker2D.look_at(mouse_pos)
	
	if Input.is_action_just_pressed("left_mouse") and bow_equiped and bow_cooldown:
		bow_cooldown = false
		var arrow_instance = arrow.instantiate()
		arrow_instance.rotation = $Marker2D.rotation
		arrow_instance.global_position = $Marker2D.global_position
		add_child(arrow_instance)
		
		await get_tree().create_timer(0.3).timeout
		bow_cooldown = true  
		
	select_animation(is_sprinting)
	update_animation_parameters()

func select_animation(is_sprinting: bool) -> void:
	if velocity == Vector2.ZERO:
		playback.travel("idle")
	else:
		if is_sprinting:
			playback.travel("walk")
		else:
			playback.travel("walk")

func update_animation_parameters() -> void:
	if input == Vector2.ZERO:
		return
	
	animation_tree["parameters/idle/blend_position"] = input
	animation_tree["parameters/walk/blend_position"] = input
	
	
func Player():
	pass
	
func collect(item):
	inv.insert(item)
