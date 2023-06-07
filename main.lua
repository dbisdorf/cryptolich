local utf8 = require("utf8")

-- constants

TILE_SIZE = 16
MAP_SIZE = 32
TILE_CENTER = 8
SCREEN_CENTER = {x = 200, y = 150}
SCREEN_MAX = {x = 400, y = 300}
COLOR_FADE = {0.5, 0.5, 0.5, 1.0}
COLOR_WHITE = {1.0, 1.0, 1.0, 1.0}
COLOR_BLACK = {0.0, 0.0, 0.0, 1.0}
COLOR_FLASH = {1.0, 0.0, 0.0, 1.0}
COLOR_GRAY = {0.6, 0.6, 0.6}
COLOR_RED = {1.0, 0.1, 0.1}
VERSION_TEXT = {{0.4, 0.4, 0.4}, "VERSION 0.8.0"}
TITLE_MENU_TEXT = {"PLAY", "INSTRUCTIONS", "OPTIONS", "CREDITS", "QUIT"}
GAME_OVER_TEXT = {{1.0, 0.2, 0.2}, "GAME OVER"}
UNLOCKED_TEXT = {{0.5, 1.0, 0.5}, "SECURITY UNLOCKED"}
PREPARE_TEXT = {{0.5, 1.0, 0.5}, "PREPARE FOR"}
LEVEL_TEXT = {{0.5, 1.0, 0.5}, "NEXT LEVEL"}
BACK_TEXT = {{0.5, 1.0, 0.5}, "PRESS ESC TO GO BACK"}
PAD_BACK_TEXT = {{0.5, 1.0, 0.5}, "PRESS [BACK] TO GO BACK"}
LORE_TEXT = {{1.0, 1.0, 1.0}, "THE CRYPTOLICH HAS SEIZED CONTROL OF THE WORLD'S TECHNOLOGY.\n\nYOU ARE DELTA, THE ONLY HACKER WITH ENOUGH SKILL TO INFILTRATE THE CRYPTOLICH'S MEGATOWER, CONFRONT ITS CYBERDIGITAL GUARDIANS, AND SAVE HUMANITY.\n\nGOOD LUCK DELTA!"}
INSTRUCTIONS_TEXT = {{0.7, 0.7, 1.0}, "ARROW KEYS TO MOVE\nZ TO SHOOT\nX TO HOLD AIM DIRECTION"}
PAD_INSTRUCTIONS_TEXT = {{0.7, 0.7, 1.0}, "JOYSTICK TO MOVE\n[A] TO SHOOT\n[X] TO HOLD AIM DIRECTION"}
LEFT_CREDITS_TEXT = {{1.0, 1.0, 1.0}, "PROGRAMMING AND ART\n\n\nENGINE\n\n\nGRAPHICS\n\n\nSOUND EFFECTS\n\n\nFONT"}
RIGHT_CREDITS_TEXT = {{0.7, 0.7, 1.0}, "DON BISDORF\ndonbisdorf.com\n\nLOVE2D\nlove2d.org\n\nKRITA\nkrita.org\n\nCHIPTONE\nsfbgames.itch.io/chiptone\n\nMx437_IBM_BIOS.ttf\nint10h.org/oldschool-pc-fonts"}
VICTORY_TEXT = {{0.5, 0.5, 1.0}, "AS THE MEGATOWER COLLAPSES, YOU LEARN THAT THE CRYPTOLICH HAS BACKED UP HIS CONSCIOUSNESS ELSEWHERE.\n\nIN A DISTANT CITY, ANOTHER MEGATOWER RISES.\n\nDELTA, YOUR WORK IS NOT YET DONE..."}
OPTIONS_TEXT = {{0.5, 0.5, 1.0}, "OPTIONS"}
LIVES_TEXT = {{1.0, 1.0, 1.0}, "LIVES"}
AUDIO_TEXT = {{1.0, 1.0, 1.0}, "AUDIO"}
OPTIONS_CONTROLS_TEXT = {{0.5, 0.5, 1.0}, "UP/DOWN TO CHOOSE OPTION\nLEFT/RIGHT TO CHANGE"}
PAUSE_TEXT = {{0.7, 0.7, 1.0}, "PAUSED\n\nPRESS ENTER TO RESUME\nPRESS ESC TO QUIT"}
PAUSE_PAD_TEXT = {{0.7, 0.7, 1.0}, "PAUSED\n\nPRESS [START] TO RESUME\nPRESS [BACK] TO QUIT"}
RIGHT_INDEX = 1
DOWN_INDEX = 2
LEFT_INDEX = 3
UP_INDEX = 4
VECTORS = {{x = 1.0, y = 0.0}, {x = 0.0, y = 1.0}, {x = -1.0, y = 0.0}, {x = 0.0, y = -1.0}}
BESTIARY = {
	["player"] = {speed = 64.0, spf = 0.25, points = 0, cooldown = 0.5, collision = "player", hits = 0},
	["spider"] = {speed = 16.0, spf = 0.2, points = 10, cooldown = 0.0, collision = "enemy", hits = 1, level1 = 4, eachLevel = 2},
	["wasp"] = {speed = 8.0, spf = 0.05, points = 25, cooldown = 3.0, steps = 5, collision = "enemy", hits = 1, level1 = 2, eachLevel = 2},
	["turret"] = {speed = 0.0, spf = 0.25, points = 0, cooldown = 10.0, collision = "invulnerable", hits = 0, level1 = 2, eachLevel = 2},
	["skull"] = {speed = 16.0, spf = 0.25, points = 0, cooldown = 0.0, collision = "omnipotent", hits = 0},
	["tank"] = {speed = 64.0, spf = 0.15, points = 100, cooldown = 3.0, steps = 10, collision = "enemy", hits = 10, level1 = 2, eachLevel = 0.5},
	["launcher"] = {speed = 24.0, spf = 0.25, points = 75, cooldown = 10.0, steps = 5, collision = "enemy", hits = 3, level1 = 2, eachLevel = 1},
	["rocket"] = {speed = 96.0, spf = 0.1, points = 0, cooldown = 0.0, collision = "enemy", hits = 1},
	["slider"] = {speed = 32.0, spf = 0.0, points = 0, cooldown = 1.5, steps = 21, collision = "invulnerable", hits = 0},
	["trailer"] = {speed = 48.0, spf = 0.2, points = 50, cooldown = 0.0, steps = 5, collision = "enemy", hits = 5, level1 = 2, eachLevel = 0.5},
	["flame"] = {speed = 0.0, spf = 0.1, points = 0, cooldown = 5.0, collision = "insubstantial", hits = 0},
	["shield"] = {spf = 0.25, points = 0, cooldown = 0.0, collision = "invulnerable", hits = 1, passive = true},
	["battery"] = {spf = 0.5, points = 50, cooldown = 0.0, collision = "enemy", hits = 3, passive = true},
	["boss"] = {spf = 0.0, speed = 32.0, cooldown = 3.0, steps = 3, hits = 0, collision = "invulnerable"}
}
ARMORY = {
	["playerM"] = {speed = 256.0, collision = "playerMissile"},
	["waspM"] = {speed = 80.0, collision = "enemy"},
	["turretM"] = {speed = 80.0, collision = "enemy"},
	["sliderM"] = {speed = 112.0, collision = "enemy"},
	["bossM"] = {speed = 64.0, collision = "enemy"}
}
TERRAIN = {
	{solid = false, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = false, safe = true, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = false, safe = false, nogo = true},
	{solid = false, safe = false, nogo = true},
	{solid = false, safe = false, nogo = true},
	{solid = false, safe = false, nogo = true},
	{solid = true, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false},
	{solid = true, safe = false, nogo = false}
}
OBSTACLES = {3, 3, 3, 3, 3, 3, 3, 14, 14, 15}
DEFAULT_LIVES = 3
DEFAULT_VOLUME = 10
LOCK_POINTS = 100
LEVEL_POINTS = 1000
VICTORY_POINTS = 2500
START_POSITION = {x = 16, y = 16}
BLAST_TIME = 0.5
BLAST_SIZE = 200.0
STALL_TIME = 2.0
TICK_TIME = 0.1
FLASH_TIME = 0.2
VICTORY_FULL_TIME = 6.0
VICTORY_BOOM_TIME = 3.0
DEFAULT_HIGH_SCORE = 10000
BONUS_LIFE_SCORE = 10000
LAST_LEVEL = 10
SHIELD_LOCKS = 20
MAX_BEAT_TIME = 2.5
BEAT_PER_LEVEL = 0.1
INFINITE_LIVES = 11
INFINITE_SYMBOL = utf8.char(8734)
LIFE_SYMBOL = utf8.char(3)
DEADLINE = 60.0

