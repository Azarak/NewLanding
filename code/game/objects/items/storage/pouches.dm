/obj/item/storage/pouch
	name = "coin pouch"
	icon = 'icons/obj/items/storage/pouch.dmi'
	desc = "An ordinary leather pouch. Useful to carry your heard earned coins in."
	icon_state = "pouch"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pouch/Initialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_items = 5
	STR.max_combined_w_class = WEIGHT_CLASS_SMALL * 5
	STR.set_holdable(list(/obj/item/stack/coin))
	update_appearance()

/obj/item/storage/pouch/play_drop_sound()
	if(get_coin_amount() >= 5)
		playsound(src, 'sound/accursed/coins.ogg', 50, ignore_walls = FALSE, vary = TRUE)
	else
		return ..()

/obj/item/storage/pouch/update_icon_state()
	switch(get_coin_amount())
		if(0 to 19)
			icon_state = "pouch1"
		if(20 to 39)
			icon_state = "pouch2"
		if(40 to 59)
			icon_state = "pouch3"
		if(60 to 100)
			icon_state = "pouch4"
	return ..()

/obj/item/storage/pouch/proc/get_coin_amount()
	var/coin_amount = 0
	// Only stack items are holdable.
	for(var/obj/item/stack/coin_stack as anything in contents)
		coin_amount += coin_stack.amount
	return coin_amount

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

