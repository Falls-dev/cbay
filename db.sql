-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               10.3.10-MariaDB-log - mariadb.org binary distribution
-- Операционная система:         Win64
-- HeidiSQL Версия:              9.4.0.5125
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Дамп структуры базы данных gavno
CREATE DATABASE IF NOT EXISTS `gavno` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `gavno`;

-- Дамп структуры для таблица gavno.admins
CREATE TABLE IF NOT EXISTS `admins` (
  `ckey` varchar(255) NOT NULL,
  `rank` int(1) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.admins: 1 rows
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
REPLACE INTO `admins` (`ckey`, `rank`) VALUES
	('valtosin', 6);
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.backpack
CREATE TABLE IF NOT EXISTS `backpack` (
  `ckey` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  UNIQUE KEY `NODUPE` (`ckey`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.backpack: 0 rows
/*!40000 ALTER TABLE `backpack` DISABLE KEYS */;
/*!40000 ALTER TABLE `backpack` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.bans
CREATE TABLE IF NOT EXISTS `bans` (
  `ckey` varchar(255) NOT NULL,
  `computerid` text NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `bannedby` varchar(255) NOT NULL,
  `temp` int(1) NOT NULL COMMENT '0 = perma ban / minutes banned',
  `minute` int(255) NOT NULL DEFAULT 0,
  `timebanned` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.bans: 0 rows
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.booklog
CREATE TABLE IF NOT EXISTS `booklog` (
  `ckey` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'INSERT',
  `title` text NOT NULL,
  `author` varchar(256) NOT NULL,
  `text` longtext NOT NULL,
  `cat` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.booklog: 0 rows
/*!40000 ALTER TABLE `booklog` DISABLE KEYS */;
/*!40000 ALTER TABLE `booklog` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.books
CREATE TABLE IF NOT EXISTS `books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `text` longtext NOT NULL,
  `cat` int(2) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=138 DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.books: 0 rows
/*!40000 ALTER TABLE `books` DISABLE KEYS */;
/*!40000 ALTER TABLE `books` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.changelog
CREATE TABLE IF NOT EXISTS `changelog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bywho` varchar(255) NOT NULL,
  `changes` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.changelog: 0 rows
/*!40000 ALTER TABLE `changelog` DISABLE KEYS */;
/*!40000 ALTER TABLE `changelog` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.config
CREATE TABLE IF NOT EXISTS `config` (
  `motd` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.config: 0 rows
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
REPLACE INTO `config` (`motd`) VALUES
	('OH HELLO');
/*!40000 ALTER TABLE `config` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.crban
CREATE TABLE IF NOT EXISTS `crban` (
  `ckey` varchar(255) NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL COMMENT 'Why the ban was placed',
  `bannedby` varchar(255) NOT NULL COMMENT 'Who set the ban',
  `time` datetime NOT NULL COMMENT 'When the ban was placed',
  `unban_time` datetime DEFAULT NULL COMMENT 'When the loser should be Unbanned',
  PRIMARY KEY (`ckey`),
  KEY `bannedby` (`bannedby`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.crban: 0 rows
/*!40000 ALTER TABLE `crban` DISABLE KEYS */;
/*!40000 ALTER TABLE `crban` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.crban_past
CREATE TABLE IF NOT EXISTS `crban_past` (
  `CKey` varchar(255) NOT NULL COMMENT 'Who was banned',
  `Banner` varchar(255) NOT NULL COMMENT 'Who banned them',
  `BanReason` text NOT NULL COMMENT 'Why they were banned',
  `BanTime` datetime NOT NULL COMMENT 'When the ban was placed',
  `UnbanTime` datetime DEFAULT NULL COMMENT 'When the ban was supposed to be lifted',
  `Unbanned` datetime DEFAULT NULL COMMENT 'If not null, when the ban was lifted early',
  `Unbanner` varchar(255) DEFAULT NULL COMMENT 'Who unbanned them early',
  KEY `CKey` (`CKey`),
  KEY `Banner` (`Banner`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Record of all the past bans';

-- Дамп данных таблицы gavno.crban_past: 0 rows
/*!40000 ALTER TABLE `crban_past` DISABLE KEYS */;
/*!40000 ALTER TABLE `crban_past` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.currentplayers
CREATE TABLE IF NOT EXISTS `currentplayers` (
  `name` varchar(255) NOT NULL,
  `playing` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.currentplayers: 0 rows
/*!40000 ALTER TABLE `currentplayers` DISABLE KEYS */;
/*!40000 ALTER TABLE `currentplayers` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.deathlog
CREATE TABLE IF NOT EXISTS `deathlog` (
  `ckey` varchar(255) NOT NULL,
  `location` text NOT NULL,
  `lastattacker` text NOT NULL,
  `ToD` text NOT NULL,
  `health` text NOT NULL,
  `lasthit` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.deathlog: 0 rows
/*!40000 ALTER TABLE `deathlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `deathlog` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.invites
CREATE TABLE IF NOT EXISTS `invites` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.invites: 0 rows
/*!40000 ALTER TABLE `invites` DISABLE KEYS */;
/*!40000 ALTER TABLE `invites` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.jobban
CREATE TABLE IF NOT EXISTS `jobban` (
  `ckey` varchar(255) NOT NULL,
  `rank` varchar(255) NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`(100),`rank`(100))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.jobban: 0 rows
/*!40000 ALTER TABLE `jobban` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobban` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.jobbanlog
CREATE TABLE IF NOT EXISTS `jobbanlog` (
  `ckey` varchar(255) NOT NULL COMMENT 'By who',
  `targetckey` varchar(255) NOT NULL COMMENT 'Target',
  `rank` varchar(255) NOT NULL COMMENT 'rank',
  `when` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'when',
  `why` varchar(355) NOT NULL,
  UNIQUE KEY `targetckey` (`targetckey`(100),`rank`(100))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.jobbanlog: 0 rows
/*!40000 ALTER TABLE `jobbanlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobbanlog` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.medals
CREATE TABLE IF NOT EXISTS `medals` (
  `ckey` varchar(255) NOT NULL,
  `medal` text NOT NULL,
  `medaldesc` text NOT NULL,
  `medaldiff` text NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`,`medal`(8))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.medals: 0 rows
/*!40000 ALTER TABLE `medals` DISABLE KEYS */;
/*!40000 ALTER TABLE `medals` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.players
CREATE TABLE IF NOT EXISTS `players` (
  `ckey` varchar(255) NOT NULL,
  `slot` int(2) NOT NULL DEFAULT 1,
  `slotname` varchar(255) NOT NULL DEFAULT 'Default',
  `real_name` varchar(255) NOT NULL,
  `gender` varchar(255) NOT NULL,
  `occupation1` varchar(255) NOT NULL,
  `occupation2` varchar(255) NOT NULL,
  `occupation3` varchar(255) NOT NULL,
  `hair_red` int(3) NOT NULL,
  `hair_green` int(3) NOT NULL,
  `hair_blue` int(3) NOT NULL,
  `ages` int(3) NOT NULL,
  `facial_red` int(3) NOT NULL,
  `facial_green` int(3) NOT NULL,
  `facial_blue` int(3) NOT NULL,
  `skin_tone` int(3) NOT NULL,
  `hair_style_name` varchar(255) NOT NULL,
  `facial_style_name` varchar(255) NOT NULL,
  `eyes_red` int(3) NOT NULL,
  `eyes_green` int(3) NOT NULL,
  `eyes_blue` int(3) NOT NULL,
  `blood_type` varchar(3) NOT NULL,
  `be_syndicate` int(3) NOT NULL,
  `underwear` int(3) NOT NULL,
  `name_is_always_random` int(3) NOT NULL,
  `bios` longtext NOT NULL,
  `show` int(1) NOT NULL DEFAULT 1,
  `be_nuke_agent` tinyint(1) NOT NULL,
  `be_takeover_agent` tinyint(1) NOT NULL,
  UNIQUE KEY `ckey` (`ckey`,`slot`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.players: 0 rows
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
/*!40000 ALTER TABLE `players` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.ranks
CREATE TABLE IF NOT EXISTS `ranks` (
  `Rank` int(11) NOT NULL COMMENT 'What Numeric Rank',
  `Desc` text NOT NULL COMMENT 'What is a person with this rank?',
  PRIMARY KEY (`Rank`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.ranks: 0 rows
/*!40000 ALTER TABLE `ranks` DISABLE KEYS */;
/*!40000 ALTER TABLE `ranks` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.roundsjoined
CREATE TABLE IF NOT EXISTS `roundsjoined` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.roundsjoined: 0 rows
/*!40000 ALTER TABLE `roundsjoined` DISABLE KEYS */;
/*!40000 ALTER TABLE `roundsjoined` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.roundsurvived
CREATE TABLE IF NOT EXISTS `roundsurvived` (
  `ckey` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.roundsurvived: 0 rows
/*!40000 ALTER TABLE `roundsurvived` DISABLE KEYS */;
/*!40000 ALTER TABLE `roundsurvived` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.stats
CREATE TABLE IF NOT EXISTS `stats` (
  `ckey` varchar(255) NOT NULL COMMENT 'ckey',
  `deaths` int(10) NOT NULL DEFAULT 0 COMMENT 'player deaths',
  `roundsplayed` int(10) NOT NULL DEFAULT 0 COMMENT 'rounds played',
  `suicides` int(10) NOT NULL DEFAULT 0 COMMENT 'suicides',
  `traitorwin` int(10) NOT NULL DEFAULT 0 COMMENT 'traitor wins',
  PRIMARY KEY (`ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.stats: 0 rows
/*!40000 ALTER TABLE `stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.suggest
CREATE TABLE IF NOT EXISTS `suggest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` text NOT NULL,
  `link` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.suggest: 0 rows
/*!40000 ALTER TABLE `suggest` DISABLE KEYS */;
/*!40000 ALTER TABLE `suggest` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.traitorbuy
CREATE TABLE IF NOT EXISTS `traitorbuy` (
  `type` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.traitorbuy: 0 rows
/*!40000 ALTER TABLE `traitorbuy` DISABLE KEYS */;
/*!40000 ALTER TABLE `traitorbuy` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.traitorlogs
CREATE TABLE IF NOT EXISTS `traitorlogs` (
  `CKey` varchar(128) NOT NULL,
  `Objective` text NOT NULL,
  `Succeeded` tinyint(4) NOT NULL,
  `Spawned` text NOT NULL,
  `Occupation` varchar(128) NOT NULL,
  `PlayerCount` int(11) NOT NULL,
  KEY `CKey` (`CKey`),
  KEY `Succeeded` (`Succeeded`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.traitorlogs: ~0 rows (приблизительно)
/*!40000 ALTER TABLE `traitorlogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `traitorlogs` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.unbans
CREATE TABLE IF NOT EXISTS `unbans` (
  `ckey` varchar(255) NOT NULL,
  `computerid` text NOT NULL,
  `ips` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `bannedby` varchar(255) NOT NULL,
  `temp` int(255) NOT NULL COMMENT '0 = perma ban / minutes banned',
  `minutes` int(255) NOT NULL,
  `timebanned` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.unbans: 0 rows
/*!40000 ALTER TABLE `unbans` DISABLE KEYS */;
/*!40000 ALTER TABLE `unbans` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.voters
CREATE TABLE IF NOT EXISTS `voters` (
  `username` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL,
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Дамп данных таблицы gavno.voters: 0 rows
/*!40000 ALTER TABLE `voters` DISABLE KEYS */;
/*!40000 ALTER TABLE `voters` ENABLE KEYS */;

-- Дамп структуры для таблица gavno.web_log
CREATE TABLE IF NOT EXISTS `web_log` (
  `type` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `bywho` varchar(255) NOT NULL,
  `time` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Дамп данных таблицы gavno.web_log: 0 rows
/*!40000 ALTER TABLE `web_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_log` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
