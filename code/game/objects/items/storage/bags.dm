/obj/item/storage/bag
	name = "bag"
	desc = "A leather bag. Not quite as sizable or comfortable as a backpack."
	icon_state = "bag"
	inhand_icon_state = "bag"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT

/obj/item/storage/bag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 5 * WEIGHT_CLASS_SMALL
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_items = 5 * WEIGHT_CLASS_SMALL
