extends Node2D

var state = "chest closed" #chest opened,chest closed
var player_in_area = false

var potion = preload("res://potion_collectable.tscn")

@export var item: InvItem
var player = null

func _ready():
	if state == "chest opened":
		$Timer.start()
		
func _process(_delta):
	if state == "chest opened":
		$AnimatedSprite2D.play("chest_opened")
	if state == "chest closed":
		$AnimatedSprite2D.play("chest_closed")
		if player_in_area:
			if Input.is_action_just_pressed("e"):
				state = "chest opened"
				drop_potion()

func _on_openable_area_body_entered(body):
	if body.has_method("Player"):
		player_in_area = true
		player = body

func _on_openable_area_body_exited(body):
	if body.has_method("Player"):
		player_in_area = false


func _on_timer_timeout():
	if state == "chest_opened":
		state = "chest closed"

func drop_potion():
	# 1. Visual Potion animation
	var potion_instance = potion.instantiate()
	potion_instance.global_position = $Marker2D.global_position 
	add_child(potion_instance)

	# 2. Update Global Brain (For Combat)
	Global.potion_count += 1
	
	# 3. Update Visual Inventory (For your UI)
	# We check if 'item' exists and the player is valid
	if player and item:
		player.collect(item) 
		print("Sent to visual inventory")
		
