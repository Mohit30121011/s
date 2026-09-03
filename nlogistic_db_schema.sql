-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: localhost    Database: nlogistic_db
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `nlogistic_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `nlogistic_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `nlogistic_db`;

--
-- Table structure for table `abc_classification_result`
--

DROP TABLE IF EXISTS `abc_classification_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `abc_classification_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `revenue_contribution_pct` decimal(5,2) DEFAULT NULL,
  `cumulative_pct` decimal(5,2) DEFAULT NULL,
  `class` enum('A','B','C') NOT NULL,
  `computed_period` varchar(20) DEFAULT NULL,
  `computed_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `abc_classification_result_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abc_classification_result`
--

LOCK TABLES `abc_classification_result` WRITE;
/*!40000 ALTER TABLE `abc_classification_result` DISABLE KEYS */;
INSERT INTO `abc_classification_result` VALUES (1,1,15.50,15.50,'A','2026-Q3','2026-09-02 17:38:04');
/*!40000 ALTER TABLE `abc_classification_result` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER abc_class_check
BEFORE INSERT ON abc_classification_result
FOR EACH ROW
BEGIN
    IF NEW.cumulative_pct < 0 OR NEW.cumulative_pct > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cumulative percentage must be between 0 and 100';
    ELSEIF NEW.cumulative_pct <= 70.00 THEN
        SET NEW.class = 'A';
    ELSEIF NEW.cumulative_pct <= 90.00 THEN
        SET NEW.class = 'B';
    ELSE
        SET NEW.class = 'C';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER abc_class_check_update
BEFORE UPDATE ON abc_classification_result
FOR EACH ROW
BEGIN
    IF NEW.cumulative_pct < 0 OR NEW.cumulative_pct > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cumulative percentage must be between 0 and 100';
    ELSEIF NEW.cumulative_pct <= 70.00 THEN
        SET NEW.class = 'A';
    ELSEIF NEW.cumulative_pct <= 90.00 THEN
        SET NEW.class = 'B';
    ELSE
        SET NEW.class = 'C';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_name` varchar(100) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`log_id`),
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_entity` (`entity_name`,`entity_id`),
  KEY `idx_audit_action` (`action`),
  CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=142 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,NULL,'COMPANY_REGISTERED','Global Logistics 1',1,NULL,'',NULL,'2026-09-02 17:43:35'),(2,NULL,'COMPANY_REGISTERED','Global Logistics 2',2,NULL,'',NULL,'2026-09-02 17:43:35'),(3,NULL,'COMPANY_REGISTERED','Global Logistics 3',3,NULL,'',NULL,'2026-09-02 17:43:35'),(4,NULL,'COMPANY_REGISTERED','Global Logistics 4',4,NULL,'',NULL,'2026-09-02 17:43:35'),(5,NULL,'COMPANY_REGISTERED','Global Logistics 5',5,NULL,'',NULL,'2026-09-02 17:43:35'),(6,NULL,'COMPANY_REGISTERED','Global Logistics 6',6,NULL,'',NULL,'2026-09-02 17:43:35'),(7,NULL,'COMPANY_REGISTERED','Global Logistics 7',7,NULL,'',NULL,'2026-09-02 17:43:35'),(8,NULL,'COMPANY_REGISTERED','Global Logistics 8',8,NULL,'',NULL,'2026-09-02 17:43:35'),(9,NULL,'COMPANY_REGISTERED','Global Logistics 9',9,NULL,'',NULL,'2026-09-02 17:43:35'),(10,NULL,'COMPANY_REGISTERED','Global Logistics 10',10,NULL,'',NULL,'2026-09-02 17:43:35'),(11,NULL,'COMPANY_REGISTERED','Global Logistics 11',11,NULL,'',NULL,'2026-09-02 17:43:35'),(12,NULL,'COMPANY_REGISTERED','Global Logistics 12',12,NULL,'',NULL,'2026-09-02 17:43:35'),(13,NULL,'COMPANY_REGISTERED','Global Logistics 13',13,NULL,'',NULL,'2026-09-02 17:43:35'),(14,NULL,'COMPANY_REGISTERED','Global Logistics 14',14,NULL,'',NULL,'2026-09-02 17:43:35'),(15,NULL,'COMPANY_REGISTERED','Global Logistics 15',15,NULL,'',NULL,'2026-09-02 17:43:35'),(16,NULL,'COMPANY_REGISTERED','Global Logistics 16',16,NULL,'',NULL,'2026-09-02 17:43:35'),(17,NULL,'COMPANY_REGISTERED','Global Logistics 17',17,NULL,'',NULL,'2026-09-02 17:43:35'),(18,NULL,'COMPANY_REGISTERED','Global Logistics 18',18,NULL,'',NULL,'2026-09-02 17:43:35'),(19,NULL,'COMPANY_REGISTERED','Global Logistics 19',19,NULL,'',NULL,'2026-09-02 17:43:35'),(20,NULL,'COMPANY_REGISTERED','Global Logistics 20',20,NULL,'',NULL,'2026-09-02 17:43:35'),(21,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 17:46:42'),(22,2,'LOGIN_FAILED','jdoe',2,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 18:48:43'),(23,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 18:49:25'),(24,1,'LOGIN_FAILED','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 19:02:46'),(25,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 19:02:58'),(26,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 19:10:28'),(27,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 19:16:39'),(28,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 19:16:43'),(29,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 19:20:05'),(30,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 22:04:37'),(31,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 22:29:21'),(32,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 22:36:05'),(33,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 22:40:57'),(34,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 22:49:24'),(35,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 22:50:30'),(36,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:14:36'),(37,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:36:04'),(38,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:40:35'),(39,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:46:33'),(40,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:46:51'),(41,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:47:00'),(42,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:47:07'),(43,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:47:19'),(44,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:47:37'),(45,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:47:48'),(46,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:48:03'),(47,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:48:41'),(48,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-02 23:59:20'),(49,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 00:20:27'),(50,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 00:46:20'),(51,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 00:55:29'),(52,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 01:15:51'),(53,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:03:52'),(54,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:05:29'),(55,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:21:28'),(56,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:23:11'),(57,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:23:40'),(58,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:24:26'),(59,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:25:06'),(60,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:25:59'),(61,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:27:00'),(62,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:29:49'),(63,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:35:02'),(64,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:35:18'),(65,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:43:44'),(66,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:50:16'),(67,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 02:52:58'),(68,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:02:50'),(69,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:03:00'),(70,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:06:00'),(71,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:18:43'),(72,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:23:59'),(73,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:37:57'),(74,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:41:18'),(75,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 03:45:42'),(76,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:00:31'),(77,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:11:47'),(78,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:28:53'),(79,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:37:04'),(80,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:37:39'),(81,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:37:49'),(82,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:37:58'),(83,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 04:38:46'),(84,1,'LOGIN_FAILED','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:02:38'),(85,1,'LOGIN_FAILED','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:02:49'),(86,1,'LOGIN_FAILED','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:02:59'),(87,1,'LOGIN_FAILED','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:03:10'),(88,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:06:02'),(89,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:10:03'),(90,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:14:21'),(91,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:20:50'),(92,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:29:03'),(93,1,'LOGOUT','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:30:18'),(94,2,'LOGIN_SUCCESS','jdoe',2,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:30:27'),(95,2,'LOGOUT','jdoe',2,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:31:14'),(96,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:31:15'),(97,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:31:53'),(98,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:37:43'),(99,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:46:40'),(100,1,'LOGOUT','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:56:15'),(101,NULL,'COMPANY_REGISTERED','qwe',21,NULL,'Pending',NULL,'2026-09-03 13:57:05'),(102,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 13:57:12'),(103,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:01:00'),(104,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:03:11'),(105,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:03:51'),(106,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:09:57'),(107,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:09:57'),(108,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:17:47'),(109,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:23:31'),(110,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:24:01'),(111,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:24:10'),(112,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:40:08'),(113,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:51:07'),(114,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 14:54:15'),(115,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 15:06:13'),(118,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 15:35:15'),(119,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 16:50:17'),(120,1,'LOGOUT','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 16:53:34'),(121,NULL,'COMPANY_REGISTERED','uu',22,NULL,'Pending',NULL,'2026-09-03 16:56:05'),(122,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 16:56:26'),(123,1,'LOGOUT','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 16:58:39'),(124,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 17:00:15'),(125,NULL,'COMPANY_REGISTERED','FastTest Logistics',23,NULL,'Pending',NULL,'2026-09-03 18:26:45'),(129,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 18:29:58'),(130,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 19:07:59'),(131,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 22:06:22'),(132,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 22:13:29'),(133,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 22:21:50'),(134,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 22:26:43'),(135,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 22:40:13'),(136,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 23:22:44'),(137,1,'LOGOUT','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 23:23:26'),(138,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 23:23:56'),(139,1,'LOGOUT','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 23:25:20'),(140,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 23:25:29'),(141,1,'LOGIN_SUCCESS','superadmin',1,NULL,NULL,'0:0:0:0:0:0:0:1','2026-09-03 23:41:43');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `barcode_entries`
--

DROP TABLE IF EXISTS `barcode_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `barcode_entries` (
  `barcode_id` int(11) NOT NULL AUTO_INCREMENT,
  `barcode_value` varchar(100) NOT NULL,
  `barcode_type` enum('Code128','QR') NOT NULL,
  `entity_type` enum('Container','Shipment','Stock','ComplianceDocument','Invoice','Claim') NOT NULL,
  `entity_id` int(11) NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `generated_by` int(11) NOT NULL,
  `generated_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`barcode_id`),
  UNIQUE KEY `barcode_value` (`barcode_value`),
  KEY `generated_by` (`generated_by`),
  KEY `idx_barcode_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `barcode_entries_ibfk_1` FOREIGN KEY (`generated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `barcode_entries`
--

LOCK TABLES `barcode_entries` WRITE;
/*!40000 ALTER TABLE `barcode_entries` DISABLE KEYS */;
INSERT INTO `barcode_entries` VALUES (1,'CON-1-57B063','QR','Container',1,'CLIENT_RENDERED',1,'2026-09-03 13:46:57'),(2,'SHI-2-58AB3D','Code128','Shipment',2,'CLIENT_RENDERED',1,'2026-09-03 13:48:02');
/*!40000 ALTER TABLE `barcode_entries` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER barcode_entries_before_insert_autogen
BEFORE INSERT ON barcode_entries
FOR EACH ROW
BEGIN
    IF NEW.barcode_value IS NULL OR TRIM(NEW.barcode_value) = '' THEN
        SET NEW.barcode_value = CONCAT(NEW.entity_type, '-', NEW.entity_id, '-', UNIX_TIMESTAMP());
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER barcode_entity_validation_ins
BEFORE INSERT ON barcode_entries
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    DECLARE v_exists INT;
    
    
    SELECT COUNT(*) INTO v_count
    FROM barcode_entries
    WHERE entity_type = NEW.entity_type AND entity_id = NEW.entity_id;
    
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Barcode already exists for this entity';
    END IF;
    
    
    SET v_exists = 0;
    IF NEW.entity_type = 'Stock' THEN
        SELECT COUNT(*) INTO v_exists FROM stock WHERE stock_id = NEW.entity_id;
    ELSEIF NEW.entity_type = 'Container' THEN
        SELECT COUNT(*) INTO v_exists FROM containers WHERE container_id = NEW.entity_id;
    ELSEIF NEW.entity_type = 'Shipment' THEN
        SELECT COUNT(*) INTO v_exists FROM shipment WHERE shipment_id = NEW.entity_id;
    ELSEIF NEW.entity_type = 'ComplianceDocument' THEN
        SELECT COUNT(*) INTO v_exists FROM compliance_documents WHERE doc_id = NEW.entity_id;
    ELSEIF NEW.entity_type = 'Invoice' THEN
        SELECT COUNT(*) INTO v_exists FROM billing_invoices WHERE invoice_id = NEW.entity_id;
    ELSEIF NEW.entity_type = 'Claim' THEN
        SELECT COUNT(*) INTO v_exists FROM claims WHERE claim_id = NEW.entity_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid entity_type for barcode';
    END IF;
    
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Referenced entity_id does not exist in the corresponding table';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER barcode_entity_validation_upd
BEFORE UPDATE ON barcode_entries
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    DECLARE v_exists INT;
    
    IF NEW.entity_type <> OLD.entity_type OR NEW.entity_id <> OLD.entity_id THEN
        
        SELECT COUNT(*) INTO v_count
        FROM barcode_entries
        WHERE entity_type = NEW.entity_type AND entity_id = NEW.entity_id;
        
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Barcode already exists for this entity';
        END IF;
        
        
        SET v_exists = 0;
        IF NEW.entity_type = 'Stock' THEN
            SELECT COUNT(*) INTO v_exists FROM stock WHERE stock_id = NEW.entity_id;
        ELSEIF NEW.entity_type = 'Container' THEN
            SELECT COUNT(*) INTO v_exists FROM containers WHERE container_id = NEW.entity_id;
        ELSEIF NEW.entity_type = 'Shipment' THEN
            SELECT COUNT(*) INTO v_exists FROM shipment WHERE shipment_id = NEW.entity_id;
        ELSEIF NEW.entity_type = 'ComplianceDocument' THEN
            SELECT COUNT(*) INTO v_exists FROM compliance_documents WHERE doc_id = NEW.entity_id;
        ELSEIF NEW.entity_type = 'Invoice' THEN
            SELECT COUNT(*) INTO v_exists FROM billing_invoices WHERE invoice_id = NEW.entity_id;
        ELSEIF NEW.entity_type = 'Claim' THEN
            SELECT COUNT(*) INTO v_exists FROM claims WHERE claim_id = NEW.entity_id;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid entity_type for barcode';
        END IF;
        
        IF v_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Referenced entity_id does not exist in the corresponding table';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `barcode_scan_log`
--

DROP TABLE IF EXISTS `barcode_scan_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `barcode_scan_log` (
  `scan_id` int(11) NOT NULL AUTO_INCREMENT,
  `barcode_id` int(11) NOT NULL,
  `scanned_by` int(11) NOT NULL,
  `scanned_at` datetime DEFAULT current_timestamp(),
  `scan_location` varchar(150) DEFAULT NULL,
  `module_context` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`scan_id`),
  KEY `scanned_by` (`scanned_by`),
  KEY `idx_scan_barcode` (`barcode_id`),
  CONSTRAINT `barcode_scan_log_ibfk_1` FOREIGN KEY (`barcode_id`) REFERENCES `barcode_entries` (`barcode_id`),
  CONSTRAINT `barcode_scan_log_ibfk_2` FOREIGN KEY (`scanned_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `barcode_scan_log`
--

LOCK TABLES `barcode_scan_log` WRITE;
/*!40000 ALTER TABLE `barcode_scan_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `barcode_scan_log` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER barcode_scan_context_default
BEFORE INSERT ON barcode_scan_log
FOR EACH ROW
BEGIN
    IF NEW.module_context IS NULL OR TRIM(NEW.module_context) = '' THEN
        SET NEW.module_context = 'General';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `billing_invoices`
--

DROP TABLE IF EXISTS `billing_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `billing_invoices` (
  `invoice_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `shipment_id` int(11) NOT NULL,
  `invoice_date` date NOT NULL,
  `due_date` date DEFAULT NULL,
  `subtotal_amount` decimal(12,2) DEFAULT 0.00,
  `tax_amount` decimal(12,2) DEFAULT 0.00,
  `total_amount` decimal(12,2) DEFAULT 0.00,
  `paid_amount` decimal(12,2) DEFAULT 0.00,
  `payment_status` enum('Unpaid','Partial','Paid','Overdue','Void') DEFAULT 'Unpaid',
  PRIMARY KEY (`invoice_id`),
  KEY `shipment_id` (`shipment_id`),
  KEY `idx_invoices_customer` (`customer_id`),
  KEY `idx_invoices_status` (`payment_status`),
  KEY `idx_invoices_due` (`due_date`),
  CONSTRAINT `billing_invoices_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `billing_invoices_ibfk_2` FOREIGN KEY (`shipment_id`) REFERENCES `shipment` (`shipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `billing_invoices`
--

LOCK TABLES `billing_invoices` WRITE;
/*!40000 ALTER TABLE `billing_invoices` DISABLE KEYS */;
INSERT INTO `billing_invoices` VALUES (1,5,1,'2026-04-01','2026-05-01',9546.22,1060.69,10606.91,0.00,'Overdue'),(2,12,2,'2026-10-16','2026-11-15',12741.53,1415.73,14157.26,0.00,'Partial'),(3,5,3,'2026-08-13','2026-09-12',10625.75,1180.64,11806.39,0.00,'Unpaid'),(4,34,4,'2026-08-22','2026-09-21',2524.36,280.48,2804.84,0.00,'Partial'),(5,33,5,'2026-10-23','2026-11-22',5605.59,622.84,6228.43,0.00,'Partial'),(6,3,6,'2026-07-22','2026-08-21',3855.27,428.36,4283.63,0.00,'Paid'),(7,25,7,'2026-02-02','2026-03-04',2671.26,296.81,2968.07,0.00,'Partial'),(8,24,8,'2026-05-26','2026-06-25',7256.20,806.25,8062.45,0.00,'Unpaid'),(9,9,9,'2026-03-08','2026-04-07',2156.98,239.66,2396.64,0.00,'Overdue'),(10,11,10,'2026-12-01','2026-12-31',6488.15,720.91,7209.06,0.00,'Overdue'),(11,32,11,'2026-04-21','2026-05-21',8758.38,973.15,9731.53,0.00,'Partial'),(12,9,12,'2026-03-13','2026-04-12',13445.95,1494.00,14939.95,0.00,'Partial'),(13,20,13,'2026-12-20','2027-01-19',13027.63,1447.51,14475.14,0.00,'Paid'),(14,28,14,'2026-07-03','2026-08-02',13314.19,1479.36,14793.55,0.00,'Paid'),(15,20,15,'2026-12-10','2027-01-09',3478.81,386.53,3865.34,0.00,'Partial'),(16,33,16,'2026-09-19','2026-10-19',12844.98,1427.22,14272.20,0.00,'Unpaid'),(17,17,17,'2026-04-11','2026-05-11',10438.57,1159.84,11598.41,0.00,'Overdue'),(18,34,18,'2026-08-10','2026-09-09',6858.16,762.02,7620.18,0.00,'Overdue'),(19,23,19,'2026-05-04','2026-06-03',13309.08,1478.79,14787.87,0.00,'Unpaid'),(20,8,20,'2026-11-15','2026-12-15',6400.19,711.13,7111.32,0.00,'Overdue'),(21,6,21,'2026-09-28','2026-10-28',2895.70,321.74,3217.44,0.00,'Overdue'),(22,33,22,'2026-07-25','2026-08-24',6037.73,670.86,6708.59,0.00,'Unpaid'),(23,26,23,'2026-01-18','2026-02-17',1474.69,163.86,1638.55,0.00,'Paid'),(24,2,24,'2026-07-08','2026-08-07',4034.47,448.28,4482.75,0.00,'Unpaid'),(25,1,25,'2026-11-06','2026-12-06',7492.00,832.44,8324.44,0.00,'Partial'),(26,22,26,'2026-08-01','2026-08-31',1475.04,163.89,1638.93,0.00,'Paid'),(27,21,27,'2026-02-25','2026-03-27',3477.39,386.38,3863.77,0.00,'Overdue'),(28,10,28,'2026-06-19','2026-07-19',12296.78,1366.31,13663.09,0.00,'Partial'),(29,2,29,'2026-05-16','2026-06-15',3278.95,364.33,3643.28,0.00,'Partial'),(30,18,30,'2026-10-24','2026-11-23',6166.25,685.14,6851.39,0.00,'Unpaid'),(31,9,31,'2026-01-21','2026-02-20',5195.84,577.32,5773.16,0.00,'Partial'),(32,10,32,'2026-01-03','2026-02-02',11779.22,1308.80,13088.02,0.00,'Overdue'),(33,19,33,'2026-07-11','2026-08-10',1636.89,181.88,1818.77,0.00,'Paid'),(34,11,34,'2026-02-05','2026-03-07',3165.20,351.69,3516.89,0.00,'Partial'),(35,1,35,'2026-10-11','2026-11-10',6962.08,773.57,7735.65,0.00,'Paid'),(36,19,36,'2026-09-17','2026-10-17',10894.85,1210.54,12105.39,0.00,'Partial'),(37,18,37,'2026-11-04','2026-12-04',8394.18,932.69,9326.87,0.00,'Paid'),(38,23,38,'2026-09-22','2026-10-22',8068.21,896.47,8964.68,0.00,'Overdue'),(39,15,39,'2026-11-10','2026-12-10',5693.63,632.63,6326.26,0.00,'Paid'),(40,20,40,'2026-08-01','2026-08-31',2434.85,270.54,2705.39,0.00,'Paid'),(41,12,41,'2026-04-18','2026-05-18',11651.75,1294.64,12946.39,0.00,'Paid'),(42,17,42,'2026-10-16','2026-11-15',4088.37,454.26,4542.63,0.00,'Paid'),(43,13,43,'2026-11-19','2026-12-19',9742.93,1082.55,10825.48,0.00,'Overdue'),(44,17,44,'2026-09-05','2026-10-05',12737.89,1415.32,14153.21,0.00,'Partial'),(45,36,45,'2026-09-17','2026-10-17',5862.47,651.39,6513.86,0.00,'Paid'),(46,8,46,'2026-02-01','2026-03-03',3379.59,375.51,3755.10,0.00,'Paid'),(47,5,47,'2026-11-09','2026-12-09',12458.16,1384.24,13842.40,0.00,'Unpaid'),(48,21,48,'2026-05-12','2026-06-11',5333.36,592.60,5925.96,0.00,'Unpaid'),(49,38,49,'2026-10-25','2026-11-24',13101.50,1455.72,14557.22,0.00,'Overdue'),(50,9,50,'2026-06-13','2026-07-13',7305.70,811.75,8117.45,0.00,'Partial'),(51,34,51,'2026-10-11','2026-11-10',2950.00,327.78,3277.78,0.00,'Overdue'),(52,19,52,'2026-09-06','2026-10-06',9423.59,1047.07,10470.66,0.00,'Overdue'),(53,8,53,'2026-02-03','2026-03-05',10915.60,1212.85,12128.45,0.00,'Partial'),(54,9,54,'2026-12-03','2027-01-02',11953.54,1328.17,13281.71,0.00,'Paid'),(55,32,55,'2026-07-23','2026-08-22',4573.85,508.21,5082.06,0.00,'Partial'),(56,12,56,'2026-04-16','2026-05-16',5414.55,601.62,6016.17,0.00,'Unpaid'),(57,14,57,'2026-05-27','2026-06-26',6648.59,738.73,7387.32,0.00,'Partial'),(58,35,58,'2026-11-22','2026-12-22',4353.93,483.77,4837.70,0.00,'Unpaid'),(59,3,59,'2026-06-27','2026-07-27',4952.39,550.26,5502.65,0.00,'Unpaid'),(60,20,60,'2026-10-04','2026-11-03',4305.55,478.39,4783.94,0.00,'Partial'),(61,28,61,'2026-05-18','2026-06-17',6936.58,770.73,7707.31,0.00,'Paid'),(62,26,62,'2026-09-06','2026-10-06',8578.64,953.18,9531.82,0.00,'Unpaid'),(63,28,63,'2026-07-03','2026-08-02',11281.00,1253.45,12534.45,0.00,'Paid'),(64,11,64,'2026-11-22','2026-12-22',7154.31,794.92,7949.23,0.00,'Overdue'),(65,30,65,'2026-03-21','2026-04-20',7471.47,830.16,8301.63,0.00,'Partial'),(66,3,66,'2026-09-18','2026-10-18',3642.31,404.70,4047.01,0.00,'Paid'),(67,30,67,'2026-10-24','2026-11-23',5322.83,591.43,5914.26,0.00,'Paid'),(68,40,68,'2026-10-24','2026-11-23',12563.78,1395.98,13959.76,0.00,'Paid'),(69,31,69,'2026-05-21','2026-06-20',3466.39,385.16,3851.55,0.00,'Overdue'),(70,25,70,'2026-08-01','2026-08-31',5262.69,584.74,5847.43,0.00,'Unpaid'),(71,2,71,'2026-10-24','2026-11-23',5701.18,633.47,6334.65,0.00,'Partial'),(72,17,72,'2026-08-01','2026-08-31',3219.65,357.74,3577.39,0.00,'Paid'),(73,9,73,'2026-12-20','2027-01-19',4577.71,508.63,5086.34,0.00,'Unpaid'),(74,20,74,'2026-02-02','2026-03-04',11262.44,1251.38,12513.82,0.00,'Paid'),(75,27,75,'2026-09-22','2026-10-22',11128.25,1236.47,12364.72,0.00,'Partial'),(76,30,76,'2026-04-07','2026-05-07',4793.91,532.66,5326.57,0.00,'Overdue'),(77,40,77,'2026-05-23','2026-06-22',3797.63,421.96,4219.59,0.00,'Overdue'),(78,13,78,'2026-04-15','2026-05-15',1807.38,200.82,2008.20,0.00,'Partial'),(79,6,79,'2026-11-18','2026-12-18',8550.12,950.01,9500.13,0.00,'Unpaid'),(80,2,80,'2026-09-19','2026-10-19',5298.75,588.75,5887.50,0.00,'Paid'),(81,40,81,'2026-04-14','2026-05-14',11763.96,1307.11,13071.07,0.00,'Paid'),(82,29,82,'2026-05-01','2026-05-31',5111.61,567.96,5679.57,0.00,'Unpaid'),(83,26,83,'2026-11-09','2026-12-09',9451.17,1050.13,10501.30,0.00,'Unpaid'),(84,3,84,'2026-03-07','2026-04-06',8979.01,997.67,9976.68,0.00,'Unpaid'),(85,27,85,'2026-02-12','2026-03-14',11849.08,1316.57,13165.65,0.00,'Paid'),(86,13,86,'2026-07-17','2026-08-16',9746.69,1082.96,10829.65,0.00,'Unpaid'),(87,3,87,'2026-07-24','2026-08-23',12078.14,1342.02,13420.16,0.00,'Unpaid'),(88,13,88,'2026-05-12','2026-06-11',8269.69,918.85,9188.54,0.00,'Unpaid'),(89,2,89,'2026-10-11','2026-11-10',12134.18,1348.24,13482.42,0.00,'Partial'),(90,26,90,'2026-01-21','2026-02-20',6019.24,668.80,6688.04,0.00,'Partial'),(91,27,91,'2026-12-08','2027-01-07',6457.52,717.50,7175.02,0.00,'Partial'),(92,19,92,'2026-05-25','2026-06-24',10680.15,1186.68,11866.83,0.00,'Overdue'),(93,12,93,'2026-11-03','2026-12-03',12053.31,1339.26,13392.57,0.00,'Overdue'),(94,38,94,'2026-11-14','2026-12-14',8405.61,933.96,9339.57,0.00,'Overdue'),(95,8,95,'2026-10-16','2026-11-15',4331.11,481.23,4812.34,0.00,'Overdue'),(96,4,96,'2026-10-13','2026-11-12',12048.80,1338.76,13387.56,0.00,'Overdue'),(97,3,97,'2026-11-07','2026-12-07',11576.88,1286.32,12863.20,0.00,'Overdue'),(98,19,98,'2026-02-14','2026-03-16',12497.38,1388.60,13885.98,0.00,'Paid'),(99,9,99,'2026-10-05','2026-11-04',8026.25,891.81,8918.06,0.00,'Unpaid'),(100,16,100,'2026-02-21','2026-03-23',6353.95,706.00,7059.95,0.00,'Unpaid'),(101,1,101,'2026-10-25','2026-11-24',10061.30,1117.92,11179.22,0.00,'Partial'),(102,13,102,'2026-05-17','2026-06-16',3142.97,349.22,3492.19,0.00,'Partial'),(103,4,103,'2026-03-05','2026-04-04',13296.24,1477.36,14773.60,0.00,'Unpaid'),(104,13,104,'2026-11-28','2026-12-28',12473.33,1385.93,13859.26,0.00,'Paid'),(105,23,105,'2026-07-22','2026-08-21',3073.48,341.50,3414.98,0.00,'Unpaid'),(106,9,106,'2026-10-23','2026-11-22',6563.41,729.27,7292.68,0.00,'Paid'),(107,36,107,'2026-01-19','2026-02-18',8898.64,988.74,9887.38,0.00,'Overdue'),(108,9,108,'2026-09-18','2026-10-18',8614.48,957.16,9571.64,0.00,'Unpaid'),(109,10,109,'2026-08-10','2026-09-09',3792.11,421.35,4213.46,0.00,'Paid'),(110,32,110,'2026-01-17','2026-02-16',12999.98,1444.44,14444.42,0.00,'Paid'),(111,27,111,'2026-06-21','2026-07-21',11782.76,1309.20,13091.96,0.00,'Overdue'),(112,20,112,'2026-03-18','2026-04-17',9308.60,1034.29,10342.89,0.00,'Overdue'),(113,12,113,'2026-08-05','2026-09-04',13032.58,1448.07,14480.65,0.00,'Paid'),(114,40,114,'2026-07-19','2026-08-18',4147.32,460.81,4608.13,0.00,'Unpaid'),(115,4,115,'2026-08-26','2026-09-25',12481.62,1386.85,13868.47,0.00,'Unpaid'),(116,26,116,'2026-06-23','2026-07-23',9066.22,1007.36,10073.58,0.00,'Paid'),(117,28,117,'2026-02-16','2026-03-18',6803.50,755.95,7559.45,0.00,'Unpaid'),(118,18,118,'2026-04-12','2026-05-12',5473.13,608.13,6081.26,0.00,'Partial'),(119,10,119,'2026-08-03','2026-09-02',11441.37,1271.26,12712.63,0.00,'Paid'),(120,7,120,'2026-12-21','2027-01-20',9882.20,1098.02,10980.22,0.00,'Partial'),(121,18,121,'2026-02-22','2026-03-24',2246.35,249.59,2495.94,0.00,'Paid'),(122,5,122,'2026-12-05','2027-01-04',12351.90,1372.43,13724.33,0.00,'Paid'),(123,34,123,'2026-09-26','2026-10-26',12911.72,1434.64,14346.36,0.00,'Unpaid'),(124,6,124,'2026-10-19','2026-11-18',11546.15,1282.91,12829.06,0.00,'Paid'),(125,39,125,'2026-01-19','2026-02-18',3185.41,353.94,3539.35,0.00,'Overdue'),(126,40,126,'2026-08-27','2026-09-26',9064.92,1007.21,10072.13,0.00,'Partial'),(127,21,127,'2026-12-14','2027-01-13',6685.05,742.78,7427.83,0.00,'Unpaid'),(128,32,128,'2026-01-17','2026-02-16',9455.14,1050.57,10505.71,0.00,'Paid'),(129,40,129,'2026-07-17','2026-08-16',9003.79,1000.42,10004.21,0.00,'Unpaid'),(130,12,130,'2026-02-04','2026-03-06',4377.94,486.44,4864.38,0.00,'Partial'),(131,28,131,'2026-10-17','2026-11-16',7653.30,850.37,8503.67,0.00,'Partial'),(132,12,132,'2026-08-13','2026-09-12',5510.02,612.23,6122.25,0.00,'Overdue'),(133,9,133,'2026-10-15','2026-11-14',11352.48,1261.39,12613.87,0.00,'Paid'),(134,10,134,'2026-04-23','2026-05-23',4720.70,524.52,5245.22,0.00,'Overdue'),(135,14,135,'2026-06-09','2026-07-09',11360.16,1262.24,12622.40,0.00,'Unpaid'),(136,36,136,'2026-12-11','2027-01-10',11856.35,1317.37,13173.72,0.00,'Paid'),(137,28,137,'2026-05-03','2026-06-02',6715.85,746.21,7462.06,0.00,'Paid'),(138,7,138,'2026-02-23','2026-03-25',10497.30,1166.37,11663.67,0.00,'Overdue'),(139,16,139,'2026-11-21','2026-12-21',7481.55,831.28,8312.83,0.00,'Unpaid'),(140,28,140,'2026-06-18','2026-07-18',4235.48,470.61,4706.09,0.00,'Overdue'),(141,37,141,'2026-05-18','2026-06-17',8816.61,979.62,9796.23,0.00,'Unpaid'),(142,1,142,'2026-06-18','2026-07-18',4762.19,529.13,5291.32,0.00,'Unpaid'),(143,29,143,'2026-12-15','2027-01-14',8270.58,918.95,9189.53,0.00,'Partial'),(144,37,144,'2026-10-04','2026-11-03',7650.55,850.06,8500.61,0.00,'Overdue'),(145,28,145,'2026-01-03','2026-02-02',2668.25,296.47,2964.72,0.00,'Unpaid'),(146,20,146,'2026-11-25','2026-12-25',12288.82,1365.42,13654.24,0.00,'Overdue'),(147,6,147,'2026-01-15','2026-02-14',8083.91,898.21,8982.12,0.00,'Overdue'),(148,15,148,'2026-10-13','2026-11-12',12250.66,1361.19,13611.85,0.00,'Unpaid'),(149,4,149,'2026-03-03','2026-04-02',11217.50,1246.39,12463.89,0.00,'Partial'),(150,33,150,'2026-10-06','2026-11-05',6913.84,768.21,7682.05,0.00,'Unpaid'),(152,1,1,'2026-09-03','2026-10-03',15000.00,2700.00,17700.00,0.00,'Unpaid');
/*!40000 ALTER TABLE `billing_invoices` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER invoice_overdue_check
BEFORE UPDATE ON billing_invoices
FOR EACH ROW
BEGIN
    IF NEW.due_date < CURDATE() AND NEW.payment_status IN ('Unpaid','Partial') THEN
        SET NEW.payment_status = 'Overdue';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `claim_documents`
--

DROP TABLE IF EXISTS `claim_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claim_documents` (
  `doc_id` int(11) NOT NULL AUTO_INCREMENT,
  `claim_id` int(11) NOT NULL,
  `doc_type` enum('Photo Evidence','Inspection Report','Other') NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`doc_id`),
  KEY `claim_id` (`claim_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `claim_documents_ibfk_1` FOREIGN KEY (`claim_id`) REFERENCES `claims` (`claim_id`),
  CONSTRAINT `claim_documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claim_documents`
--

LOCK TABLES `claim_documents` WRITE;
/*!40000 ALTER TABLE `claim_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `claim_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claim_status_history`
--

DROP TABLE IF EXISTS `claim_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claim_status_history` (
  `history_id` int(11) NOT NULL AUTO_INCREMENT,
  `claim_id` int(11) NOT NULL,
  `old_status` varchar(30) DEFAULT NULL,
  `new_status` varchar(30) DEFAULT NULL,
  `changed_by` int(11) NOT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`history_id`),
  KEY `claim_id` (`claim_id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `claim_status_history_ibfk_1` FOREIGN KEY (`claim_id`) REFERENCES `claims` (`claim_id`),
  CONSTRAINT `claim_status_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claim_status_history`
--

LOCK TABLES `claim_status_history` WRITE;
/*!40000 ALTER TABLE `claim_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `claim_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claims`
--

DROP TABLE IF EXISTS `claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claims` (
  `claim_id` int(11) NOT NULL AUTO_INCREMENT,
  `shipment_id` int(11) NOT NULL,
  `container_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `customer_id` int(11) NOT NULL,
  `claim_type` enum('Loss','Damage','Shortage') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `incident_date` date NOT NULL,
  `claimed_amount` decimal(12,2) DEFAULT NULL CHECK (`claimed_amount` >= 0),
  `approved_amount` decimal(12,2) DEFAULT NULL,
  `reason_id` int(11) DEFAULT NULL,
  `status` enum('Filed','Under Review','Approved','Rejected','Settled') DEFAULT 'Filed',
  `filed_by` int(11) NOT NULL,
  `filed_date` datetime DEFAULT current_timestamp(),
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_date` datetime DEFAULT NULL,
  PRIMARY KEY (`claim_id`),
  KEY `shipment_id` (`shipment_id`),
  KEY `container_id` (`container_id`),
  KEY `product_id` (`product_id`),
  KEY `reason_id` (`reason_id`),
  KEY `filed_by` (`filed_by`),
  KEY `resolved_by` (`resolved_by`),
  KEY `idx_claims_status` (`status`),
  KEY `idx_claims_customer` (`customer_id`),
  CONSTRAINT `claims_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipment` (`shipment_id`),
  CONSTRAINT `claims_ibfk_2` FOREIGN KEY (`container_id`) REFERENCES `containers` (`container_id`),
  CONSTRAINT `claims_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `claims_ibfk_4` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `claims_ibfk_5` FOREIGN KEY (`reason_id`) REFERENCES `loss_reasons` (`reason_id`),
  CONSTRAINT `claims_ibfk_6` FOREIGN KEY (`filed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `claims_ibfk_7` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claims`
--

LOCK TABLES `claims` WRITE;
/*!40000 ALTER TABLE `claims` DISABLE KEYS */;
INSERT INTO `claims` VALUES (1,126,NULL,NULL,18,'Shortage','Dummy claim','2026-02-04',2674.94,0.00,NULL,'Rejected',79,'2026-09-02 17:43:35',NULL,NULL),(2,136,NULL,NULL,22,'Shortage','Dummy claim','2026-05-23',2231.36,0.00,NULL,'Rejected',83,'2026-09-02 17:43:35',NULL,NULL),(3,70,NULL,NULL,5,'Shortage','Dummy claim','2026-06-26',3541.51,0.00,NULL,'Under Review',66,'2026-09-02 17:43:35',NULL,NULL),(4,187,NULL,NULL,32,'Damage','Dummy claim','2026-10-26',1860.25,0.00,NULL,'Filed',93,'2026-09-02 17:43:35',NULL,NULL),(5,120,NULL,NULL,26,'Shortage','Dummy claim','2026-12-10',3097.67,0.00,NULL,'Filed',87,'2026-09-02 17:43:35',NULL,NULL),(6,119,NULL,NULL,30,'Damage','Dummy claim','2026-02-06',4091.18,0.00,NULL,'Rejected',91,'2026-09-02 17:43:35',NULL,NULL),(7,87,NULL,NULL,23,'Shortage','Dummy claim','2026-05-04',1750.71,0.00,NULL,'Filed',84,'2026-09-02 17:43:35',NULL,NULL),(8,38,NULL,NULL,8,'Loss','Dummy claim','2026-09-26',2786.97,2128.04,NULL,'Approved',69,'2026-09-02 17:43:35',NULL,NULL),(9,123,NULL,NULL,16,'Shortage','Dummy claim','2026-11-20',912.91,0.00,NULL,'Rejected',77,'2026-09-02 17:43:35',NULL,NULL),(10,54,NULL,NULL,38,'Shortage','Dummy claim','2026-04-11',2321.15,0.00,NULL,'Under Review',99,'2026-09-02 17:43:35',NULL,NULL),(11,150,NULL,NULL,24,'Damage','Dummy claim','2026-02-23',4757.51,4001.41,NULL,'Approved',85,'2026-09-02 17:43:35',NULL,NULL),(12,67,NULL,NULL,33,'Damage','Dummy claim','2026-12-22',3303.67,0.00,NULL,'Under Review',94,'2026-09-02 17:43:35',NULL,NULL),(13,76,NULL,NULL,27,'Loss','Dummy claim','2026-09-08',2065.21,0.00,NULL,'Under Review',88,'2026-09-02 17:43:35',NULL,NULL),(14,37,NULL,NULL,23,'Loss','Dummy claim','2026-03-28',3449.44,0.00,NULL,'Under Review',84,'2026-09-02 17:43:35',NULL,NULL),(15,196,NULL,NULL,26,'Damage','Dummy claim','2026-12-19',4149.52,4026.15,NULL,'Settled',87,'2026-09-02 17:43:35',NULL,NULL),(16,89,NULL,NULL,4,'Damage','Dummy claim','2026-10-19',2464.83,0.00,NULL,'Filed',65,'2026-09-02 17:43:35',NULL,NULL),(17,193,NULL,NULL,18,'Loss','Dummy claim','2026-02-18',3081.48,0.00,NULL,'Filed',79,'2026-09-02 17:43:35',NULL,NULL),(18,186,NULL,NULL,23,'Shortage','Dummy claim','2026-11-05',2270.09,0.00,NULL,'Filed',84,'2026-09-02 17:43:35',NULL,NULL),(19,138,NULL,NULL,40,'Shortage','Dummy claim','2026-07-01',4952.73,3663.22,NULL,'Settled',101,'2026-09-02 17:43:35',NULL,NULL),(20,33,NULL,NULL,3,'Damage','Dummy claim','2026-07-11',2226.45,0.00,NULL,'Rejected',64,'2026-09-02 17:43:35',NULL,NULL),(21,150,NULL,NULL,22,'Damage','Dummy claim','2026-11-27',3251.76,2560.73,NULL,'Settled',83,'2026-09-02 17:43:35',NULL,NULL),(22,75,NULL,NULL,35,'Damage','Dummy claim','2026-12-22',2088.03,0.00,NULL,'Filed',96,'2026-09-02 17:43:35',NULL,NULL),(23,107,NULL,NULL,3,'Damage','Dummy claim','2026-11-26',1652.36,0.00,NULL,'Under Review',64,'2026-09-02 17:43:35',NULL,NULL),(24,189,NULL,NULL,9,'Loss','Dummy claim','2026-04-08',4334.59,0.00,NULL,'Rejected',70,'2026-09-02 17:43:35',NULL,NULL),(25,43,NULL,NULL,29,'Shortage','Dummy claim','2026-12-01',2111.45,1592.63,NULL,'Settled',90,'2026-09-02 17:43:35',NULL,NULL),(26,59,NULL,NULL,5,'Shortage','Dummy claim','2026-03-19',1193.63,731.85,NULL,'Approved',66,'2026-09-02 17:43:35',NULL,NULL),(27,51,NULL,NULL,38,'Shortage','Dummy claim','2026-01-19',1139.01,686.60,NULL,'Settled',99,'2026-09-02 17:43:35',NULL,NULL),(28,177,NULL,NULL,3,'Shortage','Dummy claim','2026-03-15',724.32,0.00,NULL,'Rejected',64,'2026-09-02 17:43:35',NULL,NULL),(29,71,NULL,NULL,34,'Shortage','Dummy claim','2026-02-01',4473.43,0.00,NULL,'Filed',95,'2026-09-02 17:43:35',NULL,NULL),(30,96,NULL,NULL,7,'Damage','Dummy claim','2026-07-13',1635.16,1474.15,NULL,'Settled',68,'2026-09-02 17:43:35',NULL,NULL);
/*!40000 ALTER TABLE `claims` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER claim_require_review_precondition
BEFORE UPDATE ON claims
FOR EACH ROW
BEGIN
    IF NEW.status = 'Settled' AND OLD.status <> 'Under Review' AND OLD.status <> 'Approved' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Claim must be Under Review or Approved before it can be Settled';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER claim_approved_amount_check
BEFORE UPDATE ON claims
FOR EACH ROW
BEGIN
    IF NEW.approved_amount IS NOT NULL AND NEW.approved_amount > NEW.claimed_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Approved amount cannot exceed claimed amount';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER claim_reason_required_on_settle
BEFORE UPDATE ON claims
FOR EACH ROW
BEGIN
    IF NEW.status = 'Settled' AND NEW.approved_amount IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Claim cannot be settled without an approved_amount';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `company_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(150) NOT NULL,
  `license_no` varchar(50) DEFAULT NULL,
  `gst_no` varchar(50) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `contact_email` varchar(100) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `approval_status` enum('Pending','Active','Suspended') DEFAULT 'Pending',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,'Global Freight Ltd.','LIC1001','GST2001IN','1 Main St, City','contact@globallogistics1.com','555-0101','','2026-09-02 17:43:35'),(2,'Oceanic Shipping Co.','LIC1002','GST2002IN','2 Main St, City','contact@globallogistics2.com','555-0102','','2026-09-02 17:43:35'),(3,'Blue Horizon Logistics','LIC1003','GST2003IN','3 Main St, City','contact@globallogistics3.com','555-0103','','2026-09-02 17:43:35'),(4,'Swift Marine Lines','LIC1004','GST2004IN','4 Main St, City','contact@globallogistics4.com','555-0104','','2026-09-02 17:43:35'),(5,'Pacific Crest Shipping','LIC1005','GST2005IN','5 Main St, City','contact@globallogistics5.com','555-0105','','2026-09-02 17:43:35'),(6,'Atlas Maritime Cargo','LIC1006','GST2006IN','6 Main St, City','contact@globallogistics6.com','555-0106','','2026-09-02 17:43:35'),(7,'Nordic Sea Logistics','LIC1007','GST2007IN','7 Main St, City','contact@globallogistics7.com','555-0107','','2026-09-02 17:43:35'),(8,'Meridian Ocean Lines','LIC1008','GST2008IN','8 Main St, City','contact@globallogistics8.com','555-0108','','2026-09-02 17:43:35'),(9,'TransGlobal Express','LIC1009','GST2009IN','9 Main St, City','contact@globallogistics9.com','555-0109','','2026-09-02 17:43:35'),(10,'Apex Container Line','LIC1010','GST2010IN','10 Main St, City','contact@globallogistics10.com','555-0110','','2026-09-02 17:43:35'),(11,'Vanguard Maritime','LIC1011','GST2011IN','11 Main St, City','contact@globallogistics11.com','555-0111','','2026-09-02 17:43:35'),(12,'Beacon Logistics Corp.','LIC1012','GST2012IN','12 Main St, City','contact@globallogistics12.com','555-0112','','2026-09-02 17:43:35'),(13,'Starlight Shipping','LIC1013','GST2013IN','13 Main St, City','contact@globallogistics13.com','555-0113','','2026-09-02 17:43:35'),(14,'Horizon Cargo Systems','LIC1014','GST2014IN','14 Main St, City','contact@globallogistics14.com','555-0114','','2026-09-02 17:43:35'),(15,'Titan Marine Services','LIC1015','GST2015IN','15 Main St, City','contact@globallogistics15.com','555-0115','','2026-09-02 17:43:35'),(16,'Zenith Intermodal','LIC1016','GST2016IN','16 Main St, City','contact@globallogistics16.com','555-0116','','2026-09-02 17:43:35'),(17,'Pinnacle Freight','LIC1017','GST2017IN','17 Main St, City','contact@globallogistics17.com','555-0117','','2026-09-02 17:43:35'),(18,'Crown Oceanic Lines','LIC1018','GST2018IN','18 Main St, City','contact@globallogistics18.com','555-0118','','2026-09-02 17:43:35'),(19,'Compass Sea Logistics','LIC1019','GST2019IN','19 Main St, City','contact@globallogistics19.com','555-0119','','2026-09-02 17:43:35'),(20,'Neptune Global Lines','LIC1020','GST2020IN','20 Main St, City','contact@globallogistics20.com','555-0120','','2026-09-02 17:43:35'),(21,'qwe','1233455','12345','Datta Mandir Road, Pipeline Rd, Mumbai, MH - jdoe','mohitgup1011@gmail.com','8433856648','','2026-09-03 13:57:05'),(22,'uu','2344','2345','mkfnskjdn, mumbai, MH - 34422','uu@gmail.com','1234567723','Active','2026-09-03 16:56:05');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER company_registered
AFTER INSERT ON companies
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
    VALUES (NULL, 'COMPANY_REGISTERED', NEW.company_name, NEW.company_id, NULL, NEW.approval_status);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `compliance_documents`
--

DROP TABLE IF EXISTS `compliance_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compliance_documents` (
  `doc_id` int(11) NOT NULL AUTO_INCREMENT,
  `shipment_id` int(11) NOT NULL,
  `doc_type` enum('Customs Declaration','Import License','Export License','Certificate of Origin','Insurance','Inspection') NOT NULL,
  `doc_number` varchar(100) DEFAULT NULL,
  `issuing_authority` varchar(150) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected','Expired') DEFAULT 'Pending',
  `file_path` varchar(255) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  PRIMARY KEY (`doc_id`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `idx_compliance_shipment` (`shipment_id`),
  KEY `idx_compliance_status` (`status`),
  CONSTRAINT `compliance_documents_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipment` (`shipment_id`),
  CONSTRAINT `compliance_documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compliance_documents`
--

LOCK TABLES `compliance_documents` WRITE;
/*!40000 ALTER TABLE `compliance_documents` DISABLE KEYS */;
INSERT INTO `compliance_documents` VALUES (1,26,'Certificate of Origin','34567','3456','2026-09-03','2026-09-03','Pending','uploads/Profit_Loss_Analytics.pdf',1);
/*!40000 ALTER TABLE `compliance_documents` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER compliance_doc_expiry_check
BEFORE INSERT ON compliance_documents
FOR EACH ROW
BEGIN
    IF NEW.expiry_date IS NOT NULL AND NEW.expiry_date < CURDATE() THEN
        SET NEW.status = 'Expired';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `container_movements`
--

DROP TABLE IF EXISTS `container_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_movements` (
  `movement_id` int(11) NOT NULL AUTO_INCREMENT,
  `shipment_id` int(11) NOT NULL,
  `status` enum('Booked','Container Allocated','Departed','In Transit','Customs Hold','Arrived','Delivered','Cancelled') NOT NULL,
  `checkpoint_location` varchar(150) DEFAULT NULL,
  `departure_date` datetime DEFAULT NULL,
  `expected_arrival_date` datetime DEFAULT NULL,
  `actual_arrival_date` datetime DEFAULT NULL,
  `delay_days` int(11) DEFAULT 0,
  `updated_by` int(11) NOT NULL,
  `updated_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`movement_id`),
  KEY `updated_by` (`updated_by`),
  KEY `idx_movements_shipment` (`shipment_id`),
  CONSTRAINT `container_movements_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipment` (`shipment_id`),
  CONSTRAINT `container_movements_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_movements`
--

LOCK TABLES `container_movements` WRITE;
/*!40000 ALTER TABLE `container_movements` DISABLE KEYS */;
INSERT INTO `container_movements` VALUES (1,86,'Customs Hold','Checkpoint Update',NULL,NULL,NULL,0,1,'2026-09-02 17:48:02'),(3,202,'Booked',NULL,NULL,NULL,NULL,0,1,'2026-09-02 18:38:52'),(5,157,'',NULL,NULL,NULL,NULL,0,1,'2026-09-03 21:52:55'),(10,207,'Booked',NULL,NULL,NULL,NULL,0,1,'2026-09-03 23:27:24'),(11,207,'Departed','Shipment has been departed','2026-09-03 23:28:38',NULL,NULL,0,1,'2026-09-03 23:28:38'),(12,207,'Departed','Full Edit Details',NULL,NULL,NULL,0,1,'2026-09-03 23:44:50'),(13,207,'In Transit','In Transit',NULL,NULL,NULL,0,1,'2026-09-03 23:45:53');
/*!40000 ALTER TABLE `container_movements` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER movement_check_delay
BEFORE INSERT ON container_movements
FOR EACH ROW
BEGIN
    IF NEW.delay_days < 0 THEN
        SET NEW.delay_days = 0;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER movement_prevent_depart_if_docs_pending
BEFORE INSERT ON container_movements
FOR EACH ROW
BEGIN
    DECLARE v_blocking_count INT;
    IF NEW.status = 'Departed' THEN
        SELECT COUNT(*) INTO v_blocking_count
        FROM compliance_documents
        WHERE shipment_id = NEW.shipment_id
          AND (status <> 'Approved' OR expiry_date < CURDATE());
          
        IF v_blocking_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Shipment cannot depart due to pending or expired compliance documents';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER movement_in_transit
AFTER INSERT ON container_movements
FOR EACH ROW
BEGIN
    IF NEW.status = 'In Transit' THEN
        UPDATE containers c
        JOIN shipment s ON s.container_id = c.container_id
        SET c.status = 'In-Transit'
        WHERE s.shipment_id = NEW.shipment_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `containers`
--

DROP TABLE IF EXISTS `containers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `containers` (
  `container_id` int(11) NOT NULL AUTO_INCREMENT,
  `container_number` varchar(20) NOT NULL,
  `type` enum('Dry','Reefer','Open Top','Flat Rack','Tank') NOT NULL,
  `size` enum('20ft','40ft','40ft HC','45ft') NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `tare_weight_kg` decimal(10,2) DEFAULT NULL CHECK (`tare_weight_kg` >= 0),
  `max_gross_weight_kg` decimal(10,2) DEFAULT NULL CHECK (`max_gross_weight_kg` >= 0),
  `goods_capacity_kg` decimal(10,2) DEFAULT NULL CHECK (`goods_capacity_kg` >= 0),
  `goods_capacity_cbm` decimal(10,2) DEFAULT NULL CHECK (`goods_capacity_cbm` >= 0),
  `status` enum('Available','Allocated','In-Transit','Under Maintenance') DEFAULT 'Available',
  `current_port_id` int(11) DEFAULT NULL,
  `owner_company_id` int(11) NOT NULL,
  PRIMARY KEY (`container_id`),
  UNIQUE KEY `container_number` (`container_number`),
  KEY `current_port_id` (`current_port_id`),
  KEY `idx_containers_status` (`status`),
  KEY `idx_containers_company` (`owner_company_id`),
  CONSTRAINT `containers_ibfk_1` FOREIGN KEY (`current_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `containers_ibfk_2` FOREIGN KEY (`owner_company_id`) REFERENCES `companies` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `containers`
--

LOCK TABLES `containers` WRITE;
/*!40000 ALTER TABLE `containers` DISABLE KEYS */;
INSERT INTO `containers` VALUES (1,'CONT0000001','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(2,'CONT0000002','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(3,'CONT0000003','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(4,'CONT0000004','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(5,'CONT0000005','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(6,'CONT0000006','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,1),(7,'CONT0000007','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(8,'CONT0000008','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(9,'CONT0000009','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,4),(10,'CONT0000010','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,5),(11,'CONT0000011','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(12,'CONT0000012','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(13,'CONT0000013','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(14,'CONT0000014','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,3),(15,'CONT0000015','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(16,'CONT0000016','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(17,'CONT0000017','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(18,'CONT0000018','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(19,'CONT0000019','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(20,'CONT0000020','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(21,'CONT0000021','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(22,'CONT0000022','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(23,'CONT0000023','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(24,'CONT0000024','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(25,'CONT0000025','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(26,'CONT0000026','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(27,'CONT0000027','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(28,'CONT0000028','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,5),(29,'CONT0000029','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,6),(30,'CONT0000030','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(31,'CONT0000031','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(32,'CONT0000032','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,3),(33,'CONT0000033','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(34,'CONT0000034','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(35,'CONT0000035','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,6),(36,'CONT0000036','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,1),(37,'CONT0000037','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(38,'CONT0000038','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(39,'CONT0000039','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,4),(40,'CONT0000040','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(41,'CONT0000041','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(42,'CONT0000042','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(43,'CONT0000043','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(44,'CONT0000044','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(45,'CONT0000045','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,4),(46,'CONT0000046','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,5),(47,'CONT0000047','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(48,'CONT0000048','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(49,'CONT0000049','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,2),(50,'CONT0000050','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(51,'CONT0000051','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(52,'CONT0000052','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(53,'CONT0000053','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(54,'CONT0000054','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(55,'CONT0000055','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(56,'CONT0000056','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,3),(57,'CONT0000057','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(58,'CONT0000058','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(59,'CONT0000059','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(60,'CONT0000060','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(61,'CONT0000061','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(62,'CONT0000062','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(63,'CONT0000063','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(64,'CONT0000064','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(65,'CONT0000065','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(66,'CONT0000066','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(67,'CONT0000067','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(68,'CONT0000068','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,3),(69,'CONT0000069','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(70,'CONT0000070','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(71,'CONT0000071','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(72,'CONT0000072','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(73,'CONT0000073','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,2),(74,'CONT0000074','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(75,'CONT0000075','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(76,'CONT0000076','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(77,'CONT0000077','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(78,'CONT0000078','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(79,'CONT0000079','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(80,'CONT0000080','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,3),(81,'CONT0000081','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(82,'CONT0000082','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(83,'CONT0000083','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(84,'CONT0000084','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(85,'CONT0000085','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(86,'CONT0000086','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(87,'CONT0000087','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(88,'CONT0000088','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(89,'CONT0000089','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(90,'CONT0000090','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(91,'CONT0000091','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(92,'CONT0000092','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(93,'CONT0000093','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(94,'CONT0000094','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(95,'CONT0000095','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(96,'CONT0000096','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,1),(97,'CONT0000097','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(98,'CONT0000098','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(99,'CONT0000099','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(100,'CONT0000100','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,5),(101,'CONT0000101','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(102,'CONT0000102','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(103,'CONT0000103','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(104,'CONT0000104','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,3),(105,'CONT0000105','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,4),(106,'CONT0000106','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(107,'CONT0000107','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(108,'CONT0000108','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(109,'CONT0000109','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,2),(110,'CONT0000110','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,3),(111,'CONT0000111','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(112,'CONT0000112','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,5),(113,'CONT0000113','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(114,'CONT0000114','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,1),(115,'CONT0000115','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(116,'CONT0000116','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(117,'CONT0000117','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(118,'CONT0000118','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(119,'CONT0000119','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(120,'CONT0000120','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(121,'CONT0000121','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(122,'CONT0000122','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(123,'CONT0000123','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(124,'CONT0000124','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(125,'CONT0000125','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(126,'CONT0000126','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,1),(127,'CONT0000127','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(128,'CONT0000128','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(129,'CONT0000129','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(130,'CONT0000130','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,5),(131,'CONT0000131','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(132,'CONT0000132','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(133,'CONT0000133','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(134,'CONT0000134','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(135,'CONT0000135','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,4),(136,'CONT0000136','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(137,'CONT0000137','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(138,'CONT0000138','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(139,'CONT0000139','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(140,'CONT0000140','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(141,'CONT0000141','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(142,'CONT0000142','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(143,'CONT0000143','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(144,'CONT0000144','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(145,'CONT0000145','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(146,'CONT0000146','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(147,'CONT0000147','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(148,'CONT0000148','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,5),(149,'CONT0000149','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(150,'CONT0000150','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(151,'CONT0000151','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,2),(152,'CONT0000152','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,3),(153,'CONT0000153','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(154,'CONT0000154','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(155,'CONT0000155','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(156,'CONT0000156','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(157,'CONT0000157','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(158,'CONT0000158','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(159,'CONT0000159','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(160,'CONT0000160','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(161,'CONT0000161','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(162,'CONT0000162','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,1),(163,'CONT0000163','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(164,'CONT0000164','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(165,'CONT0000165','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(166,'CONT0000166','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(167,'CONT0000167','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(168,'CONT0000168','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(169,'CONT0000169','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,2),(170,'CONT0000170','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(171,'CONT0000171','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(172,'CONT0000172','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(173,'CONT0000173','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(174,'CONT0000174','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,1),(175,'CONT0000175','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(176,'CONT0000176','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(177,'CONT0000177','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(178,'CONT0000178','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(179,'CONT0000179','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(180,'CONT0000180','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(181,'CONT0000181','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,2),(182,'CONT0000182','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,3),(183,'CONT0000183','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(184,'CONT0000184','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(185,'CONT0000185','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(186,'CONT0000186','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(187,'CONT0000187','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,2),(188,'CONT0000188','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,3),(189,'CONT0000189','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(190,'CONT0000190','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(191,'CONT0000191','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(192,'CONT0000192','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(193,'CONT0000193','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(194,'CONT0000194','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(195,'CONT0000195','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(196,'CONT0000196','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(197,'CONT0000197','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(198,'CONT0000198','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(199,'CONT0000199','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,2),(200,'CONT0000200','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,3),(201,'CONT0000201','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(202,'CONT0000202','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,5),(203,'CONT0000203','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(204,'CONT0000204','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(205,'CONT0000205','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(206,'CONT0000206','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(207,'CONT0000207','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,4),(208,'CONT0000208','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(209,'CONT0000209','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(210,'CONT0000210','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(211,'CONT0000211','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(212,'CONT0000212','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(213,'CONT0000213','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(214,'CONT0000214','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(215,'CONT0000215','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,6),(216,'CONT0000216','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,1),(217,'CONT0000217','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(218,'CONT0000218','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(219,'CONT0000219','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(220,'CONT0000220','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(221,'CONT0000221','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(222,'CONT0000222','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(223,'CONT0000223','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(224,'CONT0000224','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(225,'CONT0000225','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,4),(226,'CONT0000226','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(227,'CONT0000227','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(228,'CONT0000228','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(229,'CONT0000229','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(230,'CONT0000230','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(231,'CONT0000231','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,4),(232,'CONT0000232','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(233,'CONT0000233','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(234,'CONT0000234','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(235,'CONT0000235','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(236,'CONT0000236','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(237,'CONT0000237','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,4),(238,'CONT0000238','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(239,'CONT0000239','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(240,'CONT0000240','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(241,'CONT0000241','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,2),(242,'CONT0000242','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,3),(243,'CONT0000243','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(244,'CONT0000244','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(245,'CONT0000245','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,6),(246,'CONT0000246','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(247,'CONT0000247','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(248,'CONT0000248','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(249,'CONT0000249','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(250,'CONT0000250','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(251,'CONT0000251','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(252,'CONT0000252','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,1),(253,'CONT0000253','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(254,'CONT0000254','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,3),(255,'CONT0000255','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,4),(256,'CONT0000256','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(257,'CONT0000257','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,6),(258,'CONT0000258','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(259,'CONT0000259','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,2),(260,'CONT0000260','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(261,'CONT0000261','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,4),(262,'CONT0000262','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(263,'CONT0000263','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,6),(264,'CONT0000264','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,1),(265,'CONT0000265','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,2),(266,'CONT0000266','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,3),(267,'CONT0000267','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,4),(268,'CONT0000268','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,5),(269,'CONT0000269','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(270,'CONT0000270','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,1),(271,'CONT0000271','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,2),(272,'CONT0000272','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,3),(273,'CONT0000273','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,4),(274,'CONT0000274','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(275,'CONT0000275','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,6),(276,'CONT0000276','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,1),(277,'CONT0000277','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,2),(278,'CONT0000278','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(279,'CONT0000279','Dry','20ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(280,'CONT0000280','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,5),(281,'CONT0000281','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(282,'CONT0000282','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,1),(283,'CONT0000283','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,2),(284,'CONT0000284','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,3),(285,'CONT0000285','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Available',NULL,4),(286,'CONT0000286','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,5),(287,'CONT0000287','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,6),(288,'CONT0000288','Reefer','20ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,1),(289,'CONT0000289','Flat Rack','20ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,2),(290,'CONT0000290','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,3),(291,'CONT0000291','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'In-Transit',NULL,4),(292,'CONT0000292','Open Top','40ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,5),(293,'CONT0000293','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,6),(294,'CONT0000294','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,1),(295,'CONT0000295','Open Top','20ft','https://images.unsplash.com/photo-1494412574643-ff11b0a5c1c3?w=500&q=80',2300.00,30480.00,28180.00,33.20,'Allocated',NULL,2),(296,'CONT0000296','Flat Rack','40ft','https://images.unsplash.com/photo-1505777174135-d7247a329d91?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,3),(297,'CONT0000297','Reefer','40ft','https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=500&q=80',3750.00,30480.00,26730.00,67.70,'In-Transit',NULL,4),(298,'CONT0000298','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,5),(299,'CONT0000299','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Available',NULL,6),(300,'CONT0000300','Dry','40ft','https://images.unsplash.com/photo-1586528116311-ad8ed7abe515?w=500&q=80',3750.00,30480.00,26730.00,67.70,'Allocated',NULL,1);
/*!40000 ALTER TABLE `containers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `customer_name` varchar(150) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `kyc_doc_path` varchar(255) DEFAULT NULL,
  `credit_limit` decimal(12,2) DEFAULT 0.00,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`customer_id`),
  KEY `idx_customers_user` (`user_id`),
  CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,62,'Customer Corp 1','1 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(2,63,'Customer Corp 2','2 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(3,64,'Customer Corp 3','3 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(4,65,'Customer Corp 4','4 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(5,66,'Customer Corp 5','5 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(6,67,'Customer Corp 6','6 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(7,68,'Customer Corp 7','7 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(8,69,'Customer Corp 8','8 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(9,70,'Customer Corp 9','9 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(10,71,'Customer Corp 10','10 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(11,72,'Customer Corp 11','11 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(12,73,'Customer Corp 12','12 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(13,74,'Customer Corp 13','13 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(14,75,'Customer Corp 14','14 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(15,76,'Customer Corp 15','15 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(16,77,'Customer Corp 16','16 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(17,78,'Customer Corp 17','17 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(18,79,'Customer Corp 18','18 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(19,80,'Customer Corp 19','19 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(20,81,'Customer Corp 20','20 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(21,82,'Customer Corp 21','21 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(22,83,'Customer Corp 22','22 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(23,84,'Customer Corp 23','23 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(24,85,'Customer Corp 24','24 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(25,86,'Customer Corp 25','25 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(26,87,'Customer Corp 26','26 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(27,88,'Customer Corp 27','27 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(28,89,'Customer Corp 28','28 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(29,90,'Customer Corp 29','29 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(30,91,'Customer Corp 30','30 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(31,92,'Customer Corp 31','31 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(32,93,'Customer Corp 32','32 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(33,94,'Customer Corp 33','33 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(34,95,'Customer Corp 34','34 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(35,96,'Customer Corp 35','35 Market St',NULL,10000.00,'2026-09-02 17:43:35'),(36,97,'Customer Corp 36','36 Market St',NULL,100000.00,'2026-09-02 17:43:35'),(37,98,'Customer Corp 37','37 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(38,99,'Customer Corp 38','38 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(39,100,'Customer Corp 39','39 Market St',NULL,50000.00,'2026-09-02 17:43:35'),(40,101,'Customer Corp 40','40 Market St',NULL,100000.00,'2026-09-02 17:43:35');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `demand_forecast`
--

DROP TABLE IF EXISTS `demand_forecast`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `demand_forecast` (
  `forecast_id` int(11) NOT NULL AUTO_INCREMENT,
  `container_type` enum('Dry','Reefer','Open Top','Flat Rack','Tank') NOT NULL,
  `route_id` int(11) DEFAULT NULL,
  `forecast_period` varchar(20) NOT NULL,
  `forecasted_demand` decimal(12,2) DEFAULT NULL,
  `forecasted_price` decimal(12,2) DEFAULT NULL,
  `algorithm_version` varchar(20) DEFAULT NULL,
  `generated_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`forecast_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `demand_forecast`
--

LOCK TABLES `demand_forecast` WRITE;
/*!40000 ALTER TABLE `demand_forecast` DISABLE KEYS */;
INSERT INTO `demand_forecast` VALUES (1,'Dry',1,'2026-Q4',120.00,55000.00,'v1.0','2026-09-02 17:38:03');
/*!40000 ALTER TABLE `demand_forecast` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_ledger`
--

DROP TABLE IF EXISTS `inventory_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_ledger` (
  `ledger_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `transaction_type` enum('IN','OUT','ADJUSTMENT') NOT NULL,
  `quantity` decimal(12,2) NOT NULL,
  `unit_cost_at_txn` decimal(12,2) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `txn_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ledger_id`),
  KEY `idx_ledger_product` (`product_id`),
  CONSTRAINT `inventory_ledger_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_ledger`
--

LOCK TABLES `inventory_ledger` WRITE;
/*!40000 ALTER TABLE `inventory_ledger` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_turnover_result`
--

DROP TABLE IF EXISTS `inventory_turnover_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_turnover_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `period` varchar(20) DEFAULT NULL,
  `cogs_amount` decimal(12,2) DEFAULT NULL,
  `avg_inventory_value` decimal(12,2) DEFAULT NULL,
  `turnover_ratio` decimal(10,2) DEFAULT NULL,
  `days_in_inventory` decimal(10,2) DEFAULT NULL,
  `computed_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `inventory_turnover_result_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_turnover_result`
--

LOCK TABLES `inventory_turnover_result` WRITE;
/*!40000 ALTER TABLE `inventory_turnover_result` DISABLE KEYS */;
INSERT INTO `inventory_turnover_result` VALUES (1,1,'2026-Q3',400000.00,100000.00,4.00,91.25,'2026-09-02 17:38:04');
/*!40000 ALTER TABLE `inventory_turnover_result` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER turnover_check_negative
BEFORE INSERT ON inventory_turnover_result
FOR EACH ROW
BEGIN
    IF NEW.turnover_ratio < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Turnover ratio cannot be negative';
    ELSEIF NEW.days_in_inventory < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Days in inventory cannot be negative';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `invoice_line_items`
--

DROP TABLE IF EXISTS `invoice_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_line_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `quantity` decimal(12,2) DEFAULT 1.00,
  `unit_price` decimal(12,2) DEFAULT 0.00,
  `line_total` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `invoice_line_items_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `billing_invoices` (`invoice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_line_items`
--

LOCK TABLES `invoice_line_items` WRITE;
/*!40000 ALTER TABLE `invoice_line_items` DISABLE KEYS */;
INSERT INTO `invoice_line_items` VALUES (1,152,'Freight Charges',1.00,15000.00,15000.00),(2,152,'Taxes',1.00,2700.00,2700.00);
/*!40000 ALTER TABLE `invoice_line_items` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER invoice_line_item_total
BEFORE INSERT ON invoice_line_items
FOR EACH ROW
BEGIN
    SET NEW.line_total = NEW.quantity * NEW.unit_price;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `loss_reasons`
--

DROP TABLE IF EXISTS `loss_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loss_reasons` (
  `reason_id` int(11) NOT NULL AUTO_INCREMENT,
  `reason_code` varchar(50) NOT NULL,
  `reason_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`reason_id`),
  UNIQUE KEY `reason_code` (`reason_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loss_reasons`
--

LOCK TABLES `loss_reasons` WRITE;
/*!40000 ALTER TABLE `loss_reasons` DISABLE KEYS */;
INSERT INTO `loss_reasons` VALUES (1,'TRAFFIC_SEA','Traffic in Sea','Delay and idle fuel burn due to sea congestion'),(2,'WEATHER','Weather','Severe storm diversions and heavy sea damage'),(3,'DELAY','Delay','Port scheduling delays and demurrage penalties'),(4,'DOCK_ALLOC','Dock Allocation','Berth unavailability and waiting demurrage'),(5,'REG_HOLD','Regulatory Hold','Customs inspection holds and clearance fines'),(6,'WAR_DISRUPT','War / Disruption','Canal rerouting and maritime war risk surcharge'),(7,'SHIP_ISSUE','Ship Issue','Engine breakdown and auxiliary power failure'),(8,'DAMAGED_PROD','Damaged Product','Container seal breach and cargo compensation claim');
/*!40000 ALTER TABLE `loss_reasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id_idx` (`user_id`),
  CONSTRAINT `fk_pr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER pr_expire_old_tokens
BEFORE INSERT ON password_resets
FOR EACH ROW
BEGIN
    
    UPDATE password_resets
    SET used = 1
    WHERE user_id = NEW.user_id
      AND used = 0
      AND expires_at > NOW();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER pr_validate_expiry
BEFORE INSERT ON password_resets
FOR EACH ROW
BEGIN
    IF NEW.expires_at <= NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contract Violation: expires_at must be a future datetime';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) NOT NULL,
  `payment_date` date NOT NULL,
  `amount_paid` decimal(12,2) NOT NULL CHECK (`amount_paid` > 0),
  `payment_mode` enum('Bank Transfer','Card','UPI','Cheque') NOT NULL,
  `transaction_ref` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `idx_payments_invoice` (`invoice_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `billing_invoices` (`invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ports`
--

DROP TABLE IF EXISTS `ports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ports` (
  `port_id` int(11) NOT NULL AUTO_INCREMENT,
  `port_name` varchar(100) NOT NULL,
  `port_code` varchar(20) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `latitude` decimal(10,6) DEFAULT NULL,
  `longitude` decimal(10,6) DEFAULT NULL,
  PRIMARY KEY (`port_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ports`
--

LOCK TABLES `ports` WRITE;
/*!40000 ALTER TABLE `ports` DISABLE KEYS */;
INSERT INTO `ports` VALUES (1,'Shanghai Port','P000','Country0',-86.047700,24.754900),(2,'Singapore Port','P001','Country1',-25.281600,-169.972200),(3,'Ningbo Port','P002','Country2',67.417600,60.648200),(4,'Shenzhen Port','P003','Country3',78.586000,113.283300),(5,'Guangzhou Port','P004','Country4',7.127000,-89.731500),(6,'Busan Port','P005','Country5',-41.321200,-105.944300),(7,'Qingdao Port','P006','Country6',-50.750000,-109.122100),(8,'Hong Kong Port','P007','Country7',48.441800,-177.621000),(9,'Tianjin Port','P008','Country8',-84.964800,103.749900),(10,'Rotterdam Port','P009','Country9',55.755600,-110.422400),(11,'Dubai Port','P010','Country10',-21.263100,-27.757700),(12,'Port Klang Port','P011','Country11',-22.904900,133.500700),(13,'Antwerp Port','P012','Country12',7.668300,-80.255800),(14,'Xiamen Port','P013','Country13',-32.383400,-170.650500),(15,'Los Angeles Port','P014','Country14',31.311000,-158.352400),(16,'Kaohsiung Port','P015','Country15',62.112000,125.410400),(17,'Dalian Port','P016','Country16',-4.433200,-63.984600),(18,'Hamburg Port','P017','Country17',12.314400,-143.918700),(19,'Tanjung Pelepas Port','P018','Country18',-7.788100,15.431600),(20,'Laem Chabang Port','P019','Country19',16.151400,-133.779400),(21,'Yokohama Port','P020','Country20',38.986500,67.484900),(22,'Colombo Port','P021','Country21',-45.097000,125.794700),(23,'Bremen Port','P022','Country22',-57.269900,169.983800),(24,'Jakarta Port','P023','Country23',-40.480500,-130.266500),(25,'Mumbai Port','P024','Country24',61.979800,109.941700),(26,'Valencia Port','P025','Country25',-62.033900,-46.857800),(27,'Algeciras Port','P026','Country26',6.456600,11.294400),(28,'Nhava Sheva Port','P027','Country27',-12.533800,15.450200),(29,'Jeddah Port','P028','Country28',-68.184700,3.555200),(30,'Tokyo Port','P029','Country29',15.311200,-34.600500);
/*!40000 ALTER TABLE `ports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pricing_audit`
--

DROP TABLE IF EXISTS `pricing_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pricing_audit` (
  `audit_id` int(11) NOT NULL AUTO_INCREMENT,
  `pricing_id` int(11) NOT NULL,
  `old_price` decimal(12,2) DEFAULT NULL,
  `new_price` decimal(12,2) DEFAULT NULL,
  `changed_by` int(11) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`audit_id`),
  KEY `pricing_id` (`pricing_id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `pricing_audit_ibfk_1` FOREIGN KEY (`pricing_id`) REFERENCES `pricing_rules` (`pricing_id`),
  CONSTRAINT `pricing_audit_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pricing_audit`
--

LOCK TABLES `pricing_audit` WRITE;
/*!40000 ALTER TABLE `pricing_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `pricing_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pricing_rules`
--

DROP TABLE IF EXISTS `pricing_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pricing_rules` (
  `pricing_id` int(11) NOT NULL AUTO_INCREMENT,
  `container_type` enum('Dry','Reefer','Open Top','Flat Rack','Tank') NOT NULL,
  `container_size` enum('20ft','40ft','40ft HC','45ft') NOT NULL,
  `route_id` int(11) DEFAULT NULL,
  `base_price` decimal(12,2) NOT NULL CHECK (`base_price` >= 0),
  `seasonal_multiplier` decimal(5,2) DEFAULT 1.00,
  `demand_multiplier` decimal(5,2) DEFAULT 1.00,
  `final_price` decimal(12,2) DEFAULT NULL,
  `valid_from` date DEFAULT NULL,
  `valid_to` date DEFAULT NULL,
  PRIMARY KEY (`pricing_id`),
  KEY `idx_pricing_lookup` (`container_type`,`container_size`,`route_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pricing_rules`
--

LOCK TABLES `pricing_rules` WRITE;
/*!40000 ALTER TABLE `pricing_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `pricing_rules` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER pricing_before_insert
BEFORE INSERT ON pricing_rules
FOR EACH ROW
BEGIN
    SET NEW.final_price = NEW.base_price * NEW.seasonal_multiplier * NEW.demand_multiplier;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER pricing_validity_check
BEFORE INSERT ON pricing_rules
FOR EACH ROW
BEGIN
    IF NEW.valid_to IS NOT NULL AND NEW.valid_from IS NOT NULL AND NEW.valid_to < NEW.valid_from THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'valid_to cannot be earlier than valid_from';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER pricing_before_update
BEFORE UPDATE ON pricing_rules
FOR EACH ROW
BEGIN
    SET NEW.final_price = NEW.base_price * NEW.seasonal_multiplier * NEW.demand_multiplier;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_name` varchar(150) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `hsn_code` varchar(20) DEFAULT NULL,
  `unit_of_measure` varchar(20) DEFAULT NULL,
  `unit_cost` decimal(12,2) DEFAULT 0.00 CHECK (`unit_cost` >= 0),
  `unit_price` decimal(12,2) DEFAULT 0.00 CHECK (`unit_price` >= 0),
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`product_id`),
  KEY `idx_products_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Product 1','Electronics','HSN0001','PCS',367.30,241.02,'2026-09-02 17:43:35'),(2,'Product 2','Electronics','HSN0002','PCS',3826.07,1903.22,'2026-09-02 17:43:35'),(3,'Product 3','Electronics','HSN0003','PCS',4189.16,6863.09,'2026-09-02 17:43:35'),(4,'Product 4','Electronics','HSN0004','PCS',3687.06,3254.97,'2026-09-02 17:43:35'),(5,'Product 5','Electronics','HSN0005','PCS',119.50,1856.54,'2026-09-02 17:43:35'),(6,'Product 6','Electronics','HSN0006','PCS',1313.74,6013.83,'2026-09-02 17:43:35'),(7,'Product 7','Electronics','HSN0007','PCS',2298.55,6515.18,'2026-09-02 17:43:35'),(8,'Product 8','Electronics','HSN0008','PCS',2969.09,4411.83,'2026-09-02 17:43:35'),(9,'Product 9','Electronics','HSN0009','PCS',1953.98,6389.08,'2026-09-02 17:43:35'),(10,'Product 10','Electronics','HSN0010','PCS',3900.63,2985.27,'2026-09-02 17:43:35'),(11,'Product 11','Electronics','HSN0011','PCS',4863.07,2440.14,'2026-09-02 17:43:35'),(12,'Product 12','Electronics','HSN0012','PCS',2347.61,4699.66,'2026-09-02 17:43:35'),(13,'Product 13','Electronics','HSN0013','PCS',3626.39,2219.24,'2026-09-02 17:43:35'),(14,'Product 14','Electronics','HSN0014','PCS',1612.09,2847.18,'2026-09-02 17:43:35'),(15,'Product 15','Electronics','HSN0015','PCS',77.39,1000.25,'2026-09-02 17:43:35'),(16,'Product 16','Electronics','HSN0016','PCS',4382.34,5529.66,'2026-09-02 17:43:35'),(17,'Product 17','Electronics','HSN0017','PCS',4977.77,6447.64,'2026-09-02 17:43:35'),(18,'Product 18','Electronics','HSN0018','PCS',3190.57,3491.81,'2026-09-02 17:43:35'),(19,'Product 19','Electronics','HSN0019','PCS',3386.83,4019.62,'2026-09-02 17:43:35'),(20,'Product 20','Electronics','HSN0020','PCS',997.00,1546.09,'2026-09-02 17:43:35'),(21,'Product 21','Electronics','HSN0021','PCS',3456.62,2326.86,'2026-09-02 17:43:35'),(22,'Product 22','Electronics','HSN0022','PCS',1855.70,3013.01,'2026-09-02 17:43:35'),(23,'Product 23','Electronics','HSN0023','PCS',1258.70,5225.08,'2026-09-02 17:43:35'),(24,'Product 24','Electronics','HSN0024','PCS',2418.89,2038.74,'2026-09-02 17:43:35'),(25,'Product 25','Electronics','HSN0025','PCS',870.80,6236.32,'2026-09-02 17:43:35'),(26,'Product 26','Electronics','HSN0026','PCS',726.09,5875.58,'2026-09-02 17:43:35'),(27,'Product 27','Electronics','HSN0027','PCS',1555.44,3762.30,'2026-09-02 17:43:35'),(28,'Product 28','Electronics','HSN0028','PCS',3842.87,1901.18,'2026-09-02 17:43:35'),(29,'Product 29','Electronics','HSN0029','PCS',187.25,4319.86,'2026-09-02 17:43:35'),(30,'Product 30','Electronics','HSN0030','PCS',770.36,1971.88,'2026-09-02 17:43:35'),(31,'Product 31','Electronics','HSN0031','PCS',739.04,2363.45,'2026-09-02 17:43:35'),(32,'Product 32','Electronics','HSN0032','PCS',4449.99,5439.58,'2026-09-02 17:43:35'),(33,'Product 33','Electronics','HSN0033','PCS',4467.05,2174.71,'2026-09-02 17:43:35'),(34,'Product 34','Electronics','HSN0034','PCS',741.33,1772.64,'2026-09-02 17:43:35'),(35,'Product 35','Electronics','HSN0035','PCS',996.32,2144.10,'2026-09-02 17:43:35'),(36,'Product 36','Electronics','HSN0036','PCS',1146.79,2330.80,'2026-09-02 17:43:35'),(37,'Product 37','Electronics','HSN0037','PCS',4066.47,394.96,'2026-09-02 17:43:35'),(38,'Product 38','Electronics','HSN0038','PCS',3309.04,988.87,'2026-09-02 17:43:35'),(39,'Product 39','Electronics','HSN0039','PCS',2269.23,5117.92,'2026-09-02 17:43:35'),(40,'Product 40','Electronics','HSN0040','PCS',3661.34,1746.26,'2026-09-02 17:43:35'),(41,'Product 41','Electronics','HSN0041','PCS',3946.95,5135.82,'2026-09-02 17:43:35'),(42,'Product 42','Electronics','HSN0042','PCS',1086.25,4373.91,'2026-09-02 17:43:35'),(43,'Product 43','Electronics','HSN0043','PCS',4899.44,2691.93,'2026-09-02 17:43:35'),(44,'Product 44','Electronics','HSN0044','PCS',4714.00,1634.67,'2026-09-02 17:43:35'),(45,'Product 45','Electronics','HSN0045','PCS',3530.54,2557.97,'2026-09-02 17:43:35'),(46,'Product 46','Electronics','HSN0046','PCS',2882.24,6924.91,'2026-09-02 17:43:35'),(47,'Product 47','Electronics','HSN0047','PCS',2350.08,1315.49,'2026-09-02 17:43:35'),(48,'Product 48','Electronics','HSN0048','PCS',3318.40,4301.34,'2026-09-02 17:43:35'),(49,'Product 49','Electronics','HSN0049','PCS',41.63,1839.36,'2026-09-02 17:43:35'),(50,'Product 50','Electronics','HSN0050','PCS',3796.34,4347.21,'2026-09-02 17:43:35'),(51,'Product 51','Electronics','HSN0051','PCS',4985.42,1099.17,'2026-09-02 17:43:35'),(52,'Product 52','Electronics','HSN0052','PCS',1882.19,4330.45,'2026-09-02 17:43:35'),(53,'Product 53','Electronics','HSN0053','PCS',1269.23,5315.04,'2026-09-02 17:43:35'),(54,'Product 54','Electronics','HSN0054','PCS',4163.75,186.76,'2026-09-02 17:43:35'),(55,'Product 55','Electronics','HSN0055','PCS',925.16,926.08,'2026-09-02 17:43:35'),(56,'Product 56','Electronics','HSN0056','PCS',60.80,1988.69,'2026-09-02 17:43:35'),(57,'Product 57','Electronics','HSN0057','PCS',2328.39,5743.49,'2026-09-02 17:43:35'),(58,'Product 58','Electronics','HSN0058','PCS',4579.41,2611.40,'2026-09-02 17:43:35'),(59,'Product 59','Electronics','HSN0059','PCS',1245.16,5349.86,'2026-09-02 17:43:35'),(60,'Product 60','Electronics','HSN0060','PCS',2020.29,2494.00,'2026-09-02 17:43:35'),(61,'Product 61','Electronics','HSN0061','PCS',4768.86,2266.29,'2026-09-02 17:43:35'),(62,'Product 62','Electronics','HSN0062','PCS',2975.88,5949.29,'2026-09-02 17:43:35'),(63,'Product 63','Electronics','HSN0063','PCS',935.37,1145.19,'2026-09-02 17:43:35'),(64,'Product 64','Electronics','HSN0064','PCS',2075.53,5693.52,'2026-09-02 17:43:35'),(65,'Product 65','Electronics','HSN0065','PCS',4948.51,5886.07,'2026-09-02 17:43:35'),(66,'Product 66','Electronics','HSN0066','PCS',1656.26,4403.72,'2026-09-02 17:43:35'),(67,'Product 67','Electronics','HSN0067','PCS',2420.58,3806.37,'2026-09-02 17:43:35'),(68,'Product 68','Electronics','HSN0068','PCS',3728.54,4944.44,'2026-09-02 17:43:35'),(69,'Product 69','Electronics','HSN0069','PCS',4680.10,2747.06,'2026-09-02 17:43:35'),(70,'Product 70','Electronics','HSN0070','PCS',2631.04,6805.64,'2026-09-02 17:43:35'),(71,'Product 71','Electronics','HSN0071','PCS',1732.83,2269.24,'2026-09-02 17:43:35'),(72,'Product 72','Electronics','HSN0072','PCS',4363.32,4605.32,'2026-09-02 17:43:35'),(73,'Product 73','Electronics','HSN0073','PCS',2550.28,912.67,'2026-09-02 17:43:35'),(74,'Product 74','Electronics','HSN0074','PCS',2635.55,3168.53,'2026-09-02 17:43:35'),(75,'Product 75','Electronics','HSN0075','PCS',1087.57,5826.00,'2026-09-02 17:43:35'),(76,'Product 76','Electronics','HSN0076','PCS',2243.25,4552.90,'2026-09-02 17:43:35'),(77,'Product 77','Electronics','HSN0077','PCS',531.22,3152.62,'2026-09-02 17:43:35'),(78,'Product 78','Electronics','HSN0078','PCS',2828.49,343.87,'2026-09-02 17:43:35'),(79,'Product 79','Electronics','HSN0079','PCS',4621.13,3240.38,'2026-09-02 17:43:35'),(80,'Product 80','Electronics','HSN0080','PCS',3447.36,3196.09,'2026-09-02 17:43:35'),(81,'Product 81','Electronics','HSN0081','PCS',1910.78,3623.10,'2026-09-02 17:43:35'),(82,'Product 82','Electronics','HSN0082','PCS',3438.27,864.75,'2026-09-02 17:43:35'),(83,'Product 83','Electronics','HSN0083','PCS',2605.80,6563.69,'2026-09-02 17:43:35'),(84,'Product 84','Electronics','HSN0084','PCS',1663.24,4442.26,'2026-09-02 17:43:35'),(85,'Product 85','Electronics','HSN0085','PCS',237.77,6635.77,'2026-09-02 17:43:35'),(86,'Product 86','Electronics','HSN0086','PCS',1674.58,3442.08,'2026-09-02 17:43:35'),(87,'Product 87','Electronics','HSN0087','PCS',4890.14,2443.66,'2026-09-02 17:43:35'),(88,'Product 88','Electronics','HSN0088','PCS',3480.17,1155.96,'2026-09-02 17:43:35'),(89,'Product 89','Electronics','HSN0089','PCS',1692.19,2894.56,'2026-09-02 17:43:35'),(90,'Product 90','Electronics','HSN0090','PCS',4420.33,731.82,'2026-09-02 17:43:35'),(91,'Product 91','Electronics','HSN0091','PCS',3276.58,4655.64,'2026-09-02 17:43:35'),(92,'Product 92','Electronics','HSN0092','PCS',3507.61,936.65,'2026-09-02 17:43:35'),(93,'Product 93','Electronics','HSN0093','PCS',1324.85,2053.28,'2026-09-02 17:43:35'),(94,'Product 94','Electronics','HSN0094','PCS',4164.18,1819.40,'2026-09-02 17:43:35'),(95,'Product 95','Electronics','HSN0095','PCS',213.58,4296.64,'2026-09-02 17:43:35'),(96,'Product 96','Electronics','HSN0096','PCS',797.57,3433.23,'2026-09-02 17:43:35'),(97,'Product 97','Electronics','HSN0097','PCS',245.62,3965.42,'2026-09-02 17:43:35'),(98,'Product 98','Electronics','HSN0098','PCS',141.68,2591.92,'2026-09-02 17:43:35'),(99,'Product 99','Electronics','HSN0099','PCS',4290.69,1264.60,'2026-09-02 17:43:35'),(100,'Product 100','Electronics','HSN0100','PCS',1668.45,5090.79,'2026-09-02 17:43:35');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profit_loss`
--

DROP TABLE IF EXISTS `profit_loss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profit_loss` (
  `pl_id` int(11) NOT NULL AUTO_INCREMENT,
  `shipment_id` int(11) NOT NULL,
  `revenue_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_cost_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `profit_loss_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `record_date` date NOT NULL,
  PRIMARY KEY (`pl_id`),
  KEY `idx_pl_shipment` (`shipment_id`),
  KEY `idx_pl_date` (`record_date`),
  CONSTRAINT `profit_loss_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipment` (`shipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=511 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profit_loss`
--

LOCK TABLES `profit_loss` WRITE;
/*!40000 ALTER TABLE `profit_loss` DISABLE KEYS */;
INSERT INTO `profit_loss` VALUES (256,1,9237.78,5769.52,3468.26,'2026-04-07'),(257,2,12331.54,7570.98,4760.56,'2026-04-23'),(258,3,13951.66,8608.29,5343.37,'2026-08-16'),(259,4,2769.84,5202.81,-2432.97,'2026-05-03'),(260,5,2910.18,1665.87,1244.31,'2026-01-03'),(261,6,4305.65,2770.73,1534.92,'2026-07-23'),(262,7,1993.60,4031.26,-2037.66,'2026-08-07'),(263,8,9988.62,13381.90,-3393.28,'2026-01-13'),(264,9,5797.03,3594.18,2202.85,'2026-09-12'),(265,10,2896.37,1828.86,1067.51,'2026-10-23'),(266,11,9944.71,6091.25,3853.46,'2026-10-01'),(267,12,4619.70,7359.87,-2740.17,'2026-12-23'),(268,13,11645.21,7169.29,4475.92,'2026-02-12'),(269,14,6749.47,8737.58,-1988.11,'2026-06-12'),(270,15,13036.35,8243.86,4792.49,'2026-09-07'),(271,16,10912.89,14618.74,-3705.85,'2026-01-25'),(272,17,9034.68,5618.63,3416.05,'2026-06-02'),(273,18,16563.54,10280.74,6282.80,'2026-07-09'),(274,19,16248.62,10033.33,6215.29,'2026-08-19'),(275,20,5088.24,8658.89,-3570.65,'2026-09-11'),(276,21,8669.54,10768.69,-2099.15,'2026-01-21'),(277,22,8060.14,5005.94,3054.20,'2026-05-20'),(278,23,8639.78,5377.71,3262.07,'2026-12-17'),(279,24,10049.15,13934.02,-3884.87,'2026-12-18'),(280,25,7444.28,4536.87,2907.41,'2026-10-19'),(281,26,6329.18,3972.95,2356.23,'2026-12-22'),(282,27,6524.10,4104.85,2419.25,'2026-01-17'),(283,28,9061.11,12165.86,-3104.75,'2026-04-24'),(284,29,7508.48,4540.82,2967.66,'2026-02-08'),(285,30,15450.72,9698.15,5752.57,'2026-04-20'),(286,31,4057.74,2587.06,1470.68,'2026-09-03'),(287,32,5709.09,9271.39,-3562.30,'2026-10-09'),(288,33,3264.27,1949.10,1315.17,'2026-05-11'),(289,34,14997.10,9416.55,5580.55,'2026-11-12'),(290,35,9686.03,11651.25,-1965.22,'2026-06-05'),(291,36,11661.85,15026.65,-3364.80,'2026-06-19'),(292,37,9363.82,5883.87,3479.95,'2026-03-27'),(293,38,9182.55,5754.00,3428.55,'2026-01-14'),(294,39,7078.36,4405.25,2673.11,'2026-07-21'),(295,40,2577.25,5484.57,-2907.32,'2026-11-21'),(296,41,2413.51,1443.38,970.13,'2026-01-26'),(297,42,5771.68,7703.93,-1932.25,'2026-03-05'),(298,43,2952.83,1774.09,1178.74,'2026-11-19'),(299,44,5761.77,8927.16,-3165.39,'2026-05-22'),(300,45,6895.21,4311.76,2583.45,'2026-02-06'),(301,46,16226.96,10182.15,6044.81,'2026-05-19'),(302,47,13421.76,8242.47,5179.29,'2026-10-26'),(303,48,5621.50,8640.77,-3019.27,'2026-11-01'),(304,49,12044.73,14017.56,-1972.83,'2026-05-19'),(305,50,8337.96,5298.55,3039.41,'2026-04-07'),(306,51,10329.94,6429.66,3900.28,'2026-06-16'),(307,52,2305.97,5202.80,-2896.83,'2026-08-05'),(308,53,8692.42,5442.10,3250.32,'2026-04-24'),(309,54,5822.33,3683.96,2138.37,'2026-07-20'),(310,55,6319.50,3823.42,2496.08,'2026-06-13'),(311,56,7870.23,11471.09,-3600.86,'2026-09-08'),(312,57,13922.15,8644.16,5277.99,'2026-04-11'),(313,58,4700.34,2783.82,1916.52,'2026-10-15'),(314,59,11644.62,7249.35,4395.27,'2026-10-06'),(315,60,12051.12,15723.09,-3671.97,'2026-09-21'),(316,61,15069.18,9431.06,5638.12,'2026-04-16'),(317,62,11921.60,7541.05,4380.55,'2026-07-03'),(318,63,12527.10,14578.48,-2051.38,'2026-11-11'),(319,64,4019.76,6847.49,-2827.73,'2026-08-03'),(320,65,14652.97,9127.27,5525.70,'2026-01-07'),(321,66,8156.07,5164.59,2991.48,'2026-05-12'),(322,67,6108.27,3733.10,2375.17,'2026-10-24'),(323,68,9566.26,13608.04,-4041.78,'2026-08-10'),(324,69,12817.37,7934.12,4883.25,'2026-08-26'),(325,70,6276.38,8161.99,-1885.61,'2026-06-03'),(326,71,10501.39,6648.70,3852.69,'2026-09-01'),(327,72,7296.19,10679.19,-3383.00,'2026-03-23'),(328,73,15010.98,9446.75,5564.23,'2026-02-08'),(329,74,8351.92,5093.92,3258.00,'2026-12-06'),(330,75,11430.97,7128.52,4302.45,'2026-01-09'),(331,76,11896.61,15138.40,-3241.79,'2026-10-15'),(332,77,7117.19,9143.88,-2026.69,'2026-06-18'),(333,78,8272.83,5065.12,3207.71,'2026-11-27'),(334,79,12419.63,7782.49,4637.14,'2026-01-21'),(335,80,8239.93,12180.55,-3940.62,'2026-04-14'),(336,81,12484.84,7810.09,4674.75,'2026-08-17'),(337,82,8740.06,5309.30,3430.76,'2026-09-10'),(338,83,14626.15,9017.70,5608.45,'2026-04-26'),(339,84,2397.25,5439.75,-3042.50,'2026-01-28'),(340,85,10779.19,6743.24,4035.95,'2026-04-06'),(341,86,13905.67,8798.53,5107.14,'2026-12-27'),(342,87,4377.08,2575.15,1801.93,'2026-09-03'),(343,88,11389.71,15601.77,-4212.06,'2026-11-27'),(344,89,7370.89,4517.31,2853.58,'2026-05-16'),(345,90,7968.91,4953.40,3015.51,'2026-02-07'),(346,91,11313.45,13292.35,-1978.90,'2026-01-28'),(347,92,4398.39,7463.77,-3065.38,'2026-06-15'),(348,93,14964.50,9264.23,5700.27,'2026-06-12'),(349,94,2781.28,1762.50,1018.78,'2026-11-03'),(350,95,10894.68,6905.29,3989.39,'2026-10-10'),(351,96,9794.90,13279.78,-3484.88,'2026-08-12'),(352,97,11923.38,7447.05,4476.33,'2026-05-01'),(353,98,8472.28,10384.88,-1912.60,'2026-05-28'),(354,99,15467.62,9574.04,5893.58,'2026-05-16'),(355,100,5521.13,8960.61,-3439.48,'2026-04-24'),(356,101,9502.01,5886.49,3615.52,'2026-01-03'),(357,102,8894.64,5585.21,3309.43,'2026-01-20'),(358,103,12329.69,7553.33,4776.36,'2026-01-28'),(359,104,5447.12,8693.30,-3246.18,'2026-02-17'),(360,105,5581.88,7582.20,-2000.32,'2026-10-10'),(361,106,16350.56,10313.14,6037.42,'2026-07-07'),(362,107,2492.95,1527.03,965.92,'2026-06-18'),(363,108,12188.66,15481.09,-3292.43,'2026-01-24'),(364,109,9000.71,5644.19,3356.52,'2026-06-22'),(365,110,7743.49,4883.60,2859.89,'2026-04-20'),(366,111,15953.68,9928.71,6024.97,'2026-10-07'),(367,112,3431.03,6228.30,-2797.27,'2026-04-09'),(368,113,6694.65,4189.09,2505.56,'2026-11-24'),(369,114,8282.40,5052.06,3230.34,'2026-02-18'),(370,115,4382.47,2690.26,1692.21,'2026-11-09'),(371,116,11951.24,16024.75,-4073.51,'2026-02-07'),(372,117,5478.69,3367.26,2111.43,'2026-10-28'),(373,118,7277.85,4616.64,2661.21,'2026-07-20'),(374,119,5578.37,7661.67,-2083.30,'2026-10-28'),(375,120,3998.64,7410.98,-3412.34,'2026-06-21'),(376,121,11481.03,7197.26,4283.77,'2026-04-11'),(377,122,7625.92,4615.22,3010.70,'2026-11-01'),(378,123,5978.07,3761.78,2216.29,'2026-04-28'),(379,124,3393.63,6118.91,-2725.28,'2026-03-21'),(380,125,9200.78,5653.09,3547.69,'2026-04-24'),(381,126,4272.13,6373.94,-2101.81,'2026-02-13'),(382,127,13895.61,8705.19,5190.42,'2026-09-19'),(383,128,3813.84,6689.08,-2875.24,'2026-10-01'),(384,129,5325.05,3250.05,2075.00,'2026-07-06'),(385,130,11483.21,7243.71,4239.50,'2026-04-05'),(386,131,5105.34,3157.02,1948.32,'2026-02-17'),(387,132,7273.92,10673.20,-3399.28,'2026-11-17'),(388,133,7941.60,9805.10,-1863.50,'2026-06-13'),(389,134,9112.10,5756.79,3355.31,'2026-12-18'),(390,135,7789.70,4806.83,2982.87,'2026-06-16'),(391,136,3966.96,7108.14,-3141.18,'2026-06-01'),(392,137,7722.25,4764.32,2957.93,'2026-11-05'),(393,138,3732.56,2315.89,1416.67,'2026-01-09'),(394,139,10100.80,6238.06,3862.74,'2026-10-07'),(395,140,12667.15,16578.19,-3911.04,'2026-01-13'),(396,141,15971.62,9834.83,6136.79,'2026-07-18'),(397,142,13711.09,8589.66,5121.43,'2026-08-24'),(398,143,3116.91,1970.95,1145.96,'2026-12-17'),(399,144,11415.56,14907.67,-3492.11,'2026-04-12'),(400,145,11256.26,7086.88,4169.38,'2026-02-16'),(401,146,5213.45,3288.33,1925.12,'2026-10-03'),(402,147,9728.58,11677.63,-1949.05,'2026-08-25'),(403,148,5281.47,8708.11,-3426.64,'2026-08-13'),(404,149,11097.50,6824.78,4272.72,'2026-07-26'),(405,150,15020.37,9360.05,5660.32,'2026-09-04'),(406,151,14104.79,8739.62,5365.17,'2026-07-18'),(407,152,4112.45,7100.75,-2988.30,'2026-02-18'),(408,153,5040.30,2980.92,2059.38,'2026-11-15'),(409,154,9985.99,12031.33,-2045.34,'2026-07-02'),(410,155,3158.01,1935.77,1222.24,'2026-12-04'),(411,156,8660.03,12345.07,-3685.04,'2026-04-23'),(412,157,3994.25,2384.63,1609.62,'2026-11-14'),(413,158,4308.23,2560.12,1748.11,'2026-08-18'),(414,159,12308.01,7687.48,4620.53,'2026-12-05'),(415,160,2414.48,4864.78,-2450.30,'2026-04-18'),(416,161,2259.43,4126.94,-1867.51,'2026-05-15'),(417,162,4616.64,2901.37,1715.27,'2026-01-10'),(418,163,6612.01,4003.16,2608.85,'2026-08-13'),(419,164,11357.24,15070.52,-3713.28,'2026-12-01'),(420,165,14258.92,8922.06,5336.86,'2026-02-16'),(421,166,15627.05,9645.74,5981.31,'2026-06-16'),(422,167,6891.48,4382.22,2509.26,'2026-08-10'),(423,168,5613.07,8995.96,-3382.89,'2026-11-05'),(424,169,5746.42,3564.00,2182.42,'2026-08-18'),(425,170,11638.41,7366.78,4271.63,'2026-04-09'),(426,171,13872.71,8535.42,5337.29,'2026-11-20'),(427,172,5367.35,8308.54,-2941.19,'2026-06-12'),(428,173,4906.37,3104.36,1802.01,'2026-08-12'),(429,174,4934.83,2908.02,2026.81,'2026-09-09'),(430,175,3585.01,5478.17,-1893.16,'2026-06-14'),(431,176,9117.18,12693.11,-3575.93,'2026-01-01'),(432,177,12551.06,7742.94,4808.12,'2026-01-03'),(433,178,13028.55,8076.74,4951.81,'2026-07-10'),(434,179,12120.48,7597.07,4523.41,'2026-08-04'),(435,180,2873.56,6259.65,-3386.09,'2026-01-20'),(436,181,6283.25,3790.63,2492.62,'2026-02-12'),(437,182,4267.74,6199.09,-1931.35,'2026-10-25'),(438,183,5406.37,3257.89,2148.48,'2026-09-25'),(439,184,11981.17,15958.99,-3977.82,'2026-03-15'),(440,185,3757.78,2261.71,1496.07,'2026-12-01'),(441,186,5383.40,3307.88,2075.52,'2026-10-12'),(442,187,13716.98,8667.46,5049.52,'2026-04-26'),(443,188,1910.43,4908.98,-2998.55,'2026-12-13'),(444,189,7077.89,9023.59,-1945.70,'2026-01-14'),(445,190,3160.03,2005.65,1154.38,'2026-05-28'),(446,191,12648.11,8003.12,4644.99,'2026-04-02'),(447,192,11074.49,14677.53,-3603.04,'2026-12-07'),(448,193,7290.02,4470.08,2819.94,'2026-05-11'),(449,194,13907.95,8613.82,5294.13,'2026-03-18'),(450,195,11355.92,6993.60,4362.32,'2026-11-26'),(451,196,10142.01,14180.83,-4038.82,'2026-07-04'),(452,197,13965.82,8614.59,5351.23,'2026-08-09'),(453,198,2536.91,1406.56,1130.35,'2026-05-01'),(454,199,9837.66,6032.34,3805.32,'2026-11-12'),(455,200,8066.48,11194.77,-3128.29,'2026-05-21'),(457,202,416.19,2.00,414.19,'2026-09-02');
/*!40000 ALTER TABLE `profit_loss` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER profit_loss_before_insert
BEFORE INSERT ON profit_loss
FOR EACH ROW
BEGIN
    SET NEW.profit_loss_amount = NEW.revenue_amount - NEW.total_cost_amount;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER profit_loss_before_update
BEFORE UPDATE ON profit_loss
FOR EACH ROW
BEGIN
    SET NEW.profit_loss_amount = NEW.revenue_amount - NEW.total_cost_amount;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `profit_loss_reason_map`
--

DROP TABLE IF EXISTS `profit_loss_reason_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profit_loss_reason_map` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pl_id` int(11) NOT NULL,
  `reason_id` int(11) NOT NULL,
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pl_id` (`pl_id`),
  KEY `reason_id` (`reason_id`),
  CONSTRAINT `profit_loss_reason_map_ibfk_1` FOREIGN KEY (`pl_id`) REFERENCES `profit_loss` (`pl_id`),
  CONSTRAINT `profit_loss_reason_map_ibfk_2` FOREIGN KEY (`reason_id`) REFERENCES `loss_reasons` (`reason_id`)
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profit_loss_reason_map`
--

LOCK TABLES `profit_loss_reason_map` WRITE;
/*!40000 ALTER TABLE `profit_loss_reason_map` DISABLE KEYS */;
INSERT INTO `profit_loss_reason_map` VALUES (16,259,4,'Automated incident log'),(17,262,7,'Automated incident log'),(18,263,8,'Automated incident log'),(19,267,4,'Automated incident log'),(20,269,6,'Automated incident log'),(21,271,8,'Automated incident log'),(22,275,4,'Automated incident log'),(23,276,5,'Automated incident log'),(24,279,8,'Automated incident log'),(25,283,4,'Automated incident log'),(26,287,8,'Automated incident log'),(27,290,3,'Automated incident log'),(28,291,4,'Automated incident log'),(29,295,8,'Automated incident log'),(30,297,2,'Automated incident log'),(31,299,4,'Automated incident log'),(32,303,8,'Automated incident log'),(33,304,1,'Automated incident log'),(34,307,4,'Automated incident log'),(35,311,8,'Automated incident log'),(36,315,4,'Automated incident log'),(37,318,7,'Automated incident log'),(38,319,8,'Automated incident log'),(39,323,4,'Automated incident log'),(40,325,6,'Automated incident log'),(41,327,8,'Automated incident log'),(42,331,4,'Automated incident log'),(43,332,5,'Automated incident log'),(44,335,8,'Automated incident log'),(45,339,4,'Automated incident log'),(46,343,8,'Automated incident log'),(47,346,3,'Automated incident log'),(48,347,4,'Automated incident log'),(49,351,8,'Automated incident log'),(50,353,2,'Automated incident log'),(51,355,4,'Automated incident log'),(52,359,8,'Automated incident log'),(53,360,1,'Automated incident log'),(54,363,4,'Automated incident log'),(55,367,8,'Automated incident log'),(56,371,4,'Automated incident log'),(57,374,7,'Automated incident log'),(58,375,8,'Automated incident log'),(59,379,4,'Automated incident log'),(60,381,6,'Automated incident log'),(61,383,8,'Automated incident log'),(62,387,4,'Automated incident log'),(63,388,5,'Automated incident log'),(64,391,8,'Automated incident log'),(65,395,4,'Automated incident log'),(66,399,8,'Automated incident log'),(67,402,3,'Automated incident log'),(68,403,4,'Automated incident log'),(69,407,8,'Automated incident log'),(70,409,2,'Automated incident log'),(71,411,4,'Automated incident log'),(72,415,8,'Automated incident log'),(73,416,1,'Automated incident log'),(74,419,4,'Automated incident log'),(75,423,8,'Automated incident log'),(76,427,4,'Automated incident log'),(77,430,7,'Automated incident log'),(78,431,8,'Automated incident log'),(79,435,4,'Automated incident log'),(80,437,6,'Automated incident log'),(81,439,8,'Automated incident log'),(82,443,4,'Automated incident log'),(83,444,5,'Automated incident log'),(84,447,8,'Automated incident log'),(85,451,4,'Automated incident log'),(86,455,8,'Automated incident log');
/*!40000 ALTER TABLE `profit_loss_reason_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profitability_result`
--

DROP TABLE IF EXISTS `profitability_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profitability_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `period` varchar(20) DEFAULT NULL,
  `revenue` decimal(12,2) DEFAULT NULL,
  `direct_cogs` decimal(12,2) DEFAULT NULL,
  `allocated_logistics_cost` decimal(12,2) DEFAULT NULL,
  `net_profit` decimal(12,2) DEFAULT NULL,
  `profit_margin_pct` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `profitability_result_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profitability_result`
--

LOCK TABLES `profitability_result` WRITE;
/*!40000 ALTER TABLE `profitability_result` DISABLE KEYS */;
INSERT INTO `profitability_result` VALUES (1,1,'2026-Q3',500000.00,300000.00,50000.00,150000.00,30.00);
/*!40000 ALTER TABLE `profitability_result` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER profitability_margin_check
BEFORE INSERT ON profitability_result
FOR EACH ROW
BEGIN
    SET NEW.net_profit = NEW.revenue - NEW.direct_cogs - NEW.allocated_logistics_cost;
    IF NEW.revenue > 0 THEN
        SET NEW.profit_margin_pct = ROUND((NEW.net_profit / NEW.revenue) * 100, 2);
    ELSE
        SET NEW.profit_margin_pct = 0.00;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER profitability_margin_check_update
BEFORE UPDATE ON profitability_result
FOR EACH ROW
BEGIN
    SET NEW.net_profit = NEW.revenue - NEW.direct_cogs - NEW.allocated_logistics_cost;
    IF NEW.revenue > 0 THEN
        SET NEW.profit_margin_pct = ROUND((NEW.net_profit / NEW.revenue) * 100, 2);
    ELSE
        SET NEW.profit_margin_pct = 0.00;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Super Admin','Full system access'),(2,'Company Admin','Company level admin'),(3,'Company Staff (Ops)','Operations staff'),(4,'Company Staff (Finance)','Finance staff'),(5,'Customer','End customer');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_transactions`
--

DROP TABLE IF EXISTS `sales_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `shipment_id` int(11) DEFAULT NULL,
  `quantity_sold` decimal(12,2) NOT NULL CHECK (`quantity_sold` > 0),
  `sale_price_snapshot` decimal(12,2) NOT NULL,
  `sale_amount` decimal(12,2) DEFAULT NULL,
  `sale_date` date NOT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `customer_id` (`customer_id`),
  KEY `shipment_id` (`shipment_id`),
  KEY `idx_sales_product` (`product_id`),
  KEY `idx_sales_date` (`sale_date`),
  CONSTRAINT `sales_transactions_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `sales_transactions_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `sales_transactions_ibfk_3` FOREIGN KEY (`shipment_id`) REFERENCES `shipment` (`shipment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_transactions`
--

LOCK TABLES `sales_transactions` WRITE;
/*!40000 ALTER TABLE `sales_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sales_transactions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER sales_amount_before_insert
BEFORE INSERT ON sales_transactions
FOR EACH ROW
BEGIN
    SET NEW.sale_amount = NEW.quantity_sold * NEW.sale_price_snapshot;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sales_trend_result`
--

DROP TABLE IF EXISTS `sales_trend_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_trend_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `period` varchar(20) DEFAULT NULL,
  `actual_sales` decimal(12,2) DEFAULT NULL,
  `moving_avg` decimal(12,2) DEFAULT NULL,
  `trend_label` enum('Growing','Declining','Stable') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `sales_trend_result_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_trend_result`
--

LOCK TABLES `sales_trend_result` WRITE;
/*!40000 ALTER TABLE `sales_trend_result` DISABLE KEYS */;
INSERT INTO `sales_trend_result` VALUES (1,1,'2026-Q3',250.00,230.00,'Growing');
/*!40000 ALTER TABLE `sales_trend_result` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipment`
--

DROP TABLE IF EXISTS `shipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipment` (
  `shipment_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `container_id` int(11) NOT NULL,
  `origin_port_id` int(11) NOT NULL,
  `destination_port_id` int(11) NOT NULL,
  `vessel_id` int(11) DEFAULT NULL,
  `booking_date` date NOT NULL,
  `cargo_description` varchar(255) DEFAULT NULL,
  `cargo_weight_kg` decimal(10,2) DEFAULT NULL CHECK (`cargo_weight_kg` >= 0),
  `cargo_volume_cbm` decimal(10,2) DEFAULT NULL CHECK (`cargo_volume_cbm` >= 0),
  `cargo_declared_value` decimal(12,2) DEFAULT NULL CHECK (`cargo_declared_value` >= 0),
  `freight_cost` decimal(12,2) DEFAULT 0.00,
  `insurance_cost` decimal(12,2) DEFAULT 0.00,
  `other_charges` decimal(12,2) DEFAULT 0.00,
  `status` enum('Booked','Container Allocated','Departed','In Transit','Customs Hold','Arrived','Delivered','Cancelled') DEFAULT 'Booked',
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`shipment_id`),
  KEY `container_id` (`container_id`),
  KEY `origin_port_id` (`origin_port_id`),
  KEY `destination_port_id` (`destination_port_id`),
  KEY `vessel_id` (`vessel_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_shipment_status` (`status`),
  KEY `idx_shipment_customer` (`customer_id`),
  KEY `idx_shipment_dates` (`booking_date`),
  CONSTRAINT `shipment_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `shipment_ibfk_2` FOREIGN KEY (`container_id`) REFERENCES `containers` (`container_id`),
  CONSTRAINT `shipment_ibfk_3` FOREIGN KEY (`origin_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `shipment_ibfk_4` FOREIGN KEY (`destination_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `shipment_ibfk_5` FOREIGN KEY (`vessel_id`) REFERENCES `vessels` (`vessel_id`),
  CONSTRAINT `shipment_ibfk_6` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipment`
--

LOCK TABLES `shipment` WRITE;
/*!40000 ALTER TABLE `shipment` DISABLE KEYS */;
INSERT INTO `shipment` VALUES (1,17,108,26,22,23,'2026-04-07',NULL,NULL,NULL,NULL,5183.40,384.83,201.29,'Booked',0),(2,40,29,8,25,34,'2026-04-23',NULL,NULL,NULL,NULL,7090.12,423.04,57.82,'Arrived',0),(3,7,82,24,23,38,'2026-08-16',NULL,NULL,NULL,NULL,8078.10,454.40,75.79,'In Transit',0),(4,34,174,24,15,36,'2026-05-03',NULL,NULL,NULL,NULL,1906.79,345.19,51.04,'Departed',0),(5,17,122,20,22,6,'2026-01-03',NULL,NULL,NULL,NULL,1334.72,251.50,79.65,'Departed',0),(6,13,287,1,2,36,'2026-07-23',NULL,NULL,NULL,NULL,2091.19,380.60,298.94,'Departed',0),(7,19,284,26,14,19,'2026-08-07',NULL,NULL,NULL,NULL,1209.09,419.95,125.81,'Delivered',0),(8,23,251,5,12,30,'2026-01-13',NULL,NULL,NULL,NULL,7951.07,116.31,56.56,'Arrived',0),(9,25,14,8,21,22,'2026-09-12',NULL,NULL,NULL,NULL,3262.10,127.12,204.96,'Departed',0),(10,38,24,9,13,31,'2026-10-23',NULL,NULL,NULL,NULL,1373.99,199.73,255.14,'Arrived',0),(11,15,245,2,17,50,'2026-10-01',NULL,NULL,NULL,NULL,5533.03,486.50,71.72,'Departed',0),(12,4,18,18,23,15,'2026-12-23',NULL,NULL,NULL,NULL,3482.03,258.87,59.75,'Container Allocated',0),(13,33,101,6,25,18,'2026-02-12',NULL,NULL,NULL,NULL,6889.98,173.88,105.43,'In Transit',0),(14,18,94,24,25,4,'2026-06-12',NULL,NULL,NULL,NULL,5155.52,306.59,291.36,'Container Allocated',0),(15,36,158,23,11,15,'2026-09-07',NULL,NULL,NULL,NULL,7676.27,267.83,299.76,'Customs Hold',0),(16,37,111,6,29,34,'2026-01-25',NULL,NULL,NULL,NULL,8349.58,481.15,256.23,'Booked',0),(17,25,176,27,19,41,'2026-06-02',NULL,NULL,NULL,NULL,5149.13,284.15,185.35,'Container Allocated',0),(18,15,269,6,18,27,'2026-07-09',NULL,NULL,NULL,NULL,9732.42,438.51,109.81,'Arrived',0),(19,6,205,16,5,19,'2026-08-19',NULL,NULL,NULL,NULL,9573.08,397.09,63.16,'Arrived',0),(20,30,17,22,29,45,'2026-09-11',NULL,NULL,NULL,NULL,3827.05,293.67,297.82,'In Transit',0),(21,19,298,5,25,16,'2026-01-21',NULL,NULL,NULL,NULL,6594.65,422.69,265.20,'Customs Hold',0),(22,15,199,2,7,27,'2026-05-20',NULL,NULL,NULL,NULL,4544.79,276.13,185.02,'Departed',0),(23,31,147,20,22,29,'2026-12-17',NULL,NULL,NULL,NULL,4734.92,463.77,179.02,'Delivered',0),(24,28,157,21,15,49,'2026-12-18',NULL,NULL,NULL,NULL,7955.39,163.07,212.64,'Arrived',0),(25,13,223,9,23,35,'2026-10-19',NULL,NULL,NULL,NULL,4088.23,351.68,96.96,'Delivered',0),(26,19,98,8,27,11,'2026-12-22',NULL,NULL,NULL,NULL,3473.34,259.76,239.85,'Booked',0),(27,32,261,4,16,23,'2026-01-17',NULL,NULL,NULL,NULL,3556.91,301.66,246.28,'In Transit',0),(28,4,10,26,26,13,'2026-04-24',NULL,NULL,NULL,NULL,6873.35,461.89,124.81,'Container Allocated',0),(29,30,270,8,6,49,'2026-02-08',NULL,NULL,NULL,NULL,4346.70,116.06,78.06,'Delivered',0),(30,34,5,12,20,42,'2026-04-20',NULL,NULL,NULL,NULL,9103.76,363.00,231.39,'Arrived',0),(31,2,27,10,30,3,'2026-09-03',NULL,NULL,NULL,NULL,1885.23,434.96,266.87,'In Transit',0),(32,10,212,18,6,43,'2026-10-09',NULL,NULL,NULL,NULL,4429.23,187.52,240.55,'Customs Hold',0),(33,21,300,29,20,24,'2026-05-11',NULL,NULL,NULL,NULL,1664.26,135.66,149.18,'Container Allocated',0),(34,17,18,11,21,29,'2026-11-12',NULL,NULL,NULL,NULL,8938.26,234.21,244.08,'Booked',0),(35,25,231,16,23,46,'2026-06-05',NULL,NULL,NULL,NULL,7583.24,246.10,108.67,'Delivered',0),(36,30,280,8,30,41,'2026-06-19',NULL,NULL,NULL,NULL,9139.35,286.60,68.15,'Booked',0),(37,24,189,21,9,25,'2026-03-27',NULL,NULL,NULL,NULL,5269.91,376.85,237.11,'In Transit',0),(38,9,6,2,3,23,'2026-01-14',NULL,NULL,NULL,NULL,5140.87,393.32,219.81,'Container Allocated',0),(39,14,104,27,1,37,'2026-07-21',NULL,NULL,NULL,NULL,3779.10,437.46,188.69,'Arrived',0),(40,34,23,30,2,46,'2026-11-21',NULL,NULL,NULL,NULL,1630.12,472.48,238.26,'Booked',0),(41,3,235,14,3,18,'2026-01-26',NULL,NULL,NULL,NULL,1113.75,153.43,176.20,'Customs Hold',0),(42,33,120,3,2,49,'2026-03-05',NULL,NULL,NULL,NULL,4421.85,248.31,180.46,'Arrived',0),(43,35,163,29,28,46,'2026-11-19',NULL,NULL,NULL,NULL,1182.98,444.30,146.81,'Delivered',0),(44,19,244,28,8,31,'2026-05-22',NULL,NULL,NULL,NULL,4513.67,143.51,109.63,'Booked',0),(45,21,273,17,28,29,'2026-02-06',NULL,NULL,NULL,NULL,3841.03,246.41,224.32,'Arrived',0),(46,19,108,15,17,48,'2026-05-19',NULL,NULL,NULL,NULL,9489.94,472.19,220.02,'Departed',0),(47,7,9,5,18,17,'2026-10-26',NULL,NULL,NULL,NULL,7931.07,253.94,57.46,'Departed',0),(48,34,57,28,27,7,'2026-11-01',NULL,NULL,NULL,NULL,4175.84,379.35,158.11,'In Transit',0),(49,37,72,17,4,48,'2026-05-19',NULL,NULL,NULL,NULL,9502.64,229.63,275.96,'Departed',0),(50,24,192,2,18,39,'2026-04-07',NULL,NULL,NULL,NULL,4662.15,337.73,298.67,'Container Allocated',0),(51,16,71,18,22,20,'2026-06-16',NULL,NULL,NULL,NULL,6115.94,118.14,195.58,'In Transit',0),(52,17,17,17,29,26,'2026-08-05',NULL,NULL,NULL,NULL,1609.13,264.62,165.85,'Delivered',0),(53,28,50,24,13,26,'2026-04-24',NULL,NULL,NULL,NULL,4920.49,299.04,222.57,'Departed',0),(54,13,91,9,9,38,'2026-07-20',NULL,NULL,NULL,NULL,3191.27,220.77,271.92,'Departed',0),(55,40,2,28,4,15,'2026-06-13',NULL,NULL,NULL,NULL,3406.43,325.46,91.53,'In Transit',0),(56,40,40,23,1,6,'2026-09-08',NULL,NULL,NULL,NULL,6059.91,306.78,240.06,'Arrived',0),(57,9,259,1,16,8,'2026-04-11',NULL,NULL,NULL,NULL,8128.52,379.94,135.70,'Booked',0),(58,33,245,20,10,42,'2026-10-15',NULL,NULL,NULL,NULL,2269.36,455.76,58.70,'Container Allocated',0),(59,8,258,6,13,14,'2026-10-06',NULL,NULL,NULL,NULL,6675.06,405.59,168.70,'Booked',0),(60,28,206,18,28,18,'2026-09-21',NULL,NULL,NULL,NULL,9612.79,119.38,84.52,'Departed',0),(61,8,14,7,4,1,'2026-04-16',NULL,NULL,NULL,NULL,8929.43,292.61,209.02,'In Transit',0),(62,12,202,13,18,35,'2026-07-03',NULL,NULL,NULL,NULL,6822.96,433.64,284.45,'Delivered',0),(63,25,253,24,25,14,'2026-11-11',NULL,NULL,NULL,NULL,9804.59,321.37,174.05,'Arrived',0),(64,27,52,12,20,41,'2026-08-03',NULL,NULL,NULL,NULL,3106.07,145.21,58.37,'Booked',0),(65,27,204,8,20,22,'2026-01-07',NULL,NULL,NULL,NULL,8541.66,429.22,156.39,'Customs Hold',0),(66,7,247,14,21,1,'2026-05-12',NULL,NULL,NULL,NULL,4522.91,364.79,276.89,'Arrived',0),(67,8,98,22,15,45,'2026-10-24',NULL,NULL,NULL,NULL,3282.16,316.47,134.47,'Delivered',0),(68,12,15,19,2,10,'2026-08-10',NULL,NULL,NULL,NULL,7617.64,108.48,249.78,'Arrived',0),(69,24,8,26,24,32,'2026-08-26',NULL,NULL,NULL,NULL,7500.54,309.16,124.42,'Booked',0),(70,10,3,8,15,28,'2026-06-03',NULL,NULL,NULL,NULL,4889.35,185.15,129.46,'Delivered',0),(71,2,83,27,12,42,'2026-09-01',NULL,NULL,NULL,NULL,5902.54,464.84,281.32,'Delivered',0),(72,5,170,19,21,19,'2026-03-23',NULL,NULL,NULL,NULL,5747.90,147.91,134.15,'Booked',0),(73,25,203,28,22,44,'2026-02-08',NULL,NULL,NULL,NULL,8883.58,302.67,260.50,'Booked',0),(74,25,172,23,5,33,'2026-12-06',NULL,NULL,NULL,NULL,4779.91,220.02,93.99,'Arrived',0),(75,24,200,12,7,30,'2026-01-09',NULL,NULL,NULL,NULL,6488.69,462.02,177.81,'In Transit',0),(76,28,48,14,26,40,'2026-10-15',NULL,NULL,NULL,NULL,9156.15,467.91,93.60,'Customs Hold',0),(77,13,75,1,4,48,'2026-06-18',NULL,NULL,NULL,NULL,5410.78,350.20,159.30,'In Transit',0),(78,28,261,21,29,34,'2026-11-27',NULL,NULL,NULL,NULL,4698.82,253.97,112.33,'Departed',0),(79,34,131,19,13,43,'2026-01-21',NULL,NULL,NULL,NULL,7318.55,236.05,227.89,'Booked',0),(80,21,124,27,29,50,'2026-04-14',NULL,NULL,NULL,NULL,6507.06,150.58,270.29,'Departed',0),(81,23,247,12,14,27,'2026-08-17',NULL,NULL,NULL,NULL,7215.33,391.74,203.02,'Container Allocated',0),(82,23,172,24,27,12,'2026-09-10',NULL,NULL,NULL,NULL,4864.25,392.07,52.98,'Departed',0),(83,16,62,6,19,23,'2026-04-26',NULL,NULL,NULL,NULL,8554.42,397.26,66.02,'Container Allocated',0),(84,16,171,21,7,20,'2026-01-28',NULL,NULL,NULL,NULL,1711.67,234.32,194.00,'Delivered',0),(85,3,153,10,13,19,'2026-04-06',NULL,NULL,NULL,NULL,6286.81,238.17,218.26,'Customs Hold',0),(86,12,97,28,2,10,'2026-12-27','d',0.40,0.00,0.00,8108.17,390.75,299.61,'Container Allocated',0),(87,11,228,14,21,1,'2026-09-03',NULL,NULL,NULL,NULL,2312.87,189.61,72.67,'Booked',0),(88,3,81,7,14,30,'2026-11-27',NULL,NULL,NULL,NULL,9036.40,164.08,272.18,'Customs Hold',0),(89,12,218,18,4,7,'2026-05-16',NULL,NULL,NULL,NULL,4078.12,312.85,126.34,'Delivered',0),(90,38,228,19,12,20,'2026-02-07',NULL,NULL,NULL,NULL,4371.82,401.08,180.50,'Arrived',0),(91,10,221,26,13,48,'2026-01-28',NULL,NULL,NULL,NULL,8897.64,245.15,284.59,'Departed',0),(92,2,1,12,4,27,'2026-06-15',NULL,NULL,NULL,NULL,3358.85,200.66,136.95,'Departed',0),(93,18,230,25,25,41,'2026-06-12',NULL,NULL,NULL,NULL,8788.18,374.19,101.86,'Container Allocated',0),(94,30,50,6,1,37,'2026-11-03',NULL,NULL,NULL,NULL,1372.16,123.68,266.66,'Delivered',0),(95,15,187,19,3,42,'2026-10-10',NULL,NULL,NULL,NULL,6202.29,407.75,295.25,'Customs Hold',0),(96,29,15,1,3,39,'2026-08-12',NULL,NULL,NULL,NULL,7580.33,341.41,170.38,'In Transit',0),(97,30,265,6,9,15,'2026-05-01',NULL,NULL,NULL,NULL,6974.09,271.63,201.33,'In Transit',0),(98,17,50,28,3,39,'2026-05-28',NULL,NULL,NULL,NULL,6652.86,194.40,223.28,'Container Allocated',0),(99,9,299,18,3,37,'2026-05-16',NULL,NULL,NULL,NULL,9122.02,354.74,97.28,'In Transit',0),(100,21,152,24,1,47,'2026-04-24',NULL,NULL,NULL,NULL,4131.44,340.91,266.62,'Delivered',0),(101,7,141,3,9,50,'2026-01-03',NULL,NULL,NULL,NULL,5564.51,152.37,169.61,'In Transit',0),(102,8,217,6,28,19,'2026-01-20',NULL,NULL,NULL,NULL,4880.69,479.12,225.40,'Departed',0),(103,30,146,6,23,38,'2026-01-28',NULL,NULL,NULL,NULL,7204.27,298.50,50.56,'Container Allocated',0),(104,20,118,10,15,24,'2026-02-17',NULL,NULL,NULL,NULL,4070.86,341.80,213.61,'Container Allocated',0),(105,5,121,20,12,28,'2026-10-10',NULL,NULL,NULL,NULL,4186.61,334.47,145.02,'Container Allocated',0),(106,33,40,21,18,35,'2026-07-07',NULL,NULL,NULL,NULL,9739.39,286.59,287.16,'Departed',0),(107,36,90,24,22,24,'2026-06-18',NULL,NULL,NULL,NULL,1024.61,303.56,198.86,'Arrived',0),(108,31,198,4,14,22,'2026-01-24',NULL,NULL,NULL,NULL,9379.01,481.41,105.55,'Departed',0),(109,31,109,5,27,34,'2026-06-22',NULL,NULL,NULL,NULL,5237.80,165.35,241.04,'Booked',0),(110,19,263,15,10,10,'2026-04-20',NULL,NULL,NULL,NULL,4275.94,351.81,255.85,'Arrived',0),(111,25,83,9,24,40,'2026-10-07',NULL,NULL,NULL,NULL,9368.06,418.55,142.10,'Container Allocated',0),(112,20,30,8,27,24,'2026-04-09',NULL,NULL,NULL,NULL,2575.21,203.68,86.22,'Customs Hold',0),(113,32,235,8,10,25,'2026-11-24',NULL,NULL,NULL,NULL,3642.02,325.36,221.71,'Container Allocated',0),(114,22,257,14,16,35,'2026-02-18',NULL,NULL,NULL,NULL,4582.01,386.61,83.44,'In Transit',0),(115,20,242,28,28,48,'2026-11-09',NULL,NULL,NULL,NULL,2073.38,451.92,164.96,'Customs Hold',0),(116,37,53,27,5,23,'2026-02-07',NULL,NULL,NULL,NULL,9468.54,186.20,226.35,'In Transit',0),(117,28,172,29,4,38,'2026-10-28',NULL,NULL,NULL,NULL,2734.98,480.59,151.69,'Container Allocated',0),(118,34,173,1,15,19,'2026-07-20',NULL,NULL,NULL,NULL,4086.69,240.51,289.44,'Container Allocated',0),(119,37,181,12,15,5,'2026-10-28',NULL,NULL,NULL,NULL,4086.10,437.02,178.45,'Arrived',0),(120,12,208,23,16,28,'2026-06-21',NULL,NULL,NULL,NULL,3105.96,127.42,219.41,'Container Allocated',0),(121,4,100,14,4,8,'2026-04-11',NULL,NULL,NULL,NULL,6619.90,354.26,223.10,'Container Allocated',0),(122,39,230,16,21,16,'2026-11-01',NULL,NULL,NULL,NULL,4395.07,143.44,76.71,'Delivered',0),(123,11,252,3,25,48,'2026-04-28',NULL,NULL,NULL,NULL,3224.99,289.94,246.85,'Booked',0),(124,18,201,7,11,25,'2026-03-21',NULL,NULL,NULL,NULL,2532.21,217.14,71.55,'Customs Hold',0),(125,32,47,28,13,27,'2026-04-24',NULL,NULL,NULL,NULL,5115.97,432.57,104.55,'Container Allocated',0),(126,21,121,27,27,20,'2026-02-13',NULL,NULL,NULL,NULL,2996.43,474.20,172.02,'Container Allocated',0),(127,38,258,2,4,33,'2026-09-19',NULL,NULL,NULL,NULL,8036.03,461.84,207.32,'Container Allocated',0),(128,9,226,12,29,46,'2026-10-01',NULL,NULL,NULL,NULL,2706.29,390.47,167.31,'Delivered',0),(129,35,210,17,17,5,'2026-07-06',NULL,NULL,NULL,NULL,2966.34,126.55,157.16,'Departed',0),(130,18,63,1,11,42,'2026-04-05',NULL,NULL,NULL,NULL,6558.19,422.38,263.14,'In Transit',0),(131,9,255,11,14,15,'2026-02-17',NULL,NULL,NULL,NULL,2703.37,261.61,192.04,'Customs Hold',0),(132,29,275,29,27,19,'2026-11-17',NULL,NULL,NULL,NULL,5472.41,418.31,238.70,'Customs Hold',0),(133,16,209,19,8,11,'2026-06-13',NULL,NULL,NULL,NULL,6276.75,139.58,250.09,'Booked',0),(134,20,183,14,21,17,'2026-12-18',NULL,NULL,NULL,NULL,5284.05,190.92,281.82,'Arrived',0),(135,3,25,15,3,18,'2026-06-16',NULL,NULL,NULL,NULL,4332.40,322.16,152.27,'Booked',0),(136,29,20,13,5,43,'2026-06-01',NULL,NULL,NULL,NULL,2761.31,462.45,265.82,'Departed',0),(137,18,180,14,18,4,'2026-11-05',NULL,NULL,NULL,NULL,4475.55,121.83,166.94,'In Transit',0),(138,12,185,5,20,26,'2026-01-09',NULL,NULL,NULL,NULL,1879.06,221.17,215.66,'Booked',0),(139,20,9,27,18,16,'2026-10-07',NULL,NULL,NULL,NULL,5639.21,477.65,121.20,'Booked',0),(140,39,93,8,17,23,'2026-01-13',NULL,NULL,NULL,NULL,9963.89,272.79,193.41,'Delivered',0),(141,19,263,12,6,18,'2026-07-18',NULL,NULL,NULL,NULL,9560.35,223.04,51.44,'Customs Hold',0),(142,9,248,6,2,8,'2026-08-24',NULL,NULL,NULL,NULL,8133.23,231.77,224.66,'Container Allocated',0),(143,22,26,23,7,34,'2026-12-17',NULL,NULL,NULL,NULL,1461.86,254.35,254.74,'Departed',0),(144,2,69,8,18,34,'2026-04-12',NULL,NULL,NULL,NULL,9002.45,221.63,86.96,'Arrived',0),(145,10,14,5,2,50,'2026-02-16',NULL,NULL,NULL,NULL,6528.11,301.00,257.77,'Arrived',0),(146,32,213,18,19,17,'2026-10-03',NULL,NULL,NULL,NULL,2705.02,333.12,250.19,'Booked',0),(147,20,186,19,9,43,'2026-08-25',NULL,NULL,NULL,NULL,7637.06,225.65,136.04,'Customs Hold',0),(148,18,217,16,24,21,'2026-08-13',NULL,NULL,NULL,NULL,4007.89,267.54,242.13,'Booked',0),(149,37,42,6,24,46,'2026-07-26',NULL,NULL,NULL,NULL,6375.09,358.63,91.06,'Arrived',0),(150,39,271,20,30,44,'2026-09-04',NULL,NULL,NULL,NULL,8820.97,376.66,162.42,'Booked',0),(151,40,251,3,5,1,'2026-07-18',NULL,NULL,NULL,NULL,8137.46,494.11,108.05,'Customs Hold',0),(152,22,84,4,14,28,'2026-02-18',NULL,NULL,NULL,NULL,3197.07,128.21,95.63,'Departed',0),(153,18,203,22,24,44,'2026-11-15',NULL,NULL,NULL,NULL,2610.79,317.50,52.63,'Container Allocated',0),(154,28,17,24,30,39,'2026-07-02',NULL,NULL,NULL,NULL,7734.20,341.79,203.13,'Departed',0),(155,6,15,25,14,28,'2026-12-04',NULL,NULL,NULL,NULL,1575.39,159.60,200.78,'Container Allocated',0),(156,32,8,2,9,43,'2026-04-23',NULL,NULL,NULL,NULL,6828.30,169.29,193.39,'Container Allocated',0),(157,17,74,11,29,48,'2026-11-14',NULL,NULL,NULL,NULL,1928.76,344.91,110.96,'Customs Hold',0),(158,18,77,26,9,22,'2026-08-18',NULL,NULL,NULL,NULL,2145.79,323.38,90.95,'Booked',0),(159,31,243,7,25,18,'2026-12-05',NULL,NULL,NULL,NULL,7325.73,152.63,209.12,'Arrived',0),(160,39,243,25,22,44,'2026-04-18',NULL,NULL,NULL,NULL,1622.67,342.37,64.05,'Container Allocated',0),(161,37,249,9,1,29,'2026-05-15',NULL,NULL,NULL,NULL,1626.59,206.85,63.46,'Customs Hold',0),(162,9,279,21,2,35,'2026-01-10',NULL,NULL,NULL,NULL,2306.86,358.52,235.99,'In Transit',0),(163,19,35,27,26,21,'2026-08-13',NULL,NULL,NULL,NULL,3604.51,309.85,88.80,'Arrived',0),(164,18,203,8,22,37,'2026-12-01',NULL,NULL,NULL,NULL,8999.47,175.34,134.64,'In Transit',0),(165,17,118,3,14,43,'2026-02-16',NULL,NULL,NULL,NULL,8481.58,226.96,213.52,'Container Allocated',0),(166,8,276,7,8,24,'2026-06-16',NULL,NULL,NULL,NULL,9446.34,112.56,86.84,'Customs Hold',0),(167,9,181,1,27,12,'2026-08-10',NULL,NULL,NULL,NULL,3638.02,463.13,281.07,'Delivered',0),(168,38,208,11,22,2,'2026-11-05',NULL,NULL,NULL,NULL,4295.94,246.10,213.27,'Arrived',0),(169,1,177,9,25,2,'2026-08-18',NULL,NULL,NULL,NULL,3043.01,329.43,191.56,'Delivered',0),(170,9,143,3,17,8,'2026-04-09',NULL,NULL,NULL,NULL,6696.07,378.69,292.02,'Container Allocated',0),(171,21,151,30,6,10,'2026-11-20',NULL,NULL,NULL,NULL,8224.45,242.82,68.15,'Customs Hold',0),(172,24,41,14,6,45,'2026-06-12',NULL,NULL,NULL,NULL,3872.99,481.96,180.00,'Booked',0),(173,27,60,29,1,43,'2026-08-12',NULL,NULL,NULL,NULL,2593.87,244.97,265.52,'Delivered',0),(174,16,144,18,1,44,'2026-09-09',NULL,NULL,NULL,NULL,2740.59,105.81,61.62,'Delivered',0),(175,20,248,20,12,17,'2026-06-14',NULL,NULL,NULL,NULL,2680.12,224.01,66.01,'Booked',0),(176,13,205,4,15,45,'2026-01-01',NULL,NULL,NULL,NULL,6982.77,394.51,233.25,'Booked',0),(177,22,234,6,6,30,'2026-01-03',NULL,NULL,NULL,NULL,7422.28,213.13,107.53,'Customs Hold',0),(178,2,294,2,6,20,'2026-07-10',NULL,NULL,NULL,NULL,7664.05,275.74,136.95,'Customs Hold',0),(179,5,117,22,29,24,'2026-08-04',NULL,NULL,NULL,NULL,7200.85,160.35,235.87,'Customs Hold',0),(180,2,30,22,12,15,'2026-01-20',NULL,NULL,NULL,NULL,2205.78,119.15,237.67,'Booked',0),(181,6,177,13,8,2,'2026-02-12',NULL,NULL,NULL,NULL,3341.48,371.03,78.12,'In Transit',0),(182,6,118,9,19,39,'2026-10-25',NULL,NULL,NULL,NULL,3193.38,263.68,248.73,'Arrived',0),(183,12,152,17,5,25,'2026-09-25',NULL,NULL,NULL,NULL,3024.47,118.91,114.51,'Booked',0),(184,33,116,11,18,48,'2026-03-15',NULL,NULL,NULL,NULL,9298.31,390.30,273.22,'Container Allocated',0),(185,20,45,10,27,35,'2026-12-01',NULL,NULL,NULL,NULL,1756.76,370.35,134.60,'Arrived',0),(186,30,192,5,18,49,'2026-10-12',NULL,NULL,NULL,NULL,3005.97,123.31,178.60,'Departed',0),(187,24,61,20,4,44,'2026-04-26',NULL,NULL,NULL,NULL,7995.13,384.91,287.42,'Customs Hold',0),(188,38,11,6,11,39,'2026-12-13',NULL,NULL,NULL,NULL,1284.05,270.76,207.29,'Departed',0),(189,34,124,29,17,11,'2026-01-14',NULL,NULL,NULL,NULL,5473.91,250.60,214.34,'In Transit',0),(190,16,183,18,24,18,'2026-05-28',NULL,NULL,NULL,NULL,1313.48,443.83,248.34,'Customs Hold',0),(191,17,145,18,10,4,'2026-04-02',NULL,NULL,NULL,NULL,7281.61,430.85,290.66,'Delivered',0),(192,16,78,27,18,11,'2026-12-07',NULL,NULL,NULL,NULL,8697.32,252.97,138.90,'Arrived',0),(193,12,83,30,15,48,'2026-05-11',NULL,NULL,NULL,NULL,4063.06,274.28,132.74,'Delivered',0),(194,40,234,2,5,47,'2026-03-18',NULL,NULL,NULL,NULL,8125.38,373.71,114.73,'Arrived',0),(195,10,145,2,17,39,'2026-11-26',NULL,NULL,NULL,NULL,6686.71,197.28,109.61,'In Transit',0),(196,5,84,24,13,13,'2026-07-04',NULL,NULL,NULL,NULL,7914.86,284.32,298.79,'Booked',0),(197,36,8,15,8,5,'2026-08-09',NULL,NULL,NULL,NULL,8051.35,492.89,70.35,'In Transit',0),(198,26,287,14,22,25,'2026-05-01',NULL,NULL,NULL,NULL,1133.58,215.67,57.31,'Booked',0),(199,31,85,10,28,29,'2026-11-12',NULL,NULL,NULL,NULL,5659.16,277.71,95.47,'In Transit',0),(200,2,275,24,21,13,'2026-05-21',NULL,NULL,NULL,NULL,6113.19,417.15,140.56,'Booked',0),(202,1,3,23,13,10,'2026-09-02','eeee',2.00,2.00,2.00,2.00,0.00,0.00,'Booked',1),(207,10,8,13,17,1,'2026-09-03','eeee',123.00,21.00,2.00,2.00,0.00,0.00,'In Transit',1);
/*!40000 ALTER TABLE `shipment` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER shipment_cargo_capacity_check
BEFORE INSERT ON shipment
FOR EACH ROW
BEGIN
    DECLARE v_capacity_kg DECIMAL(10,2);
    DECLARE v_capacity_cbm DECIMAL(10,2);

    SELECT goods_capacity_kg, goods_capacity_cbm INTO v_capacity_kg, v_capacity_cbm
    FROM containers WHERE container_id = NEW.container_id;

    IF NEW.cargo_weight_kg > v_capacity_kg OR NEW.cargo_volume_cbm > v_capacity_cbm THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cargo exceeds container capacity';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER shipment_delivered
AFTER UPDATE ON shipment
FOR EACH ROW
BEGIN
    IF NEW.status = 'Delivered' AND OLD.status <> 'Delivered' THEN
        UPDATE containers SET status = 'Available' WHERE container_id = NEW.container_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `stock`
--

DROP TABLE IF EXISTS `stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock` (
  `stock_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `warehouse_location` varchar(150) DEFAULT NULL,
  `quantity_on_hand` decimal(12,2) NOT NULL DEFAULT 0.00 CHECK (`quantity_on_hand` >= 0),
  `batch_no` varchar(50) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `last_updated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`stock_id`),
  KEY `idx_stock_product` (`product_id`),
  KEY `idx_stock_company` (`company_id`),
  CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`company_id`),
  CONSTRAINT `stock_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock`
--

LOCK TABLES `stock` WRITE;
/*!40000 ALTER TABLE `stock` DISABLE KEYS */;
INSERT INTO `stock` VALUES (1,11,1,'WH-5',2750.00,NULL,NULL,'2026-09-02 17:43:35'),(2,15,2,'WH-2',1762.00,NULL,NULL,'2026-09-02 17:43:35'),(3,10,3,'WH-1',940.00,NULL,NULL,'2026-09-02 17:43:35'),(4,2,4,'WH-2',3398.00,NULL,NULL,'2026-09-02 17:43:35'),(5,5,5,'WH-3',871.00,NULL,NULL,'2026-09-02 17:43:35'),(6,14,6,'WH-1',4553.00,NULL,NULL,'2026-09-02 17:43:35'),(7,15,7,'WH-2',3375.00,NULL,NULL,'2026-09-02 17:43:35'),(8,19,8,'WH-4',865.00,NULL,NULL,'2026-09-02 17:43:35'),(9,6,9,'WH-5',634.00,NULL,NULL,'2026-09-02 17:43:35'),(10,18,10,'WH-2',2463.00,NULL,NULL,'2026-09-02 17:43:35'),(11,10,11,'WH-5',1458.00,NULL,NULL,'2026-09-02 17:43:35'),(12,17,12,'WH-3',1114.00,NULL,NULL,'2026-09-02 17:43:35'),(13,12,13,'WH-3',3304.00,NULL,NULL,'2026-09-02 17:43:35'),(14,8,14,'WH-5',2512.00,NULL,NULL,'2026-09-02 17:43:35'),(15,9,15,'WH-4',437.00,NULL,NULL,'2026-09-02 17:43:35'),(16,11,16,'WH-2',4564.00,NULL,NULL,'2026-09-02 17:43:35'),(17,11,17,'WH-1',3748.00,NULL,NULL,'2026-09-02 17:43:35'),(18,20,18,'WH-5',2564.00,NULL,NULL,'2026-09-02 17:43:35'),(19,14,19,'WH-2',927.00,NULL,NULL,'2026-09-02 17:43:35'),(20,1,20,'WH-4',2039.00,NULL,NULL,'2026-09-02 17:43:35'),(21,2,21,'WH-1',748.00,NULL,NULL,'2026-09-02 17:43:35'),(22,12,22,'WH-5',1793.00,NULL,NULL,'2026-09-02 17:43:35'),(23,19,23,'WH-2',1832.00,NULL,NULL,'2026-09-02 17:43:35'),(24,7,24,'WH-5',2519.00,NULL,NULL,'2026-09-02 17:43:35'),(25,10,25,'WH-1',2440.00,NULL,NULL,'2026-09-02 17:43:35'),(26,12,26,'WH-5',2317.00,NULL,NULL,'2026-09-02 17:43:35'),(27,5,27,'WH-1',3085.00,NULL,NULL,'2026-09-02 17:43:35'),(28,8,28,'WH-1',4796.00,NULL,NULL,'2026-09-02 17:43:35'),(29,9,29,'WH-1',2211.00,NULL,NULL,'2026-09-02 17:43:35'),(30,16,30,'WH-1',1655.00,NULL,NULL,'2026-09-02 17:43:35'),(31,2,31,'WH-3',3176.00,NULL,NULL,'2026-09-02 17:43:35'),(32,7,32,'WH-5',1039.00,NULL,NULL,'2026-09-02 17:43:35'),(33,16,33,'WH-2',2772.00,NULL,NULL,'2026-09-02 17:43:35'),(34,20,34,'WH-5',953.00,NULL,NULL,'2026-09-02 17:43:35'),(35,7,35,'WH-2',3809.00,NULL,NULL,'2026-09-02 17:43:35'),(36,3,36,'WH-2',3107.00,NULL,NULL,'2026-09-02 17:43:35'),(37,14,37,'WH-4',281.00,NULL,NULL,'2026-09-02 17:43:35'),(38,18,38,'WH-4',877.00,NULL,NULL,'2026-09-02 17:43:35'),(39,16,39,'WH-5',3470.00,NULL,NULL,'2026-09-02 17:43:35'),(40,1,40,'WH-3',1197.00,NULL,NULL,'2026-09-02 17:43:35'),(41,17,41,'WH-3',2390.00,NULL,NULL,'2026-09-02 17:43:35'),(42,11,42,'WH-2',4507.00,NULL,NULL,'2026-09-02 17:43:35'),(43,7,43,'WH-4',2645.00,NULL,NULL,'2026-09-02 17:43:35'),(44,16,44,'WH-2',993.00,NULL,NULL,'2026-09-02 17:43:35'),(45,7,45,'WH-2',3157.00,NULL,NULL,'2026-09-02 17:43:35'),(46,13,46,'WH-4',3720.00,NULL,NULL,'2026-09-02 17:43:35'),(47,5,47,'WH-4',2639.00,NULL,NULL,'2026-09-02 17:43:35'),(48,16,48,'WH-1',4441.00,NULL,NULL,'2026-09-02 17:43:35'),(49,10,49,'WH-5',4236.00,NULL,NULL,'2026-09-02 17:43:35'),(50,5,50,'WH-3',1314.00,NULL,NULL,'2026-09-02 17:43:35'),(51,17,51,'WH-1',3571.00,NULL,NULL,'2026-09-02 17:43:35'),(52,15,52,'WH-3',1326.00,NULL,NULL,'2026-09-02 17:43:35'),(53,5,53,'WH-3',1857.00,NULL,NULL,'2026-09-02 17:43:35'),(54,9,54,'WH-1',594.00,NULL,NULL,'2026-09-02 17:43:35'),(55,14,55,'WH-5',3512.00,NULL,NULL,'2026-09-02 17:43:35'),(56,2,56,'WH-4',925.00,NULL,NULL,'2026-09-02 17:43:35'),(57,13,57,'WH-3',3138.00,NULL,NULL,'2026-09-02 17:43:35'),(58,5,58,'WH-3',757.00,NULL,NULL,'2026-09-02 17:43:35'),(59,9,59,'WH-2',4739.00,NULL,NULL,'2026-09-02 17:43:35'),(60,9,60,'WH-2',282.00,NULL,NULL,'2026-09-02 17:43:35'),(61,19,61,'WH-5',4690.00,NULL,NULL,'2026-09-02 17:43:35'),(62,19,62,'WH-2',2560.00,NULL,NULL,'2026-09-02 17:43:35'),(63,10,63,'WH-3',883.00,NULL,NULL,'2026-09-02 17:43:35'),(64,19,64,'WH-5',4423.00,NULL,NULL,'2026-09-02 17:43:35'),(65,9,65,'WH-2',4895.00,NULL,NULL,'2026-09-02 17:43:35'),(66,11,66,'WH-5',2990.00,NULL,NULL,'2026-09-02 17:43:35'),(67,1,67,'WH-4',960.00,NULL,NULL,'2026-09-02 17:43:35'),(68,4,68,'WH-1',2140.00,NULL,NULL,'2026-09-02 17:43:35'),(69,15,69,'WH-3',2393.00,NULL,NULL,'2026-09-02 17:43:35'),(70,17,70,'WH-2',3673.00,NULL,NULL,'2026-09-02 17:43:35'),(71,5,71,'WH-5',1404.00,NULL,NULL,'2026-09-02 17:43:35'),(72,3,72,'WH-5',4683.00,NULL,NULL,'2026-09-02 17:43:35'),(73,9,73,'WH-1',2498.00,NULL,NULL,'2026-09-02 17:43:35'),(74,10,74,'WH-2',2352.00,NULL,NULL,'2026-09-02 17:43:35'),(75,11,75,'WH-2',539.00,NULL,NULL,'2026-09-02 17:43:35'),(76,6,76,'WH-5',2195.00,NULL,NULL,'2026-09-02 17:43:35'),(77,20,77,'WH-1',3914.00,NULL,NULL,'2026-09-02 17:43:35'),(78,1,78,'WH-4',333.00,NULL,NULL,'2026-09-02 17:43:35'),(79,2,79,'WH-4',576.00,NULL,NULL,'2026-09-02 17:43:35'),(80,3,80,'WH-1',3551.00,NULL,NULL,'2026-09-02 17:43:35'),(81,2,81,'WH-1',4083.00,NULL,NULL,'2026-09-02 17:43:35'),(82,20,82,'WH-3',112.00,NULL,NULL,'2026-09-02 17:43:35'),(83,11,83,'WH-3',4466.00,NULL,NULL,'2026-09-02 17:43:35'),(84,14,84,'WH-3',3625.00,NULL,NULL,'2026-09-02 17:43:35'),(85,11,85,'WH-3',462.00,NULL,NULL,'2026-09-02 17:43:35'),(86,18,86,'WH-5',3680.00,NULL,NULL,'2026-09-02 17:43:35'),(87,4,87,'WH-3',1997.00,NULL,NULL,'2026-09-02 17:43:35'),(88,12,88,'WH-1',2653.00,NULL,NULL,'2026-09-02 17:43:35'),(89,8,89,'WH-3',2252.00,NULL,NULL,'2026-09-02 17:43:35'),(90,7,90,'WH-5',2239.00,NULL,NULL,'2026-09-02 17:43:35'),(91,15,91,'WH-1',1456.00,NULL,NULL,'2026-09-02 17:43:35'),(92,3,92,'WH-5',174.00,NULL,NULL,'2026-09-02 17:43:35'),(93,4,93,'WH-1',3677.00,NULL,NULL,'2026-09-02 17:43:35'),(94,3,94,'WH-4',2591.00,NULL,NULL,'2026-09-02 17:43:35'),(95,13,95,'WH-1',488.00,NULL,NULL,'2026-09-02 17:43:35'),(96,17,96,'WH-4',3075.00,NULL,NULL,'2026-09-02 17:43:35'),(97,10,97,'WH-4',955.00,NULL,NULL,'2026-09-02 17:43:35'),(98,17,98,'WH-3',1788.00,NULL,NULL,'2026-09-02 17:43:35'),(99,14,99,'WH-5',2550.00,NULL,NULL,'2026-09-02 17:43:35'),(100,6,100,'WH-1',4937.00,NULL,NULL,'2026-09-02 17:43:35');
/*!40000 ALTER TABLE `stock` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER stock_check_quantity
BEFORE INSERT ON stock
FOR EACH ROW
BEGIN
    IF NEW.quantity_on_hand < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER stock_check_quantity_update
BEFORE UPDATE ON stock
FOR EACH ROW
BEGIN
    IF NEW.quantity_on_hand < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock quantity cannot go negative';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER stock_after_update_ledger
AFTER UPDATE ON stock
FOR EACH ROW
BEGIN
    IF NEW.quantity_on_hand <> OLD.quantity_on_hand THEN
        INSERT INTO inventory_ledger (product_id, transaction_type, quantity, reference_type, reference_id)
        VALUES (NEW.product_id, 'ADJUSTMENT', NEW.quantity_on_hand - OLD.quantity_on_hand, 'StockUpdate', NEW.stock_id);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `stock_upload_log`
--

DROP TABLE IF EXISTS `stock_upload_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_upload_log` (
  `upload_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `total_records` int(11) DEFAULT 0,
  `success_count` int(11) DEFAULT 0,
  `failure_count` int(11) DEFAULT 0,
  `error_report_path` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`upload_id`),
  KEY `company_id` (`company_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `stock_upload_log_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`company_id`),
  CONSTRAINT `stock_upload_log_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_upload_log`
--

LOCK TABLES `stock_upload_log` WRITE;
/*!40000 ALTER TABLE `stock_upload_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_upload_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(64) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `status` enum('Active','Inactive','Locked') DEFAULT 'Active',
  `failed_login_count` int(11) DEFAULT 0,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_role` (`role_id`),
  KEY `idx_users_company` (`company_id`),
  KEY `idx_users_status` (`status`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','admin@nlogistic.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','1234567890',1,NULL,'Active',0,'2026-09-03 23:41:43','2026-09-02 17:43:35','2026-09-03 23:41:43'),(2,'jdoe','jdoe@comp1.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1000',2,1,'Active',0,'2026-09-03 13:30:27','2026-09-02 17:43:35','2026-09-03 13:30:27'),(3,'admin_comp2','admin@comp2.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1002',2,2,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(4,'admin_comp3','admin@comp3.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1003',2,3,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(5,'admin_comp4','admin@comp4.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1004',2,4,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(6,'admin_comp5','admin@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1005',2,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(7,'admin_comp6','admin@comp6.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1006',2,6,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(8,'admin_comp7','admin@comp7.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1007',2,7,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(9,'admin_comp8','admin@comp8.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1008',2,8,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(10,'admin_comp9','admin@comp9.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1009',2,9,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(11,'admin_comp10','admin@comp10.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1010',2,10,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(12,'admin_comp11','admin@comp11.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1011',2,11,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(13,'admin_comp12','admin@comp12.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1012',2,12,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(14,'admin_comp13','admin@comp13.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1013',2,13,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(15,'admin_comp14','admin@comp14.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1014',2,14,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(16,'admin_comp15','admin@comp15.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1015',2,15,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(17,'admin_comp16','admin@comp16.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1016',2,16,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(18,'admin_comp17','admin@comp17.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1017',2,17,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(19,'admin_comp18','admin@comp18.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1018',2,18,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(20,'admin_comp19','admin@comp19.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1019',2,19,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(21,'admin_comp20','admin@comp20.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-1020',2,20,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(22,'staff_1','staff1@comp8.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2001',4,8,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(23,'staff_2','staff2@comp7.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2002',4,7,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(24,'staff_3','staff3@comp16.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2003',3,16,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(25,'staff_4','staff4@comp11.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2004',4,11,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(26,'staff_5','staff5@comp10.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2005',3,10,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(27,'staff_6','staff6@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2006',4,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(28,'staff_7','staff7@comp19.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2007',3,19,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(29,'staff_8','staff8@comp9.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2008',3,9,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(30,'staff_9','staff9@comp16.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2009',4,16,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(31,'staff_10','staff10@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2010',3,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(32,'staff_11','staff11@comp9.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2011',3,9,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(33,'staff_12','staff12@comp12.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2012',4,12,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(34,'staff_13','staff13@comp14.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2013',3,14,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(35,'staff_14','staff14@comp3.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2014',4,3,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(36,'staff_15','staff15@comp19.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2015',3,19,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(37,'staff_16','staff16@comp7.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2016',3,7,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(38,'staff_17','staff17@comp10.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2017',3,10,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(39,'staff_18','staff18@comp16.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2018',4,16,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(40,'staff_19','staff19@comp20.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2019',3,20,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(41,'staff_20','staff20@comp16.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2020',4,16,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(42,'staff_21','staff21@comp9.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2021',3,9,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(43,'staff_22','staff22@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2022',3,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(44,'staff_23','staff23@comp17.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2023',3,17,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(45,'staff_24','staff24@comp17.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2024',3,17,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(46,'staff_25','staff25@comp8.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2025',4,8,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(47,'staff_26','staff26@comp3.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2026',3,3,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(48,'staff_27','staff27@comp11.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2027',4,11,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(49,'staff_28','staff28@comp20.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2028',3,20,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(50,'staff_29','staff29@comp20.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2029',3,20,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(51,'staff_30','staff30@comp1.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2030',4,1,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(52,'staff_31','staff31@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2031',4,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(53,'staff_32','staff32@comp20.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2032',3,20,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(54,'staff_33','staff33@comp11.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2033',4,11,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(55,'staff_34','staff34@comp19.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2034',3,19,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(56,'staff_35','staff35@comp10.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2035',4,10,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(57,'staff_36','staff36@comp17.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2036',4,17,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(58,'staff_37','staff37@comp18.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2037',3,18,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(59,'staff_38','staff38@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2038',3,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(60,'staff_39','staff39@comp20.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2039',3,20,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(61,'staff_40','staff40@comp5.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-2040',4,5,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(62,'customer_1','cust1@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3001',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(63,'customer_2','cust2@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3002',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(64,'customer_3','cust3@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3003',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(65,'customer_4','cust4@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3004',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(66,'customer_5','cust5@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3005',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(67,'customer_6','cust6@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3006',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(68,'customer_7','cust7@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3007',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(69,'customer_8','cust8@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3008',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(70,'customer_9','cust9@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3009',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(71,'customer_10','cust10@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3010',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(72,'customer_11','cust11@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3011',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(73,'customer_12','cust12@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3012',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(74,'customer_13','cust13@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3013',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(75,'customer_14','cust14@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3014',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(76,'customer_15','cust15@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3015',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(77,'customer_16','cust16@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3016',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(78,'customer_17','cust17@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3017',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(79,'customer_18','cust18@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3018',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(80,'customer_19','cust19@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3019',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(81,'customer_20','cust20@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3020',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(82,'customer_21','cust21@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3021',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(83,'customer_22','cust22@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3022',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(84,'customer_23','cust23@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3023',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(85,'customer_24','cust24@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3024',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(86,'customer_25','cust25@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3025',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(87,'customer_26','cust26@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3026',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(88,'customer_27','cust27@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3027',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(89,'customer_28','cust28@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3028',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(90,'customer_29','cust29@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3029',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(91,'customer_30','cust30@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3030',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(92,'customer_31','cust31@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3031',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(93,'customer_32','cust32@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3032',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(94,'customer_33','cust33@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3033',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(95,'customer_34','cust34@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3034',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(96,'customer_35','cust35@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3035',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(97,'customer_36','cust36@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3036',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(98,'customer_37','cust37@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3037',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(99,'customer_38','cust38@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3038',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(100,'customer_39','cust39@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3039',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35'),(101,'customer_40','cust40@domain.com','5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8','555-3040',5,NULL,'Active',0,NULL,'2026-09-02 17:43:35','2026-09-02 17:43:35');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER users_auto_lock
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.failed_login_count >= 5 AND OLD.status <> 'Locked' THEN
        SET NEW.status = 'Locked';
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (NEW.user_id, 'STATUS_CHANGE', NEW.username, NEW.user_id, OLD.status, 'Locked');
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `vessels`
--

DROP TABLE IF EXISTS `vessels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vessels` (
  `vessel_id` int(11) NOT NULL AUTO_INCREMENT,
  `vessel_name` varchar(100) NOT NULL,
  `imo_number` varchar(30) DEFAULT NULL,
  `capacity_teu` int(11) DEFAULT NULL,
  PRIMARY KEY (`vessel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vessels`
--

LOCK TABLES `vessels` WRITE;
/*!40000 ALTER TABLE `vessels` DISABLE KEYS */;
INSERT INTO `vessels` VALUES (1,'Ocean Giant 1','IMO9000001',5094),(2,'Ocean Giant 2','IMO9000002',8288),(3,'Ocean Giant 3','IMO9000003',8157),(4,'Ocean Giant 4','IMO9000004',13398),(5,'Ocean Giant 5','IMO9000005',18186),(6,'Ocean Giant 6','IMO9000006',18924),(7,'Ocean Giant 7','IMO9000007',20708),(8,'Ocean Giant 8','IMO9000008',13052),(9,'Ocean Giant 9','IMO9000009',9780),(10,'Ocean Giant 10','IMO9000010',12970),(11,'Ocean Giant 11','IMO9000011',13161),(12,'Ocean Giant 12','IMO9000012',11520),(13,'Ocean Giant 13','IMO9000013',19034),(14,'Ocean Giant 14','IMO9000014',22259),(15,'Ocean Giant 15','IMO9000015',18050),(16,'Ocean Giant 16','IMO9000016',17823),(17,'Ocean Giant 17','IMO9000017',7727),(18,'Ocean Giant 18','IMO9000018',11583),(19,'Ocean Giant 19','IMO9000019',16731),(20,'Ocean Giant 20','IMO9000020',12783),(21,'Ocean Giant 21','IMO9000021',15777),(22,'Ocean Giant 22','IMO9000022',7725),(23,'Ocean Giant 23','IMO9000023',20871),(24,'Ocean Giant 24','IMO9000024',21971),(25,'Ocean Giant 25','IMO9000025',23612),(26,'Ocean Giant 26','IMO9000026',9009),(27,'Ocean Giant 27','IMO9000027',22941),(28,'Ocean Giant 28','IMO9000028',20331),(29,'Ocean Giant 29','IMO9000029',9103),(30,'Ocean Giant 30','IMO9000030',18911),(31,'Ocean Giant 31','IMO9000031',17246),(32,'Ocean Giant 32','IMO9000032',9090),(33,'Ocean Giant 33','IMO9000033',14354),(34,'Ocean Giant 34','IMO9000034',17869),(35,'Ocean Giant 35','IMO9000035',5045),(36,'Ocean Giant 36','IMO9000036',22161),(37,'Ocean Giant 37','IMO9000037',8969),(38,'Ocean Giant 38','IMO9000038',5763),(39,'Ocean Giant 39','IMO9000039',15861),(40,'Ocean Giant 40','IMO9000040',16342),(41,'Ocean Giant 41','IMO9000041',15222),(42,'Ocean Giant 42','IMO9000042',15855),(43,'Ocean Giant 43','IMO9000043',6144),(44,'Ocean Giant 44','IMO9000044',16214),(45,'Ocean Giant 45','IMO9000045',6423),(46,'Ocean Giant 46','IMO9000046',11746),(47,'Ocean Giant 47','IMO9000047',6669),(48,'Ocean Giant 48','IMO9000048',23567),(49,'Ocean Giant 49','IMO9000049',7719),(50,'Ocean Giant 50','IMO9000050',7624),(51,'n','1323546768',300);
/*!40000 ALTER TABLE `vessels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'nlogistic_db'
--

--
-- Dumping routines for database 'nlogistic_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `add_barcode_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_barcode_entry`(
    IN p_barcode_value VARCHAR(100), IN p_barcode_type ENUM('Code128','QR'),
    IN p_entity_type VARCHAR(30), IN p_entity_id INT,
    IN p_image_path VARCHAR(255), IN p_generated_by INT
)
BEGIN
    INSERT IGNORE INTO barcode_entries (barcode_value, barcode_type, entity_type, entity_id, image_path, generated_by)
    VALUES (p_barcode_value, p_barcode_type, p_entity_type, p_entity_id, p_image_path, p_generated_by);
    SELECT LAST_INSERT_ID() AS new_barcode_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_claim_document` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_claim_document`(
    IN p_claim_id INT, IN p_doc_type VARCHAR(30), IN p_file_path VARCHAR(255), IN p_uploaded_by INT
)
BEGIN
    INSERT INTO claim_documents (claim_id, doc_type, file_path, uploaded_by)
    VALUES (p_claim_id, p_doc_type, p_file_path, p_uploaded_by);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_container` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_container`(
    IN p_container_number VARCHAR(20), IN p_type VARCHAR(20), IN p_size VARCHAR(20),
    IN p_tare_weight_kg DECIMAL(10,2), IN p_max_gross_weight_kg DECIMAL(10,2),
    IN p_goods_capacity_kg DECIMAL(10,2), IN p_goods_capacity_cbm DECIMAL(10,2),
    IN p_current_port_id INT, IN p_owner_company_id INT
)
BEGIN
    INSERT INTO containers (container_number, type, size, tare_weight_kg, max_gross_weight_kg, goods_capacity_kg, goods_capacity_cbm, status, current_port_id, owner_company_id)
    VALUES (p_container_number, p_type, p_size, p_tare_weight_kg, p_max_gross_weight_kg, p_goods_capacity_kg, p_goods_capacity_cbm, 'Available', p_current_port_id, p_owner_company_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_demand_forecast` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_demand_forecast`(
    IN p_container_type VARCHAR(20), IN p_route_id INT, IN p_forecast_period VARCHAR(20),
    IN p_forecasted_demand DECIMAL(12,2), IN p_forecasted_price DECIMAL(12,2), IN p_algorithm_version VARCHAR(20)
)
BEGIN
    INSERT INTO demand_forecast (container_type, route_id, forecast_period, forecasted_demand, forecasted_price, algorithm_version)
    VALUES (p_container_type, p_route_id, p_forecast_period, p_forecasted_demand, p_forecasted_price, p_algorithm_version);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_invoice_line_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_invoice_line_item`(
    IN p_invoice_id INT, IN p_description VARCHAR(255), IN p_quantity DECIMAL(12,2), IN p_unit_price DECIMAL(12,2)
)
BEGIN
    INSERT INTO invoice_line_items (invoice_id, description, quantity, unit_price, line_total)
    VALUES (p_invoice_id, p_description, p_quantity, p_unit_price, p_quantity * p_unit_price);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_loss_reason` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_loss_reason`(IN p_pl_id INT, IN p_reason_id INT, IN p_remark VARCHAR(255))
BEGIN
    INSERT INTO profit_loss_reason_map (pl_id, reason_id, remark) VALUES (p_pl_id, p_reason_id, p_remark);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_pricing_rule` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_pricing_rule`(
    IN p_container_type VARCHAR(20), IN p_container_size VARCHAR(20), IN p_route_id INT,
    IN p_base_price DECIMAL(12,2), IN p_seasonal_multiplier DECIMAL(5,2), IN p_demand_multiplier DECIMAL(5,2),
    IN p_valid_from DATE, IN p_valid_to DATE
)
BEGIN
    DECLARE v_final_price DECIMAL(12,2);
    SET v_final_price = p_base_price * p_seasonal_multiplier * p_demand_multiplier;

    INSERT INTO pricing_rules (container_type, container_size, route_id, base_price, seasonal_multiplier, demand_multiplier, final_price, valid_from, valid_to)
    VALUES (p_container_type, p_container_size, p_route_id, p_base_price, p_seasonal_multiplier, p_demand_multiplier, v_final_price, p_valid_from, p_valid_to);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_product`(
    IN p_product_name VARCHAR(150), IN p_category VARCHAR(100), IN p_hsn_code VARCHAR(20),
    IN p_unit_of_measure VARCHAR(20), IN p_unit_cost DECIMAL(12,2), IN p_unit_price DECIMAL(12,2)
)
BEGIN
    INSERT INTO products (product_name, category, hsn_code, unit_of_measure, unit_cost, unit_price)
    VALUES (p_product_name, p_category, p_hsn_code, p_unit_of_measure, p_unit_cost, p_unit_price);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `adjust_stock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `adjust_stock`(
    IN p_stock_id INT, IN p_product_id INT, IN p_new_quantity DECIMAL(12,2), IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_old_quantity DECIMAL(12,2);
    DECLARE v_diff DECIMAL(12,2);

    IF p_reason IS NULL OR TRIM(p_reason) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Adjustment reason is mandatory';
    END IF;

    SELECT quantity_on_hand INTO v_old_quantity FROM stock WHERE stock_id = p_stock_id;
    SET v_diff = p_new_quantity - v_old_quantity;

    START TRANSACTION;
    UPDATE stock SET quantity_on_hand = p_new_quantity WHERE stock_id = p_stock_id;

    
    INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type, reference_id)
    SELECT p_product_id, 'ADJUSTMENT', v_diff, unit_cost, p_reason, p_stock_id
    FROM products WHERE product_id = p_product_id;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `allocate_container` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `allocate_container`(IN p_shipment_id INT, IN p_container_id INT)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_capacity_kg DECIMAL(10,2);
    DECLARE v_capacity_cbm DECIMAL(10,2);
    DECLARE v_cargo_weight DECIMAL(10,2);
    DECLARE v_cargo_volume DECIMAL(10,2);

    SELECT status, goods_capacity_kg, goods_capacity_cbm INTO v_status, v_capacity_kg, v_capacity_cbm
    FROM containers WHERE container_id = p_container_id;

    SELECT cargo_weight_kg, cargo_volume_cbm INTO v_cargo_weight, v_cargo_volume
    FROM shipment WHERE shipment_id = p_shipment_id;

    IF v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Container is not available for allocation';
    ELSEIF v_cargo_weight > v_capacity_kg OR v_cargo_volume > v_capacity_cbm THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cargo does not fit in the selected container';
    ELSE
        START TRANSACTION;
        UPDATE containers SET status = 'Allocated' WHERE container_id = p_container_id;
        UPDATE shipment SET container_id = p_container_id, status = 'Container Allocated' WHERE shipment_id = p_shipment_id;
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `approve_company` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `approve_company`(IN p_company_id INT, IN p_approver_user_id INT)
BEGIN
    DECLARE v_approver_role INT;
    DECLARE v_company_name VARCHAR(150);
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_approver_user_id;

    IF v_approver_role = 1 THEN
        SELECT company_name INTO v_company_name FROM companies WHERE company_id = p_company_id;
        UPDATE companies SET approval_status = 'Active' WHERE company_id = p_company_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (p_approver_user_id, 'APPROVE_COMPANY', v_company_name, p_company_id, 'Pending', 'Active');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can approve companies';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `approve_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `approve_user`(IN p_user_id INT, IN p_approver_id INT)
BEGIN
    DECLARE v_approver_role INT;
    DECLARE v_username VARCHAR(50);
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_approver_id;
    SELECT username INTO v_username FROM users WHERE user_id = p_user_id;
    
    IF v_approver_role = 1 THEN
        UPDATE users SET status = 'Active' WHERE user_id = p_user_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (p_approver_id, 'APPROVE_USER', v_username, p_user_id, 'Inactive', 'Active');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can approve users';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `book_shipment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `book_shipment`(
    IN p_customer_id INT, IN p_container_id INT, IN p_origin_port_id INT, IN p_destination_port_id INT,
    IN p_vessel_id INT, IN p_cargo_description VARCHAR(255), IN p_cargo_weight_kg DECIMAL(10,2),
    IN p_cargo_volume_cbm DECIMAL(10,2), IN p_cargo_declared_value DECIMAL(12,2),
    IN p_freight_cost DECIMAL(12,2), IN p_insurance_cost DECIMAL(12,2), IN p_other_charges DECIMAL(12,2),
    IN p_created_by INT, OUT p_shipment_id INT
)
BEGIN
    DECLARE v_capacity_kg DECIMAL(10,2);
    DECLARE v_capacity_cbm DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);

    SELECT status, goods_capacity_kg, goods_capacity_cbm INTO v_status, v_capacity_kg, v_capacity_cbm
    FROM containers WHERE container_id = p_container_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Container does not exist';
    ELSEIF p_cargo_weight_kg > v_capacity_kg OR p_cargo_volume_cbm > v_capacity_cbm THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cargo exceeds container capacity';
    ELSE
        START TRANSACTION;
        INSERT INTO shipment (customer_id, container_id, origin_port_id, destination_port_id, vessel_id, booking_date,
            cargo_description, cargo_weight_kg, cargo_volume_cbm, cargo_declared_value, freight_cost, insurance_cost,
            other_charges, status, created_by)
        VALUES (p_customer_id, p_container_id, p_origin_port_id, p_destination_port_id, p_vessel_id, CURDATE(),
            p_cargo_description, p_cargo_weight_kg, p_cargo_volume_cbm, p_cargo_declared_value, p_freight_cost,
            p_insurance_cost, p_other_charges, 'Booked', p_created_by);
        SET p_shipment_id = LAST_INSERT_ID();
        INSERT INTO container_movements (shipment_id, status, updated_by)
        VALUES (p_shipment_id, 'Booked', p_created_by);
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_shipment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_shipment`(IN p_shipment_id INT, IN p_cancelled_by INT, IN p_reason VARCHAR(255))
BEGIN
    DECLARE v_container_id INT;
    DECLARE v_status VARCHAR(30);

    SELECT container_id, status INTO v_container_id, v_status FROM shipment WHERE shipment_id = p_shipment_id;

    IF v_status = 'Delivered' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Delivered shipments cannot be cancelled';
    ELSE
        START TRANSACTION;
        UPDATE shipment SET status = 'Cancelled' WHERE shipment_id = p_shipment_id;
        UPDATE containers SET status = 'Available' WHERE container_id = v_container_id;
        INSERT INTO container_movements (shipment_id, status, checkpoint_location, updated_by)
        VALUES (p_shipment_id, 'Cancelled', p_reason, p_cancelled_by);
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `change_user_role` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_user_role`(IN p_user_id INT, IN p_new_role_id INT, IN p_changed_by INT)
BEGIN
    DECLARE v_old_role_id INT;
    DECLARE v_username VARCHAR(50);
    DECLARE v_approver_role INT;
    
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_changed_by;
    IF v_approver_role = 1 THEN
        SELECT role_id, username INTO v_old_role_id, v_username FROM users WHERE user_id = p_user_id;
        UPDATE users SET role_id = p_new_role_id WHERE user_id = p_user_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (p_changed_by, 'ROLE_CHANGE', v_username, p_user_id, v_old_role_id, p_new_role_id);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can change user roles';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_permission` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `check_permission`(
    IN p_user_id INT, IN p_required_role VARCHAR(50), OUT p_allowed TINYINT
)
BEGIN
    DECLARE v_role_name VARCHAR(50);
    DECLARE v_username VARCHAR(50);
    SELECT r.role_name, u.username INTO v_role_name, v_username
    FROM users u JOIN roles r ON u.role_id = r.role_id
    WHERE u.user_id = p_user_id AND u.status = 'Active';

    IF v_role_name = p_required_role OR v_role_name = 'Super Admin' THEN
        SET p_allowed = 1;
    ELSE
        SET p_allowed = 0;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (p_user_id, 'PERMISSION_DENIED', v_username, p_user_id, v_role_name, p_required_role);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_shipment_can_depart` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `check_shipment_can_depart`(IN p_shipment_id INT, OUT p_can_depart TINYINT)
BEGIN
    DECLARE v_blocking_count INT;

    SELECT COUNT(*) INTO v_blocking_count
    FROM compliance_documents
    WHERE shipment_id = p_shipment_id
      AND (status <> 'Approved' OR expiry_date < CURDATE());

    IF v_blocking_count > 0 THEN
        SET p_can_depart = 0;
    ELSE
        SET p_can_depart = 1;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cleanup_expired_tokens` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cleanup_expired_tokens`()
BEGIN
    DECLARE v_deleted INT DEFAULT 0;
    DELETE FROM password_resets
    WHERE expires_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);
    SET v_deleted = ROW_COUNT();
    SELECT CONCAT('Cleaned up ', v_deleted, ' expired tokens') AS status;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `compute_abc_classification` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `compute_abc_classification`(
    IN p_period VARCHAR(20),
    IN p_computed_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_total_revenue DECIMAL(14,2);
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prod_id INT;
    DECLARE v_prod_revenue DECIMAL(14,2);
    DECLARE v_contrib_pct DECIMAL(5,2);
    DECLARE v_cum_pct DECIMAL(5,2) DEFAULT 0.00;

    DECLARE cur_abc CURSOR FOR
        SELECT p.product_id, IFNULL(SUM(st.sale_amount), 0.00) AS revenue
        FROM products p
        LEFT JOIN sales_transactions st ON p.product_id = st.product_id
        GROUP BY p.product_id
        ORDER BY revenue DESC, p.product_id ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SELECT r.role_name INTO v_role
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_computed_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSEIF v_role NOT IN ('Super Admin', 'Company Admin', 'Company Staff Finance', 'Company Staff Ops') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized to compute ABC classification';
    ELSEIF p_period IS NULL OR TRIM(p_period) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Computation period identifier is mandatory';
    ELSE
        SELECT IFNULL(SUM(sale_amount), 0.00) INTO v_total_revenue FROM sales_transactions;

        OPEN cur_abc;
        abc_loop: LOOP
            FETCH cur_abc INTO v_prod_id, v_prod_revenue;
            IF v_done THEN
                LEAVE abc_loop;
            END IF;

            IF v_total_revenue > 0 THEN
                SET v_contrib_pct = ROUND((v_prod_revenue / v_total_revenue) * 100, 2);
            ELSE
                SET v_contrib_pct = 0.00;
            END IF;

            SET v_cum_pct = LEAST(100.00, v_cum_pct + v_contrib_pct);

            INSERT INTO abc_classification_result (
                product_id, revenue_contribution_pct, cumulative_pct, class, computed_period
            )
            VALUES (
                v_prod_id, v_contrib_pct, v_cum_pct, 'A', TRIM(p_period)
            )
            ON DUPLICATE KEY UPDATE
                revenue_contribution_pct = VALUES(revenue_contribution_pct),
                cumulative_pct = VALUES(cumulative_pct),
                computed_at = CURRENT_TIMESTAMP;
        END LOOP;
        CLOSE cur_abc;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `compute_inventory_turnover` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `compute_inventory_turnover`(
    IN p_period VARCHAR(20),
    IN p_computed_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prod_id INT;
    DECLARE v_cogs DECIMAL(12,2);
    DECLARE v_avg_inv DECIMAL(12,2);
    DECLARE v_turnover DECIMAL(10,2);
    DECLARE v_days DECIMAL(10,2);

    DECLARE cur_turnover CURSOR FOR
        SELECT product_id FROM products ORDER BY product_id ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SELECT r.role_name INTO v_role
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_computed_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSEIF v_role NOT IN ('Super Admin', 'Company Admin', 'Company Staff Finance', 'Company Staff Ops') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized to compute inventory turnover';
    ELSEIF p_period IS NULL OR TRIM(p_period) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Computation period identifier is mandatory';
    ELSE
        OPEN cur_turnover;
        turnover_loop: LOOP
            FETCH cur_turnover INTO v_prod_id;
            IF v_done THEN
                LEAVE turnover_loop;
            END IF;

            SELECT IFNULL(SUM(quantity * unit_cost_at_txn), 0.00) INTO v_cogs
            FROM inventory_ledger
            WHERE product_id = v_prod_id AND transaction_type = 'OUT';

            SELECT IFNULL(SUM(s.quantity_on_hand * p.unit_cost), 0.00) INTO v_avg_inv
            FROM stock s
            JOIN products p ON s.product_id = p.product_id
            WHERE s.product_id = v_prod_id;

            IF v_avg_inv > 0 AND v_cogs > 0 THEN
                SET v_turnover = ROUND(v_cogs / v_avg_inv, 2);
                SET v_days = ROUND(365.00 / v_turnover, 2);
            ELSE
                SET v_turnover = 0.00;
                SET v_days = 0.00;
            END IF;

            INSERT INTO inventory_turnover_result (
                product_id, period, cogs_amount, avg_inventory_value, turnover_ratio, days_in_inventory
            )
            VALUES (
                v_prod_id, TRIM(p_period), v_cogs, v_avg_inv, v_turnover, v_days
            )
            ON DUPLICATE KEY UPDATE
                cogs_amount = VALUES(cogs_amount),
                avg_inventory_value = VALUES(avg_inventory_value),
                turnover_ratio = VALUES(turnover_ratio),
                days_in_inventory = VALUES(days_in_inventory),
                computed_at = CURRENT_TIMESTAMP;
        END LOOP;
        CLOSE cur_turnover;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `compute_profitability` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `compute_profitability`(
    IN p_period VARCHAR(20),
    IN p_computed_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prod_id INT;
    DECLARE v_revenue DECIMAL(12,2);
    DECLARE v_direct_cogs DECIMAL(12,2);
    DECLARE v_allocated_logistics DECIMAL(12,2);

    DECLARE cur_profit CURSOR FOR
        SELECT product_id FROM products ORDER BY product_id ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SELECT r.role_name INTO v_role
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_computed_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSEIF v_role NOT IN ('Super Admin', 'Company Admin', 'Company Staff Finance') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized to compute product profitability';
    ELSEIF p_period IS NULL OR TRIM(p_period) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Computation period identifier is mandatory';
    ELSE
        OPEN cur_profit;
        profit_loop: LOOP
            FETCH cur_profit INTO v_prod_id;
            IF v_done THEN
                LEAVE profit_loop;
            END IF;

            SELECT IFNULL(SUM(sale_amount), 0.00) INTO v_revenue
            FROM sales_transactions WHERE product_id = v_prod_id;

            SELECT IFNULL(SUM(quantity * unit_cost_at_txn), 0.00) INTO v_direct_cogs
            FROM inventory_ledger
            WHERE product_id = v_prod_id AND transaction_type = 'OUT';

            SELECT IFNULL(SUM(total_cost_amount), 0.00) / GREATEST(1, (SELECT COUNT(*) FROM products))
            INTO v_allocated_logistics
            FROM profit_loss;

            INSERT INTO profitability_result (
                product_id, period, revenue, direct_cogs, allocated_logistics_cost, net_profit, profit_margin_pct
            )
            VALUES (
                v_prod_id, TRIM(p_period), v_revenue, v_direct_cogs, v_allocated_logistics, 0.00, 0.00
            )
            ON DUPLICATE KEY UPDATE
                revenue = VALUES(revenue),
                direct_cogs = VALUES(direct_cogs),
                allocated_logistics_cost = VALUES(allocated_logistics_cost);
        END LOOP;
        CLOSE cur_profit;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `compute_sales_trend` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `compute_sales_trend`(
    IN p_period VARCHAR(20),
    IN p_computed_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prod_id INT;
    DECLARE v_actual_sales DECIMAL(12,2);
    DECLARE v_moving_avg DECIMAL(12,2);
    DECLARE v_trend ENUM('Growing','Declining','Stable');

    DECLARE cur_trend CURSOR FOR
        SELECT product_id FROM products ORDER BY product_id ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SELECT r.role_name INTO v_role
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_computed_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSEIF v_role NOT IN ('Super Admin', 'Company Admin', 'Company Staff Ops') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized to compute sales trends';
    ELSEIF p_period IS NULL OR TRIM(p_period) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Computation period identifier is mandatory';
    ELSE
        OPEN cur_trend;
        trend_loop: LOOP
            FETCH cur_trend INTO v_prod_id;
            IF v_done THEN
                LEAVE trend_loop;
            END IF;

            SELECT IFNULL(SUM(quantity_sold), 0.00) INTO v_actual_sales
            FROM sales_transactions WHERE product_id = v_prod_id;

            SELECT IFNULL(AVG(actual_sales), v_actual_sales) INTO v_moving_avg
            FROM (
                SELECT actual_sales FROM sales_trend_result
                WHERE product_id = v_prod_id
                ORDER BY id DESC
                LIMIT 3
            ) AS recent_trends;

            IF v_actual_sales > (v_moving_avg * 1.05) THEN
                SET v_trend = 'Growing';
            ELSEIF v_actual_sales < (v_moving_avg * 0.95) THEN
                SET v_trend = 'Declining';
            ELSE
                SET v_trend = 'Stable';
            END IF;

            INSERT INTO sales_trend_result (
                product_id, period, actual_sales, moving_avg, trend_label
            )
            VALUES (
                v_prod_id, TRIM(p_period), v_actual_sales, v_moving_avg, v_trend
            )
            ON DUPLICATE KEY UPDATE
                actual_sales = VALUES(actual_sales),
                moving_avg = VALUES(moving_avg),
                trend_label = VALUES(trend_label);
        END LOOP;
        CLOSE cur_trend;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `consume_reset_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `consume_reset_token`(
    IN p_token             VARCHAR(64),
    IN p_new_password_hash VARCHAR(255)
)
BEGIN
    DECLARE v_user_id INT DEFAULT NULL;
    DECLARE v_expires DATETIME DEFAULT NULL;
    DECLARE v_used    TINYINT(1) DEFAULT 1;
    DECLARE v_reset_id INT DEFAULT NULL;

    SELECT id, user_id, expires_at, used
    INTO   v_reset_id, v_user_id, v_expires, v_used
    FROM   password_resets
    WHERE  token = p_token
    ORDER  BY id DESC
    LIMIT  1;

    
    IF v_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid reset token';
    ELSEIF v_used = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Token already used';
    ELSEIF v_expires <= NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Token has expired';
    END IF;

    
    UPDATE users SET password_hash = p_new_password_hash WHERE user_id = v_user_id;

    
    UPDATE password_resets SET used = 1 WHERE id = v_reset_id;

    
    UPDATE users SET failed_logins = 0, is_locked = 0 WHERE user_id = v_user_id;

    
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
    VALUES (v_user_id, 'PASSWORD_RESET_SUCCESS', 'users', v_user_id, 'Password changed via reset token');

    SELECT 'Password reset successful' AS status, v_user_id AS user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `deactivate_pricing_rule` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `deactivate_pricing_rule`(IN p_pricing_id INT, IN p_changed_by INT)
BEGIN
    UPDATE pricing_rules SET valid_to = CURDATE() WHERE pricing_id = p_pricing_id;
    INSERT INTO pricing_audit (pricing_id, old_price, new_price, changed_by, reason)
    SELECT pricing_id, base_price, base_price, p_changed_by, 'Rule deactivated'
    FROM pricing_rules WHERE pricing_id = p_pricing_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `deactivate_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `deactivate_user`(IN p_user_id INT, IN p_changed_by INT)
BEGIN
    DECLARE v_username VARCHAR(50);
    DECLARE v_approver_role INT;
    
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_changed_by;
    IF v_approver_role = 1 THEN
        SELECT username INTO v_username FROM users WHERE user_id = p_user_id;
        UPDATE users SET status = 'Inactive' WHERE user_id = p_user_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (p_changed_by, 'DEACTIVATE_USER', v_username, p_user_id, 'Active', 'Inactive');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can deactivate users';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_barcode_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_barcode_entry`(IN p_barcode_id INT)
BEGIN
    DELETE FROM barcode_entries WHERE barcode_id = p_barcode_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_billing_invoice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_billing_invoice`(
    IN p_invoice_id INT, IN p_deleted_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_deleted_by;
    IF v_approver_role = 1 THEN
        DELETE FROM invoice_line_items WHERE invoice_id = p_invoice_id;
        DELETE FROM payments WHERE invoice_id = p_invoice_id;
        DELETE FROM billing_invoices WHERE invoice_id = p_invoice_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_deleted_by, 'DELETE_INVOICE', 'billing_invoices', p_invoice_id, 'Deleted');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can delete invoices';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_claims` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_claims`(
    IN p_claim_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM claims WHERE claim_id = p_claim_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_claim_documents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_claim_documents`(
    IN p_doc_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM claim_documents WHERE doc_id = p_doc_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_companies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_companies`(
    IN p_company_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM companies WHERE company_id = p_company_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_company` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_company`(
    IN p_company_id_to_delete INT, 
    IN p_deleted_by_user_id INT
)
BEGIN
    DECLARE v_approver_role INT;
    DECLARE v_company_name VARCHAR(150);
    
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_deleted_by_user_id;
    
    IF v_approver_role = 1 THEN
        SELECT company_name INTO v_company_name FROM companies WHERE company_id = p_company_id_to_delete;
        
        IF v_company_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Company not found';
        ELSE
            DELETE FROM companies WHERE company_id = p_company_id_to_delete;
            INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
            VALUES (p_deleted_by_user_id, 'DELETE_COMPANY', v_company_name, p_company_id_to_delete, 'Active/Suspended', 'Deleted');
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can delete companies';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_compliance_document` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_compliance_document`(
    IN p_doc_id INT, IN p_deleted_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_deleted_by;
    IF v_approver_role = 1 THEN
        DELETE FROM compliance_documents WHERE doc_id = p_doc_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_deleted_by, 'DELETE_COMPLIANCE_DOC', 'compliance_documents', p_doc_id, 'Deleted');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can delete compliance documents';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_containers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_containers`(
    IN p_container_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM containers WHERE container_id = p_container_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_customers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_customers`(
    IN p_customer_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM customers WHERE customer_id = p_customer_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_invoice_line_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_invoice_line_item`(
    IN p_item_id INT, IN p_deleted_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_deleted_by;
    IF v_approver_role = 1 THEN
        DELETE FROM invoice_line_items WHERE item_id = p_item_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_deleted_by, 'DELETE_INVOICE_LINE_ITEM', 'invoice_line_items', p_item_id, 'Deleted');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can delete line items';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_loss_reasons` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_loss_reasons`(
    IN p_reason_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM loss_reasons WHERE reason_id = p_reason_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_payment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_payment`(
    IN p_payment_id INT, IN p_deleted_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_deleted_by;
    IF v_approver_role = 1 THEN
        DELETE FROM payments WHERE payment_id = p_payment_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_deleted_by, 'DELETE_PAYMENT', 'payments', p_payment_id, 'Deleted');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can delete payments';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_ports` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_ports`(
    IN p_port_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM ports WHERE port_id = p_port_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_pricing_rules` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_pricing_rules`(
    IN p_pricing_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM pricing_rules WHERE pricing_id = p_pricing_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_products` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_products`(
    IN p_product_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM products WHERE product_id = p_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_sales_transactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_sales_transactions`(
    IN p_transaction_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM sales_transactions WHERE transaction_id = p_transaction_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_shipment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_shipment`(
    IN p_shipment_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;

    START TRANSACTION;
    SET FOREIGN_KEY_CHECKS = 0;
    DELETE FROM container_movements WHERE shipment_id = p_shipment_id;
    DELETE FROM compliance_documents WHERE shipment_id = p_shipment_id;
    DELETE FROM claims WHERE shipment_id = p_shipment_id;
    DELETE FROM profit_loss_reason_map WHERE pl_id IN (SELECT pl_id FROM profit_loss WHERE shipment_id = p_shipment_id);
    DELETE FROM profit_loss WHERE shipment_id = p_shipment_id;
    DELETE FROM billing_invoices WHERE shipment_id = p_shipment_id;
    DELETE FROM sales_transactions WHERE shipment_id = p_shipment_id;
    DELETE FROM shipment WHERE shipment_id = p_shipment_id;
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_stock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_stock`(
    IN p_stock_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM stock WHERE stock_id = p_stock_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_user`(
    IN p_user_id_to_delete INT, 
    IN p_deleted_by_user_id INT
)
BEGIN
    DECLARE v_approver_role INT;
    DECLARE v_username VARCHAR(50);
    
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_deleted_by_user_id;
    
    IF v_approver_role = 1 THEN
        SELECT username INTO v_username FROM users WHERE user_id = p_user_id_to_delete;
        
        IF v_username IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
        ELSE
            DELETE FROM users WHERE user_id = p_user_id_to_delete;
            INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
            VALUES (p_deleted_by_user_id, 'DELETE_USER', v_username, p_user_id_to_delete, 'Active/Inactive', 'Deleted');
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can delete users';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_users` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_users`(
    IN p_user_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM users WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_vessels` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_vessels`(
    IN p_vessel_id int(11),
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete';
    END IF;
    DELETE FROM vessels WHERE vessel_id = p_vessel_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `file_claim` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `file_claim`(
    IN p_shipment_id INT, IN p_container_id INT, IN p_product_id INT, IN p_customer_id INT,
    IN p_claim_type VARCHAR(20), IN p_description VARCHAR(255), IN p_incident_date DATE,
    IN p_claimed_amount DECIMAL(12,2), IN p_reason_id INT, IN p_filed_by INT
)
BEGIN
    INSERT INTO claims (shipment_id, container_id, product_id, customer_id, claim_type, description, incident_date, claimed_amount, reason_id, status, filed_by)
    VALUES (p_shipment_id, p_container_id, p_product_id, p_customer_id, p_claim_type, p_description, p_incident_date, p_claimed_amount, p_reason_id, 'Filed', p_filed_by);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_barcode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_barcode`(
    IN p_barcode_value VARCHAR(100), IN p_barcode_type VARCHAR(20), IN p_entity_type VARCHAR(30),
    IN p_entity_id INT, IN p_image_path VARCHAR(255), IN p_generated_by INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM barcode_entries WHERE barcode_value = p_barcode_value) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate barcode value';
    ELSE
        INSERT INTO barcode_entries (barcode_value, barcode_type, entity_type, entity_id, image_path, generated_by)
        VALUES (p_barcode_value, p_barcode_type, p_entity_type, p_entity_id, p_image_path, p_generated_by);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_invoice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_invoice`(
    IN p_customer_id INT, IN p_shipment_id INT, OUT p_invoice_id INT
)
BEGIN
    DECLARE v_freight_charge DECIMAL(12,2);
    DECLARE v_tax_amount DECIMAL(12,2);
    DECLARE v_total_amount DECIMAL(12,2);

    
    SELECT pr.final_price INTO v_freight_charge
    FROM shipment s
    JOIN containers c ON s.container_id = c.container_id
    JOIN pricing_rules pr ON pr.container_type = c.type 
       AND pr.container_size = c.size 
    WHERE s.shipment_id = p_shipment_id
    ORDER BY pr.valid_to DESC LIMIT 1;

    
    IF v_freight_charge IS NULL THEN
        SET v_freight_charge = 15000.00;
    END IF;

    
    SET v_tax_amount = v_freight_charge * 0.18;
    SET v_total_amount = v_freight_charge + v_tax_amount;

    INSERT INTO billing_invoices (customer_id, shipment_id, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, paid_amount, payment_status)
    VALUES (p_customer_id, p_shipment_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), v_freight_charge, v_tax_amount, v_total_amount, 0.00, 'Unpaid');
    
    SET p_invoice_id = LAST_INSERT_ID();

    INSERT INTO invoice_line_items (invoice_id, description, quantity, unit_price, line_total)
    VALUES (p_invoice_id, 'Freight Charges', 1, v_freight_charge, v_freight_charge);

    INSERT INTO invoice_line_items (invoice_id, description, quantity, unit_price, line_total)
    VALUES (p_invoice_id, 'Taxes', 1, v_tax_amount, v_tax_amount);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getall_barcode_entries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getall_barcode_entries`()
BEGIN
    SELECT * FROM barcode_entries;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getall_barcode_scan_logs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getall_barcode_scan_logs`()
BEGIN
    SELECT * FROM barcode_scan_log;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_active_shipments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_shipments`(
    IN p_company_id INT,
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_user_company_id INT;
    DECLARE v_target_company INT;

    SELECT r.role_name, u.company_id INTO v_role, v_user_company_id
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSE
        IF v_role = 'Super Admin' THEN
            SET v_target_company = p_company_id;
        ELSE
            SET v_target_company = v_user_company_id;
        END IF;

        SELECT s.shipment_id, s.customer_id, cust.customer_name,
               s.container_id, c.container_number, s.status, s.booking_date,
               s.origin_port_id, op.port_name AS origin_port,
               s.destination_port_id, dp.port_name AS destination_port
        FROM shipment s
        JOIN customers cust ON s.customer_id = cust.customer_id
        LEFT JOIN containers c ON s.container_id = c.container_id
        LEFT JOIN ports op ON s.origin_port_id = op.port_id
        LEFT JOIN ports dp ON s.destination_port_id = dp.port_id
        WHERE s.status NOT IN ('Delivered', 'Cancelled')
          AND (v_target_company IS NULL OR c.owner_company_id = v_target_company)
        ORDER BY s.booking_date DESC;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_audit_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_audit_history`(IN p_entity_name VARCHAR(100), IN p_entity_id INT)
BEGIN
    SELECT * FROM audit_log WHERE entity_name = p_entity_name AND entity_id = p_entity_id ORDER BY timestamp DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_barcode_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_barcode_entry`(IN p_barcode_id INT)
BEGIN
    SELECT * FROM barcode_entries WHERE barcode_id = p_barcode_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_barcode_entry_by_value` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_barcode_entry_by_value`(IN p_barcode_value VARCHAR(100))
BEGIN
    SELECT * FROM barcode_entries WHERE barcode_value = p_barcode_value;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_barcode_scan_log` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_barcode_scan_log`(IN p_scan_id INT)
BEGIN
    SELECT * FROM barcode_scan_log WHERE scan_id = p_scan_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_billing_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_billing_history`(IN p_customer_id INT)
BEGIN
    SELECT * FROM billing_invoices WHERE customer_id = p_customer_id ORDER BY invoice_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_claims_by_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_claims_by_status`(IN p_status VARCHAR(30))
BEGIN
    SELECT * FROM claims WHERE status = p_status ORDER BY filed_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_claim_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_claim_history`(IN p_claim_id INT)
BEGIN
    SELECT * FROM claim_status_history WHERE claim_id = p_claim_id ORDER BY changed_at;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_compliance_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_compliance_status`(IN p_shipment_id INT)
BEGIN
    SELECT * FROM compliance_documents WHERE shipment_id = p_shipment_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_container_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_container_status`(IN p_container_id INT)
BEGIN
    SELECT container_id, container_number, status, current_port_id, owner_company_id FROM containers WHERE container_id = p_container_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_container_utilization` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_container_utilization`(
    IN p_company_id INT,
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_user_company_id INT;
    DECLARE v_target_company INT;
    DECLARE v_total INT;
    DECLARE v_in_use INT;
    DECLARE v_rate DECIMAL(5,2);

    SELECT r.role_name, u.company_id INTO v_role, v_user_company_id
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSE
        IF v_role = 'Super Admin' THEN
            SET v_target_company = p_company_id;
        ELSE
            SET v_target_company = v_user_company_id;
        END IF;

        SELECT COUNT(*),
               COUNT(CASE WHEN status IN ('Allocated', 'In Transit') THEN 1 END)
        INTO v_total, v_in_use
        FROM containers
        WHERE (v_target_company IS NULL OR owner_company_id = v_target_company);

        IF v_total > 0 THEN
            SET v_rate = ROUND((v_in_use / v_total) * 100, 2);
        ELSE
            SET v_rate = 0.00;
        END IF;

        SELECT v_total AS total_containers, v_in_use AS in_use_containers,
               (v_total - v_in_use) AS idle_containers, v_rate AS utilization_rate_pct;

        SELECT status, COUNT(*) AS container_count
        FROM containers
        WHERE (v_target_company IS NULL OR owner_company_id = v_target_company)
        GROUP BY status;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_customer_profitability` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_profitability`(
    IN p_customer_id INT,
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_user_customer_id INT;

    SELECT r.role_name INTO v_role
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSEIF v_role = 'Customer' THEN
        SELECT customer_id INTO v_user_customer_id FROM customers WHERE user_id = p_requested_by;

        SELECT c.customer_id, c.customer_name,
               IFNULL(SUM(pl.revenue_amount), 0.00) AS total_revenue,
               IFNULL(SUM(pl.total_cost_amount), 0.00) AS total_cost,
               IFNULL(SUM(pl.profit_loss_amount), 0.00) AS net_profit
        FROM customers c
        JOIN shipment s ON c.customer_id = s.customer_id
        JOIN profit_loss pl ON s.shipment_id = pl.shipment_id
        WHERE c.customer_id = v_user_customer_id
        GROUP BY c.customer_id, c.customer_name;
    ELSE
        SELECT c.customer_id, c.customer_name,
               IFNULL(SUM(pl.revenue_amount), 0.00) AS total_revenue,
               IFNULL(SUM(pl.total_cost_amount), 0.00) AS total_cost,
               IFNULL(SUM(pl.profit_loss_amount), 0.00) AS net_profit
        FROM customers c
        JOIN shipment s ON c.customer_id = s.customer_id
        JOIN profit_loss pl ON s.shipment_id = pl.shipment_id
        WHERE (p_customer_id IS NULL OR c.customer_id = p_customer_id)
        GROUP BY c.customer_id, c.customer_name
        ORDER BY net_profit DESC;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_dashboard_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_dashboard_summary`(
    IN p_period VARCHAR(20),
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_user_company_id INT;

    SELECT r.role_name, u.company_id INTO v_role, v_user_company_id
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSEIF v_role NOT IN ('Super Admin', 'Company Admin', 'Company Staff Finance', 'Company Staff Ops') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized to access executive dashboard summary';
    ELSE
        SELECT class, COUNT(*) AS product_count
        FROM abc_classification_result
        WHERE computed_period = p_period
        GROUP BY class;

        SELECT IFNULL(AVG(turnover_ratio), 0.00) AS avg_turnover_ratio,
               IFNULL(AVG(days_in_inventory), 0.00) AS avg_days_in_inventory
        FROM inventory_turnover_result
        WHERE period = p_period;

        SELECT IFNULL(SUM(revenue), 0.00) AS total_revenue,
               IFNULL(SUM(direct_cogs), 0.00) AS total_direct_cogs,
               IFNULL(SUM(allocated_logistics_cost), 0.00) AS total_logistics_cost,
               IFNULL(SUM(net_profit), 0.00) AS total_net_profit
        FROM profitability_result
        WHERE period = p_period;

        SELECT COUNT(*) AS active_shipment_count
        FROM shipment
        WHERE status NOT IN ('Delivered', 'Cancelled');

        SELECT COUNT(*) AS overdue_invoice_count,
               IFNULL(SUM(total_amount - paid_amount), 0.00) AS total_overdue_receivables
        FROM billing_invoices
        WHERE payment_status = 'Overdue';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_demand_forecast` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_demand_forecast`(IN p_container_type VARCHAR(20), IN p_route_id INT)
BEGIN
    SELECT * FROM demand_forecast
    WHERE container_type = p_container_type AND (p_route_id IS NULL OR route_id = p_route_id)
    ORDER BY generated_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_entity_by_barcode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_entity_by_barcode`(IN p_barcode_value VARCHAR(100))
BEGIN
    SELECT entity_type, entity_id, generated_at
    FROM barcode_entries
    WHERE barcode_value = p_barcode_value;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_final_price` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_final_price`(IN p_container_type VARCHAR(20), IN p_container_size VARCHAR(20), IN p_route_id INT)
BEGIN
    SELECT pricing_id, final_price, valid_from, valid_to
    FROM pricing_rules
    WHERE container_type = p_container_type
      AND container_size = p_container_size
      AND route_id = p_route_id
      AND CURDATE() BETWEEN valid_from AND valid_to
    ORDER BY valid_from DESC
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_inventory_ledger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_inventory_ledger`(IN p_product_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT * FROM inventory_ledger
    WHERE product_id = p_product_id AND txn_date BETWEEN p_start_date AND p_end_date
    ORDER BY txn_date;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_invoice_aging` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_invoice_aging`(IN p_customer_id INT)
BEGIN
    SELECT invoice_id, customer_id, total_amount, paid_amount, (total_amount - paid_amount) AS balance_due,
           DATEDIFF(CURDATE(), due_date) AS days_overdue, payment_status
    FROM billing_invoices
    WHERE (p_customer_id IS NULL OR customer_id = p_customer_id)
      AND payment_status IN ('Unpaid','Partial','Overdue')
    ORDER BY days_overdue DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_movement_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_movement_history`(IN p_shipment_id INT)
BEGIN
    SELECT * FROM container_movements WHERE shipment_id = p_shipment_id ORDER BY updated_at;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_profit_loss_graph` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_profit_loss_graph`(IN p_start_date DATE, IN p_end_date DATE, IN p_company_id INT)
BEGIN
    SELECT pl.record_date, s.shipment_id, c.owner_company_id, pl.revenue_amount, pl.total_cost_amount, pl.profit_loss_amount
    FROM profit_loss pl
    JOIN shipment s ON pl.shipment_id = s.shipment_id
    JOIN containers c ON s.container_id = c.container_id
    WHERE pl.record_date BETWEEN p_start_date AND p_end_date
      AND (p_company_id IS NULL OR c.owner_company_id = p_company_id)
    ORDER BY pl.record_date;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_profit_loss_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_profit_loss_summary`(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_company_id INT,
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_user_company_id INT;
    DECLARE v_target_company INT;

    SELECT r.role_name, u.company_id INTO v_role, v_user_company_id
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSE
        IF v_role = 'Super Admin' THEN
            SET v_target_company = p_company_id;
        ELSE
            SET v_target_company = v_user_company_id;
        END IF;

        SELECT IFNULL(SUM(pl.revenue_amount), 0.00) AS total_revenue,
               IFNULL(SUM(pl.total_cost_amount), 0.00) AS total_cost,
               IFNULL(SUM(pl.profit_loss_amount), 0.00) AS net_profit_loss,
               COUNT(pl.pl_id) AS shipment_count
        FROM profit_loss pl
        JOIN shipment s ON pl.shipment_id = s.shipment_id
        LEFT JOIN containers c ON s.container_id = c.container_id
        WHERE (p_start_date IS NULL OR pl.record_date >= p_start_date)
          AND (p_end_date IS NULL OR pl.record_date <= p_end_date)
          AND (v_target_company IS NULL OR c.owner_company_id = v_target_company);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_role_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_role_by_id`(IN p_role_id INT)
BEGIN
    SELECT * FROM roles WHERE role_id = p_role_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_scan_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_scan_history`(IN p_barcode_id INT)
BEGIN
    SELECT * FROM barcode_scan_log WHERE barcode_id = p_barcode_id ORDER BY scanned_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_scan_history_for_barcode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_scan_history_for_barcode`(IN p_barcode_id INT)
BEGIN
    SELECT * FROM barcode_scan_log WHERE barcode_id = p_barcode_id ORDER BY scanned_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_shipments_by_customer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_shipments_by_customer`(IN p_customer_id INT)
BEGIN
    SELECT * FROM shipment WHERE customer_id = p_customer_id ORDER BY booking_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_shipment_tracking` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_shipment_tracking`(IN p_shipment_id INT)
BEGIN
    SELECT s.*, cm.status AS latest_movement_status, cm.checkpoint_location, cm.updated_at
    FROM shipment s
    LEFT JOIN container_movements cm ON cm.shipment_id = s.shipment_id
    WHERE s.shipment_id = p_shipment_id
    ORDER BY cm.updated_at DESC LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_stock_by_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_stock_by_product`(IN p_product_id INT)
BEGIN
    SELECT * FROM stock WHERE product_id = p_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_stock_valuation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_stock_valuation`(
    IN p_company_id INT,
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_user_company_id INT;
    DECLARE v_target_company INT;

    SELECT r.role_name, u.company_id INTO v_role, v_user_company_id
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSE
        IF v_role = 'Super Admin' THEN
            SET v_target_company = p_company_id;
        ELSE
            SET v_target_company = v_user_company_id;
        END IF;

        SELECT p.product_id, p.product_name, p.category, p.unit_cost,
               IFNULL(SUM(s.quantity_on_hand), 0) AS total_quantity_on_hand,
               IFNULL(SUM(s.quantity_on_hand * p.unit_cost), 0.00) AS total_inventory_valuation
        FROM products p
        LEFT JOIN stock s ON p.product_id = s.product_id
          AND (v_target_company IS NULL OR s.company_id = v_target_company)
        GROUP BY p.product_id, p.product_name, p.category, p.unit_cost
        ORDER BY total_inventory_valuation DESC;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_top_loss_reasons` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_top_loss_reasons`(
    IN p_limit INT,
    IN p_requested_by INT
)
BEGIN
    DECLARE v_role VARCHAR(50);
    DECLARE v_max_rows INT DEFAULT 5;

    SELECT r.role_name INTO v_role
    FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = p_requested_by AND u.status = 'Active';

    IF v_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
    ELSE
        IF p_limit IS NOT NULL AND p_limit > 0 THEN
            SET v_max_rows = p_limit;
        END IF;

        SELECT lr.reason_id, lr.reason_name, lr.category,
               COUNT(m.map_id) AS occurrence_count,
               IFNULL(SUM(pl.profit_loss_amount), 0.00) AS total_financial_impact
        FROM loss_reasons lr
        JOIN profit_loss_reason_map m ON lr.reason_id = m.reason_id
        JOIN profit_loss pl ON m.pl_id = pl.pl_id
        GROUP BY lr.reason_id, lr.reason_name, lr.category
        ORDER BY occurrence_count DESC, total_financial_impact ASC
        LIMIT v_max_rows;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_upload_log_by_company` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_upload_log_by_company`(IN p_company_id INT)
BEGIN
    SELECT * FROM stock_upload_log WHERE company_id = p_company_id ORDER BY uploaded_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_users_by_company` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_users_by_company`(IN p_company_id INT)
BEGIN
    SELECT user_id, username, email, role_id, status, last_login_at FROM users WHERE company_id = p_company_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `list_roles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_roles`()
BEGIN
    SELECT * FROM roles;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `login_attempt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `login_attempt`(
    IN p_username VARCHAR(50), IN p_password_hash VARCHAR(64), IN p_ip_address VARCHAR(45), OUT p_result VARCHAR(50)
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_stored_hash VARCHAR(255);
    DECLARE v_status VARCHAR(20);
    DECLARE v_failed_count INT;
    DECLARE v_locked_at DATETIME;

    SELECT user_id, password_hash, status, failed_login_count
    INTO v_user_id, v_stored_hash, v_status, v_failed_count
    FROM users WHERE username = p_username;

    IF v_user_id IS NULL THEN
        SET p_result = 'USER_NOT_FOUND';
    ELSEIF v_status = 'Locked' THEN
        SELECT timestamp INTO v_locked_at FROM audit_log
        WHERE user_id = v_user_id AND action = 'STATUS_CHANGE' AND new_value = 'Locked'
        ORDER BY timestamp DESC LIMIT 1;

        IF v_locked_at IS NOT NULL AND TIMESTAMPDIFF(MINUTE, v_locked_at, NOW()) >= 15 THEN
            IF v_stored_hash = SHA2(p_password_hash, 256) THEN
                UPDATE users SET failed_login_count = 0, last_login_at = NOW(), status = 'Active' WHERE user_id = v_user_id;
                SET p_result = 'SUCCESS';
                INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) VALUES (v_user_id, 'LOGIN_SUCCESS', p_username, v_user_id, p_ip_address);
            ELSE
                UPDATE users SET failed_login_count = 1, status = 'Active' WHERE user_id = v_user_id;
                SET p_result = 'INVALID_PASSWORD';
                INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) VALUES (v_user_id, 'LOGIN_FAILED', p_username, v_user_id, p_ip_address);
            END IF;
        ELSE
            SET p_result = 'ACCOUNT_LOCKED';
            INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) VALUES (v_user_id, 'LOGIN_BLOCKED_LOCKED', p_username, v_user_id, p_ip_address);
        END IF;
    ELSEIF v_status = 'Inactive' THEN
        SET p_result = 'ACCOUNT_INACTIVE';
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) VALUES (v_user_id, 'LOGIN_BLOCKED_INACTIVE', p_username, v_user_id, p_ip_address);
    ELSEIF v_stored_hash = SHA2(p_password_hash, 256) THEN
        UPDATE users SET failed_login_count = 0, last_login_at = NOW() WHERE user_id = v_user_id;
        SET p_result = 'SUCCESS';
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) VALUES (v_user_id, 'LOGIN_SUCCESS', p_username, v_user_id, p_ip_address);
    ELSE
        UPDATE users SET failed_login_count = failed_login_count + 1,
            status = IF(failed_login_count >= 5, 'Locked', status)
        WHERE user_id = v_user_id;
        SET p_result = 'INVALID_PASSWORD';
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) 
        VALUES (v_user_id, 'LOGIN_FAILED', p_username, v_user_id, p_ip_address);
        IF (v_failed_count + 1) = 5 THEN
            INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
            VALUES (v_user_id, 'STATUS_CHANGE', p_username, v_user_id, 'Active', 'Locked');
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `logout` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `logout`(IN p_user_id INT, IN p_ip_address VARCHAR(45))
BEGIN
    DECLARE v_username VARCHAR(50);
    SELECT username INTO v_username FROM users WHERE user_id = p_user_id;
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address)
    VALUES (p_user_id, 'LOGOUT', v_username, p_user_id, p_ip_address);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `log_barcode_print` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `log_barcode_print`(
    IN p_barcode_id INT, IN p_printed_by INT, IN p_printer_ip_location VARCHAR(150)
)
BEGIN
    INSERT INTO barcode_scan_log (barcode_id, scanned_by, scan_location, module_context)
    VALUES (p_barcode_id, p_printed_by, p_printer_ip_location, 'PRINT_LOG');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `log_permission_denied` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `log_permission_denied`(IN p_user_id INT, IN p_entity_name VARCHAR(100), IN p_action VARCHAR(100))
BEGIN
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
    VALUES (p_user_id, 'PERMISSION_DENIED', p_entity_name, p_user_id, p_action);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `record_payment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `record_payment`(
    IN p_invoice_id INT, IN p_amount_paid DECIMAL(12,2), IN p_payment_mode VARCHAR(30), IN p_transaction_ref VARCHAR(100)
)
BEGIN
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_paid_so_far DECIMAL(12,2);
    DECLARE v_new_paid DECIMAL(12,2);

    SELECT total_amount, paid_amount INTO v_total, v_paid_so_far FROM billing_invoices WHERE invoice_id = p_invoice_id;
    SET v_new_paid = v_paid_so_far + p_amount_paid;

    IF v_new_paid > v_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment exceeds outstanding invoice amount';
    ELSE
        START TRANSACTION;
        INSERT INTO payments (invoice_id, payment_date, amount_paid, payment_mode, transaction_ref)
        VALUES (p_invoice_id, CURDATE(), p_amount_paid, p_payment_mode, p_transaction_ref);

        UPDATE billing_invoices
        SET paid_amount = v_new_paid,
            payment_status = CASE
                WHEN v_new_paid >= v_total THEN 'Paid'
                WHEN v_new_paid > 0 THEN 'Partial'
                ELSE 'Unpaid'
            END
        WHERE invoice_id = p_invoice_id;
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `record_profit_loss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `record_profit_loss`(IN p_shipment_id INT, IN p_revenue_amount DECIMAL(12,2), IN p_total_cost_amount DECIMAL(12,2))
BEGIN
    INSERT INTO profit_loss (shipment_id, revenue_amount, total_cost_amount, profit_loss_amount, record_date)
    VALUES (p_shipment_id, p_revenue_amount, p_total_cost_amount, p_revenue_amount - p_total_cost_amount, CURDATE());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `record_sale` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `record_sale`(
    IN p_product_id INT, IN p_customer_id INT, IN p_shipment_id INT,
    IN p_quantity_sold DECIMAL(12,2), IN p_sale_price DECIMAL(12,2)
)
BEGIN
    DECLARE v_available DECIMAL(12,2);
    SELECT SUM(quantity_on_hand) INTO v_available FROM stock WHERE product_id = p_product_id;

    IF v_available IS NULL OR v_available < p_quantity_sold THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for sale';
    ELSE
        START TRANSACTION;
        INSERT INTO sales_transactions (product_id, customer_id, shipment_id, quantity_sold, sale_price_snapshot, sale_amount, sale_date)
        VALUES (p_product_id, p_customer_id, p_shipment_id, p_quantity_sold, p_sale_price, p_quantity_sold * p_sale_price, CURDATE());

        INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type, reference_id)
        VALUES (p_product_id, 'OUT', p_quantity_sold, p_sale_price, 'Sale', LAST_INSERT_ID());

        UPDATE stock SET quantity_on_hand = quantity_on_hand - p_quantity_sold WHERE product_id = p_product_id;
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_company` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `register_company`(
    IN p_company_name VARCHAR(150), IN p_license_no VARCHAR(50), IN p_gst_no VARCHAR(50),
    IN p_address VARCHAR(255), IN p_contact_email VARCHAR(100), IN p_contact_phone VARCHAR(20),
    OUT p_company_id INT
)
BEGIN
    INSERT INTO companies (company_name, license_no, gst_no, address, contact_email, contact_phone, approval_status)
    VALUES (p_company_name, p_license_no, p_gst_no, p_address, p_contact_email, p_contact_phone, 'Pending');
    SET p_company_id = LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_customer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `register_customer`(
    IN p_user_id INT, IN p_customer_name VARCHAR(150), IN p_address VARCHAR(255),
    IN p_kyc_doc_path VARCHAR(255), IN p_credit_limit DECIMAL(12,2)
)
BEGIN
    INSERT INTO customers (user_id, customer_name, address, kyc_doc_path, credit_limit)
    VALUES (p_user_id, p_customer_name, p_address, p_kyc_doc_path, p_credit_limit);
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
    VALUES (p_user_id, 'CUSTOMER_REGISTERED', p_customer_name, LAST_INSERT_ID(), p_customer_name);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `register_user`(
    IN p_username VARCHAR(50), IN p_email VARCHAR(100), IN p_password_hash VARCHAR(64),
    IN p_phone VARCHAR(20), IN p_role_id INT, IN p_company_id INT
)
BEGIN
    INSERT INTO users (username, email, password_hash, phone, role_id, company_id, status)
    VALUES (p_username, p_email, SHA2(p_password_hash, 256), p_phone, p_role_id, p_company_id, 'Inactive');
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
    VALUES (LAST_INSERT_ID(), 'USER_REGISTERED', p_username, LAST_INSERT_ID(), p_username);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reject_claim` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reject_claim`(
    IN p_claim_id INT, IN p_rejected_by INT, IN p_remark VARCHAR(255)
)
BEGIN
    DECLARE v_old_status VARCHAR(30);
    DECLARE v_role_id INT;

    SELECT role_id INTO v_role_id FROM users WHERE user_id = p_rejected_by;
    IF v_role_id NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized: Only Super Admin or Company Admin can reject claims';
    END IF;

    IF p_remark IS NULL OR TRIM(p_remark) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rejection remark is mandatory';
    END IF;

    SELECT status INTO v_old_status FROM claims WHERE claim_id = p_claim_id;

    START TRANSACTION;
    UPDATE claims
    SET status = 'Rejected',
        approved_amount = 0,
        resolved_by = p_rejected_by,
        resolved_date = NOW()
    WHERE claim_id = p_claim_id;

    INSERT INTO claim_status_history (claim_id, old_status, new_status, changed_by, remark)
    VALUES (p_claim_id, v_old_status, 'Rejected', p_rejected_by, p_remark);
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `request_password_reset` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `request_password_reset`(
    IN p_user_id    INT,
    IN p_token      VARCHAR(64),
    IN p_expires_at DATETIME
)
BEGIN
    
    DECLARE v_count INT DEFAULT 0;
    SELECT COUNT(*) INTO v_count FROM users WHERE user_id = p_user_id AND is_active = 1;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Precondition Failed: User does not exist or is inactive';
    END IF;

    
    INSERT INTO password_resets (user_id, token, expires_at, used)
    VALUES (p_user_id, p_token, p_expires_at, 0);

    
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
    VALUES (p_user_id, 'PASSWORD_RESET_REQUESTED', 'users', p_user_id, 'Token issued');

    SELECT 'Reset token created' AS status, LAST_INSERT_ID() AS reset_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `review_claim` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `review_claim`(
    IN p_claim_id INT, IN p_new_status VARCHAR(30), IN p_approved_amount DECIMAL(12,2),
    IN p_changed_by INT, IN p_remark VARCHAR(255)
)
BEGIN
    DECLARE v_old_status VARCHAR(30);
    DECLARE v_role_id INT;

    SELECT role_id INTO v_role_id FROM users WHERE user_id = p_changed_by;
    IF v_role_id NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized: Only Super Admin or Company Admin can review claims';
    END IF;

    SELECT status INTO v_old_status FROM claims WHERE claim_id = p_claim_id;

    START TRANSACTION;
    UPDATE claims
    SET status = p_new_status,
        approved_amount = p_approved_amount
    WHERE claim_id = p_claim_id;

    INSERT INTO claim_status_history (claim_id, old_status, new_status, changed_by, remark)
    VALUES (p_claim_id, v_old_status, p_new_status, p_changed_by, p_remark);
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `review_compliance_document` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `review_compliance_document`(IN p_doc_id INT, IN p_new_status VARCHAR(20))
BEGIN
    UPDATE compliance_documents SET status = p_new_status WHERE doc_id = p_doc_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `scan_barcode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `scan_barcode`(
    IN p_barcode_value VARCHAR(100), IN p_scanned_by INT, IN p_scan_location VARCHAR(150),
    IN p_module_context VARCHAR(50), OUT p_entity_type VARCHAR(30), OUT p_entity_id INT
)
BEGIN
    DECLARE v_barcode_id INT;

    SELECT barcode_id, entity_type, entity_id
    INTO v_barcode_id, p_entity_type, p_entity_id
    FROM barcode_entries
    WHERE barcode_value = p_barcode_value;

    IF v_barcode_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid barcode value';
    ELSE
        INSERT INTO barcode_scan_log (barcode_id, scanned_by, scan_location, module_context)
        VALUES (v_barcode_id, p_scanned_by, p_scan_location, p_module_context);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `settle_claim` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `settle_claim`(
    IN p_claim_id INT, IN p_resolved_by INT
)
BEGIN
    DECLARE v_old_status VARCHAR(30);
    DECLARE v_customer_id INT;
    DECLARE v_approved_amount DECIMAL(12,2);
    DECLARE v_shipment_id INT;
    DECLARE v_role_id INT;

    SELECT role_id INTO v_role_id FROM users WHERE user_id = p_resolved_by;
    IF v_role_id NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized: Only Super Admin or Company Admin can settle claims';
    END IF;

    SELECT status, customer_id, approved_amount, shipment_id
    INTO v_old_status, v_customer_id, v_approved_amount, v_shipment_id
    FROM claims WHERE claim_id = p_claim_id;

    START TRANSACTION;
    UPDATE claims
    SET status = 'Settled',
        resolved_by = p_resolved_by,
        resolved_date = NOW()
    WHERE claim_id = p_claim_id;

    INSERT INTO claim_status_history (claim_id, old_status, new_status, changed_by, remark)
    VALUES (p_claim_id, v_old_status, 'Settled', p_resolved_by, 'Claim settled and credit note posted to billing');
    
    IF v_approved_amount IS NOT NULL AND v_approved_amount > 0 THEN
        INSERT INTO billing_invoices (customer_id, shipment_id, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, paid_amount, payment_status)
        VALUES (v_customer_id, v_shipment_id, CURDATE(), CURDATE(), -v_approved_amount, 0, -v_approved_amount, 0.00, 'Paid');
    END IF;

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `start_upload_log` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `start_upload_log`(
    IN p_company_id INT, IN p_uploaded_by INT, IN p_file_name VARCHAR(255), OUT p_upload_id INT
)
BEGIN
    INSERT INTO stock_upload_log (company_id, uploaded_by, file_name, total_records, success_count, failure_count)
    VALUES (p_company_id, p_uploaded_by, p_file_name, 0, 0, 0);
    SET p_upload_id = LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `suspend_company` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `suspend_company`(IN p_company_id INT, IN p_approver_user_id INT, IN p_reason VARCHAR(255))
BEGIN
    DECLARE v_company_name VARCHAR(150);
    SELECT company_name INTO v_company_name FROM companies WHERE company_id = p_company_id;
    UPDATE companies SET approval_status = 'Suspended' WHERE company_id = p_company_id;
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
    VALUES (p_approver_user_id, 'SUSPEND_COMPANY', v_company_name, p_company_id, 'Active', p_reason);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `unlock_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `unlock_user`(IN p_user_id INT, IN p_unlocked_by INT)
BEGIN
    DECLARE v_username VARCHAR(50);
    DECLARE v_approver_role INT;
    
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_unlocked_by;
    IF v_approver_role = 1 THEN
        SELECT username INTO v_username FROM users WHERE user_id = p_user_id;
        UPDATE users SET status = 'Active', failed_login_count = 0 WHERE user_id = p_user_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value)
        VALUES (p_unlocked_by, 'UNLOCK_USER', v_username, p_user_id, 'Locked', 'Active');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can unlock users';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_barcode_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_barcode_entry`(
    IN p_barcode_id INT, IN p_barcode_type ENUM('Code128','QR'),
    IN p_entity_type VARCHAR(30), IN p_entity_id INT, IN p_image_path VARCHAR(255)
)
BEGIN
    UPDATE barcode_entries
    SET barcode_type = COALESCE(p_barcode_type, barcode_type), 
        entity_type = COALESCE(p_entity_type, entity_type), 
        entity_id = COALESCE(p_entity_id, entity_id), 
        image_path = COALESCE(p_image_path, image_path)
    WHERE barcode_id = p_barcode_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_billing_invoice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_billing_invoice`(
    IN p_invoice_id INT, IN p_due_date DATE, IN p_updated_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_updated_by;
    IF v_approver_role = 1 THEN
        UPDATE billing_invoices SET due_date = p_due_date WHERE invoice_id = p_invoice_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_updated_by, 'UPDATE_INVOICE', 'billing_invoices', p_invoice_id, 'Updated');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can update invoices';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_claims` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_claims`(
    IN p_claim_id int(11),
    IN p_requesting_user_id INT,
    IN p_shipment_id int(11),
    IN p_container_id int(11),
    IN p_product_id int(11),
    IN p_customer_id int(11),
    IN p_claim_type enum('Loss','Damage','Shortage'),
    IN p_description varchar(255),
    IN p_incident_date date,
    IN p_claimed_amount decimal(12,2),
    IN p_approved_amount decimal(12,2),
    IN p_reason_id int(11),
    IN p_status enum('Filed','Under Review','Approved','Rejected','Settled'),
    IN p_filed_by int(11),
    IN p_filed_date datetime,
    IN p_resolved_by int(11),
    IN p_resolved_date datetime
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE claims
    SET shipment_id = COALESCE(p_shipment_id, shipment_id),
        container_id = COALESCE(p_container_id, container_id),
        product_id = COALESCE(p_product_id, product_id),
        customer_id = COALESCE(p_customer_id, customer_id),
        claim_type = COALESCE(p_claim_type, claim_type),
        description = COALESCE(p_description, description),
        incident_date = COALESCE(p_incident_date, incident_date),
        claimed_amount = COALESCE(p_claimed_amount, claimed_amount),
        approved_amount = COALESCE(p_approved_amount, approved_amount),
        reason_id = COALESCE(p_reason_id, reason_id),
        status = COALESCE(p_status, status),
        filed_by = COALESCE(p_filed_by, filed_by),
        filed_date = COALESCE(p_filed_date, filed_date),
        resolved_by = COALESCE(p_resolved_by, resolved_by),
        resolved_date = COALESCE(p_resolved_date, resolved_date)
    WHERE claim_id = p_claim_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_claim_documents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_claim_documents`(
    IN p_doc_id int(11),
    IN p_requesting_user_id INT,
    IN p_claim_id int(11),
    IN p_doc_type enum('Photo Evidence','Inspection Report','Other'),
    IN p_uploaded_by int(11),
    IN p_uploaded_at datetime
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE claim_documents
    SET claim_id = COALESCE(p_claim_id, claim_id),
        doc_type = COALESCE(p_doc_type, doc_type),
        uploaded_by = COALESCE(p_uploaded_by, uploaded_by),
        uploaded_at = COALESCE(p_uploaded_at, uploaded_at)
    WHERE doc_id = p_doc_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_companies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_companies`(
    IN p_company_id int(11),
    IN p_requesting_user_id INT,
    IN p_company_name varchar(150),
    IN p_license_no varchar(50),
    IN p_gst_no varchar(50),
    IN p_address varchar(255),
    IN p_contact_email varchar(100),
    IN p_contact_phone varchar(20),
    IN p_approval_status enum('Pending','Active','Suspended')
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE companies
    SET company_name = COALESCE(p_company_name, company_name),
        license_no = COALESCE(p_license_no, license_no),
        gst_no = COALESCE(p_gst_no, gst_no),
        address = COALESCE(p_address, address),
        contact_email = COALESCE(p_contact_email, contact_email),
        contact_phone = COALESCE(p_contact_phone, contact_phone),
        approval_status = COALESCE(p_approval_status, approval_status)
    WHERE company_id = p_company_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_compliance_document` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_compliance_document`(
    IN p_doc_id INT, IN p_doc_number VARCHAR(100), IN p_issue_date DATE, IN p_expiry_date DATE, IN p_updated_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_updated_by;
    IF v_approver_role = 1 THEN
        UPDATE compliance_documents 
        SET doc_number = p_doc_number, issue_date = p_issue_date, expiry_date = p_expiry_date 
        WHERE doc_id = p_doc_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_updated_by, 'UPDATE_COMPLIANCE_DOC', 'compliance_documents', p_doc_id, p_doc_number);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can update compliance documents';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_container` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_container`(IN p_container_id INT, IN p_status VARCHAR(20), IN p_current_port_id INT)
BEGIN
    UPDATE containers      
    SET status = COALESCE(p_status, status), 
        current_port_id = COALESCE(p_current_port_id, current_port_id) 
    WHERE container_id = p_container_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_containers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_containers`(
    IN p_container_id int(11),
    IN p_requesting_user_id INT,
    IN p_container_number varchar(20),
    IN p_type enum('Dry','Reefer','Open Top','Flat Rack','Tank'),
    IN p_size enum('20ft','40ft','40ft HC','45ft'),
    IN p_image_url varchar(255),
    IN p_tare_weight_kg decimal(10,2),
    IN p_max_gross_weight_kg decimal(10,2),
    IN p_goods_capacity_kg decimal(10,2),
    IN p_goods_capacity_cbm decimal(10,2),
    IN p_status enum('Available','Allocated','In-Transit','Under Maintenance'),
    IN p_current_port_id int(11),
    IN p_owner_company_id int(11)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE containers
    SET container_number = COALESCE(p_container_number, container_number),
        type = COALESCE(p_type, type),
        size = COALESCE(p_size, size),
        image_url = COALESCE(p_image_url, image_url),
        tare_weight_kg = COALESCE(p_tare_weight_kg, tare_weight_kg),
        max_gross_weight_kg = COALESCE(p_max_gross_weight_kg, max_gross_weight_kg),
        goods_capacity_kg = COALESCE(p_goods_capacity_kg, goods_capacity_kg),
        goods_capacity_cbm = COALESCE(p_goods_capacity_cbm, goods_capacity_cbm),
        status = COALESCE(p_status, status),
        current_port_id = COALESCE(p_current_port_id, current_port_id),
        owner_company_id = COALESCE(p_owner_company_id, owner_company_id)
    WHERE container_id = p_container_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_customers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_customers`(
    IN p_customer_id int(11),
    IN p_requesting_user_id INT,
    IN p_user_id int(11),
    IN p_customer_name varchar(150),
    IN p_address varchar(255),
    IN p_credit_limit decimal(12,2)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE customers
    SET user_id = COALESCE(p_user_id, user_id),
        customer_name = COALESCE(p_customer_name, customer_name),
        address = COALESCE(p_address, address),
        credit_limit = COALESCE(p_credit_limit, credit_limit)
    WHERE customer_id = p_customer_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_invoice_line_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_invoice_line_item`(
    IN p_item_id INT, IN p_quantity DECIMAL(12,2), IN p_unit_price DECIMAL(12,2), IN p_updated_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_updated_by;
    IF v_approver_role = 1 THEN
        UPDATE invoice_line_items 
        SET quantity = p_quantity, unit_price = p_unit_price, line_total = p_quantity * p_unit_price 
        WHERE item_id = p_item_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_updated_by, 'UPDATE_INVOICE_LINE_ITEM', 'invoice_line_items', p_item_id, 'Updated');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can update line items';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_loss_reasons` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_loss_reasons`(
    IN p_reason_id int(11),
    IN p_requesting_user_id INT,
    IN p_reason_code varchar(50),
    IN p_reason_name varchar(100),
    IN p_description varchar(255)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE loss_reasons
    SET reason_code = COALESCE(p_reason_code, reason_code),
        reason_name = COALESCE(p_reason_name, reason_name),
        description = COALESCE(p_description, description)
    WHERE reason_id = p_reason_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_movement_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_movement_status`(
    IN p_shipment_id INT, IN p_status VARCHAR(30), IN p_checkpoint_location VARCHAR(150),
    IN p_expected_arrival_date DATETIME, IN p_actual_arrival_date DATETIME, IN p_updated_by INT
)
BEGIN
    DECLARE v_delay_days INT DEFAULT 0;

    IF p_actual_arrival_date IS NOT NULL AND p_expected_arrival_date IS NOT NULL THEN
        SET v_delay_days = DATEDIFF(p_actual_arrival_date, p_expected_arrival_date);
        IF v_delay_days < 0 THEN
            SET v_delay_days = 0;
        END IF;
    END IF;

    IF p_status = 'Departed' THEN
        CALL check_shipment_can_depart(p_shipment_id, @can_depart);
        IF @can_depart = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Shipment cannot depart: missing or expired mandatory compliance documents';
        END IF;
    END IF;

    INSERT INTO container_movements (shipment_id, status, checkpoint_location, departure_date, expected_arrival_date, actual_arrival_date, delay_days, updated_by)
    VALUES (p_shipment_id, p_status, p_checkpoint_location, IF(p_status = 'Departed', NOW(), NULL), p_expected_arrival_date, p_actual_arrival_date, v_delay_days, p_updated_by);

    UPDATE shipment SET status = COALESCE(p_status, status) WHERE shipment_id = p_shipment_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_payment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_payment`(
    IN p_payment_id INT, IN p_amount_paid DECIMAL(12,2), IN p_updated_by INT
)
BEGIN
    DECLARE v_approver_role INT;
    SELECT role_id INTO v_approver_role FROM users WHERE user_id = p_updated_by;
    IF v_approver_role = 1 THEN
        UPDATE payments SET amount_paid = p_amount_paid WHERE payment_id = p_payment_id;
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
        VALUES (p_updated_by, 'UPDATE_PAYMENT', 'payments', p_payment_id, 'Updated');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only Super Admin can update payments';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_ports` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_ports`(
    IN p_port_id int(11),
    IN p_requesting_user_id INT,
    IN p_port_name varchar(100),
    IN p_port_code varchar(20),
    IN p_country varchar(50),
    IN p_latitude decimal(10,6),
    IN p_longitude decimal(10,6)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE ports
    SET port_name = COALESCE(p_port_name, port_name),
        port_code = COALESCE(p_port_code, port_code),
        country = COALESCE(p_country, country),
        latitude = COALESCE(p_latitude, latitude),
        longitude = COALESCE(p_longitude, longitude)
    WHERE port_id = p_port_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_price` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_price`(
    IN p_pricing_id INT, IN p_new_base_price DECIMAL(12,2), IN p_changed_by INT, IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_old_price DECIMAL(12,2);
    DECLARE v_seasonal DECIMAL(5,2);
    DECLARE v_demand DECIMAL(5,2);
    DECLARE v_new_final DECIMAL(12,2);

    SELECT base_price, seasonal_multiplier, demand_multiplier
    INTO v_old_price, v_seasonal, v_demand
    FROM pricing_rules WHERE pricing_id = p_pricing_id;

    SET v_new_final = COALESCE(p_new_base_price, v_old_price) * v_seasonal * v_demand;

    START TRANSACTION;
    UPDATE pricing_rules
    SET base_price = COALESCE(p_new_base_price, base_price), final_price = v_new_final
    WHERE pricing_id = p_pricing_id;

    INSERT INTO pricing_audit (pricing_id, old_price, new_price, changed_by, reason)
    VALUES (p_pricing_id, v_old_price, p_new_base_price, p_changed_by, p_reason);
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_pricing_rules` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_pricing_rules`(
    IN p_pricing_id int(11),
    IN p_requesting_user_id INT,
    IN p_container_type enum('Dry','Reefer','Open Top','Flat Rack','Tank'),
    IN p_container_size enum('20ft','40ft','40ft HC','45ft'),
    IN p_route_id int(11),
    IN p_base_price decimal(12,2),
    IN p_seasonal_multiplier decimal(5,2),
    IN p_demand_multiplier decimal(5,2),
    IN p_final_price decimal(12,2),
    IN p_valid_from date,
    IN p_valid_to date
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE pricing_rules
    SET container_type = COALESCE(p_container_type, container_type),
        container_size = COALESCE(p_container_size, container_size),
        route_id = COALESCE(p_route_id, route_id),
        base_price = COALESCE(p_base_price, base_price),
        seasonal_multiplier = COALESCE(p_seasonal_multiplier, seasonal_multiplier),
        demand_multiplier = COALESCE(p_demand_multiplier, demand_multiplier),
        final_price = COALESCE(p_final_price, final_price),
        valid_from = COALESCE(p_valid_from, valid_from),
        valid_to = COALESCE(p_valid_to, valid_to)
    WHERE pricing_id = p_pricing_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_product`(IN p_product_id INT, IN p_unit_cost DECIMAL(12,2), IN p_unit_price DECIMAL(12,2))
BEGIN
    UPDATE products 
    SET unit_cost = COALESCE(p_unit_cost, unit_cost), 
        unit_price = COALESCE(p_unit_price, unit_price) 
    WHERE product_id = p_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_products` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_products`(
    IN p_product_id int(11),
    IN p_requesting_user_id INT,
    IN p_product_name varchar(150),
    IN p_category varchar(100),
    IN p_hsn_code varchar(20),
    IN p_unit_of_measure varchar(20),
    IN p_unit_cost decimal(12,2),
    IN p_unit_price decimal(12,2)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE products
    SET product_name = COALESCE(p_product_name, product_name),
        category = COALESCE(p_category, category),
        hsn_code = COALESCE(p_hsn_code, hsn_code),
        unit_of_measure = COALESCE(p_unit_of_measure, unit_of_measure),
        unit_cost = COALESCE(p_unit_cost, unit_cost),
        unit_price = COALESCE(p_unit_price, unit_price)
    WHERE product_id = p_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_sales_transactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_sales_transactions`(
    IN p_transaction_id int(11),
    IN p_requesting_user_id INT,
    IN p_product_id int(11),
    IN p_customer_id int(11),
    IN p_shipment_id int(11),
    IN p_quantity_sold decimal(12,2),
    IN p_sale_price_snapshot decimal(12,2),
    IN p_sale_amount decimal(12,2),
    IN p_sale_date date
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE sales_transactions
    SET product_id = COALESCE(p_product_id, product_id),
        customer_id = COALESCE(p_customer_id, customer_id),
        shipment_id = COALESCE(p_shipment_id, shipment_id),
        quantity_sold = COALESCE(p_quantity_sold, quantity_sold),
        sale_price_snapshot = COALESCE(p_sale_price_snapshot, sale_price_snapshot),
        sale_amount = COALESCE(p_sale_amount, sale_amount),
        sale_date = COALESCE(p_sale_date, sale_date)
    WHERE transaction_id = p_transaction_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_shipment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_shipment`(
    IN p_shipment_id int(11),
    IN p_requesting_user_id INT,
    IN p_customer_id int(11),
    IN p_container_id int(11),
    IN p_origin_port_id int(11),
    IN p_destination_port_id int(11),
    IN p_vessel_id int(11),
    IN p_booking_date date,
    IN p_cargo_description varchar(255),
    IN p_cargo_weight_kg decimal(10,2),
    IN p_cargo_volume_cbm decimal(10,2),
    IN p_cargo_declared_value decimal(12,2),
    IN p_freight_cost decimal(12,2),
    IN p_insurance_cost decimal(12,2),
    IN p_other_charges decimal(12,2),
    IN p_status enum('Booked','Container Allocated','Departed','In Transit','Customs Hold','Arrived','Delivered','Cancelled'),
    IN p_created_by int(11)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE shipment
    SET customer_id = COALESCE(p_customer_id, customer_id),
        container_id = COALESCE(p_container_id, container_id),
        origin_port_id = COALESCE(p_origin_port_id, origin_port_id),
        destination_port_id = COALESCE(p_destination_port_id, destination_port_id),
        vessel_id = COALESCE(p_vessel_id, vessel_id),
        booking_date = COALESCE(p_booking_date, booking_date),
        cargo_description = COALESCE(p_cargo_description, cargo_description),
        cargo_weight_kg = COALESCE(p_cargo_weight_kg, cargo_weight_kg),
        cargo_volume_cbm = COALESCE(p_cargo_volume_cbm, cargo_volume_cbm),
        cargo_declared_value = COALESCE(p_cargo_declared_value, cargo_declared_value),
        freight_cost = COALESCE(p_freight_cost, freight_cost),
        insurance_cost = COALESCE(p_insurance_cost, insurance_cost),
        other_charges = COALESCE(p_other_charges, other_charges),
        status = COALESCE(p_status, status),
        created_by = COALESCE(p_created_by, created_by)
    WHERE shipment_id = p_shipment_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_stock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_stock`(
    IN p_stock_id int(11),
    IN p_requesting_user_id INT,
    IN p_company_id int(11),
    IN p_product_id int(11),
    IN p_warehouse_location varchar(150),
    IN p_quantity_on_hand decimal(12,2),
    IN p_batch_no varchar(50),
    IN p_expiry_date date,
    IN p_last_updated datetime
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE stock
    SET company_id = COALESCE(p_company_id, company_id),
        product_id = COALESCE(p_product_id, product_id),
        warehouse_location = COALESCE(p_warehouse_location, warehouse_location),
        quantity_on_hand = COALESCE(p_quantity_on_hand, quantity_on_hand),
        batch_no = COALESCE(p_batch_no, batch_no),
        expiry_date = COALESCE(p_expiry_date, expiry_date),
        last_updated = COALESCE(p_last_updated, last_updated)
    WHERE stock_id = p_stock_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_users` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_users`(
    IN p_user_id int(11),
    IN p_requesting_user_id INT,
    IN p_username varchar(50),
    IN p_email varchar(100),
    IN p_phone varchar(20),
    IN p_role_id int(11),
    IN p_company_id int(11),
    IN p_status enum('Active','Inactive','Locked'),
    IN p_failed_login_count int(11),
    IN p_last_login_at datetime
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE users
    SET username = COALESCE(p_username, username),
        email = COALESCE(p_email, email),
        phone = COALESCE(p_phone, phone),
        role_id = COALESCE(p_role_id, role_id),
        company_id = COALESCE(p_company_id, company_id),
        status = COALESCE(p_status, status),
        failed_login_count = COALESCE(p_failed_login_count, failed_login_count),
        last_login_at = COALESCE(p_last_login_at, last_login_at)
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_vessels` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_vessels`(
    IN p_vessel_id int(11),
    IN p_requesting_user_id INT,
    IN p_vessel_name varchar(100),
    IN p_imo_number varchar(30),
    IN p_capacity_teu int(11)
)
BEGIN
    DECLARE v_role INT;
    SELECT role_id INTO v_role FROM users WHERE user_id = p_requesting_user_id;
    IF v_role NOT IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission Denied: Admin access required to update';
    END IF;
    UPDATE vessels
    SET vessel_name = COALESCE(p_vessel_name, vessel_name),
        imo_number = COALESCE(p_imo_number, imo_number),
        capacity_teu = COALESCE(p_capacity_teu, capacity_teu)
    WHERE vessel_id = p_vessel_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `upload_compliance_document` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `upload_compliance_document`(
    IN p_shipment_id INT, IN p_doc_type VARCHAR(50), IN p_doc_number VARCHAR(100),
    IN p_issuing_authority VARCHAR(150), IN p_issue_date DATE, IN p_expiry_date DATE,
    IN p_file_path VARCHAR(255), IN p_uploaded_by INT
)
BEGIN
    INSERT INTO compliance_documents (shipment_id, doc_type, doc_number, issuing_authority, issue_date, expiry_date, status, file_path, uploaded_by)
    VALUES (p_shipment_id, p_doc_type, p_doc_number, p_issuing_authority, p_issue_date, p_expiry_date, 'Pending', p_file_path, p_uploaded_by);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `upload_stock_row` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `upload_stock_row`(
    IN p_company_id INT, IN p_product_id INT, IN p_warehouse_location VARCHAR(150),
    IN p_quantity DECIMAL(12,2), IN p_unit_cost DECIMAL(12,2), IN p_batch_no VARCHAR(50),
    IN p_expiry_date DATE, IN p_upload_id INT
)
BEGIN
    IF p_quantity < 0 OR p_unit_cost < 0 THEN
        UPDATE stock_upload_log SET failure_count = failure_count + 1, total_records = total_records + 1 WHERE upload_id = p_upload_id;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid stock row: quantity or unit cost is negative';
    ELSE
        START TRANSACTION;
        INSERT INTO stock (company_id, product_id, warehouse_location, quantity_on_hand, batch_no, expiry_date)
        VALUES (p_company_id, p_product_id, p_warehouse_location, p_quantity, p_batch_no, p_expiry_date);

        INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type, reference_id)
        VALUES (p_product_id, 'IN', p_quantity, p_unit_cost, 'Upload', p_upload_id);

        UPDATE stock_upload_log SET success_count = success_count + 1, total_records = total_records + 1 WHERE upload_id = p_upload_id;
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validate_reset_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validate_reset_token`(
    IN p_token VARCHAR(64)
)
BEGIN
    DECLARE v_user_id  INT DEFAULT NULL;
    DECLARE v_expires  DATETIME DEFAULT NULL;
    DECLARE v_used     TINYINT(1) DEFAULT 1;

    SELECT user_id, expires_at, used
    INTO   v_user_id, v_expires, v_used
    FROM   password_resets
    WHERE  token = p_token
    ORDER  BY id DESC
    LIMIT  1;

    IF v_user_id IS NULL THEN
        SELECT 'INVALID' AS token_status, NULL AS user_id;
    ELSEIF v_used = 1 THEN
        SELECT 'USED' AS token_status, NULL AS user_id;
    ELSEIF v_expires <= NOW() THEN
        SELECT 'EXPIRED' AS token_status, NULL AS user_id;
    ELSE
        SELECT 'VALID' AS token_status, v_user_id AS user_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `void_invoice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `void_invoice`(IN p_invoice_id INT, IN p_voided_by INT, IN p_reason VARCHAR(255))
BEGIN
    UPDATE billing_invoices
    SET payment_status = 'Void',
        updated_at = NOW()
    WHERE invoice_id = p_invoice_id AND payment_status != 'Paid';
    
    INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value)
    VALUES (p_voided_by, 'INVOICE_VOIDED', 'billing_invoices', p_invoice_id, p_reason);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-03 23:56:21
