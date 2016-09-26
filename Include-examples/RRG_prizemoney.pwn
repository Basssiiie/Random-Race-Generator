/*
     // - - - - - - - - - - - - //
    //   Prize Money for RRG   //
   // - - - - - - - - - - - - // 

	Description:
	 This script is an example of using the
	 Random Race Generator as an include. This
	 example gives money to the players who
	 finish 1st, 2nd or 3rd in a race.
	 
	 If you want to use it, it might be a good
	 idea to incorporate your anti-cheat into
	 this example script.
	 
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
	
	Regards,
	 Basssiiie
	 
*/


// In order tell the Random Race Generator that you want to 
// use it as an include, you need to include a_samp.inc first.
#include <a_samp>

// Make sure to also include the Random Race Generator itself.
// Note that this line will incorporate the whole RRG-script
// into this new script, you don't have to load RRG in
// server.cfg anymore. (load only this new script)
#include "RandomRaceGenerator.pwn"



// This callback will be called when a player finishes the game:
public onPlayerFinishRace(playerid, raceid, position)
{
	// Check its finished position and give money accordingly.
	switch (position)
	{
		case 1: givePrizeMoney(playerid, 1000);
		case 2: givePrizeMoney(playerid, 500);
		case 3: givePrizeMoney(playerid, 200);
	}	
	return 1;
}

// This function gives the money to the player and sends a notification.
stock givePrizeMoney(playerid, amount)
{
	GivePlayerMoney(playerid, amount);
	
	new str[128];
	format(str, sizeof(str), " [!] Great job! You have earned $%i in prize money.", amount);
	SendClientMessage(playerid, COL_TEXT_REG, str);
	return 1;
}
