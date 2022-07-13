/* Backpacks
 * Contains:
 * Backpack
 * Backpack Types
 * Satchel Types
 */

/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	inhand_icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK //ERROOOOO
	resistance_flags = NONE
	max_integrity = 300
	worn_template_bodytypes = BODYTYPE_TESHARI
	greyscale_config_worn_template = /datum/greyscale_config/worn_template_backpack
	worn_template_greyscale_color = "#5B340F"

/obj/item/storage/backpack/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 4 * WEIGHT_CLASS_NORMAL
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 4 * WEIGHT_CLASS_NORMAL

/*
 * Backpack Types
 */

/obj/item/storage/backpack/rigid
	name = "rigid-frame backpack"
	desc = "A backpack built with a wooden, rigid frame, allowing for storing of much more items."

/obj/item/storage/backpack/rigid/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 6 * WEIGHT_CLASS_NORMAL
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 6 * WEIGHT_CLASS_NORMAL


/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	inhand_icon_state = "satchel"
	greyscale_config_worn_template = /datum/greyscale_config/worn_template_satchel
	worn_template_greyscale_color = "#5B340F"
