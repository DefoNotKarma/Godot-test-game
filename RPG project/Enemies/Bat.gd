extends CharacterBody2D

const Bat_Death_Anim = preload("res://Effects/EnemyDeathEff.tscn")

@export var Acceleration = 300 
@export var Max_speed = 50
@export var Friction = 200

var knockback = Vector2.ZERO
var state = IDLE

@onready var stats = $Stats
@onready var PlayerDetector = $PlayerDetector
@onready var BatSprite = $BatSprite
@onready var hurtbox = $Hurtbox
@onready var softCollisions = $"Soft collision"
@onready var WanderControl = $WanderControl


enum{
	IDLE,
	WANDER, 
	CHASE
}

func _ready() -> void:
	pick_random_state([IDLE,WANDER])

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, 200*delta)
	knockback = move_and_slide()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO , 200 * delta)
			seek_player()
			
			if WanderControl.return_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if WanderControl.return_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(WanderControl.target_position, delta)
			
			if global_position.distance_to(WanderControl.target_position) <= 4:
				update_wander()
			
			
		CHASE:
			var player = PlayerDetector.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * Max_speed , Acceleration * delta)
			else: 
				state = IDLE
			BatSprite.flip_h = velocity.x < 0
	
	if softCollisions.is_colliding():
		velocity +=  softCollisions.get_push_vector() * delta * 400
	move_and_slide()

func seek_player():
	if PlayerDetector.can_see_player():
		state = CHASE

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction* Max_speed , Acceleration*delta)
	BatSprite.flip_h = velocity.x < 0

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	WanderControl.set_wander_timer(randf_range(1,5))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	knockback = area.knockback_vector * 120
	stats.health -= area.damage
	hurtbox.create_hitEffect()

func _on_Stats_no_health() -> void:
	queue_free()
	var Bat_death = Bat_Death_Anim.instance()
	get_parent().add_child(Bat_death)
	Bat_death.global_position = global_position

