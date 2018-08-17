extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var mainViewport

var resolution=Vector2(0,0)
var resScale=80 #1280x720 with 16:9 aspect ratio
var displayWidth
var displayHeight
var fullscreenEnabled=false
var borderlessWindow=false
var windowResizeable=false
var vsyncEnabled=true
var aspectRatio=Vector2(16,9)
var displayWidthOffset=16*aspectRatio.x
var displayHeightOffset=16*aspectRatio.y

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	resolution=Vector2(aspectRatio.x*resScale,aspectRatio.y*resScale)
	mainViewport=get_tree().get_root()
	displayWidth=OS.get_screen_size().x
	displayHeight=OS.get_screen_size().y
	OS.window_fullscreen=fullscreenEnabled
	OS.window_borderless=borderlessWindow
	OS.window_size=resolution
	OS.vsync_enabled=vsyncEnabled
	var newWinPosX=(displayWidth/2)-(resolution.x/2)
	var newWinPosY=(displayHeight/2)-(resolution.y/2)
	OS.window_position=Vector2(newWinPosX,newWinPosY)
#	mainViewport.set_size_override(true,Vector2(newWinPosX,newWinPosY),Vector2(0,0))
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
