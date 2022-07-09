#define ORESTACK_OVERLAYS_MAX 10

/**********************Mineral ores**************************/

/obj/item/stack/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	inhand_icon_state = "ore"
	full_w_class = WEIGHT_CLASS_NORMAL
	max_amount = 5
	singular_name = "ore chunk"
	novariants = TRUE // Ore stacks handle their icon updates themselves to keep the illusion that there's more going
	var/refined_type = null //What this ore defaults to being refined into
	var/list/ore_overlays

/obj/item/stack/ore/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE)
		qdel(src)

/obj/item/stack/ore/update_overlays()
	. = ..()
	var/overlay_amount = min(ORESTACK_OVERLAYS_MAX, amount - 1)
	if(overlay_amount > 0)
		LAZYINITLIST(ore_overlays)
	else
		ore_overlays = null
		return
	while(ore_overlays.len > overlay_amount)
		ore_overlays.len--
	while(ore_overlays.len < overlay_amount)
		var/mutable_appearance/newore = mutable_appearance(icon, icon_state)
		newore.pixel_x = rand(-8,8)
		newore.pixel_y = rand(-8,8)
		ore_overlays += newore
	. += ore_overlays

/obj/item/stack/ore/welder_act(mob/living/user, obj/item/I)
	..()
	if(!refined_type)
		return TRUE

	if(I.use_tool(src, user, 0, volume=50, amount=15))
		new refined_type(drop_location())
		use(1)

	return TRUE

/obj/item/stack/ore/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(isnull(refined_type))
		return
	else
		var/probability = (rand(0,100))/100
		var/burn_value = probability*amount
		var/amountrefined = round(burn_value, 1)
		if(amountrefined < 1)
			qdel(src)
		else
			new refined_type(drop_location(),amountrefined)
			qdel(src)

/obj/item/stack/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	inhand_icon_state = "Iron ore"
	singular_name = "iron ore chunk"
	mats_per_unit = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/iron
	merge_type = /obj/item/stack/ore/iron

/obj/item/stack/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	inhand_icon_state = "Glass ore"
	singular_name = "sand pile"
	mats_per_unit = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass
	w_class = WEIGHT_CLASS_TINY
	merge_type = /obj/item/stack/ore/glass

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/sandstone, 1, 1, 50),\
))

/obj/item/stack/ore/glass/get_main_recipes()
	. = ..()
	. += GLOB.sand_recipes

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.is_eyes_covered())
		C.visible_message(SPAN_DANGER("[C]'s eye protection blocks the sand!"), SPAN_WARNING("Your eye protection blocks the sand!"))
		return
	C.adjust_blurriness(6)
	C.adjustStaminaLoss(15)//the pain from your eyes burning does stamina damage
	C.add_confusion(5)
	to_chat(C, SPAN_USERDANGER("\The [src] gets into your eyes! The pain, it burns!"))
	qdel(src)

/obj/item/stack/ore/glass/ex_act(severity, target)
	if(severity)
		qdel(src)

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"
	inhand_icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"
	merge_type = /obj/item/stack/ore/glass/basalt

/obj/item/stack/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	inhand_icon_state = "Silver ore"
	singular_name = "silver ore chunk"
	mats_per_unit = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/silver
	merge_type = /obj/item/stack/ore/silver

/obj/item/stack/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	inhand_icon_state = "Gold ore"
	singular_name = "gold ore chunk"
	mats_per_unit = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/gold
	merge_type = /obj/item/stack/ore/gold

/obj/item/stack/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	inhand_icon_state = "Diamond ore"
	singular_name = "diamond ore chunk"
	mats_per_unit = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/diamond
	merge_type = /obj/item/stack/ore/diamond

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless."
	icon_state = "slag"
	inhand_icon_state = "slag"
	singular_name = "slag chunk"
	merge_type = /obj/item/stack/ore/slag

#undef ORESTACK_OVERLAYS_MAX
