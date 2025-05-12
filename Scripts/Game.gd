extends Node2D

####################################################
######## CRIAÇÃO DO MAPA E INSTÂNCIA DOS AGENTES ###
####################################################

@onready var tilemap: TileMap = $TileMap

const NUM_COLS = 36
const NUM_ROWS = 30
const CELL_SIZE = 32

const TERRENO_SET = 0
const TERRENO_CHAO = 0
const TERRENO_PAREDE = 1
const TERRENO_OBSTACULO = 2



func ajustar_tamanho_janela(cols: int, rows: int, cell_size: int):
	var largura = cols * cell_size
	var altura = rows * cell_size

	DisplayServer.window_set_size(Vector2i(largura, altura))

func _ready():
	ajustar_tamanho_janela(NUM_COLS, NUM_ROWS, CELL_SIZE)
	preencher_cenario_com_terreno(NUM_COLS, NUM_ROWS)

func preencher_cenario_com_terreno(cols: int, rows: int):
	var coords_chao: Array[Vector2i] = []
	var coords_borda: Array[Vector2i] = []
	var coords_centro: Array[Vector2i] = []

	for y in range(rows):
		for x in range(cols):
			var coord = Vector2i(x, y)
			if x == 0 or x == cols - 1 or y == 0 or y == rows - 1:
				coords_borda.append(coord)
			else:
				coords_chao.append(coord)

	# Remove as coordenadas do centro de coords_chao
	var centro_x = (cols / 2) - 2
	var centro_y = (rows / 2) - 2

	for y in range(centro_y, centro_y + 3):
		for x in range(centro_x, centro_x + 3):
			var coord = Vector2i(x, y)
			coords_centro.append(coord)
			coords_chao.erase(coord)  # remover do chão

	# Preenche tudo
	tilemap.set_cells_terrain_connect(0, coords_chao, TERRENO_SET, TERRENO_CHAO)
	tilemap.set_cells_terrain_connect(0, coords_borda, TERRENO_SET, TERRENO_PAREDE)
	tilemap.set_cells_terrain_connect(0, coords_centro, TERRENO_SET, TERRENO_OBSTACULO)
