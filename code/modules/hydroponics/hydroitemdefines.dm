// Plant analyzer
/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth, and genetic traits. Comes with a growth scanning mode and a chemical scanning mode."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	inhand_icon_state = "analyzer"
	worn_icon_state = "plantanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/plant_analyzer/examine()
	. = ..()
	. += SPAN_NOTICE("Left click a plant to scan its growth stats, and right click to scan its chemical reagent stats.")

/// When we attack something, first - try to scan something we hit with left click. Left-clicking uses scans for stats
/obj/item/plant_analyzer/pre_attack(atom/target, mob/living/user)
	. = ..()
	if(user.combat_mode)
		return

	return do_plant_stats_scan(target, user)

/// Same as above, but with right click. Right-clicking scans for chemicals.
/obj/item/plant_analyzer/pre_attack_secondary(atom/target, mob/living/user)
	if(user.combat_mode)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return do_plant_chem_scan(target, user) ? SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN : SECONDARY_ATTACK_CONTINUE_CHAIN

/*
 * Scan the target on plant scan mode. This prints traits and stats to the user.
 *
 * scan_target - the atom we're scanning
 * user - the user doing the scanning.
 *
 * returns FALSE if it's not an object or item that does something when we scan it.
 * returns TRUE if we can scan the object, and outputs the message to the USER.
 */
/obj/item/plant_analyzer/proc/do_plant_stats_scan(atom/scan_target, mob/user)
	if(istype(scan_target, /obj/item/graft))
		to_chat(user, get_graft_text(scan_target))
		return TRUE
	if(isitem(scan_target))
		var/obj/item/scanned_object = scan_target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			to_chat(user, scan_plant_stats(scanned_object))
			return TRUE
	if(isliving(scan_target))
		var/mob/living/L = scan_target
		if(L.mob_biotypes & MOB_PLANT)
			plant_biotype_health_scan(scan_target, user)
			return TRUE

	return FALSE

/*
 * Scan the target on chemical scan mode. This prints chemical genes and reagents to the user.
 *
 * scan_target - the atom we're scanning
 * user - the user doing the scanning.
 *
 * returns FALSE if it's not an object or item that does something when we scan it.
 * returns TRUE if we can scan the object, and outputs the message to the USER.
 */
/obj/item/plant_analyzer/proc/do_plant_chem_scan(atom/scan_target, mob/user)
	if(istype(scan_target, /obj/item/graft))
		to_chat(user, get_graft_text(scan_target))
		return TRUE
	if(isitem(scan_target))
		var/obj/item/scanned_object = scan_target
		if(scanned_object.get_plant_seed() || istype(scanned_object, /obj/item/seeds))
			to_chat(user, scan_plant_chems(scanned_object))
			return TRUE
	if(isliving(scan_target))
		var/mob/living/L = scan_target
		if(L.mob_biotypes & MOB_PLANT)
			plant_biotype_chem_scan(scan_target, user)
			return TRUE

	return FALSE

/*
 * Scan a living mob's (with MOB_PLANT biotype) health with the plant analyzer. No wound scanning, though.
 *
 * scanned_mob - the living mob being scanned
 * user - the person doing the scanning
 */
/obj/item/plant_analyzer/proc/plant_biotype_health_scan(mob/living/scanned_mob, mob/living/carbon/human/user)
	user.visible_message(SPAN_NOTICE("[user] analyzes [scanned_mob]'s vitals."), \
						SPAN_NOTICE("You analyze [scanned_mob]'s vitals."))

	healthscan(user, scanned_mob, advanced = TRUE)
	add_fingerprint(user)

/*
 * Scan a living mob's (with MOB_PLANT biotype) chemical contents with the plant analyzer.
 *
 * scanned_mob - the living mob being scanned
 * user - the person doing the scanning
 */
/obj/item/plant_analyzer/proc/plant_biotype_chem_scan(mob/living/scanned_mob, mob/living/carbon/human/user)
	user.visible_message(SPAN_NOTICE("[user] analyzes [scanned_mob]'s bloodstream."), \
						SPAN_NOTICE("You analyze [scanned_mob]'s bloodstream."))
	chemscan(user, scanned_mob)
	add_fingerprint(user)

