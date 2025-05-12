extends Area2D
class_name Item

var has_collected = false
@onready var collision_: CollisionShape2D = $CollisionShape2D
@export_enum("Cristal", "Metal", "Estrutura")
var tipo_item: String = "Cristal"

@export var quantidade_pontos = 10
@export var quantidade_agentes = 1

func def_visibility(state):
	visible = state
	
func def_colision(state):
	collision_.disabled = not state
	
