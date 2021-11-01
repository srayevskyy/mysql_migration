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
CREATE TABLE IF NOT EXISTS `dms_sample`.`name_data` (
  `name_type` VARCHAR(15) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`name_type`, `name`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `dms_sample`.`nfl_data`
-- -----------------------------------------------------
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


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
