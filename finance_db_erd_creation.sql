-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema finance_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema finance_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `finance_db` DEFAULT CHARACTER SET utf8 ;
USE `finance_db` ;

-- -----------------------------------------------------
-- Table `finance_db`.`PROVIDER_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`PROVIDER_MAS` (
  `PRV_ID` INT NOT NULL AUTO_INCREMENT,
  `PRV_NM` VARCHAR(45) NOT NULL,
  `PRV_DESC` VARCHAR(45) NULL,
  PRIMARY KEY (`PRV_ID`, `PRV_NM`),
  UNIQUE INDEX `PRV_NM_UNIQUE` (`PRV_NM` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`REGION_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`REGION_MAS` (
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `RGN_NM` VARCHAR(100) NOT NULL,
  `SUB_RGN_NM` VARCHAR(70) NOT NULL,
  `RGN_DESC` VARCHAR(100) NULL,
  PRIMARY KEY (`RGN_CD`, `SUB_RGN_CD`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CURRENCY_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CURRENCY_MAS` (
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CUR_NB` INT NOT NULL,
  `CUR_NM` VARCHAR(100) NOT NULL,
  `DECIMAL_PLACE` INT NULL,
  PRIMARY KEY (`CUR_CD`, `CUR_NB`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`COUNTRY_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`COUNTRY_MAS` (
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL COMMENT 'ISO 3166-1 alpha-2\n',
  `CTRY_NB` INT NOT NULL COMMENT 'ISO 3166-1 numeric\n',
  `CTRY_CD3` VARCHAR(5) NOT NULL COMMENT 'ISO 3166-1 alpha-3\n',
  `CTRY_NM` VARCHAR(100) NOT NULL,
  `CTRY_DESC` VARCHAR(100) NULL,
  `INTERM_RGN_CD` VARCHAR(5) NULL,
  `INTERM_RGN_NM` VARCHAR(70) NULL,
  PRIMARY KEY (`RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`),
  INDEX `fk_COUNTRY_MAS_CURRENCY_MAS1_idx` (`CUR_CD` ASC),
  INDEX `fk_COUNTRY_MAS_REGION_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC),
  CONSTRAINT `fk_COUNTRY_MAS_CURRENCY_MAS1`
    FOREIGN KEY (`CUR_CD`)
    REFERENCES `finance_db`.`CURRENCY_MAS` (`CUR_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_COUNTRY_MAS_REGION_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD`)
    REFERENCES `finance_db`.`REGION_MAS` (`RGN_CD` , `SUB_RGN_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`EXCHANGE_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`EXCHANGE_MAS` (
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL COMMENT 'MIC(Market Identifier Code)\n\n',
  `EXG_NM` VARCHAR(150) NOT NULL,
  `EXG_OP_CD` VARCHAR(45) NOT NULL,
  `EXG_ACRONYM` VARCHAR(45) NULL,
  `OPEN_TIME` VARCHAR(45) NULL,
  `CLOSE_TIME` VARCHAR(45) NULL,
  `EXG_CITY` VARCHAR(70) NULL,
  `EXG_DESC` VARCHAR(500) NULL,
  `EXG_URL` VARCHAR(150) NULL,
  PRIMARY KEY (`RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`),
  INDEX `fk_EXCHANGE_MAS_COUNTRY_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC),
  CONSTRAINT `fk_EXCHANGE_MAS_COUNTRY_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    REFERENCES `finance_db`.`COUNTRY_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ORGANIZATION_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ORGANIZATION_MAS` (
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `ORG_CD` VARCHAR(45) NOT NULL,
  `ORG_NM` VARCHAR(100) NOT NULL,
  `ORG_DESC` VARCHAR(100) NULL,
  PRIMARY KEY (`RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `ORG_CD`, `ORG_NM`),
  INDEX `fk_PUBLISHER_MAS_COUNTRY_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC),
  CONSTRAINT `fk_PUBLISHER_MAS_COUNTRY_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    REFERENCES `finance_db`.`COUNTRY_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CLASS_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CLASS_MAS` (
  `CLS_CD` VARCHAR(45) NOT NULL,
  `CLS_NM` VARCHAR(70) NOT NULL,
  `DATA_TYP` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CLS_CD`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`COMMODITY_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`COMMODITY_MAS` (
  `CMT_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL,
  `CMT_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `CMT_DESC` VARCHAR(100) NULL,
  `UPDATE_FREQ` VARCHAR(45) NULL,
  PRIMARY KEY (`CMT_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`, `CMT_NM`),
  INDEX `fk_COMMODITY_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  INDEX `fk_COMMODITY_MAS_EXCHANGE_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC, `EXG_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_COMMODITY_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_COMMODITY_MAS_EXCHANGE_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD`)
    REFERENCES `finance_db`.`EXCHANGE_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`STOCKINDEX_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`STOCKINDEX_MAS` (
  `STX_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL,
  `STX_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `STX_DESC` VARCHAR(100) NULL,
  `UPDATE_FREQ` VARCHAR(45) NULL,
  PRIMARY KEY (`STX_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`, `STX_NM`),
  INDEX `fk_STOCK_INDEX_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  INDEX `fk_STOCKINDEX_MAS_EXCHANGE_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC, `EXG_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_STOCK_INDEX_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_STOCKINDEX_MAS_EXCHANGE_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD`)
    REFERENCES `finance_db`.`EXCHANGE_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`DERIVATIVE_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`DERIVATIVE_MAS` (
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL,
  `DRV_TYP` VARCHAR(45) NOT NULL,
  `UASSET_CD` VARCHAR(45) NOT NULL,
  `DRV_NM` VARCHAR(100) NOT NULL,
  `DRV_DESC` VARCHAR(100) NULL,
  PRIMARY KEY (`CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`, `DRV_TYP`, `UASSET_CD`),
  INDEX `fk_DERIVATIVE_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  INDEX `fk_DERIVATIVE_MAS_EXCHANGE_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC, `EXG_CD` ASC),
  CONSTRAINT `fk_DERIVATIVE_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DERIVATIVE_MAS_EXCHANGE_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD`)
    REFERENCES `finance_db`.`EXCHANGE_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`FUTURE_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`FUTURE_MAS` (
  `FTR_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL,
  `DRV_TYP` VARCHAR(45) NOT NULL,
  `UASSET_CD` VARCHAR(45) NOT NULL,
  `MATURITY` VARCHAR(45) NOT NULL,
  `FTR_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `FTR_DESC` VARCHAR(100) NULL,
  `UPDATE_FREQ` VARCHAR(45) NULL,
  PRIMARY KEY (`FTR_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`, `DRV_TYP`, `UASSET_CD`, `MATURITY`, `FTR_NM`),
  INDEX `fk_FUTURE_MAS_DERIVATIVE_MAS2_idx` (`CLS_CD` ASC, `RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC, `EXG_CD` ASC, `DRV_TYP` ASC, `UASSET_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_FUTURE_MAS_DERIVATIVE_MAS2`
    FOREIGN KEY (`CLS_CD` , `RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD` , `DRV_TYP` , `UASSET_CD`)
    REFERENCES `finance_db`.`DERIVATIVE_MAS` (`CLS_CD` , `RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD` , `DRV_TYP` , `UASSET_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`OPTION_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`OPTION_MAS` (
  `OPT_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL,
  `DRV_TYP` VARCHAR(45) NOT NULL,
  `UASSET_CD` VARCHAR(45) NOT NULL,
  `OPT_TYP` VARCHAR(45) NOT NULL,
  `OPT_STY` VARCHAR(45) NOT NULL,
  `MATURITY` VARCHAR(45) NOT NULL,
  `OPT_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `OPT_DESC` VARCHAR(100) NULL,
  `UPDATE_FREQ` VARCHAR(45) NULL,
  PRIMARY KEY (`OPT_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`, `DRV_TYP`, `UASSET_CD`, `OPT_TYP`, `OPT_STY`, `MATURITY`, `OPT_NM`),
  INDEX `fk_OPTION_MAS_DERIVATIVE_MAS1_idx` (`CLS_CD` ASC, `RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC, `EXG_CD` ASC, `DRV_TYP` ASC, `UASSET_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_OPTION_MAS_DERIVATIVE_MAS1`
    FOREIGN KEY (`CLS_CD` , `RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD` , `DRV_TYP` , `UASSET_CD`)
    REFERENCES `finance_db`.`DERIVATIVE_MAS` (`CLS_CD` , `RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD` , `DRV_TYP` , `UASSET_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SWAP_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SWAP_MAS` (
  `SWP_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `EXG_CD` VARCHAR(45) NOT NULL,
  `DRV_TYP` VARCHAR(45) NOT NULL,
  `UASSET_CD` VARCHAR(45) NOT NULL,
  `SWP_TYP` VARCHAR(45) NOT NULL,
  `ASSET_BRW` VARCHAR(45) NOT NULL,
  `ASSET_RTN` VARCHAR(45) NOT NULL,
  `MATURITY` VARCHAR(45) NOT NULL,
  `SWP_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `SWP_DESC` VARCHAR(100) NULL,
  `UPDATE_FREQ` VARCHAR(45) NULL,
  PRIMARY KEY (`SWP_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `EXG_CD`, `DRV_TYP`, `UASSET_CD`, `SWP_TYP`, `ASSET_BRW`, `ASSET_RTN`, `MATURITY`, `SWP_NM`),
  INDEX `fk_SWAP_MAS_DERIVATIVE_MAS1_idx` (`CLS_CD` ASC, `RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC, `EXG_CD` ASC, `DRV_TYP` ASC, `UASSET_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_SWAP_MAS_DERIVATIVE_MAS1`
    FOREIGN KEY (`CLS_CD` , `RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD` , `DRV_TYP` , `UASSET_CD`)
    REFERENCES `finance_db`.`DERIVATIVE_MAS` (`CLS_CD` , `RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3` , `EXG_CD` , `DRV_TYP` , `UASSET_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`STATISTICS_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`STATISTICS_MAS` (
  `STT_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `STT_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `STT_DESC` VARCHAR(100) NULL,
  `UPDATE_FREQ` VARCHAR(45) NULL,
  PRIMARY KEY (`STT_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `STT_NM`),
  INDEX `fk_STATISTICS_MAS_COUNTRY_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC),
  INDEX `fk_STATISTICS_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_STATISTICS_MAS_COUNTRY_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    REFERENCES `finance_db`.`COUNTRY_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_STATISTICS_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ECONOMICALINDEX_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ECONOMICALINDEX_MAS` (
  `ECX_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `ECX_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `ECX_DESC` VARCHAR(100) NULL,
  PRIMARY KEY (`ECX_ID`, `CLS_CD`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `ECX_NM`),
  INDEX `fk_ECONOMICALINDEX_MAS_COUNTRY_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC),
  INDEX `fk_ECONOMICALINDEX_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_ECONOMICALINDEX_MAS_COUNTRY_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    REFERENCES `finance_db`.`COUNTRY_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ECONOMICALINDEX_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_MAS` (
  `GBD_ID` INT NOT NULL AUTO_INCREMENT,
  `RGN_CD` VARCHAR(45) NOT NULL,
  `SUB_RGN_CD` VARCHAR(5) NOT NULL,
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CTRY_CD` VARCHAR(5) NOT NULL,
  `CTRY_NB` INT NOT NULL,
  `CTRY_CD3` VARCHAR(5) NOT NULL,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `MATURITY` VARCHAR(45) NOT NULL,
  `GBD_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `GBD_DESC` VARCHAR(100) NULL,
  PRIMARY KEY (`GBD_ID`, `RGN_CD`, `SUB_RGN_CD`, `CUR_CD`, `CTRY_CD`, `CTRY_NB`, `CTRY_CD3`, `CLS_CD`, `MATURITY`, `GBD_NM`),
  INDEX `fk_GOVBOND_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  INDEX `fk_GOVBOND_MAS_COUNTRY_MAS1_idx` (`RGN_CD` ASC, `SUB_RGN_CD` ASC, `CUR_CD` ASC, `CTRY_CD` ASC, `CTRY_NB` ASC, `CTRY_CD3` ASC),
  CONSTRAINT `fk_GOVBOND_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_GOVBOND_MAS_COUNTRY_MAS1`
    FOREIGN KEY (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    REFERENCES `finance_db`.`COUNTRY_MAS` (`RGN_CD` , `SUB_RGN_CD` , `CUR_CD` , `CTRY_CD` , `CTRY_NB` , `CTRY_CD3`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`INTEREST_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`INTEREST_MAS` (
  `ITR_ID` INT NOT NULL AUTO_INCREMENT,
  `CUR_CD` VARCHAR(45) NOT NULL,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `ITR_NM` VARCHAR(100) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `ITR_DESC` VARCHAR(100) NULL,
  PRIMARY KEY (`ITR_ID`, `CUR_CD`, `CLS_CD`, `ITR_NM`),
  INDEX `fk_INTEREST_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  INDEX `fk_INTEREST_MAS_CURRENCY_MAS1_idx` (`CUR_CD` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_INTEREST_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_INTEREST_MAS_CURRENCY_MAS1`
    FOREIGN KEY (`CUR_CD`)
    REFERENCES `finance_db`.`CURRENCY_MAS` (`CUR_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`STOCKINDEX_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`STOCKINDEX_HIS` (
  `STX_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STX_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CURRENCY_ER_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CURRENCY_ER_HIS` (
  `CUR_CD` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `ER_VAL` DECIMAL NULL,
  PRIMARY KEY (`CUR_CD`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`INTEREST_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`INTEREST_HIS` (
  `ITR_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `ITR_VAL` DECIMAL NULL,
  PRIMARY KEY (`ITR_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ECONOMICALINDEX_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ECONOMICALINDEX_HIS` (
  `ECX_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `ECX_VAL` DECIMAL NULL,
  PRIMARY KEY (`ECX_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`COMMODITY_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`COMMODITY_HIS` (
  `CMDT_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `PRICE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`CMDT_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`STATISTICS_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`STATISTICS_HIS` (
  `STAT_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `STAT_VAL` DECIMAL NULL,
  PRIMARY KEY (`STAT_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_HIS` (
  `GBND_ID` INT NOT NULL,
  `STD_DT` DATETIME NULL,
  `YIELD_VAL` VARCHAR(45) NULL,
  PRIMARY KEY (`GBND_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`KOSPI_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`KOSPI_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`KOSDAQ_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`KOSDAQ_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`NYSE_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`NYSE_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`NASDAQ_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`NASDAQ_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`DJ30_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`DJ30_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SP500_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SP500_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`OPTION_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`OPTION_HIS` (
  `OPT_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `OPT_VAL` DECIMAL NULL,
  PRIMARY KEY (`OPT_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`FUTURE_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`FUTURE_HIS` (
  `FTR_ID` INT NOT NULL,
  `STD_DT` DATETIME NULL,
  `PRICE_VAL` VARCHAR(45) NULL,
  `VOLUMNE_VAL` VARCHAR(45) NULL,
  PRIMARY KEY (`FTR_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SWAP_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SWAP_HIS` (
  `SWP_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `SWP_VAL` DECIMAL NULL,
  PRIMARY KEY (`SWP_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`RUSSELL2000_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`RUSSELL2000_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`NIKKEI_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`NIKKEI_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SHENZHEN_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SHENZHEN_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SHANGHAI_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SHANGHAI_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`HANGSENG_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`HANGSENG_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`EUSTOXX50_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`EUSTOXX50_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`EURONEXT100_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`EURONEXT100_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`DAX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`DAX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`FTSE100_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`FTSE100_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CAC40_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CAC40_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`BEL20_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`BEL20_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`AEX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`AEX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`IBEX35_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`IBEX35_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`MICEX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`MICEX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`TSEC_WEIGHTED_INDEX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`TSEC_WEIGHTED_INDEX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`STI_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`STI_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SENSEX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SENSEX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`BOVESPA_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`BOVESPA_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`KRW_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`KRW_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`JPY_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`JPY_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`EUR_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`EUR_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CNY_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CNY_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`HKD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`HKD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SGD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SGD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`TWD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`TWD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`INR_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`INR_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GBP_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GBP_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`RUB_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`RUB_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `EXC_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`VIX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`VIX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`USLS_SPREAD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`USLS_SPREAD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `SPREAD_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`TED_SPREAD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`TED_SPREAD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `SPREAD_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`US_HY_CORPBOND_INDEX_SPREAD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`US_HY_CORPBOND_INDEX_SPREAD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `SPREAD_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CDSD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CDSD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `SPREAD_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ISM_PMI_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ISM_PMI_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `INDEX_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`CAIXIN_PMI_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`CAIXIN_PMI_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `INDEX_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`COMEX_GOLD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`COMEX_GOLD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `LAST_VAL` DECIMAL NULL,
  `CHANGE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`LBMA_GOLD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`LBMA_GOLD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `USDAM_VAL` DECIMAL NULL,
  `USDPM_VAL` DECIMAL NULL,
  `GBPAM_VAL` DECIMAL NULL,
  `GBPPM_VAL` DECIMAL NULL,
  `EUROAM_VAL` DECIMAL NULL,
  `EUROPM_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`WB_GOLD_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`WB_GOLD_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `PRICE_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`COMEX_SILVER_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`COMEX_SILVER_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `LAST_VAL` DECIMAL NULL,
  `CHANGE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`LME_STEEL_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`LME_STEEL_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `CASH_BUYER_VAL` DECIMAL NULL,
  `CASH_SELLER_SETTLEMENT_VAL` DECIMAL NULL,
  `M3_BUYER_VAL` DECIMAL NULL,
  `M3_SELLER_VAL` DECIMAL NULL,
  `M15_BUYER_VAL` DECIMAL NULL,
  `M15_SELLER_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SH_STEEL_REBAR_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SH_STEEL_REBAR_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `PRESETTLE_VAL` DECIMAL NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `CH1_VAL` DECIMAL NULL,
  `CH2_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`LME_COPPER_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`LME_COPPER_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `CASH_BUYER_VAL` DECIMAL NULL,
  `CASH_SELLER_SETTLEMENT_VAL` DECIMAL NULL,
  `M3_BUYER_VAL` DECIMAL NULL,
  `M3_SELLER_VAL` DECIMAL NULL,
  `M15_BUYER_VAL` DECIMAL NULL,
  `M15_SELLER_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`COMEX_COPPER_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`COMEX_COPPER_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `LAST_VAL` DECIMAL NULL,
  `CHANGE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SH_COPPER_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SH_COPPER_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `PRESETTLE_VAL` DECIMAL NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `CH1_VAL` DECIMAL NULL,
  `CH2_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`LME_ALUMINIUM_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`LME_ALUMINIUM_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `CASH_BUYER_VAL` DECIMAL NULL,
  `CASH_SELLER_SETTLEMENT_VAL` DECIMAL NULL,
  `M3_BUYER_VAL` DECIMAL NULL,
  `M3_SELLER_VAL` DECIMAL NULL,
  `M15_BUYER_VAL` DECIMAL NULL,
  `M15_SELLER_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SH_ALUMINIUM_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SH_ALUMINIUM_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `PRESETTLE_VAL` DECIMAL NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `CH1_VAL` DECIMAL NULL,
  `CH2_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`LME_ZINC_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`LME_ZINC_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `CASH_BUYER_VAL` DECIMAL NULL,
  `CASH_SELLER_SETTLEMENT_VAL` DECIMAL NULL,
  `M3_BUYER_VAL` DECIMAL NULL,
  `M3_SELLER_VAL` DECIMAL NULL,
  `M15_BUYER_VAL` DECIMAL NULL,
  `M15_SELLER_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`SH_ZINC_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`SH_ZINC_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `PRESETTLE_VAL` DECIMAL NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `CLOSE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `CH1_VAL` DECIMAL NULL,
  `CH2_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`VIX_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`VIX_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`BRENT_CRUDE_OIL_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`BRENT_CRUDE_OIL_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`DUBAI_CRUDE_OIL_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`DUBAI_CRUDE_OIL_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`OPEC_REF_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`OPEC_REF_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`US_PREMIUM_CONVGAS_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`US_PREMIUM_CONVGAS_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`US_REGULAR_CONVGAS_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`US_REGULAR_CONVGAS_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`US_ALLGRADES_CONVGAS_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`US_ALLGRADES_CONVGAS_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`HENRYHUB_NGAS_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`HENRYHUB_NGAS_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`HENRYHUB_NGAS_LA_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`HENRYHUB_NGAS_LA_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`NYMEX_HENRYHUB_NGAS_FUTURE_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`NYMEX_HENRYHUB_NGAS_FUTURE_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `LAST_VAL` DECIMAL NULL,
  `CHANGE_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ICE_UK_NGAS_FUTURE_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ICE_UK_NGAS_FUTURE_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `CHANGE_VAL` DECIMAL NULL,
  `WAVE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  `EFP_VOLUME_VAL` DECIMAL NULL,
  `EFS_VOLUME_VAL` DECIMAL NULL,
  `BLOCK_VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`DE_NGAS_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`DE_NGAS_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`JP_NGAS_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`JP_NGAS_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ITEM_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ITEM_MAS` (
  `ITEM_ID` INT NOT NULL AUTO_INCREMENT,
  `CLS_CD` VARCHAR(45) NOT NULL,
  `PRV_ID` INT NOT NULL,
  `PRV_NM` VARCHAR(45) NOT NULL,
  `ITEM_CD` VARCHAR(45) NOT NULL,
  `ITEM_NM` VARCHAR(100) NOT NULL,
  `ITEM_DESC` VARCHAR(45) NULL,
  `ITEM_UNIT` VARCHAR(45) NULL,
  `USE_YN` CHAR(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`ITEM_ID`, `CLS_CD`, `PRV_ID`, `PRV_NM`, `ITEM_CD`, `ITEM_NM`),
  INDEX `fk_ITEM_MAS_PROVIDER_MAS1_idx` (`PRV_ID` ASC, `PRV_NM` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  INDEX `fk_ITEM_MAS_CLASS_MAS1_idx` (`CLS_CD` ASC),
  CONSTRAINT `fk_ITEM_MAS_PROVIDER_MAS1`
    FOREIGN KEY (`PRV_ID` , `PRV_NM`)
    REFERENCES `finance_db`.`PROVIDER_MAS` (`PRV_ID` , `PRV_NM`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ITEM_MAS_CLASS_MAS1`
    FOREIGN KEY (`CLS_CD`)
    REFERENCES `finance_db`.`CLASS_MAS` (`CLS_CD`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_YIELD_KR_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_YIELD_KR_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `M3` DECIMAL NULL,
  `M6` DECIMAL NULL,
  `Y1` DECIMAL NULL,
  `Y2` DECIMAL NULL,
  `Y3` DECIMAL NULL,
  `Y5` DECIMAL NULL,
  `Y10` DECIMAL NULL,
  `Y20` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_YIELD_US_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_YIELD_US_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `M1` DECIMAL NULL,
  `M3` DECIMAL NULL,
  `M6` DECIMAL NULL,
  `Y1` DECIMAL NULL,
  `Y2` DECIMAL NULL,
  `Y3` DECIMAL NULL,
  `Y5` DECIMAL NULL,
  `Y7` DECIMAL NULL,
  `Y10` DECIMAL NULL,
  `Y20` DECIMAL NULL,
  `Y30` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_YIELD_JP_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_YIELD_JP_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `Y1` DECIMAL NULL,
  `Y2` DECIMAL NULL,
  `Y3` DECIMAL NULL,
  `Y4` DECIMAL NULL,
  `Y5` DECIMAL NULL,
  `Y6` DECIMAL NULL,
  `Y7` DECIMAL NULL,
  `Y8` DECIMAL NULL,
  `Y9` DECIMAL NULL,
  `Y10` DECIMAL NULL,
  `Y15` DECIMAL NULL,
  `Y20` DECIMAL NULL,
  `Y25` DECIMAL NULL,
  `Y30` DECIMAL NULL,
  `Y40` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_YIELD_CN_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_YIELD_CN_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `Y1` DECIMAL NULL,
  `Y2` DECIMAL NULL,
  `Y3` DECIMAL NULL,
  `Y4` DECIMAL NULL,
  `Y5` DECIMAL NULL,
  `Y6` DECIMAL NULL,
  `Y7` DECIMAL NULL,
  `Y10` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`GOVBOND_YIELD_DE_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`GOVBOND_YIELD_DE_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `M6` DECIMAL NULL,
  `Y1` DECIMAL NULL,
  `Y2` DECIMAL NULL,
  `Y3` DECIMAL NULL,
  `Y4` DECIMAL NULL,
  `Y5` DECIMAL NULL,
  `Y6` DECIMAL NULL,
  `Y7` DECIMAL NULL,
  `Y8` DECIMAL NULL,
  `Y9` DECIMAL NULL,
  `Y10` DECIMAL NULL,
  `Y11` DECIMAL NULL,
  `Y12` DECIMAL NULL,
  `Y13` DECIMAL NULL,
  `Y14` DECIMAL NULL,
  `Y15` DECIMAL NULL,
  `Y16` DECIMAL NULL,
  `Y17` DECIMAL NULL,
  `Y18` DECIMAL NULL,
  `Y19` DECIMAL NULL,
  `Y20` DECIMAL NULL,
  `Y21` DECIMAL NULL,
  `Y22` DECIMAL NULL,
  `Y23` DECIMAL NULL,
  `Y24` DECIMAL NULL,
  `Y25` DECIMAL NULL,
  `Y26` DECIMAL NULL,
  `Y27` DECIMAL NULL,
  `Y28` DECIMAL NULL,
  `Y29` DECIMAL NULL,
  `Y30` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ODA_COFFEE_ARABICA_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ODA_COFFEE_ARABICA_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ODA_COFFEE_ROBUSTA_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ODA_COFFEE_ROBUSTA_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `VALUE` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`ICE_COFFEE_FUTURE_RAW`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`ICE_COFFEE_FUTURE_RAW` (
  `STD_DT` DATETIME NOT NULL,
  `OPEN_VAL` DECIMAL NULL,
  `HIGH_VAL` DECIMAL NULL,
  `LOW_VAL` DECIMAL NULL,
  `SETTLE_VAL` DECIMAL NULL,
  `CHANGE_VAL` DECIMAL NULL,
  `WAVE_VAL` DECIMAL NULL,
  `VOLUME_VAL` DECIMAL NULL,
  `PREV_DAY_OPEN_INTEREST_VAL` DECIMAL NULL,
  `EFP_VOLUME_VAL` DECIMAL NULL,
  `EFS_VOLUME_VAL` DECIMAL NULL,
  `BLOCK_VOLUME_VAL` DECIMAL NULL,
  PRIMARY KEY (`STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`FX_HIS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`FX_HIS` (
  `FX_ID` INT NOT NULL,
  `STD_DT` DATETIME NOT NULL,
  `FX_VAL` DECIMAL NULL,
  PRIMARY KEY (`FX_ID`, `STD_DT`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `finance_db`.`FX_MAS`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `finance_db`.`FX_MAS` (
  `CUR_CD` VARCHAR(5) NOT NULL,
  `CUR_NB` INT NOT NULL,
  `FX_BASE` VARCHAR(45) NOT NULL,
  `ITEM_ID` VARCHAR(45) NOT NULL,
  `FX_DESC` VARCHAR(45) NULL,
  PRIMARY KEY (`CUR_CD`, `CUR_NB`, `FX_BASE`),
  INDEX `fk_table1_CURRENCY_MAS1_idx` (`CUR_CD` ASC, `CUR_NB` ASC),
  UNIQUE INDEX `ITEM_ID_UNIQUE` (`ITEM_ID` ASC),
  CONSTRAINT `fk_table1_CURRENCY_MAS1`
    FOREIGN KEY (`CUR_CD` , `CUR_NB`)
    REFERENCES `finance_db`.`CURRENCY_MAS` (`CUR_CD` , `CUR_NB`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
