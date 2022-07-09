/obj/structure/mob_spawner
	abstract_type = /obj/structure/mob_spawner
	name = "hole"
	desc = "A dark hole."
	icon = 'icons/obj/structures/mob_spawner.dmi'
	icon_state = "hole"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/max_mobs = 2
	var/spawn_time = 15 MINUTES
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_text = "emerges from"
	var/faction = list("hostile")
	var/spawner_type = /datum/component/spawner

/obj/structure/mob_spawner/Initialize()
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/obj/structure/mob_spawner/hole
	name = "hole"
	icon_state = "hole"
	density = TRUE

/obj/structure/mob_spawner/wall_hole
	name = "hole"
	icon_state = "wall_hole"
	density = FALSE

/obj/structure/mob_spawner/hovel
	name = "hovel"
	icon_state = "hovel"
	density = FALSE

/obj/structure/mob_spawner/invisible
	name = "seemingly nowhere"
	icon_state = "invisible"
	density = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	spawn_text = "appears from"
