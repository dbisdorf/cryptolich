# 0.1.0

[x] Start screen
[x] Decent sprites
[x] Increasing level difficulty
[x] Proper death procedure - jump to start location but maintain enemies
[x] sounds
[x] death VFX
[x] level transition

# 0.2.0

[x] enemy becomes combatants[1] bug
[x] Cube farm level design
[x] random starting corner
[x] turret enemy
[x] random starting cooldowns
[x] video feedback for when missile splashes harmlessly
[x] automatic build

# 0.3.0

[x] Death cloud
[x] Random enemy selection
[x] Instructions text
[x] Credits
[x] Controlled exit from title
[x] Explain the digital nature of the fight?
[ ] Constrain delta in updates due to this bug?

Error: main.lua:604: attempt to index a nil value
stack traceback:
	[love "boot.lua"]:345: in function '__index'
	main.lua:604: in function 'pointIsObstructed'
	main.lua:545: in function 'moveMissile'
	main.lua:242: in function 'update'
	[love "callbacks.lua"]:162: in function <[love "callbacks.lua"]:144>
	[C]: in function 'xpcall'


# Future features

Level design
More enemies
- Steamroller
- Fire trail
- Missile launcher
High score
More sounds
Options / key help
Exit from middle of game? Maybe after prompt?

# Tuning

spiders aren't much of a threat
text gloss / formatting / color

# Outstanding bugs

sprites don't fade during game-over
ought to reset all player-related timers (like cooldowns) between levels/kills
cooldowns and other timers should have time ADDED after it hits zero, shouldn't just jump up to full time
do we really need the strafe key?
you should die if you move into an enemy - moving into an enemy right now is buggy

