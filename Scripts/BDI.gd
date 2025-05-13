extends Node

var memoria_cells_global: Array = []
var memoria_items_global: Dictionary = {}

func atualizar_memoria_cell(memoria_local: Array):
	for coord in memoria_local:
		if not memoria_cells_global.has(coord):
			memoria_cells_global.append(coord)

func atualizar_memoria_items(memoria_local_pego: Dictionary, memoria_local_visto: Dictionary):
	for chave in memoria_local_visto:
		if not memoria_items_global.has(chave):
			memoria_items_global[chave] = memoria_local_visto[chave]
	
	for chave in memoria_local_pego:
		if memoria_items_global.has(chave):
			memoria_items_global.erase(chave)

func solicitar_memoria_cells_global():
	return memoria_cells_global.duplicate()

func solicitar_memoria_items_global():
	return memoria_items_global.duplicate()
	
func _physics_process(delta: float) -> void:
	pass
	#print("MEMORIA BDI")
	#print(memoria_items_global)
	
