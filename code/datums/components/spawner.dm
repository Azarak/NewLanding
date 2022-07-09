/datum/component/spawner
	/// Types of the mobs the spawner will spawn
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	/// Delay between a mob will emerge from the spawner
	var/spawn_time = 15 MINUTES
	/// Internal list to keep track of spawned mobs with this spawner
	var/list/spawned_mobs = list()
	/// The next time we can spawn a mob
	var/next_spawn = 0
	/// Maximum amount of mobs we can spawn.
	var/max_mobs = 2
	/// The text that describes the spawning process.
	var/spawn_text = "emerges from"
	/// List of factions the mobs will have.
	var/list/faction = list("mining")

/datum/component/spawner/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_faction)
		faction=_faction
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	for(var/spawned in spawned_mobs)
		unregister_mob(spawned)
	return ..()

/datum/component/spawner/RegisterWithParent()
	return
	
/datum/component/spawner/UnregisterFromParent()
	return

/datum/component/spawner/process()
	try_spawn_mob()

/datum/component/spawner/proc/try_spawn_mob()
	if(spawned_mobs.len >= max_mobs)
		return
	if(next_spawn > world.time)
		return
	next_spawn = world.time + spawn_time
	create_mob()

/datum/component/spawner/proc/create_mob()
	var/atom/hatchery = parent
	var/chosen_mob_type = pick(mob_types)
	var/mob/living/simple_animal/spawned_mob = new chosen_mob_type(hatchery.loc)
	spawned_mob.flags_1 |= (hatchery.flags_1 & ADMIN_SPAWNED_1)
	spawned_mob.faction = faction.Copy()
	spawned_mob.visible_message(SPAN_DANGER("[spawned_mob] [spawn_text] [hatchery]."))

	spawned_mobs += spawned_mob
	RegisterSignal(spawned_mob, COMSIG_LIVING_DEATH, .proc/mob_death)
	RegisterSignal(spawned_mob, COMSIG_PARENT_QDELETING, .proc/unregister_mob)

/datum/component/spawner/proc/mob_death(datum/source)
	SIGNAL_HANDLER
	/// If the spawner is full of mobs, set the delay once again to not spawn another mob immediately after.
	if(spawned_mobs.len == max_mobs)
		next_spawn = world.time + spawn_time

	unregister_mob(source)

/datum/component/spawner/proc/unregister_mob(datum/source)
	SIGNAL_HANDLER
	spawned_mobs -= source
	UnregisterSignal(source, COMSIG_LIVING_DEATH)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
