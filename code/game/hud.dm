//LEFT UI

//LEFT SIDE

#define ui_ears 	 "-1.9, NORTH-1.5"
#define ui_back 	 "-1.9, NORTH-2.5"
#define ui_rhand 	 "-1.9, NORTH-3.5"
#define ui_gloves 	 "-1.9, NORTH-4.5"
#define ui_storage1  "-1.9, NORTH-5.5"

//CENTRAL SIDE

#define ui_head 	 "-1, NORTH-1"
#define ui_mask 	 "-1, NORTH-2"
#define ui_hand 	 "-1, NORTH-3"
#define ui_oclothing "-1, NORTH-4"
#define ui_iclothing "-1, NORTH-5"
#define ui_belt 	 "-1, NORTH-6"
#define ui_shoes 	 "-1, NORTH-7"
#define ui_acti 	 "-1.12, NORTH-8.02"
#define ui_pull 	 "-1, NORTH-13"

//RIGHT SIDE

#define ui_glasses   "-0.1,  NORTH-1.5"
#define ui_lhand 	 "-0.1,  NORTH-3.5"
#define ui_sstore1 	 "-0.1,  NORTH-4.5"
#define ui_storage2  "-0.1,  NORTH-5.5"
#define ui_id 		 "-0.1,  NORTH-6.5"

#define ui_throw 	  "-0.25, NORTH-6.95"
#define ui_swapbutton "-0.25, NORTH-7.55"
#define ui_dropbutton "-0.25, NORTH-7.55"

//RIGHT UI
#define ui_resist 	  "EAST+1, NORTH-14"
#define ui_sleep 	  "EAST+1, NORTH-13"
#define ui_health     "EAST+1, NORTH-11"
#define ui_temp       "EAST+1, NORTH-10"
#define ui_rest       "EAST+1, NORTH-9"
#define ui_fire       "EAST+1, NORTH-8"
#define ui_movi       "EAST+1, NORTH-7"
#define ui_toxin      "EAST+1, NORTH-6"
#define ui_oxygen     "EAST+1, NORTH-4"
#define ui_internal   "EAST+1, NORTH-2"

#define ui_cyberscreen "-2, SOUTH"

/*
#define ui_hstore1 	 "5, NORTH-2"
*/

/*
//TESTING A LAYOUT
#define ui_mask "SOUTH-1:-14,1:7"
#define ui_headset "SOUTH-2:-14,1:7"
#define ui_head "SOUTH-1:-14,1:51"
#define ui_glasses "SOUTH-1:-14,2:51"
#define ui_ears "SOUTH-1:-14,3:51"
#define ui_oclothing "SOUTH-1:-49,1:51"
#define ui_iclothing "SOUTH-2:-49,1:51"
#define ui_shoes "SOUTH-3:-49,1:51"
#define ui_back "SOUTH-1:-49,2:51"
#define ui_lhand "SOUTH-2:-49,2:51"
#define ui_rhand "SOUTH-2:-49,0:51"
#define ui_gloves "SOUTH-3:-49,0:51"
#define ui_belt "SOUTH-2:-49,1:127"
#define ui_id "SOUTH-2:-49,2:127"
#define ui_storage1 "SOUTH-3:-49,1:127"
#define ui_storage2 "SOUTH-3:-49,2:127"

#define ui_dropbutton "SOUTH-3,12"
#define ui_swapbutton "SOUTH-1,13"
#define ui_resist "SOUTH-3,14"
#define ui_throw "SOUTH-3,15"
#define ui_oxygen "EAST+1, NORTH-4"
#define ui_toxin "EAST+1, NORTH-6"
#define ui_internal "EAST+1, NORTH-2"
#define ui_fire "EAST+1, NORTH-8"
#define ui_temp "EAST+1, NORTH-10"
#define ui_health "EAST+1, NORTH-11"
#define ui_pull "WEST+6,SOUTH-2"
#define ui_hand "SOUTH-1,6"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"
//TESTING A LAYOUT
*/

/obj/hud
	name = "hud"
	var/mob/mymob = null
	var/list/adding = null
	var/list/other = null
	var/list/intents = null
	var/list/mov_int = null
	var/list/mon_blo = null
	var/list/m_ints = null
	var/obj/screen/druggy = null
	var/vimpaired = null
	var/obj/screen/alien_view = null
	var/obj/screen/g_dither = null
	var/obj/screen/r_dither = null
	var/obj/screen/gray_dither = null
	var/obj/screen/lp_dither = null
	var/obj/screen/blurry = null
	var/obj/screen/breath = null
	var/list/welding = null
	var/list/darkMask = null
	var/obj/screen/station_explosion = null
	var/h_type = /obj/screen


mob/living/carbon/uses_hud = 1
mob/living/silicon/robot/uses_hud = 1


obj/hud/New()
	src.instantiate()
	..()
	return


/obj/hud/proc/other_update()

	if(!mymob) return
	if(show_otherinventory)
		if(mymob:shoes) mymob:shoes:screen_loc = ui_shoes
		if(mymob:gloves) mymob:gloves:screen_loc = ui_gloves
		if(mymob:ears) mymob:ears:screen_loc = ui_ears
		if(mymob:s_store) mymob:s_store:screen_loc = ui_sstore1
		if(mymob:glasses) mymob:glasses:screen_loc = ui_glasses
	else
		if(mymob:shoes) mymob:shoes:screen_loc = null
		if(mymob:gloves) mymob:gloves:screen_loc = null
		if(mymob:ears) mymob:ears:screen_loc = null
		if(mymob:s_store) mymob:s_store:screen_loc = null
		if(mymob:h_store) mymob:h_store:screen_loc = null
		if(mymob:glasses) mymob:glasses:screen_loc = null


/obj/hud/var/show_otherinventory = 1
/obj/hud/var/obj/screen/action_intent
/obj/hud/var/obj/screen/move_intent

/obj/hud/proc/instantiate()

	mymob = src.loc
	ASSERT(istype(mymob, /mob))

	if(!mymob.uses_hud) return

	if(istype(mymob, /mob/living/carbon/human))
		src.human_hud()
		return

	if(istype(mymob, /mob/living/carbon/monkey))
		src.monkey_hud()
		return

	//aliens
	if(istype(mymob, /mob/living/carbon/alien/larva))
		src.larva_hud()
	else if(istype(mymob, /mob/living/carbon/alien))
		src.alien_hud()
		return

	if(istype(mymob, /mob/living/silicon/ai))
		src.ai_hud()
		return

	if(istype(mymob, /mob/living/silicon/robot))
		src.robot_hud()
		return

	if(istype(mymob, /mob/dead/observer))
		src.ghost_hud()
		return
	if(istype(mymob,/mob/dead/official))
		src.ghost_hud()
		return
