#define CACHE_LOOT_POOL(type) GLOB.cache_loot_pools[type]

GLOBAL_LIST_INIT(cache_loot_pools, init_cache_pools())


/proc/init_cache_pools()
	var/list/cache_list = list()
	for(var/type in subtypesof(/datum/cache_loot_pool))
		cache_list[type] = new type()
	return cache_list

/obj/structure/cache
	abstract_type = /obj/structure/cache
	name = "cache"
	desc = "A hiding spot. Perhaps there's something inside?"
	icon = 'icons/obj/structures/cache.dmi'
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT
	pass_flags = LETPASSTHROW
	/// Type of the cache loot pool we use.
	var/loot_pool_type = /datum/cache_loot_pool/basic/common
	/// List of ckeys who already searched this cache and got an item from the pool.
	var/list/ckeys_searched = list()
	/// Whether players can hide their own items in the cache.
	var/can_hide_items = TRUE
	/// How long it takes to search this cache.
	var/search_time = 4 SECONDS
	/// Players can hide items in the caches.
	var/list/hidden_items = list()

/obj/structure/cache/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return user_do_search(user)

/obj/structure/cache/attackby(obj/item/item, mob/living/user, params)
	if(user_hide_item(user, item))
		return TRUE
	return ..()

/obj/structure/cache/Exited(atom/movable/gone, direction)
	hidden_items -= gone
	return ..()

/obj/structure/cache/Entered(atom/movable/arrived, direction)
	hidden_items += arrived
	return ..()

/obj/structure/cache/Destroy()
	for(var/obj/item/item as anything in hidden_items)
		qdel(item)
	return ..()

/// Maximum amount of items that can be hidden at once in a cache.
#define CACHE_MAXIMUM_ITEMS 3
/// Maximum item size that can be hidden by a player in a cache.
#define CACHE_MAXIMUM_ITEM_SIZE WEIGHT_CLASS_NORMAL

/obj/structure/cache/proc/user_hide_item(mob/living/user, obj/item/item)
	if(!user_hide_item_check(user, item))
		return TRUE
	to_chat(user, SPAN_NOTICE("You start hiding \the [item] in \the [src]."))
	if(do_after(user, search_time, target = src))
		if(!user_hide_item_check(user, item))
			return TRUE
		to_chat(user, SPAN_NOTICE("You hide \the [item] in \the [src]."))
		item.forceMove(src)
	return TRUE


/obj/structure/cache/proc/user_hide_item_check(mob/living/user, obj/item/item)
	if(item.w_class > CACHE_MAXIMUM_ITEM_SIZE)
		to_chat(user, SPAN_WARNING("\The [item] is too large to fit in!"))
		return FALSE
	if(hidden_items.len >= CACHE_MAXIMUM_ITEMS)
		to_chat(user, SPAN_WARNING("\The [src] has no more space for \the [item]!"))
		return FALSE
	return TRUE


#undef CACHE_MAXIMUM_ITEMS
#undef CACHE_MAXIMUM_ITEM_SIZE

/obj/structure/cache/proc/user_do_search(mob/living/user)
	user.visible_message(
		SPAN_NOTICE("[user] searches through \the [src]."), 
		SPAN_NOTICE("You search through \the [src]."))
	if(do_after(user, search_time, target = src))
		var/obj/item/result
		if(length(hidden_items))
			result = hidden_items[hidden_items.len]
			result.forceMove(loc)
		else if (!(user.ckey in ckeys_searched))
			var/datum/cache_loot_pool/pool = CACHE_LOOT_POOL(loot_pool_type)
			result = pool.produce_item(loc)
			ckeys_searched += user.ckey
		if(!result)
			to_chat(user, SPAN_NOTICE("You don't find anything in \the [src]."))
		else
			to_chat(user, SPAN_NOTICE("You find \the [result] in \the [src]."))

	return TRUE

/datum/cache_loot_pool
	abstract_type = /datum/cache_loot_pool

/datum/cache_loot_pool/proc/produce_item(atom/location)
	return

/// Global list for the unique loot pool.
GLOBAL_LIST_INIT(cache_loot_unique_list, list(/obj/item/coin/gold, /obj/item/coin/gold))

/datum/cache_loot_pool/basic
	abstract_type = /datum/cache_loot_pool/basic
	/// Associative list of item paths to weightings to pick from
	var/list/loot_list = list()
	/// Chance to not find anything
	var/blank_chance = 50
	/// Chance on receiving a unique one of a kind item from the unique list reference.
	var/unique_chance = 1
	/// Reference to a global list to pick and take unique items from
	var/list/unique_list

/datum/cache_loot_pool/basic/New()
	set_unique_list()
	return ..()

/datum/cache_loot_pool/basic/proc/set_unique_list()
	unique_list = GLOB.cache_loot_unique_list

/datum/cache_loot_pool/basic/produce_item(atom/location)
	if(prob(blank_chance))
		return
	var/type_to_make
	if(length(unique_list) && prob(unique_chance))
		type_to_make = pick_n_take(unique_list)
	else
		type_to_make = pickweight(loot_list)
	if(!type_to_make)
		return
	return new type_to_make(location)

/datum/cache_loot_pool/basic/common
	loot_list = list(
		/obj/item/coin/gold = 10,
		/obj/item/coin/silver = 10,
		)
