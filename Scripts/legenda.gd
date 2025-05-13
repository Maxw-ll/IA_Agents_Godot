extends Control
@onready var back: ColorRect = $ColorRect

@onready var util: Label = $ColorRect/util
@onready var obj: Label = $ColorRect/obj
@onready var est: Label = $ColorRect/est
@onready var reat: Label = $ColorRect/reat


func _ready() -> void:

	var labels = [util, obj, est, reat]
	for lb in labels:
		lb.text = str(0)
	

func atc_label_pontos(tipo_agent, pontos):
	match tipo_agent:
		"Reativo":
			reat.text = str(pontos)
		"Estados":
			est.text = str(pontos)
		"Objetivos":
			obj.text = str(pontos)
		"Utilidade":
			util.text = str(pontos)

func sete_size(x, y):
	back.size.x = x
	back.size.y = y
	
