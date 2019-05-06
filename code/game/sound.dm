/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num)
	//Frequency stuff only works with 45kbps oggs.

	switch(soundin)
		if ("shatter") soundin = pick('OGGS/effects/Glassbr1.ogg','OGGS/effects/Glassbr2.ogg','OGGS/effects/Glassbr3.ogg')
		if ("explosion") soundin = pick('OGGS/effects/Explosion1.ogg','OGGS/effects/Explosion2.ogg')
		if ("sparks") soundin = pick('OGGS/effects/sparks1.ogg','OGGS/effects/sparks2.ogg','OGGS/effects/sparks3.ogg','OGGS/effects/sparks4.ogg')
		if ("rustle") soundin = pick('OGGS/misc/rustle1.ogg','OGGS/misc/rustle2.ogg','OGGS/misc/rustle3.ogg','OGGS/misc/rustle4.ogg','OGGS/misc/rustle5.ogg')
		if ("punch") soundin = pick('OGGS/weapons/punch1.ogg','OGGS/weapons/punch2.ogg','OGGS/weapons/punch3.ogg','OGGS/weapons/punch4.ogg')
		if ("clownstep") soundin = pick('OGGS/misc/clownstep1.ogg','OGGS/misc/clownstep2.ogg')
		if ("swing_hit") soundin = pick('OGGS/weapons/genhit1.ogg', 'OGGS/weapons/genhit2.ogg', 'OGGS/weapons/genhit3.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	for (var/mob/M in range(world.view+extrarange, source))
		if (M.client)
			if(isturf(source))
				var/dx = source.x - M.x
				S.pan = max(-100, min(100, dx/8.0 * 100))
			M << S

/mob/proc/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num)
	if(!src.client)
		return
	switch(soundin)
		if ("shatter") soundin = pick('OGGS/effects/Glassbr1.ogg','OGGS/effects/Glassbr2.ogg','OGGS/effects/Glassbr3.ogg')
		if ("explosion") soundin = pick('OGGS/effects/Explosion1.ogg','OGGS/effects/Explosion2.ogg')
		if ("sparks") soundin = pick('OGGS/effects/sparks1.ogg','OGGS/effects/sparks2.ogg','OGGS/effects/sparks3.ogg','OGGS/effects/sparks4.ogg')
		if ("rustle") soundin = pick('OGGS/misc/rustle1.ogg','OGGS/misc/rustle2.ogg','OGGS/misc/rustle3.ogg','OGGS/misc/rustle4.ogg','OGGS/misc/rustle5.ogg')
		if ("punch") soundin = pick('OGGS/weapons/punch1.ogg','OGGS/weapons/punch2.ogg','OGGS/weapons/punch3.ogg','OGGS/weapons/punch4.ogg')
		if ("clownstep") soundin = pick('OGGS/misc/clownstep1.ogg','OGGS/misc/clownstep2.ogg')
		if ("swing_hit") soundin = pick('OGGS/weapons/genhit1.ogg', 'OGGS/weapons/genhit2.ogg', 'OGGS/weapons/genhit3.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	if(isturf(source))
		var/dx = source.x - src.x
		S.pan = max(-100, min(100, dx/8.0 * 100))
	src << S

client/verb/Toggle_Soundscape()
	usr:client:play_ambiences = !usr:client:play_ambiences
	usr << "Toggled ambient sound."
	return


/area/Entered(A)

	if(!music)
		music = list('OGGS/ambience/ambigen1.ogg','OGGS/ambience/ambigen2.ogg','OGGS/ambience/ambigen3.ogg','OGGS/ambience/ambigen4.ogg','OGGS/ambience/ambigen5.ogg','OGGS/ambience/ambigen6.ogg','OGGS/ambience/ambigen7.ogg','OGGS/ambience/ambigen8.ogg','OGGS/ambience/ambigen9.ogg','OGGS/ambience/ambigen10.ogg','OGGS/ambience/ambigen11.ogg','OGGS/ambience/ambigen12.ogg','OGGS/ambience/ambigen13.ogg','OGGS/ambience/ambigen14.ogg')

	if(!istype(music, /list))
		music = list(music)

	if (ismob(A))

		if (istype(A, /mob/dead)) return
		if (!A:client) return
		if (A:ear_deaf) return

		if (prob(35))
			if(A && A:client && !A:client:played)
				A << sound(pick(music), repeat = 0, wait = 0, volume = 25, channel = 1)
				A:client:played = 1
				spawn(600 * tick_multiplier)
					if(A && A:client)
						A:client:played = 0
