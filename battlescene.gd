extends Control

# Called when the node is added to the scene
func _ready():
	# Hide the battle UI elements initially
	visible = false
<<<<<<< Updated upstream
	"res://c50a18008bf3f9aade4d1b6bb5cc5aea.jpg"
=======
	$background.visible = false
	
	# Connect a custom signal from an event handler to the initialization function
	event_handler.battle_started.connect(init)
	pass


>>>>>>> Stashed changes
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
