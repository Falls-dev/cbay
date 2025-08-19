/*
Contains helper procs for airflow, handled in /connection_group.
*/

mob/var/tmp/last_airflow_stun = 0
mob/proc/airflow_stun()
	if(stat == 2)
		return 0
	if(last_airflow_stun > world.time - vsc.airflow_stun_cooldown)	return 0

	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0
	if(buckled)
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return 0
	if(!lying)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	Weaken(5)
	last_airflow_stun = world.time

mob/living/silicon/airflow_stun()
	return

mob/living/carbon/slime/airflow_stun()
	return

mob/living/carbon/human/airflow_stun()
	if(!slip_chance())
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return 0
	..()

atom/movable/proc/check_airflow_movable(n)

	if(anchored && !ismob(src)) return 0

	if(!isobj(src) && n < vsc.airflow_dense_pressure) return 0

	return 1

mob/check_airflow_movable(n)
	if(n < vsc.airflow_heavy_pressure)
		return 0
	return 1

mob/living/silicon/check_airflow_movable()
	return 0


obj/check_airflow_movable(n)
	if(isnull(w_class))
		if(n < vsc.airflow_dense_pressure) return 0 //most non-item objs don't have a w_class yet
	else
		switch(w_class)
			if(1,2)
				if(n < vsc.airflow_lightest_pressure) return 0
			if(3)
				if(n < vsc.airflow_light_pressure) return 0
			if(4,5)
				if(n < vsc.airflow_medium_pressure) return 0
			if(6)
				if(n < vsc.airflow_heavy_pressure) return 0
			if(7 to INFINITY)
				if(n < vsc.airflow_dense_pressure) return 0
	return ..()


/atom/movable/var/tmp/turf/airflow_dest
/atom/movable/var/tmp/airflow_speed = 0
/atom/movable/var/tmp/airflow_time = 0
/atom/movable/var/tmp/last_airflow = 0
/atom/movable/var/tmp/airborne_acceleration = 0

/atom/movable/proc/AirflowCanMove(n)
	return 1

/mob/AirflowCanMove(n)
	if(status_flags & GODMODE)
		return 0
	if(buckled)
		return 0
	var/obj/item/shoes = get_equipped_item(slot_shoes)
	if(istype(shoes) && (shoes.item_flags & ITEM_FLAG_NOSLIP))
		return 0
	return 1

/atom/movable/Bump(atom/A)
	if(airflow_speed > 0 && airflow_dest)
		if(airborne_acceleration > 1)
			airflow_hit(A)
		else if(istype(src, /mob/living/carbon/human))
			to_chat(src, "<span class='notice'>You are pinned against [A] by airflow!</span>")
			airborne_acceleration = 0
	else
		airflow_speed = 0
		airflow_time = 0
		airborne_acceleration = 0
		. = ..()

atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null
	airborne_acceleration = 0

mob/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("<span class='danger'>\The [src] slams into \a [A]!</span>",1,"<span class='danger'>You hear a loud slam!</span>",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	var/weak_amt = istype(A,/obj/item) ? A:w_class : rand(1,5) //Heheheh
	Weaken(weak_amt)
	. = ..()

obj/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("<span class='danger'>\The [src] slams into \a [A]!</span>",1,"<span class='danger'>You hear a loud slam!</span>",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	. = ..()

obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/living/carbon/human/airflow_hit(atom/A)
//	for(var/mob/M in hearers(src))
//		M.show_message("<span class='danger'>[src] slams into [A]!</span>",1,"<span class='danger'>You hear a loud slam!</span>",2)
	playsound(src.loc, "punch", 25, 1, -1)
	if (prob(33))
		loc:add_blood(src)
		bloody_body(src)
	var/b_loss = min(airflow_speed, (airborne_acceleration*2)) * vsc.airflow_damage

	apply_damage(b_loss/3, BRUTE, BP_HEAD, used_weapon = "Airflow")

	apply_damage(b_loss/3, BRUTE, BP_CHEST, used_weapon =  "Airflow")

	apply_damage(b_loss/3, BRUTE, BP_GROIN, used_weapon =  "Airflow")

	if(airflow_speed > 10)
		Paralyse(round(airflow_speed * vsc.airflow_stun))
		Stun(paralysis + 3)
	else
		Stun(round(airflow_speed * vsc.airflow_stun/2))
	. = ..()

zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/movable/A in T)
			if(!A.simulated || A.anchored || istype(A, /obj/effect) || isobserver(A))
				continue
			. += A


/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.

	return (!density || !height || air_group)

/turf/CanPass(atom/movable/mover, turf/target, height=1.5,air_group=0)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height, air_group))
				return 0
		if(target != src)
			for(var/obj/obstacle in target)
				if(!obstacle.CanPass(mover, src, height, air_group))
					return 0

		return 1

//Convenience function for atoms to update turfs they occupy
/atom/movable/proc/update_nearby_tiles(need_rebuild)
	for(var/turf/simulated/turf in locs)
		SSair.mark_for_update(turf)

	return 1

//Basically another way of calling CanPass(null, other, 0, 0) and CanPass(null, other, 1.5, 1).
//Returns:
// 0 - Not blocked
// AIR_BLOCKED - Blocked
// ZONE_BLOCKED - Not blocked, but zone boundaries will not cross.
// BLOCKED - Blocked, zone boundaries will not cross even if opened.
atom/proc/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	return (AIR_BLOCKED*!CanPass(null, other, 0, 0))|(ZONE_BLOCKED*!CanPass(null, other, 1.5, 1))


turf/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	if(((blocks_air & AIR_BLOCKED) || (other.blocks_air & AIR_BLOCKED)))
		return BLOCKED

	//Z-level handling code. Always block if there isn't an open space.
	#ifdef MULTIZAS
	if(other.z != src.z)
		if(other.z < src.z)
			if(!istype(src, /turf/simulated/open)) return BLOCKED
		else
			if(!istype(other, /turf/simulated/open)) return BLOCKED
	#endif

	if(((blocks_air & ZONE_BLOCKED) || (other.blocks_air & ZONE_BLOCKED)))
		if(z == other.z)
			return ZONE_BLOCKED
		else
			return AIR_BLOCKED

	var/result = 0
	for(var/mm in contents)
		var/atom/movable/M = mm
		result |= M.c_airblock(other)
		if(result == BLOCKED) return BLOCKED
	return result

/atom/movable
	var/atmos_canpass = CANPASS_ALWAYS

#define CONNECTION_DIRECT 2
#define CONNECTION_SPACE 4
#define CONNECTION_INVALID 8

/*

Overview:
	Connections are made between turfs by SSair.connect(). They represent a single point where two zones converge.

Class Vars:
	A - Always a simulated turf.
	B - A simulated or unsimulated turf.

	zoneA - The archived zone of A. Used to check that the zone hasn't changed.
	zoneB - The archived zone of B. May be null in case of unsimulated connections.

	edge - Stores the edge this connection is in. Can reference an edge that is no longer processed
		   after this connection is removed, so make sure to check edge.coefficient > 0 before re-adding it.

Class Procs:

	mark_direct()
		Marks this connection as direct. Does not update the edge.
		Called when the connection is made and there are no doors between A and B.
		Also called by update() as a correction.

	mark_indirect()
		Unmarks this connection as direct. Does not update the edge.
		Called by update() as a correction.

	mark_space()
		Marks this connection as unsimulated. Updating the connection will check the validity of this.
		Called when the connection is made.
		This will not be called as a correction, any connections failing a check against this mark are erased and rebuilt.

	direct()
		Returns 1 if no doors are in between A and B.

	valid()
		Returns 1 if the connection has not been erased.

	erase()
		Called by update() and connection_manager/erase_all().
		Marks the connection as erased and removes it from its edge.

	update()
		Called by connection_manager/update_all().
		Makes numerous checks to decide whether the connection is still valid. Erases it automatically if not.

*/

/connection/var/turf/simulated/A
/connection/var/turf/simulated/B
/connection/var/zone/zoneA
/connection/var/zone/zoneB

/connection/var/connection_edge/edge

/connection/var/state = 0

/connection/New(turf/simulated/A, turf/simulated/B)
	#ifdef ZASDBG
	ASSERT(SSair.has_valid_zone(A))
	//ASSERT(SSair.has_valid_zone(B))
	#endif
	src.A = A
	src.B = B
	zoneA = A.zone
	if(!istype(B))
		mark_space()
		edge = SSair.get_edge(A.zone,B)
		edge.add_connection(src)
	else
		zoneB = B.zone
		edge = SSair.get_edge(A.zone,B.zone)
		edge.add_connection(src)

/connection/proc/mark_direct()
	if(!direct())
		state |= CONNECTION_DIRECT
		edge.direct++
//	log_debug("Marked direct.")

/connection/proc/mark_indirect()
	if(direct())
		state &= ~CONNECTION_DIRECT
		edge.direct--
//	log_debug("Marked indirect.")

/connection/proc/mark_space()
	state |= CONNECTION_SPACE

/connection/proc/direct()
	return (state & CONNECTION_DIRECT)

/connection/proc/valid()
	return !(state & CONNECTION_INVALID)

/connection/proc/erase()
	edge.remove_connection(src)
	state |= CONNECTION_INVALID
//	log_debug("Connection Erased: [state]")

/connection/proc/update()
//	log_debug("Updated, \...")
	if(!istype(A,/turf/simulated))
//		log_debug("Invalid A.")
		erase()
		return

	var/block_status = SSair.air_blocked(A,B)
	if(block_status & AIR_BLOCKED)
//		log_debug("Blocked connection.")
		erase()
		return
	else if(block_status & ZONE_BLOCKED)
		mark_indirect()
	else
		mark_direct()

	var/b_is_space = !istype(B,/turf/simulated)

	if(state & CONNECTION_SPACE)
		if(!b_is_space)
//			log_debug("Invalid B.")
			erase()
			return
		if(A.zone != zoneA)
//			log_debug("Zone changed, \...")
			if(!A.zone)
				erase()
