-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

--
-- Temporary table structure for view `just_access_times`
--
DROP TABLE IF EXISTS `just_access_times`;
DROP VIEW IF EXISTS `just_access_times`;
CREATE TABLE `just_access_times` (
  `course_id` bigint(10) unsigned,
  `user_id` bigint(10) unsigned,
  `first_access` bigint(10) unsigned,
  `last_access` bigint(10) unsigned
);

--
-- Temporary table structure for view `just_alumn`
--
DROP TABLE IF EXISTS `just_alumn`;
DROP VIEW IF EXISTS `just_alumn`;
CREATE TABLE `just_alumn` (
  `course_id` bigint(10) unsigned,
  `user_id` bigint(10) unsigned,
  `firstname` varchar(100),
  `lastname` varchar(100),
  `email` varchar(100),
  `first_access` bigint(10) unsigned,
  `last_access` bigint(10) unsigned
);

--
-- Temporary table structure for view `just_coursed`
--
DROP TABLE IF EXISTS `just_coursed`;
DROP VIEW IF EXISTS `just_coursed`;
CREATE TABLE `just_coursed` (
  `user_id` bigint(10) unsigned,
  `course_id` bigint(10) unsigned
);

--
-- Temporary table structure for view `just_evaluation`
--
DROP TABLE IF EXISTS `just_evaluation`;
DROP VIEW IF EXISTS `just_evaluation`;
CREATE TABLE `just_evaluation` (
  `course_id` bigint(20) unsigned,
  `type` varchar(6),
  `fkid` bigint(20) unsigned,
  `title` varchar(255)
);

--
-- Temporary table structure for view `just_lesson_evaluation`
--
DROP TABLE IF EXISTS `just_lesson_evaluation`;
DROP VIEW IF EXISTS `just_lesson_evaluation`;
CREATE TABLE `just_lesson_evaluation` (
  `course_id` bigint(10) unsigned,
  `type` varchar(6),
  `fkid` bigint(10) unsigned,
  `title` varchar(255)
);

--
-- Temporary table structure for view `just_lesson_results`
--
DROP TABLE IF EXISTS `just_lesson_results`;
DROP VIEW IF EXISTS `just_lesson_results`;
CREATE TABLE `just_lesson_results` (
  `user_id` bigint(10) unsigned,
  `course_id` bigint(10) unsigned,
  `type` varchar(6),
  `fkid` bigint(10) unsigned,
  `result` double unsigned
);

--
-- Temporary table structure for view `just_quiz_evaluation`
--
DROP TABLE IF EXISTS `just_quiz_evaluation`;
DROP VIEW IF EXISTS `just_quiz_evaluation`;
CREATE TABLE `just_quiz_evaluation` (
  `course_id` bigint(10) unsigned,
  `type` varchar(4),
  `fkid` bigint(10) unsigned,
  `title` varchar(255)
);

--
-- Temporary table structure for view `just_quiz_results`
--
DROP TABLE IF EXISTS `just_quiz_results`;
DROP VIEW IF EXISTS `just_quiz_results`;
CREATE TABLE `just_quiz_results` (
  `user_id` bigint(10) unsigned,
  `course_id` bigint(10) unsigned,
  `type` varchar(4),
  `fkid` bigint(10) unsigned,
  `result` double
);

--
-- Temporary table structure for view `just_results`
--
DROP TABLE IF EXISTS `just_results`;
DROP VIEW IF EXISTS `just_results`;
CREATE TABLE `just_results` (
  `user_id` bigint(20) unsigned,
  `course_id` bigint(20) unsigned,
  `type` varchar(6),
  `fkid` bigint(20) unsigned,
  `result` decimal(5,2)
);

--
-- Temporary table structure for view `just_scorm_evaluation`
--
DROP TABLE IF EXISTS `just_scorm_evaluation`;
DROP VIEW IF EXISTS `just_scorm_evaluation`;
CREATE TABLE `just_scorm_evaluation` (
  `course_id` bigint(10) unsigned,
  `type` varchar(5),
  `fkid` bigint(10) unsigned,
  `title` varchar(255)
);

--
-- Temporary table structure for view `just_scorm_results`
--
DROP TABLE IF EXISTS `just_scorm_results`;
DROP VIEW IF EXISTS `just_scorm_results`;
CREATE TABLE `just_scorm_results` (
  `user_id` bigint(10) unsigned,
  `course_id` bigint(10) unsigned,
  `type` varchar(5),
  `fkid` bigint(10) unsigned,
  `result` longtext
);

