item = { }

function item:init( )
	self._itemTable = {}
	--self._book = makeBox(100, 100, 0, "book_sprite.png")
	self._effectTable = { }
	self._itemDataTabel = { }
	self._throwList = { }
	self._itemDataTabel = loadCSVData("data/items.csv")
	self._spawnableItems = { }
	for i,v in pairs(self._itemDataTabel) do
		v.mesh = makeBox(100, 100, 0, ""..v.gfx.."")
		--if v.canSpawn == "yes" then
			table.insert(self._spawnableItems, v)
		--end
		--print("V: "..i.."")
		--print("V NAME: "..v.description.."")
	end

	self._smokeMesh = makeBox(40, 40, 0, "assets/effects/mm_ef_smoke.png")

	self._itemFakeLabel = { }
	self._itemFakeLabel[1] = "<c:F00>Heap of 30 torches (u) - A</>"
	self._itemFakeLabel[2] = "<c:00FF00>Box with Flint and Steel (u) - 1</>"
	self._itemFakeLabel[3] = "Cheap Gloves (e) - <E>"
	self._itemFakeLabel[4] = "Potion of Water (u)"
	self._itemFakeLabel[5] = "Scroll of Darkness (u)"
	self._itemFakeLabel[6] = "Scroll of Item Detect (u)"
	self._itemFakeLabel[7] = "Spellbook of Frost (u)"
	self._itemFakeLabel[8] = "Spellbook of Fire Blast (u)"
	self._itemFakeLabel[9] = "Helmet of the Dovakin (u)"
	self._itemFakeLabel[10] = "Cursed Amulet Ring (u)" 

	self._itemColorTable = { }--will hold the colors

	self._moveDir = { }
	self._moveDir[1] = {0, -1} -- UP, L, D, R
	self._moveDir[2] = {-1, 0}
	self._moveDir[3] = {0, 1}
	self._moveDir[4] = {1, 0}

	self._randomDamageMin = 4
	self._randomDamageMax = 45
	---- later, add a multiplier based on your level/enemy average level :)

	self._firePotionDamage = 8

	self._magicMissileItem = 14
	self._bulletItem = 64
	self._orbItem = 73
	self._emberOrb = 84

	self._dialogueLines = {}
	self._dialogueLines[1] = "<c:d27d2c>Gobber screams:</c> Why, why, why, why, why?"
	self._dialogueLines[2] = "<c:d27d2c>Gobber screams:</c> Not this cursed, blasted, place again!"
	self._dialogueLines[3] = "<c:d27d2c>Gobber says:</c> You're as useful as a vampire wearing sunglasses!"
	self._dialogueLines[4] = "<c:d27d2c>Gobber says:</c> If only I'd have grabbed .. *my bag* of goodies"
	self._dialogueLines[5] = "<c:d27d2c>Gobber mumbles to himself</c>"
	self._dialogueLines[6] = "<c:d27d2c>Gobber prays to the fervent goddes</c>"

	self._epicItemList = {}
	self._epicItemList[1] = 34
	self._epicItemList[2] = 31
	self._epicItemList[3] = 29
	self._epicItemList[4] = 36

	self._throwProcessing = false
	
end

function item:getThrowProcessing( )
	return self._throwProcessing
end