//				log_debug("erased.")
				return
			else
				edge.remove_connection(src)
				edge = SSair.get_edge(A.zone, B)
				edge.add_connection(src)
				zoneA = A.zone

//		log_debug("valid.")
		return

	else if(b_is_space)
//		log_debug("Invalid B.")
		erase()
		return

	if(A.zone == B.zone)
//		log_debug("A == B")
		erase()
		return

	if(A.zone != zoneA || (zoneB && (B.zone != zoneB)))

//		log_debug("Zones changed, \...")
		if(A.zone && B.zone)
			edge.remove_connection(src)
			edge = SSair.get_edge(A.zone, B.zone)
			edge.add_connection(src)
			zoneA = A.zone
			zoneB = B.zone
		else
//			log_debug("erased.")
			erase()
			return


//	log_debug("valid.")

/*

Overview:
	These are what handle gas transfers between zones and into space.
	They are found in a zone's edges list and in SSair.edges.
	Each edge updates every air tick due to their role in gas transfer.
	They come in two flavors, /connection_edge/zone and /connection_edge/unsimulated.
	As the type names might suggest, they handle inter-zone and spacelike connections respectively.

Class Vars:

	A - This always holds a zone. In unsimulated edges, it holds the only zone.

	connecting_turfs - This holds a list of connected turfs, mainly for the sake of airflow.

	coefficent - This is a marker for how many connections are on this edge. Used to determine the ratio of flow.

	connection_edge/zone

		B - This holds the second zone with which the first zone equalizes.

		direct - This counts the number of direct (i.e. with no doors) connections on this edge.
		         Any value of this is sufficient to make the zones mergeable.

	connection_edge/unsimulated

		B - This holds an unsimulated turf which has the gas values this edge is mimicing.

		air - Retrieved from B on creation and used as an argument for the legacy ShareSpace() proc.

Class Procs:

	add_connection(connection/c)
		Adds a connection to this edge. Usually increments the coefficient and adds a turf to connecting_turfs.

	remove_connection(connection/c)
		Removes a connection from this edge. This works even if c is not in the edge, so be careful.
		If the coefficient reaches zero as a result, the edge is erased.

	contains_zone(zone/Z)
		Returns true if either A or B is equal to Z. Unsimulated connections return true only on A.

	erase()
		Removes this connection from processing and zone edge lists.

	tick()
		Called every air tick on edges in the processing list. Equalizes gas.

	flow(list/movable, differential, repelled)
		Airflow proc causing all objects in movable to be checked against a pressure differential.
		If repelled is true, the objects move away from any turf in connecting_turfs, otherwise they approach.
		A check against vsc.lightest_airflow_pressure should generally be performed before calling this.

	get_connected_zone(zone/from)
		Helper proc that allows getting the other zone of an edge given one of them.
		Only on /connection_edge/zone, otherwise use A.

*/


/connection_edge/var/zone/A

/connection_edge/var/list/connecting_turfs = list()
/connection_edge/var/direct = 0
/connection_edge/var/sleeping = 1

/connection_edge/var/coefficient = 0

/connection_edge/New()
	CRASH("Cannot make connection edge without specifications.")

/connection_edge/proc/add_connection(connection/c)
	coefficient++
	if(c.direct()) direct++
//	log_debug("Connection added: [type] Coefficient: [coefficient]")


/connection_edge/proc/remove_connection(connection/c)
//	log_debug("Connection removed: [type] Coefficient: [coefficient-1]")

	coefficient--
	if(coefficient <= 0)
		erase()
	if(c.direct()) direct--

/connection_edge/proc/contains_zone(zone/Z)

/connection_edge/proc/erase()
	SSair.remove_edge(src)
//	log_debug("[type] Erased.")


/connection_edge/proc/tick()

/connection_edge/proc/recheck()

/connection_edge/proc/flow(list/movable, differential, repelled)
	for(var/i = 1; i <= movable.len; i++)
		var/atom/movable/M = movable[i]

		//If they're already being tossed, don't do it again.
		if(M.last_airflow > world.time - vsc.airflow_delay) continue
		if(M.airflow_speed) continue

		//Check for knocking people over
		if(ismob(M) && differential > vsc.airflow_stun_pressure)
			if(M:status_flags & GODMODE) continue
			M:airflow_stun()

		if(M.check_airflow_movable(differential))
			//Check for things that are in range of the midpoint turfs.
			var/list/close_turfs = list()
			for(var/turf/U in connecting_turfs)
				if(get_dist(M,U) < world.view) close_turfs += U
			if(!close_turfs.len) continue

			M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.

			if(repelled) spawn if(M) M.RepelAirflowDest(differential/5)
			else spawn if(M) M.GotoAirflowDest(differential/10)




/connection_edge/zone/var/zone/B

/connection_edge/zone/New(zone/A, zone/B)

	src.A = A
	src.B = B
	A.edges.Add(src)
	B.edges.Add(src)
	//id = edge_id(A,B)
//	log_debug("New edge between [A] and [B]")


/connection_edge/zone/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.A)

/connection_edge/zone/remove_connection(connection/c)
	connecting_turfs.Remove(c.A)
	. = ..()

/connection_edge/zone/contains_zone(zone/Z)
	return A == Z || B == Z

/connection_edge/zone/erase()
	A.edges.Remove(src)
	B.edges.Remove(src)
	. = ..()

/connection_edge/zone/tick()
	if(A.invalid || B.invalid)
		erase()
		return

	var/equiv = A.air.share_ratio(B.air, coefficient)

	var/differential = A.air.return_pressure() - B.air.return_pressure()
	if(abs(differential) >= vsc.airflow_lightest_pressure)
		var/list/attracted
		var/list/repelled
		if(differential > 0)
			attracted = A.movables()
			repelled = B.movables()
		else
			attracted = B.movables()
			repelled = A.movables()

		flow(attracted, abs(differential), 0)
		flow(repelled, abs(differential), 1)

	if(equiv)
		if(direct)
			erase()
			SSair.merge(A, B)
			return
		else
			A.air.equalize(B.air)
			SSair.mark_edge_sleeping(src)

	SSair.mark_zone_update(A)
	SSair.mark_zone_update(B)

/connection_edge/zone/recheck()
	if(!A.air.compare(B.air, vacuum_exception = 1))
	// Edges with only one side being vacuum need processing no matter how close.
		SSair.mark_edge_active(src)

//Helper proc to get connections for a zone.
/connection_edge/zone/proc/get_connected_zone(zone/from)
	if(A == from) return B
	else return A

/connection_edge/unsimulated/var/turf/B
/connection_edge/unsimulated/var/datum/gas_mixture/air

/connection_edge/unsimulated/New(zone/A, turf/B)
	src.A = A
	src.B = B
	A.edges.Add(src)
	air = B.return_air()
	//id = 52*A.id
//	log_debug("New edge from [A] to [B].")


/connection_edge/unsimulated/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.B)
	air.group_multiplier = coefficient

/connection_edge/unsimulated/remove_connection(connection/c)
	connecting_turfs.Remove(c.B)
	air.group_multiplier = coefficient
	. = ..()

/connection_edge/unsimulated/erase()
	A.edges.Remove(src)
	. = ..()

/connection_edge/unsimulated/contains_zone(zone/Z)
	return A == Z

/connection_edge/unsimulated/tick()
	if(A.invalid)
		erase()
		return

	var/equiv = A.air.share_space(air)

	var/differential = A.air.return_pressure() - air.return_pressure()
	if(abs(differential) >= vsc.airflow_lightest_pressure)
		var/list/attracted = A.movables()
		flow(attracted, abs(differential), differential < 0)

	if(equiv)
		A.air.copy_from(air)
		SSair.mark_edge_sleeping(src)

	SSair.mark_zone_update(A)

/connection_edge/unsimulated/recheck()
	// Edges with only one side being vacuum need processing no matter how close.
	// Note: This handles the glaring flaw of a room holding pressure while exposed to space, but
	// does not specially handle the less common case of a simulated room exposed to an unsimulated pressurized turf.
	if(!A.air.compare(air, vacuum_exception = 1))
		SSair.mark_edge_active(src)

