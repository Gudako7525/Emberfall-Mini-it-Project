extends Control


var player_max_hp = 100
var player_hp = 100
var enemy_max_hp = 50
var enemy_hp = 50
var is_player_turn = true
var crit_chance = 0.20 # 20% chance to crit
var crit_multiplier = 2.0 # Double damage on crit
var player_miss_chance = 0.10 # 10% chance to miss
var enemy_miss_chance = 0.15  # 15% chance for the slime to miss
var heal_amount = 25       # How much HP the player recovers
var enemy_heal_amount = 20
var enemy_heal_chance = 0.70    # 70% success rate
var enemy_heal_threshold = 15  # Will only try to heal if HP is 15 or less

# Called when the node is added to the scene
func _ready():
	update_potion_display()
	# Hide the battle UI elements initially

	
	# Connect a custom signal from an event handler to the initialization function
	event_handler.battle_started.connect(init)
	pass

func update_potion_display():
	# Accesses the global variable you incremented in the chest script
	$Background/PotionLabel.text = "Potions: " + str(Global.potion_count)

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
	animate_player_attack() 
	
	await get_tree().create_timer(0.4).timeout
	
	# --- HIT OR MISS LOGIC ---
	if randf() < player_miss_chance:
		$Background/Panel/Label.text = "You MISSED!"
		# skip damage and go straight to the enemy's turn
	else:
		# DAMAGE & CRIT LOGIC
		var base_damage = 15
		var final_damage = base_damage
		var is_crit = false
		
		if randf() < crit_chance:
			is_crit = true
			final_damage = base_damage * crit_multiplier

		enemy_hp -= final_damage
		update_hp_ui() 
		
		if is_crit:
			$Background/Panel/Label.text = "CRITICAL HIT! You dealt %s damage!" % final_damage
		else:
			$Background/Panel/Label.text = "You dealt %s damage!" % final_damage
	
	# --- TURN TRANSITION ---
	if enemy_hp <= 0:
		$Background/Panel/Label.text = "Victory!"
		await animate_enemy_death()
		get_tree().change_scene_to_file("res://ember_fall3.tscn")
	else:
		await get_tree().create_timer(1.5).timeout # Longer wait so they can read the text
		execute_enemy_turn()
		
		
func execute_enemy_turn():
	# ENEMY AI DECISION
	# if health is low, the slime will try to heal instead of attacking
	if enemy_hp <= enemy_heal_threshold and randf() < 0.5: 
		execute_enemy_heal()
	else:
		perform_enemy_attack_logic()

func perform_enemy_attack_logic():
	animate_enemy_attack()
	await get_tree().create_timer(0.4).timeout
	
	if randf() < enemy_miss_chance:
		$Background/Panel/Label.text = "The Slime MISSED!"
	else:
		player_hp -= 5 
		update_hp_ui() 
		$Background/Panel/Label.text = "The Slime hits you for 5!"
	
	finish_enemy_turn()

func execute_enemy_heal():
	# Slime doesn't lunge, it just wobbles or flashes
	$Background/Panel/Label.text = "The Slime is trying to regenerate..."
	await get_tree().create_timer(0.6).timeout
	
	if randf() < enemy_heal_chance:
		enemy_hp += enemy_heal_amount
		if enemy_hp > enemy_max_hp:
			enemy_hp = enemy_max_hp
		
		update_hp_ui()
		$Background/Panel/Label.text = "The Slime healed itself!"
		
		# Visual feedback: Blue flash for enemy heal
		var tween = create_tween()
		$Background/Slime.modulate = Color.MEDIUM_PURPLE
		tween.tween_property($Background/Slime, "modulate", Color.WHITE, 0.4)
	else:
		$Background/Panel/Label.text = "The Slime failed to heal!"
	
	finish_enemy_turn()

func finish_enemy_turn():
	# check if player is dead
	if player_hp <= 0:
		$Background/Panel/Label.text = "You were defeated by the Slime..."
		# This triggers the new animation
		await animate_player_death()
	else:
		await get_tree().create_timer(1.5).timeout
		is_player_turn = true
		$Background/Panel/Label.text = "Your turn!"
		
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


func _on_heal_button_pressed():
	# 1. only heal if it's your turn and you have potions
	if is_player_turn and Global.potion_count > 0:
		is_player_turn = false # LOCKS the turn immediately
		
		# 2. uses one potion
		Global.potion_count -= 1
		update_potion_display()
		
		# 3. healing 
		player_hp += heal_amount
		player_hp = min(player_hp, player_max_hp) # Cleaner way to cap HP
		
		# 4. update UI
		update_hp_ui()
		$Background/Panel/Label.text = "You used a potion and recovered %s HP!" % heal_amount
		
		# 5. HEALING ANIMATION
		var tween = create_tween()
		var player_sprite = $Background/Sprite2D
		
		tween.tween_property(player_sprite, "modulate", Color.GREEN, 0.1)
		tween.parallel().tween_property(player_sprite, "position:y", player_sprite.position.y - 10, 0.1)
		
		tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.3)
		tween.parallel().tween_property(player_sprite, "position:y", player_sprite.position.y, 0.2)
		
		# 6.animation, then trigger the enemy
		await get_tree().create_timer(1.5).timeout
		if enemy_hp > 0:
			execute_enemy_turn()
			
	elif is_player_turn and Global.potion_count <= 0:
		# You're out of potions 
		# player can still choose to attack instead.
		$Background/Panel/Label.text = "You are out of potions!"
		
		
func animate_player_death():
	var tween = create_tween()
	var player = $Background/Sprite2D
	
	# We use set_parallel so it shrinks AND fades at the same time
	tween.set_parallel(true) 
	tween.tween_property(player, "modulate:a", 0.0, 2.0) # Fades alpha to 0
	tween.tween_property(player, "scale", Vector2(0, 0), 2.0) # Shrinks to nothing
	
	# Wait for the 2-second animation to finish
	await tween.finished
	player.visible = false
