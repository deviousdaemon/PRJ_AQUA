extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var asciiModeEnabled=true
var asciiNode
var worldManagerNode
var treeRoot

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	treeRoot=get_tree().get_root().get_child(0)
	asciiNode=treeRoot.find_node("ASCIIManager")
	worldManagerNode=treeRoot.find_node("WorldManager")
	set_process(true)
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if asciiModeEnabled==true:
#		if asciiNode.visible!=true:
#			asciiNode.visible=true
		if asciiNode.worldArray!=worldManagerNode.worldArray:
			asciiNode.worldArray=worldManagerNode.worldArray
		if asciiNode.worldWidth!=worldManagerNode.worldWidth:
			asciiNode.worldWidth=worldManagerNode.worldWidth
		if asciiNode.worldHeight!=worldManagerNode.worldHeight:
			asciiNode.worldHeight=worldManagerNode.worldHeight
#		if asciiNode.enabled!=true:
#			asciiNode.enabled=true
		pass
	pass
