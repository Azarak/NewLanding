/obj/item/rake
	name = "rake"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rake"
	inhand_icon_state = "cultivator"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = NONE
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)
	attack_verb_continuous = list("slashes", "slices", "bashes", "claws")
	attack_verb_simple = list("slash", "slice", "bash", "claw")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = FLAMMABLE

/obj/item/rake/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] is scratching [user.p_their()] back as hard as [user.p_they()] can with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/rake/Initialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/obj/item/rake/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	if(has_gravity(loc) && HAS_TRAIT(H, TRAIT_CLUMSY) && !H.resting)
		H.set_confusion(max(H.get_confusion(), 10))
		H.Stun(20)
		playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		H.visible_message(SPAN_WARNING("[H] steps on [src] causing the handle to hit [H.p_them()] right in the face!"), \
						  SPAN_USERDANGER("You step on [src] causing the handle to hit you right in the face!"))
