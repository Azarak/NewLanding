/datum/map_config/testlanding
	map_name = "Test Landing"
	map_path = "map_files/testlanding"
	map_file = "testlanding.dmm"

	traits = list(
		list(
			"Up" = 1,
			),
		list(
			"Down" = -1,
			"Up" = 1,
			),
		list(
			"Down" = -1,
			"Up" = 1,
			),
		list(
			"Down" = -1,
			"Up" = 1,
			),
		list(
			"Down" = -1,
			)
		)

	day_night_controller_type = /datum/day_night_controller

	allow_custom_shuttles = TRUE

	job_changes = list()
	job_listings = list(
		/datum/job_listing/settlers,
		/datum/job_listing/port,
		/datum/job_listing/pirate,
		/datum/job_listing/native,
		/datum/job_listing/undefined
		)
