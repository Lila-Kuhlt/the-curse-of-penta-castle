class_name Projectile extends Area2D

@export var speed := 100.0
@export var ATTACK_DAMAGE := 10.0
@export var KNOCKBACK_STRENGTH := 10.0
@export var REMOVE_AFTER := 10.0
@export var STUN_TIME := 2.0
@export var PIERCING := false
@export var STUNNING := false
@export var IS_FISH := false
var direction: Vector2 = Vector2(1, 0)
var fish_timer := 0.0
const FISH_FREQ := 12.0
const FISH_AMP := 250.0

func _ready():
	get_tree().create_timer(REMOVE_AFTER).timeout.connect(queue_free)

func flip() -> void:
	scale.x *= -1
	position.x *= -1

func _physics_process(delta: float):
	var velocity = direction * speed
	if IS_FISH:
		velocity.y += cos(fish_timer * FISH_FREQ) * FISH_AMP
		fish_timer += delta
	position += velocity * delta

func _timeout_queue_free():
	queue_free()

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.take_damage(ATTACK_DAMAGE)
		body.knockback = direction.normalized() * KNOCKBACK_STRENGTH
		if STUNNING and body is Enemy:
			body.stun()
			get_tree().create_timer(STUN_TIME).timeout.connect(body.unstun)
		if not PIERCING:
			queue_free()
	elif body is TileMap:
		queue_free()