proc/ShareHeat(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//This implements a simplistic version of the Stefan-Boltzmann law.
	var/energy_delta = ((A.temperature - B.temperature) ** 4) * STEFAN_BOLTZMANN_CONSTANT * connecting_tiles * 2.5
	var/maximum_energy_delta = max(0, min(A.temperature * A.heat_capacity() * A.group_multiplier, B.temperature * B.heat_capacity() * B.group_multiplier))
	if(maximum_energy_delta > abs(energy_delta))
		if(energy_delta < 0)
			maximum_energy_delta *= -1
		energy_delta = maximum_energy_delta

	A.temperature -= energy_delta / (A.heat_capacity() * A.group_multiplier)
	B.temperature += energy_delta / (B.heat_capacity() * B.group_multiplier)

/*

Overview:
	The connection_manager class stores connections in each cardinal direction on a turf.
	It isn't always present if a turf has no connections, check if(connections) before using.
	Contains procs for mass manipulation of connection data.

Class Vars:

	NSEWUD - Connections to this turf in each cardinal direction.

Class Procs:

	get(d)
		Returns the connection (if any) in this direction.
		Preferable to accessing the connection directly because it checks validity.

	place(connection/c, d)
		Called by air_master.connect(). Sets the connection in the specified direction to c.

	update_all()
		Called after turf/update_air_properties(). Updates the validity of all connections on this turf.

	erase_all()
		Called when the turf is changed with ChangeTurf(). Erases all existing connections.

Macros:
	check(connection/c)
		Checks for connection validity. It's possible to have a reference to a connection that has been erased.


*/

// macro-ized to cut down on proc calls
#define check(c) (c && c.valid())

/turf/var/tmp/connection_manager/connections

/connection_manager/var/connection/N
/connection_manager/var/connection/S
/connection_manager/var/connection/E
/connection_manager/var/connection/W

#ifdef MULTIZAS
/connection_manager/var/connection/U
/connection_manager/var/connection/D
#endif

/connection_manager/proc/get(d)
	switch(d)
		if(NORTH)
			if(check(N)) return N
			else return null
		if(SOUTH)
			if(check(S)) return S
			else return null
		if(EAST)
			if(check(E)) return E
			else return null
		if(WEST)
			if(check(W)) return W
			else return null

		#ifdef MULTIZAS
		if(UP)
			if(check(U)) return U
			else return null
		if(DOWN)
			if(check(D)) return D
			else return null
		#endif

/connection_manager/proc/place(connection/c, d)
	switch(d)
		if(NORTH) N = c
		if(SOUTH) S = c
		if(EAST) E = c
		if(WEST) W = c

		#ifdef MULTIZAS
		if(UP) U = c
		if(DOWN) D = c
		#endif

/connection_manager/proc/update_all()
	if(check(N)) N.update()
	if(check(S)) S.update()
	if(check(E)) E.update()
	if(check(W)) W.update()
	#ifdef MULTIZAS
	if(check(U)) U.update()
	if(check(D)) D.update()
	#endif

/connection_manager/proc/erase_all()
	if(check(N)) N.erase()
	if(check(S)) S.erase()
	if(check(E)) E.erase()
	if(check(W)) W.erase()
	#ifdef MULTIZAS
	if(check(U)) U.erase()
	if(check(D)) D.erase()
	#endif

#undef check

var/image/assigned = image('icons/Testing/Zone.dmi', icon_state = "assigned")
var/image/created = image('icons/Testing/Zone.dmi', icon_state = "created")
var/image/merged = image('icons/Testing/Zone.dmi', icon_state = "merged")
var/image/invalid_zone = image('icons/Testing/Zone.dmi', icon_state = "invalid")
var/image/air_blocked = image('icons/Testing/Zone.dmi', icon_state = "block")
var/image/zone_blocked = image('icons/Testing/Zone.dmi', icon_state = "zoneblock")
var/image/blocked = image('icons/Testing/Zone.dmi', icon_state = "fullblock")
var/image/mark = image('icons/Testing/Zone.dmi', icon_state = "mark")

/connection_edge/var/dbg_out = 0

/turf/var/tmp/dbg_img
/turf/proc/dbg(image/img, d = 0)
	if(d > 0) img.dir = d
	overlays -= dbg_img
	overlays += img
	dbg_img = img

proc/soft_assert(thing,fail)
	if(!thing) message_admins(fail)

client/proc/Zone_Info(turf/T as null|turf)
	set category = "Debug"
	if(T)
		if(istype(T,/turf/simulated) && T:zone)
			T:zone:dbg_data(src)
		else
			to_chat(mob, "No zone here.")
			var/datum/gas_mixture/mix = T.return_air()
			to_chat(mob, "[mix.return_pressure()] kPa [mix.temperature]C")
			for(var/g in mix.gas)
				to_chat(mob, "[g]: [mix.gas[g]]\n")
	else
		if(zone_debug_images)
			for(var/zone in  zone_debug_images)
				images -= zone_debug_images[zone]
			zone_debug_images = null

client/var/list/zone_debug_images

client/proc/Test_ZAS_Connection(var/turf/simulated/T as turf)
	set category = "Debug"
	if(!istype(T))
		return

	var/direction_list = list(\
	"North" = NORTH,\
	"South" = SOUTH,\
	"East" = EAST,\
	"West" = WEST,\
	#ifdef MULTIZAS
	"Up" = UP,\
	"Down" = DOWN,\
	#endif
	"N/A" = null)
	var/direction = input("What direction do you wish to test?","Set direction") as null|anything in direction_list
	if(!direction)
		return

	if(direction == "N/A")
		if(!(T.c_airblock(T) & AIR_BLOCKED))
			to_chat(mob, "The turf can pass air! :D")
		else
			to_chat(mob, "No air passage :x")
		return

	var/turf/simulated/other_turf = get_step(T, direction_list[direction])
	if(!istype(other_turf))
		return

	var/t_block = T.c_airblock(other_turf)
	var/o_block = other_turf.c_airblock(T)

	if(o_block & AIR_BLOCKED)
		if(t_block & AIR_BLOCKED)
			to_chat(mob, "Neither turf can connect. :(")

		else
			to_chat(mob, "The initial turf only can connect. :\\")
	else
		if(t_block & AIR_BLOCKED)
			to_chat(mob, "The other turf can connect, but not the initial turf. :/")

		else
			to_chat(mob, "Both turfs can connect! :)")

	to_chat(mob, "Additionally, \...")

	if(o_block & ZONE_BLOCKED)
		if(t_block & ZONE_BLOCKED)
			to_chat(mob, "neither turf can merge.")
		else
			to_chat(mob, "the other turf cannot merge.")
	else
		if(t_block & ZONE_BLOCKED)
			to_chat(mob, "the initial turf cannot merge.")
		else
			to_chat(mob, "both turfs can merge.")

client/proc/ZASSettings()
	set category = "Debug"

	vsc.SetDefault(mob)

/*

Making Bombs with ZAS:
Get gas to react in an air tank so that it gains pressure. If it gains enough pressure, it goes boom.
The more pressure, the more boom.
If it gains pressure too slowly, it may leak or just rupture instead of exploding.
*/

//#define FIREDBG

/turf/var/obj/fire/fire = null

//Some legacy definitions so fires can be started.
atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

/atom/movable/proc/is_burnable()
	return FALSE

/mob/is_burnable()
	return simulated

turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)


/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	if(fire_protection > world.time-300)
		return 0
	if(locate(/obj/fire) in src)
		return 1
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents || exposed_temperature < PHORON_MINIMUM_BURN_TEMPERATURE)
		return 0

	var/igniting = 0
	var/obj/effect/decal/cleanable/liquid_fuel/liquid = locate() in src

	if(air_contents.check_combustability(liquid))
		igniting = 1

		create_fire(exposed_temperature)
	return igniting

/zone/proc/process_fire()
	var/datum/gas_mixture/burn_gas = air.remove_ratio(vsc.fire_consuption_rate, fire_tiles.len)

	var/firelevel = burn_gas.react(src, fire_tiles, force_burn = 1, no_check = 1)

	air.merge(burn_gas)

	if(firelevel)
		for(var/turf/T in fire_tiles)
			if(T.fire)
				T.fire.firelevel = firelevel
			else
				var/obj/effect/decal/cleanable/liquid_fuel/fuel = locate() in T
				fire_tiles -= T
				fuel_objs -= fuel
	else
		for(var/turf/simulated/T in fire_tiles)
			if(istype(T.fire))
				qdel(T.fire)
		fire_tiles.Cut()
		fuel_objs.Cut()

	if(!fire_tiles.len)
		SSair.active_fire_zones.Remove(src)

/zone/proc/remove_liquidfuel(var/used_liquid_fuel, var/remove_fire=0)
	if(!fuel_objs.len)
		return

	//As a simplification, we remove fuel equally from all fuel sources. It might be that some fuel sources have more fuel,
	//some have less, but whatever. It will mean that sometimes we will remove a tiny bit less fuel then we intended to.

	var/fuel_to_remove = used_liquid_fuel/(fuel_objs.len*LIQUIDFUEL_AMOUNT_TO_MOL) //convert back to liquid volume units

	for(var/O in fuel_objs)
		var/obj/effect/decal/cleanable/liquid_fuel/fuel = O
		if(!istype(fuel))
			fuel_objs -= fuel
			continue

		fuel.amount -= fuel_to_remove
		if(fuel.amount <= 0)
			fuel_objs -= fuel
			if(remove_fire)
				var/turf/T = fuel.loc
				if(istype(T) && T.fire) qdel(T.fire)
			qdel(fuel)

/turf/proc/create_fire(fl)
	return 0

/turf/simulated/create_fire(fl)

	if(submerged())
		return 1

	if(fire)
		fire.firelevel = max(fl, fire.firelevel)
		return 1

	if(!zone)
		return 1

	fire = new(src, fl)
	SSair.active_fire_zones |= zone

	var/obj/effect/decal/cleanable/liquid_fuel/fuel = locate() in src
	zone.fire_tiles |= src
	if(fuel) zone.fuel_objs += fuel

	return 0

/obj/fire
	//Icon for fire on turfs.

	anchored = 1
	mouse_opacity = 0

	blend_mode = BLEND_ADD

	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	light_color = "#ed9200"
	plane = EFFECTS_BELOW_LIGHTING_PLANE
	layer = FIRE_LAYER

	var/firelevel = 1 //Calculated by gas_mixture.calculate_firelevel()

/obj/fire/Process()
	. = 1

	var/turf/simulated/my_tile = loc
	if(!istype(my_tile) || !my_tile.zone || my_tile.submerged())
		if(my_tile && my_tile.fire == src)
			my_tile.fire = null
		qdel(src)
		return PROCESS_KILL

	var/datum/gas_mixture/air_contents = my_tile.return_air()

	if(firelevel > 6)
		icon_state = "3"
		set_light(1, 2, 7)
	else if(firelevel > 2.5)
		icon_state = "2"
		set_light(0.7, 2, 5)
	else
		icon_state = "1"
		set_light(0.5, 1, 3)

	for(var/mob/living/L in loc)
		L.FireBurn(firelevel, air_contents.temperature, air_contents.return_pressure())  //Burn the mobs!

	loc.fire_act(air_contents, air_contents.temperature, air_contents.volume)
	for(var/atom/A in loc)
		A.fire_act(air_contents, air_contents.temperature, air_contents.volume)

	//spread
	for(var/direction in GLOB.cardinal)
		var/turf/simulated/enemy_tile = get_step(my_tile, direction)

		if(istype(enemy_tile))
			if(my_tile.open_directions & direction) //Grab all valid bordering tiles
				if(!enemy_tile.zone || enemy_tile.fire)
					continue

				//if(!enemy_tile.zone.fire_tiles.len) TODO - optimize
				var/datum/gas_mixture/acs = enemy_tile.return_air()
				var/obj/effect/decal/cleanable/liquid_fuel/liquid = locate() in enemy_tile
				if(!acs || !acs.check_combustability(liquid))
					continue

				//If extinguisher mist passed over the turf it's trying to spread to, don't spread and
				//reduce firelevel.
				if(enemy_tile.fire_protection > world.time-30)
					firelevel -= 1.5
					continue

				//Spread the fire.
				if(prob( 50 + 50 * (firelevel/vsc.fire_firelevel_multiplier) ) && my_tile.CanPass(null, enemy_tile, 0,0) && enemy_tile.CanPass(null, my_tile, 0,0))
					enemy_tile.create_fire(firelevel)

			else
				enemy_tile.adjacent_fire_act(loc, air_contents, air_contents.temperature, air_contents.volume)

	animate(src, color = fire_color(air_contents.temperature), 5)
	set_light(l_color = color)

