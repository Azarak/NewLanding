/*****************************Coin********************************/

/obj/item/stack/coin
	icon = 'icons/obj/economy.dmi'
	name = "coins"
	icon_state = "coin"
	abstract_type = /obj/item/stack/coin
	full_w_class = WEIGHT_CLASS_SMALL
	max_amount = 20
	singular_name = "coin"
	novariants = TRUE
	var/flipping = FALSE
	var/coin_face
	var/list/face_list = list("heads", "tails")
	var/list/coin_overlays

/obj/item/stack/coin/Initialize()
	. = ..()
	coin_face = face_list[1]
	update_appearance()

/obj/item/stack/coin/play_drop_sound()
	if(amount >= 5)
		playsound(src, 'sound/accursed/coins.ogg', 50, ignore_walls = FALSE, vary = TRUE)
	else
		return ..()

/obj/item/stack/coin/attack_self(mob/user)
	if(start_flip(user))
		return TRUE
	return ..()

/obj/item/stack/coin/attack_hand_secondary(mob/user, modifiers)
	if(start_flip(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/stack/coin/update_icon_state()
	. = ..()
	if(flipping)
		icon_state = "coin_[coin_face]_flip"
	else
		icon_state = "coin_[coin_face]"

#define COIN_OVERLAYS_MAX 14

/obj/item/stack/coin/update_overlays()
	. = ..()
	var/overlay_amount = min(COIN_OVERLAYS_MAX, amount - 1)
	if(overlay_amount > 0)
		LAZYINITLIST(coin_overlays)
	else
		coin_overlays = null
		return
	while(coin_overlays.len > overlay_amount)
		coin_overlays.len--
	while(coin_overlays.len < overlay_amount)
		var/rand_face = pick(face_list)
		var/mutable_appearance/newcoin = mutable_appearance(icon, "coin_[rand_face]")
		newcoin.pixel_x = rand(-8,8)
		newcoin.pixel_y = rand(-8,8)
		coin_overlays += newcoin
	. += coin_overlays

#undef COIN_OVERLAYS_MAX

/obj/item/stack/coin/proc/start_flip(mob/living/user)
	if(flipping || amount != 1)
		return FALSE
	flipping = TRUE
	update_appearance()
	playsound(user, 'sound/items/coinflip.ogg', 50, TRUE)
	addtimer(CALLBACK(src, .proc/end_flip, user), 1 SECONDS)
	return TRUE

/obj/item/stack/coin/proc/end_flip(mob/living/user)
	if(QDELETED(src) || QDELETED(user))
		return
	flipping = FALSE
	coin_face = pick(face_list)
	update_appearance()
	user.visible_message(
		SPAN_NOTICE("[user] flips [src]. It lands on [coin_face]."),
		SPAN_NOTICE("You flip [src]. It lands on [coin_face]."),
		SPAN_HEAR("You hear the clattering of loose change.")
		)

/obj/item/stack/coin/gold
	name = "gold coins"
	singular_name = "gold coin"
	color = "#f0c000"
	merge_type = /obj/item/stack/coin/gold

/obj/item/stack/coin/gold/five
	amount = 5

/obj/item/stack/coin/gold/twenty
	amount = 20

/obj/item/stack/coin/silver
	name = "silver coins"
	singular_name = "silver coin"
	merge_type = /obj/item/stack/coin/silver

/obj/item/stack/coin/silver/five
	amount = 5

/obj/item/stack/coin/silver/twenty
	amount = 20

/obj/item/stack/coin/copper
	name = "copper coins"
	singular_name = "copper coin"
	color = "#9c5d2c"
	merge_type = /obj/item/stack/coin/copper

/obj/item/stack/coin/copper/five
	amount = 5

/obj/item/stack/coin/copper/twenty
	amount = 20

/obj/item/stack/coin/diamond
	name = "diamond coins"
	singular_name = "diamond coin"
	color = "#71c8f7"
	merge_type = /obj/item/stack/coin/diamond

/obj/item/stack/coin/iron
	name = "iron coins"
	singular_name = "iron coin"
	color = "#878687"
	merge_type = /obj/item/stack/coin/iron
