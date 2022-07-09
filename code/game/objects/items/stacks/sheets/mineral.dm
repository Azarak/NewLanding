/*
Mineral Sheets
	Contains:
		- Sandstone
		- Sandbags
		- Diamond
		- Snow
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Clown
		- Titanium
		- Plastitanium
	Others:
		- Adamantine
		- Mythril
		- Alien Alloy
		- Coal
*/

/*
 * Sandstone
 */

GLOBAL_LIST_INIT(sandstone_recipes, list ( \
	new/datum/stack_recipe("fireplace", /obj/structure/fireplace, 15, time = 60, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("Breakdown into sand", /obj/item/stack/ore/glass, 1, one_per_turf = FALSE, on_floor = TRUE) \
	))

/obj/item/stack/sheet/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	inhand_icon_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	mats_per_unit = list(/datum/material/sandstone=MINERAL_MATERIAL_AMOUNT)
	sheettype = "sandstone"
	merge_type = /obj/item/stack/sheet/sandstone
	material_type = /datum/material/sandstone

/obj/item/stack/sheet/sandstone/get_main_recipes()
	. = ..()
	. += GLOB.sandstone_recipes

/obj/item/stack/sheet/sandstone/thirty
	amount = 30

/*
 * Sandbags
 */

/obj/item/stack/sheet/sandbags
	name = "sandbags"
	icon_state = "sandbags"
	singular_name = "sandbag"
	layer = LOW_ITEM_LAYER
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/sandbags

GLOBAL_LIST_INIT(sandbag_recipes, list ( \
	new/datum/stack_recipe("sandbags", /obj/structure/barricade/sandbags, 1, time = 25, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/sandbags/get_main_recipes()
	. = ..()
	. += GLOB.sandbag_recipes

/obj/item/emptysandbag
	name = "empty sandbag"
	desc = "A bag to be filled with sand."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "sandbag"
	w_class = WEIGHT_CLASS_TINY

/obj/item/emptysandbag/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/G = W
		to_chat(user, SPAN_NOTICE("You fill the sandbag."))
		var/obj/item/stack/sheet/sandbags/I = new /obj/item/stack/sheet/sandbags(drop_location())
		qdel(src)
		if (Adjacent(user))
			user.put_in_hands(I)
		G.use(1)
	else
		return ..()

/*
 * Diamond
 */
/obj/item/stack/sheet/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	inhand_icon_state = "sheet-diamond"
	singular_name = "diamond"
	sheettype = "diamond"
	mats_per_unit = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 20)
	merge_type = /obj/item/stack/sheet/diamond
	material_type = /datum/material/diamond

GLOBAL_LIST_INIT(diamond_recipes, list ())

/obj/item/stack/sheet/diamond/get_main_recipes()
	. = ..()
	. += GLOB.diamond_recipes

/*
 * Gold
 */
/obj/item/stack/sheet/gold
	name = "gold"
	icon_state = "sheet-gold"
	inhand_icon_state = "sheet-gold"
	singular_name = "gold bar"
	sheettype = "gold"
	mats_per_unit = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gold = 20)
	merge_type = /obj/item/stack/sheet/gold
	material_type = /datum/material/gold

GLOBAL_LIST_INIT(gold_recipes, list ())

/obj/item/stack/sheet/gold/get_main_recipes()
	. = ..()
	. += GLOB.gold_recipes

/*
 * Silver
 */
/obj/item/stack/sheet/silver
	name = "silver"
	icon_state = "sheet-silver"
	inhand_icon_state = "sheet-silver"
	singular_name = "silver bar"
	sheettype = "silver"
	mats_per_unit = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/silver = 20)
	merge_type = /obj/item/stack/sheet/silver
	material_type = /datum/material/silver

GLOBAL_LIST_INIT(silver_recipes, list ())

/obj/item/stack/sheet/silver/get_main_recipes()
	. = ..()
	. += GLOB.silver_recipes


/*
 * Coal
 */

/obj/item/stack/sheet/coal
	name = "coal"
	desc = "Someone's gotten on the naughty list."
	icon = 'icons/obj/mining.dmi'
	icon_state = "slag"
	singular_name = "coal lump"
	merge_type = /obj/item/stack/sheet/coal
	grind_results = list(/datum/reagent/carbon = 20)
	novariants = TRUE

/obj/item/stack/sheet/coal/attackby(obj/item/W, mob/user, params)
	if(W.get_temperature() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Coal ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("Coal ignited by [key_name(user)] in [AREACOORD(T)]")
		fire_act(W.get_temperature())
		return TRUE
	else
		return ..()

/obj/item/stack/sheet/coal/fire_act(exposed_temperature, exposed_volume)
	qdel(src)

/obj/item/stack/sheet/coal/five
	amount = 5

/obj/item/stack/sheet/coal/ten
	amount = 10