/obj/fire/New(newLoc,fl)
	..()

	if(!istype(loc, /turf))
		qdel(src)
		return

	set_dir(pick(GLOB.cardinal))

	var/datum/gas_mixture/air_contents = loc.return_air()
	color = fire_color(air_contents.temperature)
	set_light(0.5, 1, 3, l_color = color)

	firelevel = fl
	SSair.active_hotspots.Add(src)

/obj/fire/proc/fire_color(var/env_temperature)
	var/temperature = max(4000*sqrt(firelevel/vsc.fire_firelevel_multiplier), env_temperature)
	return heat2color(temperature)

/obj/fire/Destroy()
	var/turf/T = loc
	if (istype(T))
		set_light(0)
		T.fire = null
	SSair.active_hotspots.Remove(src)
	. = ..()

/turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again.
/turf/proc/apply_fire_protection()
/turf/simulated/apply_fire_protection()
	fire_protection = world.time

//Returns the firelevel
/datum/gas_mixture/proc/react(zone/zone, force_burn, no_check = 0)
	. = 0
	if((temperature > PHORON_MINIMUM_BURN_TEMPERATURE || force_burn) && (no_check ||check_recombustability(zone? zone.fuel_objs : null)))

		#ifdef FIREDBG
		log_debug("***************** FIREDBG *****************")
		log_debug("Burning [zone? zone.name : "zoneless gas_mixture"]!")
		#endif

		var/gas_fuel = 0
		var/liquid_fuel = 0
		var/total_fuel = 0
		var/total_oxidizers = 0

		//*** Get the fuel and oxidizer amounts
		for(var/g in gas)
			if(gas_data.flags[g] & XGM_GAS_FUEL)
				gas_fuel += gas[g]
			if(gas_data.flags[g] & XGM_GAS_OXIDIZER)
				total_oxidizers += gas[g]
		gas_fuel *= group_multiplier
		total_oxidizers *= group_multiplier

		//Liquid Fuel
		var/fuel_area = 0
		if(zone)
			for(var/obj/effect/decal/cleanable/liquid_fuel/fuel in zone.fuel_objs)
				liquid_fuel += fuel.amount*LIQUIDFUEL_AMOUNT_TO_MOL
				fuel_area++

		total_fuel = gas_fuel + liquid_fuel
		if(total_fuel <= 0.005)
			return 0

		//*** Determine how fast the fire burns

		//get the current thermal energy of the gas mix
		//this must be taken here to prevent the addition or deletion of energy by a changing heat capacity
		var/starting_energy = temperature * heat_capacity()

		//determine how far the reaction can progress
		var/reaction_limit = min(total_oxidizers*(FIRE_REACTION_FUEL_AMOUNT/FIRE_REACTION_OXIDIZER_AMOUNT), total_fuel) //stoichiometric limit

		//vapour fuels are extremely volatile! The reaction progress is a percentage of the total fuel (similar to old zburn).)
		var/gas_firelevel = calculate_firelevel(gas_fuel, total_oxidizers, reaction_limit, volume*group_multiplier) / vsc.fire_firelevel_multiplier
		var/min_burn = 0.30*volume*group_multiplier/CELL_VOLUME //in moles - so that fires with very small gas concentrations burn out fast
		var/gas_reaction_progress = min(max(min_burn, gas_firelevel*gas_fuel)*FIRE_GAS_BURNRATE_MULT, gas_fuel)

		//liquid fuels are not as volatile, and the reaction progress depends on the size of the area that is burning. Limit the burn rate to a certain amount per area.
		var/liquid_firelevel = calculate_firelevel(liquid_fuel, total_oxidizers, reaction_limit, 0) / vsc.fire_firelevel_multiplier
		var/liquid_reaction_progress = min((liquid_firelevel*0.2 + 0.05)*fuel_area*FIRE_LIQUID_BURNRATE_MULT, liquid_fuel)

		var/firelevel = (gas_fuel*gas_firelevel + liquid_fuel*liquid_firelevel)/total_fuel

		var/total_reaction_progress = gas_reaction_progress + liquid_reaction_progress
		var/used_fuel = min(total_reaction_progress, reaction_limit)
		var/used_oxidizers = used_fuel*(FIRE_REACTION_OXIDIZER_AMOUNT/FIRE_REACTION_FUEL_AMOUNT)

		#ifdef FIREDBG
		log_debug("gas_fuel = [gas_fuel], liquid_fuel = [liquid_fuel], total_oxidizers = [total_oxidizers]")
		log_debug("fuel_area = [fuel_area], total_fuel = [total_fuel], reaction_limit = [reaction_limit]")
		log_debug("firelevel -> [firelevel] (gas: [gas_firelevel], liquid: [liquid_firelevel])")
		log_debug("liquid_reaction_progress = [liquid_reaction_progress]")
		log_debug("gas_reaction_progress = [gas_reaction_progress]")
		log_debug("total_reaction_progress = [total_reaction_progress]")
		log_debug("used_fuel = [used_fuel], used_oxidizers = [used_oxidizers]; ")
		#endif

		//if the reaction is progressing too slow then it isn't self-sustaining anymore and burns out
		if(zone) //be less restrictive with canister and tank reactions
			if((!liquid_fuel || used_fuel <= FIRE_LIQUD_MIN_BURNRATE) && (!gas_fuel || used_fuel <= FIRE_GAS_MIN_BURNRATE*zone.contents.len))
				return 0


		//*** Remove fuel and oxidizer, add carbon dioxide and heat

		//remove and add gasses as calculated
		var/used_gas_fuel = min(max(0.25, used_fuel*(gas_reaction_progress/total_reaction_progress)), gas_fuel) //remove in proportion to the relative reaction progress
		var/used_liquid_fuel = min(max(0.25, used_fuel-used_gas_fuel), liquid_fuel)

		//remove_by_flag() and adjust_gas() handle the group_multiplier for us.
		remove_by_flag(XGM_GAS_OXIDIZER, used_oxidizers)
		var/datum/gas_mixture/burned_fuel = remove_by_flag(XGM_GAS_FUEL, used_gas_fuel)
		for(var/g in burned_fuel.gas)
			adjust_gas(gas_data.burn_product[g], burned_fuel.gas[g])

		if(zone)
			zone.remove_liquidfuel(used_liquid_fuel, !check_combustability())

		//calculate the energy produced by the reaction and then set the new temperature of the mix
		temperature = (starting_energy + vsc.fire_fuel_energy_release * (used_gas_fuel + used_liquid_fuel)) / heat_capacity()
		update_values()

		#ifdef FIREDBG
		log_debug("used_gas_fuel = [used_gas_fuel]; used_liquid_fuel = [used_liquid_fuel]; total = [used_fuel]")
		log_debug("new temperature = [temperature]; new pressure = [return_pressure()]")
		#endif

		return firelevel

datum/gas_mixture/proc/check_recombustability(list/fuel_objs)
	. = 0
	for(var/g in gas)
		if(gas_data.flags[g] & XGM_GAS_OXIDIZER && gas[g] >= 0.1)
			. = 1
			break

	if(!.)
		return 0

	if(fuel_objs && fuel_objs.len)
		return 1

	. = 0
	for(var/g in gas)
		if(gas_data.flags[g] & XGM_GAS_FUEL && gas[g] >= 0.1)
			. = 1
			break

/datum/gas_mixture/proc/check_combustability(obj/effect/decal/cleanable/liquid_fuel/liquid=null)
	. = 0
	for(var/g in gas)
		if(gas_data.flags[g] & XGM_GAS_OXIDIZER && QUANTIZE(gas[g] * vsc.fire_consuption_rate) >= 0.1)
			. = 1
			break

	if(!.)
		return 0

	if(liquid)
		return 1

	. = 0
	for(var/g in gas)
		if(gas_data.flags[g] & XGM_GAS_FUEL && QUANTIZE(gas[g] * vsc.fire_consuption_rate) >= 0.1)
			. = 1
			break

//returns a value between 0 and vsc.fire_firelevel_multiplier
/datum/gas_mixture/proc/calculate_firelevel(total_fuel, total_oxidizers, reaction_limit, gas_volume)
	//Calculates the firelevel based on one equation instead of having to do this multiple times in different areas.
	var/firelevel = 0

	var/total_combustables = (total_fuel + total_oxidizers)
	var/active_combustables = (FIRE_REACTION_OXIDIZER_AMOUNT/FIRE_REACTION_FUEL_AMOUNT + 1)*reaction_limit

	if(total_combustables > 0)
		//slows down the burning when the concentration of the reactants is low
		var/damping_multiplier = min(1, active_combustables / (total_moles/group_multiplier))

		//weight the damping mult so that it only really brings down the firelevel when the ratio is closer to 0
		damping_multiplier = 2*damping_multiplier - (damping_multiplier*damping_multiplier)

		//calculates how close the mixture of the reactants is to the optimum
		//fires burn better when there is more oxidizer -- too much fuel will choke the fire out a bit, reducing firelevel.
		var/mix_multiplier = 1 / (1 + (5 * ((total_fuel / total_combustables) ** 2)))

		#ifdef FIREDBG
		ASSERT(damping_multiplier <= 1)
		ASSERT(mix_multiplier <= 1)
		#endif

		//toss everything together -- should produce a value between 0 and fire_firelevel_multiplier
		firelevel = vsc.fire_firelevel_multiplier * mix_multiplier * damping_multiplier

	return max( 0, firelevel)


