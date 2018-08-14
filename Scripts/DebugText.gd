extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var checkFPSTime=0.2
var currFPS=""
var timer=0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	currFPS=String(Engine.get_frames_per_second())+" FPS"
	text=currFPS+"\n"+"Frame Time: "+String(delta)
#	timer+=delta
#	if timer>=checkFPSTime:
#		#Current FPS
#		currFPS=String(Engine.get_frames_per_second())+" FPS"
#		#end
#		timer=0
#		pass
	#Current Frame Time
	# Called every frame. Delta is time since last frame.
	pass
