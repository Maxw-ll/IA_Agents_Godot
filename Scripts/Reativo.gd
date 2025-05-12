extends CharacterBody2D
class_name Reativo

# Direções possíveis
var DIRECOES = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

var move_interval = Constantes.MOVE_INTERVAL
@onready var area_detect_objetcs: Area2D = $Area_Detect_Objetcs
@onready var tilemap: TileMap = $"../TileMap"


var carregando_item = false
var indo_ate_item = false
var item_carregado = null
var pontos_carregados = 0


var tempo_passado := 0.0

var cols = Constantes.COLS
var rows = Constantes.ROWS
var cell_size = Constantes.CELL_SIZE
var POS_BASE = Vector2i(cols / 2, rows / 2) 


var centro_x = int(cols / 2)
var centro_y = int(rows / 2)

var nova_direcao = null
var index_move = null
var act_keys = []

func _ready():
	global_position = Vector2i(centro_x*32+16, centro_y*32+16)

func _physics_process(delta: float) -> void:
	if not carregando_item and not indo_ate_item:
		tempo_passado += delta
		act_keys = DIRECOES.keys()
		index_move = randi() % act_keys.size()
		nova_direcao = DIRECOES[act_keys[index_move]]
		if tempo_passado > move_interval:
			position += nova_direcao * cell_size
			tempo_passado = 0.0
		
	elif indo_ate_item == true:
		tempo_passado += delta
		if tempo_passado > move_interval:
			mover_para_item(item_carregado)
			tempo_passado = 0.0
	
	elif carregando_item == true:
		tempo_passado += delta
		if tempo_passado > move_interval:
			mover_para_base()
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

#CONTROLE QUANDO DOWN
func _on_area_down_body_entered(body: Node2D) -> void:
	DIRECOES.erase("down")

func _on_area_down_body_exited(body: Node2D) -> void:
	DIRECOES["down"] = Vector2.DOWN
	
	
func mover_para_base():
	var pos_atual = tilemap.local_to_map(global_position)

	if pos_atual == POS_BASE:
		carregando_item = false
		item_carregado.erase_item()
		item_carregado = null
		return 

	var diferenca = POS_BASE - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y
		
	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)
	
func mover_para_item(item: Item):
	var pos_atual = tilemap.local_to_map(global_position)
	var pos_item = tilemap.local_to_map(item.global_position)

	if pos_atual == pos_item:
		indo_ate_item = false
		carregando_item = true
		item_carregado.collect_item()

	var diferenca = pos_item - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y

	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)
	
func _on_area_detect_objetcs_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Item) and carregando_item == false and indo_ate_item == false:
		if area.quantidade_agentes == 1:
			pontos_carregados += area.quantidade_pontos
			print(pontos_carregados)
			indo_ate_item = true
			item_carregado = area

		
