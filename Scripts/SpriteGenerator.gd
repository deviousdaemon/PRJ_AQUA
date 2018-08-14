extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#Minimum sprite size is 8x8

#Colors
#Maybe easier for color generation if you use template palettes, then vary them with rngesus
const BLACK=Color(0,0,0,1)
const WHITE=Color(1,1,1,1)

# Sprite Proc-Gen Seeds
var procSeedsCreature=[]

var procSeedsHumanoid=[]

var procSeedsItems=[] #Will include nested arrays for Potions, Equipment(Swords, Shields, Staffs, Wands)
# Index Reference: 0=Potions, 1=Swords, 2=Shields, 3=Staffs, 4=Wands

var procSeedsPotions=[]
var procSeedsSwords=[]

var procSeedsArchitecture=[] #Will include nested arrays for Floors, Walls, Doors

var width=0
var height=0
var hasChangedGridSize=false

onready var mainNode=get_tree().get_root().get_child(0)
var worldManager
onready var gStats=mainNode.get_node("GDStats")



#debug
var hasMadeASprite=false
var hasPreparedSeeds=false
var tempImage

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	worldManager=mainNode.find_node("WorldManager")
	width=worldManager.worldWidth
	height=worldManager.worldHeight
	#debug
	set_process(true)
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if !hasPreparedSeeds:
		PrepareSeeds(width,height)
		hasPreparedSeeds=true
		pass
	else:
		set_process(false)
#		if !hasMadeASprite:
#
#			tempImage=GenerateSprite("Creature", null, width, height)
#			tempImage.save_png("lolfukboi.png")
#			#end
#			hasMadeASprite=true
#			pass
		pass
	pass

func PrepareSeeds(w,h):
	#Init Top-Level Arrays
	procSeedsItems.append(procSeedsPotions)
	procSeedsItems.append(procSeedsSwords)
	
	#Init Main Arrays
	#Creature
	var sArray=mainNode.create_2d_array(w,h)
	sArray[3][3]=1
	sArray[4][3]=1
	sArray[3][4]=1
	sArray[4][4]=1
	sArray[2][6]=1
	sArray[5][6]=1
	procSeedsCreature.append(sArray.duplicate())
	sArray.clear()
	
	sArray=mainNode.create_2d_array(w,h)
	sArray[1][2]=1
	sArray[6][2]=1
	sArray[3][4]=1
	sArray[4][4]=1
	sArray[2][5]=1
	sArray[5][5]=1
	procSeedsCreature.append(sArray.duplicate())
	sArray.clear()
	pass


#Minimum sprite size is 8x8
func GenerateSprite(type,subType,w,h):
	#TODO work in randomness factor, could work well for some things
	# ^ will come from subtype, (Fearful, Evil, Chaotic, Peaceful, Neutral, etc)
	var returnImage
	var spriteGrid=mainNode.create_2d_array(w,h)
	randomize()
	var randPos=Vector2(clamp(randi() % int(w*1.25),0,w-1),clamp(randi() % int(h*1.25),0,h-1))
	var mirrorSize=w/2-1
	var maxCells=(w/2)*(h)
	match type:
		"Creature":
			returnImage=GeneratePixels(type,procSeedsCreature,spriteGrid,maxCells, mirrorSize, w, h)
			pass
			
	return returnImage
	pass

func CreateBlankImage(w,h):
	var newImage=Image.new()
	var imgFormat=Image.FORMAT_RGBA8
	var useMipMaps=false
	newImage.create(w,h,useMipMaps,imgFormat)
	newImage.lock()
	return newImage
	pass

func GenerateCircle(img, x0, y0, radius, colour=BLACK):
	#x0, y0 is bottom left
    var result
    var f = 1 - radius
    var ddf_x = 1
    var ddf_y = -2 * radius
    var x = 0
    var y = radius
    img.set_pixel(x0, y0 + radius, colour)
    img.set_pixel(x0, y0 - radius, colour)
    img.set_pixel(x0 + radius, y0, colour)
    img.set_pixel(x0 - radius, y0, colour)
    while x < y:
        if f >= 0: 
            y -= 1
            ddf_y += 2
            f += ddf_y
        x += 1
        ddf_x += 2
        f += ddf_x    
        img.set_pixel(x0 + x, y0 + y, colour)
        img.set_pixel(x0 - x, y0 + y, colour)
        img.set_pixel(x0 + x, y0 - y, colour)
        img.set_pixel(x0 - x, y0 - y, colour)
        img.set_pixel(x0 + y, y0 + x, colour)
        img.set_pixel(x0 - y, y0 + x, colour)
        img.set_pixel(x0 + y, y0 - x, colour)
        img.set_pixel(x0 - y, y0 - x, colour)
		
