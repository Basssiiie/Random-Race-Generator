/*
     // - - - - - - - - - - - - - //
    //   Bonus Pickups for RRG   //
   // - - - - - - - - - - - - - // 

	Description:
	 This script is an example of using the
	 Random Race Generator as an include. This
	 example spawns bonus pickups inside some
	 checkpoints.
	 
	 Possible pickups are:
	  - nitro 2x;
	  - bomb;
	  - repair.
	  
	Note:
	 Do not run multiple RRG scripts in the same
	 server at once, it will duplicate the original
	 script and causes a waste of memory.
	 
	End note:
	 Feel free to edit this script as you like. You
	 are also allowed to borrow any code from it,
	 as long as you keep some credits to me.
	 Please do not claim this as your own.
	
	 If you have any problems with or questions
	 about this script, please contact me via the 
	 official SA-MP forums.
	 
	 Topic URL:
	 http://forum.sa-mp.com/showthread.php?t=437708
	 
	 GitHub URL:
	 https://github.com/Basssiiie/Random-Race-Generator
	
	Regards,
	 Basssiiie
	 
*/


// In order tell the Random Race Generator that you want to 
//  use it as an include, you need to include a_samp.inc first.
#include <a_samp>

// Make sure to also include the Random Race Generator itself.
// Note that this line will incorporate the whole RRG-script
//  into this new script, you don't have to load RRG in
//  server.cfg anymore. (load only this new script)
#include "RandomRaceGenerator.pwn"



// This number is the amount of checkpoints before a new pickup is spawned.
#define pickupInterval 5

// Define array size.
#define pickupArraySize (MAX_CHECKPOINTS / pickupInterval) - 1

// This array will store the pickup IDs of the bonus pickups.
new bonusPickups[MAX_RACES][pickupArraySize][2];


// When the race starts, spawn pickups:
public onRaceStart(raceid)
{
	new cp_amount = (getRaceCheckpointAmount(raceid) - 1); // all checkpoints minus finish.
	new current_cp = pickupInterval; 
	new previous_type = 0; // to prevent multiple pickups of the same type in a row.
	
	for (new p, end = pickupArraySize; p < end; p ++, current_cp += pickupInterval)
	{
		if (current_cp >= cp_amount || !isValidRaceCheckpoint(raceid, current_cp)) break;
		
		// Pick a pickup type randomly, must not be the same as previous checkpoint's pickup:
		new type = random(3) + 1, model = 0;
		while (previous_type == type)
		{
			type = random(3) + 1;
		}
		previous_type = type;
		
		// Set the model based on its type.
		switch (type)
		{
			case 1: model = 1010; // nitro
			case 2: model = 1252; // bomb
			case 3: model = 3096; // repair
		}
		
		// Get checkpoint position:
		new Float: cp_pos[3];
		getRaceCheckpointPos(raceid, current_cp, cp_pos[0], cp_pos[1], cp_pos[2]);
		cp_pos[0] += float(random(8)) - 3.5;
		cp_pos[1] += float(random(8)) - 3.5;
		cp_pos[2] += 1.5;
		
		// Spawn bonus pickup on checkpoint
		bonusPickups[raceid][p][0] = CreatePickup(model, 14, cp_pos[0], cp_pos[1], cp_pos[2], RACE_VIRTUAL_WORLD); 
		bonusPickups[raceid][p][1] = type;
	}
	return 1;
}

// When the race ends, remove pickups:
public onRaceRemove(raceid)
{
	for (new p, end = pickupArraySize; p < end; p++)
	{
		if (bonusPickups[raceid][p][1] == 0) continue;
		
		DestroyPickup(bonusPickups[raceid][p][0]);
		
		bonusPickups[raceid][p][0] = 0;
		bonusPickups[raceid][p][1] = 0;	
	}
	return 1;
}

// Set effects when pickup is picked up.
public OnPlayerPickUpPickup(playerid, pickupid)
{
	// Check if player is in race:
	new raceid = getPlayerRace(playerid);
	if (raceid == -1)
	{
		return 0;
	}
	
	// Get player race vehicle ID:
	new vehicleid = getPlayerRaceVehicleID(playerid);
	if (vehicleid == 0)
	{
		return 0;
	}
	
	// Cancel script if the player is not in his race vehicle.
	if (!IsPlayerInVehicle(playerid, vehicleid))
	{
		return 0;
	}
	
	// Search for corresponding pickup in array.
	for (new p, end = pickupArraySize; p < end; p++)
	{
		if (bonusPickups[raceid][p][0] != pickupid || bonusPickups[raceid][p][1] == 0) continue;
		
		// Trigger the effect.
		switch (bonusPickups[raceid][p][1])
		{
			case 1: // nitro 2x
			{
				AddVehicleComponent(vehicleid, 1009);
				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			}
			case 2: // bomb
			{
				new Float: pos[3];
				GetVehiclePos(vehicleid, pos[0], pos[1], pos[2]);
				pos[0] += float(random(7) - 3);
				pos[1] += float(random(7) - 3);
				pos[2] -= 1.0;
				CreateExplosion(pos[0], pos[1], pos[2], 3, 5.0);
			}
			case 3: // repair
			{
				RepairVehicle(vehicleid);
				SetVehicleHealth(vehicleid, 1000.0);
			}
		}
		
		// Remove the pickup
		DestroyPickup(bonusPickups[raceid][p][0]);
		bonusPickups[raceid][p][0] = 0;
		bonusPickups[raceid][p][1] = 0;
		return 1;
	}
	return 0;
}
