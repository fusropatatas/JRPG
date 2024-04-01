extends CharacterBody2D

@onready var _animated_sprite = $orcanim
@onready var _focus = $focus
@onready var progress_bar = $ProgressBar
@onready var animation_player = $AnimationPlayer
@onready var battle_announcer = $"../BattleAnnouncer"

@export var MAX_HEALTH: float = 10

var pasthealth: float = 0
var health: float = 10:
	set(value):
		pasthealth = health
		health = value
		_play_animation()
		#if pasthealth < health:
		#	battle_announcer.text = "Earth Sprite receives damage!"
		#if pasthealth > health:
		#	battle_announcer.text = "Earth Sprite heals!"

func _process(_delta):
	progress_bar.value = (health/MAX_HEALTH) * 100
	_animated_sprite.play("Idle")

func _play_animation():
	_animated_sprite.play("Defend")

func focus():
	_focus.show()
	
func unfocus():
	_focus.hide()

func take_damage(value):
	health -= value

func heal(value):
	health += value

func healthcheck():
	return health
