////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = OPENCONTAINER | DUNKABLE
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	resistance_flags = NONE
	var/isGlass = TRUE //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/reagent_containers/food/drinks/attack(mob/living/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, SPAN_WARNING("[src] is empty!"))
		return FALSE

	if(!canconsume(M, user))
		return FALSE

	if (!is_drainable())
		to_chat(user, SPAN_WARNING("[src]'s lid hasn't been opened!"))
		return FALSE

	if(M == user)
		user.visible_message(SPAN_NOTICE("[user] swallows a gulp of [src]."), \
			SPAN_NOTICE("You swallow a gulp of [src]."))
		if(HAS_TRAIT(M, TRAIT_VORACIOUS))
			M.changeNext_move(CLICK_CD_MELEE * 0.5) //chug! chug! chug!

	else
		M.visible_message(SPAN_DANGER("[user] attempts to feed [M] the contents of [src]."), \
			SPAN_USERDANGER("[user] attempts to feed you the contents of [src]."))
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The drink might be empty after the delay, such as by spam-feeding
		M.visible_message(SPAN_DANGER("[user] fed [M] the contents of [src]."), \
			SPAN_USERDANGER("[user] fed you the contents of [src]."))
		log_combat(user, M, "fed", reagents.log_list())

	SEND_SIGNAL(src, COMSIG_DRINK_DRANK, M, user)
	var/fraction = min(gulp_size/reagents.total_volume, 1)
	reagents.trans_to(M, gulp_size, transfered_by = user, methods = INGEST)
	checkLiked(fraction, M)

	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	return TRUE

/*
 * On accidental consumption, make sure the container is partially glass, and continue to the reagent_container proc
 */
/obj/item/reagent_containers/food/drinks/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item,  discover_after = TRUE)
	if(isGlass && !custom_materials)
		set_custom_materials(list(GET_MATERIAL_REF(/datum/material/glass) = 5))
	return ..()

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return

	if(target.is_refillable() && is_drainable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, SPAN_WARNING("[src] is empty."))
			return

		if(target.reagents.holder_full())
			to_chat(user, SPAN_WARNING("[target] is full."))
			return

		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, SPAN_NOTICE("You transfer [trans] units of the solution to [target]."))

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if (!is_refillable())
			to_chat(user, SPAN_WARNING("[src]'s tab isn't open!"))
			return

		if(!target.reagents.total_volume)
			to_chat(user, SPAN_WARNING("[target] is empty."))
			return

		if(reagents.holder_full())
			to_chat(user, SPAN_WARNING("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, SPAN_NOTICE("You fill [src] with [trans] units of the contents of [target]."))

/obj/item/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	var/hotness = I.get_temperature()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, SPAN_NOTICE("You heat [name] with [I]!"))
	..()

/obj/item/reagent_containers/food/drinks/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if the bottle wasn't caught
		smash(hit_atom, throwingdatum?.thrower, TRUE)

/obj/item/reagent_containers/food/drinks/proc/smash(atom/target, mob/thrower, ranged = FALSE)
	if(!isGlass)
		return
	if(QDELING(src) || !target) //Invalid loc
		return
	if(bartender_check(target) && ranged)
		return
	var/obj/item/broken_bottle/B = new (loc)
	B.icon_state = icon_state
	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I
	B.name = "broken [name]"
	if(prob(33))
		var/obj/item/shard/S = new(drop_location())
		target.Bumped(S)
	playsound(src, "shatter", 70, TRUE)
	transfer_fingerprints_to(B)
	qdel(src)
	target.Bumped(B)

/obj/item/reagent_containers/food/drinks/bullet_act(obj/projectile/P)
	. = ..()
	if(!(P.nodamage) && P.damage_type == BRUTE && !QDELETED(src))
		var/atom/T = get_turf(src)
		smash(T)
		return



////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/food/drinks/mug // parent type is literally just so empty mug sprites are a thing
	name = "mug"
	desc = "A drink served in a classy mug."
	icon_state = "tea"
	inhand_icon_state = "coffee"
	spillable = TRUE

/obj/item/reagent_containers/food/drinks/mug/update_icon_state()
	icon_state = reagents.total_volume ? "tea" : "tea_empty"
	return ..()

/obj/item/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	inhand_icon_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/ale = 30)
	foodtype = GRAIN | ALCOHOL
	custom_price = PAYCHECK_EASY
