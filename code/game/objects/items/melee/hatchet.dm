/obj/item/hatchet
	name = "hatchet"
	desc = "A crude axe blade upon a short wooden handle."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "woodhatchet"
	inhand_icon_state = "hatchet"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	force = 12
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 15
	throw_speed = 4
	throw_range = 7
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	attack_verb_continuous = list("chops", "tears", "lacerates", "cuts")
	attack_verb_simple = list("chop", "tear", "lacerate", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_AXE
	usesound = 'sound/weapons/bladeslice.ogg'

/obj/item/hatchet/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 70, 100)

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] is chopping at [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return (BRUTELOSS)