function item:updateLightning()
	local px, py = player:returnPosition( )
	for i,v in ipairs(self._itemTable) do
		local dist = math.distance(px, py, v.x, v.y)
		if dist > 1 then
			local lightFactor = dist/(7-Game.lightFactor)
			image:setColor(v.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
		end	
	end
end

function item:updateLightning2(x, y)
	local px, py = x,y
	for i,v in ipairs(self._itemTable) do
		local dist = math.distance(px, py, v.x, v.y)
		if dist > 1 then
			local lightFactor = dist/(7-Game.lightFactor)
			image:setColor(v.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
		else
			local lightFactor = 0
			image:setColor(v.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
		end	
	end
end

function item:_getRandomItemForCurrentLevel( )

end
--_dmg, _name, _multi, _armor_def, _armor_arcane_def
function item:throwSetStats(_gfxID, _orientation, __x, __y, _goForPlayer, _dmg, _name, _multi, _armor_def, _armor_arcane_def)
	sound:play(Game.dropItem)
	local distance = 5
	local throwSpeed = 0.5
	local throwTimer = Game.worldTimer
	local rndItem = _gfxID
	local _x, _y 
	local thrownByPlayer = false
	if _goForPlayer == nil then
		if __x == nil and __y == nil then
			_x, _y = player:returnPosition( )
			thrownByPlayer = true
		else
			_x = __x
			_y = __y
			thrownByPlayer = false
		end
	else 
		thrownByPlayer = _goForPlayer
		_x = __x
		_y = __y
	end
	--,weapon_dmg, name, weapon_multi, armor_def, armor_arcane_def, 
	--print("GFXID IS: ".._gfxID.."")
		local temp = {
			id = #self._throwList + 1,
			x = _x,
			y = _y,
			distance = 6,
			speed = 0.04,
			throwTimer = Game.worldTimer,
			gfx = image:new3DImage(self._itemDataTabel[rndItem].mesh, _x*100, 100, _y*100, 2 ), 
			name = _name,
			weight = self._itemDataTabel[rndItem].weight,
			weapon_dmg = _dmg,
			weapon_multi = _multi,
			spell_dmg = self._itemDataTabel[rndItem].sdmg,
			spell_atune = self._itemDataTabel[rndItem].sa,
			armor_def = _armor_def,
			armor_arcane_def = _armor_arcane_def,
			_type = self._itemDataTabel[rndItem]._type,
			gfxID = rndItem,
			value = self._itemDataTabel[rndItem].value,
			effect = self._itemDataTabel[rndItem].effect,
			color = self._itemDataTabel[rndItem].color,
			description = self._itemDataTabel[rndItem].description,
			spawnChance = self._itemDataTabel[rndItem].spawnChance,
			modifierType = self._itemDataTabel[rndItem].modifierType,
			modifier = self._itemDataTabel[rndItem].modifier,
			hitSomething = false,
			orient = _orientation,
			isPlayerThrown = thrownByPlayer,
			effect = self._itemDataTabel[rndItem].effect,	
			cur = 1,			
			ALABALAPORTOCALA = "DA BA",
		}
	--	print("ITEM NAME: "..temp.name.."")
		if temp._type == "Armor" then
			temp.armor_def = _armor_def
			temp.armor_arcane_def = _armor_arcane_def
			temp.name = _name
		elseif temp._type == "Weapon" then
			temp.weapon_dmg =  _dmg
			temp.weapon_multi = _multi
			temp.name = _name					
		end
		--print("".._dmg.." | ".._name.." | ".._multi.." | ".._armor_def.." | ".._armor_arcane_def.."")
		--print("FUCKING THIS! Name: "..temp.name.." DMG: "..temp.weapon_dmg.."")
	--print("WEEE AND THRWWW")
		table.insert(self._throwList, temp)

end

function item:throw(_gfxID, _orientation, __x, __y, _goForPlayer, _dmg, _name, _multi, _armor_def, _armor_arcane_def)
	sound:play(Game.dropItem)
	local distance = 5
	local throwSpeed = 0.5
	local throwTimer = Game.worldTimer
	local rndItem = _gfxID
	local _x, _y 
	local thrownByPlayer = false
	if _goForPlayer == nil then
		if __x == nil and __y == nil then
			_x, _y = player:returnPosition( )
			thrownByPlayer = true
		else
			_x = __x
			_y = __y
			thrownByPlayer = false
		end
	else 
		thrownByPlayer = _goForPlayer
		_x = __x
		_y = __y
	end
	--print("GFXID IS: ".._gfxID.."")
	local temp = {
		id = #self._throwList + 1,
		distance = 5,
		speed = 0.04,
		throwTimer = Game.worldTimer,
		gfx = image:new3DImage(self._itemDataTabel[rndItem].mesh, _x*100, 100, _y*100, 2 ),
		x = _x,
		y = _y,
		gfxID = rndItem,
		orient = _orientation,
		weight = self._itemDataTabel[rndItem].weight,
		weapon_dmg = self._itemDataTabel[rndItem].wmd,
		isPlayerThrown = thrownByPlayer,
		effect = self._itemDataTabel[rndItem].effect,
		cur = 1,
		_type = self._itemDataTabel[rndItem]._type,
		name = self._itemDataTabel[rndItem].name,
		hitSomething = false,
		spell_dmg = self._itemDataTabel[rndItem].sdmg,
		spell_atun = self._itemDataTabel[rndItem].sa,
	}
	--print("WEEE AND THRWWW")
	table.insert(self._throwList, temp)
end



function item:getThrowListSize( )
	return #self._throwList
end

function item:updateThrow()
	local rx, ry, rz = camera:getRot( )
	for i,v in ipairs(self._throwList) do
		--self._throwProcessing = true
		if Game.worldTimer > v.throwTimer + v.speed then
			local checkX = v.x + self._moveDir[v.orient][1]
			local checkY = v.y + self._moveDir[v.orient][2]
			local wallCheckResult = rngMap:isWallAt(checkX, checkY)
			local entityCheck, entityID = entity:isEntityAt(checkX, checkY)
			local _x, _y = player:returnPosition( )
			if v.isPlayerThrown == true then
				if wallCheckResult == false and entityCheck == false then
					v.x = v.x + self._moveDir[v.orient][1]
					v.y = v.y + self._moveDir[v.orient][2]
					v.throwTimer = Game.worldTimer
					image:setLoc(v.gfx, v.x*100, 100, v.y*100)

					image:setRot3D(v.gfx, 0, ry, 0)
					v.distance = v.distance - 1
				else
					v.hitSomething = true
					local _entName = entity:getName(entityID)

					if _entName ~= nil then
						log:newMessage("You hit <c:27F>".._entName.."</c> for "..v.weight.." damage")
						--print("TYPE IS: "..v._type.."")
						if v._type ~= "Spell" and v._type ~= "Projectile" then
							entity:_doDamage(entityID, v.weight + v.weapon_dmg)
						elseif v._type == "Projectile" then
							local playerGunKnowledge = player:_getGunKnowledge( )
							local damageToDo = v.spell_dmg + math.ceil(v.spell_dmg * playerGunKnowledge/10)
							entity:_doDamage(entityID, damageToDo)
							player:_trainGunStats( )
						else
							local playerSpellKnowledge = player:_getSpellKnowledge( )
							local damageToDo = v.spell_dmg + math.ceil(v.spell_dmg * playerSpellKnowledge/10)
							entity:_doDamage(entityID, damageToDo)
							-- don't forget to train the spell:
							player:_trainSpell( )
							--print("SPELL TRAINING")
						end
					end

					if v.effect ~= "nil" then
						local _v = entity:getList()[entityID]
						if _v ~= nil then
							self:doItemEffect(v, _v.x, _v.y)
						elseif wallCheckResult == true then
							self:doItemEffect(v, v.x, v.y)
						end	
					end
					v.distance = 0
				end
			else
				-- check to see if it didn't hit the wall, or the player
				if (v.x ~= _x or v.y ~= _y) and wallCheckResult == false then
					--[[v.x = v.x + self._moveDir[v.orient][1]
					v.y = v.y + self._moveDir[v.orient][2]--]]
					-- Here's where it gets tricky. Technically,
					-- I don't have time to get a propper Fov and LoS 
					-- algorithm in place. So what I'mma gonna do is
					-- when the entity tries to throw an item at you,
					-- it will try and get a path to you.
					-- The thrown item will travel down that path.
					-- In case a path isn't obtainable, the entity
					-- will just throw straight :)
					local path = pather:getPath(v.x, v.y, _x, _y)
					if path ~= nil then
						local nodeList = { }
						local nidx = 0
						for node, count in path:nodes( ) do
							nidx = nidx + 1
							nodeList[nidx] = { }
							nodeList[nidx]._x = node:getX( )
							nodeList[nidx]._y = node:getY( )
						end

						if nodeList ~= nil then
							if nodeList[v.cur+1] ~= nil then
								v.x = nodeList[v.cur+1]._x
								v.y = nodeList[v.cur+1]._y
								v.cur = v.cur + 1
							end
						else
							v.x = v.x + self._moveDir[v.orient][1]
							v.y = v.y + self._moveDir[v.orient][2]
						end
					else
						v.x = v.x + self._moveDir[v.orient][1]
						v.y = v.y + self._moveDir[v.orient][2]
					end
					v.throwTimer = Game.worldTimer
					image:setLoc(v.gfx, v.x*100, 100, v.y*100)

					image:setRot3D(v.gfx, 0, ry, 0)
					v.distance = v.distance - 1
				else
					v.hitSomething = true
					local px, py = player:returnPosition( )
					if entityCheck == true then -- did it hit another entity
						local _entName = entity:getName(entityID)
						log:newMessage("It hit entity <c:27F>".._entName.."</c> for "..v.weight.."damage")
						if v._type ~= "Spell" then
							entity:_doDamage(entityID, v.weight + v.weapon_dmg)
						else
							local playerSpellKnowledge = player:_getSpellKnowledge( )
							local damageToDo = v.spell_dmg + math.ceil(v.spell_dmg * playerSpellKnowledge)
							entity:_doDamage(entityID, damageToDo)
						end

						if v.effect ~= "nil" then
							local _v = entity:getList()[entityID]
							self:doItemEffect(v, v.x, v.y)						
						end
					elseif v.x == px and v.y == py then -- it hit the player

						if v.effect ~= "nil" then
							self:doItemEffect(v, v.x, v.y)						
						end						
						log:newMessage("You were hit for "..v.weight.." damage")
						player:receiveDamage(v.weight)
				
					end					
					--entity:_doDamage(entityID, v.weight + v.weapon_dmg)
					v.distance = 0
				end

			end
		end
		local px, py = player:returnPosition( )
		local dist = math.distance(px, py, v.x, v.y)
		if dist > 1 then
			local lightFactor = dist/(7-Game.lightFactor)
			image:setColor(v.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
		end	
		if v.distance <= 0 then
			self:destroyThrownitem(i)
		end
		self._throwProcessing = true
	end
	if #self._throwList == 0 then
		self._throwProcessing = false
	else
		self._throwProcessing = true
	end
end

function item:_debugMakeTableOfSpawnableItems( )

end

---- MinlevelToSpawn MIGHT BE FUCKING BROKEN! 
function item:new(_x, _y, _item)
	local itemNr = #self._itemDataTabel
	local rndItem = math.random(1,itemNr)
	local tableToSpawnFrom = self._itemDataTabel
	local string = "yes"
	local tempLevToSpawnFrom = nil

	if _item ~= nil then
		 rndItem = _item
		 string = "no"
		 tempLevToSpawnFrom = 0
	else
		tableToSpawnFrom = self._spawnableItems
		rndItem = math.random(1,#tableToSpawnFrom)
	end

	local itemTableSize = #self._itemTable
	local minLevelsToSpawn = tableToSpawnFrom[rndItem].AllowedFrom
	if tempLevToSpawnFrom ~= nil then
		minLevelsToSpawn = tempLevToSpawnFrom
	end
	if Game.dungeoNLevel >= minLevelsToSpawn then
		if tableToSpawnFrom[rndItem].canSpawn == "yes" or tableToSpawnFrom[rndItem].canSpawn == ""..string.."" then
			local rnd = math.random(1, 100)
			if _item ~= nil then
				rnd = tableToSpawnFrom[rndItem].spawnChance
			end
			if rnd <= tableToSpawnFrom[rndItem].spawnChance + itemTableSize  then
				local temp = {
					id = #self._itemTable + 1,
					x = _x,
					y = _y,
					gfx = image:new3DImage(tableToSpawnFrom[rndItem].mesh, _x*100, 100, _y*100, 2 ), 
					name = "<c:"..tableToSpawnFrom[rndItem].color..">"..tableToSpawnFrom[rndItem].name.."</c>",
					weight = tableToSpawnFrom[rndItem].weight,
					weapon_dmg = tableToSpawnFrom[rndItem].wmd,
					weapon_multi = tableToSpawnFrom[rndItem].wmulti,
					spell_dmg = tableToSpawnFrom[rndItem].sdmg,
					spell_atune = tableToSpawnFrom[rndItem].sa,
					armor_def = tableToSpawnFrom[rndItem].adef,
					armor_arcane_def = tableToSpawnFrom[rndItem].aarcdef,
					_type = tableToSpawnFrom[rndItem]._type,
					gfxID = rndItem,
					value = tableToSpawnFrom[rndItem].value,
					effect = tableToSpawnFrom[rndItem].effect,
					color = tableToSpawnFrom[rndItem].color,
					description = tableToSpawnFrom[rndItem].description,
					spawnChance = tableToSpawnFrom[rndItem].spawnChance,
					modifierType = tableToSpawnFrom[rndItem].modifierType,
					modifier = tableToSpawnFrom[rndItem].modifier,
				}
			--	print("ITEM NAME: "..temp.name.."")
				if temp._type == "Armor" then
					temp.armor_def = temp.armor_def + math.floor( math.random(temp.armor_def/2, temp.armor_def/2+temp.armor_def/2) )
					temp.armor_arcane_def = temp.armor_arcane_def + math.floor( math.random( temp.armor_arcane_def/2,  temp.armor_arcane_def/2 + temp.armor_arcane_def/2) )
					temp.name = temp.name.." +<c:dad45e>"..temp.armor_def.." def</c>"
				elseif temp._type == "Weapon" then
					temp.weapon_dmg =  temp.weapon_dmg + math.floor( math.random(temp.weapon_dmg/2, temp.weapon_dmg/2+temp.weapon_dmg/2) )
					temp.weapon_multi = temp.weapon_multi + math.floor( math.random(temp.weapon_multi/2, temp.weapon_multi/2+temp.weapon_multi/2) )
					temp.name = temp.name.." +<c:dad45e>"..temp.weapon_dmg.." dmg</c>"					
				end

				local px, py = player:returnPosition( )
				local dist = math.distance(px, py, temp.x, temp.y)
				if dist > 1 then
					local lightFactor = dist/(7-Game.lightFactor)
					image:setColor(temp.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
				end	

				table.insert(self._itemTable, temp )
			end
		--	print("THIS HAPPENED")
		else
		--	self:new(_x, _y, _item)
		end
	end
end

---- MinlevelToSpawn MIGHT BE FUCKING BROKEN! 
function item:newSetStats(_x, _y, _item, _dmg, _name, _multi, _armor_def, _armor_arcane_def)
	local itemNr = #self._itemDataTabel
	local rndItem = math.random(1,itemNr)
	local tableToSpawnFrom = self._itemDataTabel
	local string = "yes"
	local tempLevToSpawnFrom = nil

	if _item ~= nil then
		 rndItem = _item
		 string = "no"
		 tempLevToSpawnFrom = 0
	else
		tableToSpawnFrom = self._spawnableItems
		rndItem = math.random(1,#tableToSpawnFrom)
	end

	local itemTableSize = #self._itemTable
	local minLevelsToSpawn = tableToSpawnFrom[rndItem].AllowedFrom
	if tempLevToSpawnFrom ~= nil then
		minLevelsToSpawn = tempLevToSpawnFrom
	end
	if Game.dungeoNLevel >= minLevelsToSpawn then
		if tableToSpawnFrom[rndItem].canSpawn == "yes" or tableToSpawnFrom[rndItem].canSpawn == ""..string.."" then
			local rnd = math.random(1, 100)
			if _item ~= nil then
				rnd = tableToSpawnFrom[rndItem].spawnChance
			end
			if rnd <= tableToSpawnFrom[rndItem].spawnChance + itemTableSize  then
				local temp = {
					id = #self._itemTable + 1,
					x = _x,
					y = _y,
					gfx = image:new3DImage(tableToSpawnFrom[rndItem].mesh, _x*100, 100, _y*100, 2 ), 
					name = _name,
					weight = tableToSpawnFrom[rndItem].weight,
					weapon_dmg = _dmg,
					weapon_multi = _multi,
					spell_dmg = tableToSpawnFrom[rndItem].sdmg,
					spell_atune = tableToSpawnFrom[rndItem].sa,
					armor_def = _armor_def,
					armor_arcane_def = _armor_arcane_def,
					_type = tableToSpawnFrom[rndItem]._type,
					gfxID = rndItem,
					value = tableToSpawnFrom[rndItem].value,
					effect = tableToSpawnFrom[rndItem].effect,
					color = tableToSpawnFrom[rndItem].color,
					description = tableToSpawnFrom[rndItem].description,
					spawnChance = tableToSpawnFrom[rndItem].spawnChance,
					modifierType = tableToSpawnFrom[rndItem].modifierType,
					modifier = tableToSpawnFrom[rndItem].modifier,
				}
			--	print("ITEM NAME: "..temp.name.."")
				if temp._type == "Armor" then
					temp.armor_def = _armor_def
					temp.armor_arcane_def = _armor_arcane_def
					temp.name = _name
				elseif temp._type == "Weapon" then
					temp.weapon_dmg =  _dmg
					temp.weapon_multi = _multi
					temp.name = _name					
				end

				local px, py = player:returnPosition( )
				local dist = math.distance(px, py, temp.x, temp.y)
				if dist > 1 then
					local lightFactor = dist/(7-Game.lightFactor)
					image:setColor(temp.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
				end	

				table.insert(self._itemTable, temp )
			end
		--	print("THIS HAPPENED")
		else
		--	self:new(_x, _y, _item)
		end
	end
end

function item:getItemsAt(_x, _y)
	local listOfItems = {}
	for i,v in ipairs(self._itemTable) do
		if v.x == _x and v.y == _y then
			local temp = {
				name = v.name
			}
			table.insert(listOfItems, temp)
		end
	end
	
	return listOfItems
end

function item:newInBox(_x, _y, _item)
	local itemNr = #self._itemDataTabel
	local rndItem = math.random(1,itemNr)
	local tableToSpawnFrom = self._itemDataTabel
	local string = "yes"
	local tempLevToSpawnFrom = nil

	if _item ~= nil then
		 rndItem = _item
		 string = "no"
		 tempLevToSpawnFrom = 0
	else
		tableToSpawnFrom = self._spawnableItems
		rndItem = math.random(1,#tableToSpawnFrom)
	end

	local itemTableSize = #self._itemTable
	local minLevelsToSpawn = tableToSpawnFrom[rndItem].AllowedFrom
	if tempLevToSpawnFrom ~= nil then
		minLevelsToSpawn = tempLevToSpawnFrom
	end
	if Game.dungeoNLevel >= minLevelsToSpawn then
		if tableToSpawnFrom[rndItem].canSpawn == "yes" or tableToSpawnFrom[rndItem].canSpawn == ""..string.."" then
			local rnd = math.random(1, 100)
			if _item ~= nil then
				rnd = 2--tableToSpawnFrom[rndItem].spawnChance
			end
			if rnd ~= 0  then
				local temp = {
					id = #self._itemTable + 1,
					x = _x,
					y = _y,
					gfx = image:new3DImage(tableToSpawnFrom[rndItem].mesh, _x*100, 100, _y*100, 2 ), 
					name = "<c:"..tableToSpawnFrom[rndItem].color..">"..tableToSpawnFrom[rndItem].name.."</c>",
					weight = tableToSpawnFrom[rndItem].weight,
					weapon_dmg = tableToSpawnFrom[rndItem].wmd,
					weapon_multi = tableToSpawnFrom[rndItem].wmulti,
					spell_dmg = tableToSpawnFrom[rndItem].sdmg,
					spell_atune = tableToSpawnFrom[rndItem].sa,
					armor_def = tableToSpawnFrom[rndItem].adef,
					armor_arcane_def = tableToSpawnFrom[rndItem].aarcdef,
					_type = tableToSpawnFrom[rndItem]._type,
					gfxID = rndItem,
					value = tableToSpawnFrom[rndItem].value,
					effect = tableToSpawnFrom[rndItem].effect,
					color = tableToSpawnFrom[rndItem].color,
					description = tableToSpawnFrom[rndItem].description,
					spawnChance = tableToSpawnFrom[rndItem].spawnChance,
					modifierType = tableToSpawnFrom[rndItem].modifierType,
					modifier = tableToSpawnFrom[rndItem].modifier,
				}
				--print("ITEM NAME: "..temp.name.."")
				if temp._type == "Armor" then
					temp.armor_def = temp.armor_def + math.floor( math.random(temp.armor_def/2, temp.armor_def/2+temp.armor_def/2) )
					temp.armor_arcane_def = temp.armor_arcane_def + math.floor( math.random( temp.armor_arcane_def/2,  temp.armor_arcane_def/2 + temp.armor_arcane_def/2) )
					temp.name = temp.name.." +<c:dad45e>"..temp.armor_def.." def</c>"
				elseif temp._type == "Weapon" then
					temp.weapon_dmg =  temp.weapon_dmg + math.floor( math.random(temp.weapon_dmg/2, temp.weapon_dmg/2+temp.weapon_dmg/2) )
					temp.weapon_multi = temp.weapon_multi + math.floor( math.random(temp.weapon_multi/2, temp.weapon_multi/2+temp.weapon_multi/2) )
					temp.name = temp.name.." +<c:dad45e>"..temp.weapon_dmg.." dmg</c>"					
				end

				local px, py = player:returnPosition( )
				local dist = math.distance(px, py, temp.x, temp.y)
				if dist > 1 then
					local lightFactor = dist/(7-Game.lightFactor)
					image:setColor(temp.gfx, 1-lightFactor, 1-lightFactor, 1-lightFactor, 1)
				end	

				table.insert(self._itemTable, temp )
			end
			--print("THIS HAPPENED")
		else
			self:new(_x, _y, _item)
		end
	end
end

function item:update( )
	local rx, ry, rz = camera:getRot( )
	for i,v in ipairs(self._itemTable) do
		
		--print("I IS: "..i.."")
		image:setRot3D(v.gfx, rx, ry, 0)
	end

	self:updateEffects( )

	self:updateThrow()
end

function item:isItemAt(_x, _y)
	local bool = false
	local id = nil
	for i,v in ipairs(self._itemTable) do
		if v.x == _x and v.y == _y then
			bool = true
			id = i
			--log:newMessage("There is an item here: "..v.name.."")
			
		end
	end

	return bool, id
end

function item:dropitem(_i, _forceDelete)
	local _item = self._itemTable[_i]
	image:removeProp(_item.gfx, 2)
	_item.gfx = nil
	if _forceDelete ~= true then
		table.remove(self._itemTable, _i)
	end
end

function item:removeAll( )
	for i,v in ipairs(self._itemTable) do
		self:dropitem(i, true)
	end

	for i = 1, #self._itemTable do
		table.remove(self._itemTable, i)
	end
end

function item:destroyThrownitem(_i)
	local _item = self._throwList[_i]

	image:removeProp(_item.gfx, 2)
	_item.gfx = nil
	if _item._type ~= "Potion" and _item._type ~= "Spell" and _item._type ~= "Projectile" then
		--
		--self:new(_item.x, _item.y, _item.gfxID )
		item:newSetStats(_item.x, _item.y, _item.gfxID, _item.weapon_dmg, _item.name,  _item.weapon_multi,  _item.armor_def,   _item.armor_arcane_def)
	elseif _item._type ~= "Spell" and _item._type ~= "Projectile" then
		if _item.hitSomething == false then
			item:newSetStats(_item.x, _item.y, _item.gfxID, _item.weapon_dmg, _item.name,  _item.weapon_multi,  _item.armor_def,   _item.armor_arcane_def)
			--self:new(_item.x, _item.y, _item.gfxID )
		end
	end
	table.remove(self._throwList, _i)
end

function item:returnItem(_id)
	local _item = self._itemTable[_id]
	return _item
end


-----------------------------------------------------------
----------------------- EFFECTS ---------------------------
-----------------------------------------------------------
function item:doItemEffect(_v, _px, _py, _toPlayer)
	local v = _v

	local px = v.x
	local py = v.y

	if _px ~= nil and _py ~= nil then
		px = _px
		py = _py
	end
	local endGameEffect = false
	if v.isPlayerThrown == true then
		--print("CHECK IF PLAYER THROWN")
		if v.effect == "god_power" then
			self:doWinCondition(_v, px, py, _toPlayer)
			endGameEffect = true
		end		
	end
	if endGameEffect == false then
		if v.effect == "heal" then
			self:createItemEffect_HEAL(px, py)
		elseif v.effect == "heal_single" then
			self:createItemEffect_HEALSINGLE(px, py)
			-- apply health here
		elseif v.effect == "burn" then
			self:createItemEffect_FIRE(px, py, v.spell_dmg)
		elseif v.effect == "teleport" then
			self:createItemEffect_TELEPORT(px, py)
		elseif v.effect == "summon" then

			self:createItemEffect_SUMMON(px, py)
		elseif v.effect == "noctus_summon" then
			self:createItemEffect_NOCTUSSUMMON(px, py)
		elseif v.effect == "summon_gobber" then
			self:createItemEffect_SUMMONGober(px, py)
		elseif v.effect == "summon_multi" then
			self:createItemEffect_SUMMONNMulti(px, py)
		elseif v.effect == "summon_nextto" then
			self:createItemEffect_SUMMONNearby(px, py)
		elseif v.effect == "darkness" then
			self:createItemEffect_SpawnDarkness(px, py)
		elseif v.effect == "reveal_map" then
			self:createItemEffect_REVEAL(px, py)
		elseif v.effect == "darkness_repulse" then
			self:createItemEffect_RemoveDarkness(px, py)
		elseif v.effect == "damage_all" then
			--print("DMG SHOULD BE: "..v.spell_dmg.."")
			if _toPlayer == false then
				self:createItemEffect_DamagePlayer(px, py, v.spell_dmg)
			else
				self:createItemEffect_DamageAll(px, py, v.spell_dmg)
			end
		elseif v.effect == "gobber_dialogue" then
			self:createItemEffect_GobberDialogue( )
		elseif v.effect == "magic_missile" then
			self:createItemEffect_MagicMissile(px, py, _toPlayer)
		elseif v.effect == "sleep" then
			self:createItemEffect_Sleep(px, py, _toPlayer)
		elseif v.effect == "sleep_missile" then
			self:createItemEffect_SleepEffect(px, py, _toPlayer)
		elseif v.effect == "shoot" then
			self:createItemEffect_Shoot(px, py, _toPlayer)
		elseif v.effect == "shoot_one" then
			self:createItemEffect_Shoot_One(px, py, _toPlayer)
		elseif v.effect == "shoot_double" then
			self:createItemEffect_ShootDouble(px, py, _toPlayer)
		elseif v.effect == "magic_missile_proj" then
			self:createItemEffect_MagicMissileImpact(px, py, _ammount)
		elseif v.effect == "bullet_impact" then
			self:createItemEffect_BulletImpact(px, py, _ammount)		
		elseif v.effect == "polymorph" then
			self:createItemEffect_POLYMORPH(px, py)
		elseif v.effect == "summon_epic" then
			self:createItemEffect_SUMMONEPIC(px, py)
		elseif v.effect == "ember" then
			self:createItemEffect_EmberSpell(px, py, _toPlayer)
		elseif v.effect == "WinCondition" then
			self:doWinCondition(_v, px, py, _toPlayer)
		elseif v.effect == "god_power" then
			self:createItemEffect_GodPower(px, py, _toPlayer)
		end
	end
end


function item:doWinCondition(_v, _x, _y, _toPlayer)
	local v = _v
	player:setKilledBy("<c:9FC43A>lovely mass of love and friendship</c>")
--[[	for i = 1, 6 do
		rngMap:destroyMap( )
		item:removeAll( )
		entity:removeAll( )
		interface:destroyUI ( )
		item:removeAll( )
	end
	--player:saveStats( )
	
	_bGameLoaded = false
	_bGuiLoaded = false


	currentState = 22--
	Game.dungeoNLevel = 1--]]

	--if _toPlayer ~= false then
	---	interface:showVictory( )
	--end
	--[[_bGameLoaded = false
	_bGuiLoaded = false
	Game.dungeoNLevel = 11
	currentState = 24--]]
						if rngMap:isTowerLevel( ) then
							Game:exportSaveInfo( )
							Game.classOptions = nil
							Game.dungeonType = 1
							Game.dungeoNLevel = 11
							
						end
						currentState = 16


	--[[

	--]]
end

function item:createItemEffect_GodPower(_x, _y, _toPlayer)
	local randomRoll = math.random(1, 8)
	local effectPower = {}
	effectPower[1] = "summon_nextto"
	effectPower[2] = "heal_single"
	effectPower[3] = "teleport"
	effectPower[4] = "summon_multi"
	effectPower[5] = "summon_nextto"
	effectPower[6] = "summon_nextto"
	effectPower[7] = "teleport"
	effectPower[8] = "heal_single"
	effectPower[8] = "magic_missile"
	

	if randomRoll < #effectPower then
		print("EFFECT POWER: "..effectPower[randomRoll])
		local temp = {
			effect = effectPower[randomRoll],
			isPlayerThrown = false,
			spell_dmg = 15,
		}
		item:doItemEffect(temp, _x, _y, false)
	end
end

function item:createItemEffect_POLYMORPH(_x, _y)
	local _mesh = makeBox(40, 40, 0, "assets/effects/poly1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/polymorph_2.png")
	local portalCounter = 0
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if i ~= 1  then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 2,
		}

		if i == 1 then
			temp.ix = 0
			temp.iy = 0
			temp.z = 100
			temp.life = 100
			temp.mainElement = true
		end
		portalCounter = portalCounter + 1
		table.insert(self._effectTable, temp)
	end	

	local px, py = player:returnPosition( )
	if (px == _x and py == _y) then -- yep, player
		--player:healPlayer( )
		log:newMessage("<c:26EB5D>You feel a change inside you!!</c>")
	else -- check for enemies
		rngMap:isDarknessAt(_x, _y, true)
		local bool, id = entity:isEntityAt(_x, _y)
		if bool == true then -- yep, entity is there
			--print("BOOL IS TRUE")
			local v = entity:getList( )[id]
			if v ~= nil then
				--v.hp = v.initial_health
				--log:newMessage(""..v.name.." <c:26EB5D> has recovered his health</c>")
				local oldName = v.name
				v.hp = 0
				local rnd = math.random(1, #entity:makeSpawnListForLevel( ))
				local newName = entity:new(_x, _y, rnd)
				log:newMessage(""..oldName.." was turned into "..newName.."")
			end
		end
	end	


end

function item:createItemEffect_BulletImpact(_x, _y,_ammount)
	local _mesh = self._smokeMesh
	local _mesh2 = self._smokeMesh--makeBox(50, 50, 0, "assets/effects/mm_ef_smoke.png")
	local tmesh = _mesh
	local rndCheck = math.random(1,2)
	if rndCheck == 1 then
		tmesh = _mesh2
	end
	local temp = {
		id = #self._effectTable + 1,
		gfx = image:new3DImage(tmesh, 10, 10-1*20,  10, 2 ), 
		x = (_x),
		y = (_y),
		ix = math.random(-40, 40),
		iy = math.random(-40, 40),
		z = 100-1*20,
		life = 100,
		speed = 8,
		_effectType = 1,
	}

	table.insert(self._effectTable, temp)	
end
function item:createItemEffect_MagicMissileImpact(_x, _y)
	local _mesh = makeBox(40, 40, 0, "assets/effects/mm_ef_casted.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/mm_ef_casted.png")
	local tmesh = _mesh
	local rndCheck = math.random(1,2)
	if rndCheck == 1 then
		tmesh = _mesh2
	end
	local temp = {
		id = #self._effectTable + 1,
		gfx = image:new3DImage(tmesh, 10, 10-1*20,  10, 2 ), 
		x = (_x),
		y = (_y),
		ix = math.random(-40, 40),
		iy = math.random(-40, 40),
		z = 100-1*20,
		life = 100,
		speed = 8,
		_effectType = 1,
	}

	table.insert(self._effectTable, temp)	


end

function item:createItemEffect_EmberSpell(_x, _y, _toPlayer)
	local _positionTable = { }

	if player:getOrientation() == 1 or player:getOrientation() == 3 then
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	else
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	end

	if _toPlayer == nil then
		_toPlayer = true
	end

	for i = 1, math.random(1, 3) do
		item:throw(self._emberOrb, player:getOrientation(), _x, _y, _toPlayer)
	end
end

function item:createItemEffect_Sleep(_x, _y, _toPlayer)
	local _positionTable = { }

	if player:getOrientation() == 1 or player:getOrientation() == 3 then
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	else
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	end

	if _toPlayer == nil then
		_toPlayer = true
	end

	for i = 1, 1 do
		item:throw(self._orbItem, player:getOrientation(), _x+_positionTable[i].x, _y+_positionTable[i].y, _toPlayer)
	end

end

function item:createItemEffect_SleepEffect(_x, _y, _toPlayer)
--createItemEffect_SleepEffect
	local px, py = player:returnPosition( )
	if (px == _x and py == _y) then -- yep, player
		--player:healPlayer( )
		player.isSleeping = true
		log:newMessage("<c:26EB5D>You fall asleep</c>")
	else -- check for enemies
		local bool, id = entity:isEntityAt(_x, _y)
		if bool == true then

			local v = entity:getList( )[id]
			if v ~= nil then
				if v.isBox == false then
					v.state = "sleep"
					image:setColor(v.prop, 0, 0, 0, 1)	
					log:newMessage("<c:26EB5D>"..v.name.."</c> fell asleep")
				end
			end
		end
	end	
end

function item:createItemEffect_Shoot_One(_x, _y, _toPlayer)
	local _positionTable = { }

	if player:getOrientation() == 1 or player:getOrientation() == 3 then
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	else
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	end

	if _toPlayer == nil then
		_toPlayer = true
	end

	sound:play(Game.gun)
	local backfireChance = 15
	local backfireRandom = math.random(1, 100)

	local entityIs, entityID, entityObject = entity:isEntityAt(_x, _y)
	if backfireRandom > backfireChance-math.floor(player:_getGunKnowledge( )) then
		--for i = 1, 2 do
			item:throw(self._bulletItem, player:getOrientation(), _x, _y, _toPlayer)
		--end
	else
		local damageRoll = math.random(math.random(9, 12), 20)
		if _toPlayer == true then
			
			local dmgResult = player:receiveDamage(damageRoll, false)
			log:newMessage("Your weapon backfired. You take: "..dmgResult.." points of damage")
		else
			log:newMessage("The weapon backfired. "..entityObject.name.." takes "..damageRoll.." points of damage")
			entity:_receiveDamage(entityID, damageRoll)
		end
	end
end

function item:createItemEffect_ShootDouble(_x, _y, _toPlayer)
	-- add some magic missile items to the player's inventory
	local _positionTable = { }

	if player:getOrientation() == 1 or player:getOrientation() == 3 then
		_positionTable[1] = {x = -1, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 1, y = 0}
	else
		_positionTable[1] = {x = 0, y = -1}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 1}
	end

	if _toPlayer == nil then
		_toPlayer = true
	end

	sound:play(Game.gun)
	local backfireChance = 11
	local backfireRandom = math.random(1, 100)

	local entityIs, entityID, entityObject = entity:isEntityAt(_x, _y)
	if backfireRandom > backfireChance-math.floor(player:_getGunKnowledge( )) then
		for i = 1, 3 do
			item:throw(self._bulletItem, player:getOrientation(), _x+_positionTable[i].x, _y+_positionTable[i].y, _toPlayer)
		end
		for i = 1, 3 do
			item:throw(self._bulletItem, player:getOrientation(), _x+_positionTable[i].x, _y+_positionTable[i].y, _toPlayer)
		end
	else
		local damageRoll = math.random(15, 22)
		if _toPlayer == true then
			
			local dmgResult = player:receiveDamage(damageRoll, false)
			log:newMessage("Your weapon backfired. You take: "..dmgResult.." points of damage")
		else
			log:newMessage("The weapon backfired. "..entityObject.name.." takes "..damageRoll.." points of damage")
			entity:_receiveDamage(entityID, damageRoll)
		end
	end
end

function item:createItemEffect_Shoot(_x, _y, _toPlayer)
	-- add some magic missile items to the player's inventory
	local _positionTable = { }

	if player:getOrientation() == 1 or player:getOrientation() == 3 then
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	else
		_positionTable[1] = {x = 0, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 0}
	end

	if _toPlayer == nil then
		_toPlayer = true
	end

	sound:play(Game.gun)
	local backfireChance = 15
	local backfireRandom = math.random(1, 100)

	local entityIs, entityID, entityObject = entity:isEntityAt(_x, _y)
	if backfireRandom > backfireChance-math.floor(player:_getGunKnowledge( )) then
		for i = 1, 3 do
			item:throw(self._bulletItem, player:getOrientation(), _x+_positionTable[i].x, _y+_positionTable[i].y, _toPlayer)
		end
	else
		local damageRoll = math.random(6, 13)
		if _toPlayer == true then
			
			local dmgResult = player:receiveDamage(damageRoll, false)
			log:newMessage("Your weapon backfired. You take: "..dmgResult.." points of damage")
		else
			log:newMessage("The weapon backfired. "..entityObject.name.." takes "..damageRoll.." points of damage")
			entity:_receiveDamage(entityID, damageRoll)
		end
	end

end


function item:createItemEffect_MagicMissile(_x, _y, _toPlayer)
	-- add some magic missile items to the player's inventory
	local _positionTable = { }

	if player:getOrientation() == 1 or player:getOrientation() == 3 then
		_positionTable[1] = {x = -1, y = 0}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 1, y = 0}
	else
		_positionTable[1] = {x = 0, y = -1}
		_positionTable[2] = {x = 0, y = 0}
		_positionTable[3] = {x = 0, y = 1}
	end

	if _toPlayer == nil then
		_toPlayer = true
	end

	for i = 1, 3 do
		item:throw(self._magicMissileItem, player:getOrientation(), _x+_positionTable[i].x, _y+_positionTable[i].y, _toPlayer)
	end

end

function item:createItemEffect_HEALSINGLE(_x, _y)
	local _mesh = makeBox(20, 20, 0, "assets/effects/health_anim.png")
	for i = 1, 24 do
				--if _x-dx ~= _x or _y-dy ~= _y then
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(_mesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-60, 60),
			iy = math.random(-60, 60),
			z = 100-i*20,
			life = 200,
			speed = 5,
			_effectType = 1,
		}

		table.insert(self._effectTable, temp)
		--end
	end
	local loopedOnce = false
	local px, py = player:returnPosition( )
	if (px == _x and py == _y) then -- yep, player

		if loopedOnce == false then
			local healingRoll = 0
			for i = 1, 2+math.floor(player:_getSpellKnowledge( ))	 do
				healingRoll = healingRoll + 1 + math.random(1, 6)
			end
			local totalHealing = healingRoll + math.floor(player:_getSpellKnowledge( ))		
			log:newMessage("<c:26EB5D>You recovered "..totalHealing.." HP </c>")
			player:heal(totalHealing)
			loopedOnce = true
			
		end
	
		--log:newMessage("<c:26EB5D>Your wounds are healed!</c>")
	else -- check for enemies
		
		local bool, id = entity:isEntityAt(_x, _y)
		if bool == true then -- yep, entity is there
			--print("BOOL IS TRUE")
			local v = entity:getList( )[id]
			if v ~= nil then
				v.hp = v.initial_health+v.healthModifier
				log:newMessage(""..v.name.." <c:26EB5D> has recovered his health</c>")
			end
		end
	end	


end

-- creates a HEALING effect with the center point
-- at the given coordinates.
-- the effect is made out of multiple textured meshes that
-- spawn in the center of the player mesh
-- and then move outwords and up in a radius
function item:createItemEffect_HEAL(_x, _y)
	--self._effectTable = { }
	local _mesh = makeBox(20, 20, 0, "assets/effects/health_anim.png")
	for i = 1, 12 do
		for dx = -1, 1 do
			for dy = -1, 1 do
				--if _x-dx ~= _x or _y-dy ~= _y then
					local temp = {
						id = #self._effectTable + 1,
						gfx = image:new3DImage(_mesh, 10, 10-i*20,  10, 2 ), 
						x = (_x-dx),
						y = (_y-dy),
						ix = math.random(-60, 60),
						iy = math.random(-60, 60),
						z = 100-i*20,
						life = 200,
						speed = 5,
						_effectType = 1,
					}

					table.insert(self._effectTable, temp)
				--end
			end
		end
	end
	entity_loopedOnce = false
	-- is player in that location?
	--print("*************************************************")
	--print("EFFECT TABLE SIZE: "..#self._effectTable.."")
	local px, py = player:returnPosition( )
	local loopedOnce = false
	for i, j in ipairs(self._effectTable) do
		--print("I IS: "..i.."")
		
		if (px == j.x and py == j.y) then -- yep, player
			--player:healPlayer( )
			--Healing: 2d6 + math.floor(spell knowledge)

			if loopedOnce == false then
				local healingRoll = 0
				for i = 1, 2+math.floor(player:_getSpellKnowledge( ))	 do
					healingRoll = healingRoll  + 1 + math.random(1, 6)
				end
			
				local totalHealing = healingRoll + math.floor(player:_getSpellKnowledge( ))			
				log:newMessage("<c:26EB5D>You recovered "..totalHealing.." HP </c>")
				loopedOnce = true
				player:heal(totalHealing)
			end
		
		else -- check for enemies
			
			local bool, id = entity:isEntityAt(j.x, j.y)
			if bool == true then -- yep, entity is there
				--print("BOOL IS TRUE")
				local v = entity:getList( )[id]
				if v ~= nil then
					v.hp = v.initial_health+v.healthModifier
					if entity_loopedOnce == false then
						log:newMessage(""..v.name.." <c:26EB5D> has recovered his health</c>")
						entity_loopedOnce = true
					end
				end
			end
		end
	end
	--print("*************************************************")
end

function item:createItemEffect_DamagePlayer(_x, _y, _ammount)
	local _mesh = makeBox(40, 40, 0, "assets/effects/effect_discharge_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/effect_discharge_2.png")

	local dmg = math.random(1, _ammount)
	log:newMessage("You took "..dmg.." damage from the discharge spell")
	--entity:_combatDebug(i, dmg)
	local px, py = player:returnPosition( )
	player:receiveDamage(dmg, true)
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if rndCheck == 1 then
			tmesh = _mesh2
		end
		_x = px
		_y = py
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 1,
		}

		table.insert(self._effectTable, temp)

	end

end

function item:createItemEffect_DamageAll(_x, _y, _ammount)
	local _mesh = makeBox(40, 40, 0, "assets/effects/effect_discharge_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/effect_discharge_2.png")
	local entTable = entity:getList( )
	for i,v in ipairs(entTable) do
		local dmg = math.random(1, _ammount) + math.floor(player:_getSpellKnowledge( ))
		entity:_combatDebug(i, dmg)
		for i = 1, 12 do
			local tmesh = _mesh
			local rndCheck = math.random(1,2)
			if rndCheck == 1 then
				tmesh = _mesh2
			end
			local temp = {
				id = #self._effectTable + 1,
				gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
				x = (v.x),
				y = (v.y),
				ix = math.random(-40, 40),
				iy = math.random(-40, 40),
				z = 100-i*20,
				life = 100,
				speed = 8,
				_effectType = 1,
			}

			table.insert(self._effectTable, temp)

		end
	end

	
	--for i,v in ipairs
end

function item:createItemEffect_REVEAL(_x, _y)
	local _mesh = makeBox(40, 40, 0, "assets/effects/reveal_darkness_fx1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/reveal_darkness_fx2.png")
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if rndCheck == 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 1,
		}

		table.insert(self._effectTable, temp)

	end
	--end

	rngMap:disableDarkness( )
end

function item:createItemEffect_TELEPORT(_x, _y)
	--self._effectTable = { }
	local _mesh = makeBox(40, 40, 0, "assets/effects/teleport_effect_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/teleport_effect_2.png")
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if rndCheck == 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 1,
		}

		table.insert(self._effectTable, temp)

	end

	-- is player in that location?
	local px, py = player:returnPosition( )
	if px == _x and py == _y then -- yep, player
		--player:receiveDamage(self._firePotionDamage) -- MAGIC NUMBER 15
		--log:newMessage("You took "..self._firePotionDamage.." damage form the fire brew ")
		local x, y = rngMap:returnEmptyLocations( )
		for i = 1, 12 do
			self._effectTable[i].x = x
			self._effectTable[i].y = y
		end
		player:setLoc(x, y)
		rngMap:updateLights2(x, y)
		entity:updateLightning2(x, y)
		item:updateLightning2(x, y)
		log:newMessage("You feel jumpy! You were randomly teleported somewhere....")
		--evTurn:updateLights( )
	else -- check for enemies
		local bool, id = entity:isEntityAt(_x, _y)
		if bool == true then -- yep, entity is there
			local v = entity:getList( )[id]
			--print("I2222D IS: "..id.."")
			if v ~= nil then
				--print("V NOT NIl")
				--entity:_doDamage(id, self._firePotionDamage)
				-- get random cell to teleport to
				local x, y = rngMap:returnEmptyLocations( )
				v.x = x
				v.y = y
				image:setLoc(v.prop, v.x*100, 100, v.y*100)
				log:newMessage(""..v.name.." blinked away")
			end
		else

		end
		--evTurn:updateLights( )
	end
	evTurn:updateLights( )
end

function item:createItemEffect_SpawnDarkness(_x, _y)

	local bool = rngMap:getDarknessAt(_x, _y)
	if bool == true then -- darkness present, REMOVE IT!
		for dx = -1, 1 do
			for dy = -1, 1 do
				rngMap:isDarknessAt(_x-dx, _y-dy, true)
			end
		end
		log:newMessage("Patches of Darkness are retreating")
	else -- not present, add it
		for dx = -1, 1 do
			for dy = -1, 1 do
				rngMap:addDarknessAt(_x-dx, _y-dy, true)
			end
		end
		log:newMessage("Patches of Darkness start to creep out")
	end



	
end

function item:createItemEffect_RemoveDarkness(_x, _y)
		for dx = -2, 2 do
			for dy = -2, 2 do
				rngMap:isDarknessAt(_x-dx, _y-dy, true)
			end
		end
		log:newMessage("The Artefact shines bright!")
end

-- summong effect 1 and 2
function item:createItemEffect_SUMMONEPIC(_x, _y)
	--self._effectTable = { }
	local _mesh = makeBox(40, 40, 0, "assets/effects/summong_fx_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/summong_fx_2.png")
	local portalCounter = 0
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if portalCounter ~= 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 2,
		}

		if portalCounter == 1 then
			temp.ix = 0
			temp.iy = 0
			temp.z = 100
			temp.life = 100
			temp.mainElement = true
		end
		portalCounter = portalCounter + 1
		table.insert(self._effectTable, temp)

	end



	local px, py = player:returnPosition( )
	local bool = false --, id = entity:isEntityAt(_x,_y)
	local spawnText = " creature"
	if bool == false then
		--if _x ~= px and _y ~= py then
		local itemTable = { }
		itemTable[1] = 23
		itemTable[2] = 22
		itemTable[3] = 21
		--print("LINE 1110 - ADD LIST OF POSSIBLE EPICS TO SUMMON! RANDOM THROUGH IT")
		--print("LINE 1110 - ADD LIST OF POSSIBLE EPICS TO SUMMON! RANDOM THROUGH IT")
		--print("LINE 1110 - ADD LIST OF POSSIBLE EPICS TO SUMMON! RANDOM THROUGH IT")
		item:new(_x, _y, self._epicItemList[math.random(1, #self._epicItemList)])

		log:newMessage("A summoning portal has appeared. A powerful item is being brough into this world!")

			
	else
		log:newMessage("A summoning portal has appeared, but nothing can pass through it")
	end

end

-- summong effect 1 and 2
function item:createItemEffect_SUMMON(_x, _y, _falseFlag)
	--self._effectTable = { }
	local _mesh = makeBox(40, 40, 0, "assets/effects/summong_fx_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/summong_fx_2.png")
	local portalCounter = 0
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if portalCounter ~= 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 2,
		}

		if portalCounter == 1 then
			temp.ix = 0
			temp.iy = 0
			temp.z = 100
			temp.life = 100
			temp.mainElement = true
		end
		portalCounter = portalCounter + 1
		table.insert(self._effectTable, temp)

	end


	if _falseFlag == nil then
		local px, py = player:returnPosition( )
		--local x, y = rngMap:returnEmptyLocations( )
		local bool, id = entity:isEntityAt(_x,_y)
		local spawnType = math.random(1, 4)
		local spawnText = " creature"
		if bool == false then
			--if _x ~= px and _y ~= py then
				if spawnType == 1 then -- summon an item
					spawnText = "n item"
					item:new(_x, _y)
				else
					entity:debugSpawner(_x, _y )
				end
				log:newMessage("A summoning portal has appeared. A"..spawnText.." is being brought into our world!")
			--else
			--	log:newMessage("A summoning portal has appeared, but nothing can pass through it")
			--end
				
		else
			log:newMessage("A summoning portal has appeared, but nothing can pass through it")
		end
	end

end

function item:createItemEffect_NOCTUSSUMMON(px, py)
	--print("TEST")
	local _x = px
	local _y = py
	local spawnChance = 2
	local spawnRoll = math.random(1, 100)
	local BATID = 11
	if spawnRoll <= spawnChance then
		for i = -1, 1 do
			for j = -1, 1 do
				local bool = entity:isEntityAt(_x+i,_y+j)
				if bool == false then
					self:createItemEffect_SUMMON(_x+i, _y+j, false)
					entity:newCreature(_x+i, _y+j, BATID, false)
				end
			end
		end
		log:newMessage("Bats are being brought into this world...")
	else
		local px, py = player:returnPosition( )
		--local x, y = rngMap:returnEmptyLocations( )
		local bool, id 
		local sumX, sumY
		local freeSpot = false
		for i = -1, 1 do
			for j = -1, 1 do
				bool, id = entity:isEntityAt(_x+i,_y+j)
				if bool == false then
					sumX = _x + i
					sumY = _y + j
					freeSpot = true
				end
			end
		end
		
		local spawnType = 2
		local spawnText = " creature"
		local spawnName = ""
		if freeSpot == true then
			self:createItemEffect_SUMMON(_x, _y, false)
			entity:newCreature(sumX,sumY, 9, false)
		else
			--log:newMessage("A summoning portal has appeared, but nothing can pass through it")
		end


	end
end

function item:createItemEffect_SUMMONGober(_x, _y)
	--self._effectTable = { }
	local _mesh = makeBox(40, 40, 0, "assets/effects/summong_fx_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/summong_fx_2.png")
	local portalCounter = 0
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if portalCounter ~= 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 2,
		}

		if portalCounter == 1 then
			temp.ix = 0
			temp.iy = 0
			temp.z = 100
			temp.life = 100
			temp.mainElement = true
		end
		portalCounter = portalCounter + 1
		table.insert(self._effectTable, temp)

	end

	entity:spawnGobber(_x, _y )
end


function item:createSummonEffectLimitless(_x, _y)
	--self._effectTable = { }
	local _mesh = makeBox(40, 40, 0, "assets/effects/summong_fx_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/summong_fx_2.png")
	local portalCounter = 0
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if portalCounter ~= 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100*100*100*100*100,
			speed = 8,
			_effectType = 2,
		}

		if portalCounter == 1 then
			temp.ix = 0
			temp.iy = 0
			temp.z = 100
			temp.life = 100
			temp.mainElement = true
		end
		portalCounter = portalCounter + 1
		table.insert(self._effectTable, temp)

	end


end

function item:createItemEffect_SUMMONNMulti(_x, _y)
	--for i = -2, 2 do
	--	self:createItemEffect_SUMMON(_x+i, _y)
	--	entity:debugSpawner(_x+i, _y)
	--end
	--print("TEST")
	for i = -2, 2 do
		for j = -2, 2 do
			self:createItemEffect_SUMMON(_x+j, _y+i, false)
			entity:summonSpawner(_x+j, _y+i)
		end
		--entity:debugSpawner(_x, _y+i)
	end
	--log:newMessage("Sebastian threw a party! Time to jam!")
end

-- summong effect 1 and 2
function item:createItemEffect_SUMMONNearby(_x, _y)
	--self._effectTable = { }
	local _mesh = makeBox(40, 40, 0, "assets/effects/summong_fx_1.png")
	local _mesh2 = makeBox(50, 50, 0, "assets/effects/summong_fx_2.png")
	local portalCounter = 0
	for i = 1, 12 do
		local tmesh = _mesh
		local rndCheck = math.random(1,2)
		if portalCounter ~= 1 then
			tmesh = _mesh2
		end
		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(tmesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-40, 40),
			iy = math.random(-40, 40),
			z = 100-i*20,
			life = 100,
			speed = 8,
			_effectType = 2,
		}

		if portalCounter == 1 then
			temp.ix = 0
			temp.iy = 0
			temp.z = 100
			temp.life = 100
			temp.mainElement = true
		end
		portalCounter = portalCounter + 1
		table.insert(self._effectTable, temp)

	end



	local px, py = player:returnPosition( )
	--local x, y = rngMap:returnEmptyLocations( )
	local bool, id 
	local sumX, sumY
	local freeSpot = false
	for i = -1, 1 do
		for j = -1, 1 do
			bool, id = entity:isEntityAt(_x+i,_y+j)
			if bool == false then
				if rngMap:isWallAt(_x+i, _y+1) == false then
					sumX = _x + i
					sumY = _y + j
					freeSpot = true
				end
			end
		end
	end
	
	local spawnType = 2
	local spawnText = " creature"
	local spawnName = ""
	if freeSpot == true then
		--if _x ~= px and _y ~= py then
			if spawnType == 1 then -- summon an item
				spawnText = "n item"
				item:new(sumX, sumY)
			else
				spawnName = entity:summonSpawner(sumX, sumY )
			end
			log:newMessage("A summoning portal has appeared. "..spawnName.." appeared!")
		--else
		--	log:newMessage("A summoning portal has appeared, but nothing can pass through it")
		--end
			
	else
		log:newMessage("A summoning portal has appeared, but nothing can pass through it")
	end

end

function item:createItemEffect_FIRE(_x, _y, _ammount)
	--self._effectTable = { }
	local _mesh = makeBox(20, 20, 0, "assets/effects/fire_ball.png")
	for i = 1, 12 do

		local temp = {
			id = #self._effectTable + 1,
			gfx = image:new3DImage(_mesh, 10, 10-i*20,  10, 2 ), 
			x = (_x),
			y = (_y),
			ix = math.random(-30, 30),
			iy = math.random(-30, 30),
			z = 100-i*20,
			life = 200,
			speed = 5,
			_effectType = 1,
		}

		table.insert(self._effectTable, temp)

	end
	-- is player in that location?
	local px, py = player:returnPosition( )
	if px == _x and py == _y then -- yep, player
		player:receiveDamage(_ammount, true) -- MAGIC NUMBER 15
		log:newMessage("You took "..self._firePotionDamage.." damage from the fire brew ")
	else -- check for enemies
		local bool, id = entity:isEntityAt(_x, _y)
		if bool == true then -- yep, entity is there
			local v = entity:getList( )[id]
			--print("I2222D IS: "..id.."")
			if v ~= nil then
				--print("V NOT NIl")
				entity:_doDamage(id, _ammount)
				log:newMessage("The Fire Brew exploded dealing ".._ammount.." damage to "..v.name.." Life left: "..v.hp.."")
			end
		else

		end
	end
end
-----------------------------------------------------------
----------------- END OF EFFECTS --------------------------
-----------------------------------------------------------

function item:updateEffects( )
	local heightCount = 0
	local rotCounter = 1
	for i,v in ipairs(self._effectTable) do
		if v._effectType == 1 then -- particles-like
			heightCount = heightCount + 10
			local rx, ry, rz = camera:getRot( )
			image:setRot3D(v.gfx, 0, ry, 0)
			v.z = v.z + v.speed
			image:setLoc(v.gfx, v.x*100+v.ix, v.z, v.y*100+v.iy)
		elseif v._effectType == 2 then -- with main element around which particles spin
			local rx, ry, rz = camera:getRot( )
			if v.mainElement == true then
				local irx, iry, irz = image:getRot3D(v.gfx)
				image:setRot3D(v.gfx, rx+math.random(1, 5), ry, 0)
				--image:moveRot(v.gfx, 0, 0, rotCounter)

				image:setLoc(v.gfx, v.x*100+v.ix, v.z, v.y*100+v.iy)
				rotCounter = rotCounter + 1
			else
				v.z = v.z + v.speed
				image:setLoc(v.gfx, v.x*100+v.ix, v.z, v.y*100+v.iy)
				image:setRot3D(v.gfx, 0, ry, 0)
			end
		end
		v.life = v.life - 1
	end

	for i,v in ipairs(self._effectTable) do
		if v.life <= 0 then
			self:dropEffect(i)
		end
	end


end

function item:dropEffect(_i)
	local _item = self._effectTable[_i]
	image:removeProp(_item.gfx, 2)
	_item.gfx = nil
	if _forceDelete ~= true then
		table.remove(self._effectTable, _i)
	end

end

function item:createItemEffect_GobberDialogue(_optionalLine)
	local px, py = player:returnPosition( )
	log:newMessage(self._dialogueLines[math.random(1, #self._dialogueLines)])
end