/*! Material datum

Simple datum which is instanced once per type and is used for every object of said material. It has a variety of variables that define behavior. Subtyping from this makes it easier to create your own materials.

*/


/datum/material
	abstract_type = /datum/material
	/// What the material is referred to as IC.
	var/name = "material"
	/// A short description of the material. Not used anywhere, yet...
	var/desc = "its..stuff."

	///Base color of the material, is used for greyscale. Item isn't changed in color if this is null.
	var/color
	///Determines the color palette of the material. Formatted as a color string.
	var/greyscale_colors
	///Base alpha of the material, is used for greyscale icons.
	var/alpha = 255
	///The type of sheet this material creates.
	var/sheet_type
	/// The type of ore this material yields.
	var/ore_type
	/// types to be removed
	var/wall_type
	var/false_wall_type
	var/shard_type

///This proc is called when the material is added to an object.
/datum/material/proc/on_applied(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color) //Do we have a custom color?
			source.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		if(alpha)
			source.alpha = alpha

	if(material_flags & MATERIAL_GREYSCALE)
		var/config_path = get_greyscale_config_for(source.greyscale_config)
		source.set_greyscale(greyscale_colors, config_path)

	if(alpha < 255)
		source.opacity = FALSE
	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = "[name] [source.name]"

	source.mat_update_desc(src)

///This proc is called when a material updates an object's description
/atom/proc/mat_update_desc(/datum/material/mat)
	return

/datum/material/proc/get_greyscale_config_for(datum/greyscale_config/config_path)
	if(!config_path)
		return
	for(var/datum/greyscale_config/path as anything in subtypesof(config_path))
		if(type != initial(path.material_skin))
			continue
		return path

///This proc is called when the material is removed from an object.
/datum/material/proc/on_removed(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color)
			source.remove_atom_colour(FIXED_COLOUR_PRIORITY, color)
		source.alpha = initial(source.alpha)

	if(material_flags & MATERIAL_GREYSCALE)
		source.set_greyscale(initial(source.greyscale_colors), initial(source.greyscale_config))

	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = initial(source.name)

/**
 * This proc is called when the mat is found in an item that's consumed by accident. see /obj/item/proc/on_accidental_consumption.
 * Arguments
 * * M - person consuming the mat
 * * S - (optional) item the mat is contained in (NOT the item with the mat itself)
 */
/datum/material/proc/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	return FALSE

/** Returns the composition of this material.
 *
 * Mostly used for alloys when breaking down materials.
 *
 * Arguments:
 * - amount: The amount of the material to break down.
 * - breakdown_flags: Some flags dictating how exactly this material is being broken down.
 */
/datum/material/proc/return_composition(amount=1, breakdown_flags=NONE)
	return list((src) = amount) // Yes we need the parenthesis, without them BYOND stringifies src into "src" and things break.
