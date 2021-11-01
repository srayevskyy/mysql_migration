-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema dms_sample
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema dms_sample
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `dms_sample` DEFAULT CHARACTER SET latin1 ;
USE `dms_sample` ;

-- -----------------------------------------------------
-- Table `dms_sample`.`mlb_data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`mlb_data` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`mlb_data` (
  `mlb_id` MEDIUMINT(9) NULL DEFAULT NULL,
  `mlb_name` VARCHAR(30) NULL DEFAULT NULL,
  `mlb_pos` VARCHAR(30) NULL DEFAULT NULL,
  `mlb_team` VARCHAR(30) NULL DEFAULT NULL,
  `mlb_team_long` VARCHAR(30) NULL DEFAULT NULL,
  `bats` VARCHAR(30) NULL DEFAULT NULL,
  `throws` VARCHAR(30) NULL DEFAULT NULL,
  `birth_year` VARCHAR(30) NULL DEFAULT NULL,
  `bp_id` SMALLINT(6) NULL DEFAULT NULL,
  `bref_id` VARCHAR(30) NULL DEFAULT NULL,
  `bref_name` VARCHAR(30) NULL DEFAULT NULL,
  `cbs_id` VARCHAR(30) NULL DEFAULT NULL,
  `cbs_name` VARCHAR(30) NULL DEFAULT NULL,
  `cbs_pos` VARCHAR(30) NULL DEFAULT NULL,
  `espn_id` SMALLINT(6) NULL DEFAULT NULL,
  `espn_name` VARCHAR(30) NULL DEFAULT NULL,
  `espn_pos` VARCHAR(30) NULL DEFAULT NULL,
  `fg_id` VARCHAR(30) NULL DEFAULT NULL,
  `fg_name` VARCHAR(30) NULL DEFAULT NULL,
  `lahman_id` VARCHAR(30) NULL DEFAULT NULL,
  `nfbc_id` SMALLINT(6) NULL DEFAULT NULL,
  `nfbc_name` VARCHAR(30) NULL DEFAULT NULL,
  `nfbc_pos` VARCHAR(30) NULL DEFAULT NULL,
  `retro_id` VARCHAR(30) NULL DEFAULT NULL,
  `retro_name` VARCHAR(30) NULL DEFAULT NULL,
  `debut` VARCHAR(30) NULL DEFAULT NULL,
  `yahoo_id` MEDIUMINT(9) NULL DEFAULT NULL,
  `yahoo_name` VARCHAR(30) NULL DEFAULT NULL,
  `yahoo_pos` VARCHAR(30) NULL DEFAULT NULL,
  `mlb_depth` VARCHAR(30) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`name_data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`name_data` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`name_data` (
  `name_type` VARCHAR(15) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`name_type`, `name`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`nfl_data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`nfl_data` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`nfl_data` (
  `Position` VARCHAR(5) NULL DEFAULT NULL,
  `player_number` SMALLINT(6) NULL DEFAULT NULL,
  `Name` VARCHAR(40) NULL DEFAULT NULL,
  `status` VARCHAR(10) NULL DEFAULT NULL,
  `stat1` VARCHAR(10) NULL DEFAULT NULL,
  `stat1_val` VARCHAR(10) NULL DEFAULT NULL,
  `stat2` VARCHAR(10) NULL DEFAULT NULL,
  `stat2_val` VARCHAR(10) NULL DEFAULT NULL,
  `stat3` VARCHAR(10) NULL DEFAULT NULL,
  `stat3_val` VARCHAR(10) NULL DEFAULT NULL,
  `stat4` VARCHAR(10) NULL DEFAULT NULL,
  `stat4_val` VARCHAR(10) NULL DEFAULT NULL,
  `team` VARCHAR(10) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`nfl_stadium_data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`nfl_stadium_data` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`nfl_stadium_data` (
  `stadium` VARCHAR(60) NULL DEFAULT NULL,
  `seating_capacity` MEDIUMINT(9) NULL DEFAULT NULL,
  `location` VARCHAR(40) NULL DEFAULT NULL,
  `surface` VARCHAR(80) NULL DEFAULT NULL,
  `roof` VARCHAR(30) NULL DEFAULT NULL,
  `team` VARCHAR(40) NULL DEFAULT NULL,
  `opened` VARCHAR(10) NULL DEFAULT NULL,
  `sport_location_id` SMALLINT(6) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`person` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`person` (
  `ID` MEDIUMINT(9) NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(60) NOT NULL,
  `last_name` VARCHAR(30) NULL DEFAULT NULL,
  `first_name` VARCHAR(30) NULL DEFAULT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB
AUTO_INCREMENT = 7077781
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sport_location`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sport_location` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sport_location` (
  `id` SMALLINT(6) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `city` VARCHAR(60) NOT NULL,
  `seating_capacity` INT(11) NULL DEFAULT NULL,
  `levels` TINYINT(4) NULL DEFAULT NULL,
  `sections` SMALLINT(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 94
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sport_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sport_type` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sport_type` (
  `name` VARCHAR(15) NOT NULL,
  `description` VARCHAR(120) NULL DEFAULT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sport_team`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sport_team` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sport_team` (
  `id` MEDIUMINT(9) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  `abbreviated_name` VARCHAR(10) NULL DEFAULT NULL,
  `home_field_id` SMALLINT(6) NULL DEFAULT NULL,
  `sport_type_name` VARCHAR(15) NOT NULL,
  `sport_league_short_name` VARCHAR(10) NOT NULL,
  `sport_division_short_name` VARCHAR(10) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `sport_team_u` (`sport_type_name` ASC, `sport_league_short_name` ASC, `name` ASC),
  INDEX `home_field_fk` (`home_field_id` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 63
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`player`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`player` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`player` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `sport_team_id` MEDIUMINT(9) NOT NULL,
  `last_name` VARCHAR(30) NULL DEFAULT NULL,
  `first_name` VARCHAR(30) NULL DEFAULT NULL,
  `full_name` VARCHAR(30) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `sport_team_fk` (`sport_team_id` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 3130
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`seat_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`seat_type` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`seat_type` (
  `name` VARCHAR(15) NOT NULL,
  `description` VARCHAR(120) NULL DEFAULT NULL,
  `relative_quality` TINYINT(4) NULL DEFAULT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`seat`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`seat` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`seat` (
  `sport_location_id` SMALLINT(6) NOT NULL,
  `seat_level` SMALLINT(6) NOT NULL,
  `seat_section` VARCHAR(15) NOT NULL,
  `seat_row` VARCHAR(10) NOT NULL,
  `seat` VARCHAR(10) NOT NULL,
  `seat_type` VARCHAR(15) NULL DEFAULT NULL,
  PRIMARY KEY (`sport_location_id`, `seat_level`, `seat_section`, `seat_row`, `seat`),
  INDEX `seat_type_fk` (`seat_type` ASC),
  INDEX `seat_sport_location_idx` (`sport_location_id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sport_league`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sport_league` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sport_league` (
  `sport_type_name` VARCHAR(15) NOT NULL,
  `short_name` VARCHAR(10) NOT NULL,
  `long_name` VARCHAR(60) NOT NULL,
  `description` VARCHAR(120) NULL DEFAULT NULL,
  PRIMARY KEY (`short_name`),
  INDEX `sl_sport_type_fk` (`sport_type_name` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sport_division`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sport_division` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sport_division` (
  `sport_type_name` VARCHAR(15) NOT NULL,
  `sport_league_short_name` VARCHAR(10) NOT NULL,
  `short_name` VARCHAR(10) NOT NULL,
  `long_name` VARCHAR(60) NULL DEFAULT NULL,
  `description` VARCHAR(120) NULL DEFAULT NULL,
  PRIMARY KEY (`sport_type_name`, `sport_league_short_name`, `short_name`),
  INDEX `sd_sport_league_fk` (`sport_league_short_name` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sporting_event`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sporting_event` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sporting_event` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `sport_type_name` VARCHAR(15) NOT NULL,
  `home_team_id` MEDIUMINT(9) NOT NULL,
  `away_team_id` MEDIUMINT(9) NOT NULL,
  `location_id` SMALLINT(6) NOT NULL,
  `start_date_time` DATETIME NOT NULL,
  `start_date` DATE NOT NULL,
  `sold_out` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX `se_sport_type_fk` (`sport_type_name` ASC),
  INDEX `se_home_team_id_fk` (`home_team_id` ASC),
  INDEX `se_away_team_id_fk` (`away_team_id` ASC),
  INDEX `se_location_id_fk` (`location_id` ASC),
  INDEX `se_start_date` (`start_date` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 1159
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`sporting_event_ticket`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sporting_event_ticket` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`sporting_event_ticket` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `sporting_event_id` BIGINT(20) NOT NULL,
  `sport_location_id` SMALLINT(6) NOT NULL,
  `seat_level` SMALLINT(6) NOT NULL,
  `seat_section` VARCHAR(15) NOT NULL,
  `seat_row` VARCHAR(10) NOT NULL,
  `seat` VARCHAR(10) NOT NULL,
  `ticketholder_id` MEDIUMINT(9) NULL DEFAULT NULL,
  `ticket_price` DECIMAL(6,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `set_sporting_event_idx` (`sporting_event_id` ASC),
  INDEX `set_seat_idx` (`sport_location_id` ASC, `seat_level` ASC, `seat_section` ASC, `seat_row` ASC, `seat` ASC),
  INDEX `set_ticketholder_idx` (`ticketholder_id` ASC),
  INDEX `set_ev_id_tkholder_id_idx` (`sporting_event_id` ASC, `ticketholder_id` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 90274449
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`ticket_purchase_hist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`ticket_purchase_hist` ;

CREATE TABLE IF NOT EXISTS `dms_sample`.`ticket_purchase_hist` (
  `sporting_event_ticket_id` BIGINT(20) NOT NULL,
  `purchased_by_id` MEDIUMINT(9) NOT NULL,
  `transaction_date_time` DATETIME NOT NULL,
  `transferred_from_id` MEDIUMINT(9) NULL DEFAULT NULL,
  `purchase_price` DECIMAL(6,2) NOT NULL,
  PRIMARY KEY (`sporting_event_ticket_id`, `purchased_by_id`, `transaction_date_time`),
  INDEX `tph_purch_by_id` (`purchased_by_id` ASC),
  INDEX `tph_trans_from_id` (`transferred_from_id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

USE `dms_sample` ;

-- -----------------------------------------------------
-- Placeholder table for view `dms_sample`.`sporting_event_info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dms_sample`.`sporting_event_info` (`event_id` INT, `sport` INT, `event_date_time` INT, `home_team` INT, `away_team` INT, `location` INT, `city` INT);

-- -----------------------------------------------------
-- Placeholder table for view `dms_sample`.`sporting_event_ticket_info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dms_sample`.`sporting_event_ticket_info` (`ticket_id` INT, `event_id` INT, `sport` INT, `event_date_time` INT, `home_team` INT, `away_team` INT, `location` INT, `city` INT, `seat_level` INT, `seat_section` INT, `seat_row` INT, `seat` INT, `ticket_price` INT, `ticketholder` INT);

-- -----------------------------------------------------
-- View `dms_sample`.`sporting_event_info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sporting_event_info`;
DROP VIEW IF EXISTS `dms_sample`.`sporting_event_info` ;
USE `dms_sample`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dms_sample`.`sporting_event_info` AS select `e`.`id` AS `event_id`,`e`.`sport_type_name` AS `sport`,`e`.`start_date_time` AS `event_date_time`,`h`.`name` AS `home_team`,`a`.`name` AS `away_team`,`l`.`name` AS `location`,`l`.`city` AS `city` from (((`dms_sample`.`sporting_event` `e` join `dms_sample`.`sport_team` `h`) join `dms_sample`.`sport_team` `a`) join `dms_sample`.`sport_location` `l`) where ((`e`.`home_team_id` = `h`.`id`) and (`e`.`away_team_id` = `a`.`id`) and (`e`.`location_id` = `l`.`id`));

-- -----------------------------------------------------
-- View `dms_sample`.`sporting_event_ticket_info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dms_sample`.`sporting_event_ticket_info`;
DROP VIEW IF EXISTS `dms_sample`.`sporting_event_ticket_info` ;
USE `dms_sample`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dms_sample`.`sporting_event_ticket_info` AS select `t`.`id` AS `ticket_id`,`e`.`event_id` AS `event_id`,`e`.`sport` AS `sport`,`e`.`event_date_time` AS `event_date_time`,`e`.`home_team` AS `home_team`,`e`.`away_team` AS `away_team`,`e`.`location` AS `location`,`e`.`city` AS `city`,`t`.`seat_level` AS `seat_level`,`t`.`seat_section` AS `seat_section`,`t`.`seat_row` AS `seat_row`,`t`.`seat` AS `seat`,`t`.`ticket_price` AS `ticket_price`,`p`.`full_name` AS `ticketholder` from ((`dms_sample`.`sporting_event_ticket` `t` join `dms_sample`.`sporting_event_info` `e` on((`t`.`sporting_event_id` = `e`.`event_id`))) left join `dms_sample`.`person` `p` on((`t`.`ticketholder_id` = `p`.`ID`)));

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
