/obj/item/storage/tray
	name = "serving tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	worn_icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=3000)
	custom_price = PAYCHECK_ASSISTANT * 0.6

/obj/item/storage/tray/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.display_numerical_stacking = TRUE
	STR.click_gather = TRUE
	STR.max_w_class = WEIGHT_CLASS_NORMAL //Allows stuff such as Bowls, and normal sized foods, to fit.
	STR.set_holdable(list(
		/obj/item/reagent_containers/food,
		/obj/item/reagent_containers/glass,
		/obj/item/food,
		/obj/item/trash,
		/obj/item/kitchen,
		/obj/item/organ,
		)) //Should cover: Bottles, Beakers, Bowls, Booze, Glasses, Food, Food Containers, Food Trash, Organs, Tobacco Products, Lighters, and Kitchen Tools.
	STR.insert_preposition = "on"
	STR.max_items = 7

/obj/item/storage/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_QUICK_EMPTY)
	// Make each item scatter a bit
	for(var/obj/item/I in oldContents)
		INVOKE_ASYNC(src, .proc/do_scatter, I)

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, TRUE)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, TRUE)

	if(ishuman(M))
		if(prob(10))
			M.Paralyze(40)
	update_appearance()

/obj/item/storage/tray/proc/do_scatter(obj/item/I)
	for(var/i in 1 to rand(1,2))
		if(I)
			step(I, pick(NORTH,SOUTH,EAST,WEST))
			sleep(rand(2,4))

/obj/item/storage/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		var/mutable_appearance/I_copy = new(I)
		I_copy.plane = FLOAT_PLANE
		I_copy.layer = FLOAT_LAYER
		. += I_copy

/obj/item/storage/tray/Entered(atom/movable/arrived, direction)
	. = ..()
	update_appearance()

/obj/item/storage/tray/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()
