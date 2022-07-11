/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

/proc/ui_hand_position(i) //values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
	var/x_off = -(!(i % 2))
	var/y_off = round((i-1) / 2)
	return"CENTER+[x_off]:16,SOUTH+[y_off]:5"

/proc/ui_equip_position(mob/M)
	var/y_off = round((M.held_items.len-1) / 2) //values based on old equip ui position (CENTER: +/-16,SOUTH+1:5)
	return "CENTER:-16,SOUTH+[y_off+1]:5"

/proc/ui_swaphand_position(mob/M, which = 1) //values based on old swaphand ui positions (CENTER: +/-16,SOUTH+1:5)
	var/x_off = which == 1 ? -1 : 0
	var/y_off = round((M.held_items.len-1) / 2)
	return "CENTER+[x_off]:16,SOUTH+[y_off+1]:5"

//Lower left, persistent menu
#define ui_inventory "WEST:6,SOUTH:5"

//Middle left indicators
#define ui_lingchemdisplay "WEST,CENTER-1:15"
#define ui_lingstingdisplay "WEST:6,CENTER-3:11"

//Lower center, persistent menu
#define ui_sstore1 "CENTER-5:10,SOUTH:5"
#define ui_id "CENTER-4:12,SOUTH:5"
#define ui_belt "CENTER-3:14,SOUTH:5"
#define ui_back "CENTER-2:14,SOUTH:5"
#define ui_storage1 "CENTER+1:18,SOUTH:5"
#define ui_storage2 "CENTER+2:20,SOUTH:5"
#define ui_combo "CENTER+4:24,SOUTH+1:7" //combo meter for martial arts

//Lower right, persistent menu
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_above_movement "EAST-2:26,SOUTH+1:7"
#define ui_above_intent "EAST-3:24, SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_combat_toggle "EAST-3:24,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,SOUTH:5" //alternative intent switcher for when the interface is hidden (F12)
#define ui_crafting "EAST-4:22,SOUTH:5"
#define ui_building "EAST-4:22,SOUTH:21"
#define ui_language_menu "EAST-4:6,SOUTH:21"
#define ui_skill_menu "EAST-4:22,SOUTH:5"

//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:28,CENTER+5:27"
#define ui_alert2 "EAST-1:28,CENTER+4:25"
#define ui_alert3 "EAST-1:28,CENTER+3:23"
#define ui_alert4 "EAST-1:28,CENTER+2:21"
#define ui_alert5 "EAST-1:28,CENTER+1:19"

//Middle right (status indicators)
#define ui_healthdoll "EAST-1:28,CENTER-2:13"
#define ui_health "EAST-1:28,CENTER-1:15"
#define ui_stamina "EAST-1:28,CENTER:17"

//Pop-up inventory
#define ui_shoes "WEST+1:8,SOUTH:5"
#define ui_iclothing "WEST:6,SOUTH+1:7"
#define ui_oclothing "WEST+1:8,SOUTH+1:7"
#define ui_gloves "WEST+2:10,SOUTH+1:7"
#define ui_glasses "WEST:6,SOUTH+3:11"
#define ui_mask "WEST+1:8,SOUTH+2:9"
#define ui_ears "WEST+2:10,SOUTH+2:9"
#define ui_neck "WEST:6,SOUTH+2:9"
#define ui_head "WEST+1:8,SOUTH+3:11"

//Generic living
#define ui_living_pull "EAST-1:28,CENTER-3:15"
#define ui_living_healthdoll "EAST-1:28,CENTER-1:15"

//Monkeys
#define ui_monkey_head "CENTER-5:13,SOUTH:5"
#define ui_monkey_mask "CENTER-4:14,SOUTH:5"
#define ui_monkey_neck "CENTER-3:15,SOUTH:5"
#define ui_monkey_back "CENTER-2:16,SOUTH:5"

//Ghosts
#define ui_ghost_spawners_menu "SOUTH:6,CENTER-2:24"
#define ui_ghost_orbit "SOUTH:6,CENTER-1:24"
#define ui_ghost_reenter_corpse "SOUTH:6,CENTER:24"
#define ui_ghost_teleport "SOUTH:6,CENTER+1:24"
#define ui_ghost_pai "SOUTH: 6, CENTER+2:24"
#define ui_ghost_language_menu "SOUTH: 22, CENTER+3:8"

//Blobbernauts
#define ui_blobbernaut_overmind_health "EAST-1:28,CENTER+0:19"