/**
 * This proc is called when a seed or any grown plant is scanned on left click (stats mode).
 * It formats the plant name as well as either its traits and stats.
 *
 * - scanned_object - the source objecte for what we are scanning. This can be a grown food, a grown inedible, or a seed.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/scan_plant_stats(obj/item/scanned_object)
	var/returned_message = "[SPAN_INFO("*---------*\nThis is \a <span class='name'>[scanned_object]")].\n"
	var/obj/item/seeds/our_seed = scanned_object
	if(!istype(our_seed)) //if we weren't passed a seed, we were passed a plant with a seed
		our_seed = scanned_object.get_plant_seed()

	if(our_seed && istype(our_seed))
		returned_message += get_analyzer_text_traits(our_seed)
	else
		returned_message += "*---------*\nNo genes found.\n*---------*"

	returned_message += "</span>\n"
	return returned_message

/**
 * This proc is called when a seed or any grown plant is scanned on right click (chemical mode).
 * It formats the plant name as well as its chemical contents.
 *
 * - scanned_object - the source objecte for what we are scanning. This can be a grown food, a grown inedible, or a seed.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/scan_plant_chems(obj/item/scanned_object)
	var/returned_message = "[SPAN_INFO("*---------*\nThis is \a <span class='name'>[scanned_object]")].\n"
	var/obj/item/seeds/our_seed = scanned_object
	if(!istype(our_seed)) //if we weren't passed a seed, we were passed a plant with a seed
		our_seed = scanned_object.get_plant_seed()

	if(scanned_object.reagents) //we have reagents contents
		returned_message += get_analyzer_text_chem_contents(scanned_object)
	else if (our_seed.reagents_add?.len) //we have a seed with reagent genes
		returned_message += get_analyzer_text_chem_genes(our_seed)
	else
		returned_message += "*---------*\nNo reagents found.\n*---------*"

	returned_message += "</span>\n"
	return returned_message

/**
 * This proc is formats the traits and stats of a seed into a message.
 *
 * - scanned - the source seed for what we are scanning for traits.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_traits(obj/item/seeds/scanned)
	var/text = ""
	if(scanned.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
		text += "- Plant type: [SPAN_NOTICE("Weed. Can grow in nutrient-poor soil.")]\n"
	else if(scanned.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		text += "- Plant type: [SPAN_NOTICE("Mushroom. Can grow in dry soil.")]\n"
	else if(scanned.get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
		text += "- Plant type: [SPAN_WARNING("UNKNOWN")] \n"
	else
		text += "- Plant type: [SPAN_NOTICE("Normal plant")]\n"

	if(scanned.potency != -1)
		text += "- Potency: [SPAN_NOTICE("[scanned.potency]")]\n"
	if(scanned.yield != -1)
		text += "- Yield: [SPAN_NOTICE("[scanned.yield]")]\n"
	text += "- Maturation speed: [SPAN_NOTICE("[scanned.maturation]")]\n"
	if(scanned.yield != -1)
		text += "- Production speed: [SPAN_NOTICE("[scanned.production]")]\n"
	text += "- Endurance: [SPAN_NOTICE("[scanned.endurance]")]\n"
	text += "- Lifespan: [SPAN_NOTICE("[scanned.lifespan]")]\n"
	text += "- Instability: [SPAN_NOTICE("[scanned.instability]")]\n"
	text += "- Weed Growth Rate: [SPAN_NOTICE("[scanned.weed_rate]")]\n"
	text += "- Weed Vulnerability: [SPAN_NOTICE("[scanned.weed_chance]")]\n"
	if(scanned.rarity)
		text += "- Species Discovery Value: [SPAN_NOTICE("[scanned.rarity]")]</span>\n"
	var/all_removable_traits = ""
	var/all_immutable_traits = ""
	for(var/datum/plant_gene/trait/traits in scanned.genes)
		if(istype(traits, /datum/plant_gene/trait/plant_type))
			continue
		if(traits.mutability_flags & PLANT_GENE_REMOVABLE)
			all_removable_traits += "[(all_removable_traits == "") ? "" : ", "][traits.get_name()]"
		else
			all_immutable_traits += "[(all_immutable_traits == "") ? "" : ", "][traits.get_name()]"

	text += "- Plant Traits: [SPAN_NOTICE("[all_removable_traits? all_removable_traits : "None."]")]</span>\n"
	text += "- Core Plant Traits: [SPAN_NOTICE("[all_immutable_traits? all_immutable_traits : "None."]")]</span>\n"
	var/datum/plant_gene/scanned_graft_result = scanned.graft_gene? new scanned.graft_gene : new /datum/plant_gene/trait/repeated_harvest
	text += "- Grafting this plant would give: [SPAN_NOTICE("[scanned_graft_result.get_name()]")]\n"
	QDEL_NULL(scanned_graft_result) //graft genes are stored as typepaths so if we want to get their formatted name we need a datum ref - musn't forget to clean up afterwards
	text += "*---------*"
	var/unique_text = scanned.get_unique_analyzer_text()
	if(unique_text)
		text += "\n"
		text += unique_text
		text += "\n*---------*"
	return text

/**
 * This proc is formats the chemical GENES of a seed into a message.
 *
 * - scanned - the source seed for what we are scanning for chemical genes.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_chem_genes(obj/item/seeds/scanned)
	var/text = ""
	text += "- Plant Reagent Genes -\n"
	text += "*---------*\n<span class='notice'>"
	for(var/datum/plant_gene/reagent/gene in scanned.genes)
		text += "- [gene.get_name()] -\n"
	text += "</span>*---------*"
	return text

/**
 * This proc is formats the chemical CONTENTS of a plant into a message.
 *
 * - scanned_plant - the source plant we are reading out its reagents contents.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_analyzer_text_chem_contents(obj/item/scanned_plant)
	var/text = ""
	var/reagents_text = ""
	text += "<br>[SPAN_INFO("- Plant Reagents -")]"
	text += "<br>[SPAN_INFO("Maximum reagent capacity: [scanned_plant.reagents.maximum_volume]")]"
	var/chem_cap = 0
	for(var/_reagent in scanned_plant.reagents.reagent_list)
		var/datum/reagent/reagent  = _reagent
		var/amount = reagent.volume
		chem_cap += reagent.volume
		reagents_text += "\n[SPAN_INFO("- [reagent.name]: [amount]")]"
	if(chem_cap > 100)
		text += "<br>[SPAN_WARNING("- Reagent Traits Over 100% Production")]</br>"

	if(reagents_text)
		text += "<br>[SPAN_INFO("*---------*")]"
		text += reagents_text
	text += "<br>[SPAN_INFO("*---------*")]"
	return text

/**
 * This proc is formats the scan of a graft of a seed into a message.
 *
 * - scanned_graft - the graft for what we are scanning.
 *
 * Returns the formatted output as text.
 */
