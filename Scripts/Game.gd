extends Node2D

####################################################
######## CRIAÇÃO DO MAPA E INSTÂNCIA DOS AGENTES ###
####################################################

@export var cena_cristal: PackedScene
@export var cena_metal: PackedScene
@export var cena_estrutura: PackedScene

var qtd_cristal: int = Constantes.QTDCRISTAL
var qtd_metal: int = Constantes.QTDMETAL
var qtd_estrutura: int = Constantes.QTDESTRUTURA

@onready var tilemap: TileMap = $TileMap

var cols = Constantes.COLS
var rows = Constantes.ROWS
var cell_size = Constantes.CELL_SIZE


const TERRENO_SET = 0
const TERRENO_CHAO = 0
const TERRENO_PAREDE = 1
const TERRENO_OBSTACULO = 2



func ajustar_tamanho_janela():
	var largura = cols * cell_size
	var altura = rows * cell_size

	DisplayServer.window_set_size(Vector2i(largura, altura))

func _ready():
	
	randomize()
	var posicoes_validas = gerar_posicoes_validas()
	distribuir_itens(cena_cristal, qtd_cristal, posicoes_validas)
	distribuir_itens(cena_metal, qtd_metal, posicoes_validas)
	distribuir_itens(cena_estrutura, qtd_estrutura, posicoes_validas)

	ajustar_tamanho_janela()
	preencher_cenario_com_terreno()
	
func gerar_posicoes_validas() -> Array[Vector2i]:
	var posicoes: Array[Vector2i] = []

	var base_x = int(cols / 2) - 2
	var base_y = int(rows / 2) - 2

	for y in range(1, rows - 1):
		for x in range(1, cols - 1):
			var dentro_da_base = x >= base_x and x < base_x + 4 and y >= base_y and y < base_y + 4
			if not dentro_da_base:
				posicoes.append(Vector2i(x, y))
	return posicoes
	
	
func distribuir_itens(cena: PackedScene, quantidade: int, posicoes_validas: Array[Vector2i]):
	for i in range(quantidade):
		if posicoes_validas.is_empty():
			return

		var index = randi_range(0, posicoes_validas.size() - 1)
		var pos_tile = posicoes_validas[index]
		posicoes_validas.remove_at(index)

		var item = cena.instantiate()
		item.global_position = tilemap.map_to_local(pos_tile)
		add_child(item)

func preencher_cenario_com_terreno():
	var coords_chao: Array[Vector2i] = []
	var coords_borda: Array[Vector2i] = []
	var coords_centro: Array[Vector2i] = []
	var coord
	for y in range(rows):
		for x in range(cols):
			coord = Vector2i(x, y)
			if x == 0 or x == cols - 1 or y == 0 or y == rows - 1:
				coords_borda.append(coord)
			else:
				coords_chao.append(coord)

	# Remove as coordenadas do centro de coords_chao
	var centro_x = int(cols / 2) 
	var centro_y = int(rows / 2)

	coord = Vector2i(centro_x, centro_y)
	coords_centro.append(coord)
	coords_chao.erase(coord)  # remover do chão

	# Preenche tudo
	tilemap.set_cells_terrain_connect(0, coords_chao, TERRENO_SET, TERRENO_CHAO)
	tilemap.set_cells_terrain_connect(0, coords_borda, TERRENO_SET, TERRENO_PAREDE)
	tilemap.set_cells_terrain_connect(0, coords_centro, TERRENO_SET, TERRENO_OBSTACULO)
