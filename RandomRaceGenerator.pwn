/*
     // - - - - - - - - - - - - - - - - //
    //   Random Race Generator v1.2.1  //
   // - - - - - - - - - - - - - - - - // 

	Description:
	 This script allows the player to randomly 
	 create races across the San Andreas map.
	 
	 While doing this, it provides a neat GUI for 
	 viewing the current available races.
	 
	Commands:
	 /rrg (main command)
	 /rrg help
		 - shows all possible commands in the chat.
	 /rrg menu
		 - shows the race list (join & create).
	 /rrg respawn
		 - respawns the at the last checkpoint.
	 /rrg leave
		 - leave the current race or call it off.
	 /rrg start
		 - starts the current race, if player is
			the host.
	 /rrg invite [name]
		 - invite another player to your race, if
			the inviting player is host.
	 /rrg showinvite
		 - shows the last received invite.
		
	Contest:
	 This script was made for the RouteConnector
	 contest, hosted by Gamer_Z.
	 
	 Contest URL:
	 http://forum.sa-mp.com/showthread.php?t=411412
	
	Thanks a lot:
	 - Gamer_Z;
	 - Mauzen;
	 - All the people who contributed to the forums
	   with their snippets and examples!
	
	End note:
	 Feel free to edit this script as you like. You
	 are also allowed to borrow any code from it,
	 as long as you keep some credits to me.
	 Please do not claim this as your own.
	
	 If you have any problems with or questions
	 about this script, please contact me via the 
	 official SA-MP forums or on GitHub.
	 
	 An extensive readme can be found on the
	 GitHub page of this script.
	 
	 Topic URL:
	 http://forum.sa-mp.com/showthread.php?t=437708
	 
	 GitHub URL:
	 https://github.com/Basssiiie/Random-Race-Generator
	
	Regards,
	 Basssiiie
	 
*/

// ---------------------------------------------
// --- > --- > --- MAIN SETTINGS --- < --- < ---
// ---------------------------------------------


// This defines the amount of milliseconds before you'll be respawned.
// Default: 2000
#define RESPAWN_TIME 2000


// This defines the virtual world which will be used for the races.
// Note: if this isn't 0 and REMEMBER_OLD_POSITION is false, make sure there's a way out of this virtual world! (Ex. via other cmds)
// Default: 0
#define RACE_VIRTUAL_WORLD 0

// This is the amount of seconds it will take before a player gets disqualified for leaving their vehicle.
// Note: set to 0 if you want to disable this, which allows players to roam the land on foot and they might annoy other people.
// Default: 25 
#define VEHICLE_LEAVE_TIME 25


// This defines the amount of milliseconds the game will wait after the first person finished a race, before the race will be cleaned up.
// Note: when a race is cleaned up, everyone is removed from the race and the race-slot becomes available again.
// Default: 60000
#define RACE_CLEANUP_TIME 60000


// This defines whether to remember the old position of a player, before he joins a race.
// Note: when set to true, the player will be spawned at his old position after the race finishes.
// Default: false
#define REMEMBER_OLD_POSITION false


// The amount of time in seconds a race invite will stay active.
// During this time, the invited player can't receive other invites.
// Default: 20
#define INVITE_EXPIRE 20



// -------------------------------------------------
// --- > --- > --- LIMITING SETTINGS --- < --- < ---
// -------------------------------------------------


// This is the maximum amount of public races shown in the list.
// Note: if this number is too high, it will overlap the other buttons.
// Default: 13
#define MAX_PUBLIC_RACES 13


// This is the maximum amount of private races available through the "Create private race"-button.
// Default: 25
#define MAX_PRIVATE_RACES 25


// This is the "maximum" distance a race can be in meters.
// Note: the race won't stop at this exact number, it will try to find a finish point as quickly as possible.
// Default: 30000
#define MAX_RACE_DISTANCE 30000


// This defines the minimal distance a race can be in meters.
// Default: 150
#define MIN_RACE_DISTANCE 150


// This number defines the maximum amount of checkpoints that will be saved into memory.
// Note 1: if a race exceeds this number, it will immediately spawn a finish point at the last checkpoint.
// Note 2: try to find a good balance between this number and MAX_RACE_DISTANCE.
// Default: 300
#define MAX_CHECKPOINTS 300


// This number is the maximum amount of textdraw icons that will be shown on the race menu map.
// Note: the limit seems to be somewhere around 85.
// Default: 80
#define MAX_TEXTDRAW_ICONS 80


// This is the maximum amount of contestants that are allowed to join a race.
// Note 1: this number includes the race starter! 
// Note 2: the higher the number, the more vehicles have to be spawned, the higher the chance that they'll get stuck inside buildings.
// Default: 8
#define MAX_CONTESTANTS 8


// This is the minimum amount of contestants that are required to start a race.
// Note 1: this number includes the race starter.
// Note 2: setting this number to anything below 2 will allow 1-player races.
// Default: 2
#define MIN_CONTESTANTS 2


// This is the minimum distance between checkpoints. 
// Default: 100.0
#define MINIMAL_DISTANCE_CP 100.0


// This number defines the maximum amount of map icons on the radar, which will be used to suggest the next checkpoints.
// Note 1: as of 0.3x, the limit is 100 map icons.
// Note 2: if you are using a map icon streamer, these suggested icons might not work properly.
// Default: 2
#define MAX_SUGGESTED_MAPICONS 2



// ------------------------------------------------
// --- > --- > --- VEHICLE SETTINGS --- < --- < ---
// ------------------------------------------------


// This is a list with the available vehicles during the race.
// Note: this is a very error-prone part of the script, be careful with adding other vehicles!
// Example: 415,
new RaceVehicleList[] = {
	415, // Cheetah
	411, // Infernus
	451, // Turismo
	560, // Sultan
	494, // Hotring Racer
	524, // Cement Truck
	407, // Firetruck
	444, // Monster Truck
	423, // Mr. Whoopee
	457, // Golf Caddy
	571, // Go-Kart
	594, // RC Cam
	568, // Bandito
	463, // Freeway
	461, // PCJ-600
	468, // Sanchez
	471, // Quadbike
	510, // Mountain Bike
	530, // Forklift
	539  // Vortex Hovercraft
	// Make sure the last entry doesn't have a comma! (All the other entries require a comma at the end.)
};


// This defines whether the player is allowed to pick any vehicle using their ID.
// Note 1: this only adds an extra option to the vehicle list called "Enter a specific model ID", the above list will still exist.
// Note 2: this allows the player to also spawn airplanes, helicopters or invalid vehicles like trailers!
// Default: false
#define ALLOW_ALL_VEHICLES false


// These values define the vehicle colors used on the model defined at RACE_VEHICLE_MODEL or the vehicle in the race.
// Default: -1 and -1
#define RACE_VEHICLE_COL1 -1
#define RACE_VEHICLE_COL2 -1



// --------------------------------------------------
// --- > --- > --- TECHNICAL SETTINGS --- < --- < ---
// --------------------------------------------------


// This is the PVar-tag that will be used for Player Variables.
// Note: this is used to prevent conflicts with other scripts and their variables.
// Default: "RRG_"
#define PVAR_TAG "RRG_"


// This number is the offset of the ID which will be used for dialogs.
// Note: use an unique number which doesn't come close to other IDs used in other scripts.
// Default: 1357
#define DIALOG_OFFSET 1357


// This is the offset, which will be used to create the suggested race checkpoints on the radar.
// Note 1: if this number is lower than 0 or higher than 99, the map icons might not show. (Limit of SA-MP 0.3x.)
// Note 2: the map icons IDs will start at this number. If you have 3 suggested icons (see MAX_SUGGESTED_MAPICONS), make sure this number isn't higher than 97 due to limits.
// Default: 80
#define SUGGESTED_MAPICONS_OFFSET 80



// ----------------------------------------------
// --- > --- > --- COLOR SETTINGS --- < --- < ---
// ----------------------------------------------


// This color is used for empty race slots in the race menu.
// Default: 0xFFFFFFFF (White)
#define COL_MENU_REGULAR 0xFFFFFFFF


// This color is shown when you move your mouse over a race slot in the race menu.
// Default: 0xDD8080FF (Indian/light red)
#define COL_MENU_MOUSEOVER 0xDD8080FF


// This color is used when you select one of the slots in the race menu.
// Default: 0xCF2C23FF (Firebrick/dark red)
#define COL_MENU_SELECTED 0xCF2C23FF


// This color is used for a race slot which can't be joined anymore.
// Default: 0x5B0000FF (Very dark red)
#define COL_MENU_STARTED 0x5B0000FF


// This is the color which is used for the regular chat text.
// Default: 0xFFFFFFFF (White)
#define COL_TEXT_REG 0xFFFFFFFF
#define COL_EMB_REG "{FFFFFF}"


// This is the color which is used for the winners chat text.
// Default: 0xFF3E3EFF (Just red)
#define COL_TEXT_WIN 0xFF2D2DFF
#define COL_EMB_WIN "{FF2D2D}"


// This is the color which is used for important chat, like notes and commands.
// Default: 0xFF3E3EFF (Just red)
#define COL_TEXT_IMPORTANT 0xFF6262FF
#define COL_EMB_IMPORTANT "{FF6262}"


// This is the color which is used for the chat errors.
// Default: 0xD21313FF (Firebrick/dark red)
#define COL_TEXT_ERROR 0xD21313FF // D21313
#define COL_EMB_ERROR "{D21313}"


// This color is used for the (radar) map icons which suggest the next checkpoints.
// Default: 0x5B0000FF (Very dark red)
#define COL_MAP_CP 0x5B0000FF



// -----------------------------------------------
// --- > --- > --- THE SOURCE CODE --- < --- < ---
// -----------------------------------------------

#if defined _samp_included
	#define RRG_is_include 
#else
	#include <a_samp>
#endif

#if defined RRG_is_include
	#if defined RRG_included
		#endinput
	#endif
	#define RRG_included
#endif

#define RRG_VERSION "v1.2.1"

#include <RouteConnector>

#define REQUIRED_INC_VERSION (184)
#define REQUIRED_PLUGIN_VERSION (184)

#if (INCLUDE_VERSION < REQUIRED_INC_VERSION)
	#error <Invalid include version> Please update RouteConnector.inc from the RouteConnector plugin!
#endif

#if defined MAX_RACES
	#if !defined MAX_PUBLIC_RACES
		#define MAX_PUBLIC_RACES MAX_RACES
	#endif
	
	#undef MAX_RACES
#endif

#define MAX_RACES MAX_PUBLIC_RACES + MAX_PRIVATE_RACES

enum eRaceInfo
{
	rHost,
	rVehicleModel,
	rStarted,
	rPlayerAmount,
	rCPAmount,
	rFinishedPlayers,
	Float: rDistance,
	rEndTimer
}

new raceInfo[MAX_RACES][eRaceInfo];
new racePeopleInRace[MAX_RACES][MAX_CONTESTANTS][2];
new Float: raceCheckpointList[MAX_RACES][MAX_CHECKPOINTS + 2][3];
new Text: raceMapIcons[MAX_RACES][MAX_TEXTDRAW_ICONS];
new amountOfPrivateRaces = 0;

new Text: joinMenuButtons[3] = {Text: INVALID_TEXT_DRAW, ...};
new Text: joinMenuSlots[MAX_RACES] = {Text: INVALID_TEXT_DRAW, ...};
new Text: joinMenuPrivate = Text: INVALID_TEXT_DRAW;
new Text: joinMenuRaceInfo[MAX_RACES][3];
new Text: joinMenuExtra[4] = {Text: INVALID_TEXT_DRAW, ...};

#define MENU_X 50.0
#define MENU_Y 145.0

#define MAX_VEHICLE_NAME 25
new const VehicleNames[][MAX_VEHICLE_NAME char] = {
	!"Landstalker", !"Bravura", !"Buffalo", !"Linerunner", !"Perennial", !"Sentinel", !"Dumper", !"Firetruck", !"Trashmaster", !"Stretch", !"Manana", !"Infernus", !"Voodoo", !"Pony", !"Mule",
	!"Cheetah", !"Ambulance", !"Leviathan", !"Moonbeam", !"Esperanto", !"Taxi", !"Washington", !"Bobcat", !"Mr Whoopee", !"BF Injection", !"Hunter", !"Premier", !"Enforcer", !"Securicar", !"Banshee",
	!"Predator", !"Bus", !"Rhino", !"Barracks", !"Hotknife", !"Closed Trailer A", !"Previon", !"Coach", !"Cabbie", !"Stallion", !"Rumpo", !"RC Bandit",	"Romero", !"Packer", !"Monster", !"Admiral", 
	!"Squalo", !"Seasparrow", !"Pizzaboy", !"Tram", !"Open Trailer", !"Turismo", !"Speeder", !"Reefer", !"Tropic", !"Flatbed", !"Yankee", !"Caddy", !"Solair", !"Berkley's RC Van",	!"Skimmer", 
	!"PCJ-600", !"Faggio", !"Freeway", !"RC Baron", !"RC Raider", !"Glendale", !"Oceanic", !"Sanchez", !"Sparrow", !"Patriot", !"Quad", !"Coastguard", !"Dinghy", !"Hermes", !"Sabre", 
	!"Rustler", !"ZR-350", !"Walton", !"Regina", !"Comet", !"BMX", !"Burrito", !"Camper", !"Marquis", !"Baggage", !"Dozer", !"Maverick", !"News Chopper", !"Rancher", !"FBI Rancher", 
	!"Virgo", !"Greenwood", !"Jetmax", !"Hotring", !"Sandking", !"Blista Compact", !"Police Maverick", !"Boxville", !"Benson", !"Mesa", !"RC Goblin", !"Hotring Racer A", !"Hotring Racer B", !"Bloodring Banger", 
	!"Lure Rancher", !"Super GT", !"Elegant", !"Journey", !"Bike", !"Mountain Bike", !"Beagle", !"Cropdust", !"Stuntplane", !"Petrol Trailer", !"Roadtrain", !"Nebula", !"Majestic", !"Buccaneer", !"Shamal",
	!"Hydra", !"FCR-900", !"NRG-500", !"HPV1000", !"Cement Truck", !"Tow Truck", !"Fortune", !"Cadrona", !"FBI Truck", !"Willard", !"Forklift", !"Tractor", !"Combine", !"Feltzer", !"Remington",
	!"Slamvan", !"Blade", !"Freight", !"Brown Streak", !"Vortex", !"Vincent", !"Bullet", !"Clover", !"Sadler", !"Firetruck LA", !"Hustler", !"Intruder", !"Primo", !"Cargobob", !"Tampa", !"Sunrise",
	!"Merit", !"Utility", !"Nevada", !"Yosemite", !"Windsor", !"Monster A", !"Monster B", !"Uranus", !"Jester", !"Sultan", !"Stratum", !"Elegy", !"Raindance", !"RC Tiger", !"Flash", !"Tahoma", !"Savanna",
	!"Bandito", !"Freight Flat", !"Brown Streak Carriage", !"Kart", !"Mower", !"Duneride", !"Sweeper", !"Broadway", !"Tornado", !"AT-400", !"DFT-30", !"Huntley", !"Stafford", !"BF-400", !"Newsvan",
	!"Tug", !"Petrol Trailer", !"Emperor", !"Wayfarer", !"Euros", !"Hotdog", !"Club", !"Freight Carriage", !"Closed Trailer B", !"Andromada", !"Dodo", !"RC Cam", !"Launch", !"LSPD Police", !"SFPD Police",
	!"LVPD Police", !"Police Ranger", !"Picador", !"S.W.A.T. Van", !"Alpha", !"Phoenix", !"Ghost Glendale", !"Ghost Sadler", !"Baggage Trailer A", !"Baggage Trailer B", !"Stairs Trailer", !"Black Boxville",
	!"Farm Plow", !"Utility Trailer"
};
new vehListStr[(sizeof(RaceVehicleList) + 1) * (MAX_VEHICLE_NAME + 2)];

#if defined RRG_is_include
	public OnGameModeInit() return onScriptInit(), CallLocalFunction("RRG_OnGameModeInit", "");
	public OnFilterScriptInit() return onScriptInit(), CallLocalFunction("RRG_OnFilterScriptInit", "");
	public OnGameModeExit() return onScriptExit(), CallLocalFunction("RRG_OnGameModeExit", "");
	public OnFilterScriptExit() return onScriptExit(), CallLocalFunction("RRG_OnFilterScriptInit", "");
#else
	public OnGameModeInit() return onScriptInit();
	public OnFilterScriptInit() return onScriptInit();
	public OnGameModeExit() return onScriptExit();
	public OnFilterScriptExit() return onScriptExit();
#endif
new bool: scriptLoaded = false;

