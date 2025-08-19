//Логгирование. Да.

/////////////////////////////////////////////////////////////
//
// Это говно после создания мира записывает в лог информацию.
//
/////////////////////////////////////////////////////////////

/world/New()
    ..()
    diary = file("DATA/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
    diary << ""
    diary << ""
    diary << "NEW ROUND: [time2text(world.timeofday, "hh:mm.ss")]"
    diary << "---------------------"
    diary << ""

/////////////////////////////////////////////////////////////
//
// Это говно просто логгирует (костыль для diary).
//
/////////////////////////////////////////////////////////////

/proc/to_log(text)
	check_diary()
	diary << "[timestamp()][text]"

/////////////////////////////////////////////////////////////
//
// Это говно генерирует точное время.
//
/////////////////////////////////////////////////////////////

/proc/timestamp()
	return "\[[time2text(world.timeofday, "hh:mm:ss")]\]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует админлоги.
//
// Usage: log_admin('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_admin(text)
	check_diary()
	admin_log.Add(text)
	if (config.log_admin)
		diary << "[timestamp()]ADMINL: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует геймлоги.
//
// Usage: log_game('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_game(text)
	check_diary()
	if (config.log_game)
		diary << "[timestamp()]GAMLOG: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует воуты.
//
// Usage: log_vote('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_vote(text)
	check_diary()
	if (config.log_vote)
		diary << "[timestamp()]VOTLOG: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует входы.
//
// Usage: log_access('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_access(text)
	check_diary()
	if (config.log_access)
		diary << "[timestamp()]ACCESS: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует сеи.
//
// Usage: log_say('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_say(text)
	check_diary()
	if (config.log_say)
		diary << "[timestamp()]SAYLOG: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует OOC.
//
// Usage: log_ooc('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_ooc(text)
	check_diary()
	if (config.log_ooc)
		diary << "[timestamp()]OOCLOG: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует шепот.
//
// Usage: log_whisper('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_whisper(text)
	check_diary()
	if (config.log_whisper)
		diary << "[timestamp()]WHISPE: [text]"

/////////////////////////////////////////////////////////////
//
// Это говно логгирует атаки.
//
// Usage: log_attack('SOMESHIT')
//
/////////////////////////////////////////////////////////////

/proc/log_attack(text)
	check_diary()
	diary << "[timestamp()]ATTACK:[text]"
	message_admins(text)

/////////////////////////////////////////////////////////////
//
// Это говно проверяет время и в случае нового дня создаёт новую папку с новой датой и новым файлом логов на текущий день. Просто, да?
//
/////////////////////////////////////////////////////////////

/proc/check_diary()
	if (time2text(world.realtime, "YYYYMMDD") > current_date)
		diary << "---------------------"
		diary << "Day Ended, see next log"
		diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
		current_date = time2text(world.realtime, "YYYYMMDD")
		diary << "New Day, continuing from previous"
		diary << "---------------------"