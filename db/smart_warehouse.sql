-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: smart_warehouse
-- ------------------------------------------------------
-- Server version	8.0.46

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
-- Current Database: `smart_warehouse`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `smart_warehouse` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `smart_warehouse`;

--
-- Table structure for table `goods`
--

DROP TABLE IF EXISTS `goods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goods` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `create_time` datetime(6) DEFAULT NULL,
  `current_stock` int DEFAULT NULL,
  `max_stock` int DEFAULT NULL,
  `min_stock` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `update_time` datetime(6) DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKl8eh87voijifwa1sd41xavgn8` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods`
--

/*!40000 ALTER TABLE `goods` DISABLE KEYS */;
INSERT INTO `goods` VALUES (1,'G001','2026-09-20 09:00:00.000000',45,100,20,'罗技 M330 无线鼠标','2026-11-01 00:41:48.478802','中心仓库','数码配件'),(2,'G002','2026-09-20 09:05:00.000000',28,80,10,'机械键盘 K8','2026-11-01 01:13:30.514319','中心仓库','数码配件'),(3,'G003','2026-09-21 10:00:00.000000',22,30,5,'27 英寸显示器','2026-10-12 16:00:00.000000','中心仓库','数码配件'),(4,'G004','2026-09-22 11:00:00.000000',5,60,15,'USB-C 扩展坞','2026-10-14 10:10:00.000000','二号仓','数码配件'),(5,'G005','2026-09-22 11:10:00.000000',90,120,20,'蓝牙降噪耳机','2026-10-16 11:40:00.000000','二号仓','数码配件'),(6,'G006','2026-09-23 09:30:00.000000',55,50,10,'20000mAh 移动电源','2026-10-19 14:05:00.000000','二号仓','数码配件'),(7,'G007','2026-09-25 14:00:00.000000',12,20,5,'生鲜保温箱','2026-10-15 08:40:00.000000','冷链仓','冷链物资'),(8,'G008','2026-09-26 10:20:00.000000',8,40,8,'无线扫码枪','2026-10-22 09:20:00.000000','中心仓库','仓储设备'),(9,'G009','2026-09-28 15:00:00.000000',8,15,3,'标签打印机','2026-10-25 15:55:00.000000','二号仓','仓储设备'),(10,'G010','2026-09-30 09:00:00.000000',500,1000,100,'打包纸箱（大号）','2026-11-01 00:31:18.915964','中心仓库','包装耗材'),(11,'G011','2026-10-30 10:00:00.000000',8,40,5,'小米 14 手机','2026-11-01 18:00:00.000000','中心仓库','数码配件'),(12,'G012','2026-10-30 10:00:00.000000',5,30,8,'华为 MatePad','2026-11-01 18:00:00.000000','中心仓库','数码配件'),(13,'G013','2026-10-30 10:00:00.000000',220,500,50,'Type-C 数据线','2026-11-01 18:00:00.000000','中心仓库','数码配件'),(14,'G014','2026-10-30 10:00:00.000000',110,300,30,'65W 氮化镓充电器','2026-11-01 18:00:00.000000','中心仓库','数码配件'),(15,'G015','2026-10-30 10:00:00.000000',65,150,20,'蓝牙音箱','2026-11-01 18:00:00.000000','二号仓','数码配件'),(16,'G016','2026-10-30 10:00:00.000000',62,120,15,'智能手环','2026-11-01 18:00:00.000000','二号仓','数码配件'),(17,'G017','2026-10-30 10:00:00.000000',38,30,10,'4K 摄像头','2026-11-01 18:00:00.000000','二号仓','仓储设备'),(18,'G018','2026-10-30 10:00:00.000000',35,100,10,'路由器 AX3000','2026-11-01 18:00:00.000000','二号仓','数码配件'),(19,'G019','2026-10-30 10:00:00.000000',32,80,10,'移动硬盘 1TB','2026-11-01 18:00:00.000000','中心仓库','数码配件'),(20,'G020','2026-10-30 10:00:00.000000',180,300,30,'U 盘 128G','2026-11-01 18:00:00.000000','中心仓库','数码配件'),(21,'G021','2026-10-30 10:00:00.000000',900,2000,100,'一次性雨衣','2026-11-01 18:00:00.000000','退货仓','劳保用品'),(22,'G022','2026-10-30 10:00:00.000000',480,1000,50,'泡沫填充物','2026-11-01 18:00:00.000000','退货仓','包装耗材'),(23,'G023','2026-10-30 10:00:00.000000',420,800,40,'缠绕膜','2026-11-01 18:00:00.000000','退货仓','包装耗材'),(24,'G024','2026-10-30 10:00:00.000000',740,1500,100,'冷链冰袋','2026-11-01 18:00:00.000000','冷链仓','冷链物资'),(25,'G025','2026-10-30 10:00:00.000000',110,200,20,'保温泡沫箱','2026-11-01 18:00:00.000000','冷链仓','冷链物资'),(26,'G026','2026-10-30 10:00:00.000000',35,60,40,'温度记录仪','2026-11-01 18:00:00.000000','冷链仓','冷链物资'),(27,'G027','2026-10-30 10:00:00.000000',24,50,5,'电子秤','2026-11-01 18:00:00.000000','二号仓','仓储设备'),(28,'G028','2026-10-30 10:00:00.000000',1100,2000,100,'封箱胶带','2026-11-01 18:00:00.000000','中心仓库','包装耗材'),(29,'G029','2026-10-30 10:00:00.000000',650,1000,50,'快递面单纸','2026-11-01 18:00:00.000000','中心仓库','包装耗材'),(30,'G030','2026-10-30 10:00:00.000000',21,40,5,'手持终端 PDA','2026-11-01 01:01:12.742627','二号仓','仓储设备');
/*!40000 ALTER TABLE `goods` ENABLE KEYS */;

