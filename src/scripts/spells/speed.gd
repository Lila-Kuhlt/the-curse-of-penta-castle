extends SpellBase

var speed_diff = 0.0

func cast(player: Player, _enemies: Array[Node]):
	speed_diff = player.MAX_SPEED
	player.MAX_SPEED *= 2
	speed_diff = player.MAX_SPEED - speed_diff

func uncast(player: Player, _enemies: Array[Node]):
	player.MAX_SPEED -= speed_diff
