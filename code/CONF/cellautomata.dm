/world/New()
	src.load_configuration()

	if (config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	. = ..()

	master_controller = new /datum/controller/game_controller()
	spawn(-1) master_controller.setup()
	return

/world/Reboot(var/reason)
	if(makejson)
		send2irc(world.url,"Server Rebooting!")
	world << "\red <B>Rebooting! (This may take a while, just hang on unless you receive an error message!)</B>"
	spawn(0)
		for(var/client/C)
			C << link("byond://[world.internet_address]:[world.port]")
	..(reason)

/atom/proc/check_eye(user as mob)
	if (istype(user, /mob/living/silicon/ai))
		return 1
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM as mob|obj)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, yes)
	spawn( 0 )
		if ((A && yes))
			A.last_bumped = world.timeofday
			A.Bumped(src)
		return
	..()
	return

// **** Note in 40.93.4, split into obj/mob/turf point verbs, no area

/atom/verb/point()
	set category = "Object"
	set src in oview()

	if (!usr || !isturf(usr.loc))
		return
	else if (usr.stat != 0 || usr.restrained())
		return

	var/tile = get_turf(src)
	if (!tile)
		return

	var/P = new /obj/decal/point(tile)
	spawn (20)
		del(P)

	usr.visible_message("<b>[usr]</b> points to [src]")

/obj/decal/point/point()
	set src in oview()
	set hidden = 1
	return

/proc/heartbeat()
	spawn(0)
		while (1)
			sleep(100 * tick_multiplier)
			world.Export("http://127.0.0.1:31337")