/mob/living/proc/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	var/mx = 5 * firelevel/vsc.fire_firelevel_multiplier * min(pressure / ONE_ATMOSPHERE, 1)
	apply_damage(2.5*mx, BURN)


/mob/living/carbon/human/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	//Burns mobs due to fire. Respects heat transfer coefficients on various body parts.
	//Due to TG reworking how fireprotection works, this is kinda less meaningful.

	var/head_exposure = 1
	var/chest_exposure = 1
	var/groin_exposure = 1
	var/legs_exposure = 1
	var/arms_exposure = 1

	//Get heat transfer coefficients for clothing.

	for(var/obj/item/clothing/C in src)
		if(l_hand == C || r_hand == C)
			continue

		if( C.max_heat_protection_temperature >= last_temperature )
			if(C.body_parts_covered & HEAD)
				head_exposure = 0
			if(C.body_parts_covered & UPPER_TORSO)
				chest_exposure = 0
			if(C.body_parts_covered & LOWER_TORSO)
				groin_exposure = 0
			if(C.body_parts_covered & LEGS)
				legs_exposure = 0
			if(C.body_parts_covered & ARMS)
				arms_exposure = 0
	//minimize this for low-pressure enviroments
	var/mx = 5 * firelevel/vsc.fire_firelevel_multiplier * min(pressure / ONE_ATMOSPHERE, 1)

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.

	apply_damage(0.9*mx*head_exposure,  BURN, BP_HEAD,  used_weapon =  "Fire")
	apply_damage(2.5*mx*chest_exposure, BURN, BP_CHEST, used_weapon =  "Fire")
	apply_damage(2.0*mx*groin_exposure, BURN, BP_GROIN, used_weapon =  "Fire")
	apply_damage(0.6*mx*legs_exposure,  BURN, BP_L_LEG, used_weapon =  "Fire")
	apply_damage(0.6*mx*legs_exposure,  BURN, BP_R_LEG, used_weapon =  "Fire")
	apply_damage(0.4*mx*arms_exposure,  BURN, BP_L_ARM, used_weapon =  "Fire")
	apply_damage(0.4*mx*arms_exposure,  BURN, BP_R_ARM, used_weapon =  "Fire")

var/image/contamination_overlay = image('icons/effects/contamination.dmi')

/pl_control
	var/PHORON_DMG = 3
	var/PHORON_DMG_NAME = "Phoron Damage Amount"
	var/PHORON_DMG_DESC = "Self Descriptive"

	var/CLOTH_CONTAMINATION = 1
	var/CLOTH_CONTAMINATION_NAME = "Cloth Contamination"
	var/CLOTH_CONTAMINATION_DESC = "If this is on, phoron does damage by getting into cloth."

	var/PHORONGUARD_ONLY = 0
	var/PHORONGUARD_ONLY_NAME = "\"PhoronGuard Only\""
	var/PHORONGUARD_ONLY_DESC = "If this is on, only biosuits and spacesuits protect against contamination and ill effects."

	var/GENETIC_CORRUPTION = 0
	var/GENETIC_CORRUPTION_NAME = "Genetic Corruption Chance"
	var/GENETIC_CORRUPTION_DESC = "Chance of genetic corruption as well as toxic damage, X in 10,000."

	var/SKIN_BURNS = 0
	var/SKIN_BURNS_DESC = "Phoron has an effect similar to mustard gas on the un-suited."
	var/SKIN_BURNS_NAME = "Skin Burns"

	var/EYE_BURNS = 1
	var/EYE_BURNS_NAME = "Eye Burns"
	var/EYE_BURNS_DESC = "Phoron burns the eyes of anyone not wearing eye protection."

	var/CONTAMINATION_LOSS = 0.02
	var/CONTAMINATION_LOSS_NAME = "Contamination Loss"
	var/CONTAMINATION_LOSS_DESC = "How much toxin damage is dealt from contaminated clothing" //Per tick?  ASK ARYN

	var/PHORON_HALLUCINATION = 0
	var/PHORON_HALLUCINATION_NAME = "Phoron Hallucination"
	var/PHORON_HALLUCINATION_DESC = "Does being in phoron cause you to hallucinate?"

	var/N2O_HALLUCINATION = 1
	var/N2O_HALLUCINATION_NAME = "N2O Hallucination"
	var/N2O_HALLUCINATION_DESC = "Does being in sleeping gas cause you to hallucinate?"


obj/var/contaminated = 0


/obj/item/proc/can_contaminate()
	//Clothing and backpacks can be contaminated.
	if(obj_flags & ITEM_FLAG_PHORONGUARD) return 0
	else if(istype(src,/obj/item/weapon/storage/backpack)) return 0 //Cannot be washed :(
	else if(istype(src,/obj/item/clothing)) return 1

/obj/item/proc/contaminate()
	//Do a contamination overlay? Temporary measure to keep contamination less deadly than it was.
	if(!contaminated)
		contaminated = 1
		overlays += contamination_overlay

/obj/item/proc/decontaminate()
	contaminated = 0
	overlays -= contamination_overlay

/mob/proc/contaminate()

/mob/living/carbon/human/contaminate()
	//See if anything can be contaminated.

	if(!pl_suit_protected())
		suit_contamination()

	if(!pl_head_protected())
		if(prob(1)) suit_contamination() //Phoron can sometimes get through such an open suit.

//Cannot wash backpacks currently.
//	if(istype(back,/obj/item/weapon/storage/backpack))
//		back.contaminate()

/mob/proc/pl_effects()

/mob/living/carbon/human/pl_effects()
	//Handles all the bad things phoron can do.

	//Contamination
	if(vsc.plc.CLOTH_CONTAMINATION) contaminate()

	//Anything else requires them to not be dead.
	if(stat >= 2)
		return

	//Burn skin if exposed.
	if(vsc.plc.SKIN_BURNS)
		if(!pl_head_protected() || !pl_suit_protected())
			burn_skin(0.75)
			if(prob(20)) to_chat(src, "<span class='danger'>Your skin burns!</span>")
			updatehealth()

	//Burn eyes if exposed.
	if(vsc.plc.EYE_BURNS)
		if(!head)
			if(!wear_mask)
				burn_eyes()
			else
				if(!(wear_mask.body_parts_covered & EYES))
					burn_eyes()
		else
			if(!(head.body_parts_covered & EYES))
				if(!wear_mask)
					burn_eyes()
				else
					if(!(wear_mask.body_parts_covered & EYES))
						burn_eyes()

	//Genetic Corruption
	if(vsc.plc.GENETIC_CORRUPTION)
		if(rand(1,10000) < vsc.plc.GENETIC_CORRUPTION)
			randmutb(src)
			to_chat(src, "<span class='danger'>High levels of toxins cause you to spontaneously mutate!</span>")
			domutcheck(src,null)


/mob/living/carbon/human/proc/burn_eyes()
	var/obj/item/organ/internal/eyes/E = internal_organs_by_name[BP_EYES]
	if(E && !E.phoron_guard)
		if(prob(20)) to_chat(src, "<span class='danger'>Your eyes burn!</span>")
		E.damage += 2.5
		eye_blurry = min(eye_blurry+1.5,50)
		if (prob(max(0,E.damage - 15) + 1) &&!eye_blind)
			to_chat(src, "<span class='danger'>You are blinded!</span>")
			eye_blind += 20

/mob/living/carbon/human/proc/pl_head_protected()
	//Checks if the head is adequately sealed.
	if(head)
		if(vsc.plc.PHORONGUARD_ONLY)
			if(head.item_flags & ITEM_FLAG_PHORONGUARD)
				return 1
		else if(head.body_parts_covered & EYES)
			return 1
	return 0

/mob/living/carbon/human/proc/pl_suit_protected()
	//Checks if the suit is adequately sealed.
	var/coverage = 0
	for(var/obj/item/protection in list(wear_suit, gloves, shoes))
		if(!protection)
			continue
		if(vsc.plc.PHORONGUARD_ONLY && !(protection.item_flags & ITEM_FLAG_PHORONGUARD))
			return 0
		coverage |= protection.body_parts_covered

	if(vsc.plc.PHORONGUARD_ONLY)
		return 1

	return BIT_TEST_ALL(coverage, UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS)

/mob/living/carbon/human/proc/suit_contamination()
	//Runs over the things that can be contaminated and does so.
	if(w_uniform) w_uniform.contaminate()
	if(shoes) shoes.contaminate()
	if(gloves) gloves.contaminate()


turf/Entered(obj/item/I)
	. = ..()
	//Items that are in phoron, but not on a mob, can still be contaminated.
	if(istype(I) && vsc && vsc.plc.CLOTH_CONTAMINATION && I.can_contaminate())
		var/datum/gas_mixture/env = return_air(1)
		if(!env)
			return
		for(var/g in env.gas)
			if(gas_data.flags[g] & XGM_GAS_CONTAMINANT && env.gas[g] > gas_data.overlay_limit[g] + 1)
				I.contaminate()
				break

/turf/simulated/var/zone/zone
/turf/simulated/var/open_directions

/turf/var/needs_air_update = 0
/turf/var/datum/gas_mixture/air

/turf/simulated/proc/update_graphic(list/graphic_add = null, list/graphic_remove = null)
	if(graphic_add && graphic_add.len)
		vis_contents += graphic_add
	if(graphic_remove && graphic_remove.len)
		vis_contents -= graphic_remove

/turf/proc/update_air_properties()
	var/block = c_airblock(src)
	if(block & AIR_BLOCKED)
		//dbg(blocked)
		return 1

	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim)
			continue

		block = unsim.c_airblock(src)

		if(block & AIR_BLOCKED)
			//unsim.dbg(air_blocked, turn(180,d))
			continue

		var/r_block = c_airblock(unsim)

		if(r_block & AIR_BLOCKED)
			continue

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(TURF_HAS_VALID_ZONE(sim))
				SSair.connect(sim, src)

