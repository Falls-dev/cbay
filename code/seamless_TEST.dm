/turf/seamless_l
	blocks_air = 1
	icon_state = "clean"
	New()
		..()
		spawn(3)
			Check()

/turf/seamless_r
	blocks_air = 1
	icon_state = "clean"
	New()
		..()
		spawn(3)
			Check()

/turf/seamless_l/proc/Check()
	var/turf/T = locate(x+128, y, z)
	if (T)
		if (istype(T, /turf/simulated/wall))
			new /turf/simulated/wall(src)
		vis_contents += T

/turf/seamless_r/proc/Check()
	var/turf/T = locate(x-128, y, z)
	if (T)
		if (istype(T, /turf/simulated/wall))
			new /turf/simulated/wall(src)
		vis_contents += T

/turf/seamless_l/Enter(var/atom/movable/AM)
	if (..())
		if(AM)
			Check()
			AM.Move(locate(x+128, y, z))
	return ..()

/turf/seamless_r/Enter(var/atom/movable/AM)
	if (..())
		if(AM)
			Check()
			AM.Move(locate(x-128, y, z))
	return ..()

/area/seamless
	name = "???"
	requires_power = 0
	luminosity = 1
	ul_Lighting = 0