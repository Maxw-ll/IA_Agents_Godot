extends States
class_name Objetivos

var memory_objetives = {}
var memory_help = {}

#OVERRIDE
func _physics_process(delta: float) -> void:
	if Vector2i(global_position) == POS_BASE:
		BDI.atualizar_memoria_cell(memory_cells)
		BDI.atualizar_memoria_items(memory_item_pegos, memory_item_vistos)
		memory_cells = BDI.solicitar_memoria_cells_global()
		memory_objetives = BDI.solicitar_memoria_cells_global()
		memory_help = BDI.solicitar_memoria_ajuda()
		
	tempo_passado += delta
	#print("MEMORIA OBJETIVOS")
	#print(memory_objetives)
	#Prioridade para ajudar
	if memory_help and not carregando_item and not indo_ate_item:
		if tempo_passado > move_interval:
			mover_para_item_longe(memory_help.keys()[0])
			tempo_passado = 0.0
		
	if memory_objetives and not carregando_item and not indo_ate_item:
		if tempo_passado > move_interval:
			mover_para_item_longe(memory_objetives.keys()[0])
			tempo_passado = 0.0
			#print("Tenho Obetivo")
		
	elif not carregando_item and not indo_ate_item:
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

#OVERRRIDE
func mover_para_base():
	var pos_atual = tilemap.local_to_map(global_position)

	if pos_atual == POS_BASE:
		carregando_item = false
		item_carregado = null
		BDI.atualizar_memoria_cell(memory_cells)
		BDI.atualizar_memoria_items(memory_item_pegos, memory_item_vistos)
		memory_cells = BDI.solicitar_memoria_cells_global()
		memory_objetives = BDI.solicitar_memoria_items_global()
		memory_help = BDI.solicitar_memoria_ajuda()
		return 

	var diferenca = POS_BASE - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y
		
	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)
	
	
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
			
		memory_objetives.erase(item.global_position)
		
			

	var diferenca = pos_item - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y

	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)	
	
	
func mover_para_item_longe(coord):
	var pos_atual = tilemap.local_to_map(global_position)
	var pos_item = tilemap.local_to_map(coord)
	

	var diferenca = pos_item - pos_atual
	var direcao: Vector2i
	
	if pos_item == pos_atual:
		if memory_help:
			memory_help.erase(coord)
			pontos_carregados += Constantes.VALORES_ITEMS["Estrutura"]
			legenda.atc_label_pontos(agente, pontos_carregados)
			BDI.ajuda_realizada(coord)
			carregando_item = true
			indo_ate_item = false
		else:
			memory_objetives.erase(coord)
		
		
	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y

	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)	

#override
func _on_area_detect_objetcs_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Item) and (indo_ate_item or carregando_item):
		memory_item_vistos[area.global_position] = area.tipo_item
		
	#print("Chamou no Reativo")
	if is_instance_of(area, Item) and carregando_item == false and indo_ate_item == false:
		if area.quantidade_agentes == 1:
			pontos_carregados += area.quantidade_pontos
			legenda.atc_label_pontos(agente, pontos_carregados)
			print(pontos_carregados)
			indo_ate_item = true
			area.call_deferred("def_colision", false)
			item_carregado = area