--
-- Table structure for table `inbound_order`
--

DROP TABLE IF EXISTS `inbound_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inbound_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `goods_id` bigint DEFAULT NULL,
  `goods_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `inbound_time` datetime(6) DEFAULT NULL,
  `operator` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `order_no` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inbound_order`
--

/*!40000 ALTER TABLE `inbound_order` DISABLE KEYS */;
INSERT INTO `inbound_order` VALUES (1,1,'罗技 M330 无线鼠标','2026-10-03 09:12:00.000000','张伟','IN-20261003-001',60,'中心仓库'),(2,2,'机械键盘 K8','2026-10-03 09:30:00.000000','张伟','IN-20261003-002',40,'中心仓库'),(3,3,'27 英寸显示器','2026-10-05 10:05:00.000000','李娜','IN-20261005-001',25,'中心仓库'),(4,4,'USB-C 扩展坞','2026-10-07 14:20:00.000000','李娜','IN-20261007-001',50,'二号仓'),(5,5,'蓝牙降噪耳机','2026-10-09 09:00:00.000000','张伟','IN-20261009-001',100,'二号仓'),(6,6,'20000mAh 移动电源','2026-10-12 11:15:00.000000','王强','IN-20261012-001',60,'二号仓'),(7,7,'生鲜保温箱','2026-10-15 08:40:00.000000','王强','IN-20261015-001',12,'冷链仓'),(8,8,'无线扫码枪','2026-10-18 16:10:00.000000','李娜','IN-20261018-001',30,'中心仓库'),(9,9,'标签打印机','2026-10-21 10:25:00.000000','张伟','IN-20261021-001',10,'二号仓'),(10,10,'打包纸箱（大号）','2026-10-24 13:50:00.000000','王强','IN-20261024-001',500,'中心仓库'),(101,11,'小米 14 手机','2026-11-01 00:00:00.000000','王强','IN-20261101-011',30,'中心仓库'),(102,12,'华为 MatePad','2026-11-01 00:01:00.000000','赵敏','IN-20261101-012',20,'中心仓库'),(103,13,'Type-C 数据线','2026-11-01 00:02:00.000000','刘洋','IN-20261101-013',400,'中心仓库'),(104,14,'65W 氮化镓充电器','2026-11-01 00:03:00.000000','陈静','IN-20261101-014',200,'中心仓库'),(105,15,'蓝牙音箱','2026-11-01 00:04:00.000000','孙磊','IN-20261101-015',100,'二号仓'),(106,16,'智能手环','2026-11-01 00:05:00.000000','王强','IN-20261101-016',80,'二号仓'),(107,17,'4K 摄像头','2026-11-01 00:06:00.000000','赵敏','IN-20261101-017',50,'二号仓'),(108,18,'路由器 AX3000','2026-11-01 00:07:00.000000','刘洋','IN-20261101-018',60,'二号仓'),(109,19,'移动硬盘 1TB','2026-11-01 00:08:00.000000','陈静','IN-20261101-019',40,'中心仓库'),(110,20,'U 盘 128G','2026-11-01 00:09:00.000000','孙磊','IN-20261101-020',250,'中心仓库'),(111,21,'一次性雨衣','2026-11-01 00:10:00.000000','王强','IN-20261101-021',1200,'退货仓'),(112,22,'泡沫填充物','2026-11-01 00:11:00.000000','赵敏','IN-20261101-022',600,'退货仓'),(113,23,'缠绕膜','2026-11-01 00:12:00.000000','刘洋','IN-20261101-023',500,'退货仓'),(114,24,'冷链冰袋','2026-11-01 00:13:00.000000','陈静','IN-20261101-024',1000,'冷链仓'),(115,25,'保温泡沫箱','2026-11-01 00:14:00.000000','孙磊','IN-20261101-025',150,'冷链仓'),(116,26,'温度记录仪','2026-11-01 00:15:00.000000','王强','IN-20261101-026',40,'冷链仓'),(117,27,'电子秤','2026-11-01 00:16:00.000000','赵敏','IN-20261101-027',30,'二号仓'),(118,28,'封箱胶带','2026-11-01 00:17:00.000000','刘洋','IN-20261101-028',1500,'中心仓库'),(119,29,'快递面单纸','2026-11-01 00:18:00.000000','陈静','IN-20261101-029',800,'中心仓库'),(120,30,'手持终端 PDA','2026-11-01 00:19:00.000000','孙磊','IN-20261101-030',25,'二号仓'),(121,2,'机械键盘 K8','2026-11-01 00:39:06.792000','lina','IN-1793464746711',10,'中心仓库'),(122,2,'机械键盘 K8','2026-11-01 00:40:18.537000','lina','IN-1793464818456',10,'中心仓库');
/*!40000 ALTER TABLE `inbound_order` ENABLE KEYS */;

--
-- Table structure for table `inbound_record`
--

DROP TABLE IF EXISTS `inbound_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inbound_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `goods_id` bigint DEFAULT NULL,
  `in_time` datetime(6) DEFAULT NULL,
  `operator` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inbound_record`
--

/*!40000 ALTER TABLE `inbound_record` DISABLE KEYS */;
INSERT INTO `inbound_record` VALUES (1,1,'2026-10-03 09:12:00.000000','张伟',60,'中心仓库'),(2,2,'2026-10-03 09:30:00.000000','张伟',40,'中心仓库'),(3,3,'2026-10-05 10:05:00.000000','李娜',25,'中心仓库'),(4,4,'2026-10-07 14:20:00.000000','李娜',50,'二号仓'),(5,5,'2026-10-09 09:00:00.000000','张伟',100,'二号仓'),(6,6,'2026-10-12 11:15:00.000000','王强',60,'二号仓'),(7,7,'2026-10-15 08:40:00.000000','王强',12,'冷链仓'),(8,8,'2026-10-18 16:10:00.000000','李娜',30,'中心仓库'),(9,9,'2026-10-21 10:25:00.000000','张伟',10,'二号仓'),(10,10,'2026-10-24 13:50:00.000000','王强',500,'中心仓库'),(101,11,'2026-11-01 00:00:00.000000','王强',30,'中心仓库'),(102,12,'2026-11-01 00:01:00.000000','赵敏',20,'中心仓库'),(103,13,'2026-11-01 00:02:00.000000','刘洋',400,'中心仓库'),(104,14,'2026-11-01 00:03:00.000000','陈静',200,'中心仓库'),(105,15,'2026-11-01 00:04:00.000000','孙磊',100,'二号仓'),(106,16,'2026-11-01 00:05:00.000000','王强',80,'二号仓'),(107,17,'2026-11-01 00:06:00.000000','赵敏',50,'二号仓'),(108,18,'2026-11-01 00:07:00.000000','刘洋',60,'二号仓'),(109,19,'2026-11-01 00:08:00.000000','陈静',40,'中心仓库'),(110,20,'2026-11-01 00:09:00.000000','孙磊',250,'中心仓库'),(111,21,'2026-11-01 00:10:00.000000','王强',1200,'退货仓'),(112,22,'2026-11-01 00:11:00.000000','赵敏',600,'退货仓'),(113,23,'2026-11-01 00:12:00.000000','刘洋',500,'退货仓'),(114,24,'2026-11-01 00:13:00.000000','陈静',1000,'冷链仓'),(115,25,'2026-11-01 00:14:00.000000','孙磊',150,'冷链仓'),(116,26,'2026-11-01 00:15:00.000000','王强',40,'冷链仓'),(117,27,'2026-11-01 00:16:00.000000','赵敏',30,'二号仓'),(118,28,'2026-11-01 00:17:00.000000','刘洋',1500,'中心仓库'),(119,29,'2026-11-01 00:18:00.000000','陈静',800,'中心仓库'),(120,30,'2026-11-01 00:19:00.000000','孙磊',25,'二号仓'),(121,2,'2026-11-01 00:39:06.792000','lina',10,'中心仓库'),(122,2,'2026-11-01 00:40:18.537000','lina',10,'中心仓库');
/*!40000 ALTER TABLE `inbound_record` ENABLE KEYS */;

--
-- Table structure for table `monthly_stat`
--

DROP TABLE IF EXISTS `monthly_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `monthly_stat` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `inbound_total` int DEFAULT NULL,
  `outbound_total` int DEFAULT NULL,
  `stat_month` varchar(7) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monthly_stat`
--

/*!40000 ALTER TABLE `monthly_stat` DISABLE KEYS */;
INSERT INTO `monthly_stat` VALUES (1,887,134,'2026-10'),(2,7095,1840,'2026-11'),(3,520,420,'2026-06'),(4,640,700,'2026-07'),(5,710,600,'2026-08'),(6,820,970,'2026-09');
/*!40000 ALTER TABLE `monthly_stat` ENABLE KEYS */;

--
-- Table structure for table `operation_log`
--

DROP TABLE IF EXISTS `operation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `action` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime(6) DEFAULT NULL,
  `detail` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `target_id` bigint DEFAULT NULL,
  `target_type` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_log`
--

/*!40000 ALTER TABLE `operation_log` DISABLE KEYS */;
INSERT INTO `operation_log` VALUES (1,'登录','2026-11-01 02:02:20.275744','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(2,'保存商品','2026-11-01 02:02:20.571652','编码 LOG-DEMO / 日志演示商品，库存 0','127.0.0.1','ADMIN',32,'goods','admin',NULL),(3,'删除商品','2026-11-01 02:02:20.634855','删除商品 ID 32','127.0.0.1','ADMIN',32,'goods','admin',NULL),(4,'新增用户','2026-11-01 02:02:20.745021','用户名 logdemo，角色 WAREHOUSE，仓库 中心仓库','127.0.0.1','ADMIN',11,'user','admin',NULL),(5,'绑定仓库','2026-11-01 02:02:20.811600','用户 logdemo 绑定 二号仓','127.0.0.1','ADMIN',11,'user','admin',NULL),(6,'删除用户','2026-11-01 02:02:20.841111','用户名 logdemo','127.0.0.1','ADMIN',11,'user','admin',NULL),(7,'登录','2026-11-01 02:02:31.920514','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(8,'登录','2026-11-01 02:03:22.172699','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(9,'登录','2026-11-01 02:03:22.450447','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(10,'登录','2026-11-01 02:04:05.850081','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(11,'处理预警','2026-11-01 02:04:22.701237','处理预警记录 127','127.0.0.1','ADMIN',127,'warning','admin',NULL),(12,'检查预警','2026-11-01 02:04:23.703402','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(13,'检查预警','2026-11-01 02:04:24.403110','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(14,'处理预警','2026-11-01 02:04:25.250069','处理预警记录 133','127.0.0.1','ADMIN',133,'warning','admin',NULL),(15,'检查预警','2026-11-01 02:04:26.175205','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(16,'处理预警','2026-11-01 02:04:31.164784','处理预警记录 138','127.0.0.1','ADMIN',138,'warning','admin',NULL),(17,'检查预警','2026-11-01 02:04:31.857048','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(18,'处理预警','2026-11-01 02:04:36.054823','处理预警记录 143','127.0.0.1','ADMIN',143,'warning','admin',NULL),(19,'处理预警','2026-11-01 02:04:39.157934','处理预警记录 144','127.0.0.1','ADMIN',144,'warning','admin',NULL),(20,'处理预警','2026-11-01 02:04:39.582489','处理预警记录 145','127.0.0.1','ADMIN',145,'warning','admin',NULL),(21,'处理预警','2026-11-01 02:04:39.973564','处理预警记录 146','127.0.0.1','ADMIN',146,'warning','admin',NULL),(22,'处理预警','2026-11-01 02:04:40.344043','处理预警记录 147','127.0.0.1','ADMIN',147,'warning','admin',NULL),(23,'检查预警','2026-11-01 02:04:41.009469','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(24,'登录','2026-11-01 02:05:54.935114','登录成功','127.0.0.1','WAREHOUSE',6,'session','liuyang','退货仓'),(25,'登录','2026-11-01 02:08:44.564330','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(26,'登录','2026-11-01 02:08:52.418574','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(27,'登录','2026-11-01 02:09:53.910480','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(28,'登录','2026-11-01 02:10:01.913540','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(29,'登录','2026-11-01 02:10:56.229151','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(30,'登录','2026-11-01 02:12:15.388935','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(31,'登录','2026-11-01 02:15:24.682719','登录成功','127.0.0.1','WAREHOUSE',6,'session','liuyang','退货仓'),(32,'登录','2026-11-01 02:15:24.527543','登录成功','127.0.0.1','WAREHOUSE',6,'session','liuyang','退货仓'),(33,'登录','2026-11-01 02:15:24.425471','登录成功','127.0.0.1','WAREHOUSE',6,'session','liuyang','退货仓'),(34,'登录','2026-11-01 02:15:28.225260','登录成功','127.0.0.1','WAREHOUSE',6,'session','liuyang','退货仓'),(35,'退出','2026-11-01 02:15:52.924809','退出登录','127.0.0.1','WAREHOUSE',NULL,'session','liuyang','退货仓'),(36,'登录','2026-11-01 14:34:30.667067','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(37,'登录','2026-11-01 14:34:35.524444','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(38,'登录','2026-11-01 14:34:35.694931','登录成功','127.0.0.1','VIEWER',9,'session','guest',NULL),(39,'登录','2026-11-01 14:34:50.662070','登录成功','127.0.0.1','VIEWER',9,'session','guest',NULL),(40,'登录','2026-11-01 14:34:50.899234','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(41,'登录','2026-11-01 14:34:51.049325','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(42,'登录','2026-11-01 14:35:04.925040','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(43,'登录','2026-11-01 14:35:17.690428','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(44,'登录','2026-11-01 14:35:48.201856','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(45,'登录','2026-11-01 14:39:40.173054','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(46,'登录','2026-11-01 14:39:40.465834','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(47,'登录','2026-11-01 14:39:40.576860','登录成功','127.0.0.1','VIEWER',9,'session','guest',NULL),(48,'登录','2026-11-01 14:39:44.821665','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(49,'检查预警','2026-11-01 14:39:44.964841','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(50,'登录','2026-11-01 14:39:50.391995','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(51,'登录','2026-11-01 14:40:19.652533','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(52,'登录','2026-11-01 15:26:51.513506','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(53,'登录','2026-11-01 15:27:20.538543','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(54,'登录','2026-11-01 15:27:20.727124','用户 guest 登录成功','127.0.0.1','VIEWER',9,'auth','guest',NULL),(55,'登录','2026-11-01 15:28:18.117830','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(56,'登录','2026-11-01 15:34:16.616094','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(57,'登录','2026-11-01 15:34:33.558921','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(58,'登录','2026-11-01 15:56:21.603800','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(59,'退出','2026-11-01 15:56:28.501853','用户 liuyang 退出登录','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(60,'登录','2026-11-01 15:56:30.574903','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(61,'登录','2026-11-01 15:57:42.189044','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(62,'登录','2026-11-01 15:58:26.064706','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(63,'处理预警','2026-11-01 15:58:33.168833','处理预警记录 153','127.0.0.1','ADMIN',153,'warning','admin',NULL),(64,'检查预警','2026-11-01 15:58:34.050147','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(65,'登录','2026-11-01 16:53:25.269420','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(66,'登录','2026-11-01 16:57:00.707723','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(67,'登录','2026-11-01 16:57:17.947135','登录成功','127.0.0.1','WAREHOUSE',3,'session','lina','中心仓库'),(68,'登录','2026-11-01 16:57:22.409336','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(69,'登录','2026-11-01 16:58:19.798269','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(70,'登录','2026-11-01 16:58:24.355614','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(71,'登录','2026-11-01 16:59:42.940052','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(72,'登录','2026-11-01 17:01:33.427931','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(73,'登录','2026-11-01 17:02:24.987592','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(74,'处理预警','2026-11-01 17:02:28.917807','处理预警记录 158','127.0.0.1','ADMIN',158,'warning','admin',NULL),(75,'检查预警','2026-11-01 17:02:30.461040','手动重算预警','127.0.0.1','ADMIN',NULL,'warning','admin',NULL),(76,'登录','2026-11-01 17:03:20.731026','登录成功','127.0.0.1','ADMIN',1,'session','admin',NULL),(77,'登录','2026-11-05 14:15:46.808577','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(78,'登录','2026-11-05 14:15:59.721230','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(79,'登录','2026-11-05 14:17:47.986825','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(80,'登录','2026-11-05 14:17:48.108569','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(81,'登录','2026-11-05 14:19:33.362225','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(82,'重算预警','2026-11-05 14:19:38.017122','手动检查库存预警','127.0.0.1','WAREHOUSE',NULL,'warning','liuyang',NULL),(83,'退出','2026-11-05 14:19:53.528211','用户 liuyang 退出登录','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(84,'登录','2026-11-05 14:19:56.553580','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(85,'退出','2026-11-05 14:20:09.642220','用户 admin 退出登录','127.0.0.1','ADMIN',1,'auth','admin',NULL),(86,'登录','2026-11-05 14:41:30.324070','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(87,'登录','2026-11-05 14:41:46.836847','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(88,'退出','2026-11-05 14:41:57.746168','用户 liuyang 退出登录','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(89,'登录','2026-11-05 14:42:02.356016','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(90,'退出','2026-11-05 14:42:12.049866','用户 admin 退出登录','127.0.0.1','ADMIN',1,'auth','admin',NULL),(91,'登录','2026-11-05 14:52:15.903935','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(92,'登录','2026-11-05 14:52:17.483200','用户 zhangwei 登录成功','127.0.0.1','WAREHOUSE',2,'auth','zhangwei','中心仓库'),(93,'切换账号','2026-11-05 14:52:17.995599','zhangwei → admin','127.0.0.1','ADMIN',1,'auth','admin',NULL),(94,'登录','2026-11-05 14:52:41.503358','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(95,'登录','2026-11-05 14:52:54.367438','用户 zhangwei 登录成功','127.0.0.1','WAREHOUSE',2,'auth','zhangwei','中心仓库'),(96,'切换账号','2026-11-05 14:53:08.101415','zhangwei → admin','127.0.0.1','ADMIN',1,'auth','admin',NULL),(97,'切换账号','2026-11-05 14:53:38.166196','admin → zhangwei','127.0.0.1','WAREHOUSE',2,'auth','zhangwei','中心仓库'),(98,'切换账号','2026-11-05 14:53:43.631212','zhangwei → admin','127.0.0.1','ADMIN',1,'auth','admin',NULL),(99,'登录','2026-11-05 14:54:26.284848','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(100,'登录','2026-11-05 14:54:30.180283','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(101,'登录','2026-11-05 15:21:13.852400','用户 zhangwei 登录成功','127.0.0.1','WAREHOUSE',2,'auth','zhangwei','中心仓库'),(102,'登录','2026-11-05 15:58:36.834643','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(103,'登录','2026-11-05 15:58:39.141860','用户 admin 登录成功','127.0.0.1','ADMIN',1,'auth','admin',NULL),(104,'退出','2026-11-05 15:58:52.252774','用户 admin 退出登录','127.0.0.1','ADMIN',1,'auth','admin',NULL),(105,'登录','2026-11-05 15:58:54.840268','用户 liuyang 登录成功','127.0.0.1','WAREHOUSE',6,'auth','liuyang','退货仓'),(106,'登录','2026-11-05 16:00:47.982364','用户 zhangwei 登录成功','127.0.0.1','WAREHOUSE',2,'auth','zhangwei','中心仓库');
/*!40000 ALTER TABLE `operation_log` ENABLE KEYS */;

--
-- Table structure for table `outbound_order`
--

DROP TABLE IF EXISTS `outbound_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `outbound_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `goods_id` bigint DEFAULT NULL,
  `goods_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `operator` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `order_no` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `outbound_time` datetime(6) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outbound_order`
--

/*!40000 ALTER TABLE `outbound_order` DISABLE KEYS */;
INSERT INTO `outbound_order` VALUES (1,1,'罗技 M330 无线鼠标','张伟','OUT-20261008-001','2026-10-08 15:30:00.000000',15,'中心仓库'),(2,2,'机械键盘 K8','李娜','OUT-20261010-001','2026-10-10 09:45:00.000000',32,'中心仓库'),(3,3,'27 英寸显示器','王强','OUT-20261012-002','2026-10-12 16:00:00.000000',3,'中心仓库'),(4,4,'USB-C 扩展坞','张伟','OUT-20261014-001','2026-10-14 10:10:00.000000',45,'二号仓'),(5,5,'蓝牙降噪耳机','李娜','OUT-20261016-001','2026-10-16 11:40:00.000000',10,'二号仓'),(6,6,'20000mAh 移动电源','王强','OUT-20261019-001','2026-10-19 14:05:00.000000',5,'二号仓'),(7,8,'无线扫码枪','张伟','OUT-20261022-001','2026-10-22 09:20:00.000000',22,'中心仓库'),(8,9,'标签打印机','李娜','OUT-20261025-001','2026-10-25 15:55:00.000000',2,'二号仓'),(101,11,'小米 14 手机','刘洋','OUT-20261101-011','2026-11-01 00:20:00.000000',22,'中心仓库'),(102,12,'华为 MatePad','陈静','OUT-20261101-012','2026-11-01 00:21:00.000000',15,'中心仓库'),(103,13,'Type-C 数据线','孙磊','OUT-20261101-013','2026-11-01 00:22:00.000000',180,'中心仓库'),(104,14,'65W 氮化镓充电器','王强','OUT-20261101-014','2026-11-01 00:23:00.000000',90,'中心仓库'),(105,15,'蓝牙音箱','赵敏','OUT-20261101-015','2026-11-01 00:24:00.000000',35,'二号仓'),(106,16,'智能手环','刘洋','OUT-20261101-016','2026-11-01 00:25:00.000000',18,'二号仓'),(107,17,'4K 摄像头','陈静','OUT-20261101-017','2026-11-01 00:26:00.000000',12,'二号仓'),(108,18,'路由器 AX3000','孙磊','OUT-20261101-018','2026-11-01 00:27:00.000000',25,'二号仓'),(109,19,'移动硬盘 1TB','王强','OUT-20261101-019','2026-11-01 00:28:00.000000',8,'中心仓库'),(110,20,'U 盘 128G','赵敏','OUT-20261101-020','2026-11-01 00:29:00.000000',70,'中心仓库'),(111,21,'一次性雨衣','刘洋','OUT-20261101-021','2026-11-01 00:30:00.000000',300,'退货仓'),(112,22,'泡沫填充物','陈静','OUT-20261101-022','2026-11-01 00:31:00.000000',120,'退货仓'),(113,23,'缠绕膜','孙磊','OUT-20261101-023','2026-11-01 00:32:00.000000',80,'退货仓'),(114,24,'冷链冰袋','王强','OUT-20261101-024','2026-11-01 00:33:00.000000',260,'冷链仓'),(115,25,'保温泡沫箱','赵敏','OUT-20261101-025','2026-11-01 00:34:00.000000',40,'冷链仓'),(116,26,'温度记录仪','刘洋','OUT-20261101-026','2026-11-01 00:35:00.000000',5,'冷链仓'),(117,27,'电子秤','陈静','OUT-20261101-027','2026-11-01 00:36:00.000000',6,'二号仓'),(118,28,'封箱胶带','孙磊','OUT-20261101-028','2026-11-01 00:37:00.000000',400,'中心仓库'),(119,29,'快递面单纸','王强','OUT-20261101-029','2026-11-01 00:38:00.000000',150,'中心仓库'),(120,30,'手持终端 PDA','赵敏','OUT-20261101-030','2026-11-01 00:39:00.000000',4,'二号仓');
/*!40000 ALTER TABLE `outbound_order` ENABLE KEYS */;

--
-- Table structure for table `outbound_record`
--

DROP TABLE IF EXISTS `outbound_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `outbound_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `goods_id` bigint DEFAULT NULL,
  `operator` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `out_time` datetime(6) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outbound_record`
