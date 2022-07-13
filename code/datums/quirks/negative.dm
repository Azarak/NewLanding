//predominantly negative traits

/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	value = -8
	gain_text = SPAN_DANGER("You feel your vigor slowly fading away.")
	lose_text = SPAN_NOTICE("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	processing_quirk = TRUE

/datum/quirk/blooddeficiency/process(delta_time)
	if(quirk_holder.stat == DEAD)
		return

	var/mob/living/carbon/human/H = quirk_holder
	if(NOBLOOD in H.dna.species.species_traits) //can't lose blood if your species doesn't have any
		return

	if (H.blood_volume > (BLOOD_VOLUME_SAFE - 25)) // just barely survivable without treatment
		H.blood_volume -= 0.275 * delta_time

/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	value = -8
	mob_trait = TRAIT_DEAF
	gain_text = SPAN_DANGER("You can't hear anything.")
	lose_text = SPAN_NOTICE("You're able to hear again!")
	medical_record_text = "Patient's cochlear nerve is incurably damaged."

/datum/quirk/frail
	name = "Frail"
	desc = "You have skin of paper and bones of glass! You suffer wounds much more easily than most."
	value = -6
	mob_trait = TRAIT_EASILY_WOUNDED
	gain_text = SPAN_DANGER("You feel frail.")
	lose_text = SPAN_NOTICE("You feel sturdy again.")
	medical_record_text = "Patient is absurdly easy to injure. Please take all due dilligence to avoid possible malpractice suits."

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep or knocked unconscious, you take a little bit longer to wake up."
	value = -2
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = SPAN_DANGER("You feel sleepy.")
	lose_text = SPAN_NOTICE("You feel awake again.")
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."

/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	value = -2
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = SPAN_NOTICE("Just the thought of drinking alcohol makes your head spin.")
	lose_text = SPAN_DANGER("You're no longer severely affected by alcohol.")
	medical_record_text = "Patient demonstrates a low tolerance for alcohol. (Wimp)"

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -8
	mob_trait = TRAIT_PACIFISM
	gain_text = SPAN_DANGER("You feel repulsed by the thought of violence!")
	lose_text = SPAN_NOTICE("You think you can defend yourself again.")
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	value = -12
	human_only = TRUE
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."

/datum/quirk/paraplegic/add_unique()
	if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_holder.buckled.unbuckle_mob(quirk_holder)

	var/turf/holder_turf = get_turf(quirk_holder)
	var/obj/structure/chair/spawn_chair = locate() in holder_turf

	var/obj/vehicle/ridden/wheelchair/wheels = new(holder_turf)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_holder)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.
	for(var/obj/item/dropped_item in holder_turf)
		if(dropped_item.fingerprintslast == quirk_holder.ckey)
			quirk_holder.put_in_hands(dropped_item)

/datum/quirk/paraplegic/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/poor_aim
	name = "Stormtrooper Aim"
	desc = "You've never hit anything you were aiming for in your life."
	value = -4
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	value = -4
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."

/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs will take conscious effort."
	value = -8
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = SPAN_DANGER("You feel like a pushover.")
	lose_text = SPAN_NOTICE("You feel like standing up for yourself.")
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. <b>This is not a license to grief.</b>"
	value = -8
	mob_trait = TRAIT_INSANITY
	gain_text = SPAN_USERDANGER("...")
	lose_text = SPAN_NOTICE("You feel in tune with the world again.")
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."
	processing_quirk = TRUE

/datum/quirk/insanity/process(delta_time)
	if(quirk_holder.stat == DEAD)
		return

	if(DT_PROB(2, delta_time))
		quirk_holder.hallucination += rand(10, 25)

/datum/quirk/insanity/post_add() //I don't /think/ we'll need this but for newbies who think "roleplay as insane" = "license to kill" it's probably a good thing to have
	if(!quirk_holder.mind || quirk_holder.mind.special_role)
		return
	to_chat(quirk_holder, "<span class='big bold info'>Please note that your dissociation syndrome does NOT give you the right to attack people or otherwise cause any interference to \
	the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")

/datum/quirk/mute
	name = "Mute"
	desc = "Due to some accident, medical condition, or simply by choice, you are completely unable to speak."
	value = -2
	gain_text = SPAN_DANGER("You find yourself unable to speak!")
	lose_text = SPAN_NOTICE("You feel a growing strength in your vocal chords.")
	medical_record_text = "Functionally mute, patient is unable to use their voice in any capacity."

/datum/quirk/mute/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(new /datum/brain_trauma/severe/mute, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/mute/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder?.cure_trauma_type(/datum/brain_trauma/severe/mute, TRAUMA_RESILIENCE_ABSOLUTE)