main() {}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
onScriptInit()
{
	// To prevent the script from loading the same stuff twice:
	if (scriptLoaded == true) return 1;
	scriptLoaded = true;
	
	// Error checking with plugin or files
	if (GetPluginVersion() < REQUIRED_PLUGIN_VERSION)
	{
		print("\n");
		print(" [!] RRG Notice: the RouteConnector plugin is outdated. Please update it if you want to avoid problems!\n");
	}
	
	new GPSversion = GetGPSdatVersion();
	if (GPSversion == -1 || GPSversion == 0)
	{
		print("\n");
		print(" [!] RRG Notice: GPS.dat has not been found. Please update your RouteConnector plugin or load a file containing nodes!\n");
	}
	
	// TD - background
	joinMenuExtra[0] = TextDrawCreate(MENU_X, MENU_Y, "_");
	TextDrawUseBox(joinMenuExtra[0], true);
	TextDrawLetterSize(joinMenuExtra[0], 1.0, 30.0);
	TextDrawBoxColor(joinMenuExtra[0], 0x77);
	TextDrawTextSize(joinMenuExtra[0], MENU_X + 540.0, MENU_Y + 255.0);

	// TD - map
	joinMenuExtra[1] = TextDrawCreate(MENU_X + 150.0, MENU_Y + 10.0, "samaps:map");
	TextDrawFont(joinMenuExtra[1], 4);
	TextDrawTextSize(joinMenuExtra[1], 250.0, 250.0);
	
	// TD - title
	joinMenuExtra[2] = TextDrawCreate(320.0, MENU_Y - 18.0, "Random Race Generator");
	TextDrawFont(joinMenuExtra[2], 0);
	TextDrawLetterSize(joinMenuExtra[2], 1.3, 3.5); // 1.0, 2.75
	TextDrawSetOutline(joinMenuExtra[2], 2);
	TextDrawAlignment(joinMenuExtra[2], 2);
	
	// TD - description
	joinMenuExtra[3] = TextDrawCreate(MENU_X + 410.0, MENU_Y + 19.0, \
		"Welcome to the...~n~Random Race Generator!~n~~n~"\
		"You can create or join a race by selecting one of the slots on the left.~n~~n~"\
		"Each race is randomly generated along the roads of San Andreas; no race is the same as the last one.~n~~n~"\
		"The map will show you the current race track of each slot and more information about each race will be shown in this box."\
		" ______________________________ Have fun!");
	TextDrawColor(joinMenuExtra[3], COL_MENU_REGULAR);
	TextDrawTextSize(joinMenuExtra[3], MENU_X + 530.0, 500.0);
	TextDrawLetterSize(joinMenuExtra[3], 0.25, 1.2);
	TextDrawSetOutline(joinMenuExtra[3], 1);
	
	// TD - buttons
	joinMenuButtons[0] = TextDrawCreate(MENU_X + 10.0, MENU_Y + 245.0, " Create");
	joinMenuButtons[1] = TextDrawCreate(MENU_X + 10.0, MENU_Y + 245.0, " Join");
	joinMenuButtons[2] = TextDrawCreate(MENU_X + 80.0, MENU_Y + 245.0, " Close");
	
	for (new b; b < sizeof(joinMenuButtons); b++) // same looks for all buttons
	{
		TextDrawColor(joinMenuButtons[b], COL_MENU_REGULAR);
		TextDrawLetterSize(joinMenuButtons[b], 0.4, 1.5);
		TextDrawSetOutline(joinMenuButtons[b], 1);
		TextDrawUseBox(joinMenuButtons[b], true);
		TextDrawBoxColor(joinMenuButtons[b], 0x55);
		if (b == 2)
		{
			TextDrawTextSize(joinMenuButtons[b], MENU_X + 140.0, 12.0);
		}
		else
		{
			TextDrawTextSize(joinMenuButtons[b], MENU_X + 70.0, 12.0);
		}
		TextDrawSetSelectable(joinMenuButtons[b], true);
	}
	
	// TD - private race button
	joinMenuPrivate = TextDrawCreate(MENU_X + 10.0, MENU_Y + 19.0 + float(MAX_PUBLIC_RACES * 15), "<0/"#MAX_PRIVATE_RACES"> Create private race!");
	TextDrawColor(joinMenuPrivate, COL_MENU_REGULAR);
	TextDrawLetterSize(joinMenuPrivate, 0.25, 1.2);
	TextDrawSetOutline(joinMenuPrivate, 1);
	TextDrawTextSize(joinMenuPrivate, MENU_X + 155.0, 12.0);
	TextDrawSetSelectable(joinMenuPrivate, true);

	// TD - public race buttons
	for (new s; s < MAX_RACES; s++)
	{
		if (s < MAX_PUBLIC_RACES)
		{
			joinMenuSlots[s] = TextDrawCreate(MENU_X + 10.0, MENU_Y + 19.0 + float(s * 15), "<Empty> Create a race!");
			TextDrawColor(joinMenuSlots[s], COL_MENU_REGULAR);
			TextDrawLetterSize(joinMenuSlots[s], 0.25, 1.2);
			TextDrawSetOutline(joinMenuSlots[s], 1);
			TextDrawTextSize(joinMenuSlots[s], MENU_X + 155.0, 12.0);
			TextDrawSetSelectable(joinMenuSlots[s], true);
		}
		else
		{
			joinMenuSlots[s] = Text: INVALID_TEXT_DRAW;
		}
		
		raceInfo[s][rHost] = INVALID_PLAYER_ID;
		raceInfo[s][rEndTimer] = -1;
		
		for (new p; p < MAX_CONTESTANTS; p++)
		{
			racePeopleInRace[s][p][0] = INVALID_PLAYER_ID;
		}
		for (new t; t < sizeof(joinMenuRaceInfo[]); t++)
		{
			joinMenuRaceInfo[s][t] = Text: INVALID_TEXT_DRAW;
		}
		for (new i; i < MAX_TEXTDRAW_ICONS; i++)
		{
			raceMapIcons[s][i] = Text: INVALID_TEXT_DRAW;		
		}
	}
	
	// Dialog - race vehicles list
	for (new v; v < sizeof(RaceVehicleList); v++)
	{
		strcat(vehListStr, VehicleNames[RaceVehicleList[v] - 400]);
		strcat(vehListStr, "\n");
	}	
	#if ALLOW_ALL_VEHICLES == true
		strcat(vehListStr, "Enter a specific model ID");
	#endif
	
	// Loading finished
	print("\n");
	#if defined RRG_is_include
		print("Random Race Generator "RRG_VERSION" loaded succesfully. (include version)\n");
	#else
		print("Random Race Generator "RRG_VERSION" loaded succesfully.\n");
	#endif
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onScriptExit()
{
	scriptLoaded = false;
	
	// Destroy all the textdraws:
	for (new b; b < sizeof(joinMenuButtons); b++)
	{
		TextDrawHideForAll(joinMenuButtons[b]);
		TextDrawDestroy(joinMenuButtons[b]);
	}
	for (new e; e < sizeof(joinMenuExtra); e++)
	{
		TextDrawHideForAll(joinMenuExtra[e]);
		TextDrawDestroy(joinMenuExtra[e]);
	}
	for (new s; s < MAX_RACES; s++)
	{
		cleanRace(s);
		TextDrawHideForAll(joinMenuSlots[s]);
		TextDrawDestroy(joinMenuSlots[s]);
		
		for (new r; r < sizeof(joinMenuRaceInfo[]); r++)
		{
			TextDrawHideForAll(joinMenuRaceInfo[s][r]);
			TextDrawDestroy(joinMenuRaceInfo[s][r]);
		}
		
		for (new i; i < MAX_TEXTDRAW_ICONS; i++)
		{
			if (raceMapIcons[s][i] != Text: INVALID_TEXT_DRAW)
			{
				TextDrawHideForAll(raceMapIcons[s][i]);
				TextDrawDestroy(raceMapIcons[s][i]);
				raceMapIcons[s][i] = Text: INVALID_TEXT_DRAW;
			}
		}
	}
	for (new p, m = GetPlayerPoolSize(); p < m; p++)
	{
		removeText(p);
		DeletePVar(p, PVAR_TAG"exitVehTimer");
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	// Respawn the player after they've died:
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (race)
	{
		race -= 2;
		if (raceInfo[race][rHost] != INVALID_PLAYER_ID)
		{
			respawnPlayer(playerid, race);
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerSpawn", "i", playerid);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnPlayerDisconnect(playerid, reason)
{
	// Message everyone that the race has been canceled:
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (race)
	{
		race -= 2;
		if (raceInfo[race][rHost] == playerid)
		{
			for (new p; p < MAX_CONTESTANTS; p++)
			{
				if (racePeopleInRace[race][p][0] != INVALID_PLAYER_ID && racePeopleInRace[race][p][0] != playerid)
				{
					SendClientMessage(racePeopleInRace[race][p][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"The race you had participated in has been called off.");
				}
			}
		}
	}
	
	// Remove player from race and cancel race if necessary:
	#if REMEMBER_OLD_POSITION == true
		removePlayerFromRace(playerid, false);
	#else
		removePlayerFromRace(playerid);
	#endif
	
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerDisconnect", "ii", playerid, reason);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnVehicleDeath(vehicleid, killerid)
{
	// Check if vehicle was a race vehicle
	for (new p, mp = GetPlayerPoolSize(); p < mp; p++)
	{
		if (IsPlayerConnected(p) && !IsPlayerNPC(p))
		{
			new race = GetPVarInt(p, PVAR_TAG"currentRaceID");
			if (race)
			{
				race -= 2;
				if (raceInfo[race][rHost] != INVALID_PLAYER_ID)
				{
					if (GetPVarInt(p, PVAR_TAG"currentVehID") == vehicleid)
					{
						new Float: health;
						GetPlayerHealth(p, health);
						if (health > 0)
						{
							respawnPlayer(p, race);
						}
						break;
					}
				}
			}
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnVehicleDeath", "ii", vehicleid, killerid);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#if !defined RRG_DisableCommands
public OnPlayerCommandText(playerid, cmdtext[])
{
	// First: check if one of the RRG-commands is typed.
	if (!strcmp(cmdtext, "/rrg", true, 4)) 
	{	
		new subcmd[32];
		strmid(subcmd, cmdtext, 5, cellmax);
		
		if (cmdtext[4] == ' ' && subcmd[0])
		{
			// This command shows the join menu with the map.
			if (!strcmp(subcmd, "menu", true) || !strcmp(subcmd, "join", true))
			{
				showJoinMenuForPlayer(playerid);
				return 1;
			}
			
			// This command allows the player to respawn during the race.
			if (!strcmp(cmdtext[5], "respawn", true))
			{
				new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
				if (race)
				{
					race -= 2;
					if (raceInfo[race][rStarted] != 2)
					{
						return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You cannot respawn right now! The race has not started yet.");
					}

					if (GetPVarInt(playerid, PVAR_TAG"isFinished"))
					{
						return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You cannot respawn anymore! You have already finished.");
					}
					respawnPlayer(playerid, race);
				}
				else
				{
					SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are not om a race right now!");
				}
				return 1;	
			}
			
			// This command allows the player to leave a race
			if (!strcmp(subcmd, "leave", true))
			{
				new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
				if (race && raceInfo[race - 2][rHost] == playerid) // If the player is host
				{
					race -= 2;
					
					if (removePlayerFromRace(playerid) == 1) // Race has been ended and no host was found
					{
						SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You have called off the race.");
						
						for (new p; p < MAX_CONTESTANTS; p++)
						{
							if (racePeopleInRace[race][p][0] != INVALID_PLAYER_ID && racePeopleInRace[race][p][0] != raceInfo[race][rHost])
							{
								SendClientMessage(racePeopleInRace[race][p][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"The race you are participating in has been called off.");
							}
						}
					}
				}
				else // If the player is a contestant (not the host)
				{
					if (race)
					{
						SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You have left the race.");
					}
					else
					{
						return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are currently not in a race.");
					}
					removePlayerFromRace(playerid);
				}
				return 1;
			}
			
			// This allows people to invite other players (especially useful for private races)
			if (!strcmp(subcmd, "invite", true, 6))
			{	
				new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
				if (!race)
				{
					return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are currently not in a race.");
				}
				race -= 2;
				
				
				if (subcmd[6] != ' ' || !subcmd[7])
				{
					return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: Correct usage: '/rrg invite [name]'.");
				}
				
				new invitename[MAX_PLAYER_NAME + 2];
				strmid(invitename, subcmd, 7, cellmax);
				
				// Search for a player with the given name
				new lastplayer = INVALID_PLAYER_ID, amountfound;
				for (new p, m = GetPlayerPoolSize(); p < m; p++)
				{
					if (IsPlayerConnected(p) && !IsPlayerNPC(p))
					{
						new pName[MAX_PLAYER_NAME];
						GetPlayerName(p, pName, MAX_PLAYER_NAME);
						if (strfind(pName, invitename, true) != -1)
						{
							amountfound++;
							if (amountfound == 1)
							{
								lastplayer = p;
							}
						}
					}
				}
				
				switch (amountfound)
				{
					case 0: // No players were found with the given name.
					{
						return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: No player in this server matches the given name.");
					}
					case 1: // One player was found with the given name, thus try to send an invite.
					{
						if (playerid == lastplayer)
						{
							return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You cannot invite yourself.");
						}
						
						// Already invited?
						new curinvite = GetPVarInt(lastplayer, PVAR_TAG"currentInviteID"); 
						if (curinvite)
						{
							curinvite--;
							if (GetPVarInt(lastplayer, PVAR_TAG"currentInviteTime") >= gettime())
							{
								if (curinvite == playerid)
								{
									return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You have already invited the given player.");
								}
								else
								{
									return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: The given player has already received another invite.");
								}
							}
							
						}
						
						// Already racing?
						new otherrace = GetPVarInt(lastplayer, PVAR_TAG"currentRaceID"); 
						if (otherrace)
						{
							otherrace -= 2;
							if (otherrace == race)
							{
								return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: The given player is already in this race.");
							}
							else
							{
								return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: The given player is already in another race.");
							}				
						}
						
						// Send invite!
						new str[128], pName[MAX_PLAYER_NAME], len;
						len = GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
						
						if (raceInfo[race][rHost] == playerid)
						{
							switch (pName[len - 1])
							{
								case 's', 'z', 'S', 'Z': format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have been invited to join %s' race.", pName);
								default: format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have been invited to join %s's race.", pName);
							}
						}
						else
						{
							new hName[MAX_PLAYER_NAME];
							len = GetPlayerName(raceInfo[race][rHost], hName, MAX_PLAYER_NAME);
							
							switch (pName[len - 1])
							{
								case 's', 'z', 'S', 'Z': format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have been invited by %s to join %s' race.", pName, hName);
								default: format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have been invited by %s to join %s's race. ", pName, hName);
							}
						}
						
						SendClientMessage(lastplayer, COL_TEXT_ERROR, str);
						SendClientMessage(lastplayer, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"Use '"COL_EMB_IMPORTANT"/rrg showinvite"COL_EMB_REG"' to accept or decline it. The invite will expire in "#INVITE_EXPIRE" seconds.");
						SetPVarInt(lastplayer, PVAR_TAG"currentInviteID", playerid + 1);
						SetPVarInt(lastplayer, PVAR_TAG"currentInviteTime", gettime() + INVITE_EXPIRE);
						
						GetPlayerName(lastplayer, pName, MAX_PLAYER_NAME);
						format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have invited %s to join your race.", pName);
						SendClientMessage(playerid, COL_TEXT_IMPORTANT, str);
					}
					default: // More than one player was found with the given name
					{
						return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: More than one player in this server matches the given name. Be more specific!");
					}
				}
				return 1;
			}
			
			// Shows an invite to the player if he or she received one.
			if (!strcmp(subcmd, "showinvite", true))
			{
				new invitetime = GetPVarInt(playerid, PVAR_TAG"currentInviteTime"), invitingplayer = GetPVarInt(playerid, PVAR_TAG"currentInviteID");
				
				if (invitetime >= gettime())
				{
					if (invitingplayer)
					{
						invitingplayer--;
						
						new race = GetPVarInt(invitingplayer, PVAR_TAG"currentRaceID");
						if (!race)
						{
							DeletePVar(playerid, PVAR_TAG"currentInviteID");
							DeletePVar(playerid, PVAR_TAG"currentInviteTime");
							
							SendClientMessage(playerid, COL_TEXT_REG, " [!] ERROR: The invite you received is not valid anymore. Invite has been removed.");
							return 1;
						}						
						race -= 2;
						
						new dialogTitle[MAX_PLAYER_NAME + 24], dialogStr[255], pName[MAX_PLAYER_NAME], len, vehicleName[MAX_VEHICLE_NAME];
						len = GetPlayerName(invitingplayer, pName, MAX_PLAYER_NAME);
						format(dialogTitle, sizeof(dialogTitle), "{FFFFFF}Invite from %s", pName);
						if (raceInfo[race][rVehicleModel])
						{
							strunpack(vehicleName, VehicleNames[raceInfo[race][rVehicleModel] - 400]);
						}
						else
						{
							DeletePVar(playerid, PVAR_TAG"currentInviteID");
							DeletePVar(playerid, PVAR_TAG"currentInviteTime");
							return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured while showing invite. (Reference ID: 011) Race vehicle model could not be found.");
						}
						
						// Make dialog text based on if the inviting player is the host of the race or not.
						if (raceInfo[race][rHost] == invitingplayer)
						{
							switch (pName[len - 1])
							{
								case 's', 'z', 'S', 'Z': 
								{
									format(dialogStr, sizeof(dialogStr),\
									"{FFFFFF}You have been invited to join %s' race.\n\n{CF2C23}Vehicle:{FFFFFF} %s\n{CF2C23}Length:{FFFFFF} %.1f meters\n{CF2C23}Checkpoints{FFFFFF}: %i\n{CF2C23}Host:{FFFFFF} %s\n\nDo you want to accept or decline this invite?",\
									pName, vehicleName, raceInfo[race][rDistance], raceInfo[race][rCPAmount], pName);
								}
								default:
								{
									format(dialogStr, sizeof(dialogStr),\
									"{FFFFFF}You have been invited to join %s's race.\n\n{CF2C23}Vehicle:{FFFFFF} %s\n{CF2C23}Length:{FFFFFF} %.1f meters\n{CF2C23}Checkpoints{FFFFFF}: %i\n{CF2C23}Host:{FFFFFF} %s\n\nDo you want to accept or decline this invite?",\
									pName, vehicleName, raceInfo[race][rDistance], raceInfo[race][rCPAmount], pName);
								}
							}
						}
						else
						{
							new hName[MAX_PLAYER_NAME];
							len = GetPlayerName(raceInfo[race][rHost], hName, MAX_PLAYER_NAME);
							
							switch (hName[len - 1])
							{
								case 's', 'z', 'S', 'Z': 
								{
									format(dialogStr, sizeof(dialogStr),\
									"{FFFFFF}You have been invited by %s to join %s' race.\n\n{CF2C23}Vehicle:{FFFFFF} %s\n{CF2C23}Length:{FFFFFF} %.1f meters\n{CF2C23}Checkpoints:{FFFFFF} %i\n{CF2C23}Host:{FFFFFF} %s\n\nDo you want to accept or decline this invite?",\
									pName, hName, vehicleName, raceInfo[race][rDistance], raceInfo[race][rCPAmount], hName);
								}
								default:
								{
									format(dialogStr, sizeof(dialogStr),\
									"{FFFFFF}You have been invited by %s to join %s's race.\n\n{CF2C23}Vehicle:{FFFFFF} %s\n{CF2C23}Length:{FFFFFF} %.1f meters\n{CF2C23}Checkpoints:{FFFFFF} %i\n{CF2C23}Host:{FFFFFF} %s\n\nDo you want to accept or decline this invite?",\
									pName, hName, vehicleName, raceInfo[race][rDistance], raceInfo[race][rCPAmount], hName);
								}
							}
						
						}
						SetPVarInt(playerid, PVAR_TAG"currentInviteTime", cellmax);
						ShowPlayerDialog(playerid, DIALOG_OFFSET + 3, 0, dialogTitle, dialogStr, "Accept", "Decline");
					}
					else
					{
						DeletePVar(playerid, PVAR_TAG"currentInviteID");
						DeletePVar(playerid, PVAR_TAG"currentInviteTime");
						return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured while showing invite. (Reference ID: 010) The inviting player ID could not be found.");
					}
				}
				else // If the invite has expired
				{
					if (invitetime && invitingplayer)
					{
						DeletePVar(playerid, PVAR_TAG"currentInviteID");
						DeletePVar(playerid, PVAR_TAG"currentInviteTime");
						
						new str[128], pName[MAX_PLAYER_NAME];
						GetPlayerName(invitingplayer - 1, pName, MAX_PLAYER_NAME);
						format(str, sizeof(str), " [!] ERROR: The invite you received from %s has expired.", pName);
						SendClientMessage(playerid, COL_TEXT_ERROR, str);
					}
					else
					{
						SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You do not have an invite to show.");
					}
				}
				return 1;
			}
			
			// This command allows the host to start a race
			if (!strcmp(subcmd, "start", true))
			{
				new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
				if (!race)
				{
					SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You have not created a race yet.");
					return 1;
				}
				
				race -= 2;
				if (raceInfo[race][rHost] != playerid)
				{
					SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You have not created this race.");
					return 1;
				}
				
				if (raceInfo[race][rStarted])
				{
					SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: This race has already started.");
					return 1;
				}
				
				if (raceInfo[race][rPlayerAmount] < MIN_CONTESTANTS)
				{
					SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: To start this race, there needs to be at least "#MIN_CONTESTANTS" contestants.");
					return 1;
				}
				
				startRace(race);
				return 1;
			}
		}
		
		// The help command gets triggered if '/rrg' or '/rrg help' is typed.
		if (cmdtext[4] == '\0' || (cmdtext[4] == ' ' && (cmdtext[5] == '\0' || !strcmp(subcmd, "help", true))))
		{
			SendClientMessage(playerid, COL_TEXT_REG, " ");
			SendClientMessage(playerid, COL_TEXT_WIN, " - - - Random Race Generator [Help] - - -");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg help ................\tshows this command list.");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg menu ..............\tshows the race list (join & create).");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg respawn .........\trespawns you during the race.");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg leave ...............\tleave the current race.");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg start ...............\tstart the race countdown (as host).");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg invite [name] ...\tinvite another player (as host).");
			SendClientMessage(playerid, COL_TEXT_REG, "/rrg showinvite ......\tshows the current invite.");
			return 1;
		}
		
		// Error if the sub-text is something different.
		if (cmdtext[4] == ' ')
		{
			SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: This RRG-command does not exist. See all available commands with '/rrg help'.");
			return 1;
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerCommandText", "is", playerid, cmdtext);
	#else
		return 0;
	#endif
}
#endif

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	new menuopen = GetPVarInt(playerid, PVAR_TAG"joinMenuOpen");
	if (menuopen)
	{
		menuopen -= 2;
		// If player clicked ESC (allows other filterscripts to register this action too)
		if (clickedid == Text: INVALID_TEXT_DRAW) 
		{
			hideJoinMenu(playerid);
			return 0;
		}
		
		// If player clicked "Close"
		if (clickedid == Text: joinMenuButtons[2]) 
		{
			hideJoinMenu(playerid);	
			return 1;
		}
		
		// If one of the slots has already been selected previously:
		if (menuopen != -1)
		{
			// If player clicked "Create"
			if (clickedid == Text: joinMenuButtons[0] && raceInfo[menuopen][rHost] == INVALID_PLAYER_ID) 
			{
				CancelSelectTextDraw(playerid);
				createRace(playerid, menuopen);
				return 1;
			}
			
			// If player clicked "Join"
			if (clickedid == Text: joinMenuButtons[1] && raceInfo[menuopen][rHost] != INVALID_PLAYER_ID) 
			{
				CancelSelectTextDraw(playerid);
				putPlayerInRace(playerid, menuopen);
				return 1;
			}
			
			// Unselect last button (remove their red selected color)
			if (clickedid != joinMenuSlots[menuopen]) 
			{
				if (raceInfo[menuopen][rStarted] == 2)
				{
					TextDrawColor(joinMenuSlots[menuopen], COL_MENU_STARTED);
				}
				else
				{
					TextDrawColor(joinMenuSlots[menuopen], COL_MENU_REGULAR);
				}
				TextDrawShowForPlayer(playerid, joinMenuSlots[menuopen]);
				
				for (new t; t < sizeof(joinMenuRaceInfo[]); t++)
				{
					TextDrawHideForPlayer(playerid, joinMenuRaceInfo[menuopen][t]);
				}
				
				for (new c; c < MAX_TEXTDRAW_ICONS; c++)
				{
					if (raceMapIcons[menuopen][c] != Text: INVALID_TEXT_DRAW)
					{
						TextDrawHideForPlayer(playerid, raceMapIcons[menuopen][c]);
					}
				}
			}
		}
		
		// If player clicked the private race slot (while not in a private race)
		if (GetPVarInt(playerid, PVAR_TAG"currentRaceID") - 2 < MAX_PUBLIC_RACES)
		{
			if (clickedid == joinMenuPrivate)
			{
				SetPVarInt(playerid, PVAR_TAG"joinMenuOpen", MAX_PUBLIC_RACES + 2);
				TextDrawColor(joinMenuPrivate, COL_MENU_SELECTED);
				TextDrawShowForPlayer(playerid, joinMenuPrivate);
				
				TextDrawShowForPlayer(playerid, joinMenuButtons[0]);
				TextDrawHideForPlayer(playerid, joinMenuButtons[1]);
				TextDrawShowForPlayer(playerid, joinMenuExtra[3]);
			}
			else if (menuopen == MAX_PUBLIC_RACES)// Deselect it
			{
				TextDrawColor(joinMenuPrivate, COL_MENU_REGULAR);
				TextDrawShowForPlayer(playerid, joinMenuPrivate);
			}
		}
		
		// If clicked one of the public race slot
		for (new i; i < MAX_RACES; i++) 
		{
			if (clickedid == joinMenuSlots[i] && menuopen != i)
			{
				SetPVarInt(playerid, PVAR_TAG"joinMenuOpen", i + 2);
				TextDrawColor(joinMenuSlots[i], COL_MENU_SELECTED);
				TextDrawShowForPlayer(playerid, joinMenuSlots[i]);
				
				// Show "Create" if there is no race
				if (raceInfo[i][rHost] == INVALID_PLAYER_ID)
				{
					TextDrawShowForPlayer(playerid, joinMenuButtons[0]);
					TextDrawHideForPlayer(playerid, joinMenuButtons[1]);
					TextDrawShowForPlayer(playerid, joinMenuExtra[3]);
				}
				else // Show "Join" if there is a race
				{
					TextDrawHideForPlayer(playerid, joinMenuButtons[0]);
					TextDrawShowForPlayer(playerid, joinMenuButtons[1]);
					
					// Show all the Race Info TD's
					new bool: showdesc = true;
					for (new t; t < sizeof(joinMenuRaceInfo[]); t++)
					{
						if (joinMenuRaceInfo[i][t] != Text: INVALID_TEXT_DRAW)
						{
							TextDrawShowForPlayer(playerid, joinMenuRaceInfo[i][t]);
							showdesc = false;
						}
					}
					
					// Show default description if there is no race
					if (showdesc)
					{
						TextDrawShowForPlayer(playerid, joinMenuExtra[3]);
					}
					else // Show map icons if there is a race
					{						
						TextDrawHideForPlayer(playerid, joinMenuExtra[3]);
						for (new c; c < MAX_TEXTDRAW_ICONS; c++)
						{
							if (raceMapIcons[i][c] != Text: INVALID_TEXT_DRAW)
							{
								TextDrawShowForPlayer(playerid, raceMapIcons[i][c]);
							}
						}
					}
				}
				return 1;
			}
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerClickTextdraw", "ii", playerid, _:clickedid);
	#else
		return 0;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_OFFSET: // Choose a race length
		{
			// If creation is canceled
			if (!response) 
			{
				DeletePVar(playerid, PVAR_TAG"closestNode");
				DeletePVar(playerid, PVAR_TAG"currentRaceID");
				DeletePVar(playerid, PVAR_TAG"selectedVehicle");
				TogglePlayerControllable(playerid, true);
				return 1;
			}
			
			// Retrieve closest node ID
			new closestNode = GetPVarInt(playerid, PVAR_TAG"closestNode");
			if (closestNode == -1)
			{
				SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 001) The race has been reset.");
				DeletePVar(playerid, PVAR_TAG"currentRaceID");
				DeletePVar(playerid, PVAR_TAG"selectedVehicle");
				return 1;
			}
			
			// Retrieve input value
			new value = strval(inputtext);
			if (MIN_RACE_DISTANCE > value || value > MAX_RACE_DISTANCE)
			{
				return ShowPlayerDialog(playerid, DIALOG_OFFSET, 1, "Maximum length", "Please input the maximum length of the race in meters.\n\nERROR: The number must be between "#MIN_RACE_DISTANCE" and "#MAX_RACE_DISTANCE"!", "Generate", "Cancel");		
			}
			DeletePVar(playerid, PVAR_TAG"closestNode");
			
			// Check if slot got filled in the mean time
			new slot = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
			if (slot)
			{
				slot -= 2;
				if (raceInfo[slot][rHost] != INVALID_PLAYER_ID)
				{
					// Check if private race
					new minr = MAX_PUBLIC_RACES, maxr = MAX_RACES, bool: privaterace = true;
					if (0 <= slot < MAX_PUBLIC_RACES)
					{
						minr = 0;
						maxr = MAX_PUBLIC_RACES;
						privaterace = false;
					}				
					
					// Get first empty slot
					new freeRace = -1;
					for (new r = minr; r < maxr; r++)
					{
						if (raceInfo[r][rHost] == INVALID_PLAYER_ID)
						{
							freeRace = r;
							break;
						}
					}
					
					// If no empty slot left, cancel race creation.. :(
					if (freeRace == -1)
					{
						if (privaterace)
						{
							SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: It's not possible to create more private races at the moment!");
						}
						else
						{
							SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: It's not possible to create more public races at the moment!");
						}
						DeletePVar(playerid, PVAR_TAG"currentRaceID");
						DeletePVar(playerid, PVAR_TAG"selectedVehicle");
						return 1;
					}
					
					// If another slot is empty; save new slot ID
					slot = freeRace;
					SetPVarInt(playerid, PVAR_TAG"currentRaceID", slot + 2);
				}
			}
			else
			{
				// Error if slot ID does not exist
				SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 003) The race has been reset.");
				DeletePVar(playerid, PVAR_TAG"currentRaceID");
				DeletePVar(playerid, PVAR_TAG"selectedVehicle");
				return 1;
			}
			
			// Save race info and start calculating
			SetPVarFloat(playerid, PVAR_TAG"totalRaceDistance", float(value));
			
			raceInfo[slot][rHost] = playerid;
			calculateNextRacePart(slot, 0, closestNode, true);
			return 1;
		}
		case DIALOG_OFFSET + 1: // Pick a vehicle (list)
		{
			// If canceled, stop race creation
			if (!response) 
			{
				DeletePVar(playerid, PVAR_TAG"closestNode");
				DeletePVar(playerid, PVAR_TAG"currentRaceID");
				TogglePlayerControllable(playerid, true);
				return 1;
			}
			
			// If the 'all vehicles allowed' entry exists, allow a new dialog to set the ID
			#if ALLOW_ALL_VEHICLES == true
				if (listitem == sizeof(RaceVehicleList))
				{
					ShowPlayerDialog(playerid, DIALOG_OFFSET + 2, 1, "Vehicle model", "Please input a vehicle model ID ranging from 400 to 611.", "Pick", "Cancel");
					return 1;
				}
			#endif
			
			// Save race vehicle and open distance dialog
			SetPVarInt(playerid, PVAR_TAG"selectedVehicle", RaceVehicleList[listitem]);		
			ShowPlayerDialog(playerid, DIALOG_OFFSET, 1, "Maximum length", "Please input the maximum length of the race in meters.", "Generate", "Cancel");
			return 1;
		}
		#if ALLOW_ALL_VEHICLES == true
		case DIALOG_OFFSET + 2: // Pick a vehicle (model id)
		{
			// If race creation is canceled...
			if (!response) 
			{
				DeletePVar(playerid, PVAR_TAG"closestNode");
				DeletePVar(playerid, PVAR_TAG"currentRaceID");
				TogglePlayerControllable(playerid, true);
				return 1;
			}
			
			// Scan through vehicle ID, check if no invalid characters are used
			for (new c; inputtext[c] != EOS; c++)
			{
				switch (inputtext[c])
				{
					case '0' .. '9', ' ', '\0': continue;
					default:
					{
						ShowPlayerDialog(playerid, DIALOG_OFFSET + 2, 1, "Vehicle model", "Please input a vehicle model ID ranging from 400 to 611.\n\nERROR: This input is not a valid vehicle model ID.", "Pick", "Cancel");
						return 1;
					}
				}
			}
			
			// Read out vehicle ID
			new model = strval(inputtext);
			if (400 <= model <= 611)
			{	
				new str[128], vname[MAX_VEHICLE_NAME];
				strunpack(vname, VehicleNames[model - 400]);
				format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have picked the %s!", vname);
				SendClientMessage(playerid, COL_TEXT_IMPORTANT, str);
				SetPVarInt(playerid, PVAR_TAG"selectedVehicle", model);
				
				ShowPlayerDialog(playerid, DIALOG_OFFSET, 1, "Maximum length", "Please input the maximum length of the race in meters.", "Generate", "Cancel");
			}
			else
			{
				ShowPlayerDialog(playerid, DIALOG_OFFSET + 2, 1, "Vehicle model", "Please input a vehicle model ID ranging from 400 to 611.\n\nERROR: This input is not a valid vehicle model ID.", "Pick", "Cancel");
			}			
			return 1;
		}
		#endif
		case DIALOG_OFFSET + 3: // Accept or decline a race invite
		{
			new inviteplayer = GetPVarInt(playerid, PVAR_TAG"currentInviteID");
			DeletePVar(playerid, PVAR_TAG"currentInviteID");
			DeletePVar(playerid, PVAR_TAG"currentInviteTime");
			
			// In case of invalid data, error
			if (!inviteplayer)
			{
				return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured in the invite. (Reference ID: 009) The inviting player ID could not be found.");
			}
			inviteplayer--;			
			
			// If the invite is declined
			if (!response)
			{
				// If the inviting player is not online anymore, just 'decline', else use name of player.
				if (!IsPlayerConnected(inviteplayer))
				{
					SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You have declined the race invite.");
				}
				else
				{
					new str[128], iName[MAX_PLAYER_NAME];
					GetPlayerName(inviteplayer, iName, MAX_PLAYER_NAME);
					format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have declined the race invite from %s.", iName);
					SendClientMessage(playerid, COL_TEXT_IMPORTANT, str);
				}				
				return 1;
			}
			
			// If invite is accepted, but player is not online anymore
			if (!IsPlayerConnected(inviteplayer))
			{
				return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: The player who invited you is not online anymore.");
			}
			
			// If player is not in race anymore
			new race = GetPVarInt(inviteplayer, PVAR_TAG"currentRaceID");
			if (!race)
			{
				return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: The player is not in a race anymore. You cannot join him.");
			}
			race -= 2;
			
			// If everything is okay, join the inviting player
			putPlayerInRace(playerid, race);		
			return 1;
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnDialogResponse", "iiiis", playerid, dialogid, response, listitem, inputtext);
	#else
		return 0;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public GPS_WhenRouteIsCalculated(routeid, node_id_array[], amount_of_nodes, Float:distance, Float:Polygon[], Polygon_Size, Float:NodePosX[], Float:NodePosY[], Float:NodePosZ[])
{
	if (0 <= routeid < MAX_RACES && raceInfo[routeid][rHost] != INVALID_PLAYER_ID)
	{
		new playerid = raceInfo[routeid][rHost];
		// In case of invalid info, error
		if (!amount_of_nodes || distance == -1) 
		{
			SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 004) The race has been reset.");
			return cleanRace(routeid);
		}
		
		new lastIntersection, Float: distIntersection, curCPSlot = getFirstEmptyCPSlot(routeid), Float: maxDistance = GetPVarFloat(playerid, PVAR_TAG"totalRaceDistance"), i = 1, lastNode, bool: cps_added;
		
		// Set start position nodes
		if (curCPSlot == 0)
		{
			raceCheckpointList[routeid][0][0] = NodePosX[0];
			raceCheckpointList[routeid][0][1] = NodePosY[0];
			raceCheckpointList[routeid][0][2] = NodePosZ[0];
			raceCheckpointList[routeid][1][0] = NodePosX[1];
			raceCheckpointList[routeid][1][1] = NodePosY[1];
			raceCheckpointList[routeid][1][2] = NodePosZ[1];

			curCPSlot = 2;
		}
		
		// Loop through all nodes
		for (; i < amount_of_nodes; i++)
		{
			// Add up distance since last intersection
			distIntersection += GetDistanceBetweenNodes(node_id_array[i - 1], node_id_array[i]);
			
			// If node is intersection, check its distance to see if it's relevant as new checkpoint
			if (IsNodeIntersection(node_id_array[i]) == 1)
			{
				if (distIntersection > MINIMAL_DISTANCE_CP * 0.333)
				{
					cps_added = true;
					new Float: averageDist = distIntersection / float(floatround(distIntersection / MINIMAL_DISTANCE_CP, floatround_floor)), Float: curDist, Float: cpDist, bool: limitreached;
					
					// Re-read all nodes between last and current intersections and add checkpoints in between if necessary
					for (new n = lastIntersection + 1; n < i; n++) 
					{						
						cpDist += GetDistanceBetweenNodes(node_id_array[n - 1], node_id_array[n]);
						
						// Check distance between last and current checkpoint. (if greater than average distance, add new checkpoint)
						if (cpDist >= averageDist) 
						{
							raceCheckpointList[routeid][curCPSlot][0] = NodePosX[n];
							raceCheckpointList[routeid][curCPSlot][1] = NodePosY[n];
							raceCheckpointList[routeid][curCPSlot][2] = NodePosZ[n];
							
							curDist += cpDist; // Add checkpoint distance to total distance between current and last intersection.
							cpDist = 0.0;
							curCPSlot++;
							lastNode = node_id_array[i];
							
							if (curCPSlot >= MAX_CHECKPOINTS + 2 || raceInfo[routeid][rDistance] + curDist >= maxDistance) // Checkpoint or distance limit reached
							{
								raceInfo[routeid][rDistance] += curDist;
								limitreached = true;
								break;
							}
						}
					}
					
					// Add current intersection
					if (limitreached == false) 
					{
						raceInfo[routeid][rDistance] += curDist + cpDist;
						
						raceCheckpointList[routeid][curCPSlot][0] = NodePosX[i];
						raceCheckpointList[routeid][curCPSlot][1] = NodePosY[i];
						raceCheckpointList[routeid][curCPSlot][2] = NodePosZ[i];
						
						curCPSlot++;
						lastNode = node_id_array[i];
				
						lastIntersection = i;
						distIntersection = 0.0;
					}
					
					// End the race creation, add the finishing touch
					if (limitreached == true || curCPSlot >= MAX_CHECKPOINTS + 2 || raceInfo[routeid][rDistance] >= maxDistance)
					{	
						// Set the name of the race
						new str[48], pName[MAX_PLAYER_NAME], len;
						len = GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
						switch (pName[len - 1])
						{
							case 's', 'z', 'S', 'Z': format(str, sizeof(str), "%s' race (%.1fm)", pName, raceInfo[routeid][rDistance]);
							default: format(str, sizeof(str), "%s's race (%.1fm)", pName, raceInfo[routeid][rDistance]);
						}
						
						// If private race, create new hidden textdraw if necessary
						if (routeid >= MAX_PUBLIC_RACES)
						{
							if (joinMenuSlots[routeid] == Text: INVALID_TEXT_DRAW)
							{
								joinMenuSlots[routeid] = TextDrawCreate(MENU_X + 10.0, MENU_Y + 19.0 + float(MAX_PUBLIC_RACES * 15), str);
								TextDrawColor(joinMenuSlots[routeid], COL_MENU_REGULAR);
								TextDrawLetterSize(joinMenuSlots[routeid], 0.25, 1.2);
								TextDrawSetOutline(joinMenuSlots[routeid], 1);
								TextDrawTextSize(joinMenuSlots[routeid], MENU_X + 155.0, 12.0);
								TextDrawSetSelectable(joinMenuSlots[routeid], true);
							}
							amountOfPrivateRaces++;
							format(str, sizeof(str), "<%i/"#MAX_PRIVATE_RACES"> Create private race!", amountOfPrivateRaces);
							TextDrawSetString(joinMenuPrivate, str);
						}
						else
						{
							TextDrawSetString(joinMenuSlots[routeid], str);
						}
						
						// Spawn all textdraw checkpoint icons on the race map
						new interval = (curCPSlot >= MAX_TEXTDRAW_ICONS) ? floatround(float(curCPSlot - 1) / float(MAX_TEXTDRAW_ICONS), floatround_ceil) : 1;
						
						for (new c = 1, cp = 2; cp < curCPSlot && cp <= MAX_CHECKPOINTS + 2 && c < MAX_TEXTDRAW_ICONS - 2; cp += interval)
						{
							if ((!raceCheckpointList[routeid][cp][0] && !raceCheckpointList[routeid][cp][1])) continue;
							
							raceMapIcons[routeid][c] = TextDrawCreate(MENU_X + 148.0 + ((raceCheckpointList[routeid][cp][0] + 3000.0) / 6000.0) * 250.0, MENU_Y + 257.0 - ((raceCheckpointList[routeid][cp][1] + 3000.0) / 6000.0) * 250.0, "hud:radar_light");
							TextDrawFont(raceMapIcons[routeid][c], 4);
							TextDrawTextSize(raceMapIcons[routeid][c], 6.0, 6.0);
							c++;
						}
						
						// Spawn start and finish icon
						raceMapIcons[routeid][0] = TextDrawCreate(MENU_X + 148.0 + ((raceCheckpointList[routeid][0][0] + 3000.0) / 6000.0) * 250.0, MENU_Y + 255.0 - ((raceCheckpointList[routeid][0][1] + 3000.0) / 6000.0) * 250.0, "hud:radar_impound");
						raceMapIcons[routeid][MAX_TEXTDRAW_ICONS - 1] = TextDrawCreate(MENU_X + 148.0 + ((raceCheckpointList[routeid][curCPSlot - 1][0] + 3000.0) / 6000.0) * 250.0, MENU_Y + 255.0 - ((raceCheckpointList[routeid][curCPSlot - 1][1] + 3000.0) / 6000.0) * 250.0, "hud:radar_Flag");

						TextDrawFont(raceMapIcons[routeid][0], 4);
						TextDrawTextSize(raceMapIcons[routeid][0], 10.0, 10.0);
						TextDrawFont(raceMapIcons[routeid][MAX_TEXTDRAW_ICONS - 1], 4);
						TextDrawTextSize(raceMapIcons[routeid][MAX_TEXTDRAW_ICONS - 1], 10.0, 10.0);
						
						// Set vehicle model to the textdraw race info
						raceInfo[routeid][rVehicleModel] = GetPVarInt(playerid, PVAR_TAG"selectedVehicle");
						DeletePVar(playerid, PVAR_TAG"selectedVehicle");
						
						joinMenuRaceInfo[routeid][0] = TextDrawCreate(MENU_X + 390.0, MENU_Y - 5.0, "_"); // Vehicle model
						TextDrawFont(joinMenuRaceInfo[routeid][0], TEXT_DRAW_FONT_MODEL_PREVIEW);
						TextDrawUseBox(joinMenuRaceInfo[routeid][0], 1);
						TextDrawBackgroundColor(joinMenuRaceInfo[routeid][0], 0);
						TextDrawTextSize(joinMenuRaceInfo[routeid][0], 170.0, 130.0);
						TextDrawSetOutline(joinMenuRaceInfo[routeid][0], 2);
						TextDrawSetPreviewModel(joinMenuRaceInfo[routeid][0], raceInfo[routeid][rVehicleModel]);
						TextDrawSetPreviewVehCol(joinMenuRaceInfo[routeid][0], RACE_VEHICLE_COL1, RACE_VEHICLE_COL2);
						TextDrawSetPreviewRot(joinMenuRaceInfo[routeid][0], 345.0, 0.0, 325.0, 1.0);
						
						// Update rest of text to the textdraw race ifno
						new text[145];
						strunpack(str, VehicleNames[raceInfo[routeid][rVehicleModel] - 400]);
						
						raceInfo[routeid][rCPAmount] = curCPSlot - 2;
						format(text, sizeof(text), "~r~Vehicle: ~w~%s~n~~r~Length: ~w~%.1f meters~n~~r~Checkpoints: ~w~%i~n~~r~Host: ~w~%s", str, raceInfo[routeid][rDistance], raceInfo[routeid][rCPAmount], pName);
						
						joinMenuRaceInfo[routeid][1] = TextDrawCreate(MENU_X + 410.0, MENU_Y + 95.0, text);
						TextDrawColor(joinMenuRaceInfo[routeid][1], COL_MENU_REGULAR);
						TextDrawLetterSize(joinMenuRaceInfo[routeid][1], 0.25, 1.2);
						TextDrawSetOutline(joinMenuRaceInfo[routeid][1], 1);
						
						// Spawn the host in the race and update contestants
						spawnInRace(raceInfo[routeid][rHost], routeid, 0);
						raceInfo[routeid][rPlayerAmount] = 1;
						updateContestantList(routeid);
						
						if (joinMenuRaceInfo[routeid][2] != Text: INVALID_TEXT_DRAW)
						{
							TextDrawShowForPlayer(playerid, joinMenuRaceInfo[routeid][2]);
						}
						
						DeletePVar(playerid, PVAR_TAG"totalRaceDistance");
						
						// If race is private race, send different message
						if (routeid >= MAX_PUBLIC_RACES)
						{
							format(text, sizeof(text), " [!] NOTE: "COL_EMB_REG"You have started a private race with a length of %.1f meters! Use '"COL_EMB_IMPORTANT"/rrg invite [name]"COL_EMB_REG"' to invite people.", raceInfo[routeid][rDistance]);
							SendClientMessage(playerid, COL_TEXT_IMPORTANT, text);
						}
						else
						{
							format(text, sizeof(text), " [!] NOTE: "COL_EMB_REG"%s has started a new race with a length of %.1f meters! Use '"COL_EMB_IMPORTANT"/rrg menu"COL_EMB_REG"' to join this race.", pName, raceInfo[routeid][rDistance]);
							SendClientMessageToAll(COL_TEXT_IMPORTANT, text);
						}
						SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You can use '"COL_EMB_IMPORTANT"/rrg start"COL_EMB_REG"' to start the countdown or '"COL_EMB_IMPORTANT"/rrg leave"COL_EMB_REG"' to call the race off.");
						GameTextForPlayer(playerid, "~r~100%", 250, 4);
						
						#if defined RRG_is_include
							CallLocalFunction("onRandomRaceCreated", "iifi", routeid, playerid, raceInfo[routeid][rDistance], raceInfo[routeid][rCPAmount]);
						#endif
						return 1;
					}
				}
			}
		}
		
		new text[8];
		format(text, sizeof(text), "~w~%i%%", floatround(100.0 * raceInfo[routeid][rDistance] / maxDistance));
		GameTextForPlayer(playerid, text, 5000, 4);
		
		/*if (!cps_added)
		{
			SendClientMessage(raceInfo[routeid][rHost], COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 008)  The race might not properly connect.");
			printf("first node: %i, %.2f, %.2f, %.2f, last node: %i, %.2f, %.2f, %.2f, distance: %.2f", node_id_array[0], NodePosX[0], NodePosY[0], NodePosZ[0], node_id_array[amount_of_nodes-1], NodePosX[amount_of_nodes-1], NodePosY[amount_of_nodes-1], NodePosZ[amount_of_nodes-1], GetDistanceBetweenNodes(node_id_array[0], node_id_array[amount_of_nodes-1]));
		}
		if (!lastNode)
		{
			SendClientMessage(raceInfo[routeid][rHost], COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 014)  The race might not properly connect.");
			printf("first node: %i, %.2f, %.2f, %.2f, last node: %i, %.2f, %.2f, %.2f, distance: %.2f", node_id_array[0], NodePosX[0], NodePosY[0], NodePosZ[0], node_id_array[amount_of_nodes-1], NodePosX[amount_of_nodes-1], NodePosY[amount_of_nodes-1], NodePosZ[amount_of_nodes-1], GetDistanceBetweenNodes(node_id_array[0], node_id_array[amount_of_nodes-1]));
		}*/
		
		if (!cps_added || !lastNode) // Ugly fix :(
		{
			calculateNextRacePart(routeid, curCPSlot, NearestNodeFromPoint(raceCheckpointList[routeid][curCPSlot - 1][0], raceCheckpointList[routeid][curCPSlot - 1][1], 25.0));
		}
		else
		{
			calculateNextRacePart(routeid, curCPSlot, lastNode);
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_GPS_WhenRouteIsCalculated", "iaifaiaaa", routeid, node_id_array, amount_of_nodes, distance, Polygon, Polygon_Size, NodePosX, NodePosY, NodePosZ);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Float:GetAngleToPos(Float: PX, Float: PY, Float:X, Float:Y)
{
	new Float:Angle = floatabs(atan((Y-PY)/(X-PX)));
	Angle = (X<=PX && Y>=PY) ? floatsub(180.0, Angle) : (X<PX && Y<PY) ? floatadd(Angle, 180.0) : (X>=PX && Y<=PY) ? floatsub(360.0, Angle) : Angle;
	Angle = floatsub(Angle, 90.0);
	Angle = (Angle >= 360.0) ? floatsub(Angle, 360.0) : Angle;
	Angle = (Angle <= 0.0) ? floatadd(Angle, 360.0) : Angle;
	return Angle;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

calculateNextRacePart(routeid, curCPSlot, lastNode, bool: firstcalculation = false)
{
	new Float: newpos[2];	
	if (firstcalculation)
	{
		newpos[0] = float((random(6000) - 3000));
		newpos[1] = float((random(6000) - 3000));
		
		new Float: nodepos[3], Float: testpos[2];
		GetNodePos(lastNode, nodepos[0], nodepos[1], nodepos[2]);
		
		
		// If the position is too close to the startpoint: try again (up to 10 times, to prevent freeze if all nodes are too close)
		for (new s; s != 10; s++)
		{
			testpos[0] = newpos[0] - nodepos[0];
			testpos[1] = newpos[1] - nodepos[1];
			
			if ((testpos[0] * testpos[0]) + (testpos[1] * testpos[1]) < (MIN_RACE_DISTANCE * MIN_RACE_DISTANCE))
			{
				newpos[0] = float((random(6000) - 3000));
				newpos[1] = float((random(6000) - 3000));
			}
			else
			{
				break;
			}
		}
	}
	else
	{
		if (curCPSlot < 2)
		{
			SendClientMessage(raceInfo[routeid][rHost], COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 007)  The race has been reset.");
			DeletePVar(raceInfo[routeid][rHost], PVAR_TAG"selectedVehicle");
			DeletePVar(raceInfo[routeid][rHost], PVAR_TAG"totalRaceDistance");
			cleanRace(routeid);
			return 1;	
		}
	
		// Pick new position for the route calculator:
		newpos[0] = raceCheckpointList[routeid][curCPSlot - 2][0];
		newpos[1] = raceCheckpointList[routeid][curCPSlot - 2][1];
		
	
		new Float: angle = GetAngleToPos(newpos[0], newpos[1], raceCheckpointList[routeid][curCPSlot - 1][0], raceCheckpointList[routeid][curCPSlot - 1][1]);
		angle += float(random(50) - 25);
		
		new Float: dist = 1000 + float(random(2000));
		newpos[0] += (dist * floatsin(-angle, degrees));
		newpos[1] += (dist * floatcos(-angle, degrees));

		// Get the new position between the world boundries:
		newpos[0] = (newpos[0] > 3000.0) ? float(3000 - random(500)) : (newpos[0] < -3000.0) ? float(-3000 + random(500)) : newpos[0];
		newpos[1] = (newpos[1] > 3000.0) ? float(3000 - random(500)) : (newpos[1] < -3000.0) ? float(-3000 + random(500)) : newpos[1];
	}
	
	new newNode = NearestNodeFromPoint(newpos[0], newpos[1], 25.0, .IgnoreNodeID = lastNode);
	if (newNode == -1)
	{
		SendClientMessage(raceInfo[routeid][rHost], COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation. (Reference ID: 002)  The race has been reset.");
		DeletePVar(raceInfo[routeid][rHost], PVAR_TAG"selectedVehicle");
		DeletePVar(raceInfo[routeid][rHost], PVAR_TAG"totalRaceDistance");
		cleanRace(routeid);
		return 1;
	}
	CalculatePath(lastNode, newNode, routeid, .GrabNodePositions = true);
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

createRace(playerid, slot)
{
	for (new r; r < MAX_RACES; r++)
	{
		if (raceInfo[r][rHost] == playerid)
		{
			return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You have already started a race!");
		}
	}
	
	new oldrace = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (oldrace)
	{
		return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are already in a race! Use '/rrg leave' to leave that race.");
	}
	
	new closestNode = NearestPlayerNode(playerid, 75.0, .UseAreas = 1);
	if (closestNode == -1)
	{
		return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You need to move closer to a road!");
	}
	SetPVarInt(playerid, PVAR_TAG"closestNode", closestNode);
	SetPVarInt(playerid, PVAR_TAG"currentRaceID", slot + 2);
	
	ShowPlayerDialog(playerid, DIALOG_OFFSET + 1, 2, "Vehicle model", vehListStr, "Select", "Cancel");
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cleanRace(race, checkhost = false)
{
	raceInfo[race][rVehicleModel] = 0;
	raceInfo[race][rStarted] = 0;
	raceInfo[race][rDistance] = 0.0;
	raceInfo[race][rFinishedPlayers] = 0;
	if (raceInfo[race][rEndTimer] != -1)
	{
		KillTimer(raceInfo[race][rEndTimer]);
	}
	raceInfo[race][rEndTimer] = -1;
	
	for (new c; c < MAX_CHECKPOINTS + 2; c++)
	{
		raceCheckpointList[race][c][0] = 0.0;
		raceCheckpointList[race][c][1] = 0.0;
		raceCheckpointList[race][c][2] = 0.0;
	}
	raceInfo[race][rCPAmount] = 0;
	
	for (new i; i < MAX_TEXTDRAW_ICONS; i++)
	{
		if (raceMapIcons[race][i] != Text: INVALID_TEXT_DRAW)
		{
			TextDrawHideForAll(raceMapIcons[race][i]);
			TextDrawDestroy(raceMapIcons[race][i]);
			raceMapIcons[race][i] = Text: INVALID_TEXT_DRAW;
		}
	}
	
	for (new t; t < sizeof(joinMenuRaceInfo[]); t++)
	{
		if (joinMenuRaceInfo[race][t] != Text: INVALID_TEXT_DRAW)
		{
			TextDrawHideForAll(joinMenuRaceInfo[race][t]);
			TextDrawDestroy(joinMenuRaceInfo[race][t]);
			joinMenuRaceInfo[race][t] = Text: INVALID_TEXT_DRAW;
		}
	}
	
	if (race >= MAX_PUBLIC_RACES) // private races
	{
		new str[48];
		amountOfPrivateRaces--;
		format(str, sizeof(str), "<%i/"#MAX_PRIVATE_RACES"> Create private race!", amountOfPrivateRaces);
		TextDrawSetString(joinMenuPrivate, str);
		
		TextDrawHideForAll(joinMenuSlots[race]);
		TextDrawDestroy(joinMenuSlots[race]);
		joinMenuSlots[race] = Text: INVALID_TEXT_DRAW;
	}
	
	new playerid = raceInfo[race][rHost];
	raceInfo[race][rHost] = INVALID_PLAYER_ID;
	for (new p, mp = GetPlayerPoolSize(); p < mp; p++)
	{
		if (IsPlayerConnected(p) && !IsPlayerNPC(p))
		{
			new pRace = GetPVarInt(p, PVAR_TAG"currentRaceID");
			if (pRace && pRace - 2 == race)
			{
				if (!checkhost || (checkhost && p != playerid))
				{
					removePlayerFromRace(p);
				}
			}
		}
	}
	raceInfo[race][rPlayerAmount] = 0;
	
	TextDrawSetString(joinMenuSlots[race], "<Empty> Create a race!");
	
	#if defined RRG_is_include
		CallLocalFunction("onRaceRemove", "i", race);
	#endif
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#if REMEMBER_OLD_POSITION == true
removePlayerFromRace(playerid, bool: oldspawn = true)
#else
removePlayerFromRace(playerid)
#endif
{
	if (!IsPlayerConnected(playerid)) return 0;
	
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (!race)
	{
		return 0;
	}
	race -= 2;
	
	new spot = GetPVarInt(playerid, PVAR_TAG"startSpotI");
	if (racePeopleInRace[race][spot][0] == playerid)
	{
		racePeopleInRace[race][spot][0] = INVALID_PLAYER_ID;
		racePeopleInRace[race][spot][1] = 0;
	}
	
	new veh = GetPVarInt(playerid, PVAR_TAG"currentVehID");
	DestroyVehicle(veh);
	DeletePVar(playerid, PVAR_TAG"currentVehID");
	DisablePlayerRaceCheckpoint(playerid);
	DeletePVar(playerid, PVAR_TAG"currentCPID");
	new timer = GetPVarInt(playerid, PVAR_TAG"respawnTimer");
	if (timer)
	{
		KillTimer(timer);
	}
	DeletePVar(playerid, PVAR_TAG"respawnTimer");
	
	if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
	{
		TextDrawHideForPlayer(playerid, joinMenuRaceInfo[race][2]);
	}
	
	new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
	if (gui)
	{
		gui--;
		PlayerTextDrawHide(playerid, gui);
		PlayerTextDrawDestroy(playerid, gui);
	}
	DeletePVar(playerid, PVAR_TAG"racePlayerTD");
	
	for (new ci, icon = SUGGESTED_MAPICONS_OFFSET; ci < MAX_SUGGESTED_MAPICONS; ci++, icon++)
	{
		RemovePlayerMapIcon(playerid, icon);
	}
	
	#if REMEMBER_OLD_POSITION == true // spawn player at old position
		if (oldspawn == true)
		{
			new Float: oldpos[4], oldint, oldvw;
			oldpos[0] = GetPVarFloat(playerid, PVAR_TAG"oldX");
			oldpos[1] = GetPVarFloat(playerid, PVAR_TAG"oldY");
			oldpos[2] = GetPVarFloat(playerid, PVAR_TAG"oldZ");
			oldpos[3] = GetPVarFloat(playerid, PVAR_TAG"oldR");
			oldint = GetPVarInt(playerid, PVAR_TAG"oldInt");
			oldvw = GetPVarInt(playerid, PVAR_TAG"oldVW");
			SetPlayerPos(playerid, oldpos[0], oldpos[1], oldpos[2]);
			SetPlayerFacingAngle(playerid, oldpos[3]);
			SetPlayerInterior(playerid, oldint);
			SetPlayerVirtualWorld(playerid, oldvw);
		}
		DeletePVar(playerid, PVAR_TAG"oldX");
		DeletePVar(playerid, PVAR_TAG"oldY");
		DeletePVar(playerid, PVAR_TAG"oldZ");
		DeletePVar(playerid, PVAR_TAG"oldR");
		DeletePVar(playerid, PVAR_TAG"oldInt");
		DeletePVar(playerid, PVAR_TAG"oldVW");
	#endif
	
	// Delete race start position
	DeletePVar(playerid, PVAR_TAG"startSpotX");
	DeletePVar(playerid, PVAR_TAG"startSpotY");
	DeletePVar(playerid, PVAR_TAG"startSpotZ");
	DeletePVar(playerid, PVAR_TAG"startSpotA");
	DeletePVar(playerid, PVAR_TAG"startSpotI");
						
	TogglePlayerControllable(playerid, true);
	
	new bool: updatelist = true, bool: found_new_host;
	for (new r; r < MAX_RACES; r++)
	{
		if (raceInfo[r][rHost] == playerid)
		{
			if (raceInfo[r][rPlayerAmount] <= 1 && raceInfo[r][rFinishedPlayers] != raceInfo[r][rPlayerAmount]) // If player is only contestant left; delete race.
			{
				cleanRace(r, true);
			
				if (r == race)
				{
					updatelist = false;
				}
			}
			else // There is another player in the race; make him host!
			{
				for (new c; c < MAX_CONTESTANTS; c++)
				{
					if (racePeopleInRace[race][c][0] != INVALID_PLAYER_ID && racePeopleInRace[race][c][0] != playerid)
					{
						raceInfo[r][rHost] = racePeopleInRace[race][c][0];
						
						new str[128], newhostName[MAX_PLAYER_NAME];
						GetPlayerName(raceInfo[r][rHost], newhostName, MAX_PLAYER_NAME);
						
						if (raceInfo[r][rPlayerAmount] > 1) // If there are more than 1 person left, send a message to other contestants as well
						{
							format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"%s has become the new host for this race. The old host left.", newhostName);
						
							for (new s; s < MAX_CONTESTANTS; s++)
							{
								if (racePeopleInRace[race][s][0] != INVALID_PLAYER_ID && racePeopleInRace[race][s][0] != raceInfo[r][rHost] && racePeopleInRace[race][s][0] != playerid)
								{
									SendClientMessage(racePeopleInRace[race][s][0], COL_TEXT_IMPORTANT, str);						
								}
							}
						}
						
						SendClientMessage(raceInfo[r][rHost], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You have become the new host for this race. The old host left.");
						format(str, sizeof(str), " [!] NOTE: "COL_EMB_REG"You have left the race. %s has taken your position as host.", newhostName);
						SendClientMessage(playerid, COL_TEXT_IMPORTANT, str);
						
						// Update race information box
						if (joinMenuRaceInfo[r][1] != Text: INVALID_TEXT_DRAW)
						{
							new text[145];
							strunpack(str, VehicleNames[raceInfo[r][rVehicleModel] - 400]);
							format(text, sizeof(text), "~r~Vehicle: ~w~%s~n~~r~Length: ~w~%.1f meters~n~~r~Checkpoints: ~w~%i~n~~r~Host: ~w~%s", str, raceInfo[r][rDistance], raceInfo[r][rCPAmount], newhostName);
							
							TextDrawSetString(joinMenuRaceInfo[r][1], text);
						}
						
						found_new_host = true;
						break;
					}				
				}
				
				// If still couldn't find any other player, clean race anyway.
				if (!found_new_host)
				{
					cleanRace(r, true);
			
					if (r == race)
					{
						updatelist = false;
					}
				}
			}
			
			DeletePVar(playerid, PVAR_TAG"totalRaceDistance");
		}
	}
	if (!GetPVarInt(playerid, PVAR_TAG"isFinished"))
	{
		raceInfo[race][rPlayerAmount]--;
	}
	DeletePVar(playerid, PVAR_TAG"isFinished");
	
	// Update the contestant list in the race menu.
	if (updatelist == true)
	{
		updateContestantList(race);
	}
	DeletePVar(playerid, PVAR_TAG"currentRaceID");
	return (found_new_host == true) ? 2 : 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

showJoinMenuForPlayer(playerid)
{
	if (!IsPlayerConnected(playerid)) return 0;
	
	SetPVarInt(playerid, PVAR_TAG"joinMenuOpen", 1);
	for (new e; e < sizeof(joinMenuExtra); e++)
	{
		TextDrawShowForPlayer(playerid, joinMenuExtra[e]);
	}
	for (new s; s < MAX_PUBLIC_RACES; s++)
	{
		if (raceInfo[s][rStarted] == 2)
		{
			TextDrawColor(joinMenuSlots[s], COL_MENU_STARTED);
		}
		else
		{
			TextDrawColor(joinMenuSlots[s], COL_MENU_REGULAR);
		}
		TextDrawShowForPlayer(playerid, joinMenuSlots[s]);
	}
	TextDrawShowForPlayer(playerid, joinMenuButtons[2]);
	SelectTextDraw(playerid, COL_MENU_MOUSEOVER);
	
	for (new d; d < 5; d++)
	{
		SendDeathMessageToPlayer(playerid, -1, MAX_PLAYERS, -1);
	}
	
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID"), bool: privaterace = false;
	if (race)
	{
		new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
		if (gui)
		{
			PlayerTextDrawHide(playerid, gui - PlayerText: 1);
		}
		race -= 2;
		if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
		{
			TextDrawHideForPlayer(playerid, joinMenuRaceInfo[race][2]);
		}
		if (race >= MAX_PUBLIC_RACES)
		{
			if (raceInfo[race][rStarted] == 2)
			{
				TextDrawColor(joinMenuSlots[race], COL_MENU_STARTED);
			}
			else
			{
				TextDrawColor(joinMenuSlots[race], COL_MENU_REGULAR);
			}
			TextDrawShowForPlayer(playerid, joinMenuSlots[race]);
			privaterace = true;
		}
	}
	if (privaterace == false)
	{
		TextDrawColor(joinMenuPrivate, COL_MENU_REGULAR);
		TextDrawShowForPlayer(playerid, joinMenuPrivate);
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

hideJoinMenu(playerid)
{
	CancelSelectTextDraw(playerid);
	DeletePVar(playerid, PVAR_TAG"joinMenuOpen");
	for (new b; b < sizeof(joinMenuButtons); b++)
	{
		TextDrawHideForPlayer(playerid, joinMenuButtons[b]);
	}
	for (new e; e < sizeof(joinMenuExtra); e++)
	{
		TextDrawHideForPlayer(playerid, joinMenuExtra[e]);
	}
	
	TextDrawHideForPlayer(playerid, joinMenuPrivate);
	for (new s; s < MAX_RACES; s++)
	{
		if (joinMenuSlots[s] != Text: INVALID_TEXT_DRAW)
		{
			TextDrawHideForPlayer(playerid, joinMenuSlots[s]);
		}
		
		for (new i; i < MAX_TEXTDRAW_ICONS; i++)
		{
			if (raceMapIcons[s][i] != Text: INVALID_TEXT_DRAW)
			{
				TextDrawHideForPlayer(playerid, raceMapIcons[s][i]);
			}
		}
		for (new v; v < sizeof(joinMenuRaceInfo[]); v++)
		{
			if (joinMenuRaceInfo[s][v] != Text: INVALID_TEXT_DRAW)
			{
				TextDrawHideForPlayer(playerid, joinMenuRaceInfo[s][v]);
			}
		}
	}
	
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (race)
	{
		race -= 2;
		if (raceInfo[race][rStarted] == 2)
		{
			if (GetPVarInt(playerid, PVAR_TAG"currentCPID") - 1 < raceInfo[race][rCPAmount])
			{
				new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
				if (gui)
				{
					PlayerTextDrawShow(playerid, gui - PlayerText: 1);
				}
			}
		}
		else
		{
			if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
			{
				TextDrawShowForPlayer(playerid, joinMenuRaceInfo[race][2]);
			}
		}
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

putPlayerInRace(playerid, race)
{
	if (!IsPlayerConnected(playerid)) return 0;
	if (!(0 <= race < MAX_RACES) || raceInfo[race][rHost] == INVALID_PLAYER_ID) return 0;
	
	for (new r; r < MAX_RACES; r++)
	{
		if (raceInfo[r][rHost] == playerid)
		{
			if (r == race)
			{
				return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are already in this race!");
			}
			else
			{
				return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You have already started another race! You cannot join this one.");
			}
		}
	}
	
	new oldrace = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (oldrace)
	{
		if (oldrace - 2 == race)
		{
			return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are already in this race!");
		}
		else
		{
			return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You are already in another race! Use '/rrg leave' to leave that race.");
		}
	}
	
	if (raceInfo[race][rStarted] == 2)
	{
		return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: This race has already started! You cannot join anymore.");	
	}
	
	new currentcontestants;
	for (new p, mp = GetPlayerPoolSize(); p < mp; p++)
	{
		if (IsPlayerConnected(p) && !IsPlayerNPC(p))
		{
			new pRace = GetPVarInt(p, PVAR_TAG"currentRaceID");
			if (pRace && pRace - 2 == race)
			{
				currentcontestants++;
			}
		}
	}
	raceInfo[race][rPlayerAmount] = currentcontestants;
	if (currentcontestants >= MAX_CONTESTANTS)
	{
		SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You cannot join this race anymore! There's no room.");
		return 0;
	}
	
	raceInfo[race][rPlayerAmount]++;
	SetPVarInt(playerid, PVAR_TAG"currentRaceID", race + 2);
	spawnInRace(playerid, race, currentcontestants);
	updateContestantList(race);
	
	if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
	{
		TextDrawShowForPlayer(playerid, joinMenuRaceInfo[race][2]);
	}
	
	SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You can use '"COL_EMB_IMPORTANT"/rrg leave"COL_EMB_REG"' to leave this race.");
	
	#if defined RRG_is_include
		CallLocalFunction("onPlayerJoinRace", "ii", playerid, race);
	#endif
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

spawnInRace(playerid, race, spot = -1)
{
	new Float: spos[3], Float: angle;
	spos[0] = GetPVarFloat(playerid, PVAR_TAG"startSpotX");
	spos[1] = GetPVarFloat(playerid, PVAR_TAG"startSpotY");
	
	if (!spos[0] && !spos[1])
	{
		#if REMEMBER_OLD_POSITION == true
			new Float: oldpos[4], oldint;
			GetPlayerPos(playerid, oldpos[0], oldpos[1], oldpos[2]);
			GetPlayerFacingAngle(playerid, oldpos[3]);
			oldint = GetPlayerInterior(playerid);
			oldvw = GetPlayerVirtualWorld(playerid);
			SetPVarFloat(playerid, PVAR_TAG"oldX", oldpos[0]);
			SetPVarFloat(playerid, PVAR_TAG"oldY", oldpos[1]);
			SetPVarFloat(playerid, PVAR_TAG"oldZ", oldpos[2]);
			SetPVarFloat(playerid, PVAR_TAG"oldR", oldpos[3]);
			SetPVarInt(playerid, PVAR_TAG"oldInt", oldint);
			SetPVarInt(playerid, PVAR_TAG"oldVW", oldvw);
		#endif
	
		if (spot == -1)
		{
			for (new s; s < MAX_CONTESTANTS; s++)
			{
				if (racePeopleInRace[race][s][0] != INVALID_PLAYER_ID)
				{
					spot = s;
					break;
				}
			}
			
			if (spot == -1)
			{
				removePlayerFromRace(playerid);
				return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: You have been removed from the race, because there is no free space left.");
			}
		}
	
		new Float: size[3], Float: offset[2], Float: temp;
		angle = GetAngleToPos(raceCheckpointList[race][0][0], raceCheckpointList[race][0][1], raceCheckpointList[race][1][0], raceCheckpointList[race][1][1]);
		GetVehicleModelInfo(raceInfo[race][rVehicleModel], VEHICLE_MODEL_INFO_SIZE, size[0], size[1], size[2]);
		offset[0] = (spot & 1) ? (size[0] * 0.75) : -(size[0] * 0.75);
		offset[1] = -float((spot / 2) * floatround((size[1] * 1.2), floatround_ceil));
			
		// Thanks to Mauzen for offset calculation! ( http://forum.sa-mp.com/showthread.php?t=270427 )
		new Float: flSin = floatsin(-angle, degrees), Float: flCos = floatcos(-angle, degrees);
		spos[0] = flSin * offset[1] + flCos * offset[0] + raceCheckpointList[race][0][0];
		spos[1] = flCos * offset[1] - flSin * offset[0] + raceCheckpointList[race][0][1];
		GetNodePos(NearestNodeFromPoint(spos[0], spos[1], raceCheckpointList[race][0][2] + 1.5, 50.0, -1, 1), temp, temp, spos[2]);
		
		SetPVarFloat(playerid, PVAR_TAG"startSpotX", spos[0]);
		SetPVarFloat(playerid, PVAR_TAG"startSpotY", spos[1]);
		SetPVarFloat(playerid, PVAR_TAG"startSpotZ", spos[2]);
		SetPVarFloat(playerid, PVAR_TAG"startSpotA", angle);
		SetPVarInt(playerid, PVAR_TAG"startSpotI", spot);
		
		new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
		if (!gui)
		{
			gui = CreatePlayerTextDraw(playerid, 580.0, 340.0, "_"); // GUI
			PlayerTextDrawColor(playerid, gui, COL_MENU_REGULAR);
			PlayerTextDrawLetterSize(playerid, gui, 0.5, 2.4);
			PlayerTextDrawAlignment(playerid, gui, 3);
			PlayerTextDrawSetOutline(playerid, gui, 2);
			SetPVarInt(playerid, PVAR_TAG"racePlayerTD", _:gui + 1);
		}
		
		racePeopleInRace[race][spot][0] = playerid;
		racePeopleInRace[race][spot][1] = spot + 1;
		
	}
	else
	{
		new oldveh = GetPVarInt(playerid, PVAR_TAG"currentVehID");
		if (oldveh)
		{
			DestroyVehicle(oldveh);
		}
		spos[2] = GetPVarFloat(playerid, PVAR_TAG"startSpotZ");
		angle = GetPVarFloat(playerid, PVAR_TAG"startSpotA");
	}
	
	new veh = CreateVehicle(raceInfo[race][rVehicleModel], spos[0], spos[1], spos[2] + 2.5, angle, RACE_VEHICLE_COL1, RACE_VEHICLE_COL2, 0);
	SetVehicleVirtualWorld(veh, RACE_VIRTUAL_WORLD);
	SetVehicleParamsEx(veh, true, false, false, true, false, false, false);
	SetVehicleParamsForPlayer(veh, playerid, false, false);
	
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, RACE_VIRTUAL_WORLD);
	TogglePlayerControllable(playerid, false);
	
	// Fix the ghost vehicles:
	new oldveh = GetPlayerVehicleID(playerid);
	if (oldveh)
	{
		new Float: oldpos[3];
		GetVehiclePos(oldveh, oldpos[0], oldpos[1], oldpos[2]);
		SetPlayerPos(playerid, oldpos[0], oldpos[1], oldpos[2] - 2.0);
	}
	else
	{	
		PutPlayerInVehicle(playerid, veh, 0);
	}
	SetPVarInt(playerid, PVAR_TAG"currentVehID", veh);
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

startRace(race, bool: countdown = true)
{
	if (!(0 <= race < MAX_RACES) || raceInfo[race][rHost] == INVALID_PLAYER_ID) return 0;
	
	
	if (countdown == true)
	{
		raceInfo[race][rStarted] = 1;
		SetTimerEx("countdownTimer", 1000, false, "ii", race, 3);
	
		#if defined RRG_is_include
			CallLocalFunction("onRaceCountdown", "i", race);
		#endif
	}
	else // start race immediately
	{
		raceInfo[race][rStarted] = 2;
		
		for (new s; s < MAX_CONTESTANTS; s++)
		{
			if (racePeopleInRace[race][s][0] != INVALID_PLAYER_ID)
			{
				new p = racePeopleInRace[race][s][0];
				
				TogglePlayerControllable(p, true);
				DeletePVar(p, PVAR_TAG"startSpotX");
				DeletePVar(p, PVAR_TAG"startSpotY");
				DeletePVar(p, PVAR_TAG"startSpotZ");
				DeletePVar(p, PVAR_TAG"startSpotA");
				
				SetCameraBehindPlayer(p);
				updatePlayerGUI(p);
				setCheckpoint(p, race, 2);
				SendClientMessage(p, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"If you get stuck, you can respawn at the last checkpoint by using '"COL_EMB_IMPORTANT"/rrg respawn"COL_EMB_REG"'.");
				
				if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
				{
					TextDrawHideForPlayer(p, joinMenuRaceInfo[race][2]);
				}
				
				new veh = GetPVarInt(p, PVAR_TAG"currentVehID"), params[7];
				GetVehicleDamageStatus(veh, params[0], params[1], params[2], params[3]);
				UpdateVehicleDamageStatus(veh, params[0], params[1], params[2], 0);
				
				GetVehicleParamsEx(veh, params[0], params[1], params[2], params[3], params[4], params[5], params[6]);
				SetVehicleParamsEx(veh, true, params[1], params[2], true, params[4], params[5], params[6]);
			}
		}
		
		#if defined RRG_is_include
			CallLocalFunction("onRaceStart", "i", race);
		#endif
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

forward countdownTimer(race, count);
public countdownTimer(race, count)
{
	if (raceInfo[race][rStarted] != 1)
	{
		return 0;
	}
	
	new str[2];
	str[0] = '0' + count;

	for (new s; s < MAX_CONTESTANTS; s++)
	{
		if (racePeopleInRace[race][s][0] != INVALID_PLAYER_ID)
		{
			new p = racePeopleInRace[race][s][0];
			switch (count)
			{
				case 0:
				{
					GameTextForPlayer(p, "GO!", 2000, 3);
					TogglePlayerControllable(p, true);
					PlayerPlaySound(p, 1057, 0.0, 0.0, 0.0);
					
					DeletePVar(p, PVAR_TAG"startSpotX");
					DeletePVar(p, PVAR_TAG"startSpotY");
					DeletePVar(p, PVAR_TAG"startSpotZ");
					DeletePVar(p, PVAR_TAG"startSpotA");
					
					new veh = GetPVarInt(p, PVAR_TAG"currentVehID"), params[7];
					GetVehicleDamageStatus(veh, params[0], params[1], params[2], params[3]);
					UpdateVehicleDamageStatus(veh, params[0], params[1], params[2], 0);

					GetVehicleParamsEx(veh, params[0], params[1], params[2], params[3], params[4], params[5], params[6]);
					SetVehicleParamsEx(veh, 1, params[1], params[2], 1, params[4], params[5], params[6]);
				}
				case 1, 2:
				{
					GameTextForPlayer(p, str, 2000, 3);
					PlayerPlaySound(p, 1056, 0.0, 0.0, 0.0);
				}
				case 3:
				{
					GameTextForPlayer(p, str, 2000, 3);
					PlayerPlaySound(p, 1056, 0.0, 0.0, 0.0);
					
					SetCameraBehindPlayer(p);
					updatePlayerGUI(p);
					setCheckpoint(p, race, 2);
					SendClientMessage(p, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"If you get stuck, you can respawn at the last checkpoint by using '"COL_EMB_IMPORTANT"/rrg respawn"COL_EMB_REG"'.");
					
					if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
					{
						TextDrawHideForPlayer(p, joinMenuRaceInfo[race][2]);
					}
					
				}
			}
		}
	}
	if (count) 
	{
		SetTimerEx("countdownTimer", 1000, false, "ii", race, count - 1);
	}
	else
	{
		raceInfo[race][rStarted] = 2;
		CallLocalFunction("onRaceStart", "i", race);
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnPlayerEnterRaceCheckpoint(playerid)
{
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	// When the player enters a race checkpoint in his race vehicle without being finished
	if (race && IsPlayerInVehicle(playerid, GetPVarInt(playerid, PVAR_TAG"currentVehID")) /* && !GetPVarInt(playerid, PVAR_TAG"isFinished")*/)
	{
		race -= 2;
		new cp = GetPVarInt(playerid, PVAR_TAG"currentCPID"),
			startspot = GetPVarInt(playerid, PVAR_TAG"startSpotI");
			
		if (!cp)
		{
			SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation of your checkpoint position. (Reference ID: 012)");
			return 1;
		}
		cp++;
		
		if (racePeopleInRace[race][startspot][0] != playerid)
		{
			SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation of your race position. (Reference ID: 006)");
		}
		
		if (raceInfo[race][rPlayerAmount] > 1)
		{
			// Get race position based on amount of CPs.
			new max_cps = MAX_CHECKPOINTS + 2, cur_top_cps = -1, cur_top_id = -1, ranking[MAX_CONTESTANTS];
			
			for (new r = raceInfo[race][rFinishedPlayers]; r < MAX_CONTESTANTS; r++)
			{
				// Find the best player for the current rank (r = rank ID, p = contestant ID):
				for (new p; p < MAX_CONTESTANTS; p++)
				{
					if (racePeopleInRace[race][p][0] == INVALID_PLAYER_ID || ranking[p] || GetPVarInt(racePeopleInRace[race][p][0], PVAR_TAG"isFinished")) continue;
					
					new pcp = (racePeopleInRace[race][p][0] == playerid) ? cp : GetPVarInt(racePeopleInRace[race][p][0], PVAR_TAG"currentCPID");
					if (max_cps >= pcp > cur_top_cps) // Check if player's CP amount is between current ranks highest and last ranks highest.
					{
						cur_top_id = p;
						cur_top_cps = pcp;
					}
					else if (pcp == cur_top_cps && cur_top_id != -1) // If 2 players have the same CP-amount
					{
						// Get CP distance current checking player
						new Float: pos[2][3], Float: p_dist, Float: cur_top_dist;
						GetPlayerPos(racePeopleInRace[race][p][0], pos[0][0], pos[0][1], pos[0][2]);
						pos[0][0] -= raceCheckpointList[race][pcp][0];
						pos[0][1] -= raceCheckpointList[race][pcp][1];
						pos[0][2] -= raceCheckpointList[race][pcp][1];
						p_dist = floatsqroot((pos[0][0] * pos[0][0]) + (pos[0][1] * pos[0][1]) + (pos[0][2] * pos[0][2]));
						
						// Get CP distance from current best player for this rank
						GetPlayerPos(racePeopleInRace[race][cur_top_id][0], pos[1][0], pos[1][1], pos[1][2]);
						pos[1][0] -= raceCheckpointList[race][pcp][0];
						pos[1][1] -= raceCheckpointList[race][pcp][1];
						pos[1][2] -= raceCheckpointList[race][pcp][1];
						cur_top_dist = floatsqroot((pos[1][0] * pos[1][0]) + (pos[1][1] * pos[1][1]) + (pos[1][2] * pos[1][2]));
						
						// Compare the distance, if this player is closer -> make him top
						if (cur_top_dist > p_dist)
						{
							cur_top_id = p;
							cur_top_cps = pcp;
						}						
					}
				}
				
				// Set the current checking rank to the chosen player:
				if (cur_top_id != -1)
				{
					max_cps = cur_top_cps;
					ranking[cur_top_id] = r + 1;
					cur_top_id = -1;
					cur_top_cps = -1;
				}
				else
				{
					break;
				}
			}
			
			// Update other players their GUI if necessary:
			for (new u; u < MAX_CONTESTANTS; u++)
			{
				if (racePeopleInRace[race][u][0] == INVALID_PLAYER_ID || !ranking[u]) continue;
			
				if (ranking[u] != racePeopleInRace[race][u][1])
				{
					racePeopleInRace[race][u][1] = ranking[u]; // Saving the race rank in the global list.
					
					if (racePeopleInRace[race][u][0] != playerid && !GetPVarInt(racePeopleInRace[race][u][0], PVAR_TAG"isFinished")) // Updating for current player will happen a bit later.
					{
						updatePlayerGUI(racePeopleInRace[race][u][0]);
					}
				}
			}
		}
		else // If there's only one contestant, there's only one spot they can claim: first place! :3
		{
			racePeopleInRace[race][startspot][1] = 1;
		}
			
		setCheckpoint(playerid, race, cp);
		updatePlayerGUI(playerid);
		PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
		
		#if defined RRG_is_include
			CallLocalFunction("onPlayerCheckCP", "iii", playerid, race, cp - 2);
		#endif
	}	
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerEnterRaceCheckpoint", "i", playerid);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnPlayerUpdate(playerid)
{
	new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
	if (race)
	{
		// If race hasn't started or if player is respawning, force him in his vehicle at all costs
		if (raceInfo[race - 2][rStarted] != 2 || GetPVarInt(playerid, PVAR_TAG"respawnTimer"))
		{
			/*new raceveh = GetPVarInt(playerid, PVAR_TAG"currentVehID"), curveh = GetPlayerVehicleID(playerid), curstate = GetPlayerState(playerid);
			
			// Check if player is in different vehicle: remove them if required
			if (curveh && curveh != raceveh && curstate != PLAYER_STATE_ONFOOT)
			{
				new Float: oldpos[3];
				GetVehiclePos(curveh, oldpos[0], oldpos[1], oldpos[2]);
				SetPlayerPos(playerid, oldpos[0], oldpos[1], oldpos[2]);
			}
			else if (!curveh && raceveh && curstate == PLAYER_STATE_ONFOOT)
			{
				PutPlayerInVehicle(playerid, raceveh, 0);
			}*/
			TogglePlayerControllable(playerid, false);
		}
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerUpdate", "i", playerid);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	// Lock race vehicles for other players, no carjacking allowed!
	for (new p, e = GetPlayerPoolSize(); p < e; p++)
	{
		if (!IsPlayerNPC(p) && IsPlayerConnected(p))
		{
			new race =  GetPVarInt(p, PVAR_TAG"currentRaceID"), veh = GetPVarInt(p, PVAR_TAG"currentVehID");
			if (race && veh == vehicleid)
			{
				SetVehicleParamsEx(veh, true, false, false, true, false, false, false);
				SetVehicleParamsForPlayer(veh, p, false, false);
				break;
			}
		}	
	}
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnVehicleStreamIn", "ii", vehicleid, forplayerid);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	// Put player in vehicle if it desynced out of it
	if (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
		new race =  GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (race && (raceInfo[race - 2][rStarted] != 2 || GetPVarInt(playerid, PVAR_TAG"respawnTimer")))
		{
			new raceveh = GetPVarInt(playerid, PVAR_TAG"currentVehID"), curveh = GetPlayerVehicleID(playerid);
			if (raceveh && curveh != raceveh)
			{
				SendClientMessage(playerid, -1, "tried to be put back in vehicle");
				PutPlayerInVehicle(playerid, raceveh, 0);
			}
		}	
	}
	
	// Show "get back in your vehicle" message
	#if VEHICLE_LEAVE_TIME != 0
    if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER) 
    {
		if (!GetPVarInt(playerid, PVAR_TAG"exitVehTimer"))
		{
			new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
			if (!race) return 1;
			
			race -= 2;
			if (raceInfo[race][rStarted] != 2) return 1;
			
			new veh = GetPVarInt(playerid, PVAR_TAG"currentVehID");
			if (!veh) return 1;
			
			new Float: health;
			GetPlayerHealth(playerid, health);
			if (health <= 0) return 1;
			
			// Lock vehicle for everyone but the player
			SetVehicleParamsEx(veh, true, false, false, true, false, false, false);
			SetVehicleParamsForPlayer(veh, playerid, false, false);
			
			if (GetPVarInt(playerid, PVAR_TAG"isFinished")) return 1;

			new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
			if (gui)
			{
				PlayerTextDrawHide(playerid, gui - PlayerText: 1);
			}
			
			SetPVarInt(playerid, PVAR_TAG"exitVehTimer", VEHICLE_LEAVE_TIME + 1);
			CallLocalFunction("exitVehTimer", "i", playerid);
		}

	}
	#endif
	
	#if defined RRG_is_include
		return CallLocalFunction("RRG_OnPlayerStateChange", "iii", playerid, newstate, oldstate);
	#else
		return 1;
	#endif
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#if VEHICLE_LEAVE_TIME != 0
forward exitVehTimer(playerid);
public exitVehTimer(playerid)
{
	if (!IsPlayerConnected(playerid)) return 0;
	
	new veh = GetPVarInt(playerid, PVAR_TAG"currentVehID");
	if (!(IsPlayerInVehicle(playerid, veh) && !GetPlayerVehicleSeat(playerid)))
	{
		new time = GetPVarInt(playerid, PVAR_TAG"exitVehTimer") - 1;
		if (time == 0)
		{
			SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You have been disqualified for leaving your vehicle.");
			removePlayerFromRace(playerid);
		}
		else
		{
			new str[128];
			if (time == 1)
			{
				format(str, sizeof(str), "~s~You have %i second to return to your ~y~vehicle ~s~before you are disqualified.", time);
			}
			else
			{
				format(str, sizeof(str), "~s~You have %i seconds to return to your ~y~vehicle ~s~before you are disqualified.", time);
			}
		
			showText(playerid, str, 1500);
			SetPVarInt(playerid, PVAR_TAG"exitVehTimer", time);
			SetTimerEx("exitVehTimer", 800, false, "i", playerid);
			return 1;
		}
	}
	else
	{
		new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
		if (gui)
		{
			PlayerTextDrawShow(playerid, gui - PlayerText: 1);
		}
	}
	DeletePVar(playerid, PVAR_TAG"exitVehTimer");
	return 1;
}
#endif

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

setCheckpoint(playerid, race, cp)
{
	// If the player triggered the last checkpoint:
	if (cp == MAX_CHECKPOINTS + 2 || cp == raceInfo[race][rCPAmount] + 2) // checked last checkpoint
	{
		DisablePlayerRaceCheckpoint(playerid);
		new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
		if (gui)
		{
			PlayerTextDrawHide(playerid, gui - PlayerText: 1);
		}
		
		new nmb[3], startspot = GetPVarInt(playerid, PVAR_TAG"startSpotI");
		if (racePeopleInRace[race][startspot][0] != playerid)
		{
			SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the calculation of your race position. (Reference ID: 005)");
		}
		
		// Create "Player has finished #th"-text:
		switch (racePeopleInRace[race][startspot][1])
		{
			case 1: GameTextForPlayer(playerid, "1st place!", 3500, 3), nmb = "st";
			case 2: GameTextForPlayer(playerid, "2nd place!", 3500, 3), nmb = "nd";
			case 3: GameTextForPlayer(playerid, "3rd place!", 3500, 3), nmb = "rd";
			default:
			{
				new str[12];
				format(str, sizeof(str), "%ith place!", racePeopleInRace[race][startspot][1]);
				GameTextForPlayer(playerid, str, 3500, 3);
				nmb = "th";
			}
		}
		new text[128], pName[MAX_PLAYER_NAME], oName[MAX_PLAYER_NAME], len;
		GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
		len = GetPlayerName(raceInfo[race][rHost], oName, MAX_PLAYER_NAME);
		
		switch (oName[len - 1])
		{
			case 's', 'z', 'S', 'Z': format(text, sizeof(text), " [!] FINISH: %s finished %i%s place in %s' race!", pName, racePeopleInRace[race][startspot][1], nmb, oName);
			default: format(text, sizeof(text), " [!] FINISH: %s finished %i%s place in %s's race!", pName, racePeopleInRace[race][startspot][1], nmb, oName);
		}
		SendClientMessageToAll(COL_TEXT_WIN, text);
		
		raceInfo[race][rFinishedPlayers]++;
		
		// Check if everyone has finished or just one
		if (raceInfo[race][rPlayerAmount] == 1 || raceInfo[race][rPlayerAmount] == raceInfo[race][rFinishedPlayers]) // The last finisher starts the shortened ending timer.
		{
			if (raceInfo[race][rEndTimer] != -1)
			{
				KillTimer(raceInfo[race][rEndTimer]);
			}
			raceInfo[race][rEndTimer] = SetTimerEx("raceEndingTimer", 10000, false, "i", race);

			if (raceInfo[race][rPlayerAmount] == 1)
			{
				SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"All contestants have crossed the finish line! The race will be removed in 10 seconds.");
			}
			else
			{
				for (new p; p < MAX_CONTESTANTS; p++)
				{
					if (racePeopleInRace[race][p][0] != INVALID_PLAYER_ID)
					{
						SendClientMessage(racePeopleInRace[race][p][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"All contestants have crossed the finish line! The race will be removed in 10 seconds.");
					}
				}
			}
		}
		else // The first finisher will start the ending timer.
		{
			if (racePeopleInRace[race][startspot][1] == 1 && raceInfo[race][rFinishedPlayers] == 1 && raceInfo[race][rEndTimer] == -1)
			{
				raceInfo[race][rEndTimer] = SetTimerEx("raceEndingTimer", 60000, false, "i", race);
				
				for (new p; p < MAX_CONTESTANTS; p++)
				{
					if (racePeopleInRace[race][p][0] != INVALID_PLAYER_ID)
					{
						SendClientMessage(racePeopleInRace[race][p][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"The race will end in 60 seconds.");
					}
				}
			}
		}
		
		SetPVarInt(playerid, PVAR_TAG"isFinished", 1);
		SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You can leave the race by using '"COL_EMB_IMPORTANT"/rrg leave"COL_EMB_REG"' or wait until the race ends.");
		
		#if defined RRG_is_include
			CallLocalFunction("onPlayerFinishRace", "iii", playerid, race, racePeopleInRace[race][startspot][1]);
		#endif
	}
	// If the player triggered the checkpoint just before the last one (spawns finish checkpoint)
	else if (cp == MAX_CHECKPOINTS + 1 || cp == raceInfo[race][rCPAmount] + 1) 
	{
		SetPlayerRaceCheckpoint(playerid, 1, raceCheckpointList[race][cp][0], raceCheckpointList[race][cp][1], raceCheckpointList[race][cp][2] + 1.0, 0.0, 0.0, 0.0, 15.0);
	}
	else if (cp <= MAX_CHECKPOINTS || cp <= raceInfo[race][rCPAmount]) // Spawns regular checkpoint
	{
		SetPlayerRaceCheckpoint(playerid, 0, raceCheckpointList[race][cp][0], raceCheckpointList[race][cp][1], raceCheckpointList[race][cp][2] + 1.0, raceCheckpointList[race][cp + 1][0], raceCheckpointList[race][cp + 1][1], raceCheckpointList[race][cp + 1][2], 15.0);
	}
	else
	{
		return SendClientMessage(playerid, COL_TEXT_ERROR, " [!] ERROR: An error occured during the placing of the next checkpoint. (Reference ID: 013)");
	}
	
	// Create map icons on radar which suggest the next two checkpoints:
	for (new ci, icon = SUGGESTED_MAPICONS_OFFSET; ci < MAX_SUGGESTED_MAPICONS; ci++, icon++)
	{
		new cin = cp + ci + 1; // For CP list position, to get coords
		if (cin < MAX_CHECKPOINTS + 2 && cin < raceInfo[race][rCPAmount] + 2)
		{
			SetPlayerMapIcon(playerid, icon, raceCheckpointList[race][cin][0], raceCheckpointList[race][cin][1], raceCheckpointList[race][cin][2], 0, COL_MAP_CP, 0);
		}
		else 
		{
			RemovePlayerMapIcon(playerid, icon);
		}
	}
	
	SetPVarInt(playerid, PVAR_TAG"currentCPID", cp);
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

forward raceEndingTimer(race);
public raceEndingTimer(race)
{
	for (new s; s < MAX_CONTESTANTS; s++)
	{
		if (racePeopleInRace[race][s][0] != INVALID_PLAYER_ID)
		{
			if (!GetPVarInt(racePeopleInRace[race][s][0], PVAR_TAG"IsFinished"))
			{
				SendClientMessage(racePeopleInRace[race][s][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"Too slow! You didn't finish before the race ended.");
			}
			else
			{
				#if REMEMBER_OLD_POSITION == true
					SendClientMessage(racePeopleInRace[race][s][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"The race has been ended. You have been respawned at your old position.");
				#else
					SendClientMessage(racePeopleInRace[race][s][0], COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"The race has been ended.");
				#endif
			}
		}
	}
	cleanRace(race);
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

respawnPlayer(playerid, race)
{
	if (raceInfo[race][rStarted] != 2)
	{
		spawnInRace(playerid, race);
		
		if (joinMenuRaceInfo[race][2] != Text: INVALID_TEXT_DRAW)
		{
			TextDrawShowForPlayer(playerid, joinMenuRaceInfo[race][2]);
		}
		return 1;
	}
	
	if (GetPVarInt(playerid, PVAR_TAG"isFinished"))
	{
		removePlayerFromRace(playerid);
		return 1;
	}
	
	new veh = GetPVarInt(playerid, PVAR_TAG"currentVehID"), cp = GetPVarInt(playerid, PVAR_TAG"currentCPID") - 1, 
		Float: angle = GetAngleToPos(raceCheckpointList[race][cp][0], raceCheckpointList[race][cp][1], raceCheckpointList[race][cp + 1][0], raceCheckpointList[race][cp + 1][1]);
	
	if (veh)
	{
		DestroyVehicle(veh);
	}

	veh = CreateVehicle(raceInfo[race][rVehicleModel], raceCheckpointList[race][cp][0], raceCheckpointList[race][cp][1], raceCheckpointList[race][cp][2] + 3.5, angle, RACE_VEHICLE_COL1, RACE_VEHICLE_COL2, 0);
	SetVehicleVirtualWorld(veh, RACE_VIRTUAL_WORLD);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, RACE_VIRTUAL_WORLD);
	SetVehicleParamsEx(veh, true, false, false, true, false, false, false);
	SetVehicleParamsForPlayer(veh, playerid, false, false);
	PutPlayerInVehicle(playerid, veh, 0);
	SetPVarInt(playerid, PVAR_TAG"currentVehID", veh);
	
	TogglePlayerControllable(playerid, false);
	SetPVarInt(playerid, PVAR_TAG"respawnTimer", SetTimerEx("respawnUnfreeze", RESPAWN_TIME, false, "i", playerid));
	GameTextForPlayer(playerid, "Respawning", RESPAWN_TIME + 200, 3);
	SendClientMessage(playerid, COL_TEXT_IMPORTANT, " [!] NOTE: "COL_EMB_REG"You have been respawned in the race.");
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

forward respawnUnfreeze(playerid);
public respawnUnfreeze(playerid)
{
	if (!IsPlayerConnected(playerid)) return 1;
	TogglePlayerControllable(playerid, true);
	DeletePVar(playerid, PVAR_TAG"respawnTimer");
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

getFirstEmptyCPSlot(race)
{
	if (0 <= race < MAX_RACES && raceInfo[race][rHost] != INVALID_PLAYER_ID)
	{
		for (new c; c < MAX_CHECKPOINTS + 2; c++)
		{
			if (raceCheckpointList[race][c][0] || raceCheckpointList[race][c][1] || raceCheckpointList[race][c][2]) continue;
			return c;
		}
	}
	return MAX_CHECKPOINTS + 2;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

updateContestantList(race)
{
	new list[255], amount, curlen = 32, bool: stopadding = false;
	for (new s; s < MAX_CONTESTANTS; s++)
	{
		if (racePeopleInRace[race][s][0] != INVALID_PLAYER_ID)
		{
			new pName[MAX_PLAYER_NAME];
			curlen += GetPlayerName(racePeopleInRace[race][s][0], pName, MAX_PLAYER_NAME);
			
			if (curlen < sizeof(list) - 16)
			{
				strcat(list, "~n~ - ");
				strcat(list, pName);
			}
			else if (stopadding == false)
			{
				stopadding = true;
				strcat(list, "~n~ - and more!");
			}
			amount++;
		}
	}
	format(list, sizeof(list), "~r~Contestants (%i of "#MAX_CONTESTANTS"):~w~%s", amount, list);
	if (joinMenuRaceInfo[race][2] == Text: INVALID_TEXT_DRAW)
	{
		joinMenuRaceInfo[race][2] = TextDrawCreate(MENU_X + 410.0, MENU_Y + 150.0, list);
		TextDrawColor(joinMenuRaceInfo[race][2], COL_MENU_REGULAR);
		TextDrawLetterSize(joinMenuRaceInfo[race][2], 0.25, 1.2);
		TextDrawSetOutline(joinMenuRaceInfo[race][2], 1);
	}
	else
	{
		TextDrawSetString(joinMenuRaceInfo[race][2], list);
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

updatePlayerGUI(playerid)
{
	new PlayerText: gui = PlayerText: GetPVarInt(playerid, PVAR_TAG"racePlayerTD");
	if (gui)
	{
		new race = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (!race) return 0;
		race -= 2;
		gui--;
		
		new startspot = GetPVarInt(playerid, PVAR_TAG"startSpotI");
		if (racePeopleInRace[race][startspot][0] != playerid) return 0;
		
		new str[64], cp = GetPVarInt(playerid, PVAR_TAG"currentCPID") - 2;
		format(str, sizeof(str), "~r~Position: ~w~%i/%i~n~~r~Checkpoint: ~w~%i/%i__", racePeopleInRace[race][startspot][1], raceInfo[race][rPlayerAmount], (cp > 0) ? cp : 0, raceInfo[race][rCPAmount]);
		PlayerTextDrawSetString(playerid, gui, str);
		PlayerTextDrawShow(playerid, gui);
	}
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

showText(playerid, text[], time)
{
	new PlayerText: textitem = PlayerText: GetPVarInt(playerid, PVAR_TAG"SubTextID");
	if (textitem)
	{
		PlayerTextDrawHide(playerid, textitem - PlayerText: 1);
		PlayerTextDrawDestroy(playerid, textitem - PlayerText: 1);
	}
	
	textitem = CreatePlayerTextDraw(playerid, 380.0, 350.0, text);
	PlayerTextDrawLetterSize(playerid, textitem, 0.5, 2.0);
	PlayerTextDrawAlignment(playerid, textitem, 2);
	PlayerTextDrawTextSize(playerid, textitem, 300.0, 450.0);
	PlayerTextDrawShow(playerid, textitem);
	SetPVarInt(playerid, PVAR_TAG"SubTextID", _:textitem + 1);

	new timer = GetPVarInt(playerid, PVAR_TAG"SubTextTimer");
	if (timer)
	{
		KillTimer(timer);
	}
	SetPVarInt(playerid, PVAR_TAG"SubTextTimer", SetTimerEx("removeText", time, false, "i", playerid));
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

forward removeText(playerid);
public removeText(playerid)
{
	new PlayerText: textitem = PlayerText: GetPVarInt(playerid, PVAR_TAG"SubTextID");
	if (textitem)
	{
		PlayerTextDrawHide(playerid, textitem - PlayerText: 1);
		PlayerTextDrawDestroy(playerid, textitem - PlayerText: 1);
	}
	DeletePVar(playerid, PVAR_TAG"SubTextID");
	
	new timer = GetPVarInt(playerid, PVAR_TAG"SubTextTimer");
	if (timer)
	{
		KillTimer(timer);
	}
	DeletePVar(playerid, PVAR_TAG"SubTextTimer");
	return 1;
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#if defined RRG_is_include // Include stuff
	#undef MENU_X 
	#undef MENU_Y 
	#undef MAX_VEHICLE_NAME

	// - - OnGameModeInit - -
	#if defined RRG_OnGameModeInit
		forward RRG_OnGameModeInit();
	#endif
	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif
	#define OnGameModeInit RRG_OnGameModeInit
	
	// - - OnGameModeExit - -
	#if defined RRG_OnGameModeExit
		forward RRG_OnGameModeExit();
	#endif
	#if defined _ALS_OnGameModeExit
		#undef OnGameModeExit
	#else
		#define _ALS_OnGameModeExit
	#endif
	#define OnGameModeExit RRG_OnGameModeExit
	
	// - - OnFilterScriptInit - -
	#if defined RRG_OnFilterScriptInit
		forward RRG_OnFilterScriptInit();
	#endif
	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif
	#define OnFilterScriptInit RRG_OnFilterScriptInit
	
	// - - OnFilterScriptExit - -
	#if defined RRG_OnFilterScriptExit
		forward RRG_OnFilterScriptExit();
	#endif
	#if defined _ALS_OnFilterScriptExit
		#undef OnFilterScriptExit
	#else
		#define _ALS_OnFilterScriptExit
	#endif
	#define OnFilterScriptExit RRG_OnFilterScriptExit
	
	// - - OnPlayerSpawn - -
	#if defined RRG_OnPlayerSpawn
		forward RRG_OnPlayerSpawn(playerid);
	#endif
	#if defined _ALS_OnPlayerSpawn
		#undef OnPlayerSpawn
	#else
		#define _ALS_OnPlayerSpawn
	#endif
	#define OnPlayerSpawn RRG_OnPlayerSpawn
	
	// - - OnPlayerDisconnect - -
	#if defined RRG_OnPlayerDisconnect
		forward RRG_OnPlayerDisconnect(playerid, reason);
	#endif
	#if defined _ALS_OnPlayerDisconnect
		#undef OnPlayerDisconnect
	#else
		#define _ALS_OnPlayerDisconnect
	#endif
	#define OnPlayerDisconnect RRG_OnPlayerDisconnect
	
	#if !defined RRG_DisableCommands
		// - - OnPlayerCommandText - -
		#if defined RRG_OnPlayerCommandText
			forward RRG_OnPlayerCommandText(playerid, cmdtext[]);
		#endif
		#if defined _ALS_OnPlayerCommandText
			#undef OnPlayerCommandText
		#else
			#define _ALS_OnPlayerCommandText
		#endif
		#define OnPlayerCommandText RRG_OnPlayerCommandText
	#endif
	
	// - - OnPlayerClickTextDraw - -
	#if defined RRG_OnPlayerUpdate
		forward RRG_OnPlayerUpdate(playerid);
	#endif
	#if defined _ALS_OnPlayerClickTextDraw
		#undef OnPlayerClickTextDraw
	#else
		#define _ALS_OnPlayerClickTextDraw
	#endif
	#define OnPlayerClickTextDraw RRG_OnPlayerClickTextDraw
	forward RRG_OnPlayerClickTextDraw(playerid, Text:clickedid);
	
	// - - OnDialogResponse - -
	#if defined RRG_OnPlayerUpdate
		forward RRG_OnPlayerUpdate(playerid);
	#endif
	#if defined _ALS_OnDialogResponse
		#undef OnDialogResponse
	#else
		#define _ALS_OnDialogResponse
	#endif
	#define OnDialogResponse RRG_OnDialogResponse
	forward RRG_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
	
	// - - GPS_WhenRouteIsCalculated - -
	#if defined RRG_OnPlayerUpdate
		forward RRG_OnPlayerUpdate(playerid);
	#endif
	#if defined _ALS_GPS_WhenRouteIsCalculated
		#undef GPS_WhenRouteIsCalculated
	#else
		#define _ALS_GPS_WhenRouteIsCalculated
	#endif
	#define GPS_WhenRouteIsCalculated RRG_GPS_WhenRouteIsCalculated
	forward RRG_GPS_WhenRouteIsCalculated(routeid, node_id_array[], amount_of_nodes, Float:distance, Float:Polygon[], Polygon_Size, Float:NodePosX[], Float:NodePosY[], Float:NodePosZ[]);
	
	// - - OnPlayerEnterRaceCheckpoint - -
	#if defined RRG_OnPlayerUpdate
		forward RRG_OnPlayerUpdate(playerid);
	#endif
	#if defined _ALS_OnPlayerEnterRaceCP
		#undef OnPlayerEnterRaceCheckpoint
	#else
		#define _ALS_OnPlayerEnterRaceCP
	#endif
	#define OnPlayerEnterRaceCheckpoint RRG_OnPlayerEnterRaceCP
	forward RRG_OnPlayerEnterRaceCP(playerid);
	
	// - - OnPlayerUpdate - -
	#if defined RRG_OnPlayerUpdate
		forward RRG_OnPlayerUpdate(playerid);
	#endif
	#if defined _ALS_OnPlayerUpdate
		#undef OnPlayerUpdate
	#else
		#define _ALS_OnPlayerUpdate
	#endif
	#define OnPlayerUpdate RRG_OnPlayerUpdate
	
	// - - OnVehicleStreamIn - -
	#if defined RRG_OnVehicleStreamIn
		forward RRG_OnVehicleStreamIn(vehicleid, forplayerid);
	#endif
	#if defined _ALS_OnVehicleStreamIn
		#undef OnVehicleStreamIn
	#else
		#define _ALS_OnVehicleStreamIn
	#endif
	#define OnVehicleStreamIn RRG_OnVehicleStreamIn
	
	
	// - - OnPlayerStateChange - -
	#if defined RRG_OnPlayerStateChange
		forward RRG_OnPlayerStateChange(playerid, newstate, oldstate);
	#endif
	#if defined _ALS_OnPlayerStateChange
		#undef OnPlayerStateChange
	#else
		#define _ALS_OnPlayerStateChange
	#endif
	#define OnPlayerStateChange RRG_OnPlayerStateChange
	
	
	/* Planned INCLUDE functions:
		// For use, see example scripts. Do not use non-listed internal functions, they might cause problems.
		
		// --- Defines
		
			RRG_DisableCommands
				if defined, will disable commands like /rrg
	
		// --- Main functions
		
		native generateRandomRace(hostplayer, Float: startX, Float: startY, Float: startZ, Float: distance, vehiclemodel, bool: private, slot = -1, Float: nodedistance = 1000.0, bool: nodeareas = false);
			'private' parameter will only have effect if 'slot' = -1.
			'slot' parameter defines the internal array slot at which the race is created. 
				(With default settings: 0 to 12 are public races, 13 to 24 are private races.
				If 'slot' = -1, it will internally search for an empty slot.
				Be aware that you can overwrite races if you use a slot which is already used.)
			'nodedistance' and 'nodeareas' are used in the GPS Plugin's NearestNodeFromPoint function, for 'MaxDist' and 'UseAreas' respectively.
			returns -1 if unable to create race. (Hostplayer might not be online, vehicle model is invalid, starting position is invalid or no slots are available at the moment.)
			returns slot ID of created race.
			calls onRandomRaceGenerated(raceid, hostplayer, Float: totaldistance, totalcps) when done.
			
		native startRace(raceid, bool: countdown = true);
			returns 0 if race doesn't exist.
			returns 1 otherwise.
			setting countdown to 'false' will start the race immediately. (useful for custom countdowns)
			
		native removeRace(raceid);
			returns 0 if race doesn't exist.
			returns 1 otherwise and removes the entire race from memory.
			
		// --- Player functions
			
		native putPlayerInRace(playerid, raceid);
			returns 0 if race doesn't exist or player is not online or there is no room for more players in the race.
			returns 1 otherwise.
			
		native removePlayerFromRace(playerid);
			returns 0 if player is not online or not in a race.
			returns 1 otherwise.
			removing the host causes the script to pick another host, the race will be removed if there's no other contestant present.
			
		native isPlayerInRace(playerid, raceid);
			returns 1 if player is in the specified race, returns 0 if not.
			
		native getPlayerRace(playerid);
			returns the ID of the race the player is in.
			returns -1 if player is not in a race or player is not online.
			
		native getPlayerCurrentCheckpoint(playerid);
			returns 0 if player is not in race or race hasn't started yet or player is not online.
			returns number of current checkpoint of player. 
			
		native isPlayerInRaceVehicle(playerid);
			returns 1 if player is in his race vehicle, returns 0 if not.
			
		native getPlayerRaceVehicleID(playerid);
			returns 0 if player is not in race or if player is not online.
			returns the ID of the player's race vehicle otherwise.
			
		native isPlayerFinishedInRace(playerid);
			returns 0 if player still in race or not in race or player is not online.
			returns 1 if player has finished his current race.
			
		native getPlayerRacePosition(playerid);
			returns 0 if player not online or not in race or race hasn't started yet.
			returns current position otherwise.
			
		native showJoinMenuForPlayer(playerid);
			returns 0 if player is not online.
			returns 1 otherwise.
			
		// --- Race functions
		
		native isRaceValid(raceid);
			returns 0 if race doesn't exist.
			returns 1 if race does exist.
		
		native isRacePublic(raceid);
			returns 0 if race doesn't exist or is not public.
			returns 1 if race is public.
			
		native isRacePrivate(raceid);
			returns 0 if race doesn't exist or is not private.
			returns 1 if race is private.
		
		native getRaceHost(raceid);
			returns the playerid of the host of the race.
			returns INVALID_PLAYER_ID if race doesn't exist.
			
		native getRaceState(raceid);
			returns 0 (RACE_STATE_NONE) if not started or doesn't exist.
			returns 1 (RACE_STATE_CREATED) if race has been created but not yet started.
			returns 2 (RACE_STATE_COUNTING) if countdown has started.
			returns 3 (RACE_STATE_STARTED if race has started.
			returns 4 (RACE_STATE_ENDED) if race has ended (everyone has finished and race is counting down to removal).
			
		native getRaceCheckpointAmount(raceid);
			returns 0 if race doesn't exist.
			returns amount of checkpoints otherwise.
			
		native isValidRaceCheckpoint(raceid, cpi);
			returns 0 if race doesn't exist or cpid is not valid.
			returns 1 if checkpoint does exist.
		
		native getRaceCheckpointPos(raceid, cpid, &Float: cpx, &Float: cpy, &Float: cpz);
			returns 0 if race doesn't exist or cpid is out of range.
			returns 1 along with coordinates if checkpoint does exist.
			
		native getRaceContestantAmount(raceid);
			returns 0 if race doesn't exist.
			returns amount of contestants in race otherwise.
			
		native getRaceFinishedAmount(raceid);
			returns 0 if race doesn't exist or no-one has finished yet.
			returns amount of finished contestants otherwise.
			
		native Float: getRaceDistance(raceid);
			returns 0.0 if race doesn't exist.
			returns the distance of the race in meters otherwise.
			
		native getRaceVehicleModel(raceid);
			returns 0 if race doesn't exist.
			returns modelid otherwise.
	*/
	
	forward onRandomRaceCreated(raceid, hostplayer, Float: totaldistance, totalcps); // called when random race is created using createRace.
	forward onPlayerJoinRace(playerid, raceid); // called when someone joins a race.
	forward onPlayerFinishRace(playerid, raceid, position); // called when someone finishes a race.
	forward onPlayerCheckCP(playerid, raceid, cpid); // called when someone checks a checkpoint.
	forward onRaceCountdown(raceid); // called when the internal countdown starts (will not be called when startRace parameter 'countdown' is false)
	forward onRaceStart(raceid); // called when the race starts
	forward onRaceRemove(raceid); // called when a race gets removed.
	
	
	
	
	// Implemented functions for include specifically, see list above for more info 
	
	// generateRandomRace
	stock generateRandomRace(hostplayer, Float: startX, Float: startY, Float: startZ, Float: distance, vehiclemodel, bool: private, slot = -1, Float: nodedistance = 9999.99, bool: nodeareas = false)
	{
		if (!IsPlayerConnected(hostplayer)) return -1;
		
		if (!(400 <= vehiclemodel <= 611)) return -1;

		// Set min and max possible slot
		new minr = MAX_PUBLIC_RACES, maxr = MAX_RACES;
		if (private == true)
		{
			minr = 0;
			maxr = MAX_PUBLIC_RACES;
		}
		
		// Get first empty slot
		new freeSlot = -1;
		for (new r = minr; r < maxr; r++)
		{
			if (raceInfo[r][rHost] == INVALID_PLAYER_ID)
			{
				freeSlot = r;
				break;
			}
		}
		if (freeSlot == -1) return -1;
		
		// Get a node in the area
		new closestNode = NearestNodeFromPoint(startX, startY, startZ, nodedistance, .UseAreas = _:nodeareas);
		if (closestNode == -1) return -1;
		
		// Save information onto the host player
		SetPVarInt(hostplayer, PVAR_TAG"currentRaceID", freeSlot + 2);
		SetPVarFloat(hostplayer, PVAR_TAG"totalRaceDistance", distance);
		SetPVarInt(hostplayer, PVAR_TAG"selectedVehicle", vehiclemodel);
		raceInfo[slot][rHost] = hostplayer;
		
		// Start calculation
		calculateNextRacePart(freeSlot, 0, closestNode, true);
		return freeSlot;
	}
	
	// startRace - is internal function
	
	stock removeRace(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0;
		
		cleanRace(raceid);
		return 1;
	}
	
	// ---
	
	// putPlayerInRace - is internal function
	
	// removePlayerFromRace - is internal function
	
	stock isPlayerInRace(playerid, raceid)
	{
		if (!IsPlayerConnected(playerid)) return 0;
		
		
		if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
		{
			new playerrace = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
			
			if (playerrace)
			{
				playerrace -= 2;
				
				if (playerrace == raceid) return 1;
			}			
		}
		return 0;
	}
	
	stock getPlayerRace(playerid)
	{
		if (!IsPlayerConnected(playerid)) return -1;
		
		new raceid = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (raceid)
		{
			raceid -= 2;
			
			if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID) return raceid;
		}
		return -1;
	}
	
	stock getPlayerCurrentCheckpoint(playerid)
	{
		if (!IsPlayerConnected(playerid)) return 0;
		
		new raceid = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (raceid)
		{
			raceid -= 2;
			
			if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID && raceInfo[raceid][rStarted] == 2)
			{
				return (GetPVarInt(playerid, PVAR_TAG"currentCPID") - 2);				
			}
		}
		return 0;
	}
	
	stock isPlayerInRaceVehicle(playerid)
	{
		if (!IsPlayerConnected(playerid)) return 0;
		
		new raceid = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (raceid)
		{
			raceid -= 2;
			
			if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
			{
				new veh = GetPVarInt(playerid, PVAR_TAG"currentVehID");
				if (IsPlayerInVehicle(playerid, veh))
				{
					return 1;
				}
			}
		}
		return 0;
	}	
	
	stock getPlayerRaceVehicleID(playerid)
	{
		if (!IsPlayerConnected(playerid)) return 0;
		
		new raceid = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (raceid)
		{
			raceid -= 2;
			
			if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
			{
				new veh = GetPVarInt(playerid, PVAR_TAG"currentVehID");
				if (veh)
				{
					return veh;
				}
			}
		}
		return 0;
	}
	
	stock isPlayerFinishedInRace(playerid)
	{
		if (!IsPlayerConnected(playerid)) return 0;
		
		new raceid = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (raceid && GetPVarInt(playerid, PVAR_TAG"isFinished"))
		{
			return 1;
		}
		return 0;
	}
	
	stock getPlayerRacePosition(playerid)
	{
		if (!IsPlayerConnected(playerid)) return 0;
		
		new raceid = GetPVarInt(playerid, PVAR_TAG"currentRaceID");
		if (raceid)
		{
			raceid -= 2;
			
			if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID && raceInfo[raceid][rStarted] == 2)
			{
				new startspot = GetPVarInt(playerid, PVAR_TAG"startSpotI");
				if (racePeopleInRace[raceid][startspot][0] == playerid)
				{
					return racePeopleInRace[raceid][startspot][1];
				}
			}
		}
		return 0;
	}
	
	// showJoinMenuForPlayer - is internal function
	
	// --- 
	
	stock isRaceValid(raceid)
	{
		if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
		{
			return 1;
		}
		return 0;
	}
	
	stock isRacePublic(raceid)
	{
		if (0 <= raceid < MAX_PUBLIC_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
		{
			return 1;
		}
		return 0;
	}
	
	stock isRacePrivate(raceid)
	{
		if (MAX_RACES > raceid >= MAX_PUBLIC_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
		{
			return 1;
		}
		return 0;
	}
	
	stock getRaceHost(raceid)
	{
		if (0 <= raceid < MAX_RACES)
		{
			return raceInfo[raceid][rHost];
		}
		return INVALID_PLAYER_ID;
	}
			
	enum
	{
		RACE_STATE_NONE = 0,	// not started or doesn't exist.
		RACE_STATE_CREATED,		// race has been created but not yet started.
		RACE_STATE_COUNTING,	// countdown has started.
		RACE_STATE_STARTED,		// race has started.
		RACE_STATE_ENDED		// race has ended (everyone has finished and race is counting down to removal).
	}
	
	stock getRaceState(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return RACE_STATE_NONE;
		
		switch (raceInfo[raceid][rStarted])
		{
			case 0: return RACE_STATE_CREATED;
			case 1: return RACE_STATE_COUNTING;
			case 2:
			{
				if (raceInfo[raceid][rPlayerAmount] == raceInfo[raceid][rFinishedPlayers])
				{
					return RACE_STATE_ENDED;
				}
				else
				{
					return RACE_STATE_STARTED;
				}
			}
		}
		return RACE_STATE_NONE;
	}
	
	stock getRaceCheckpointAmount(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0;
		
		return raceInfo[raceid][rCPAmount];	
	}
	
	stock isValidRaceCheckpoint(raceid, cpid)
	{
		if (0 <= raceid < MAX_RACES && raceInfo[raceid][rHost] != INVALID_PLAYER_ID)
		{
			cpid += 2; // do not include invisible spawn checkpoints
			
			if (2 <= cpid < MAX_CHECKPOINTS && cpid <= raceInfo[raceid][rCPAmount])
			{
				return 1;
			}
		}
		return 0;
	}
	
	stock getRaceCheckpointPos(raceid, cpid, &Float: cpx, &Float: cpy, &Float: cpz)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0;
		
		cpid += 2; // do not include invisible spawn checkpoints
		
		if (2 <= cpid < MAX_CHECKPOINTS && cpid <= raceInfo[raceid][rCPAmount])
		{		
			cpx = raceCheckpointList[raceid][cpid][0];
			cpy = raceCheckpointList[raceid][cpid][1];
			cpz = raceCheckpointList[raceid][cpid][2];
			return 1;
		}
		return 0;
	}
	
	stock getRaceContestantAmount(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0;
		
		return raceInfo[raceid][rPlayerAmount];	
	}
	
	stock getRaceFinishedAmount(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0;
		
		return raceInfo[raceid][rFinishedPlayers];	
	}
	
	stock Float: getRaceDistance(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0.0;
		
		return raceInfo[raceid][rDistance];	
	}
	
	stock getRaceVehicleModel(raceid)
	{
		if (!(0 <= raceid < MAX_RACES) || raceInfo[raceid][rHost] == INVALID_PLAYER_ID) return 0;
		
		return raceInfo[raceid][rVehicleModel];	
	}
#endif