--

/*!40000 ALTER TABLE `outbound_record` DISABLE KEYS */;
INSERT INTO `outbound_record` VALUES (1,1,'张伟','2026-10-08 15:30:00.000000',15,'中心仓库'),(2,2,'李娜','2026-10-10 09:45:00.000000',32,'中心仓库'),(3,3,'王强','2026-10-12 16:00:00.000000',3,'中心仓库'),(4,4,'张伟','2026-10-14 10:10:00.000000',45,'二号仓'),(5,5,'李娜','2026-10-16 11:40:00.000000',10,'二号仓'),(6,6,'王强','2026-10-19 14:05:00.000000',5,'二号仓'),(7,8,'张伟','2026-10-22 09:20:00.000000',22,'中心仓库'),(8,9,'李娜','2026-10-25 15:55:00.000000',2,'二号仓'),(101,11,'刘洋','2026-11-01 00:20:00.000000',22,'中心仓库'),(102,12,'陈静','2026-11-01 00:21:00.000000',15,'中心仓库'),(103,13,'孙磊','2026-11-01 00:22:00.000000',180,'中心仓库'),(104,14,'王强','2026-11-01 00:23:00.000000',90,'中心仓库'),(105,15,'赵敏','2026-11-01 00:24:00.000000',35,'二号仓'),(106,16,'刘洋','2026-11-01 00:25:00.000000',18,'二号仓'),(107,17,'陈静','2026-11-01 00:26:00.000000',12,'二号仓'),(108,18,'孙磊','2026-11-01 00:27:00.000000',25,'二号仓'),(109,19,'王强','2026-11-01 00:28:00.000000',8,'中心仓库'),(110,20,'赵敏','2026-11-01 00:29:00.000000',70,'中心仓库'),(111,21,'刘洋','2026-11-01 00:30:00.000000',300,'退货仓'),(112,22,'陈静','2026-11-01 00:31:00.000000',120,'退货仓'),(113,23,'孙磊','2026-11-01 00:32:00.000000',80,'退货仓'),(114,24,'王强','2026-11-01 00:33:00.000000',260,'冷链仓'),(115,25,'赵敏','2026-11-01 00:34:00.000000',40,'冷链仓'),(116,26,'刘洋','2026-11-01 00:35:00.000000',5,'冷链仓'),(117,27,'陈静','2026-11-01 00:36:00.000000',6,'二号仓'),(118,28,'孙磊','2026-11-01 00:37:00.000000',400,'中心仓库'),(119,29,'王强','2026-11-01 00:38:00.000000',150,'中心仓库'),(120,30,'赵敏','2026-11-01 00:39:00.000000',4,'二号仓');
/*!40000 ALTER TABLE `outbound_record` ENABLE KEYS */;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'2026-09-01 09:00:00.000000','$2a$10$crl/G7TMOE84m9dpj6m/leZRE5JlaaVAcaQOesYx9448FxGS5tNuu','ADMIN','admin',NULL),(2,'2026-09-05 10:00:00.000000','$2a$10$f59hnZGiNxFmP0TcIeZH0.9xuhLthVomjml2Rl/AbI1rEmhIZUsmW','WAREHOUSE','zhangwei','中心仓库'),(3,'2026-09-05 10:05:00.000000','$2a$10$yDfBu.mgCNisFLeKCrQSx.YoIn7phpJSA6zEdbnIBVN33R5cdvV3m','WAREHOUSE','lina','中心仓库'),(4,'2026-10-30 09:00:00.000000','123456','WAREHOUSE','wangqiang','中心仓库'),(5,'2026-10-30 09:00:00.000000','$2a$10$8FuN53Ge/LoWGO8Ykpg9hedSx7Q6hVk5nAQ3wu48CM0K4EPHAO9je','WAREHOUSE','zhaomin','冷链仓'),(6,'2026-10-30 09:00:00.000000','$2a$10$HGE0CFBjm7UY7eW/ygQ7aO1/9KavAEUCleJUDQcsX3IfH.8EbwmiS','WAREHOUSE','liuyang','退货仓'),(7,'2026-10-30 09:00:00.000000','123456','ADMIN','chenjing',NULL),(8,'2026-10-30 09:00:00.000000','$2a$10$/fEO5fEMSoKjShh9I86kh.oz4a5vYCbmaY2NVfnKn7jeTldGtbjHG','WAREHOUSE','sunlei','二号仓'),(9,'2026-11-01 09:00:00.000000','$2a$10$/6n3.OUysn02qR7nfRbAcOQQYVKYKOG9QAZAALjr.pcfZJELWK2AC','VIEWER','guest',NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;

--
-- Table structure for table `warning_record`
--

DROP TABLE IF EXISTS `warning_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warning_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_time` datetime(6) DEFAULT NULL,
  `current_stock` int DEFAULT NULL,
  `goods_code` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `goods_id` bigint DEFAULT NULL,
  `goods_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `max_stock` int DEFAULT NULL,
  `min_stock` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `warehouse` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `warning_type` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=168 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warning_record`
--

/*!40000 ALTER TABLE `warning_record` DISABLE KEYS */;
INSERT INTO `warning_record` VALUES (163,'2026-11-01 17:02:30.408111',5,'G004',4,'USB-C 扩展坞',60,15,'未处理','二号仓','低库存预警'),(164,'2026-11-01 17:02:30.408111',55,'G006',6,'20000mAh 移动电源',50,10,'未处理','二号仓','高库存预警'),(165,'2026-11-01 17:02:30.408111',5,'G012',12,'华为 MatePad',30,8,'未处理','中心仓库','低库存预警'),(166,'2026-11-01 17:02:30.408111',38,'G017',17,'4K 摄像头',30,10,'未处理','二号仓','高库存预警'),(167,'2026-11-01 17:02:30.408111',35,'G026',26,'温度记录仪',60,40,'未处理','冷链仓','低库存预警');
/*!40000 ALTER TABLE `warning_record` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-07 20:49:32
