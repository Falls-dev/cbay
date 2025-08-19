//Тут происходит загрузка говна из DATA. Достаточно?

/////////////////////////////////////////////////////////////
//
// Это говно подгружает mode и записывает его в память.
//
// Usage: load_mode()
//
/////////////////////////////////////////////////////////////

/world/proc/load_mode()
	var/text = file2text("DATA/mode.txt")
	if (text)
		var/list/lines = dd_text2list(text, "\n")
		if (lines[1])
			master_mode = lines[1]
			check_diary()
			to_log ("SERVER: Saved mode is '[master_mode]'")

/////////////////////////////////////////////////////////////
//
// Это говно сохраняет mode.
//
// Usage: save_mode('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/world/proc/save_mode(var/the_mode)
	var/F = file("DATA/mode.txt")
	fdel(F)
	F << the_mode

/////////////////////////////////////////////////////////////
//
// Это говно подгружает твики атмоса.
//
// Usage: LoadTweaks()
//
/////////////////////////////////////////////////////////////

proc/LoadTweaks()
	if(fexists("DATA/game_settings.sav"))
		var/savefile/F = new("DATA/game_settings.sav")
		F >> vsc
		del F
		world.log << "TWEAKS: Airflow, Plasma and Damage settings loaded."

/////////////////////////////////////////////////////////////
//
// Это говно сохраняет твики атмоса.
//
// Usage: SaveTweaks()
//
/////////////////////////////////////////////////////////////

proc/SaveTweaks()
	var/savefile/F = new("DATA/game_settings.sav")
	F << vsc
	del F
	world.log << "TWEAKS: Airflow, Plasma and Damage settings saved."