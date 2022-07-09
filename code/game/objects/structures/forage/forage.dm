/obj/structure/forage/berry_bush
	name = "berry bush"
	desc = "A bush growing tasty berries."
	icon_state = "berry_bush"
	base_icon_state = "berry_bush"
	foraged_icon_state = "berry_bush_empty"
	forage_by_hand = TRUE
	result_type = /obj/item/food/grown/berries
	result_amount = 3

/obj/structure/forage/shrub
	name = "shrub"
	desc = "A shrub."
	icon_state = "shrub"
	base_icon_state = "shrub"
	foraged_icon_state = "shrub_empty"
	density = FALSE
	forage_by_hand = TRUE
	result_type = /obj/item/grown/log
	result_amount = 1

/obj/structure/forage/tea_herbs
	name = "herbs"
	desc = "A plant with some leaves."
	icon_state = "tea_herbs"
	base_icon_state = "tea_herbs"
	foraged_icon_state = "tea_herbs_empty"
	density = FALSE
	forage_by_hand = TRUE
	result_type = /obj/item/food/grown/tea
	result_amount = 2
