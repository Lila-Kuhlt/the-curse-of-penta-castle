extends Enemy

enum UnicornMode { CHARGE, CHARGE_START, STAND, WALK }

const MIN_WALK_COOLDOWN := 1.0
const MAX_WALK_COOLDOWN := 5.0
const MIN_STAND_COOLDOWN := 0.5
const MAX_STAND_COOLDOWN := 4.0
const CHARGE_COOLDOWN := 1.0
const WALK_MULT := 0.6
const CHARGE_MULT := 7.0
const VIEW_RAY_WIDTH := 10.0

@onready var anim: AnimationPlayer = $AnimationPlayer

var mode := UnicornMode.STAND
var mode_cooldown := 1.0
var was_on_wall_cooldown := 0.0

func goto_stand_mode():
	mode = UnicornMode.STAND
	anim.play('idle')
	mode_cooldown = randf_range(MIN_STAND_COOLDOWN, MAX_STAND_COOLDOWN)

func goto_walk_mode(toggle: bool):
	mode = UnicornMode.WALK
	if toggle or (randi() & 1):
		flip_direction()
	anim.play('walk')
	mode_cooldown = randf_range(MIN_WALK_COOLDOWN, MAX_WALK_COOLDOWN)

func _physics_process(delta):
	if not stunned:
		# player detection
		var collider = $ViewRay.get_collider()
		if collider == player:
			if mode != UnicornMode.CHARGE_START and mode != UnicornMode.CHARGE:
				mode = UnicornMode.CHARGE_START
				mode_cooldown = CHARGE_COOLDOWN
				anim.play('charge')

		on_obstacle(func(): goto_walk_mode(true))

		match mode:
			UnicornMode.STAND:
				velocity.x = 0
				if mode_cooldown <= 0:
					if randi() & 1:
						goto_walk_mode(false)
					else:
						goto_stand_mode()
						flip_direction()
				else:
					mode_cooldown -= delta
			UnicornMode.WALK:
				if is_on_wall():
					is_facing_right = get_wall_normal().x > 0.0
				velocity.x = MOVEMENT_SPEED * WALK_MULT
				if not is_facing_right:
					velocity.x = -velocity.x
				if mode_cooldown <= 0:
					goto_stand_mode()
				else:
					mode_cooldown -= delta
			UnicornMode.CHARGE_START:
				velocity.x = 0
				mode_cooldown -= delta
				if mode_cooldown <= 0:
					mode = UnicornMode.CHARGE
					anim.play('walk')
					SfxAudio.play_sfx(SfxAudio.Sound.UNICORN_CHARGE)

			UnicornMode.CHARGE:
				if is_on_wall() and (get_wall_normal().x > 0.0) != is_facing_right:
					was_on_wall_cooldown = 100.0
					goto_walk_mode(true)
				else:
					velocity.x = MOVEMENT_SPEED * CHARGE_MULT
					if not is_facing_right:
						velocity.x = -velocity.x
	else:
		velocity.x = 0.0

	do_physics(delta)
	move_and_slide()
