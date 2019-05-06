var/DBConnection/dbcon = new()
world
	proc
		startmysql(var/silent)
			dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:[DB_PORT]","[DB_USER]","[DB_PASSWORD]")
			if(!dbcon.IsConnected()) return
			else
				if(!silent)
					world << "\red \b MySQL connection established..."
		keepalive()
			if(!dbcon.IsConnected())
				dbcon.Connect("dbi:mysql:[DB_DBNAME]:[DB_SERVER]:[DB_PORT]","[DB_USER]","[DB_PASSWORD]")

var/motdmysql = null
/client/proc/showmotd()
	if(!motdmysql)
		var/DBQuery/r_query = dbcon.NewQuery("SELECT * FROM `config`")
		if(!r_query.Execute())
			to_log ("Failed-[r_query.ErrorMsg()]")
		else
			var/lawl
			while(r_query.NextRow())
				var/list/column_data = r_query.GetRowData()
				lawl = column_data["motd"]
			if(!lawl)
				src << "ERROR GETTING MOTD"
				return
			motdmysql += "[lawl]"
			motdmysql += "<BR><center><a href=?src=\ref[src];closemotd=1>Close</a></center>"
			motdmysql += "</body>"

			usr << browse(motdmysql,"window=motd;size=800x600")
	else
		usr << browse(motdmysql,"window=motd;size=800x600")

client/Topic(href, href_list[])
	if(href_list["closemotd"])
		src << browse(null,"window=motd;")
	..()