/obj/item/plant_analyzer/proc/get_graft_text(obj/item/graft/scanned_graft)
	var/text = "[SPAN_INFO("*---------*")]\n<span class='info'>- Plant Graft -\n"
	if(scanned_graft.parent_name)
		text += "- Parent Plant: [SPAN_NOTICE("[scanned_graft.parent_name]")] -\n"
	if(scanned_graft.stored_trait)
		text += "- Graftable Traits: [SPAN_NOTICE("[scanned_graft.stored_trait.get_name()]")] -\n"
	text += "*---------*\n"
	text += "- Yield: [SPAN_NOTICE("[scanned_graft.yield]")]\n"
	text += "- Production speed: [SPAN_NOTICE("[scanned_graft.production]")]\n"
	text += "- Endurance: [SPAN_NOTICE("[scanned_graft.endurance]")]\n"
	text += "- Lifespan: [SPAN_NOTICE("[scanned_graft.lifespan]")]\n"
	text += "- Weed Growth Rate: [SPAN_NOTICE("[scanned_graft.weed_rate]")]\n"
	text += "- Weed Vulnerability: [SPAN_NOTICE("[scanned_graft.weed_chance]")]\n"
	text += "*---------*</span>"
	return text


// *************************************
// Hydroponics Tools
// *************************************

/obj/item/reagent_containers/spray/weedspray // -- Skie
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "weed spray"
	icon_state = "weedspray"
	inhand_icon_state = "spraycan"
	worn_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 100)

/obj/item/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (TOXLOSS)

/obj/item/reagent_containers/spray/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "pest spray"
	icon_state = "pestspray"
	inhand_icon_state = "plantbgone"
	worn_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/pestkiller = 100)

/obj/item/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (TOXLOSS)

/obj/item/secateurs
	name = "secateurs"
	desc = "It's a tool for cutting grafts off plants."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "secateurs"
	inhand_icon_state = "secateurs"
	worn_icon_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=4000)
	attack_verb_continuous = list("slashes", "slices", "cuts", "claws")
	attack_verb_simple = list("slash", "slice", "cut", "claw")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/geneshears
	name = "Botanogenetic Plant Shears"
	desc = "A high tech, high fidelity pair of plant shears, capable of cutting genetic traits out of a plant."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "genesheers"
	inhand_icon_state = "secateurs"
	worn_icon_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 8
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	material_flags = MATERIAL_NO_EFFECTS
	custom_materials = list(/datum/material/iron=4000, /datum/material/gold=500)
	attack_verb_continuous = list("slashes", "slices", "cuts")
	attack_verb_simple = list("slash", "slice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'


// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/reagent_containers/glass/bottle/nutrient
	name = "bottle of nutrient"
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize()
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	desc = "Contains a fertilizer that causes mild mutations and gradual plant growth with each harvest."
	list_reagents = list(/datum/reagent/plantnutriment/eznutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/l4z
	name = "bottle of Left 4 Zed"
	desc = "Contains a fertilizer that lightly heals the plant but causes significant mutations in plants over generations."
	list_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/rh
	name = "bottle of Robust Harvest"
	desc = "Contains a fertilizer that increases the yield of a plant while gradually preventing mutations."
	list_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/empty
	name = "bottle"

/obj/item/reagent_containers/glass/bottle/killer
	volume = 30
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1,2,5)

/obj/item/reagent_containers/glass/bottle/killer/weedkiller
	name = "bottle of weed killer"
	desc = "Contains a herbicide."
	list_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 30)

/obj/item/reagent_containers/glass/bottle/killer/pestkiller
	name = "bottle of pest spray"
	desc = "Contains a pesticide."
	list_reagents = list(/datum/reagent/toxin/pestkiller = 30)
