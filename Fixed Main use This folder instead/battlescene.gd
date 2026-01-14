extends Control

var player_hp = 100
var enemy_hp = 50
var is_player_turn = true

# Called when the node is added to the scene
func _ready():
	# Hide the battle UI elements initially

	
	# Connect a custom signal from an event handler to the initialization function
	event_handler.battle_started.connect(init)
	pass


# Initialization function called when the "battle_started" signal is emitted
func init(character_name, lvl):
	# Make the battle UI visible
	visible = true
	
	# Play a visual transition animation (e.g., screen fade)
	$AnimationPlayer.play("fade_in")
	
	# Pause the main game world/scene tree (Exploration state)
	get_tree().paused = true
	
	# Set the text to display the enemy encounter message
	$background/Panel/Label.text = "A wild %s lvl %s appears" % [character_name, lvl]
	pass

func _on_attack_button_pressed():
	# Only allow attack if it's the player's turn and enemy is alive
	if is_player_turn and enemy_hp > 0:
		execute_player_attack()

func execute_player_attack():
	is_player_turn = false # Block buttons so player can't spam
	var damage = 15
	enemy_hp -= damage
	$Background/Panel/Label.text = "You dealt 15 damage!"
	
	# Check if enemy died
	if enemy_hp <= 0:
		$Background/Panel/Label.text = "Victory! The enemy was defeated."
		# Optional: add a timer to close the battle here
	else:
		# Wait 1 second, then the enemy hits back
		await get_tree().create_timer(2.0).timeout
		execute_enemy_turn()

func execute_enemy_turn():
	var enemy_damage = 10
	player_hp -= enemy_damage
	$Background/Panel/Label.text = "The enemy hits you for " + str(enemy_damage) + " damage!"
	
	if player_hp <= 0:
		$Background/Panel/Label.text = "You have been defeated..."
	else:
		is_player_turn = true # Turn comes back to you
