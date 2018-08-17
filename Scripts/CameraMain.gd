extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var zoomAmount=0.5
var zoomMax=1+zoomAmount
var zoomMin=zoomAmount
var cameraSpeed=25

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process_input(true)
	set_process(true)
	pass
	
func _process(delta):
	if Input.is_action_pressed("CameraUp"):
		offset.y=lerp(offset.y,offset.y-cameraSpeed,0.25)
		pass
	if Input.is_action_pressed("CameraDown"):
		offset.y=lerp(offset.y,offset.y+cameraSpeed,0.25)
		pass
	if Input.is_action_pressed("CameraLeft"):
		offset.x=lerp(offset.x,offset.x-cameraSpeed,0.25)
		pass
	if Input.is_action_pressed("CameraRight"):
		offset.x=lerp(offset.x,offset.x+cameraSpeed,0.25)
		pass
	pass

func _input(event):
	if event.is_action_released("CameraZoomIn"):
		if zoom.x-zoomAmount>=zoomMin:
			if zoom.y-zoomAmount>=zoomMin:
				zoom.x-=zoomAmount
				zoom.y-=zoomAmount
		pass
	if event.is_action_released("CameraZoomOut"):
		if zoom.x+zoomAmount<=zoomMax:
			if zoom.y+zoomAmount<=zoomMax:
				zoom.x+=zoomAmount
				zoom.y+=zoomAmount
			pass
	pass