/*
	Simple heuristic for determining if removing the turf from it's zone will not partition the zone (A very bad thing).
	Instead of analyzing the entire zone, we only check the nearest 3x3 turfs surrounding the src turf.
	This implementation may produce false negatives but it (hopefully) will not produce any false postiives.
*/

/turf/simulated/proc/can_safely_remove_from_zone()
	if(!zone) return 1

	var/check_dirs = get_zone_neighbours(src)
	var/unconnected_dirs = check_dirs

	#ifdef MULTIZAS
	var/to_check = GLOB.cornerdirsz
	#else
	var/to_check = GLOB.cornerdirs
	#endif

	for(var/dir in to_check)

		//for each pair of "adjacent" cardinals (e.g. NORTH and WEST, but not NORTH and SOUTH)
		if((dir & check_dirs) == dir)
			//check that they are connected by the corner turf
			var/connected_dirs = get_zone_neighbours(get_step(src, dir))
			if(connected_dirs && (dir & GLOB.reverse_dir[connected_dirs]) == dir)
				unconnected_dirs &= ~dir //they are, so unflag the cardinals in question

	//it is safe to remove src from the zone if all cardinals are connected by corner turfs
	return !unconnected_dirs

//helper for can_safely_remove_from_zone()
/turf/simulated/proc/get_zone_neighbours(turf/simulated/T)
	. = 0
	if(istype(T) && T.zone)
		#ifdef MULTIZAS
		var/to_check = GLOB.cardinalz
		#else
		var/to_check = GLOB.cardinal
		#endif
		for(var/dir in to_check)
			var/turf/simulated/other = get_step(T, dir)
			if(istype(other) && other.zone == T.zone && !(other.c_airblock(T) & AIR_BLOCKED) && get_dist(src, other) <= 1)
				. |= dir

