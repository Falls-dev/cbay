datum/track
	var/title
	var/sound

datum/track/New(var/title_name, var/audio)
	title = title_name
	sound = audio

/obj/machinery/jukebox
	name = "jukebox"
	icon = 'ICON/obj/jukebox.dmi'
	icon_state = "jukebox"
	anchored = 1
	density = 0

	var/playing = 0
	var/volume = 100


	var/datum/track/current_track
	var/list/datum/track/tracks = list(
		new/datum/track("Song 1", 'OGGS/jukebox/barsong1.ogg'),
		new/datum/track("Song 2", 'OGGS/jukebox/barsong2.ogg'),
	)

/obj/machinery/jukebox/attack_hand(user as mob)
	var/dat = "<HEAD><TITLE>Jukebox</TITLE></HEAD><B>Jukebox</B><BR>"
	if (!playing)
		for(var/datum/track/T in tracks)
			dat += text("[T.title]<br> <a href='byond://?src=\ref[src];play=\ref[T.title]'>Play</A> <a href='byond://?src=\ref[src];stop=\ref[T.title]'>Vend</A>")
	else
		dat += text("Now playing [current_track]<br>")
	user << browse("[dat]","window=jukebox")
	onclose(user, "jukebox")

/obj/machinery/jukebox/proc/play()
	stop()

	spawn _SoundEngine('OGGS/jukebox/barsong1.ogg', src, range=80, repeat=1, volume=volume, falloff=5)

	playing = 1

/obj/machinery/jukebox/proc/stop()
	playing = 0
	return

/obj/machinery/jukebox/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return

	if(istype(usr,/mob/living/silicon))
		usr << "\red The vending machine refuses to interface with you, as you are not in its target demographic!"
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if ((href_list["play"]) && (!src.playing))
			play()
			return
		else if ((href_list["stop"]) && (src.playing))
			stop()
			return
		return
	return

