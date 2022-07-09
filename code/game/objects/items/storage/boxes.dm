/*
 * Everything derived from the common cardboard box.
 * Basically everything except the original is a kit (starts full).
 *
 * Contains:
 * Empty box, starter boxes (survival/engineer),
 * Latex glove and sterile mask boxes,
 * Syringe, beaker, dna injector boxes,
 * Blanks, flashbangs, and EMP grenade boxes,
 * Tracking and chemical implant boxes,
 * Prescription glasses and drinking glass boxes,
 * Condiment bottle and silly cup boxes,
 * Donkpocket and monkeycube boxes,
 * ID and security PDA cart boxes,
 * Handcuff, mousetrap, and pillbottle boxes,
 * Snap-pops and matchboxes,
 * Replacement light boxes.
 * Action Figure Boxes
 * Various paper bags.
 *
 * For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/cardboardbox_pickup.ogg'
	var/foldable
	var/illustration = "writing"

/obj/item/storage/box/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/storage/box/suicide_act(mob/living/carbon/user)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(myhead)
		user.visible_message(SPAN_SUICIDE("[user] puts [user.p_their()] head into \the [src], and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
		myhead.dismember()
		myhead.forceMove(src)//force your enemies to kill themselves with your head collection box!
		playsound(user, "desecration-01.ogg", 50, TRUE, -1)
		return BRUTELOSS
	user.visible_message(SPAN_SUICIDE("[user] beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/box/update_overlays()
	. = ..()
	if(illustration)
		. += illustration

/obj/item/storage/box/attack_self(mob/user)
	..()

	if(!foldable || (flags_1 & HOLOGRAM_1))
		return
	if(contents.len)
		to_chat(user, SPAN_WARNING("You can't fold this box with items still inside!"))
		return
	if(!ispath(foldable))
		return

	to_chat(user, SPAN_NOTICE("You fold [src] flat."))
	var/obj/item/I = new foldable
	qdel(src)
	user.put_in_hands(I)

// Ordinary survival box
/obj/item/storage/box/survival
	name = "survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others."
	icon_state = "internals"
	illustration = "emergencytank"

/obj/item/storage/box/survival/PopulateContents()
	new /obj/item/crowbar(src)
