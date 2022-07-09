#define MAX_DENT_DECALS 15

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of iron used to separate rooms."
	icon = 'icons/turf/walls/solid_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#57575c"
	explosion_block = 1

	baseturfs = /turf/open/floor/rock

	flags_ricochet = RICOCHET_HARD

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_DOORS, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_LOW_WALL)

	var/list/dent_decals

	/// Typecache of all objects that we seek out to apply a neighbor stripe overlay
	var/static/list/neighbor_typecache

/// Most of this code is pasted within /obj/structure/falsewall. Be mindful of this
/turf/closed/wall/update_overlays()
	//Updating the unmanaged wall overlays (unmanaged for optimisations)
	overlays.Cut()
	var/neighbor_stripe = NONE
	if(!neighbor_typecache)
		neighbor_typecache = typecacheof(list(
			/obj/structure/window/reinforced/fulltile,
			/obj/structure/window/fulltile,
			/obj/structure/window/plasma/reinforced/fulltile,
			/obj/structure/window/plasma/fulltile,
			/obj/structure/low_wall,
			/obj/structure/door
			))
	for(var/cardinal in GLOB.cardinals)
		var/turf/step_turf = get_step(src, cardinal)
		for(var/atom/movable/movable_thing as anything in step_turf)
			if(neighbor_typecache[movable_thing.type])
				neighbor_stripe ^= cardinal
				break
	if(neighbor_stripe)
		var/mutable_appearance/neighb_stripe_appearace = mutable_appearance('icons/turf/walls/neighbor_stripe.dmi', "[neighbor_stripe]", appearance_flags = RESET_COLOR)
		neighb_stripe_appearace.color = color
		overlays += neighb_stripe_appearace

	if(dent_decals)
		add_overlay(dent_decals)
	//And letting anything else that may want to render on the wall to work (ie components)
	return ..()

/turf/closed/wall/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

/turf/closed/wall/wood
	name = "wooden wall"
	desc = "A huge chunk of wood used to separate rooms."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#533213"

/turf/closed/wall/stone
	name = "stone wall"
	desc = "A huge chunk of stone bricks used to separate rooms."
	icon = 'icons/turf/walls/stone_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#5e5e5e"

/turf/closed/wall/sandstone
	name = "sandstone wall"
	desc = "A huge chunk of sandstone bricks used to separate rooms."
	icon = 'icons/turf/walls/stone_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#c4b982"

#undef MAX_DENT_DECALS

