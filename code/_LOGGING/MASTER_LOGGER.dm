//������������. ��.

/////////////////////////////////////////////////////////////
//
// ��� ����� ����� �������� ���� ���������� � ��� ����������.
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
// ��� ����� ������ ��������� (������� ��� diary).
//
/////////////////////////////////////////////////////////////

/proc/to_log(text)
	check_diary()
	diary << "[timestamp()][text]"

/////////////////////////////////////////////////////////////
//
// ��� ����� ���������� ������ �����.
//
/////////////////////////////////////////////////////////////

/proc/timestamp()
	return "\[[time2text(world.timeofday, "hh:mm:ss")]\]"

/////////////////////////////////////////////////////////////
//
// ��� ����� ��������� ���������.
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
// ��� ����� ��������� ��������.
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
// ��� ����� ��������� �����.
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
// ��� ����� ��������� �����.
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
// ��� ����� ��������� ���.
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
// ��� ����� ��������� OOC.
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
// ��� ����� ��������� �����.
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
// ��� ����� ��������� �����.
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
// ��� ����� ��������� ����� � � ������ ������ ��� ������ ����� ����� � ����� ����� � ����� ������ ����� �� ������� ����. ������, ��?
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