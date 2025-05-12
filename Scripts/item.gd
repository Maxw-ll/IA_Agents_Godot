extends Area2D
class_name Item


@export_enum("Cristal", "Metal", "Estrutura")
var tipo_item: String = "Cristal"

@export var quantidade_pontos = 10
@export var quantidade_agentes = 1

func collect_item():
	visible = false
	
func erase_item():
	queue_free()
