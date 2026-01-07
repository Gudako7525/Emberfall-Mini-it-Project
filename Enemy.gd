extends CharacterBody2D

var speed = 120.0
var stop_distance = 10.0 # Distance at which the enemy will stop chasing
var player_chase = false
var player = null

func _physics_process(_delta):
	if player_chase and player != null:
		var direction = (player.position - position)
		var distance = direction.length()
		
		if distance > stop_distance:
			# Chase: Set velocity towards the player
			velocity = direction.normalized() * speed
		else:
			# Stop: Player is close enough
			velocity = Vector2.ZERO
			
	else:
		# Enemy not chasing or player is null
		velocity = Vector2.ZERO
		
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false