/turf/simulated/update_air_properties()

	if(zone && zone.invalid) //this turf's zone is in the process of being rebuilt
		c_copy_air() //not very efficient :(
		zone = null //Easier than iterating through the list at the zone.

	var/s_block = c_airblock(src)
	if(s_block & AIR_BLOCKED)
		#ifdef ZASDBG
		if(verbose) log_debug("Self-blocked.")
		//dbg(blocked)
		#endif
		if(zone)
			var/zone/z = zone

			if(can_safely_remove_from_zone()) //Helps normal airlocks avoid rebuilding zones all the time
				c_copy_air() //we aren't rebuilding, but hold onto the old air so it can be readded
				z.remove(src)
			else
				z.rebuild()

		return 1

	var/previously_open = open_directions
	open_directions = 0

	var/list/postponed
	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim) //edge of map
			continue

		var/block = unsim.c_airblock(src)
		if(block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) log_debug("[d] is blocked.")
			//unsim.dbg(air_blocked, turn(180,d))
			#endif

			continue

		var/r_block = c_airblock(unsim)
		if(r_block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) log_debug("[d] is blocked.")
			//dbg(air_blocked, d)
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			if((previously_open & d) && istype(unsim, /turf/simulated))
				var/turf/simulated/sim = unsim
				if(zone && sim.zone == zone)
					zone.rebuild()
					return

			continue

		open_directions |= d

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			sim.open_directions |= GLOB.reverse_dir[d]

			if(TURF_HAS_VALID_ZONE(sim))

				//Might have assigned a zone, since this happens for each direction.
				if(!zone)

					//We do not merge if
					//    they are blocking us and we are not blocking them, or if
					//    we are blocking them and not blocking ourselves - this prevents tiny zones from forming on doorways.
					if(((block & ZONE_BLOCKED) && !(r_block & ZONE_BLOCKED)) || ((r_block & ZONE_BLOCKED) && !(s_block & ZONE_BLOCKED)))
						#ifdef ZASDBG
						if(verbose) log_debug("[d] is zone blocked.")

						//dbg(zone_blocked, d)
						#endif

						//Postpone this tile rather than exit, since a connection can still be made.
						if(!postponed) postponed = list()
						postponed.Add(sim)

					else

						sim.zone.add(src)

						#ifdef ZASDBG
						dbg(assigned)
						if(verbose) log_debug("Added to [zone]")
						#endif

				else if(sim.zone != zone)

					#ifdef ZASDBG
					if(verbose) log_debug("Connecting to [sim.zone]")
					#endif

					SSair.connect(src, sim)


			#ifdef ZASDBG
				else if(verbose) log_debug("[d] has same zone.")

			else if(verbose) log_debug("[d] has invalid zone.")
			#endif

		else

			//Postponing connections to tiles until a zone is assured.
			if(!postponed) postponed = list()
			postponed.Add(unsim)

	if(!TURF_HAS_VALID_ZONE(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(created)

	ASSERT(zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		SSair.connect(src, T)

/turf/proc/post_update_air_properties()
	if(connections) connections.update_all()

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	return 0

/turf/proc/assume_gas(gasid, moles, temp = 0)
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	if(initial_gas)
		GM.gas = initial_gas.Copy()
	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/remove_air(amount as num)
	var/datum/gas_mixture/GM = return_air()
	return GM.remove(amount)

/turf/simulated/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/my_air = return_air()
	my_air.merge(giver)

/turf/simulated/assume_gas(gasid, moles, temp = null)
	var/datum/gas_mixture/my_air = return_air()

	if(isnull(temp))
		my_air.adjust_gas(gasid, moles)
	else
		my_air.adjust_gas_temp(gasid, moles, temp)

	return 1

/turf/simulated/return_air()
	if(zone)
		if(!zone.invalid)
			SSair.mark_zone_update(zone)
			return zone.air
		else
			if(!air)
				make_air()
			c_copy_air()
			return air
	else
		if(!air)
			make_air()
		return air

/turf/proc/make_air()
	air = new/datum/gas_mixture
	air.temperature = temperature
	if(initial_gas)
		air.gas = initial_gas.Copy()
	air.update_values()

/turf/simulated/proc/c_copy_air()
	if(!air) air = new/datum/gas_mixture
	air.copy_from(zone.air)
	air.group_multiplier = 1

var/global/vs_control/vsc = new

/vs_control
	var/fire_consuption_rate = 0.25
	var/fire_consuption_rate_NAME = "Fire - Air Consumption Ratio"
	var/fire_consuption_rate_DESC = "Ratio of air removed and combusted per tick."

	var/fire_firelevel_multiplier = 25
	var/fire_firelevel_multiplier_NAME = "Fire - Firelevel Constant"
	var/fire_firelevel_multiplier_DESC = "Multiplied by the equation for firelevel, affects mainly the extingiushing of fires."

	//Note that this parameter and the phoron heat capacity have a significant impact on TTV yield.
	var/fire_fuel_energy_release = 866000 //J/mol. Adjusted to compensate for fire energy release being fixed, was 397000
	var/fire_fuel_energy_release_NAME = "Fire - Fuel energy release"
	var/fire_fuel_energy_release_DESC = "The energy in joule released when burning one mol of a burnable substance"


	var/IgnitionLevel = 0.5
	var/IgnitionLevel_DESC = "Determines point at which fire can ignite"

	var/airflow_lightest_pressure = 20
	var/airflow_lightest_pressure_NAME = "Airflow - Small Movement Threshold %"
	var/airflow_lightest_pressure_DESC = "Percent of 1 Atm. at which items with the small weight classes will move."

	var/airflow_light_pressure = 35
	var/airflow_light_pressure_NAME = "Airflow - Medium Movement Threshold %"
	var/airflow_light_pressure_DESC = "Percent of 1 Atm. at which items with the medium weight classes will move."

	var/airflow_medium_pressure = 50
	var/airflow_medium_pressure_NAME = "Airflow - Heavy Movement Threshold %"
	var/airflow_medium_pressure_DESC = "Percent of 1 Atm. at which items with the largest weight classes will move."

	var/airflow_heavy_pressure = 65
	var/airflow_heavy_pressure_NAME = "Airflow - Mob Movement Threshold %"
	var/airflow_heavy_pressure_DESC = "Percent of 1 Atm. at which mobs will move."

	var/airflow_dense_pressure = 85
	var/airflow_dense_pressure_NAME = "Airflow - Dense Movement Threshold %"
	var/airflow_dense_pressure_DESC = "Percent of 1 Atm. at which items with canisters and closets will move."

	var/airflow_stun_pressure = 60
	var/airflow_stun_pressure_NAME = "Airflow - Mob Stunning Threshold %"
	var/airflow_stun_pressure_DESC = "Percent of 1 Atm. at which mobs will be stunned by airflow."

	var/airflow_stun_cooldown = 60
	var/airflow_stun_cooldown_NAME = "Aiflow Stunning - Cooldown"
	var/airflow_stun_cooldown_DESC = "How long, in tenths of a second, to wait before stunning them again."

	var/airflow_stun = 1
	var/airflow_stun_NAME = "Airflow Impact - Stunning"
	var/airflow_stun_DESC = "How much a mob is stunned when hit by an object."

	var/airflow_damage = 3
	var/airflow_damage_NAME = "Airflow Impact - Damage"
	var/airflow_damage_DESC = "Damage from airflow impacts."

	var/airflow_speed_decay = 1.5
	var/airflow_speed_decay_NAME = "Airflow Speed Decay"
	var/airflow_speed_decay_DESC = "How rapidly the speed gained from airflow decays."

	var/airflow_delay = 30
	var/airflow_delay_NAME = "Airflow Retrigger Delay"
	var/airflow_delay_DESC = "Time in deciseconds before things can be moved by airflow again."

	var/airflow_mob_slowdown = 1
	var/airflow_mob_slowdown_NAME = "Airflow Slowdown"
	var/airflow_mob_slowdown_DESC = "Time in tenths of a second to add as a delay to each movement by a mob if they are fighting the pull of the airflow."

	var/connection_insulation = 1
	var/connection_insulation_NAME = "Connections - Insulation"
	var/connection_insulation_DESC = "Boolean, should doors forbid heat transfer?"

	var/connection_temperature_delta = 10
	var/connection_temperature_delta_NAME = "Connections - Temperature Difference"
	var/connection_temperature_delta_DESC = "The smallest temperature difference which will cause heat to travel through doors."


/vs_control/var/list/settings = list()
/vs_control/var/list/bitflags = list("1","2","4","8","16","32","64","128","256","512","1024")
/vs_control/var/pl_control/plc = new()

/vs_control/New()
	. = ..()
	settings = vars.Copy()

	var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
	for(var/V in D.vars)
		settings -= V

	for(var/V in settings)
		if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC") || findtextEx(V,"_METHOD"))
			settings -= V

	settings -= "settings"
	settings -= "bitflags"
	settings -= "plc"

/vs_control/proc/ChangeSettingsDialog(mob/user,list/L)
	//var/which = input(user,"Choose a setting:") in L
	var/dat = ""
	for(var/ch in L)
		if(findtextEx(ch,"_RANDOM") || findtextEx(ch,"_DESC") || findtextEx(ch,"_METHOD") || findtextEx(ch,"_NAME")) continue
		var/vw
		var/vw_desc = "No Description."
		var/vw_name = ch
		if(ch in plc.settings)
			vw = plc.vars[ch]
			if("[ch]_DESC" in plc.vars) vw_desc = plc.vars["[ch]_DESC"]
			if("[ch]_NAME" in plc.vars) vw_name = plc.vars["[ch]_NAME"]
		else
			vw = vars[ch]
			if("[ch]_DESC" in vars) vw_desc = vars["[ch]_DESC"]
			if("[ch]_NAME" in vars) vw_name = vars["[ch]_NAME"]
		dat += "<b>[vw_name] = [vw]</b> <A href='?src=\ref[src];changevar=[ch]'>\[Change\]</A><br>"
		dat += "<i>[vw_desc]</i><br><br>"
	user << browse(dat,"window=settings")

/vs_control/Topic(href,href_list)
	if("changevar" in href_list)
		ChangeSetting(usr,href_list["changevar"])

/vs_control/proc/ChangeSetting(mob/user,ch)
	var/vw
	var/how = "Text"
	var/display_description = ch
	if(ch in plc.settings)
		vw = plc.vars[ch]
		if("[ch]_NAME" in plc.vars)
			display_description = plc.vars["[ch]_NAME"]
		if("[ch]_METHOD" in plc.vars)
			how = plc.vars["[ch]_METHOD"]
		else
			if(isnum(vw))
				how = "Numeric"
			else
				how = "Text"
	else
		vw = vars[ch]
		if("[ch]_NAME" in vars)
			display_description = vars["[ch]_NAME"]
		if("[ch]_METHOD" in vars)
			how = vars["[ch]_METHOD"]
		else
			if(isnum(vw))
				how = "Numeric"
			else
				how = "Text"
	var/newvar = vw
	switch(how)
		if("Numeric")
			newvar = input(user,"Enter a number:","Settings",newvar) as num
		if("Bit Flag")
			var/flag = input(user,"Toggle which bit?","Settings") in bitflags
			flag = text2num(flag)
			if(newvar & flag)
				newvar &= ~flag
			else
				newvar |= flag
		if("Toggle")
			newvar = !newvar
		if("Text")
			newvar = input(user,"Enter a string:","Settings",newvar) as text
		if("Long Text")
			newvar = input(user,"Enter text:","Settings",newvar) as message
	vw = newvar
	if(ch in plc.settings)
		plc.vars[ch] = vw
	else
		vars[ch] = vw
	if(how == "Toggle")
		newvar = (newvar?"ON":"OFF")
	to_world("<span class='notice'><b>[key_name(user)] changed the setting [display_description] to [newvar].</b></span>")
	if(ch in plc.settings)
		ChangeSettingsDialog(user,plc.settings)
	else
		ChangeSettingsDialog(user,settings)

/vs_control/proc/RandomizeWithProbability()
	for(var/V in settings)
		var/newvalue
		if("[V]_RANDOM" in vars)
			if(isnum(vars["[V]_RANDOM"]))
				newvalue = prob(vars["[V]_RANDOM"])
			else if(istext(vars["[V]_RANDOM"]))
				newvalue = roll(vars["[V]_RANDOM"])
			else
				newvalue = vars[V]
		V = newvalue

/vs_control/proc/ChangePhoron()
	for(var/V in plc.settings)
		plc.Randomize(V)

/vs_control/proc/SetDefault(var/mob/user)
	var/list/setting_choices = list("Phoron - Standard", "Phoron - Low Hazard", "Phoron - High Hazard", "Phoron - Oh Shit!",\
	"ZAS - Normal", "ZAS - Forgiving", "ZAS - Dangerous", "ZAS - Hellish", "ZAS/Phoron - Initial")
	var/def = input(user, "Which of these presets should be used?") as null|anything in setting_choices
	if(!def)
		return
	switch(def)
		if("Phoron - Standard")
			plc.CLOTH_CONTAMINATION = 1 //If this is on, phoron does damage by getting into cloth.
			plc.PHORONGUARD_ONLY = 0
			plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.
			plc.SKIN_BURNS = 0       //Phoron has an effect similar to mustard gas on the un-suited.
			plc.EYE_BURNS = 1 //Phoron burns the eyes of anyone not wearing eye protection.
			plc.PHORON_HALLUCINATION = 0
			plc.CONTAMINATION_LOSS = 0.02

		if("Phoron - Low Hazard")
			plc.CLOTH_CONTAMINATION = 0 //If this is on, phoron does damage by getting into cloth.
			plc.PHORONGUARD_ONLY = 0
			plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000
			plc.SKIN_BURNS = 0       //Phoron has an effect similar to mustard gas on the un-suited.
			plc.EYE_BURNS = 1 //Phoron burns the eyes of anyone not wearing eye protection.
			plc.PHORON_HALLUCINATION = 0
			plc.CONTAMINATION_LOSS = 0.01

		if("Phoron - High Hazard")
			plc.CLOTH_CONTAMINATION = 1 //If this is on, phoron does damage by getting into cloth.
			plc.PHORONGUARD_ONLY = 0
			plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.
			plc.SKIN_BURNS = 1       //Phoron has an effect similar to mustard gas on the un-suited.
			plc.EYE_BURNS = 1 //Phoron burns the eyes of anyone not wearing eye protection.
			plc.PHORON_HALLUCINATION = 1
			plc.CONTAMINATION_LOSS = 0.05

		if("Phoron - Oh Shit!")
			plc.CLOTH_CONTAMINATION = 1 //If this is on, phoron does damage by getting into cloth.
			plc.PHORONGUARD_ONLY = 1
			plc.GENETIC_CORRUPTION = 5 //Chance of genetic corruption as well as toxic damage, X in 1000.
			plc.SKIN_BURNS = 1       //Phoron has an effect similar to mustard gas on the un-suited.
			plc.EYE_BURNS = 1 //Phoron burns the eyes of anyone not wearing eye protection.
			plc.PHORON_HALLUCINATION = 1
			plc.CONTAMINATION_LOSS = 0.075

		if("ZAS - Normal")
			airflow_lightest_pressure = 20
			airflow_light_pressure = 35
			airflow_medium_pressure = 50
			airflow_heavy_pressure = 65
			airflow_dense_pressure = 85
			airflow_stun_pressure = 60
			airflow_stun_cooldown = 60
			airflow_stun = 1
			airflow_damage = 3
			airflow_speed_decay = 1.5
			airflow_delay = 30
			airflow_mob_slowdown = 1

		if("ZAS - Forgiving")
			airflow_lightest_pressure = 45
			airflow_light_pressure = 60
			airflow_medium_pressure = 120
			airflow_heavy_pressure = 110
			airflow_dense_pressure = 200
			airflow_stun_pressure = 150
			airflow_stun_cooldown = 90
			airflow_stun = 0.15
			airflow_damage = 0.5
			airflow_speed_decay = 1.5
			airflow_delay = 50
			airflow_mob_slowdown = 0

		if("ZAS - Dangerous")
			airflow_lightest_pressure = 15
			airflow_light_pressure = 30
			airflow_medium_pressure = 45
			airflow_heavy_pressure = 55
			airflow_dense_pressure = 70
			airflow_stun_pressure = 50
			airflow_stun_cooldown = 50
			airflow_stun = 2
			airflow_damage = 4
			airflow_speed_decay = 1.2
			airflow_delay = 25
			airflow_mob_slowdown = 2

		if("ZAS - Hellish")
			airflow_lightest_pressure = 20
			airflow_light_pressure = 30
			airflow_medium_pressure = 40
			airflow_heavy_pressure = 50
			airflow_dense_pressure = 60
			airflow_stun_pressure = 40
			airflow_stun_cooldown = 40
			airflow_stun = 3
			airflow_damage = 5
			airflow_speed_decay = 1
			airflow_delay = 20
			airflow_mob_slowdown = 3
			connection_insulation = 0

		if("ZAS/Phoron - Initial")
			fire_consuption_rate 			= initial(fire_consuption_rate)
			fire_firelevel_multiplier 		= initial(fire_firelevel_multiplier)
			fire_fuel_energy_release 		= initial(fire_fuel_energy_release)
			IgnitionLevel 					= initial(IgnitionLevel)
			airflow_lightest_pressure 		= initial(airflow_lightest_pressure)
			airflow_light_pressure 			= initial(airflow_light_pressure)
			airflow_medium_pressure 		= initial(airflow_medium_pressure)
			airflow_heavy_pressure 			= initial(airflow_heavy_pressure)
			airflow_dense_pressure 			= initial(airflow_dense_pressure)
			airflow_stun_pressure 			= initial(airflow_stun_pressure)
			airflow_stun_cooldown 			= initial(airflow_stun_cooldown)
			airflow_stun 					= initial(airflow_stun)
			airflow_damage 					= initial(airflow_damage)
			airflow_speed_decay 			= initial(airflow_speed_decay)
			airflow_delay 					= initial(airflow_delay)
			airflow_mob_slowdown 			= initial(airflow_mob_slowdown)
			connection_insulation 			= initial(connection_insulation)
			connection_temperature_delta 	= initial(connection_temperature_delta)

			plc.PHORON_DMG 					= initial(plc.PHORON_DMG)
			plc.CLOTH_CONTAMINATION 		= initial(plc.CLOTH_CONTAMINATION)
			plc.PHORONGUARD_ONLY 			= initial(plc.PHORONGUARD_ONLY)
			plc.GENETIC_CORRUPTION 			= initial(plc.GENETIC_CORRUPTION)
			plc.SKIN_BURNS 					= initial(plc.SKIN_BURNS)
			plc.EYE_BURNS 					= initial(plc.EYE_BURNS)
			plc.CONTAMINATION_LOSS 			= initial(plc.CONTAMINATION_LOSS)
			plc.PHORON_HALLUCINATION 		= initial(plc.PHORON_HALLUCINATION)
			plc.N2O_HALLUCINATION 			= initial(plc.N2O_HALLUCINATION)


	to_world("<span class='notice'><b>[key_name(user)] changed the global phoron/ZAS settings to \"[def]\"</b></span>")

/pl_control/var/list/settings = list()

/pl_control/New()
	. = ..()
	settings = vars.Copy()

	var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
	for(var/V in D.vars)
		settings -= V

	for(var/V in settings)
		if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC"))
			settings -= V

	settings -= "settings"

/pl_control/proc/Randomize(V)
	var/newvalue
	if("[V]_RANDOM" in vars)
		if(isnum(vars["[V]_RANDOM"]))
			newvalue = prob(vars["[V]_RANDOM"])
		else if(istext(vars["[V]_RANDOM"]))
			var/txt = vars["[V]_RANDOM"]
			if(findtextEx(txt,"PROB"))
				txt = splittext(txt,"/")
				txt[1] = replacetext(txt[1],"PROB","")
				var/p = text2num(txt[1])
				var/r = txt[2]
				if(prob(p))
					newvalue = roll(r)
				else
					newvalue = vars[V]
			else if(findtextEx(txt,"PICK"))
				txt = replacetext(txt,"PICK","")
				txt = splittext(txt,",")
				newvalue = pick(txt)
			else
				newvalue = roll(txt)
		else
			newvalue = vars[V]
		vars[V] = newvalue

/*

Overview:
	Each zone is a self-contained area where gas values would be the same if tile-based equalization were run indefinitely.
	If you're unfamiliar with ZAS, FEA's air groups would have similar functionality if they didn't break in a stiff breeze.

Class Vars:
	name - A name of the format "Zone [#]", used for debugging.
	invalid - True if the zone has been erased and is no longer eligible for processing.
	needs_update - True if the zone has been added to the update list.
	edges - A list of edges that connect to this zone.
	air - The gas mixture that any turfs in this zone will return. Values are per-tile with a group multiplier.

Class Procs:
	add(turf/simulated/T)
		Adds a turf to the contents, sets its zone and merges its air.

	remove(turf/simulated/T)
		Removes a turf, sets its zone to null and erases any gas graphics.
		Invalidates the zone if it has no more tiles.

	c_merge(zone/into)
		Invalidates this zone and adds all its former contents to into.

	c_invalidate()
		Marks this zone as invalid and removes it from processing.

	rebuild()
		Invalidates the zone and marks all its former tiles for updates.

	add_tile_air(turf/simulated/T)
		Adds the air contained in T.air to the zone's air supply. Called when adding a turf.

	tick()
		Called only when the gas content is changed. Archives values and changes gas graphics.

	dbg_data(mob/M)
		Sends M a printout of important figures for the zone.

*/


/zone
	var/name
	var/invalid = 0
	var/list/contents = list()
	var/list/fire_tiles = list()
	var/list/fuel_objs = list()
	var/needs_update = 0
	var/list/edges = list()
	var/datum/gas_mixture/air = new
	var/list/graphic_add = list()
	var/list/graphic_remove = list()
	var/last_air_temperature = TCMB

/zone/New()
	SSair.add_zone(src)
	air.temperature = TCMB
	air.group_multiplier = 1
	air.volume = CELL_VOLUME

/zone/proc/add(turf/simulated/T)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(T))
	ASSERT(!SSair.has_valid_zone(T))
#endif

	var/datum/gas_mixture/turf_air = T.return_air()
	add_tile_air(turf_air)
	T.zone = src
	contents.Add(T)
	if(T.fire)
		var/obj/effect/decal/cleanable/liquid_fuel/fuel = locate() in T
		fire_tiles.Add(T)
		SSair.active_fire_zones |= src
		if(fuel) fuel_objs += fuel
	T.update_graphic(air.graphic)

/zone/proc/remove(turf/simulated/T)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(T))
	ASSERT(T.zone == src)
	soft_assert(T in contents, "Lists are weird broseph")
#endif
	contents.Remove(T)
	fire_tiles.Remove(T)
	if(T.fire)
		var/obj/effect/decal/cleanable/liquid_fuel/fuel = locate() in T
		fuel_objs -= fuel
	T.zone = null
	T.update_graphic(graphic_remove = air.graphic)
	if(contents.len)
		air.group_multiplier = contents.len
	else
		c_invalidate()

/zone/proc/c_merge(zone/into)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(into))
	ASSERT(into != src)
	ASSERT(!into.invalid)
