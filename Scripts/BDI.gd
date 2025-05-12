extends Node

var memoria_global: Dictionary = {}

func atualizar_memoria(agent_id: String, memoria_local: Dictionary):
	for chave in memoria_local:
		if not memoria_global.has(chave):
			memoria_global[chave] = memoria_local[chave]

func solicitar_memoria_global() -> Dictionary:
	return memoria_global.duplicate()
