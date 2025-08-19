//Тут происходит загрузка говна из конфигов. И только из них.

/////////////////////////////////////////////////////////////
//
// Это говно подгружает конфиги mysql и записывает их в память.
//
// Usage: load_mysql()
//
/////////////////////////////////////////////////////////////

/datum/configuration/proc/load_mysql()
	var/text = file2text("CONF/db_config.txt")
	var/list/CL = dd_text2list(text, "\n")

	for (var/t in CL)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if("db_server")
				DB_SERVER = value
			if("db_port")
				DB_PORT = text2num(value)
			if("db_user")
				DB_USER = value
			if("db_password")
				DB_PASSWORD = value
			if("db_dbname")
				DB_DBNAME = value

/////////////////////////////////////////////////////////////
//
// Это говно подгружает motd и записывает его в память.
//
// Usage: load_motd()
//
/////////////////////////////////////////////////////////////

/world/proc/load_motd()
	join_motd = file2text("CONF/motd.txt")
	auth_motd = file2text("CONF/motd-auth.txt")
	no_auth_motd = file2text("CONF/motd-noauth.txt")
	to_log ("SERVER: MOTD loaded!")

/////////////////////////////////////////////////////////////
//
// Это говно подгружает rules и записывает его в память.
//
// Usage: load_rules()
//
/////////////////////////////////////////////////////////////

/world/proc/load_rules()
	rules = file2text("CONF/rules.html")
	if (!rules)
		rules = "<html><head><title>Rules</title><body>There are no rules! Go nuts!</body></html>"
	to_log ("SERVER: Rules loaded!")

/////////////////////////////////////////////////////////////
//
// Это говно подгружает testers и записывает его в память.
//
// Usage: load_testers()
//
/////////////////////////////////////////////////////////////

/world/proc/load_testers()
	var/text = file2text("CONF/testers.txt")
	if (!text)
		check_diary()
		to_log ("SERVER: Failed to load CONF/testers.txt\n")
	else
		var/list/lines = dd_text2list(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == ";")
				continue

			var/pos = findtext(line, " - ", 1, null)
			if (pos)
				var/m_key = copytext(line, 1, pos)
				var/a_lev = copytext(line, pos + 3, length(line) + 1)
				admins[m_key] = a_lev

/////////////////////////////////////////////////////////////
//
// Это говно подгружает configuration и записывает его в память.
//
// Usage: load_configuration()
//
/////////////////////////////////////////////////////////////

/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("CONF/config.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn
