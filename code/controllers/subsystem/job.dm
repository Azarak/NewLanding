SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	/// List of all jobs.
	var/list/datum/job/all_occupations = list()
	/// Dictionary of all jobs, keys are types.
	var/list/datum/job/type_occupations = list()
	/// The main job listing of the game. This is gonna be the first station/ship/ruin's that is loaded.
	var/datum/job_listing/main_jobs
	/// Reference to current job listing we're diving in DivideOccupations, for ease of access
	var/datum/job_listing/dividing_jobs
	/// List of all job listings in the game.
	var/list/job_listings = list()
	/// Assec List of all job listings in the game. Type to instance
	var/list/type_job_listings = list()
	/// List of all fallback landmarks to spawn players in, in case they miss any of the listing/job specific ones.
	var/list/fallback_landmarks = list()

	/// Dictionary of jobs indexed by the experience type they grant.
	var/list/experience_jobs_map = list()

	var/list/unassigned = list() //Players who need jobs
	var/initial_players_to_assign = 0 //used for checking against population caps

	var/list/prioritized_jobs = list()

	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)

	/// A list of all jobs associated with the station. These jobs also have various icons associated with them including sechud and card trims.
	var/list/station_jobs
	/// A list of all Head of Staff jobs.
	var/list/head_of_staff_jobs
	/// A list of additional jobs that have various icons associated with them including sechud and card trims.
	var/list/additional_jobs_with_icons
	/// A list of jobs associed with Centcom and should use the standard NT Centcom icons.
	var/list/centcom_jobs

	/**
	 * Keys should be assigned job roles. Values should be >= 1.
	 * Represents the chain of command on the station. Lower numbers mean higher priority.
	 * Used to give the Cap's Spare safe code to a an appropriate player.
	 * Assumed Captain is always the highest in the chain of command.
	 * See [/datum/controller/subsystem/ticker/proc/equip_characters]
	 */
	var/list/chain_of_command = list(
		"Captain" = 1,
		"Head of Personnel" = 2,
		"Research Director" = 3,
		"Chief Engineer" = 4,
		"Chief Medical Officer" = 5,
		"Head of Security" = 6,
		"Quartermaster" = 7)


/datum/controller/subsystem/job/Initialize(timeofday)
	setup_job_lists()
	if(!length(all_occupations))
		SetupOccupations()
	generate_selectable_species()
	return ..()

/datum/controller/subsystem/job/proc/SetupOccupations()
	type_occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!length(all_jobs))
		all_occupations = list()
		experience_jobs_map = list()
		to_chat(world, SPAN_BOLDANNOUNCE("Error setting up jobs, no job datums found"))
		return FALSE

	var/list/new_all_occupations = list()
	var/list/new_experience_jobs_map = list()

	for(var/job_type in all_jobs)
		var/datum/job/job = new job_type()
		if(!job.config_check())
			continue
		if(!job.map_check()) //Even though we initialize before mapping, this is fine because the config is loaded at new
			testing("Removed [job.type] due to map config")
			continue
		new_all_occupations += job
		type_occupations[job_type] = job

	sortTim(new_all_occupations, /proc/cmp_job_display_asc)
	for(var/datum/job/job as anything in new_all_occupations)
		if(!job.exp_granted_type)
			continue
		new_experience_jobs_map[job.exp_granted_type] += list(job)

	all_occupations = new_all_occupations
	experience_jobs_map = new_experience_jobs_map

	return TRUE

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!length(all_occupations))
		SetupOccupations()
	return type_occupations[jobtype]

//TODO: Get rid of this
/datum/controller/subsystem/job/proc/get_department_type(department_type)
	return main_jobs.joinable_departments_by_type[department_type]

/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, datum/job/job, latejoin = FALSE)
	JobDebug("Running AR, Player: [player], Rank: [isnull(job) ? "null" : job.type], LJ: [latejoin]")
	if(!player?.mind || !job)
		JobDebug("AR has failed, Player: [player], Rank: [isnull(job) ? "null" : job.type]")
		return FALSE
	if(is_banned_from(player.ckey, job.title) || QDELETED(player))
		return FALSE
	if(!job.player_old_enough(player.client))
		return FALSE
	if(job.required_playtime_remaining(player.client))
		return FALSE
	var/position_limit = job.total_positions
	if(!latejoin)
		position_limit = job.spawn_positions
	JobDebug("Player: [player] is now Rank: [job.title], JCP:[job.current_positions], JPL:[position_limit]")
	player.mind.set_assigned_role(job)
	unassigned -= player
	job.current_positions++
	return TRUE


/datum/controller/subsystem/job/proc/FreeRole(datum/job/job)
	if(!job)
		return FALSE
	JobDebug("Freeing role: [job.title]")
	job.current_positions = max(0, job.current_positions - 1)

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, job_listing_type, flag)
	JobDebug("Running FOC, Job: [job], Level: [level], Job Listing Type:[job_listing_type], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			JobDebug("FOC player not old enough, Player: [player]")
			continue
		if(job.required_playtime_remaining(player.client))
			JobDebug("FOC player not enough xp, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			JobDebug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("FOC incompatible with antagonist role, Player: [player]")
			continue

		if(player.client.prefs.job_preferences[job_listing_type][job.type] == level)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates


/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job as anything in shuffle(dividing_jobs.joinable_occupations))

		if(dividing_jobs.overflow_role && istype(job, GetJobType(dividing_jobs.overflow_role))) // We don't want to give him assistant, that's boring!
			continue

		if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) //If you want a command position, select it!
			continue

		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			if(QDELETED(player))
				JobDebug("GRJ isbanned failed, Player deleted")
				break
			JobDebug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			JobDebug("GRJ player not old enough, Player: [player]")
			continue

		if(job.required_playtime_remaining(player.client))
			JobDebug("GRJ player not enough xp, Player: [player]")
			continue

		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			JobDebug("GRJ Random job given, Player: [player], Job: [job]")
			if(AssignRole(player, job))
				return TRUE


/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player?.mind)
			continue
		player.mind.set_assigned_role(GetJobType(/datum/job/unassigned))
		player.mind.special_role = null
	SetupOccupations()
	unassigned = list()
	return

/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	JobDebug("Running DO")

	SEND_SIGNAL(src, COMSIG_OCCUPATIONS_DIVIDED)

	//Get the players who are ready
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences() && player.mind && is_unassigned_job(player.mind.assigned_role))
			unassigned += player

	initial_players_to_assign = unassigned.len

	JobDebug("DO, Len: [unassigned.len]")

	//Jobs will have fewer access permissions if the number of players exceeds the threshold defined in game_options.txt
	var/mat = CONFIG_GET(number/minimal_access_threshold)
	if(mat)
		if(mat > unassigned.len)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	var/list/all_unassigned = unassigned
	var/list/unassigned_by_listing_type = list()
	for(var/mob/dead/new_player/player as anything in all_unassigned)
		player.client.prefs.SetupChosenJobListing()
		var/player_job_listing_start = player.client.prefs.chosen_job_listing_start
		if(!unassigned_by_listing_type[player_job_listing_start])
			unassigned_by_listing_type[player_job_listing_start] = list()
		unassigned_by_listing_type[player_job_listing_start] += player

	for(var/datum/job_listing/job_listing as anything in job_listings)
		dividing_jobs = job_listing
		unassigned = unassigned_by_listing_type[job_listing.type]
		if(!unassigned)
			unassigned = list()
		JobDebug("DO, For [job_listing.name]:")
		//People who wants to be the overflow role, sure, go on.
		JobDebug("DO, Running Overflow Check 1")
		var/datum/job/overflow_datum = job_listing.GetJobType(job_listing.overflow_role)
		if(overflow_datum)
			var/list/overflow_candidates = FindOccupationCandidates(overflow_datum, JP_LOW, dividing_jobs.type)
			JobDebug("AC1, Candidates: [overflow_candidates.len]")
			for(var/mob/dead/new_player/player in overflow_candidates)
				JobDebug("AC1 pass, Player: [player]")
				AssignRole(player, job_listing.GetJobType(job_listing.overflow_role))
				overflow_candidates -= player
		JobDebug("DO, AC1 end")
	
		//Other jobs are now checked
		JobDebug("DO, Running Standard Check")
	
	
		// New job giving system by Donkie
		// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
		// Hopefully this will add more randomness and fairness to job giving.
	
		// Loop through all levels from high to low
		var/list/shuffledoccupations = shuffle(job_listing.joinable_occupations)
		for(var/level in level_order)
			// Loop through all unassigned players
			for(var/mob/dead/new_player/player in unassigned)
				if(PopcapReached())
					RejectPlayer(player)
	
				// Loop through all jobs
				for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
					if(!job)
						continue
	
					if(is_banned_from(player.ckey, job.title))
						JobDebug("DO isbanned failed, Player: [player], Job:[job.title]")
						continue
	
					if(QDELETED(player))
						JobDebug("DO player deleted during job ban check")
						break
	
					if(!job.player_old_enough(player.client))
						JobDebug("DO player not old enough, Player: [player], Job:[job.title]")
						continue
	
					if(job.required_playtime_remaining(player.client))
						JobDebug("DO player not enough xp, Player: [player], Job:[job.title]")
						continue
	
					if(player.mind && (job.title in player.mind.restricted_roles))
						JobDebug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
						continue
	
					// If the player wants that job on this level, then try give it to him.
					var/list/job_prefs_list = player.client.prefs.job_preferences[job_listing.type]
					if(job_prefs_list && job_prefs_list[job.type] == level)
						// If the job isn't filled
						if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
							JobDebug("DO pass, Player: [player], Level:[level], Job:[job.title]")
							AssignRole(player, job)
							unassigned -= player
							break
	
	
		JobDebug("DO, Handling unassigned.")
		// Hand out random jobs to the people who didn't get any in the last check
		// Also makes sure that they got their preference correct
		for(var/mob/dead/new_player/player in unassigned)
			HandleUnassigned(player)
	dividing_jobs = null
	return TRUE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/player)
	if(PopcapReached())
		RejectPlayer(player)
	else if(player.client.prefs.joblessrole == BEOVERFLOW)
		var/datum/job/overflow_role_datum = GetJobType(dividing_jobs.overflow_role)
		if(!overflow_role_datum)
			RejectPlayer(player)
		var/allowed_to_be_a_loser = !is_banned_from(player.ckey, overflow_role_datum.title)
		if(QDELETED(player) || !allowed_to_be_a_loser)
			RejectPlayer(player)
		else
			if(!AssignRole(player, overflow_role_datum))
				RejectPlayer(player)
	else if(player.client.prefs.joblessrole == BERANDOMJOB)
		if(!GiveRandomJob(player))
			RejectPlayer(player)
	else if(player.client.prefs.joblessrole == RETURNTOLOBBY)
		RejectPlayer(player)
	else //Something gone wrong if we got here.
		var/message = "DO: [player] fell through handling unassigned"
		JobDebug(message)
		log_game(message)
		message_admins(message)
		RejectPlayer(player)


//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/living/equipping, datum/job/job, client/player_client)
	equipping.job = job.title

	SEND_SIGNAL(equipping, COMSIG_JOB_RECEIVED, job)

	equipping.mind?.set_assigned_role(job)

	if(player_client)
		to_chat(player_client, "<span class='infoplain'><b>You are the [job.title].</b></span>")

	equipping.on_job_equipping(job, TRUE, player_client)

	job.announce_job(equipping)

	if(player_client?.holder)
		if(CONFIG_GET(flag/auto_deadmin_players) || (player_client.prefs?.toggles & DEADMIN_ALWAYS))
			player_client.holder.auto_deadmin()
		else
			handle_auto_deadmin_roles(player_client, job)

	if(player_client)
		to_chat(player_client, "<span class='infoplain'><b>As the [job.title] you answer directly to [job.supervisors]. Special circumstances may change this.</b></span>")

	job.radio_help_message(equipping)

	if(player_client)
		if(job.req_admin_notify)
			to_chat(player_client, "<span class='infoplain'><b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b></span>")
		if(CONFIG_GET(number/minimal_access_threshold))
			to_chat(player_client, SPAN_NOTICE("<B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B>"))

		var/related_policy = get_policy(job.title)
		if(related_policy)
			to_chat(player_client, related_policy)

	if(ishuman(equipping))
		var/mob/living/carbon/human/wageslave = equipping
		wageslave.add_memory("Your account ID is [wageslave.account_id].")

	job.after_spawn(equipping, player_client)


/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, datum/job/job)
	if(!C?.holder)
		return TRUE

	var/timegate_expired = FALSE
	// allow only forcing deadminning in the first X seconds of the round if auto_deadmin_timegate is set in config
	var/timegate = CONFIG_GET(number/auto_deadmin_timegate)
	if(timegate && (world.time - SSticker.round_start_time > timegate))
		timegate_expired = TRUE

	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && ((CONFIG_GET(flag/auto_deadmin_heads) && !timegate_expired) || (C.prefs?.toggles & DEADMIN_POSITION_HEAD)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SECURITY) && ((CONFIG_GET(flag/auto_deadmin_security) && !timegate_expired) || (C.prefs?.toggles & DEADMIN_POSITION_SECURITY)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SILICON) && ((CONFIG_GET(flag/auto_deadmin_silicons) && !timegate_expired) || (C.prefs?.toggles & DEADMIN_POSITION_SILICON))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job as anything in main_jobs.joinable_occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/i in GLOB.new_player_list)
			var/mob/dead/new_player/player = i
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && is_unassigned_job(player.mind.assigned_role)))
				continue //This player is not ready
			if(is_banned_from(player.ckey, job.title) || QDELETED(player))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.required_playtime_remaining(player.client))
				young++
				continue
			var/list/pref_list = player.client.prefs.job_preferences[main_jobs.type] || list()
			switch(pref_list[job.type])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/player)
	if(player.mind && player.mind.special_role)
		return
	if(PopcapReached())
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<span class='infoplain'><b>You have failed to qualify for any job you desired.</b></span>")
	unassigned -= player
	player.ready = PLAYER_NOT_READY


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.all_occupations
	sleep(20)
	for (var/datum/job/job as anything in oldjobs)
		INVOKE_ASYNC(src, .proc/RecoverJob, job)

/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJobType(J.type)
	if (!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.spawn_positions = J.spawn_positions
	newjob.current_positions = J.current_positions

/atom/proc/JoinPlayerHere(mob/M, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	M.forceMove(get_turf(src))

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M.mind && M.mind.assigned_role)
		destination = M.mind.assigned_role.get_spawn_point(roundstart = FALSE)
	if(!destination)
		destination = get_last_resort_spawn_point()
	destination.JoinPlayerHere(M, buckle)


/datum/controller/subsystem/job/proc/get_last_resort_spawn_point()
	//bad mojo
	if(length(fallback_landmarks))
		return pick(fallback_landmarks)
	var/area/arrivals_area = GLOB.areas_by_type[/area/outdoors/jungle]
	if(arrivals_area)
		//first check if we can find a chair
		var/obj/structure/chair/shuttle_chair = locate() in arrivals_area
		if(shuttle_chair)
			return shuttle_chair

		//last hurrah
		var/list/turf/available_turfs = list()
		for(var/turf/arrivals_turf in arrivals_area)
			if(!arrivals_turf.is_blocked_turf(TRUE))
				available_turfs += arrivals_turf
		if(length(available_turfs))
			return pick(available_turfs)

	//pick an open spot on arrivals and dump em
	var/list/arrivals_turfs = shuffle(get_area_turfs(/area/outdoors/jungle))
	if(length(arrivals_turfs))
		for(var/turf/arrivals_turf in arrivals_turfs)
			if(!arrivals_turf.is_blocked_turf(TRUE))
				return arrivals_turf
		//last chance, pick ANY spot on arrivals and dump em
		return pick(arrivals_turfs)

	stack_trace("Unable to find last resort spawn point.")
	return GET_ERROR_ROOM

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.stat != DEAD && (player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
			. += player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			. += player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.stat != DEAD && (player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
			. += player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			. += player.mind

/datum/controller/subsystem/job/proc/JobDebug(message)
	log_job_debug(message)

/// Builds various lists of jobs based on station, centcom and additional jobs with icons associated with them.
/datum/controller/subsystem/job/proc/setup_job_lists()
	station_jobs = list("Assistant", "Captain", "Head of Personnel", "Bartender", "Cook", "Botanist", "Quartermaster", "Cargo Technician", \
		"Shaft Miner", "Clown", "Mime", "Janitor", "Curator", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer", \
		"Atmospheric Technician", "Chief Medical Officer", "Medical Doctor", "Paramedic", "Chemist", "Geneticist", "Virologist", "Psychologist", \
		"Research Director", "Scientist", "Roboticist", "Head of Security", "Warden", "Detective", "Security Officer", "Prisoner")

	head_of_staff_jobs = list("Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Head of Security", "Captain")

	additional_jobs_with_icons = list("Emergency Response Team Commander", "Security Response Officer", "Engineering Response Officer", "Medical Response Officer", \
		"Entertainment Response Officer", "Religious Response Officer", "Janitorial Response Officer", "Death Commando", "Security Officer (Engineering)", \
		"Security Officer (Cargo)", "Security Officer (Medical)", "Security Officer (Science)")

	centcom_jobs = list("Central Command","VIP Guest","Custodian","Thunderdome Overseer","CentCom Official","Medical Officer","Research Officer", \
		"Special Ops Officer","Admiral","CentCom Commander","CentCom Bartender","Private Security Force")

/datum/controller/subsystem/job/proc/create_listing(listing_type)
	if(type_job_listings[listing_type])
		CRASH("Tried to instantiate an already existing job listing type [listing_type]")
	var/datum/job_listing/new_listing = new listing_type()
	type_job_listings[listing_type] = new_listing
	job_listings += new_listing
	if(!main_jobs)
		main_jobs = new_listing
