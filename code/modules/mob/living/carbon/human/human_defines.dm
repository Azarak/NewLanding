/// Any humanoid (non-Xeno) mob, such as humans, plasmamen, lizards.
/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,FAN_HUD)
	hud_type = /datum/hud/human
	can_buckle = TRUE
	buckle_lying = 0
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	can_be_shoved_into = TRUE

	var/skin_tone = "caucasian1" //Skin tone

	var/lip_style = null //no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30 //Player's age

	//consider updating /mob/living/carbon/human/copy_clothing_prefs() if adding more of these
	var/jumpsuit_style = PREF_SUIT //suit/skirt

	//Equipment slots
	var/obj/item/clothing/wear_suit = null
	var/obj/item/clothing/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	/// What types of mobs are allowed to ride/buckle to this mob
	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/parrot))
	var/lastpuke = 0
	var/last_fire_update
	var/account_id

	var/hardcore_survival_score = 0
	/// For agendered spessmen, which body type to use
	var/body_type = MALE

	/// How many "units of blood" we have on our hands
	var/blood_in_hands = 0

	/// The core temperature of the human compaired to the skin temp of the body
	var/coretemperature = BODYTEMP_NORMAL

	///Exposure to damaging heat levels increases stacks, stacks clean over time when temperatures are lower. Stack is consumed to add a wound.
	var/heat_exposure_stacks = 0

	///human specific screwyhuds from hallucinations (define key (bodypart) to int value (severity)) - see /datum/hallucination/fake_health_doll
	var/hal_screwydoll
	/// When an braindead player has their equipment fiddled with, we log that info here for when they come back so they know who took their ID while they were DC'd for 30 seconds
	var/list/afk_thefts

	///Flags for showing/hiding underwear, toggleabley by a verb
	var/underwear_visibility = NONE
	///Render key for mutant bodyparts, utilized to reduce the amount of re-rendering
	var/mutant_renderkey = ""
	///Whether the human is trying to hide their mutant bodyparts under their clothes intentially
	var/try_hide_mutant_parts = FALSE

