extends CharacterBody2D

var level : int = 49

@onready var target = $"."
var speed = 150

@onready var battle_trigger = $BattleTrigger 

func _ready():
	battle_trigger.body_entered.connect(_on_battle_trigger_body_entered)

func _physics_process(delta):
	var direction = (target.position - position).normalized()
	velocity = direction * speed
	look_at(target.position)
	move_and_slide()

func _on_battle_trigger_body_entered(body):
	if body.is_in_group("player"):
		
		var slime_name = "Slime"
		var slime_level = level 
		
		event_handler.battle_started.emit(slime_name, slime_level)
		
		queue_free()
