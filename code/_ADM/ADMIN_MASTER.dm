/////////////////////////////////////////////////////////////
//
// Загружает администрацию из базы в память.
//
/////////////////////////////////////////////////////////////

/world/proc/load_admins()
	var/DBQuery/my_query = dbcon.NewQuery("SELECT * FROM `admins`")
	if(my_query.Execute())
		while(my_query.NextRow())
			var/list/row  = my_query.GetRowData()
			var/rank = world.convert_ranks(text2num(row["rank"]))
			check_diary()
			to_log ("ADMINL: [row["ckey"]] = [rank]")
			admins[row["ckey"]] = rank
	if (!admins)
		check_diary()
		to_log ("Failed to load admins \n")

/////////////////////////////////////////////////////////////
//
// Выдаёт ранги согласно значениям в БД.
//
/////////////////////////////////////////////////////////////

/world/proc/convert_ranks(var/nym as num)
	switch(nym)
		if(0) return 0
		if(1) return "Moderator"
		if(2) return "Administrator"
		if(3) return "Primary Administrator"
		if(4) return "Super Administrator"
		if(5) return "Coder"
		if(6) return "Host"
		else  return 0