--
-- Temporary table structure for view `just_sections`
--
DROP TABLE IF EXISTS `just_sections`;
DROP VIEW IF EXISTS `just_sections`;
CREATE TABLE `just_sections` (
  `course_id` bigint(20) unsigned,
  `section_id` bigint(20) unsigned,
  `section_title` varchar(255)
);

--
-- Definition of view `just_access_times`
--

DROP TABLE IF EXISTS `just_access_times`;
DROP VIEW IF EXISTS `just_access_times`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_access_times` AS select `c`.`id` AS `course_id`,`u`.`id` AS `user_id`,max(`log`.`time`) AS `first_access`,min(`log`.`time`) AS `last_access` from ((`mdl_log` `log` join `mdl_course` `c`) join `mdl_user` `u`) where ((`log`.`userid` = `u`.`id`) and (`log`.`course` = `c`.`id`)) group by `c`.`id`,`u`.`id`;

--
-- Definition of view `just_alumn`
--

DROP TABLE IF EXISTS `just_alumn`;
DROP VIEW IF EXISTS `just_alumn`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_alumn` AS select `c`.`course_id` AS `course_id`,`u`.`id` AS `user_id`,`u`.`firstname` AS `firstname`,`u`.`lastname` AS `lastname`,`u`.`email` AS `email`,`access`.`first_access` AS `first_access`,`access`.`last_access` AS `last_access` from ((`mdl_user` `u` join `just_coursed` `c` on((`u`.`id` = `c`.`user_id`))) left join `just_access_times` `access` on(((`c`.`course_id` = `access`.`course_id`) and (`c`.`user_id` = `access`.`user_id`))));

--
-- Definition of view `just_coursed`
--

DROP TABLE IF EXISTS `just_coursed`;
DROP VIEW IF EXISTS `just_coursed`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_coursed` AS select `u`.`id` AS `user_id`,`c`.`id` AS `course_id` from ((((`mdl_user` `u` join `mdl_course` `c`) join `mdl_context` `ctx`) join `mdl_role` `role`) join `mdl_role_assignments` `ra`) where ((`c`.`id` = `ctx`.`instanceid`) and (`ctx`.`contextlevel` = 50) and (`role`.`shortname` = 'student') and (`ra`.`roleid` = `role`.`id`) and (`ra`.`userid` = `u`.`id`) and (`ra`.`contextid` = `ctx`.`id`));

--
-- Definition of view `just_evaluation`
--

DROP TABLE IF EXISTS `just_evaluation`;
DROP VIEW IF EXISTS `just_evaluation`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_evaluation` AS (select `just_quiz_evaluation`.`course_id` AS `course_id`,`just_quiz_evaluation`.`type` AS `type`,`just_quiz_evaluation`.`fkid` AS `fkid`,`just_quiz_evaluation`.`title` AS `title` from `just_quiz_evaluation`) union (select `just_scorm_evaluation`.`course_id` AS `course_id`,`just_scorm_evaluation`.`type` AS `type`,`just_scorm_evaluation`.`fkid` AS `fkid`,`just_scorm_evaluation`.`title` AS `title` from `just_scorm_evaluation`) union (select `just_lesson_evaluation`.`course_id` AS `course_id`,`just_lesson_evaluation`.`type` AS `type`,`just_lesson_evaluation`.`fkid` AS `fkid`,`just_lesson_evaluation`.`title` AS `title` from `just_lesson_evaluation`);

--
-- Definition of view `just_lesson_evaluation`
--

DROP TABLE IF EXISTS `just_lesson_evaluation`;
DROP VIEW IF EXISTS `just_lesson_evaluation`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_lesson_evaluation` AS select `c`.`id` AS `course_id`,'lesson' AS `type`,`lesson`.`id` AS `fkid`,`lesson`.`name` AS `title` from (`mdl_lesson` `lesson` join `mdl_course` `c`) where (`lesson`.`course` = `c`.`id`);

--
-- Definition of view `just_lesson_results`
--

DROP TABLE IF EXISTS `just_lesson_results`;
DROP VIEW IF EXISTS `just_lesson_results`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_lesson_results` AS select `u`.`id` AS `user_id`,`c`.`id` AS `course_id`,'lesson' AS `type`,`lesson`.`id` AS `fkid`,`lesson_grades`.`grade` AS `result` from (((`mdl_lesson_grades` `lesson_grades` join `mdl_lesson` `lesson`) join `mdl_course` `c`) join `mdl_user` `u`) where ((`c`.`id` = `lesson`.`course`) and (`lesson`.`id` = `lesson_grades`.`lessonid`) and (`u`.`id` = `lesson_grades`.`userid`));

--
-- Definition of view `just_quiz_evaluation`
--

