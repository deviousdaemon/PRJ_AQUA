extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var moveSpeed=5
var boundryW=Vector2(0,0)
var boundryH=Vector2(0,0)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process(true)
	set_physics_process(true)
	pass

func _physics_process(delta):
	if Input.is_action_pressed("CameraUp"):
		position.y-=moveSpeed
		pass
	if Input.is_action_pressed("CameraDown"):
		position.y+=moveSpeed
		pass
	if Input.is_action_pressed("CameraLeft"):
		position.x-=moveSpeed
		pass
	if Input.is_action_pressed("CameraRight"):
		position.x+=moveSpeed
		pass
	pass