#endif
	c_invalidate()
	for(var/turf/simulated/T in contents)
		into.add(T)
		T.update_graphic(graphic_remove = air.graphic)
		#ifdef ZASDBG
		T.dbg(merged)
		#endif

	//rebuild the old zone's edges so that they will be possessed by the new zone
	for(var/connection_edge/E in edges)
		if(E.contains_zone(into))
			continue //don't need to rebuild this edge
		for(var/turf/T in E.connecting_turfs)
			SSair.mark_for_update(T)

/zone/proc/c_invalidate()
	invalid = 1
	SSair.remove_zone(src)
	#ifdef ZASDBG
	for(var/turf/simulated/T in contents)
		T.dbg(invalid_zone)
	#endif

/zone/proc/rebuild()
	if(invalid) return //Short circuit for explosions where rebuild is called many times over.
	c_invalidate()
	for(var/turf/simulated/T in contents)
		T.update_graphic(graphic_remove = air.graphic) //we need to remove the overlays so they're not doubled when the zone is rebuilt
		//T.dbg(invalid_zone)
		T.needs_air_update = 0 //Reset the marker so that it will be added to the list.
		SSair.mark_for_update(T)

/zone/proc/add_tile_air(datum/gas_mixture/tile_air)
	//air.volume += CELL_VOLUME
	air.group_multiplier = 1
	air.multiply(contents.len)
	air.merge(tile_air)
	air.divide(contents.len+1)
	air.group_multiplier = contents.len+1

/zone/proc/tick()

	// Update fires.
	if(air.temperature >= PHORON_FLASHPOINT && !(src in SSair.active_fire_zones) && air.check_combustability() && contents.len)
		var/turf/T = pick(contents)
		if(istype(T))
			T.create_fire(vsc.fire_firelevel_multiplier)

	// Update gas overlays.
	if(air.check_tile_graphic(graphic_add, graphic_remove))
		for(var/turf/simulated/T in contents)
			T.update_graphic(graphic_add, graphic_remove)
		graphic_add.len = 0
		graphic_remove.len = 0

	// Update connected edges.
	for(var/connection_edge/E in edges)
		if(E.sleeping)
			E.recheck()

	// Handle condensation from the air.
	for(var/g in air.gas)
		var/product = gas_data.condensation_products[g]
		if(product && air.temperature <= gas_data.condensation_points[g])
			var/condensation_area = air.group_multiplier
			while(condensation_area > 0)
				condensation_area--
				var/turf/flooding = pick(contents)
				var/condense_amt = min(air.gas[g], rand(3,5))
				if(condense_amt < 1)
					break
				air.adjust_gas(g, -condense_amt)
				flooding.add_fluid(condense_amt, product)

	// Update atom temperature.
	if(abs(air.temperature - last_air_temperature) >= ATOM_TEMPERATURE_EQUILIBRIUM_THRESHOLD)
		last_air_temperature = air.temperature
		for(var/turf/simulated/T in contents)
			for(var/check_atom in T.contents)
				var/atom/checking = check_atom
				if(checking.simulated)
					QUEUE_TEMPERATURE_ATOMS(checking)
			CHECK_TICK

/zone/proc/dbg_data(mob/M)
	to_chat(M, name)
	for(var/g in air.gas)
		to_chat(M, "[gas_data.name[g]]: [air.gas[g]]")
	to_chat(M, "P: [air.return_pressure()] kPa V: [air.volume]L T: [air.temperature]В°K ([air.temperature - T0C]В°C)")
	to_chat(M, "O2 per N2: [(air.gas["nitrogen"] ? air.gas["oxygen"]/air.gas["nitrogen"] : "N/A")] Moles: [air.total_moles]")
	to_chat(M, "Simulated: [contents.len] ([air.group_multiplier])")
//	to_chat(M, "Unsimulated: [unsimulated_contents.len]")
//	to_chat(M, "Edges: [edges.len]")
	if(invalid) to_chat(M, "Invalid!")
	var/zone_edges = 0
	var/space_edges = 0
	var/space_coefficient = 0
	for(var/connection_edge/E in edges)
		if(E.type == /connection_edge/zone) zone_edges++
		else
			space_edges++
			space_coefficient += E.coefficient
			to_chat(M, "[E:air:return_pressure()]kPa")

	to_chat(M, "Zone Edges: [zone_edges]")
	to_chat(M, "Space Edges: [space_edges] ([space_coefficient] connections)")

	//for(var/turf/T in unsimulated_contents)
//		to_chat(M, "[T] at ([T.x],[T.y])")
