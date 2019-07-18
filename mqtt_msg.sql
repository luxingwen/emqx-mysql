/*
Navicat MySQL Data Transfer

Source Server         : 112.74.44.130 _3306
Source Server Version : 50724
Source Host           : 112.74.44.130:3306
Source Database       : easylinker_v3

Target Server Type    : MYSQL
Target Server Version : 50724
File Encoding         : 65001

Date: 2019-07-18 11:37:29
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for mqtt_msg
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_msg`;
CREATE TABLE `mqtt_msg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mid` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `payload` text,
  `time` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2330 DEFAULT CHARSET=utf8mb4;
