/obj/item/storage/pouch
	name = "pouch"
	icon = 'icons/obj/items/storage/pouch.dmi'
	desc = "An ordinary leather pouch. Useful to carry your heard earned coins in, or lead balls."
	icon_state = "pouch"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pouch/Initialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_items = 5
	STR.max_combined_w_class = WEIGHT_CLASS_SMALL * 5
	STR.set_holdable(list(/obj/item/stack/coin, /obj/item/stack/lead_ball))
	update_appearance()

/obj/item/storage/pouch/play_drop_sound()
	if(get_stack_fullfillment() >= 5)
		playsound(src, 'sound/accursed/coins.ogg', 50, ignore_walls = FALSE, vary = TRUE)
	else
		return ..()

/obj/item/storage/pouch/update_icon_state()
	switch(get_stack_fullfillment())
		if(0 to 19)
			icon_state = "pouch1"
		if(20 to 39)
			icon_state = "pouch2"
		if(40 to 59)
			icon_state = "pouch3"
		if(60 to 100)
			icon_state = "pouch4"
	return ..()

/// Returns a value from 0 to 100 regarding how "filled" the pouch is
/obj/item/storage/pouch/proc/get_stack_fullfillment()
	var/stack_fillment = 0
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/fillment_per_slot = 100 / STR.max_items
	// Only stack items are holdable.
	for(var/obj/item/stack/stack as anything in contents)
		stack_fillment += (stack.amount / stack.max_amount) * fillment_per_slot
	return stack_fillment

/obj/item/storage/pouch/random_commoner/PopulateContents()
	var/copper_amount = rand(10,20)
	var/silver_amount = rand(10,20)
	var/gold_amount = rand(4,10)
	for(var/i in 1 to copper_amount)
		new /obj/item/stack/coin/copper(src)
	for(var/i in 1 to silver_amount)
		new /obj/item/stack/coin/silver(src)
	for(var/i in 1 to gold_amount)
		new /obj/item/stack/coin/gold(src)

/obj/item/storage/pouch/opulent/PopulateContents()
	new /obj/item/stack/coin/silver/twenty(src)
	new /obj/item/stack/coin/silver/twenty(src)
	new /obj/item/stack/coin/gold/twenty(src)

/obj/item/storage/pouch/rich/PopulateContents()
	new /obj/item/stack/coin/silver/twenty(src)
	new /obj/item/stack/coin/silver/twenty(src)
	new /obj/item/stack/coin/gold/twenty(src)
	new /obj/item/stack/coin/gold/twenty(src)

/obj/item/storage/pouch/lead_balls/PopulateContents()
	new /obj/item/stack/lead_ball/five(src)
	new /obj/item/stack/lead_ball/five(src)
	new /obj/item/stack/lead_ball/five(src)

/obj/item/storage/pouch/lead_balls_scarce/PopulateContents()
	new /obj/item/stack/lead_ball/five(src)
	new /obj/item/stack/lead_ball/two(src)
