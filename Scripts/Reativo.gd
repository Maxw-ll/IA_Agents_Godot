extends CharacterBody2D


# Direções possíveis
var DIRECOES = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}


@onready var area_detect_objetcs: Area2D = $Area_Detect_Objetcs




const CELL_SIZE = 32
const MOVE_INTERVAL = 0.05
var tempo_passado := 0.0

var cols = 36
var rows = 30
var centro_x = (cols / 2) - 2
var centro_y = (rows / 2) - 2

var nova_direcao = null
var index_move = null
var act_keys = []

func _ready():
	global_position = Vector2i(centro_x*32-16, centro_y*32-16)

func _physics_process(delta: float) -> void:
	tempo_passado += delta
	act_keys = DIRECOES.keys()
	index_move = randi() % act_keys.size()
	nova_direcao = DIRECOES[act_keys[index_move]]
	if tempo_passado > MOVE_INTERVAL:
		position += nova_direcao * CELL_SIZE
	
		tempo_passado = 0.0


#CONTROLE QUANDO RIGHT
func _on_area_right_body_entered(body: Node2D) -> void:
	DIRECOES.erase("right")

func _on_area_right_body_exited(body: Node2D) -> void:
	DIRECOES["right"] = Vector2.RIGHT


#CONTROLE QUANDO LEFT
func _on_area_left_body_entered(body: Node2D) -> void:
	DIRECOES.erase("left")
	
func _on_area_left_body_exited(body: Node2D) -> void:
	DIRECOES["left"] = Vector2.LEFT


#CONTROLE QUANDO UP
func _on_area_up_body_entered(body: Node2D) -> void:
	DIRECOES.erase("up")

func _on_area_up_body_exited(body: Node2D) -> void:
	DIRECOES["up"] = Vector2.UP


func _on_area_down_body_entered(body: Node2D) -> void:
	DIRECOES.erase("down")

func _on_area_down_body_exited(body: Node2D) -> void:
	DIRECOES["down"] = Vector2.DOWN
