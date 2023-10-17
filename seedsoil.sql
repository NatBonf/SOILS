-- MariaDB dump 10.19  Distrib 10.11.3-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: seedsoil
-- ------------------------------------------------------
-- Server version	10.11.3-MariaDB-1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `containers`
--

DROP TABLE IF EXISTS `containers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `containers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `containers`
--

LOCK TABLES `containers` WRITE;
/*!40000 ALTER TABLE `containers` DISABLE KEYS */;
INSERT INTO `containers` VALUES
(1,'COD12345','DISPONIVEL'),
(2,'COD66331','DISPONIVEL'),
(3,'COD54321','ALOCADO'),
(4,'COD78564','DISPONIVEL'),
(5,'COD79067','DISPONIVEL'),
(6,'COD43657','DISPONIVEL');
/*!40000 ALTER TABLE `containers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pontos_coleta`
--

DROP TABLE IF EXISTS `pontos_coleta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pontos_coleta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `endereco` varchar(100) NOT NULL,
  `responsavel` varchar(100) NOT NULL,
  `telefone` varchar(15) NOT NULL,
  `container` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pontos_coleta`
--

LOCK TABLES `pontos_coleta` WRITE;
/*!40000 ALTER TABLE `pontos_coleta` DISABLE KEYS */;
INSERT INTO `pontos_coleta` VALUES
(1,'Rua das Oliveiras, 123','Paulo Venancio','(11) 3333-4444',3),
(2,'Avenida das Palmeiras, 456','Ana Valentina de Nogueira','(21) 2222-3333',NULL),
(3,'Rua das Sementes, 789','Arlete do Santos','(31) 3231-3031',NULL),
(4,'Alameda das Árvores, 321','Devanir Feliciano','(43) 5555-7788',NULL),
(5,'Travessa das Flores, 567','Vanessa dos Santos Paixao','(47) 98123-0123',NULL),
(6,'Rua dos Bambus, 234','Cicero Jose Silva','(75) 9999-4567',NULL);
/*!40000 ALTER TABLE `pontos_coleta` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-10-17 11:11:27