func ConvertRGBToFloat(r,g,b):
	var floatPer=0.004
	var fR=r*floatPer
	var fG=g*floatPer
	var fB=b*floatPer
	var returnValue=[fR,fG,fB,1]
	pass
	
func GeneratePixels(type,typeArray,sGrid,maxCells, mirrorSize, w, h):
	var returnImage=CreateBlankImage(w,h)
	var startingCell=Vector2(0,0)
	var currentCell=startingCell
	var isStartingCellSelected=false
	var arraySize=typeArray.size()
	randomize()
	var seedIndex=clamp(randi()%arraySize+int(arraySize),0,arraySize-1)
	sGrid=typeArray[seedIndex].duplicate()
	var cellsFilled=0
	var cellsScanned=0
	for y in h-1:
		for x in w-1:
			if sGrid[x][y]==1:
				returnImage.set_pixel(x,y,BLACK)
				returnImage.set_pixel(w-x-1,y,BLACK)
				cellsFilled+=1
				pass
			pass
	for y in h-1:
		for x in w-1:
			if sGrid[x/2][y]==1:
				cellsScanned+=1
				if !isStartingCellSelected:
					if cellsScanned==cellsFilled/2:
						startingCell=Vector2(x,y)
						currentCell=startingCell
						break;
						pass
					else:
						var chanceToSelect=gStats.randi_bernoulli()
						if chanceToSelect==1:
							startingCell=Vector2(x,y)
							currentCell=startingCell
							break;
							pass
						pass
					pass
				pass
			pass
	cellsFilled/=2
	var cellRatToPer=100/maxCells
	var cellsRatio=maxCells-cellsFilled
	var newCellP=float(cellsRatio)/float(maxCells)
	var percentChanceNextFill=(newCellP)
	var chanceNextFillScan=gStats.randi_bernoulli(percentChanceNextFill)
	while chanceNextFillScan==1:
		var xx=currentCell.x
		var yy=currentCell.y
		var randDir=clamp(randi()%4+1,1,4)
		var randCellChance=0.99
		match randDir:
			1: #right
				if xx+mirrorSize<=w-1:
					var chanceFill=gStats.randi_bernoulli(randCellChance)
					if chanceFill==1:
						sGrid[xx+1][yy]=1
						sGrid[w-xx-1][yy]=1
						currentCell.x+=1
						returnImage.set_pixel(xx,yy,BLACK)
						returnImage.set_pixel(w-xx-1,yy,BLACK)
						cellsFilled+=1
						pass
					pass
				pass
			2: #down
				if !yy==h-1:
					var chanceFill=gStats.randi_bernoulli(randCellChance)
					if chanceFill==1:
						sGrid[xx][yy+1]=1
						sGrid[w-xx-1][yy]=1
						currentCell.y+=1
						returnImage.set_pixel(xx,yy,BLACK)
						returnImage.set_pixel(w-xx-1,yy,BLACK)
						cellsFilled+=1
						pass
					pass
				pass
			3: #left
				if !xx==0:
					var chanceFill=gStats.randi_bernoulli(randCellChance)
					if chanceFill==1:
						sGrid[xx-1][yy]=1
						sGrid[w-xx-1][yy]=1
						currentCell.x-=1
						returnImage.set_pixel(xx,yy,BLACK)
						returnImage.set_pixel(w-xx-1,yy,BLACK)
						cellsFilled+=1
						pass
					pass
				pass
			4: #up
				if !yy==0:
					var chanceFill=gStats.randi_bernoulli(randCellChance)
					if chanceFill==1:
						sGrid[xx][yy-1]=1
						sGrid[w-xx-1][yy-1]=1
						currentCell.y-=1
						returnImage.set_pixel(xx,yy,BLACK)
						returnImage.set_pixel(w-xx-1,yy,BLACK)
						cellsFilled+=1
						pass
					pass
				pass
		#end
		cellsRatio=maxCells-cellsFilled
		newCellP=float(cellsRatio)/float(maxCells)
		percentChanceNextFill=(newCellP)
		chanceNextFillScan=gStats.randi_bernoulli(percentChanceNextFill)
		pass
		
	return returnImage
	pass