extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var mainViewport

var resWidth=512
var resHeight=512
var displayWidth
var displayHeight
var fullscreenEnabled=false
var borderlessWindow=false
var windowResizeable=false
var vsyncEnabled=true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	mainViewport=get_tree().get_root()
	displayWidth=OS.get_screen_size().x
	displayHeight=OS.get_screen_size().y
	OS.window_fullscreen=fullscreenEnabled
	OS.window_borderless=borderlessWindow
	OS.window_size=Vector2(resWidth,resHeight)
	OS.vsync_enabled=vsyncEnabled
	var newWinPosX=(displayWidth/2)-(resWidth/2)
	var newWinPosY=(displayHeight/2)-(resHeight/2)
	OS.window_position=Vector2(newWinPosX,newWinPosY)
	mainViewport.set_size_override(true,Vector2(newWinPosX,newWinPosY),Vector2(0,0))
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
