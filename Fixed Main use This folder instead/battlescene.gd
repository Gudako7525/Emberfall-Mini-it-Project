extends Control


var player_max_hp = 100
var player_hp = 100
var enemy_max_hp = 50
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
	$Background/Panel/Label.text = "A wild %s lvl %s appears" % [character_name, lvl]
	pass
	
	$Background/PlayerHPBar.max_value = player_max_hp
	$Background/PlayerHPBar.value = player_hp
	
	$Background/SlimeHPBar.max_value = enemy_max_hp
	$Background/SlimeHPBar.value = enemy_hp

func _on_attack_button_pressed():
	# Only allow attack if it's the player's turn and enemy is alive
	if is_player_turn and enemy_hp > 0:
		execute_player_attack()

func execute_player_attack():
	is_player_turn = false
	animate_player_attack() # animation call
	
	await get_tree().create_timer(0.5).timeout
	
	enemy_hp = enemy_hp - 10 # Deals 10 damage
	update_hp_ui() # <--- THIS UPDATES THE BAR
	
	$Background/Panel/Label.text = "You dealt 10 damage!"
	
	if enemy_hp <= 0:
		$Background/Panel/Label.text = "Victory!"
		await animate_enemy_death()
		get_tree().change_scene_to_file("res://ember_fall3.tscn")
	else:
		await get_tree().create_timer(1.0).timeout
		execute_enemy_turn()
		
		
func execute_enemy_turn():
	animate_enemy_attack() # Keep your animation call
	
	await get_tree().create_timer(0.5).timeout
	
	player_hp = player_hp - 5 # Take 5 damage
	update_hp_ui() # <--- THIS UPDATES THE BAR
	
	$Background/Panel/Label.text = "The Slime hits you for 5!"
	
	if player_hp <= 0:
		$Background/Panel/Label.text = "You were defeated..."
	else:
		is_player_turn = true
		
		
func animate_player_attack():
	var tween = create_tween()
	var player = $Background/Sprite2D 
	var original_pos = player.position
	
	# move forward quickly
	tween.tween_property(player, "position", original_pos + Vector2(50, 0), 0.1)
	# move back to start
	tween.tween_property(player, "position", original_pos, 0.2)
	
	# make the enemy flash red while being hit
	var enemy_tween = create_tween()
	$Background/Slime.modulate = Color.RED
	enemy_tween.tween_property($Background/Slime, "modulate", Color.WHITE, 0.3)

func animate_enemy_attack():
	var tween = create_tween()
	var enemy = $Background/Slime
	var original_pos = enemy.position
	
	# enemy moves left towards the player
	tween.tween_property(enemy, "position", original_pos + Vector2(-50, 0), 0.1)
	tween.tween_property(enemy, "position", original_pos, 0.2)
	
	# makes the player flash red
	var player_tween = create_tween()
	$Background/Sprite2D.modulate = Color.RED
	player_tween.tween_property($Background/Sprite2D, "modulate", Color.WHITE, 0.3)


func animate_enemy_death():
	var tween = create_tween()
	var enemy = $Background/Slime
	
	#animate two things at once:
	# 1. fade out (modulate alpha to 0)
	# 2. shrink (Scale to 0)
	tween.set_parallel(true) 
	tween.tween_property(enemy, "modulate:a", 0.0, 2.0) # fades over 2s
	tween.tween_property(enemy, "scale", Vector2(0, 0), 2.0) # shrinks over 2s
	
	# wait for the animation to finish
	await tween.finished
	enemy.visible = false # fully hides it at the end
	
func update_hp_ui():
	$Background/PlayerHPBar.value = player_hp
	$Background/SlimeHPBar.value = enemy_hp
