#Random Race Generator v1.2

##Content

- [Introduction](https://github.com/Basssiiie/Random-Race-Generator#introduction)
- [How to add to server](https://github.com/Basssiiie/Random-Race-Generator#how-to-add-to-server)
- [Troubleshooting](https://github.com/Basssiiie/Random-Race-Generator#troubleshooting)
- [Customized RRG (Includes)](https://github.com/Basssiiie/Random-Race-Generator#customized-rrg-includes)
- [Changelog](https://github.com/Basssiiie/Random-Race-Generator#customized-rrg-includes)

 -----------------------------------------
 
##Introduction

###Description
This SA-MP script allows the player to randomly create races across the San Andreas map.
 
While doing this, it provides a neat GUI for viewing the current available races.
 
###Server Commands

| Command | Effect |
| --- | --- |
| `/rrg (main command)` | Shows all possible commands in the chat. |
| `/rrg help` | Same as `/rrg`. |
| `/rrg menu` | Shows the race list (join & create). |
| `/rrg respawn` | Respawns the at the last checkpoint. |
| `/rrg leave` | Leave the current race or call it off. |
| `/rrg start` | Starts the current race, if player is the host. |
| `/rrg invite [name]` | Invite another player to your race, if the inviting player is host. |
| `/rrg showinvite` | Shows the last received invite. |
	
###Contest
This script was made for the RouteConnector contest, hosted by Gamer_Z.
 
Contest URL: http://forum.sa-mp.com/showthread.php?t=411412

###Thanks a lot
 - Gamer_Z;
 - Mauzen;
 - All the people who contributed to the forums with their snippets and examples!

###End note

Feel free to edit this script as you like. You are also allowed to borrow any code from it, as long as you keep some credits to me. Please do not claim this as your own.

If you have any problems with or questions about this script, please contact me via the official SA-MP forums or on Github.

Topic URL: http://forum.sa-mp.com/showthread.php?t=437708

Regards,
Basssiiie

 -----------------------------------------

##How to add to server

###Step 1
Make sure you have the RouteConnector plugin installed. 
 - Download: http://forum.sa-mp.com/showthread.php?t=292031
 - Put the plugin in the 'plugins' folder.
 - Put the *.dat files in the 'scriptfiles' folder.
 - Add 'RouteConnectorPlugin' (or 'RouteConnectorPlugin.so' on Linux server) after 'plugins' in server.cfg.

###Step 2
If you want to use the Random Race Generator as a gamemode:
 - Put RandomRaceGenerator.amx in either the 'gamemodes' folder.
 - Set gamemode0 (or any other number) to 'gamemode0 RandomRaceGenerator 1' in server.cfg.
	
If you want to use the Random Race Generator as a filterscript:
 - Put RandomRaceGenerator.amx in either the 'filterscripts' folder.
 - Add 'RandomRaceGenerator' after 'filterscripts' in server.cfg.
	
If you want to use the Random Race Generator as an include:
 - Scroll down to read the 'CUSTOMIZED RRG' part.
	
###Step 3
Launch the server and check in the console if both the plugin and Random Race Generator are launched properly.

 -----------------------------------------

##Troubleshooting

####_When I try to create a race, the script says "move closer to the road!" even though I'm standing on the road?_

Make sure you have a node-file loaded. When you load the RouteConnector plugin, it will tell you in the console how many nodes were loaded. By default, it will load GPS.dat in the "scriptfiles" folder. This file is included in the [download](http://forum.sa-mp.com/showthread.php?t=292031) of the plugin. If this file is not present and there's no other node-file loaded, this problem might occur.

Fix it by redownloading the plugin and putting GPS.dat in the "scriptfiles" folder. Restart the server and the problem should be fixed.

####_The script loads fine in the console/log, but when I type one of the commands, it responds `SERVER: Unknown command`?_

####_The server log reports `[debug]Run time error 19: "File or function is not found"` followed by names of functions?_

Follow this checklist:

**Step 1:** Go to your server folder where "samp-server.exe" or "samp03svr" is located.

**Step 2:** Go to the folder "plugins": is there a file called "RouteConnectorPlugin.dll" (if Windows server) or "RouteConnectorPlugin.so" (if Linux server)?

  - If the correct file is not present, download the RouteConnector plugin [here](http://forum.sa-mp.com/showthread.php?t=292031). 
  
**Step 3:** Go back to the folder containing "samp-server.exe" or "samp03svr". Now open the file called "server.cfg": find the line which starts with "plugins".

  - If this line is not present, add it at the bottom along with the instruction below.
  
  - If this line is present, make sure one of the words after that (on the same line) is "RouteConnectorPlugin" (if Windows server) or "RouteConnectorPlugin.so" (if Linux server).
  
**Step 4:** Now re-launch your server and check the console if the plugin loads properly. You can see this because it will print this:
```
Loading plugin: RouteConnectorPlugin
Loaded.
```
There are probably some extra words between those lines, but it is at utmost important that it prints the line called "Loaded." before it prints another "Loading plugin:"-line for another plugin (if you have any others).
  
**Step 5:** If you're still experiencing problems, feel free to leave a message in this topic. I'll try to respond as quick as possible.

####_The server log reports `Failed (libtbb.so.2: cannot open shared object file: No such file or directory)`?_

The RouteConnector plugin makes use of IntelTBB. Make sure you have it installed on your Linux server. You can download it [here](https://www.threadingbuildingblocks.org/download). Download the linux binaries and install the 'ia32' redistribution.

Otherwise, you may be able to use this:
```
sudo apt-get install libtbb-dev
sudo apt-get install libtbb2
```
(Source: [maker of RouteConnector, Gamer_Z](http://forum.sa-mp.com/showthread.php?t=292031))


 -----------------------------------------

##Customized RRG (Includes)

Version 1.2 allows scripters to create their own versions of the Random Race Generator, for example by adding new features or creating a new GUI.

If you want to create a custom version, you have to include the original script into your new filterscript. 

 - To do this, you can to place 'RandomRaceGenerator.pwn' in the 'pawno/include' folder.

Alternatively, you can keep it in the 'gamemodes' folder if you want to include it in your gamemode, or in the 'filterscripts' folder to include it in your filterscript.
		
 - **NOTE:** If you want to load your custom version into your server, you don't have to load the original script too! It's included in your new script, so you can remove the original one from your server.cfg file.

There are two example scripts in the download of RRG, which will showcase how everything is set up.
 - **RRG_prizemoney:** A custom script which gifts the first, second and third place in a race some prize money. It shows how you can hook the script using RRG callbacks without much hassle.
 - **RRG_bonuspickups:** This custom script is a bit larger. It spawns one of three pickups every few checkpoints. One pickup will give the car nitro, another one repairs the car. The last one will explode when picked up. It's a combination of several callbacks, functions and using additional arrays for saving race data.

If you want to release your customized version to the public, you can do that. However, you cannot reupload the original script with it!

- In your release topic, provide a download link to the original forum topic. (This one: http://forum.sa-mp.com/showthread.php?t=437708 )

###Callbacks

```pawn
forward onRandomRaceCreated(raceid, hostplayer, Float: totaldistance, totalcps); 
	Description:
		Is called when a race is succesfully generated after using 'generateRandomRace'.
	Params:
		- raceid		= The ID of the created race.
		- hostplayer	= Player ID of the creator and host of the race.
		- totaldistance	= The total distance of the race in meters.
		- totalcps		= The total amount of checkpoints in the race.


forward onPlayerJoinRace(playerid, raceid);
	Description:
		Is called when someone joins a race.
	Params:
		- playerid		= The ID of the player who joined.
		- raceid		= The ID of the race.


forward onPlayerFinishRace(playerid, raceid, position);
	Description:
		Is called when someone checks the last checkpoint in a race.
	Params:
		- playerid		= The ID of the player who finished the race.
		- raceid		= The ID of the race.
		- position		= The position at which he finished.


forward onPlayerCheckCP(playerid, raceid, cpid);
	Description:
		Is called every time a player enters a race checkpoint.
	Params:
		- playerid		= The ID of the player who checked the race checkpoint.
		- raceid		= The ID of the race.
		- cpid			= The ID of the checkpoint.


forward onRaceCountdown(raceid);
	Description:
		If the countdown is enabled, this callback will be called when the countdown starts.
		If the countdown is disabled, this callback will not be called.
	Params:
		- raceid 		= The ID of the race.


forward onRaceStart(raceid);
	Description:
		Is called when the race starts.
	Params:
		- raceid		= The ID of the race.


forward onRaceRemove(raceid);
	Description:
		Is called when the race is removed.
	Params:
		- raceid		= The ID of the race.
```

###Macro's
```pawn
#define RRG_DisableCommands
	Description:
		If defined before the include, it will disable commands like /rrg. Useful if you want to make your own commands or only access the race generator from a specific location.
```

###Main Functions
```pawn
native generateRandomRace(hostplayer, Float: startX, Float: startY, Float: startZ, Float: distance, vehiclemodel, bool: private, slot = -1, Float: nodedistance = 1000.0, bool: nodeareas = false);
	Description:
		Generates a new random race and calls 'onRandomRaceGenerated(raceid, hostplayer, Float: totaldistance, totalcps)' when done with creating.
	Params:
		- hostplayer	= The ID of the player who will be the host.
		- startXYZ		= The position where the race will start, the script will pick the closest path node to this point.
		- distance		= The total allowed distance the race should be.
		- vehiclemodel	= The model ID of the vehicle which will be used in the race.
		- private		= Toggles whether the race should be private or not. Set to 'true' if race should be private, set to 'false' if race should be public.
						   Will only have effect if 'slot' is -1, else it will be private depending on the slot ID.
		- slot			= The internal slot which will be used for the race. Use -1 to just get the first empty slot. 
						   Note that any other number can just overwrite another race if the slot is already used.
						   With the default settings, public races are slots 0 to 12 and private races are slots 13 to 24.
		- nodedistance	= The maximum distance to the closest path node for the RouteConnector plugin.
		- nodeareas		= Allow use of RouteConnector's checking only in nearby areas. Look at RouteConnector documentation about 'NearestNodeFromPoint' for more information.
	Returns:
		Slot ID (raceid) of the created race...
		or -1 if unable to create race. (The host player might not be online, or the vehicle model is invalid, or the starting position is invalid or no slots are available at the moment.)


native startRace(raceid, bool: countdown = true);
	Description:
		Starts the race after it was generated with the 'generateRandomRace' function.
	Params:
		- raceid		= The ID of the race.
		- countdown		= Defines whether to use the default countdown, if 'false' the race will start instantly. (Useful for custom countdowns.)
	Returns:
		0 if the race doesn't exist, 1 otherwise.


native removeRace(raceid);
	Description:
		Removes the race and its information from memory and kicks all its contestants, empties the race slot for new races.
	Params:
		- raceid		= The ID of the race.
	Returns:
		0 if race doesn't exist, 1 otherwise.
```
###Player Functions
```pawn
native putPlayerInRace(playerid, raceid);
	Description:
		Adds a new player into the race.
	Params:
		- playerid		= The ID of the player who will join the race.
		- raceid		= The ID of the race.
	Returns:
		0 if race doesn't exist or player is not online or there is no room for more players in the race, or 1 otherwise.

		
native removePlayerFromRace(playerid);
	Description:
		Removes a player from the race he/she is currently in. Removing the host will cause the script to pick another host, if there are no other contestants the race will be removed.
	Params:
		- playerid		= The ID of the player who needs to be removed from the race.
	Returns:
		0 if player is not online or not in a race, or 1 otherwise.


native isPlayerInRace(playerid, raceid);
	Description:
		Checks if the player is in the specified race.
	Params:
		- playerid		= The ID of the player.
		- raceid		= The ID of the race.
	Returns:
		1 if player is in the specified race, or 0 if not.


native getPlayerRace(playerid);
	Description:
		Returns the current race of the player.
	Params:
		- playerid		= The ID of the player.
	Returns:
		The ID of the race the player is in, or -1 if the player is not in a race or not online.


native getPlayerCurrentCheckpoint(playerid);
	Description:
		Returns the current checkpoint ID of the player in a race.
	Params:
		- playerid		= The ID of the player.
	Returns:
		The ID of the current checkpoint; or 0 if the player is not in a race, the race hasn't started yet or the player is not online.


native isPlayerInRaceVehicle(playerid);
	Description:
		Checks if the player is in his/her race vehicle.
	Params:
		- playerid		= The ID of the player.
	Returns:
		1 if player is in his/her race vehicle, or 0 if not.


native getPlayerRaceVehicleID(playerid);
	Description:
		Returns the vehicle ID of the player's race vehicle.
	Params:
		- playerid		= The ID of the player.
	Returns:
		The ID of the player's race vehicle, or 0 if the player is not in a race or if the player is not online.


native isPlayerFinishedInRace(playerid);
	Description:
		Checks if the player has finished the race he or she is currently in.
	Params:
		- playerid		= The ID of the player.
	Returns:
		1 if player has finished his current race, or 0 if the player still in race or not in a race or the player is not online.


native getPlayerRacePosition(playerid);
	Description:
		Returns the current race position of the player.
	Params:
		- playerid		= The ID of the player.
	Returns:
		The current race position (1st, 2nd etc.), or 0 if the player is not online or not in a race or the race hasn't been started yet.


native showJoinMenuForPlayer(playerid);
	Description:
		Shows the default race lobby menu (with the map) to the player.
	Params:
		- playerid		= The ID of the player.
	Returns:
		0 if player is not online, or 1 otherwise.
``` 
###Race Functions
```pawn
native isRaceValid(raceid);
	Description:
		Checks if the given race exists.
	Params:
		- raceid		= The ID of the race.
	Returns:
		0 if race doesn't exist, or 1 if race does exist.


native isRacePublic(raceid);
	Description:
		Checks if the given race is public or not.
	Params:
		- raceid		= The ID of the race.
	Returns:
		0 if race doesn't exist or is not public, or 1 if race is public.


native isRacePrivate(raceid);
	Description:
		Checks if the given race is private or not.
	Params:
		- raceid		= The ID of the race.
	Returns:
		0 if race doesn't exist or is not private, or 1 if race is private.


native getRaceHost(raceid);
	Description:
		Returns the player ID of the host of the race.
	Params:
		- raceid		= The ID of the race.
	Returns:
		The player ID of the host of the race, or INVALID_PLAYER_ID if race doesn't exist.


native getRaceState(raceid);
	Description:
		Returns the current state of the given race.
	Params:
		- raceid		= The ID of the race.
	Returns:
		RACE_STATE_NONE (0) if the race doesn't exist.
		RACE_STATE_CREATED (1) if the race has been created but not yet started.
		RACE_STATE_COUNTING (2) if the default countdown has started.
		RACE_STATE_STARTED (3) if the race has started.
		RACE_STATE_ENDED (4) if the race has ended (everyone has finished and race is counting down to removal).


native getRaceCheckpointAmount(raceid);
	Description:
		Returns the total amount of checkpoints in the given race.
	Params:
		- raceid		= The ID of the race.
	Returns:
		The total amount of checkpoints, or 0 if the race doesn't exist.


native isValidRaceCheckpoint(raceid, cpi);
	Description:
		Checks if the given checkpoint is a valid one in the given race.
	Params:
		- raceid		= The ID of the race.
		- cpi			= The ID of the checkpoint.
	Returns:
		0 if the race doesn't exist or the checkpoint is not valid, or 1 if the checkpoint does exist.


native getRaceCheckpointPos(raceid, cpid, &Float: cpx, &Float: cpy, &Float: cpz);
	Description:
		Returns the position of the given checkpoint.
	Params:
		- raceid		= The ID of the race.
		- cpid			= The ID of the checkpoint.
		- cpx			= Stores the X value of the position.
		- cpy			= Stores the Y value of the position.
		- cpz			= Stores the Z value of the position.
	Returns:
		0 if the race doesn't exist or cpid is out of range, or 1 along with coordinates if checkpoint does exist.


native getRaceContestantAmount(raceid);
	Description:
		Returns the total amount of contestants in the given race.
	Params:
		- raceid		= The ID of the race.
	Returns:
		The amount of contestants in the given race, or 0 if race doesn't exist.


native getRaceFinishedAmount(raceid);
	Description:
		Returns the total amount of contestants which have finished the given race.
	Params:
		- raceid		= The ID of the race.
	Returns:
		The amount of contestants who have finished the given race, or 0 if 0 if race doesn't exist or no-one has finished yet.


native Float: getRaceDistance(raceid);
	Description:
		Returns the total distance of the given race in meters.
	Params:
		- raceid		= The ID of the race.
	Returns:
		The distance of the race in meters, or 0.0 if the race doesn't exist.


native getRaceVehicleModel(raceid);
	Description:
		Returns the vehicle model used for the given race.
	Params:
		- raceid		= The ID of the race.
	Returns:
		The model ID of the vehicle in the race, or 0 if the race doesn't exist.
```

 -----------------------------------------

##Changelog

###Version 1.2, 1st of June 2014
 - Added: You can now invite players to the race you are currently in (both public and private races).
 - Added: The ability to create private races. Other people can only join these races via invites from one of the contestants.
 - Added: During the race, a textdraw will show the contestant how many checkpoints are left and which position he has in the race.
 - Added: Extra checks and warning messages for outdated include and plugin and missing GPS.dat.
 - Added: It's possible to use this script as an include as well. For more information, check the forum-post.
 - Added: More compatibility with different virtual worlds.
 - Added: The game will now message you via the chat if a race is canceled.
 - Added: While calculating a race, the game will now tell you what the progress is in percentages.
 - Added: More fancy colors in the chat messages.
 - Added: Support for include scripts, see 'RRG_readme.txt' or forums for more information.
 - Added: Two include example scripts; 'RRG_prizemoney' and 'RRG_bonuspickups'.
 - Added: Chocolate flavour with sprinkles.
 - Changed: All the command-names are changed, they are more consistent and user friendly.
 - Changed: Revamped the way race-info is saved internally.
 - Changed: The script settings are better ordered now. (Made a new category called "Limiting settings", with all the limits.)
 - Changed: The range in which the closest road has to be has been increased by 50%.
 - Changed: Races now require at least two contestants to start. (This can be adjusted in the script settings though.)
 - Changed: The 60 seconds ending timer will switch to a 15 second timer if all contestants have finished the race.
 - Changed: Opening the race menu will now empty death message box only for the player itself. (Not server-wide, new 0.3z R2-2 function.)
 - Improved: Heavily improved route creation progress; 'sudden turnarounds' should be less frequent now.
 - Fixed: Starting the race twice doesn't cause the race to reset anymore.
 - Fixed: If your respawn before the race started for whatever reason (death, vehicle destroyed), now you'll respawn in your spot and not in the middle of the road.
 - Fixed: Respawning after you died won't spawn you somewhere else anymore on some servers.
 - Fixed: On some servers, you could abuse certain (non-RRG) commands to unfreeze yourself before the race started, this should be fixed now.
 - Fixed: The vehicle engine will be automatically turned on when the race starts. (To fix some servers which use manual toggling.)
 - Fixed: The total route distance is a bit more accurate now.
 - Fixed: "Run time error 20" if script was used as gamemode.
 - Fixed: Ghost vehicles (vehicles which drive without visible driver) should not happen anymore.

###Version 1.1, 13th of August 2013
 - Added: You can use different vehicle models for a race now in a pre-set list. This list is changeable in the settings.
 - Added: There's also an option called "Enter a specific model ID" in the list, but this has to be enabled via the settings.
 - Added: The join menu now has a sidebar on the left, which contains information about the selected race. (vehicle, length, host, contestants etc..)
 - Added: Several new settings in the *.PWN file, like: configurable respawn time, race vehicle list and some internal offsets and limits.
 - Added: When leaving your vehicle, you'll be prompted to return to it. If not, the player will be removed from the race.
 - Added: When waiting for a race to start, the player-list is shown to notify you who's in the race.
 - Changed: The "How to respawn"-message so it will show up when the countdown hits '3' instead of 'GO'.
 - Changed: Default minimum race distance is now 150 instead of 500.
 - Improved: Slightly better route and distance calculation.
 - Improved: Extra UI information during race creation for slower servers. (In case creating a race takes longer than a few seconds.)
 - Fixed: /leaverace doesn't try to remove you from a race anymore, if you aren't in one.
 - Fixed: Your vehicle is locked now so people can't highjack your race vehicle anymore.
 - Fixed: You won't be respawned twice when dying in your exploding vehicle.
 - Fixed: Races which were created in the first slot will start properly now.
 - Fixed: You can now only check checkpoints if you are in your race vehicle.

###Version 1.0, 17th of May 2013
 - First release
 
