extends Objetivos
var better_item = null

var esperando_ajuda = false

func utilidade(valor, coords):
	var dist = global_position.distance_to(coords)
	return (valor * 0.6) / (dist + 0.1) * 0.4
	
func decide_better_item():
	var chaves = memory_objetives.keys()
	var melhor_chave = chaves[0]
	var melhor_utilidade = utilidade(Constantes.VALORES_ITEMS[memory_objetives[melhor_chave]], melhor_chave)
	for chave in memory_objetives:
		var utilidad_ = utilidade(Constantes.VALORES_ITEMS[memory_objetives[chave]], chave)
		if utilidad_ > melhor_utilidade:
			melhor_chave = chave
			melhor_utilidade = utilidad_
	
	return melhor_chave
		
		
		
		
#OVERRIDE
func _physics_process(delta: float) -> void:
	if Vector2i(global_position) == POS_BASE:
		BDI.atualizar_memoria_cell(memory_cells)
		BDI.atualizar_memoria_items(memory_item_pegos, memory_item_vistos)
		memory_cells = BDI.solicitar_memoria_cells_global()
		memory_objetives = BDI.solicitar_memoria_cells_global()
		
	tempo_passado += delta
	if BDI.solicitar_memoria_ajuda().is_empty():
		esperando_ajuda = false
		
	if memory_objetives and not carregando_item and not indo_ate_item:
		if better_item == null:
			better_item = decide_better_item()
			if memory_objetives[better_item] == "Estrutura":
				BDI.solicitar_ajuda(better_item)

		if tempo_passado > move_interval:
			mover_para_item_longe(better_item)
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
	elif carregando_item == true and not esperando_ajuda:
		if tempo_passado > move_interval:
			mover_para_base()
			tempo_passado = 0.0
	


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
			
			if item.tipo_item == "Estrutura":
				esperando_ajuda = true
				
			
		memory_objetives.erase(item.global_position)
		better_item = null
		
			

	var diferenca = pos_item - pos_atual
	var direcao: Vector2i

	if diferenca.x != 0:
		direcao = Vector2i(sign(diferenca.x), 0)  # Move no eixo X
	else:
		direcao = Vector2i(0, sign(diferenca.y))  # Move no eixo Y

	var proxima_celula = pos_atual + direcao
	global_position = tilemap.map_to_local(proxima_celula)	

#OVERRIDE
func mover_para_item_longe(coord):
	var pos_atual = tilemap.local_to_map(global_position)
	var pos_item = tilemap.local_to_map(coord)

	var diferenca = pos_item - pos_atual
	var direcao: Vector2i
	
	if pos_item == pos_atual:
		memory_objetives.erase(coord)
		better_item = null
		
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
			legenda.atc_label_pontos(agente, pontos_carregados)
			print(pontos_carregados)
			indo_ate_item = true
			area.call_deferred("def_colision", false)
			item_carregado = area
		if better_item != null:
			if memory_objetives[better_item] == "Estrutura" and area.quantidade_agentes == 2:
				pontos_carregados += area.quantidade_pontos
				legenda.atc_label_pontos(agente, pontos_carregados)
				print(pontos_carregados)
				indo_ate_item = true
				area.call_deferred("def_colision", false)
				item_carregado = area
