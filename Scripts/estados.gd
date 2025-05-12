extends Reativo
class_name States

var memory_cells = []
var memory_item_pegos = {} #Armazena os itens que foram visto e não pegos
var memory_item_vistos = {}
#Está aqui apenas para comunicação com o BDI - Estados não usa os Itens encontrados

var ALL_DIRECTIONS = [
	Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i(1,1),
	Vector2i(-1,-1),
	Vector2i(-1, 1),
	Vector2i(1, -1),
	Vector2i(0,0)
]


#OVERRIDE
func _physics_process(delta: float) -> void:
	if Vector2i(global_position) == POS_BASE:
		BDI.atualizar_memoria_cell(memory_cells)
		BDI.atualizar_memoria_items(memory_item_pegos, memory_item_vistos)
		memory_cells = BDI.solicitar_memoria_cells_global()
		
	tempo_passado += delta
	if not carregando_item and not indo_ate_item:
		if tempo_passado > move_interval:
			mover_novas_direcoes()
			tempo_passado = 0.0
		
	elif indo_ate_item == true:
		if tempo_passado > move_interval:
			mover_para_item(item_carregado)
			tempo_passado = 0.0
	elif carregando_item == true:

		if tempo_passado > move_interval:
			mover_para_base()
			tempo_passado = 0.0
#OVERRIDE
func mover_para_base():
	var pos_atual = tilemap.local_to_map(global_position)

	if pos_atual == POS_BASE:
		carregando_item = false
		item_carregado = null
		BDI.atualizar_memoria_cell(memory_cells)
		BDI.atualizar_memoria_items(memory_item_pegos, memory_item_vistos)
		memory_cells = BDI.solicitar_memoria_cells_global()
		return 

	var diferenca = POS_BASE - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y
		
	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)

func salvar_celulas_ao_redor():
	for coord in ALL_DIRECTIONS:
		var n_position = Vector2i(global_position) + coord
		memory_cells.append(n_position)
		
func mover_novas_direcoes():
	var pos_atual = global_position
	var candidatas = []
	
	for dir in DIRECOES.keys():
		#print(pos_atual)
		#print(DIRECOES[dir])
		var destino = Vector2i(pos_atual) + DIRECOES[dir]
		if not memory_cells.has(destino):
			candidatas.append(destino)

	if candidatas.size() > 0:
		var coord_escolhida = candidatas[randi() % candidatas.size()]
		global_position = coord_escolhida
	else:
		if not carregando_item and not indo_ate_item:
			mover_randomically()
		
	salvar_celulas_ao_redor()
	
#OVERRIDE
func mover_para_item(item: Item):
	var pos_atual = tilemap.local_to_map(global_position)
	var pos_item = tilemap.local_to_map(item.global_position)

	if pos_atual == pos_item:
		indo_ate_item = false
		if item.has_collected == false:
			memory_item_pegos[item.global_position] = item.tipo_item
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
	
		
	
#OVERRRIDE
func _on_area_detect_objetcs_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Item) and (indo_ate_item or carregando_item):
		memory_item_vistos[area.global_position] = area.tipo_item
		
	#print("Chamou no Reativo")
	if is_instance_of(area, Item) and carregando_item == false and indo_ate_item == false:
		if area.quantidade_agentes == 1:
			pontos_carregados += area.quantidade_pontos
			print(pontos_carregados)
			indo_ate_item = true
			area.call_deferred("def_colision", false)
			item_carregado = area