-- globals

font = nil
textures = nil
sounds = {}
spriteQuads = {}
tileQuads = {}
mapCanvas = nil
mapInfo = {}
spriteBatch = nil
combatants = {}
missiles = {}
blasts = {}
killed = false
lives = 0
score = 0
highScore = DEFAULT_HIGH_SCORE
gameOver = false
locks = 0
unlocked = 0
title = true
instructions = false
credits = false
options = false
oldButtons = false
level = 0
stalling = 0.0
advancing = false
startX = 0
startY = 0
gamepad = nil
boss = nil
beat = 0.0
titleScreen = nil
volume = DEFAULT_VOLUME
startingLives = DEFAULT_LIVES
menuLevel = 1
quitting = false
paused = false
lifetime = 0.0
offsetX = 0
offsetY = 0

-- LOVE callbacks

function love.load()
	-- this is where we initialize
	
	math.randomseed(os.time())

	love.graphics.setDefaultFilter("nearest", "nearest")

	font = love.graphics.newFont("Mx437_IBM_BIOS.ttf", 8, "mono")
	font:setLineHeight(2.0)
	love.graphics.setFont(font)

	titleScreen = love.graphics.newImage("title.png")
	textures = love.graphics.newImage("textures.png")

	loadWalkingSprites("player", 0)
	loadWalkingSprites("spider", 16)
	loadWalkingSprites("wasp", 32)
	loadWalkingSprites("turret", 48)
	loadWalkingSprites("skull", 64)
	loadWalkingSprites("tank", 80)
	loadWalkingSprites("launcher", 96)
	loadWalkingSprites("rocket", 112)
	loadWalkingSprites("trailer", 128)
	loadWalkingSprites("slider", 144)
	loadWalkingSprites("flame", 160)
	loadWalkingSprites("shield", 176)
	loadWalkingSprites("battery", 192)

	spriteQuads["boss"] = love.graphics.newQuad(208, 160, 48, 48, textures)

	loadMissileSprites("playerM", 0, 208)
	loadMissileSprites("waspM", 64, 208)
	loadMissileSprites("turretM", 128, 208)
	loadMissileSprites("sliderM", 192, 208)
	loadMissileSprites("bossM", 192, 224)

	spriteQuads["life"] = love.graphics.newQuad(0, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastH"] = love.graphics.newQuad(16, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastV"] = love.graphics.newQuad(32, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastHS"] = love.graphics.newQuad(64, 224, TILE_SIZE, TILE_SIZE, textures)
	spriteQuads["blastVS"] = love.graphics.newQuad(80, 224, TILE_SIZE, TILE_SIZE, textures)

	for t = 1, 15 do
		tileQuads[t] = love.graphics.newQuad((t - 1) * TILE_SIZE, 240, TILE_SIZE, TILE_SIZE, textures)
	end

	mapCanvas = love.graphics.newCanvas(MAP_SIZE * TILE_SIZE, MAP_SIZE * TILE_SIZE)
	spriteBatch = love.graphics.newSpriteBatch(textures, 100)

	sounds["player"] = love.audio.newSource("player.wav", "static")
	sounds["boom"] = love.audio.newSource("boom.wav", "static")
	sounds["unlock"] = love.audio.newSource("unlock.wav", "static")
	sounds["level"] = love.audio.newSource("level.wav", "static")
	sounds["heartbeat"] = love.audio.newSource("heartbeat.wav", "static")
	sounds["begin"] = love.audio.newSource("begin.wav", "static")
	sounds["startup"] = love.audio.newSource("startup.wav", "static")
	sounds["begin"] = love.audio.newSource("begin.wav", "static")
	sounds["beep"] = love.audio.newSource("beep.wav", "static")
	sounds["wasp"] = love.audio.newSource("wasp.wav", "static")
	sounds["launcher"] = love.audio.newSource("launcher.wav", "static")
	sounds["turret"] = love.audio.newSource("turret.wav", "static")
	sounds["slider"] = love.audio.newSource("slider.wav", "static")
	sounds["boss"] = love.audio.newSource("boss.wav", "static")
	sounds["tank"] = love.audio.newSource("tank.wav", "static")
	sounds["trailer"] = love.audio.newSource("trailer.wav", "static")

	readSaveFile()

	gamepad = getGamepad()

	startTitle()
end

function love.update(delta)
	local elapsed = delta
	while elapsed > TICK_TIME do
		tick(TICK_TIME)
		elapsed = elapsed - TICK_TIME
	end
	if elapsed > 0.0 then
		tick(elapsed)
	end
end

function love.draw()
	if quitting then
		return
	end

	-- this is where we draw
	
	love.graphics.scale(2.0, 2.0)

	if title then
		drawTitle()
	elseif instructions then
		drawInstructions()
	elseif credits then
		drawCredits()
	elseif options then
		drawOptions()
	else
		if gameOver or advancing or paused then
			if advancing and level == LAST_LEVEL then
				if stalling < VICTORY_BOOM_TIME then
					local dim = stalling / VICTORY_BOOM_TIME
					love.graphics.setColor(dim, dim, dim, 1.0)
				end
			else
				love.graphics.setColor(COLOR_FADE)
			end
		end

		love.graphics.draw(mapCanvas, SCREEN_CENTER.x - combatants[1].x, SCREEN_CENTER.y - combatants[1].y)
		love.graphics.draw(spriteBatch)

		if gameOver then
			love.graphics.setColor(COLOR_WHITE)
			love.graphics.printf(GAME_OVER_TEXT, 0, 150, 200, "center", 0, 2.0, 2.0)
		elseif paused then
			love.graphics.setColor(COLOR_WHITE)
			if gamepad then
				love.graphics.printf(PAUSE_PAD_TEXT, 0, 90, 200, "center", 0, 2.0, 2.0)
			else
				love.graphics.printf(PAUSE_TEXT, 0, 90, 200, "center", 0, 2.0, 2.0)
			end
		elseif advancing then
			love.graphics.setColor(COLOR_WHITE)
			if level == LAST_LEVEL then
				if stalling < VICTORY_BOOM_TIME then
					love.graphics.printf(VICTORY_TEXT, 0, 70, 400, "center")
				end
			else
				love.graphics.printf(UNLOCKED_TEXT, 0, 70, 200, "center", 0, 2.0, 2.0)
				love.graphics.printf(PREPARE_TEXT, 0, 140, 200, "center", 0, 2.0, 2.0)
				love.graphics.printf(LEVEL_TEXT, 0, 210, 200, "center", 0, 2.0, 2.0)
			end
		end

		love.graphics.print(string.format("%06d", score), 0, 4)
		love.graphics.print(string.format("LEVEL %02d", level), 100, 4)
		love.graphics.print(string.format("HIGH %06d", highScore), 220, 4)
		local lifeString
		if lives <= 5 then
			lifeString = string.rep(LIFE_SYMBOL, lives)
		elseif lives == INFINITE_LIVES then
			lifeString = INFINITE_SYMBOL .. " " .. LIFE_SYMBOL
		elseif lives > 5 then
			lifeString = tostring(lives) .. " " .. LIFE_SYMBOL
		end
		love.graphics.printf({COLOR_RED, lifeString}, 360, 4, 40, "right")
	end

	love.graphics.origin()
end

-- other game functions

function tick(delta)
	-- process the maximum allowable game time
	
	if title then
		updateTitle()
		return
	elseif instructions or credits then
		if oldButtons then
			checkOldButtons()
		else
			if backButton() then
				instructions = false
				credits = false
				title = true
				menuBeep()
				checkOldButtons()
			end
		end
		return
	elseif options then
		updateOptions()
		return
	end

	local player = combatants[1]

	if gameOver then
		-- wait until start
		if startButton() or backButton() then
			startTitle()
			return
		end
	elseif paused then
		if oldButtons then
			checkOldButtons()
		else
			if startButton() then
				checkOldButtons()
				paused = false
			end
			if backButton() then
				startTitle()
				return
			end
		end
		return
	elseif stalling > 0.0 then
		-- don't do much if we're stalling
		stalling = stalling - delta
		if advancing and level == LAST_LEVEL then
			-- extra effects for stalling during last level
			if stalling > VICTORY_BOOM_TIME then
				demise(delta)
			else
				if boss then
					sounds["boom"]:play()
					for b = 1, 10 do
						makeBlast(
							boss.x + (TILE_SIZE * 3.0 * math.random()),
							boss.y + (TILE_SIZE * 3.0 * math.random()),
							true)
					end
					boss.destroyed = true
					boss = nil
				end
				if stalling <= 0.0 then
					stalling = 0.01
				end
			end
			if startButton() then
				level = 1
				startLevel()
			end
		else
			-- normally just a brief wait to reset the level
			if stalling <= 0.0 then
				if killed then
					resetPlayer()
					killed = false
				else
					level = level + 1
					startLevel()
				end
			end
		end
	else
		-- heartbeat and life timer
		beat = beat - delta
		if beat <= 0.0 then
			sounds["heartbeat"]:play()
			resetHeartbeat()
		end
		lifetime = lifetime + delta
		if lifetime >= DEADLINE then
			makeSkull()
			lifetime = lifetime - DEADLINE
		end

		-- do player and enemy stuff
		if killed then
			makeBlast(player.x, player.y, true)
			sounds["boom"]:play()
			if lives < INFINITE_LIVES then
				lives = lives - 1
			end
			if lives == 0 then
				gameOver = true
				if score > highScore then
					highScore = score
					writeSaveFile()
				end
			else
				stalling = STALL_TIME
			end
		elseif unlocked == locks then
			if level == LAST_LEVEL then
				awardPoints(VICTORY_POINTS)
				stalling = VICTORY_FULL_TIME
			else
				awardPoints(LEVEL_POINTS)
				sounds["level"]:play()
				stalling = STALL_TIME
			end
			advancing = true
		end

		-- player commands
		-- this could be simpler too
		local turn = nil
		local go = false
		player.waiting = true
		player.dx = 0.0
		player.dy = 0.0
		if rightButton() then
			turn = RIGHT_INDEX
			player.waiting = false
			player.dx = 1.0
		elseif leftButton() then
			turn = LEFT_INDEX
			player.waiting = false
			player.dx = -1.0
		elseif upButton() then
			turn = UP_INDEX
			player.waiting = false
			player.dy = -1.0
		elseif downButton() then
			turn = DOWN_INDEX
			player.waiting = false
			player.dy = 1.0
		end
		if turn and not aimButton() then
			player.facing = turn
		end
		if backButton() then
			checkOldButtons()
			paused = true
		end

		-- abilities and cooldowns
		if player.cooling > 0.0 then
			player.cooling = player.cooling - delta
			if player.cooling < 0.0 then
				player.cooling = 0.0
			end
		elseif oldButtons then
			checkOldButtons()
		else
			if shootButton() then
				-- unlocked = locks
				player.cooling = BESTIARY["player"].cooldown
				makeMissile(
					player.x + (VECTORS[player.facing].x * TILE_CENTER), 
					player.y + (VECTORS[player.facing].y * TILE_CENTER), 
					player.facing,
					"player")
			end
		end

		-- enemy action
		for i, c in ipairs(combatants) do
			if i > 1 then
				runEnemyLogic(c, delta)
			end
		end

		-- move the combatants around
		for i, c in ipairs(combatants) do
			moveCombatant(c, delta)
		end
	end

	-- move the missiles around
	for i, m in ipairs(missiles) do
		moveMissile(m, delta)
	end

	-- move the blasts around
	for i, b in ipairs(blasts) do
		moveBlast(b, delta)
	end

	removeDestroyed(missiles)
	removeDestroyed(combatants)
	removeDestroyed(blasts)

	spriteBatch:clear()

	-- player xy offset should be calculated only once
	local offsetX = player.x - SCREEN_CENTER.x
	local offsetY = player.y - SCREEN_CENTER.y
	for i, c in ipairs(combatants) do
		if c.name == "flame" then
			spriteBatch:add(spriteQuads[c.name][c.facing][c.frame], c.x - offsetX, c.y - offsetY)
		end
	end
	for i, c in ipairs(combatants) do
		if c.name == "boss" then
			spriteBatch:add(spriteQuads["boss"], c.x - offsetX, c.y - offsetY)
		elseif c.name ~= "flame" and (i > 1 or not killed) then
			if c.flashing > 0.0 then
				spriteBatch:setColor(COLOR_FLASH[1], COLOR_FLASH[2], COLOR_FLASH[3], COLOR_FLASH[4])
			end
			spriteBatch:add(spriteQuads[c.name][c.facing][c.frame], c.x - offsetX, c.y - offsetY)
			if c.flashing > 0.0 then
				spriteBatch:setColor(COLOR_WHITE)
			end
		end
	end
	for i, m in ipairs(missiles) do
		spriteBatch:add(spriteQuads[m.name][m.facing], m.x - offsetX, m.y - offsetY)
	end
	local blastDistance
	local blastName
	for i, b in ipairs(blasts) do
		if b.big then
			blastName = "blastH"
		else
			blastName = "blastHS"
		end
		blastDistance = (b.time / BLAST_TIME) * b.size
		for v = 1, 4 do
			spriteBatch:add(
				spriteQuads[blastName], 
				b.x + (VECTORS[v].x * blastDistance) - offsetX, 
				b.y + (VECTORS[v].y * blastDistance) - offsetY)
			if blastName == "blastH" then
				blastName = "blastV"
			elseif blastName == "blastV" then
				blastName = "blastH"
			elseif blastName == "blastHS" then
				blastName = "blastVS"
			else
				blastName = "blastHS"
			end
		end
	end

	-- for l = 1, lives do
	--	if l == 1 or lives < 6 then
	--		spriteBatch:add(spriteQuads["life"], SCREEN_MAX.x - (l * TILE_SIZE), 0)
	--	end
	-- end
end

function drawTitle()
	love.graphics.draw(titleScreen, 0, 0)
	for o = 1, 5 do
		if o == menuLevel then
			love.graphics.rectangle("fill", 241, 138 + (o * 15), 130, 12)
			love.graphics.printf({COLOR_BLACK, TITLE_MENU_TEXT[o]}, 215, 140 + (o * 15), 185, "center")
		else
			love.graphics.printf({COLOR_GRAY, TITLE_MENU_TEXT[o]}, 215, 140 + (o * 15), 185, "center")
		end
	end
	love.graphics.printf(VERSION_TEXT, 215, 280, 185, "center")
end

function drawInstructions()
	love.graphics.printf(LORE_TEXT, 20, 50, 360, "center")
	if gamepad then
		love.graphics.printf(PAD_INSTRUCTIONS_TEXT, 20, 210, 360, "center")
		love.graphics.printf(PAD_BACK_TEXT, 0, 280, 400, "center")
	else
		love.graphics.printf(INSTRUCTIONS_TEXT, 20, 210, 360, "center")
		love.graphics.printf(BACK_TEXT, 0, 280, 400, "center")
	end
end

function drawCredits()
	love.graphics.printf(LEFT_CREDITS_TEXT, 20, 30, 360, "left")
	love.graphics.printf(RIGHT_CREDITS_TEXT, 20, 30, 360, "right")
	if gamepad then
		love.graphics.printf(PAD_BACK_TEXT, 0, 280, 400, "center")
	else
		love.graphics.printf(BACK_TEXT, 0, 280, 400, "center")
	end
end

function drawOptions()
	love.graphics.printf(OPTIONS_TEXT, 20, 20, 360, "center")
	love.graphics.printf(LIVES_TEXT, 20, 50, 360, "center")
	love.graphics.printf(AUDIO_TEXT, 20, 120, 360, "center")
	local rect
	local livesText
	for o = 1, 11 do
		rect = optionsRect(1, o)
		if o == 11 then
			livesText = INFINITE_SYMBOL
		else
			livesText = tostring(o)
		end
		if startingLives == o and menuLevel == 1 then
			love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
			love.graphics.printf({COLOR_BLACK, livesText}, rect.x, rect.y + 2, rect.w, "center")
		else
			if startingLives == o then
				love.graphics.setColor(COLOR_GRAY)
				love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
				love.graphics.setColor(COLOR_WHITE)
			end
			love.graphics.printf({COLOR_GRAY, livesText}, rect.x, rect.y + 2, rect.w, "center")
		end
		rect = optionsRect(2, o)
		if (volume + 1) == o and menuLevel == 2 then
			love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
			love.graphics.printf({COLOR_BLACK, tostring(o - 1)}, rect.x, rect.y + 2, rect.w, "center")
		else
			if (volume + 1) == o then
				love.graphics.setColor(COLOR_GRAY)
				love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
				love.graphics.setColor(COLOR_WHITE)
			end
			love.graphics.printf({COLOR_GRAY, tostring(o - 1)}, rect.x, rect.y + 2, rect.w, "center")
		end
	end
	love.graphics.printf(OPTIONS_CONTROLS_TEXT, 20, 200, 360, "center")
	if gamepad then
		love.graphics.printf(PAD_BACK_TEXT, 0, 280, 400, "center")
	else
		love.graphics.printf(BACK_TEXT, 0, 280, 400, "center")
	end
end

function optionsRect(level, option)
	local rect = {x = option * 35 - 23, y = 68, w = 28, h = 11}
	if level == 2 then
		rect.y = 138
	end
	return rect
end

function menuBeep()
	sounds["beep"]:stop()
	sounds["beep"]:play()
end

function updateTitle()
	if oldButtons then
		checkOldButtons()
		return
	end
	local beep = false
	if shootButton() or startButton() then
		title = false
		if menuLevel == 1 then
			startGame()
		elseif menuLevel == 2 then
			instructions = true
			beep = true
		elseif menuLevel == 3 then
			menuLevel = 1
			options = true
			beep = true
		elseif menuLevel == 4 then
			credits = true
			beep = true
		else
			quitting = true
			love.event.quit(0)
		end
	elseif upButton() and menuLevel > 1 then
		menuLevel = menuLevel - 1
		beep = true
	elseif downButton() and menuLevel < 5 then
		menuLevel = menuLevel + 1
		beep = true
	elseif backButton() then
		quitting = true
		love.event.quit(0)
	end
	if beep then
		menuBeep()
	end
	checkOldButtons()
end

function updateOptions()
	if oldButtons then
		checkOldButtons()
		return
	end

	local changed = false
	if menuLevel == 1 then
		if upButton() or downButton() then
			menuLevel = 2
			changed = true
		end
		if leftButton() and startingLives > 1 then
			startingLives = startingLives - 1
			changed = true
		elseif rightButton() and startingLives < 11 then
			startingLives = startingLives + 1
			changed = true
		end
	else
		if upButton() or downButton() then
			menuLevel = 1
			changed = true
		end
		if leftButton() and volume > 0 then
			volume = volume - 1
			love.audio.setVolume(volume / 10.0)
			changed = true
		elseif rightButton() and volume < 10 then
			volume = volume + 1
			love.audio.setVolume(volume / 10.0)
			changed = true
		end
	end
	if changed then
		menuBeep()
	end
	if backButton() then
		options = false
		title = true
		writeSaveFile()
		menuBeep()
	end
	checkOldButtons()
end

function loadWalkingSprites(name, y)
	spriteQuads[name] = {}
	for v = 1, 4 do
		spriteQuads[name][v] = {}
		for w = 1, 4 do
			spriteQuads[name][v][w] = love.graphics.newQuad(
				((v - 1) * TILE_SIZE * 4) + ((w - 1) * TILE_SIZE), y, 
				TILE_SIZE, TILE_SIZE, textures)
		end
	end
end

function loadMissileSprites(name, x, y)
	spriteQuads[name] = {}
	for v = 1, 4 do
		spriteQuads[name][v] = love.graphics.newQuad(x + ((v - 1) * TILE_SIZE), y, TILE_SIZE, TILE_SIZE, textures)
	end
end

function randomObstacle()
	return OBSTACLES[math.random(10)]
end

function buildOfficeMap()
	mapInfo = {}

	-- cube farm
	local corner = math.random(1, 4)
	local x1 = math.random(13, 19)
	local x2 = math.random(13, 19)
	local y1 = math.random(13, 19)
	local y2 = math.random(13, 19)
	for x = 0, MAP_SIZE - 1 do
		mapInfo[x] = {}
		for y = 0, MAP_SIZE - 1 do
			if x == 0 or x == MAP_SIZE - 1 or y == 0 or y == MAP_SIZE - 1 then
				-- exterior walls
				mapInfo[x][y] = 2
			elseif (x == x1 and y < 7) or (x == x2 and y > 24) or (y == y1 and x < 7) or (y == y2 and x > 24) or
				(math.abs(x - x1) < 4 and y == 7) or (math.abs(x - x2) < 4 and y == 24) or
				(math.abs(y - y1) < 4 and x == 7) or (math.abs(y - y2) < 4 and x == 24) then
				-- interior walls
				mapInfo[x][y] = 2
			elseif (corner == 1 and x < 4 and y < 4) or
				(corner == 2 and x > 27 and y < 4) or
				(corner == 3 and x < 4 and y > 27) or
				(corner == 4 and x > 27 and y > 27) then
				-- safe starting zone
				mapInfo[x][y] = 6
			elseif (x == 1 and y == 1 and corner ~= 1) or
				(x == 30 and y == 1 and corner ~= 2) or
				(x == 1 and y == 30 and corner ~= 3) or
				(x == 30 and y == 30 and coner ~= 4) then
				-- security servers
				mapInfo[x][y] = 4
			else
				mapInfo[x][y] = 1
			end
		end
	end
	local mapX, mapY
	for o = 1, 12 do
		mapX, mapY = findVacantSpot(2, 2, 29, 29, true)
		mapInfo[mapX][mapY] = randomObstacle()
	end
	if corner == 1 then
		startX = TILE_SIZE
		startY = TILE_SIZE
	elseif corner == 2 then
		startX = 30 * TILE_SIZE
		startY = TILE_SIZE
	elseif corner == 3 then
		startX = TILE_SIZE
		startY = 30 * TILE_SIZE
	else
		startX = 30 * TILE_SIZE
		startY = 30 * TILE_SIZE
	end

	makeCombatant(startX, startY, "player")
	placeRandomEnemies()
end

function buildServerMap()
	mapInfo = {}

	-- cube farm
	local corner = math.random(1, 4)
	local x1 = math.random(12, 20)
	local x2 = math.random(12, 20)
	local y1 = math.random(12, 20)
	local y2 = math.random(12, 20)
	for x = 0, MAP_SIZE - 1 do
		mapInfo[x] = {}
		for y = 0, MAP_SIZE - 1 do
			if x == 0 or x == MAP_SIZE - 1 or y == 0 or y == MAP_SIZE - 1 then
				-- exterior walls
				mapInfo[x][y] = 2
			elseif (corner == 1 and x < 4 and y < 4) or
				(corner == 2 and x > 27 and y < 4) or
				(corner == 3 and x < 4 and y > 27) or
				(corner == 4 and x > 27 and y > 27) then
				-- safe starting zone
				mapInfo[x][y] = 6
			else
				mapInfo[x][y] = 1
			end
		end
	end
	local mapX, mapY
	for s = 1, 8 do
		mapX = math.random(5, 26)
		mapY = (s * 3) + 2
		for x = mapX - 2, mapX + 2 do
			if mapInfo[x][mapY] == 1 then
				if x == mapX and (s == 1 or s == 4 or s == 8) then
					mapInfo[x][mapY] = 4
				else
					if math.random(5) == 1 then
						mapInfo[x][mapY] = 8
					else
						mapInfo[x][mapY] = 7
					end
				end
			end
		end
	end
	if corner == 1 then
		startX = TILE_SIZE
		startY = TILE_SIZE
	elseif corner == 2 then
		startX = 30 * TILE_SIZE
		startY = TILE_SIZE
	elseif corner == 3 then
		startX = TILE_SIZE
		startY = 30 * TILE_SIZE
	else
		startX = 30 * TILE_SIZE
		startY = 30 * TILE_SIZE
	end

	makeCombatant(startX, startY, "player")
	placeRandomEnemies()
end

function buildSnakeMap()
	mapInfo = {}
	local horizontal = false
	if math.random(2) == 2 then
		horizontal = true
	end
	local wall1Width = 3
	local wall1Length = math.random(15, 20) 
	local wall1Position = math.random(5, 7)
	local wall2Width = 3
	local wall2Length = math.random(15, 20) 
	local wall2Position = math.random(22, 24)
	--print("laying down foundation")
	for x = 0, MAP_SIZE - 1 do
		mapInfo[x] = {}
		for y = 0, MAP_SIZE - 1 do
			if x == 0 or x == MAP_SIZE - 1 or y == 0 or y == MAP_SIZE - 1 then
				-- exterior walls
				mapInfo[x][y] = 2
			else
				mapInfo[x][y] = 1
			end
		end
	end
	--print("drawing cross walls", wall1Position, wall1Length, wall2Position, wall2Length)
	if horizontal then
		for x = 0, wall1Length - 1 do
			for y = wall1Position, wall1Position + wall1Width - 1 do
				if x == wall1Length - 1 or y == wall1Position or y == wall1Position + wall1Width - 1 then
					mapInfo[x][y] = 2
				else
					mapInfo[x][y] = 13
				end
			end
		end
		for x = MAP_SIZE - wall2Length, MAP_SIZE - 1 do
			for y = wall2Position, wall2Position + wall2Width - 1 do
				if x == MAP_SIZE - wall2Length or y == wall2Position or y == wall2Position + wall2Width - 1 then
					mapInfo[x][y] = 2
				else
					mapInfo[x][y] = 13
				end
			end
		end
		mapInfo[MAP_SIZE - 2][wall1Position + 1] = 4
		mapInfo[1][wall2Position + 1] = 4
	else
		for y = 0, wall1Length - 1 do
			for x = wall1Position, wall1Position + wall1Width - 1 do
				if y == wall1Length - 1 or x == wall1Position or x == wall1Position + wall1Width - 1 then
					mapInfo[x][y] = 2
				else
					mapInfo[x][y] = 13
				end
			end
		end
		for y = MAP_SIZE - wall2Length, MAP_SIZE - 1 do
			for x = wall2Position, wall2Position + wall2Width - 1 do
				if y == MAP_SIZE - wall2Length or x == wall2Position or x == wall2Position + wall2Width - 1 then
					mapInfo[x][y] = 2
				else
					mapInfo[x][y] = 13
				end
			end
		end
		mapInfo[wall1Position + 1][MAP_SIZE - 2] = 4
		mapInfo[wall2Position + 1][1] = 4
	end
	--print("setting up start areas and servers")
	if math.random(1, 2) == 1 then
		for x = 1, 3 do
			for y = 1, 3 do
				mapInfo[x][y] = 6
			end
		end
		startX = TILE_SIZE
		startY = TILE_SIZE
		mapInfo[MAP_SIZE - 2][MAP_SIZE - 2] = 4
	else
		for x = MAP_SIZE - 4, MAP_SIZE - 2 do
			for y = MAP_SIZE - 4, MAP_SIZE - 2 do
				mapInfo[x][y] = 6
			end
		end
		startX = (MAP_SIZE - 2) * TILE_SIZE
		startY = (MAP_SIZE - 2) * TILE_SIZE
		mapInfo[1][1] = 4
	end
	--print("laying down obstacles")
	local mapX, mapY
	for o = 1, 12 do
		mapX, mapY = findVacantSpot(2, 2, 29, 29, true)
		mapInfo[mapX][mapY] = randomObstacle()
	end
	makeCombatant(startX, startY, "player")
	placeRandomEnemies()
end

function buildBossMap()
	mapInfo = {}

	-- boss level
	for x = 0, MAP_SIZE - 1 do
		mapInfo[x] = {}
		for y = 0, MAP_SIZE - 1 do
			if x == 0 or x == MAP_SIZE - 1 or y == 0 or y == MAP_SIZE - 1 then
				-- exterior walls
				mapInfo[x][y] = 2
			elseif (x == 12 or x == 19) and y < 7 then
				-- boss walls
				mapInfo[x][y] = 2
			elseif y == 8 and x > 2 and x < MAP_SIZE - 3 then
				-- no go horizontal
				mapInfo[x][y] = 9
			elseif y > 8 and (x == 2 or x == MAP_SIZE - 3) then
				-- no go vertical
				mapInfo[x][y] = 12
			elseif y == 8 and x == 2 then
				-- no go upper left
				mapInfo[x][y] = 10
			elseif y == 8 and x == MAP_SIZE - 3 then
				-- no go upper right
				mapInfo[x][y] = 11
			elseif x >= 14 and x <= 17 and y >= 29 then
				-- safe zone
				mapInfo[x][y] = 6
			else
				-- empty space
				mapInfo[x][y] = 1
			end
		end
	end
	for s = 1, 20 do
		mapX, mapY = findVacantSpot(3, 10, 28, 27, true)
		mapInfo[mapX][mapY] = 7
	end
	startX = 16 * TILE_SIZE
	startY = 30 * TILE_SIZE
	makeCombatant(startX, startY, "player")
	boss = makeCombatant(13 * TILE_SIZE, 2 * TILE_SIZE, "boss")
	boss.facing = DOWN_INDEX
	boss.sliding = RIGHT_INDEX
	local c
	for i = 1, SHIELD_LOCKS do
		if i <= SHIELD_LOCKS / 2 then
			mapX, mapY = findVacantSpot(3, 1, 10, 5)
		else
			mapX, mapY = findVacantSpot(MAP_SIZE - 11, 1, MAP_SIZE - 4, 5)
		end
		c = makeCombatant(mapX * TILE_SIZE, mapY * TILE_SIZE, "battery")
		c.frame = math.random(4)
	end
	for i = 1, 6 do
		mapX = (12 + i) * TILE_SIZE
		makeCombatant(mapX, 6 * TILE_SIZE, "shield")
		c = makeCombatant(mapX, TILE_SIZE, "battery")
		c.frame = math.random(4)
	end
	c = makeCombatant(TILE_SIZE, (MAP_SIZE - 2) * TILE_SIZE, "slider")
	c.facing = RIGHT_INDEX
	c.sliding = UP_INDEX
	c = makeCombatant(5 * TILE_SIZE, 7 * TILE_SIZE, "slider")
	c.facing = DOWN_INDEX
	c.sliding = RIGHT_INDEX
	c = makeCombatant((MAP_SIZE - 2) * TILE_SIZE, 9 * TILE_SIZE, "slider")
	c.facing = LEFT_INDEX
	c.sliding = DOWN_INDEX
	locks = 26
end

function drawMap()
	love.graphics.clear()
	for x = 0, MAP_SIZE - 1 do
		for y = 0, MAP_SIZE - 1 do
			love.graphics.draw(textures, tileQuads[mapInfo[x][y]], x * TILE_SIZE, y * TILE_SIZE)
		end
	end
end

function redrawMapTile(x, y)
	love.graphics.setCanvas(mapCanvas)
	love.graphics.setColor(COLOR_BLACK)
	love.graphics.rectangle("fill", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	love.graphics.setColor(COLOR_WHITE)
	love.graphics.draw(textures, tileQuads[mapInfo[x][y]], x * TILE_SIZE, y * TILE_SIZE)
	love.graphics.setCanvas()
end

function makeCombatant(startX, startY, name)
	local combatant = {
		x = startX, 
		y = startY, 
		dX = startX, 
		dY = startY, 
		facing = RIGHT_INDEX, 
		sliding = RIGHT_INDEX,
		animation = 0.0,
		frame = 1,
		waiting = true, 
		name = name,
		cooling = math.random() * BESTIARY[name].cooldown,
		stepping = 0,
		flashing = 0.0,
		hits = BESTIARY[name].hits,
		destroyed = false}
	table.insert(combatants, combatant)
	return combatant
end

function makeMissile(startX, startY, facing, shooter)
	table.insert(missiles, {
		x = startX, 
		y = startY, 
		facing = facing, 
		name = shooter .. "M",
		destroyed = false})
	soundIfOnScreen(shooter, startX, startY)
end

function makeBlast(startX, startY, big)
	local duration = BLAST_TIME
	local size = BLAST_SIZE
	if not big then
		duration = duration / 2.5
		size = size / 2.5
	end
	table.insert(blasts, {
		x = startX,
		y = startY,
		big = big,
		time = 0.0,
		duration = duration,
		size = size,
		destroyed = false})
end

function makeSkull()
	local x = 0.0
	local y = 0.0
	if combatants[1].x < TILE_SIZE * MAP_SIZE / 2 then
		x = TILE_SIZE * (MAP_SIZE - 1)
	end
	if combatants[1].y < TILE_SIZE * MAP_SIZE / 2 then
		y = TILE_SIZE * (MAP_SIZE - 1)
	end
	makeCombatant(x, y, "skull")
end

function removeSkulls()
	for i, c in ipairs(combatants) do
		if c.name == "skull" then
			c.destroyed = true
		end
	end
end

function removeDestroyed(list)
	local i = 1
	local copyTo = 1
	while list[i] do
		if list[i].destroyed then
			list[i] = nil
		else
			if copyTo < i then
				list[copyTo] = list[i]
				list[i] = nil
			end
			copyTo = copyTo + 1
		end
		i = i + 1
	end
end

function pushCombatant(combatant, facing)
	combatant.dX = combatant.x + (VECTORS[facing].x * TILE_SIZE)
	combatant.dY = combatant.y + (VECTORS[facing].y * TILE_SIZE)
	combatant.waiting = false
end

function moveCombatant(combatant, delta)
	-- this could be more succinct

	if BESTIARY[combatant.name].spf > 0.0 and (not combatant.waiting or BESTIARY[combatant.name].passive) then
		if combatant.animation > 0.0 then
			combatant.animation = combatant.animation - delta
		end
		if combatant.animation <= 0.0 then
			combatant.animation = combatant.animation + BESTIARY[combatant.name].spf
			combatant.frame = combatant.frame + 1
			if combatant.frame > 4 then
				combatant.frame = 1
			end
		end
	end
	if not combatant.waiting then
		movement = BESTIARY[combatant.name].speed * delta
		if combatant.name == "player" then
			-- player collision logic
			local mx = combatant.x + combatant.dx * movement
			local my = combatant.y + combatant.dy * movement
			local coords = mapCoordsAtCorners(mx, my)
			local ult = mapInfo[coords.ulx][coords.uly]
			local urt = mapInfo[coords.urx][coords.ury]
			local llt = mapInfo[coords.llx][coords.lly]
			local lrt = mapInfo[coords.lrx][coords.lry]
			local collided = false
			if (TERRAIN[ult].solid or TERRAIN[ult].nogo) and (combatant.dx < 0 or combatant.dy < 0) then
				if ult == 4 then
					unlock(coords.ulx, coords.uly)
				end
				if combatant.dx < 0 then
					combatant.x = math.floor(combatant.x / TILE_SIZE) * TILE_SIZE
				else
					combatant.y = math.floor(combatant.y / TILE_SIZE) * TILE_SIZE
				end
				collided = true
			end
			if (TERRAIN[urt].solid or TERRAIN[urt].nogo) and (combatant.dx > 0 or combatant.dy < 0) then
				if urt == 4 then
					unlock(coords.urx, coords.ury)
				end
				if combatant.dx > 0 then
					combatant.x = math.floor(mx / TILE_SIZE) * TILE_SIZE
				else
					combatant.y = math.floor(combatant.y / TILE_SIZE) * TILE_SIZE
				end
				collided = true
			end
			if (TERRAIN[llt].solid or TERRAIN[llt].nogo) and (combatant.dx < 0 or combatant.dy > 0) then
				if llt == 4 then
					unlock(coords.llx, coords.lly)
				end
				if combatant.dx < 0 then
					combatant.x = math.floor(combatant.x / TILE_SIZE) * TILE_SIZE
				else
					combatant.y = math.floor(my / TILE_SIZE) * TILE_SIZE
				end
				collided = true
			end
			if (TERRAIN[lrt].solid or TERRAIN[lrt].nogo) and (combatant.dx > 0 or combatant.dy > 0) then
				if lrt == 4 then
					unlock(coords.lrx, coords.lry)
				end
				if combatant.dx > 0 then
					combatant.x = math.floor(mx / TILE_SIZE) * TILE_SIZE
				else
					combatant.y = math.floor(my / TILE_SIZE) * TILE_SIZE
				end
				collided = true
			end
			if not collided then
				combatant.x = mx
				combatant.y = my
			end
		else
			-- enemy collision logic
			if combatant.x < combatant.dX then
				if combatant.x + movement >= combatant.dX then
					combatant.x = combatant.dX
					combatant.waiting = true
				else
					combatant.x = combatant.x + movement
				end
			elseif combatant.x > combatant.dX then
				if combatant.x - movement <= combatant.dX then
					combatant.x = combatant.dX
					combatant.waiting = true
				else
					combatant.x = combatant.x - movement
				end
			end
			if combatant.y < combatant.dY then
				if combatant.y + movement >= combatant.dY then
					combatant.y = combatant.dY
					combatant.waiting = true
				else
					combatant.y = combatant.y + movement
				end
			elseif combatant.y > combatant.dY then
				if combatant.y - movement <= combatant.dY then
					combatant.y = combatant.dY
					combatant.waiting = true
				else
					combatant.y = combatant.y - movement
				end
			end
		end
	end
	if combatant.name ~= "player" then
		if math.abs(combatant.x - combatants[1].x) < TILE_SIZE - 2 and
			math.abs(combatant.y - combatants[1].y) < TILE_SIZE - 2 then
			if combatant.name == "rocket" then
				takeHits(combatant, 1)
			else
				killed = true
			end
		end
	end
end

function moveMissile(missile, delta)
	missile.x = missile.x + (VECTORS[missile.facing].x * ARMORY[missile.name].speed * delta)
	missile.y = missile.y + (VECTORS[missile.facing].y * ARMORY[missile.name].speed * delta)
	local centerX = missile.x + TILE_CENTER
	local centerY = missile.y + TILE_CENTER
	local fizzle = false

	if pointIsObstructed(centerX, centerY, ARMORY[missile.name].collision) then
		missile.destroyed = true
		fizzle = true
	else
		for i, c in ipairs(combatants) do
			if (i == 1 and ARMORY[missile.name].collsion ~= "playerMissile") or 
				(i > 1 and ARMORY[missile.name].collision == "playerMissile" and BESTIARY[c.name].collision ~= "insubstantial") then
				local x1, x2, y1, y2
				if c.name == "boss" then
					x1 = c.x + 7
					x2 = x1 + 41
					y1 = c.y
					y2 = y1 + 41
				else
					x1 = c.x
					x2 = x1 + TILE_SIZE
					y1 = c.y
					y2 = y1 + TILE_SIZE
				end
				if centerX >= x1 and centerX < x2 and centerY >= y1 and centerY < y2 then
					if i == 1 then
						if not killed then
							killed = true
						end
					else
						if BESTIARY[c.name].collision ~= "invulnerable" and BESTIARY[c.name].collision ~= "omnipotent" then
							takeHits(c, 1)
						end
					end
					missile.destroyed = true
					break
				end
			end
		end
	end
	if fizzle and missile.name == "playerM" then
		makeBlast(missile.x, missile.y, false)
	end
end

function moveBlast(blast, delta)
	blast.time = blast.time + delta
	if blast.time > blast.duration then
		blast.destroyed = true
	end
end

function unlock(mapX, mapY)
	if mapInfo[mapX][mapY] ~= 4 then
		return
	end
	mapInfo[mapX][mapY] = 5
	redrawMapTile(mapX, mapY)
	unlocked = unlocked + 1
	awardPoints(LOCK_POINTS)
	sounds["unlock"]:play()
end

function checkLocks()
	local checkX, checkY
	local mapX, mapY
	for v = 1, 4 do
		checkX = combatants[1].x + (VECTORS[v].x * TILE_SIZE)
		checkY = combatants[1].y + (VECTORS[v].y * TILE_SIZE)
		mapX, mapY = convertToMapCoords(checkX, checkY)
		if mapInfo[mapX][mapY] == 4 then
			mapInfo[mapX][mapY] = 5
			redrawMapTile(mapX, mapY)
			unlocked = unlocked + 1
			awardPoints(LOCK_POINTS)
			sounds["unlock"]:play()
		end
	end
end

function killBattery()
	unlocked = unlocked + 1
	if unlocked == SHIELD_LOCKS then
		for i, c in ipairs(combatants) do
			if c.name == "shield" then
				takeHits(c, 1)
			end
		end
	end
end
		
function convertToMapCoords(x, y)
	return math.floor(x / TILE_SIZE), math.floor(y / TILE_SIZE)
end

function pointIsObstructed(x, y, from)
	local obstructed = false
	local mapX, mapY = convertToMapCoords(x, y)
	if (from == "player" and (TERRAIN[mapInfo[mapX][mapY]].solid or TERRAIN[mapInfo[mapX][mapY]].nogo)) or 
		(from == "playerMissile" and TERRAIN[mapInfo[mapX][mapY]].solid) or
		(from == "enemy" and (TERRAIN[mapInfo[mapX][mapY]].solid or TERRAIN[mapInfo[mapX][mapY]].safe)) or
		(from == "insubstantial" and TERRAIN[mapInfo[mapX][mapY]].safe) then
		obstructed = true
	elseif from ~= "player" then
		for i, c in ipairs(combatants) do
			if BESTIARY[c.name].collision ~= "insubstantial" and x == c.dX and y == c.dY then
				if not (from == "enemy" and i == 1) then
					obstructed = true
					break
				end
			end
		end
	end
	return obstructed
end

function takeHits(combatant, hits)
	combatant.flashing = FLASH_TIME
	combatant.hits = combatant.hits - hits
	if combatant.hits <= 0 then
		combatant.destroyed = true
		makeBlast(combatant.x, combatant.y, combatant.name ~= "shield")
		sounds["boom"]:play()
		awardPoints(BESTIARY[combatant.name].points)
		if combatant.name == "battery" then
			killBattery()
		elseif combatant.name == "rocket" then
			bigFire(combatant.x, combatant.y)
		end
	end
end

function bigFire(middleX, middleY)
	local f
	local fx
	local fy
	local coords
	for x = -1, 1 do
		for y = -1, 1 do
			fx = middleX + x * TILE_SIZE
			fy = middleY + y * TILE_SIZE
			coords = mapCoordsAtCorners(fx, fy)
			if mapInfo[coords.ulx][coords.uly] == 1 and
				mapInfo[coords.urx][coords.ury] == 1 and
				mapInfo[coords.urx][coords.ury] == 1 and
				mapInfo[coords.urx][coords.ury] == 1 then
				for i, c in ipairs(combatants) do
					if c.name == "flame" and
						fx > c.x - TILE_CENTER and fx < c.x + TILE_CENTER and
						fy > c.y - TILE_CENTER and fy < c.y + TILE_CENTER then
						c.destroyed = true
					end
				end
				f = makeCombatant(fx, fy, "flame")
				f.waiting = false
			end
		end
	end
end

function runEnemyLogic(enemy, delta)
	local rangeX = combatants[1].x - enemy.x
	local rangeY = combatants[1].y - enemy.y
	if enemy.cooling > 0.0 then
		enemy.cooling = enemy.cooling - delta
	end
	if enemy.flashing > 0.0 then
		enemy.flashing = enemy.flashing - delta
	end
	if enemy.name == "spider" or enemy.name == "skull" then
		runEnemyWalkerLogic(enemy, delta, rangeX, rangeY)
	elseif enemy.name == "wasp" or enemy.name == "launcher" then
		runEnemyShooterLogic(enemy, delta, rangeX, rangeY)
	elseif enemy.name == "tank" or enemy.name == "rocket" or enemy.name == "trailer" then
		runEnemyRammerLogic(enemy, delta, rangeX, rangeY)
	elseif enemy.name == "slider" or enemy.name == "boss" then
		runEnemySliderLogic(enemy, delta)
	elseif enemy.name == "turret" then
		runEnemyTurretLogic(enemy, delta, rangeX, rangeY)
	elseif enemy.name == "flame" then
		runEnemyBurnerLogic(enemy, delta)
	end
end

function runEnemyWalkerLogic(enemy, delta, rangeX, rangeY)
	if enemy.waiting then
		local vX = 0.0
		local vY = 0.0
		local facing = RIGHT_INDEX
		-- this is shared with the rammer logic
		if math.abs(rangeX) > math.abs(rangeY) then
			vX = rangeX / math.abs(rangeX)
		else
			vY = rangeY / math.abs(rangeY)
		end
		for f = 1, 4 do
			if vX == VECTORS[f].x and vY == VECTORS[f].y then
				facing = f
			end
		end
		enemy.facing = facing
		local futureX = enemy.x + (vX * TILE_SIZE)
		local futureY = enemy.y + (vY * TILE_SIZE)
		if not pointIsObstructed(futureX, futureY, BESTIARY[enemy.name].collision) then
			pushCombatant(enemy, facing)
		end
	end
end

function runEnemyShooterLogic(enemy, delta, rangeX, rangeY)
	--if enemy.name == "launcher" and enemy.cooling <= 0.0 then print(enemy.cooling, enemy.waiting) end
	if enemy.cooling <= 0.0 and (enemy.waiting or enemy.name ~= "launcher") then
		local fireFacing
		if math.abs(rangeX) > math.abs(rangeY) then
			if rangeX < 0 then
				fireFacing = LEFT_INDEX
			else
				fireFacing = RIGHT_INDEX
			end
		else
			if rangeY < 0 then
				fireFacing = UP_INDEX
			else
				fireFacing = DOWN_INDEX
			end
		end
		if enemy.name == "launcher" then
			rocket = makeCombatant(
				enemy.x + VECTORS[fireFacing].x * TILE_SIZE, 
				enemy.y + VECTORS[fireFacing].y * TILE_SIZE,
				"rocket")
			rocket.facing = fireFacing
			rocket.stepping = math.floor(math.max(math.abs(rangeX), math.abs(rangeY)) / TILE_SIZE)
			soundIfOnScreen("launcher", rocket.x, rocket.y)
		else
			makeMissile(
				enemy.x + VECTORS[fireFacing].x * TILE_SIZE, 
				enemy.y + VECTORS[fireFacing].y * TILE_SIZE,
				fireFacing,
				enemy.name)
		end
		enemy.cooling = BESTIARY[enemy.name].cooldown
	end
	if enemy.waiting then
		if enemy.stepping == 0 then
			enemy.facing = math.random(1, 4)
			enemy.stepping = BESTIARY[enemy.name].steps
		end
		local futureX = enemy.x + (VECTORS[enemy.facing].x * TILE_SIZE)
		local futureY = enemy.y + (VECTORS[enemy.facing].y * TILE_SIZE)
		if not pointIsObstructed(futureX, futureY, BESTIARY[enemy.name].collision) then
			pushCombatant(enemy, enemy.facing)
			enemy.stepping = enemy.stepping - 1
		else
			enemy.stepping = 0
		end
	end
end

function runEnemyRammerLogic(enemy, delta, rangeX, rangeY)
	if enemy.waiting then
		local goNow = false
		if enemy.stepping == 0 then
			if enemy.cooling <= 0.0 then
				local vX = 0.0
				local vY = 0.0
				if math.abs(rangeX) > math.abs(rangeY) then
					vX = rangeX / math.abs(rangeX)
				else
					vY = rangeY / math.abs(rangeY)
				end
				local facing = RIGHT_INDEX
				for f = 1, 4 do
					if vX == VECTORS[f].x and vY == VECTORS[f].y then
						facing = f
					end
				end
				enemy.facing = facing
				enemy.stepping = BESTIARY[enemy.name].steps
				enemy.cooling = BESTIARY[enemy.name].cooldown
				goNow = true
			end
		end
		if enemy.stepping > 0 then
			local futureX = enemy.x + (VECTORS[enemy.facing].x * TILE_SIZE)
			local futureY = enemy.y + (VECTORS[enemy.facing].y * TILE_SIZE)
			if not pointIsObstructed(futureX, futureY, BESTIARY[enemy.name].collision) then
				if goNow then
					soundIfOnScreen(enemy.name, enemy.x, enemy.y)
				end
				if enemy.name == "trailer" then
					local fire = makeCombatant(enemy.x, enemy.y, "flame")
					fire.waiting = false
				end
				pushCombatant(enemy, enemy.facing)
				enemy.stepping = enemy.stepping - 1
			else
				enemy.stepping = 0
			end
			if enemy.stepping == 0 then
				if enemy.name == "rocket" then
					takeHits(enemy, 1)
				else
					enemy.cooling = BESTIARY[enemy.name].cooldown
				end
			end
		end
	end
end

function runEnemySliderLogic(enemy, delta)
	if enemy.name == "boss" then
		if unlocked >= SHIELD_LOCKS then
			if enemy.cooling < 1.0 then
				local i1 = math.floor(enemy.cooling / 0.1)
				local i2 = math.floor((enemy.cooling + delta) / 0.1)
				if i1 ~= i2 then
					makeMissile(
						enemy.x + TILE_SIZE + (math.random() * TILE_SIZE),
						enemy.y + TILE_SIZE * 3,
						DOWN_INDEX, enemy.name)
				end
			elseif enemy.cooling <= 0.0 then
				enemy.cooling = enemy.cooling + BESTIARY[enemy.name].cooldown
			end
		end
	else
		if enemy.cooling <= 0.0 then
			makeMissile(
				enemy.x + VECTORS[enemy.facing].x * TILE_SIZE, 
				enemy.y + VECTORS[enemy.facing].y * TILE_SIZE,
				enemy.facing,
				enemy.name)
			enemy.cooling = BESTIARY[enemy.name].cooldown
		end
	end
	if enemy.waiting then
		if enemy.stepping == 0 then
			enemy.stepping = BESTIARY[enemy.name].steps
		end
		if enemy.stepping > 0 then
			pushCombatant(enemy, enemy.sliding)
			enemy.stepping = enemy.stepping - 1
			if enemy.stepping == 0 then
				enemy.sliding = enemy.sliding + 2
				if enemy.sliding > 4 then
					enemy.sliding = enemy.sliding - 4
				end
			end
		end
	end
end

function runEnemyTurretLogic(enemy, delta, rangeX, rangeY)
	if enemy.cooling < 1.0 then
		local i1 = math.floor(enemy.cooling / 0.2)
		local i2 = math.floor((enemy.cooling + delta) / 0.2)
		if i1 ~= i2 then
			for v = 1, 4 do
				makeMissile(
					enemy.x + VECTORS[v].x * TILE_SIZE,
					enemy.y + VECTORS[v].y * TILE_SIZE,
					v, enemy.name)
			end
		end
		if enemy.cooling <= 0.0 then
			enemy.cooling = enemy.cooling + BESTIARY[enemy.name].cooldown
		end
	elseif enemy.cooling < 2.0 then
		enemy.frame = math.floor((enemy.cooling - 1.0) / 0.25) + 1
	end
end

function runEnemyBurnerLogic(enemy, delta)
	if enemy.cooling <= 0.0 then
		enemy.destroyed = true
	end
end

function demise(delta)
	local i1 = math.floor(stalling / 0.1)
	local i2 = math.floor((stalling + delta) / 0.1)
	if i1 ~= i2 then
		makeBlast(
			boss.x + (TILE_SIZE * 3.0 * math.random()),
			boss.y + (TILE_SIZE * 3.0 * math.random()),
			false)
	end
end

function findVacantSpot(minX, minY, maxX, maxY, wide)
	local searching = true
	local x1 = minX or 1
	local y1 = minY or 1
	local x2 = maxX or MAP_SIZE - 2
	local y2 = maxY or MAP_SIZE - 2
	local tryMapX = math.random(x1, x2)
	local tryMapY = math.random(y1, y2)
	local lowMapX
	local hiMapX
	local lowMapY
	local hiMapY
	local obstructed
	while searching do
		if wide then
			lowMapX = tryMapX - 2
			lowMapY = tryMapY - 2
			hiMapX = lowMapX + 5
			hiMapY = lowMapY + 5
		else
			lowMapX = tryMapX
			lowMapY = tryMapY
			hiMapX = lowMapX
			hiMapY = lowMapY
		end
		obstructed = false
		for mapX = lowMapX, hiMapX do
			for mapY = lowMapY, hiMapY do
				if not obstructed then
					x = mapX * TILE_SIZE
					y = mapY * TILE_SIZE
					if pointIsObstructed(x, y, "enemy") then
						obstructed = true
					end
				end
			end
		end
		if not obstructed then
			x = tryMapX * TILE_SIZE
			y = tryMapY * TILE_SIZE
			for i, c in ipairs(combatants) do
				if x == c.x and y == c.y then
					obstructed = true
					break
				end
			end
		end
		if not obstructed then
			searching = false
		else
			tryMapX = tryMapX + 1
			if tryMapX > maxX then
				tryMapX = minX
				tryMapY = tryMapY + 1
				if tryMapY > maxY then
					tryMapY = minY
				end
			end
		end
	end
	return tryMapX, tryMapY
end

function checkOldButtons()
	oldButtons = startButton() or shootButton() or aimButton() or backButton() or upButton() or downButton() or leftButton() or rightButton()
end

function startTitle()
	title = true
	checkOldButtons()
	sounds["startup"]:play()
end

function startGame()
	checkOldButtons()
	score = 0
	level = 1
	lives = startingLives
	gameOver = false
	killed = false
	paused = false
	startLevel()
end

function placeRandomEnemies()
	local keys = {}
	for k in pairs(BESTIARY) do
		if BESTIARY[k].eachLevel then
			table.insert(keys, k)
		end
	end
	local chosen = {}
	local r = 0
	while #chosen < 3 do
		r = math.random(#keys)
		table.insert(chosen, keys[r])
		table.remove(keys, r)
	end
	for i, e in ipairs(chosen) do
		for n = 1, BESTIARY[e].level1 + math.floor(level * BESTIARY[e].eachLevel) do
			mapX, mapY = findVacantSpot(2, 2, MAP_SIZE - 2, MAP_SIZE - 2, true)
			makeCombatant(mapX * TILE_SIZE, mapY * TILE_SIZE, e)
		end
	end
end

function startLevel()
	combatants = {}
	missiles = {}
	blasts = {}
	killed = false
	advancing = false
	unlocked = 0
	stalling = 0.0

	local mapX, mapY
	if level == LAST_LEVEL then
		buildBossMap()
	else
		local algorithm = math.random(3)
		if algorithm == 1 then
			buildOfficeMap()
		elseif algorithm == 2 then
			buildServerMap()
		else
			buildSnakeMap()
		end
		locks = 3
	end
	mapCanvas:renderTo(drawMap)

	combatants[1].cooling = 0.0
	resetHeartbeat()
	lifetime = 0.0
	sounds["begin"]:play()
end

function awardPoints(points)
	local tenThousands = math.floor(score / BONUS_LIFE_SCORE)
	score = score + points
	if lives < 10 and math.floor(score / BONUS_LIFE_SCORE) > tenThousands then
		lives = lives + 1
	end
end

function resetPlayer()
	combatants[1].x = startX
	combatants[1].y = startY
	combatants[1].dX = startX
	combatants[1].dY = startY
	combatants[1].frame = 1
	combatants[1].animation = 0.0
	combatants[1].waiting = true
	combatants[1].cooling = 0.0
	blasts = {}
	resetHeartbeat()
	removeSkulls()
	lifetime = 0.0
	sounds["begin"]:play()
end

function readSaveFile()
	local file, ioError
	file, ioError = love.filesystem.newFile("savedata", "r")
	if file then
		local saveData = file:read()
		_, _, scoreString, livesString, volumeString = string.find(saveData, "(%d+) (%d+) (%d+)")
		highScore = tonumber(scoreString)
		startingLives = tonumber(livesString)
		volume = tonumber(volumeString)
		file:close()
		love.audio.setVolume(volume / 10.0)
	end
end

function writeSaveFile()
	local file, ioError
	file, ioError = love.filesystem.newFile("savedata", "w")
	if file then
		file:write(string.format("%d %d %d", highScore, startingLives, volume))
		file:close()
	end
end

function resetHeartbeat()
	beat = MAX_BEAT_TIME - ((level - 1) * BEAT_PER_LEVEL)
end

function mapCoordsAtCorners(x, y)
	local coords = {}
	coords.ulx, coords.uly = convertToMapCoords(x, y)
	coords.urx, coords.ury = coords.ulx, coords.uly 
	coords.llx, coords.lly = coords.ulx, coords.uly 
	coords.lrx, coords.lry = coords.ulx, coords.uly 
	if x - coords.ulx * TILE_SIZE > 0.0 then
		coords.urx = coords.urx + 1
		coords.lrx = coords.lrx + 1
	end
	if y - coords.uly * TILE_SIZE > 0.0 then
		coords.lly = coords.lly + 1
		coords.lry = coords.lry + 1
	end
	return coords
end

function soundIfOnScreen(snd, x, y)
	if x > combatants[1].x - SCREEN_CENTER.x and x < combatants[1].x + SCREEN_CENTER.x and
		y > combatants[1].y - SCREEN_CENTER.y and y < combatants[1].y + SCREEN_CENTER.y then
		sounds[snd]:play()
	end
end

-- gamepad and keyboard functions

function getGamepad()
	local pad = nil
	local joysticks = love.joystick.getJoysticks()
	for i, j in ipairs(joysticks) do
		if j:isGamepad() then
			pad = j
			break
		end
	end
	return pad
end

function downButton()
	if love.keyboard.isDown("down") then
		return true
	elseif gamepad then
		return gamepad:getGamepadAxis("lefty") > 0.5
	end
	return false
end

function upButton()
	if love.keyboard.isDown("up") then
		return true
	elseif gamepad then
		return gamepad:getGamepadAxis("lefty") < -0.5
	end
	return false
end

function leftButton()
	if love.keyboard.isDown("left") then
		return true
	elseif gamepad then
		return gamepad:getGamepadAxis("leftx") < -0.5
	end
	return false
end

function rightButton()
	if love.keyboard.isDown("right") then
		return true
	elseif gamepad then
		return gamepad:getGamepadAxis("leftx") > 0.5
	end
	return false
end

function startButton()
	if love.keyboard.isDown("return") then
		return true
	elseif gamepad then
		return gamepad:isGamepadDown("start")
	end
	return false
end

function backButton()
	if love.keyboard.isDown("escape") then
		return true
	elseif gamepad then
		return gamepad:isGamepadDown("back")
	end
	return false
end

function shootButton()
	if love.keyboard.isDown("z") then
		return true
	elseif gamepad then
		return gamepad:isGamepadDown("a")
	end
	return false
end

function aimButton()
	if love.keyboard.isDown("x") then
		return true
	elseif gamepad then
		return gamepad:isGamepadDown("x")
	end
	return false
end
