extends Node

@export var obstacle : PackedScene
@export var coin : PackedScene

var last_obstacle_position : String
var dynamic_objects_speed : int = 700
var health_decrease_speed : int = 3
var spawned_object_position_x : int = 1700
var health : float = 100
var score : float

func _process(delta):
	for dynamic_object in get_tree().get_nodes_in_group("DynamicObject"):
		dynamic_object.position.x -= delta * dynamic_objects_speed
	
	
#-------------Manage Healt and game over----------
	if health > 0:
		health -= delta * health_decrease_speed
		$UI/HealthBar.value = health
	else:
		game_over()
#-------------Manage Healt and game over end----------

	score += delta
	var formatted_score = str(score)
	var decimal_index = formatted_score.find(".")
	formatted_score = formatted_score.left(decimal_index + 3)
	$UI/HealthBar/ScoreLabel.text = formatted_score

	

#------------spawner timer obstacles-----
func _on_spawner_timer_timeout():
	var random : int = randi() % 2
	var obstacle_instance : Area2D = obstacle.instantiate()
	add_child(obstacle_instance)
	obstacle_instance.position.x = spawned_object_position_x
	obstacle_instance.body_entered.connect(_on_obstacle_collided)
	
	if random == 0:
		obstacle_instance.position.y = 200
		last_obstacle_position = "up"
	
	if random == 1:
		obstacle_instance.position.y  = 800
		obstacle_instance.scale.y *= -1
		last_obstacle_position = "down"

#--------------spawner timer coins-------
func _on_coin_timer_timeout():
	var random_position : int = randi() % 3
		
	if random_position == 0 and last_obstacle_position == "up":
		return
	if random_position == 2 and last_obstacle_position == "down":
		return
			
	var coin_instance : Area2D = coin.instantiate()
	add_child(coin_instance)
	coin_instance.position.x = spawned_object_position_x
	coin_instance.body_entered.connect(_on_coin_collided.bind(coin_instance))
	coin_instance.position.y = 280 + random_position * 200
			

func _on_coin_collided(body : Node2D, coin_instance : Area2D) -> void:
	if body.is_in_group("Player"):
		$Player/CoinCollected.play()
		health += 4
		coin_instance.get_node("AnimationPlayer").play("CoinCollected")
		
		if health > 100:
			health = 100

func _on_obstacle_collided(body : Node2D) -> void:
	if body.is_in_group("Player"):
		game_over()

func game_over() -> void:
	$Player/GameOver.play()
	$GameOver.show()
	get_tree().paused = true
