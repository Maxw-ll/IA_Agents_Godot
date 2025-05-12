extends CharacterBody2D
class_name Reativo

# Direções possíveis
var DIRECOES = {
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT,
	"up": Vector2i.UP,
	"down": Vector2i.DOWN
}

var move_interval = Constantes.MOVE_INTERVAL
@onready var area_detect_objetcs: Area2D = $Area_Detect_Objetcs
@onready var tilemap: TileMap = $"../TileMap"
@export_enum("Reativo", "Estados", "Objetivos", "Utilidade")
var agente: String = ""




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

	tempo_passado += delta
	if not carregando_item and not indo_ate_item:
		if tempo_passado > move_interval:
			mover_randomically()
			tempo_passado = 0.0
		
	elif indo_ate_item == true:
		if tempo_passado > move_interval:
			mover_para_item(item_carregado)
			tempo_passado = 0.0
	elif carregando_item == true:

		if tempo_passado > move_interval:
			mover_para_base()
			tempo_passado = 0.0
		
		

func mover_randomically():
	act_keys = DIRECOES.keys()
	index_move = randi() % act_keys.size()
	nova_direcao = DIRECOES[act_keys[index_move]]
	global_position = Vector2i(global_position) + nova_direcao*cell_size
	

#CONTROLE QUANDO RIGHT
func _on_area_right_body_entered(body: Node2D) -> void:
	DIRECOES.erase("right")

func _on_area_right_body_exited(body: Node2D) -> void:
	DIRECOES["right"] = Vector2i.RIGHT


#CONTROLE QUANDO LEFT
func _on_area_left_body_entered(body: Node2D) -> void:
	DIRECOES.erase("left")
	
func _on_area_left_body_exited(body: Node2D) -> void:
	DIRECOES["left"] = Vector2i.LEFT


#CONTROLE QUANDO UP
func _on_area_up_body_entered(body: Node2D) -> void:
	DIRECOES.erase("up")

func _on_area_up_body_exited(body: Node2D) -> void:
	DIRECOES["up"] = Vector2i.UP

#CONTROLE QUANDO DOWN
func _on_area_down_body_entered(body: Node2D) -> void:
	DIRECOES.erase("down")

func _on_area_down_body_exited(body: Node2D) -> void:
	DIRECOES["down"] = Vector2i.DOWN
	
	
func mover_para_base():
	var pos_atual = tilemap.local_to_map(global_position)

	if pos_atual == POS_BASE:
		carregando_item = false
		BDI.atualizar_memoria_items({item_carregado.global_position: item_carregado.tipo_item}, {})
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
		if item.has_collected == false:
			item.has_collected = true
			carregando_item = true
			item.visible = false
		
			

	var diferenca = pos_item - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y

	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)
	
func _on_area_detect_objetcs_area_entered(area: Area2D) -> void:
	#print("Chamou no Reativo")
	if is_instance_of(area, Item) and carregando_item == false and indo_ate_item == false:
		if area.quantidade_agentes == 1:
			pontos_carregados += area.quantidade_pontos
			print(pontos_carregados)
			indo_ate_item = true
			area.call_deferred("def_colision", false)
			item_carregado = area

		