DROP TABLE IF EXISTS `just_quiz_evaluation`;
DROP VIEW IF EXISTS `just_quiz_evaluation`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_quiz_evaluation` AS select `c`.`id` AS `course_id`,'quiz' AS `type`,`quiz`.`id` AS `fkid`,`quiz`.`name` AS `title` from (`mdl_quiz` `quiz` join `mdl_course` `c`) where (`quiz`.`course` = `c`.`id`);

--
-- Definition of view `just_quiz_results`
--

DROP TABLE IF EXISTS `just_quiz_results`;
DROP VIEW IF EXISTS `just_quiz_results`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_quiz_results` AS select `u`.`id` AS `user_id`,`c`.`id` AS `course_id`,'quiz' AS `type`,`quiz`.`id` AS `fkid`,`quiz_grades`.`grade` AS `result` from (((`mdl_quiz_grades` `quiz_grades` join `mdl_quiz` `quiz`) join `mdl_course` `c`) join `mdl_user` `u`) where ((`c`.`id` = `quiz`.`course`) and (`quiz`.`id` = `quiz_grades`.`quiz`) and (`u`.`id` = `quiz_grades`.`userid`));

--
-- Definition of view `just_results`
--

DROP TABLE IF EXISTS `just_results`;
DROP VIEW IF EXISTS `just_results`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_results` AS (select `just_scorm_results`.`user_id` AS `user_id`,`just_scorm_results`.`course_id` AS `course_id`,`just_scorm_results`.`type` AS `type`,`just_scorm_results`.`fkid` AS `fkid`,cast(`just_scorm_results`.`result` as decimal(5,2)) AS `result` from `just_scorm_results`) union (select `just_quiz_results`.`user_id` AS `user_id`,`just_quiz_results`.`course_id` AS `course_id`,`just_quiz_results`.`type` AS `type`,`just_quiz_results`.`fkid` AS `fkid`,cast(`just_quiz_results`.`result` as decimal(5,2)) AS `result` from `just_quiz_results`) union (select `just_lesson_results`.`user_id` AS `user_id`,`just_lesson_results`.`course_id` AS `course_id`,`just_lesson_results`.`type` AS `type`,`just_lesson_results`.`fkid` AS `fkid`,cast(`just_lesson_results`.`result` as decimal(5,2)) AS `result` from `just_lesson_results`);

--
-- Definition of view `just_scorm_evaluation`
--

DROP TABLE IF EXISTS `just_scorm_evaluation`;
DROP VIEW IF EXISTS `just_scorm_evaluation`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_scorm_evaluation` AS select `c`.`id` AS `course_id`,'scorm' AS `type`,`scoes`.`id` AS `fkid`,`scoes`.`title` AS `title` from (((`mdl_scorm_scoes_track` `track` join `mdl_course` `c`) join `mdl_scorm_scoes` `scoes`) join `mdl_scorm` `scorm`) where ((`track`.`element` = 'cmi.core.score.raw') and (`track`.`scormid` = `scorm`.`id`) and (`track`.`scoid` = `scoes`.`id`) and (`scorm`.`course` = `c`.`id`)) group by `scoes`.`id`;

--
-- Definition of view `just_scorm_results`
--

DROP TABLE IF EXISTS `just_scorm_results`;
DROP VIEW IF EXISTS `just_scorm_results`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_scorm_results` AS select `u`.`id` AS `user_id`,`c`.`id` AS `course_id`,'scorm' AS `type`,`track`.`scoid` AS `fkid`,`track`.`value` AS `result` from (((`mdl_user` `u` join `mdl_course` `c`) join `mdl_scorm` `scorm`) join `mdl_scorm_scoes_track` `track`) where ((`track`.`element` = 'cmi.core.score.raw') and (`track`.`userid` = `u`.`id`) and (`scorm`.`course` = `c`.`id`) and (`track`.`scormid` = `scorm`.`id`));

--
-- Definition of view `just_sections`
--

DROP TABLE IF EXISTS `just_sections`;
DROP VIEW IF EXISTS `just_sections`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `just_sections` AS (select `c`.`id` AS `course_id`,`scoes`.`id` AS `section_id`,`scoes`.`title` AS `section_title` from ((`mdl_course` `c` join `mdl_scorm` `scorm`) join `mdl_scorm_scoes` `scoes`) where ((`c`.`id` = `scorm`.`course`) and (`scorm`.`id` = `scoes`.`scorm`))) union (select `c`.`id` AS `course_id`,`res`.`id` AS `section_id`,`res`.`name` AS `section_title` from (`mdl_course` `c` join `mdl_resource` `res`) where (`c`.`id` = `res`.`course`));



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
