extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var zoomAmount=0.5
var zoomMax=1+zoomAmount
var zoomMin=zoomAmount
var cameraSpeed=300
var cameraSpeedCurrent=cameraSpeed
var targetPosition=Vector2(0,0)
var cameraSmoothRate=0.4
var accelAmountCurrent=Vector2(0,0)
var accelAmountMax=Vector2(100,100)
var accelStep=0.01
var accelFactorNeg=Vector2(1,1)
var accelFactorPos=Vector2(1,1)
var accelFactorStep=0.1

var mainNode
var target

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	mainNode=get_tree().get_root().get_child(0)
	target=mainNode.find_node("CameraTarget")
	set_process_input(false)
	set_process(true)
	set_physics_process(true)
	pass
	
func _process(delta):
	pass
	
func _physics_process(delta):
	targetPosition=offset
	var newPosition=offset
#	if Input.is_action_pressed("CameraUp"):
#		if accelAmountCurrent.y-accelStep>-accelAmountMax.y:
#			accelFactorNeg.y+=accelFactorStep
#			accelAmountCurrent.y-=accelStep
#			print("yah")
#			pass
#		targetPosition.y-=cameraSpeed+(accelAmountCurrent.y*accelFactorNeg.y)
#		pass
#	elif Input.is_action_just_released("CameraUp"):
#		if accelAmountCurrent.y<0:
#			accelAmountCurrent.y+=accelStep*2
#		if accelFactorNeg.y>1:
#			accelFactorNeg.y-=accelFactorStep*2
#		pass
#	if Input.is_action_pressed("CameraDown"):
#		if accelAmountCurrent.y+accelStep<accelAmountMax.y:
#			accelFactorPos.y+=accelFactorStep
#			accelAmountCurrent.y+=accelStep
#			pass
#		targetPosition.y+=cameraSpeed+(accelAmountCurrent.y*accelFactorPos.y)
#		pass
#	elif Input.is_action_just_released("CameraDown"):
#		if accelAmountCurrent.y>0:
#			accelAmountCurrent.y-=accelStep*2
#		if accelFactorPos.y>1:
#			accelFactorPos.y-=accelFactorStep*2
#		pass
#	if Input.is_action_pressed("CameraLeft"):
#		if accelAmountCurrent.x-accelStep>-accelAmountMax.x:
#			accelFactorNeg.x+=accelFactorStep
#			accelAmountCurrent.x-=accelStep
#			pass
#		targetPosition.x-=cameraSpeed+(accelAmountCurrent.x*-accelFactorNeg.x)
#		pass
#	elif Input.is_action_just_released("CameraLeft"):
#		if accelAmountCurrent.x<0:
#			accelAmountCurrent.x+=accelStep*2
#		if accelFactorNeg.x>1:
#			accelFactorNeg.x-=accelFactorStep*2
#		pass
#	if Input.is_action_pressed("CameraRight"):
#		if accelAmountCurrent.x+accelStep<accelAmountMax.x:
#			accelFactorPos.x+=accelFactorStep
#			accelAmountCurrent.x+=accelStep
#			pass
#		targetPosition.x+=cameraSpeed+(accelAmountCurrent.x*accelFactorPos.x)
#		pass
#	elif !Input.is_action_pressed("CameraRight"):
#		if accelAmountCurrent.x>0:
#			accelAmountCurrent.x-=accelStep*2
#		if accelFactorPos.x>1:
#			accelFactorPos.x-=accelFactorStep*2
#		pass
	if Input.is_action_pressed("CameraUp"):
		targetPosition.y-=cameraSpeedCurrent
		pass
	if Input.is_action_pressed("CameraDown"):
		targetPosition.y+=cameraSpeedCurrent
		pass
	if Input.is_action_pressed("CameraLeft"):
		targetPosition.x-=cameraSpeedCurrent
		pass
	if Input.is_action_pressed("CameraRight"):
		targetPosition.x+=cameraSpeedCurrent
		pass
	if Input.is_action_pressed("ShiftCameraSpeed"):
		cameraSpeedCurrent=cameraSpeed*2
		pass
	elif Input.is_action_just_released("ShiftCameraSpeed"):
		cameraSpeedCurrent=cameraSpeed
		pass
	offset.x=lerp(newPosition.x,targetPosition.x,cameraSmoothRate*delta)
	offset.y=lerp(newPosition.y,targetPosition.y,cameraSmoothRate*delta)
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
