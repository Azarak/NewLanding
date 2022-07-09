/obj/structure/cliff_side
	abstract_type = /obj/structure/cliff_side
	name = "cliff side"
	desc = "A side of a small cliff."
	icon = 'icons/obj/structures/cliff_side.dmi'
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	flags_1 = ON_BORDER_1
	pass_flags_self = PASSTABLE | LETPASSTHROW

/obj/structure/cliff_side/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return
	qdel(src)

/obj/structure/cliff_side/corner
	icon_state = "corner"

/// Types named after directions relative to the center of the cliff
/obj/structure/cliff_side/corner/northwest
	dir = NORTH

/obj/structure/cliff_side/corner/northeast
	dir = SOUTH

/obj/structure/cliff_side/corner/southeast
	dir = EAST

/obj/structure/cliff_side/corner/southwest
	dir = WEST

/obj/structure/cliff_side/side
	icon_state = "side"
	density = TRUE
	flags_1 = ON_BORDER_1

/obj/structure/cliff_side/side/Initialize()
	. = ..()
	AddElement(/datum/element/climbable, climb_over = TRUE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/obj/structure/cliff_side/side/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(get_dir(loc, target) & dir)
		return . || mover.throwing || mover.movement_type & (PHASING | FLYING | FLOATING)
	return TRUE

/obj/structure/cliff_side/side/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(!(direction & dir))
		return

	if(!density)
		return

	if(leaving.throwing)
		return

	if(leaving.movement_type & (PHASING | FLYING | FLOATING))
		return

	if(leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/// Types named after directions relative to the center of the cliff
/obj/structure/cliff_side/side/north
	dir = SOUTH

/obj/structure/cliff_side/side/south
	dir = NORTH

/obj/structure/cliff_side/side/west
	dir = EAST

/obj/structure/cliff_side/side/east
	dir = WEST

/// Types for the smoothed "ends" of the cliffs

/obj/structure/cliff_side/side/end_northwest
	icon_state = "side_end_northwest"

/obj/structure/cliff_side/side/end_northwest/north
	dir = SOUTH

/obj/structure/cliff_side/side/end_northwest/south
	dir = NORTH

/obj/structure/cliff_side/side/end_northwest/west
	dir = EAST

/obj/structure/cliff_side/side/end_northwest/east
	dir = WEST

/obj/structure/cliff_side/side/end_southeast
	icon_state = "side_end_southeast"

/obj/structure/cliff_side/side/end_southeast/north
	dir = SOUTH

/obj/structure/cliff_side/side/end_southeast/south
	dir = NORTH

/obj/structure/cliff_side/side/end_southeast/west
	dir = EAST

/obj/structure/cliff_side/side/end_southeast/east
	dir = WEST
