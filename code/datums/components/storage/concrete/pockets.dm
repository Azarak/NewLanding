/datum/component/storage/concrete/pockets
	max_items = 2
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 50
	rustle_sound = FALSE

/datum/component/storage/concrete/pockets/handle_item_insertion(obj/item/I, prevent_warning, mob/user)
	. = ..()
	if(. && silent && !prevent_warning)
		if(quickdraw)
			to_chat(user, SPAN_NOTICE("You discreetly slip [I] into [parent]. Alt-click or Right-click [parent] to remove it."))
		else
			to_chat(user, SPAN_NOTICE("You discreetly slip [I] into [parent]."))

/datum/component/storage/concrete/pockets/small
	max_items = 1
	max_w_class = WEIGHT_CLASS_SMALL
	attack_hand_interact = FALSE

/datum/component/storage/concrete/pockets/tiny
	max_items = 1
	max_w_class = WEIGHT_CLASS_TINY
	attack_hand_interact = FALSE

/datum/component/storage/concrete/pockets/shoes
	attack_hand_interact = FALSE
	quickdraw = TRUE
	silent = TRUE

/datum/component/storage/concrete/pockets/shoes/Initialize()
	. = ..()
	set_holdable(list(
		/obj/item/kitchen/knife, /obj/item/pen,
		/obj/item/scalpel, /obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
		/obj/item/screwdriver, /obj/item/weldingtool/mini,
		))

/datum/component/storage/concrete/pockets/helmet
	quickdraw = TRUE
	max_combined_w_class = 6

/datum/component/storage/concrete/pockets/helmet/Initialize()
	. = ..()
	set_holdable(list(/obj/item/reagent_containers/food/drinks/bottle/vodka,
					  /obj/item/reagent_containers/food/drinks/bottle/molotov,
					  /obj/item/reagent_containers/food/drinks/drinkingglass))
