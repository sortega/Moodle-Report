-- phpMyAdmin SQL Dump
-- version 3.3.2deb1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 14-07-2011 a las 08:28:10
-- Versión del servidor: 5.1.41
-- Versión de PHP: 5.3.2-1ubuntu4.7

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `moodle-fcupm`
--

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `course_end`
--
CREATE TABLE IF NOT EXISTS `course_end` (
`courseid` bigint(10) unsigned
,`enddate` bigint(10) unsigned
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `final_grades`
--
CREATE TABLE IF NOT EXISTS `final_grades` (
`course_id` bigint(10) unsigned
,`user_id` bigint(10) unsigned
,`grade` decimal(10,5)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `report`
--
CREATE TABLE IF NOT EXISTS `report` (
`curso` bigint(10) unsigned
,`alumn_id` bigint(10) unsigned
,`nombre` varchar(100)
,`apellidos` varchar(100)
,`dni` varchar(255)
,`primera_conexion` datetime
,`ultima_conexion` datetime
,`conectado_a_tiempo` int(1)
,`tiempo_total` decimal(24,4)
,`evaluaciones` bigint(21)
,`calificacion_final` decimal(10,5)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `report_controles`
--
CREATE TABLE IF NOT EXISTS `report_controles` (
`nombre` varchar(100)
,`apellidos` varchar(100)
,`dni` varchar(255)
,`course_id` bigint(10) unsigned
,`user_id` bigint(10) unsigned
,`name` varchar(255)
,`grade` decimal(10,5)
,`date` datetime
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `user_accesses`
--
CREATE TABLE IF NOT EXISTS `user_accesses` (
`course_id` bigint(10) unsigned
,`user_id` bigint(10) unsigned
,`first_access` bigint(10) unsigned
,`last_access` bigint(10) unsigned
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `user_grades`
--
CREATE TABLE IF NOT EXISTS `user_grades` (
`course_id` bigint(10) unsigned
,`user_id` bigint(10) unsigned
,`name` varchar(255)
,`grade` decimal(10,5)
,`date` datetime
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `user_hours`
--
CREATE TABLE IF NOT EXISTS `user_hours` (
`course` bigint(10) unsigned
,`userid` bigint(10) unsigned
,`hours` decimal(24,4)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `user_sessions`
--
CREATE TABLE IF NOT EXISTS `user_sessions` (
`course` bigint(10) unsigned
,`userid` bigint(10) unsigned
,`half_hour_session` decimal(21,0)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `user_submissions`
--
CREATE TABLE IF NOT EXISTS `user_submissions` (
`course_id` bigint(10) unsigned
,`assignment_id` bigint(10) unsigned
,`user_id` bigint(10) unsigned
,`grade` bigint(11)
,`date` datetime
);
-- --------------------------------------------------------

--
-- Estructura para la vista `course_end`
--
DROP TABLE IF EXISTS `course_end`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `course_end` AS select `mdl_event`.`courseid` AS `courseid`,`mdl_event`.`timestart` AS `enddate` from `mdl_event` where ((`mdl_event`.`eventtype` = 'course') and (`mdl_event`.`name` like '%Fin de curso%'));

-- --------------------------------------------------------

--
-- Estructura para la vista `final_grades`
--
DROP TABLE IF EXISTS `final_grades`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `final_grades` AS select `item`.`courseid` AS `course_id`,`grade`.`userid` AS `user_id`,`grade`.`finalgrade` AS `grade` from (`mdl_grade_items` `item` left join `mdl_grade_grades` `grade` on((`item`.`id` = `grade`.`itemid`))) where (`item`.`itemname` like '%Calificación final%');

-- --------------------------------------------------------

--
-- Estructura para la vista `report`
--
DROP TABLE IF EXISTS `report`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `report` AS select `c`.`id` AS `curso`,`usr`.`id` AS `alumn_id`,`usr`.`firstname` AS `nombre`,`usr`.`lastname` AS `apellidos`,`usr`.`idnumber` AS `dni`,from_unixtime(`access`.`first_access`) AS `primera_conexion`,from_unixtime(`access`.`last_access`) AS `ultima_conexion`,(((`access`.`last_access` - `access`.`first_access`) / (`end`.`enddate` - `c`.`startdate`)) <= 0.15) AS `conectado_a_tiempo`,`hours`.`hours` AS `tiempo_total`,count(0) AS `evaluaciones`,`grade`.`grade` AS `calificacion_final` from (((`mdl_user` `usr` left join `user_accesses` `access` on((`usr`.`id` = `access`.`user_id`))) left join `user_hours` `hours` on((`usr`.`id` = `hours`.`userid`))) join (((`mdl_course` `c` left join `course_end` `end` on((`c`.`id` = `end`.`courseid`))) left join `user_submissions` `sub` on((`c`.`id` = `sub`.`course_id`))) left join `final_grades` `grade` on((`c`.`id` = `grade`.`course_id`)))) where ((`access`.`course_id` = `c`.`id`) and (`hours`.`course` = `c`.`id`) and (`sub`.`user_id` = `usr`.`id`) and (`grade`.`user_id` = `usr`.`id`)) group by `c`.`id`,`usr`.`id` order by `c`.`id`,`usr`.`id`;

-- --------------------------------------------------------

--
-- Estructura para la vista `report_controles`
--
DROP TABLE IF EXISTS `report_controles`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `report_controles` AS select `usr`.`firstname` AS `nombre`,`usr`.`lastname` AS `apellidos`,`usr`.`idnumber` AS `dni`,`grade`.`course_id` AS `course_id`,`grade`.`user_id` AS `user_id`,`grade`.`name` AS `name`,`grade`.`grade` AS `grade`,`grade`.`date` AS `date` from ((`mdl_course` `c` left join `user_grades` `grade` on((`c`.`id` = `grade`.`course_id`))) join `mdl_user` `usr` on((`usr`.`id` = `grade`.`user_id`))) order by `c`.`id`,`usr`.`idnumber`;

-- --------------------------------------------------------

--
-- Estructura para la vista `user_accesses`
--
DROP TABLE IF EXISTS `user_accesses`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `user_accesses` AS select `c`.`id` AS `course_id`,`u`.`id` AS `user_id`,min(`log`.`time`) AS `first_access`,max(`log`.`time`) AS `last_access` from (((`mdl_log` `log` join `mdl_course` `c`) join `mdl_user` `u`) left join `course_end` `end` on((`c`.`id` = `end`.`courseid`))) where ((`log`.`userid` = `u`.`id`) and (`log`.`course` = `c`.`id`) and (`log`.`time` >= `c`.`startdate`) and (`log`.`time` <= `end`.`enddate`)) group by `c`.`id`,`u`.`id`;

-- --------------------------------------------------------

--
-- Estructura para la vista `user_grades`
--
DROP TABLE IF EXISTS `user_grades`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `user_grades` AS select `item`.`courseid` AS `course_id`,`grade`.`userid` AS `user_id`,`item`.`itemname` AS `name`,`grade`.`finalgrade` AS `grade`,from_unixtime(`grade`.`timemodified`) AS `date` from (`mdl_grade_items` `item` join `mdl_grade_grades` `grade` on((`item`.`id` = `grade`.`itemid`))) where (`item`.`itemmodule` = 'assignment');

-- --------------------------------------------------------

--
-- Estructura para la vista `user_hours`
--
DROP TABLE IF EXISTS `user_hours`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `user_hours` AS select `user_sessions`.`course` AS `course`,`user_sessions`.`userid` AS `userid`,(count(0) / 2) AS `hours` from `user_sessions` group by `user_sessions`.`course`,`user_sessions`.`userid`;

-- --------------------------------------------------------

--
-- Estructura para la vista `user_sessions`
--
DROP TABLE IF EXISTS `user_sessions`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `user_sessions` AS select `mdl_log`.`course` AS `course`,`mdl_log`.`userid` AS `userid`,round((`mdl_log`.`time` / 3600),0) AS `half_hour_session` from `mdl_log` group by `mdl_log`.`course`,`mdl_log`.`userid`,round((`mdl_log`.`time` / 3600),0);

-- --------------------------------------------------------

--
-- Estructura para la vista `user_submissions`
--
DROP TABLE IF EXISTS `user_submissions`;

CREATE ALGORITHM=UNDEFINED  SQL SECURITY DEFINER VIEW `user_submissions` AS select `ejercicio`.`course` AS `course_id`,`entrega`.`id` AS `assignment_id`,`entrega`.`userid` AS `user_id`,`entrega`.`grade` AS `grade`,from_unixtime(`entrega`.`timemodified`) AS `date` from (`mdl_assignment` `ejercicio` join `mdl_assignment_submissions` `entrega`) where (`ejercicio`.`id` = `entrega`.`assignment`);
