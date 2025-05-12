extends CharacterBody2D


####################################################
######## CRIAÇÃO DO MAPA E INSTÂNCIA DOS AGENTES ###
####################################################

@onready var area_2d: Area2D = $Area2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
const CELL_SIZE = 32
const MOVE_INTERVAL = 0.5
var pode_mover = true
var tempo_passado := 0.0
var direcao := Vector2.RIGHT

var cols = 36
var rows = 30
var centro_x = (cols / 2) - 2
var centro_y = (rows / 2) - 2


func _ready():
	global_position = Vector2i(centro_x*32-16, centro_y*32-16)

func _process(delta):
	tempo_passado += delta
	if tempo_passado >= MOVE_INTERVAL:
		tempo_passado = 0.0
		if pode_mover:
			mover()

func mover():
	position += direcao * CELL_SIZE
