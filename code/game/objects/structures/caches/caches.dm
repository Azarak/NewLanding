/obj/structure/cache/tree_stump
	name = "tree stump"
	desc = "A tree stump. There seems to be a hollowed space underneath it."
	icon_state = "tree_stump"

/obj/structure/cache/wall_crack
	name = "wall crack"
	desc = "A crack in the wall. You think you see a small glint coming from within..."
	icon_state = "wall_crack"
	density = FALSE

/obj/structure/cache/spider_cocoon
	name = "cocoon"
	desc = "Something wrapped in thick spider web."
	icon_state = "cocoon1"
	density = FALSE

/obj/structure/cache/spider_cocoon/Initialize()
	. = ..()
	icon_state = pick(list("cocoon1", "cocoon2", "cocoon3"))

/obj/structure/cache/shipwreck
	name = "shipwreck"
	desc = "Ruined parts of a ship. Perhaps there's something valueable there?"
	icon_state = "shipwreck"
