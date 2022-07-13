/obj/item/stack/lead_ball
	name = "lead balls"
	icon = 'icons/obj/items/stack/lead_balls.dmi'
	icon_state = "lead_balls"
	merge_type = /obj/item/stack/lead_ball
	full_w_class = WEIGHT_CLASS_SMALL
	max_amount = 5
	singular_name = "lead ball"
	novariants = TRUE

/obj/item/stack/lead_ball/update_icon_state()
	. = ..()
	icon_state = "lead_balls_[amount]"

/obj/item/stack/lead_ball/two
	amount = 2

/obj/item/stack/lead_ball/three
	amount = 3

/obj/item/stack/lead_ball/four
	amount = 4

/obj/item/stack/lead_ball/five
	amount = 5
