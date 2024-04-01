extends Node2D

@onready var lose = $"../Lose"

var players: Array = []
var index : int = 0

func _ready():
	players = get_children()

	players[0].focus()

func _process(delta):
	if players[0].healthcheck() <= 0 && players[1].healthcheck() <= 0:
		lose.show()

func _on_enemy_group_next_player():
	if index < players.size() - 1:
		index += 1
		switch_focus( index, index - 1)
	else:
		index = 0
		switch_focus( index, players.size() - 1)

func switch_focus(x, y):
	players[x].focus()
	players[y].unfocus()

func _on_enemy_group_player_heal(playerindex, rng):
	players[playerindex].heal(rng)

func _on_enemy_group_player_damage(playerindex, rng):
	players[playerindex].take_damage(rng)

func _on_enemy_group_get_player_health(playerindex):
	return players[playerindex].healthcheck()
