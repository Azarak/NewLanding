///Has no special properties.
/datum/material/iron
	name = "iron"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	color = "#878687"
	greyscale_colors = "#878687"
	sheet_type = /obj/item/stack/sheet/iron
	ore_type = /obj/item/stack/ore/iron

/datum/material/iron/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	desc = "Glass forged by melting sand."
	color = "#88cdf1"
	greyscale_colors = "#88cdf1"
	alpha = 150
	sheet_type = /obj/item/stack/sheet/glass
	ore_type = /obj/item/stack/ore/glass

/datum/material/glass/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5, sharpness = TRUE) //cronch
	return TRUE

/*
Color matrices are like regular colors but unlike with normal colors, you can go over 255 on a channel.
Unless you know what you're doing, only use the first three numbers. They're in RGB order.
*/

///Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	desc = "Silver"
	color = list(255/255, 284/255, 302/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#e3f1f8"
	sheet_type = /obj/item/stack/sheet/silver
	ore_type = /obj/item/stack/ore/silver

/datum/material/silver/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Slight force increase
/datum/material/gold
	name = "gold"
	desc = "Gold"
	color = list(340/255, 240/255, 50/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //gold is shiny, but not as bright as bananium
	greyscale_colors = "#dbdd4c"
	sheet_type = /obj/item/stack/sheet/gold
	ore_type = /obj/item/stack/ore/gold

/datum/material/gold/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

///Has no special properties
/datum/material/diamond
	name = "diamond"
	desc = "Highly pressurized carbon"
	color = list(48/255, 272/255, 301/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#71c8f7"
	sheet_type = /obj/item/stack/sheet/diamond
	ore_type = /obj/item/stack/ore/diamond
	alpha = 132

/datum/material/diamond/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
	return TRUE

/datum/material/wood
	name = "wood"
	desc = "Flexible, durable, but flamable. Hard to come across in space."
	color = "#bb8e53"
	greyscale_colors = "#bb8e53"
	sheet_type = /obj/item/stack/sheet/wood

/datum/material/wood/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
	victim.reagents.add_reagent(/datum/reagent/cellulose, rand(8, 12))
	source_item?.reagents?.add_reagent(/datum/reagent/cellulose, source_item.reagents.total_volume*(2/5))

	return TRUE

//I don't like sand. It's coarse, and rough, and irritating, and it gets everywhere.
/datum/material/sand
	name = "sand"
	desc = "You know, it's amazing just how structurally sound sand can be."
	color = "#EDC9AF"
	greyscale_colors = "#EDC9AF"
	sheet_type = /obj/item/stack/sheet/sandblock

/datum/material/sand/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.adjust_disgust(17)
	return TRUE

/datum/material/sandstone
	name = "sandstone"
	desc = "Bialtaakid 'ant taerif ma hdha."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/sandstone

/datum/material/paper
	name = "paper"
	desc = "Ten thousand folds of pure starchy power."
	color = "#E5DCD5"
	greyscale_colors = "#E5DCD5"
	sheet_type = /obj/item/stack/sheet/paperframes

/datum/material/bone
	name = "bone"
	desc = "Man, building with this will make you the coolest caveman on the block."
	color = "#e3dac9"
	greyscale_colors = "#e3dac9"
	sheet_type = /obj/item/stack/sheet/bone

/datum/material/bamboo
	name = "bamboo"
	desc = "If it's good enough for pandas, it's good enough for you."
	color = "#339933"
	greyscale_colors = "#339933"
	sheet_type = /obj/item/stack/sheet/bamboo

// Do we want this? I'm not sure..
///It's gross, gets the name of it's owner, and is all kinds of fucked up
/datum/material/meat
	name = "meat"
	desc = "Meat"
	color = rgb(214, 67, 67)
	greyscale_colors = rgb(214, 67, 67)
	sheet_type = /obj/item/stack/sheet/meat

/datum/material/stone
	name = "stone"
	desc = "It's stone."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/stone

/datum/material/tin
	name = "tin"
	desc = "It's tin."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/tin

/datum/material/copper
	name = "copper"
	desc = "It's copper."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/copper

/datum/material/zinc
	name = "zinc"
	desc = "It's zinc."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/zinc

/datum/material/leather
	name = "leather"
	desc = "It's leather"
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/leather

/datum/material/coal
	name = "coal"
	desc = "It's coal."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/coal

/datum/material/clay
	name = "clay"
	desc = "It's clay."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/clay

/datum/material/brick
	name = "brick"
	desc = "It's brick."
	color = "#B77D31"
	greyscale_colors = "#B77D31"
	sheet_type = /obj/item/stack/sheet/brick
