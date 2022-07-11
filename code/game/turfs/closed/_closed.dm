/turf/closed
	layer = CLOSED_TURF_LAYER
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	rad_insulation = RAD_MEDIUM_INSULATION
	pass_flags_self = PASSCLOSEDTURF

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/indestructible
	name = "wall"
	desc = "Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	explosion_block = 50

/turf/closed/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/closed/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/closed/indestructible/splashscreen
	name = "Accursed"
	icon = 'icons/blank_title.png'
	icon_state = ""
	plane = SPLASHSCREEN_PLANE
	bullet_bounce_sound = null

/turf/closed/indestructible/splashscreen/New()
	SStitle.splash_turf = src
	if(SStitle.icon)
		icon = SStitle.icon
	..()

/turf/closed/indestructible/splashscreen/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				SStitle.icon = icon
