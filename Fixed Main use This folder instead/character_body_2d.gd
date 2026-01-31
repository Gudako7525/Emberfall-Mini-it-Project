class_name player
extends CharacterBody2D

@export var speed : float = 300.0
@export var sprint_multiplier : float = 2.0
@export var animation_tree : AnimationTree
@export var inv: Inv

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

# This allows the chest and other items to identify the player
func Player():
	pass
	
# This function is what the chest is looking for!
func collect(item_to_add):
	# 1. This updates the visual inventory resource
	if inv:
		inv.insert(item_to_add)
		print("Player script: Item inserted into resource.")
	else:
		print("Player script ERROR: No inventory resource assigned in Inspector!")
	
	
