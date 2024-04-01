extends Node2D

var enemies: Array = []
var index: int = 0
var action_queue: Array = []
var action_type: Array = []
var is_battling: bool = false
var rng = RandomNumberGenerator.new()
@onready var battle_announcer = $"../BattleAnnouncer"
@onready var win = $"../Win"
@onready var lose = $"../Lose"



signal next_player
signal player_heal
signal player_damage
signal get_player_health

func _ready():
	enemies = get_children()
	battle_announcer.text = "Battle Begins!"
	enemies[0].focus()
	
func _process(delta):
	if enemies[0].healthcheck() <= 0 && enemies[1].healthcheck() <= 0:
		win.show()
	
	if Input.is_action_just_pressed("ui_down"):
		if index > 0:
			index -= 1
			switch_focus(index, index + 1)
			
	if Input.is_action_just_pressed("ui_up"):
		if index < enemies.size() - 1:
			index += 1
			switch_focus(index, index - 1)
			
	if Input.is_action_just_pressed("apress"):
		action_queue.push_back(index)
		action_type.push_back(1) # 1 action_type means normal attack
		emit_signal("next_player")
	
	if Input.is_action_just_pressed("spress"):
		action_queue.push_back(index)
		action_type.push_back(2) # 2 action_type means group attack
		emit_signal("next_player")
		
	if Input.is_action_just_pressed("hpress"):
		action_queue.push_back(index)
		action_type.push_back(3) # 3 action_type means heal self
		emit_signal("next_player")
		
	if Input.is_action_just_pressed("jpress"):
		action_queue.push_back(index)
		action_type.push_back(4) # 4 action_type means group heal
		emit_signal("next_player")
		
	if Input.is_action_just_pressed("fpress"):
		action_queue.push_back(index)
		action_type.push_back(0) # 0 action_type means skip turn
		emit_signal("next_player")
		
	if action_queue.size() == enemies.size() and not is_battling:
		is_battling = true
		_action(action_queue, action_type)

func _action(enemy, act):
	var c = 0
	var enemyind = 0
	var dmgmult = 1
	for i in enemy:
		
		# dmg multiplier for weakness matching on player's turn
		if c == 0 && enemyind == 0:
			dmgmult = 1
		if c == 1 && enemyind == 0:
			dmgmult = 1.5
		if c == 0 && enemyind == 1:
			dmgmult = 1.5
		if c == 1 && enemyind == 1:
			dmgmult = 1
		
		var playerhealth = emit_signal("get_player_health", c)
		
		if playerhealth >= 0:
			if act[c] == 1: # 1 action_type means normal attack
				battle_announcer.text = "Player attacks!"
				var atkrng = rng.randf_range(0.5, 1)
				enemies[i].take_damage(3 * atkrng * dmgmult)
				await get_tree().create_timer(2).timeout
			
			if act[c] == 2: # 2 action_type means group attack
				battle_announcer.text = "Player casts group attack!"
				var atkrng = rng.randf_range(0.5, 0.7)
				for z in enemies:
					z.take_damage(3 * atkrng * dmgmult)
					await get_tree().create_timer(2).timeout
				
			if act[c] == 3: # 3 action_type means heal self
				battle_announcer.text = "Player heals self!"
				var healrng = rng.randf_range(0.25, 0.5)
				emit_signal("player_heal", c, 1 * healrng)
				await get_tree().create_timer(2).timeout
				
			if act[c] == 4: # 4 action_type means group heal
				battle_announcer.text = "Player casts heal on party!"
				var healrng = rng.randf_range(0.15, 0.30)
				var z = 0
				while z < 2:
					emit_signal("player_heal", z, 1 * healrng)
					z += 1
					await get_tree().create_timer(2).timeout
				
			if act[c] == 0: # 0 action_type means skip turn
				battle_announcer.text = "Player falls asleep... ZZzzZZz..."
				await get_tree().create_timer(2).timeout
				
		
		emit_signal("next_player")	
		
		enemyind += 1
		c += 1
	
	
	var e = 0
	var charind = 0
	
	while e < 2:
		var enemyattack = rng.randf_range(0,10) # enemyattack >= 5 means enemy attacks random player, else heals self
		
		# dmg multiplier for weakness matching on enemies' turn
		if e == 0 && charind == 0:
			dmgmult = 1
		if e == 1 && charind == 0:
			dmgmult = 1.5
		if e == 0 && charind == 1:
			dmgmult = 1.5
		if e == 1 && charind == 1:
			dmgmult = 1
			
		if enemies[e].healthcheck() >= 0: # Makes sure dead enemies don't do anything
			if enemyattack >= 5:
				var atkrng = rng.randf_range(0.5, 1)
				battle_announcer.text = "Enemy attacks player!"
				emit_signal("player_damage", e, 3 * atkrng * dmgmult)
				await get_tree().create_timer(2).timeout
			else:
				battle_announcer.text = "Enemy heals self!"
				var healrng = rng.randf_range(0.10, 0.30)
				enemies[e].heal(1 * healrng)
				await get_tree().create_timer(2).timeout
			
		next_enemy()
		emit_signal("next_player")
		e += 1
		charind += 1
	
	action_queue.clear()
	action_type.clear()
	is_battling = false

func switch_focus(x, y):
	enemies[x].focus()
	enemies[y].unfocus()
	
func next_enemy():
	if index < enemies.size() - 1:
		index += 1
		switch_focus( index, index - 1)
	else:
		index = 0
		switch_focus( index, enemies.size() - 1)
