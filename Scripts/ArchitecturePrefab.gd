extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var type="Arch"
var subType=""
var spriteColor=Color(0,0,0,255)
var spriteColorDefault=Color(25,25,25,255)
var spriteAtlas
var spriteAtlasRegion=Vector2()
var spriteResource
var gridPosition=Vector2()
var condition=0
var readyToStart=0
var spriteSize=0
var gridSize=0
var spriteScale=0
var currentSpriteSheetName=""
var gridScaleRatio

var stepEnabled=false

onready var mainNode=get_tree().get_root().get_child(0)
onready var worldManager=mainNode.find_node("WorldManager")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	visible=false
	set_process(true)
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if readyToStart==1:
		gridScaleRatio=worldManager.gridScaleRatio
		spriteSize=texture.get_width()
		gridSize=worldManager.gridSize
		spriteScale=gridSize/spriteSize*gridScaleRatio.x
		currentSpriteSheetName=worldManager.currentSpriteSheetName
		spriteAtlasRegion.x*=worldManager.originalGridSize
		spriteAtlasRegion.y*=worldManager.originalGridSize
		var spriteAtlasCopy=worldManager.currentSpriteSheetAtlas.duplicate()
		spriteAtlas=AtlasTexture.new()
		spriteAtlas.atlas=spriteAtlasCopy.atlas
		spriteAtlas.region=Rect2(spriteAtlasRegion,Vector2(worldManager.originalGridSize,worldManager.originalGridSize))
		spriteResource=spriteAtlas
		texture=spriteResource
		self_modulate=spriteColor
		scale=Vector2(spriteScale,spriteScale)
		visible=true
		worldManager.connect("worldStep", self, "OnWorldStep")
		
		name=String(gridPosition.x)+","+String(gridPosition.y)+"-"+type+"_"+subType
		
		
		
#		#debug
#		spriteAtlas.atlas=spriteAtlasCopy.atlas
#		spriteAtlasRegion=Vector2(14,15)
#		spriteAtlasRegion.x*=worldManager.originalGridSize
#		spriteAtlasRegion.y*=worldManager.originalGridSize
#		spriteAtlas.region=Rect2(spriteAtlasRegion,Vector2(worldManager.originalGridSize,worldManager.originalGridSize))
#		spriteResource=spriteAtlas
#		texture=spriteResource
#		self_modulate=spriteColor
		
		
		#end
		readyToStart=2
		pass
	pass

func OnWorldStep():
	if stepEnabled!=true:
		stepEnabled=true
	pass
