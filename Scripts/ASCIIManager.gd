extends RichTextLabel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var worldArray
var enabled=false
var worldWidth
var worldHeight
var worldArrayConverted=false
var worldArrayEntityString
var worldManagerNode
var mainNode
var fontSize=17
var visualLayerCurrent=1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	mainNode=get_tree().get_root().get_child(0)
	worldManagerNode=mainNode.get_node("WorldManager")
	if enabled:
		set_process(true)
		set_process_input(true)
	pass

func _process(delta):
	if enabled:
		if worldArray!=null:
			if !worldArrayConverted:
				worldArrayEntityString=WorldArrayToString(worldArray)
				rect_min_size=Vector2(worldWidth*fontSize, worldHeight*fontSize)
				pass
			bbcode_text="[code][center]"+worldArrayEntityString+"[/center][/code]"
		pass
	pass

func _input(event):
	if event.is_action_released("ActionVisualLayerUp"):
		if visualLayerCurrent==0:
			visualLayerCurrent+=1
			pass
		elif visualLayerCurrent==1:
			visualLayerCurrent+=1
			pass
		pass
		pass
	elif event.is_action_released("ActionVisualLayerDown"):
		if visualLayerCurrent==2:
			visualLayerCurrent-=1
			pass
		elif visualLayerCurrent==1:
			visualLayerCurrent-=1
			pass
		pass
	pass
	
func WorldArrayToString(var array):
	var array0=[]+array[0]
	var array1=[]+array[1]
	var returnString=""
	var tempText=""
	for y in array0.size():
		if y>0:
			returnString+="\n"
			pass
		for x in array0[y].size():
			if array0[x][y]=="blank":
				tempText="X"
			elif array0[x][y]==null:
				tempText="X"
			elif array0[x][y]=="water":
				#color=5db09d
				tempText="[color=#46b588]"+"#"+"[/color]"
			returnString+=tempText
			pass
		pass
	for y in array1.size():
		if y>0:
			pass
		for x in array1[y].size():
			if x!=array1[y].size():
				var sIndex
				if x<array1[y].size():
					sIndex=(array1[y].size())*(array1.size()+1)+x
					pass
				elif x==array1[y].size():
					sIndex=(array1[y].size())*(array1.size()+1)+x+1
					pass
				if typeof(array1[x][y])==TYPE_OBJECT:
					if returnString[sIndex]=="[color=#46b588]"+array1[x][y].name[0]+"[/color]":
						pass
					elif returnString[sIndex]=="blank" || returnString[sIndex]==null:
						returnString[sIndex]="[color=#46b588]"+array1[x][y].name[0]+"[/color]"
						pass
					pass
				elif typeof(array1[x][y])==TYPE_STRING:
					if returnString[sIndex]==array1[x][y]:
						if returnString[sIndex]==array1[x][y]:
							
							pass
						else:
							if returnString[sIndex]=="blank" || returnString[sIndex]==null:
								if array1[x][y]=="water":
									#color=5db09d
									returnString[sIndex]="[color=#46b588]"+"#"+"[/color]"
									pass
								pass
							pass
						pass
					pass
				pass
			pass
		pass
	return returnString


func _on_WorldManager_worldStep():
	if enabled:
		worldArray=worldManagerNode.worldArray
		worldArrayEntityString=WorldArrayToString(worldArray)
		bbcode_text="[code][center]"+worldArrayEntityString+"[/center][/code]"
	pass # replace with function body
