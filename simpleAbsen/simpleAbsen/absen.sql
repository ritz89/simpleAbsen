-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema absen
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema absen
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `absen` DEFAULT CHARACTER SET utf8 ;
USE `absen` ;

-- -----------------------------------------------------
-- Table `absen`.`Kelas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`Kelas` (
  `id` INT NOT NULL,
  `Prodi` VARCHAR(45) NULL,
  `Angkatan` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`Mahasiswas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`Mahasiswas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `NIM` VARCHAR(45) NULL,
  `Nama` VARCHAR(45) NULL,
  `digisign` LONGTEXT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `NIM_UNIQUE` (`NIM` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`mata_kuliah`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`mata_kuliah` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `kode_mk` VARCHAR(45) NULL,
  `nama_mk` VARCHAR(45) NULL,
  `mata_kuliahcol` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`classroom`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`classroom` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `Nama` VARCHAR(45) NULL,
  `Gedung` VARCHAR(45) NULL,
  `Kampus` VARCHAR(45) NULL,
  `Kapasitas` INT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`Periode`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`Periode` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `tahun_ajar` VARCHAR(45) NULL,
  `semester` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`Session`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`Session` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `jam_awal` VARCHAR(45) NULL,
  `jam_akhir` VARCHAR(45) NULL,
  `kode_sesi` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`Jadwal`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`Jadwal` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `classroom_id` INT NOT NULL,
  `Periode_id` INT NOT NULL,
  `Session_id` INT NOT NULL,
  `jadwal` DATETIME NULL,
  PRIMARY KEY (`id`, `classroom_id`, `Periode_id`, `Session_id`),
  INDEX `fk_Jadwal_classroom1_idx` (`classroom_id` ASC) VISIBLE,
  INDEX `fk_Jadwal_Periode1_idx` (`Periode_id` ASC) VISIBLE,
  INDEX `fk_Jadwal_Session1_idx` (`Session_id` ASC) VISIBLE,
  CONSTRAINT `fk_Jadwal_classroom1`
    FOREIGN KEY (`classroom_id`)
    REFERENCES `absen`.`classroom` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Jadwal_Periode1`
    FOREIGN KEY (`Periode_id`)
    REFERENCES `absen`.`Periode` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Jadwal_Session1`
    FOREIGN KEY (`Session_id`)
    REFERENCES `absen`.`Session` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`Mahasiswas_has_Kelas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`Mahasiswas_has_Kelas` (
  `Mahasiswas_id` INT NOT NULL,
  `Kelas_id` INT NOT NULL,
  `mata_kuliah_id` INT NOT NULL,
  `Jadwal_id` INT NOT NULL,
  PRIMARY KEY (`Mahasiswas_id`, `Kelas_id`, `mata_kuliah_id`, `Jadwal_id`),
  INDEX `fk_Mahasiswas_has_Kelas_Kelas1_idx` (`Kelas_id` ASC) VISIBLE,
  INDEX `fk_Mahasiswas_has_Kelas_Mahasiswas_idx` (`Mahasiswas_id` ASC) VISIBLE,
  INDEX `fk_Mahasiswas_has_Kelas_mata_kuliah1_idx` (`mata_kuliah_id` ASC) VISIBLE,
  INDEX `fk_Mahasiswas_has_Kelas_Jadwal1_idx` (`Jadwal_id` ASC) VISIBLE,
  CONSTRAINT `fk_Mahasiswas_has_Kelas_Mahasiswas`
    FOREIGN KEY (`Mahasiswas_id`)
    REFERENCES `absen`.`Mahasiswas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Mahasiswas_has_Kelas_Kelas1`
    FOREIGN KEY (`Kelas_id`)
    REFERENCES `absen`.`Kelas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Mahasiswas_has_Kelas_mata_kuliah1`
    FOREIGN KEY (`mata_kuliah_id`)
    REFERENCES `absen`.`mata_kuliah` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Mahasiswas_has_Kelas_Jadwal1`
    FOREIGN KEY (`Jadwal_id`)
    REFERENCES `absen`.`Jadwal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`attendance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`attendance` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `Mahasiswas_has_Kelas_Mahasiswas_id` INT NOT NULL,
  `Mahasiswas_has_Kelas_Kelas_id` INT NOT NULL,
  `Mahasiswas_has_Kelas_mata_kuliah_id` INT NOT NULL,
  `Mahasiswas_has_Kelas_Jadwal_id` INT NOT NULL,
  `dtm_attendance` TIMESTAMP NULL,
  `active` TINYINT NULL,
  PRIMARY KEY (`id`, `Mahasiswas_has_Kelas_Mahasiswas_id`, `Mahasiswas_has_Kelas_Kelas_id`, `Mahasiswas_has_Kelas_mata_kuliah_id`, `Mahasiswas_has_Kelas_Jadwal_id`),
  INDEX `fk_attendance_Mahasiswas_has_Kelas1_idx` (`Mahasiswas_has_Kelas_Mahasiswas_id` ASC, `Mahasiswas_has_Kelas_Kelas_id` ASC, `Mahasiswas_has_Kelas_mata_kuliah_id` ASC, `Mahasiswas_has_Kelas_Jadwal_id` ASC) VISIBLE,
  CONSTRAINT `fk_attendance_Mahasiswas_has_Kelas1`
    FOREIGN KEY (`Mahasiswas_has_Kelas_Mahasiswas_id` , `Mahasiswas_has_Kelas_Kelas_id` , `Mahasiswas_has_Kelas_mata_kuliah_id` , `Mahasiswas_has_Kelas_Jadwal_id`)
    REFERENCES `absen`.`Mahasiswas_has_Kelas` (`Mahasiswas_id` , `Kelas_id` , `mata_kuliah_id` , `Jadwal_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `absen`.`perijinan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `absen`.`perijinan` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `reason` VARCHAR(45) NULL,
  `Mahasiswas_has_Kelas_Mahasiswas_id` INT NOT NULL,
  `Mahasiswas_has_Kelas_Kelas_id` INT NOT NULL,
  `Mahasiswas_has_Kelas_mata_kuliah_id` INT NOT NULL,
  `Mahasiswas_has_Kelas_Jadwal_id` INT NOT NULL,
  PRIMARY KEY (`id`, `Mahasiswas_has_Kelas_Mahasiswas_id`, `Mahasiswas_has_Kelas_Kelas_id`, `Mahasiswas_has_Kelas_mata_kuliah_id`, `Mahasiswas_has_Kelas_Jadwal_id`),
  INDEX `fk_perijinan_Mahasiswas_has_Kelas1_idx` (`Mahasiswas_has_Kelas_Mahasiswas_id` ASC, `Mahasiswas_has_Kelas_Kelas_id` ASC, `Mahasiswas_has_Kelas_mata_kuliah_id` ASC, `Mahasiswas_has_Kelas_Jadwal_id` ASC) VISIBLE,
  CONSTRAINT `fk_perijinan_Mahasiswas_has_Kelas1`
    FOREIGN KEY (`Mahasiswas_has_Kelas_Mahasiswas_id` , `Mahasiswas_has_Kelas_Kelas_id` , `Mahasiswas_has_Kelas_mata_kuliah_id` , `Mahasiswas_has_Kelas_Jadwal_id`)
    REFERENCES `absen`.`Mahasiswas_has_Kelas` (`Mahasiswas_id` , `Kelas_id` , `mata_kuliah_id` , `Jadwal_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
