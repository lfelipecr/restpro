-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         10.4.27-MariaDB - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Volcando estructura para tabla factuyorest.comunicacion_baja
CREATE TABLE IF NOT EXISTS `comunicacion_baja` (
  `id_comunicacion` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_registro` datetime DEFAULT NULL,
  `fecha_baja` date DEFAULT NULL,
  `fecha_referencia` date DEFAULT NULL,
  `tipo_doc` char(2) DEFAULT NULL,
  `serie_doc` char(4) DEFAULT NULL,
  `num_doc` varchar(8) DEFAULT NULL,
  `nombre_baja` varchar(200) DEFAULT NULL,
  `correlativo` varchar(5) DEFAULT NULL,
  `enviado_sunat` char(1) DEFAULT NULL,
  `hash_cpe` varchar(100) DEFAULT NULL,
  `hash_cdr` varchar(100) DEFAULT NULL,
  `code_respuesta_sunat` varchar(5) DEFAULT NULL,
  `descripcion_sunat_cdr` varchar(300) DEFAULT NULL,
  `name_file_sunat` varchar(80) DEFAULT NULL,
  `estado` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`id_comunicacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Volcando datos para la tabla factuyorest.comunicacion_baja: ~0 rows (aproximadamente)
DELETE FROM `comunicacion_baja`;

-- Volcando estructura para tabla factuyorest.resumen_diario
CREATE TABLE IF NOT EXISTS `resumen_diario` (
  `id_resumen` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_registro` datetime DEFAULT NULL,
  `fecha_resumen` date DEFAULT NULL,
  `fecha_referencia` date DEFAULT NULL,
  `correlativo` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `enviado_sunat` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `hash_cpe` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `hash_cdr` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `code_respuesta_sunat` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `descripcion_sunat_cdr` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `name_file_sunat` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `estado` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_resumen`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.resumen_diario: ~0 rows (aproximadamente)
DELETE FROM `resumen_diario`;

-- Volcando estructura para tabla factuyorest.resumen_diario_detalle
CREATE TABLE IF NOT EXISTS `resumen_diario_detalle` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `id_resumen` int(11) DEFAULT NULL,
  `id_venta` int(11) DEFAULT NULL,
  `status_code` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `FK_RDD_RES` (`id_resumen`),
  KEY `FK_RDD_VEN` (`id_venta`),
  CONSTRAINT `FK_RDD_RES` FOREIGN KEY (`id_resumen`) REFERENCES `resumen_diario` (`id_resumen`),
  CONSTRAINT `FK_RDD_VEN` FOREIGN KEY (`id_venta`) REFERENCES `tm_venta` (`id_venta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.resumen_diario_detalle: ~0 rows (aproximadamente)
DELETE FROM `resumen_diario_detalle`;

-- Volcando estructura para procedimiento factuyorest.sp_actualizar_cdr_baja
DELIMITER //
CREATE PROCEDURE `sp_actualizar_cdr_baja`(`p_id_comunicacion` INT, `p_hash_cpe` VARCHAR(100), `p_hash_cdr` VARCHAR(100), `p_code_respuesta_sunat` VARCHAR(5), `p_descripcion_sunat_cdr` VARCHAR(300), `p_name_file_sunat` VARCHAR(80), OUT `mensaje` VARCHAR(100))
BEGIN
	IF(NOT EXISTS(SELECT * FROM comunicacion_baja WHERE id_comunicacion=p_id_comunicacion))THEN
		SET mensaje='No existe la comunicación de baja';
	ELSE
		UPDATE comunicacion_baja SET enviado_sunat=1,hash_cpe=p_hash_cpe,hash_cdr=p_hash_cdr,code_respuesta_sunat=p_code_respuesta_sunat,descripcion_sunat_cdr=p_descripcion_sunat_cdr,name_file_sunat=p_name_file_sunat WHERE id_comunicacion=p_id_comunicacion;
		SET mensaje='Actualizado correctamente';
	END IF;
END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_actualizar_cdr_resumen
DELIMITER //
CREATE PROCEDURE `sp_actualizar_cdr_resumen`(`p_id_resumen` INT, `p_hash_cpe` VARCHAR(100), `p_hash_cdr` VARCHAR(100), `p_code_respuesta_sunat` VARCHAR(5), `p_descripcion_sunat_cdr` VARCHAR(300), `p_name_file_sunat` VARCHAR(80), OUT `mensaje` VARCHAR(100))
BEGIN
	IF(NOT EXISTS(SELECT * FROM resumen_diario WHERE id_resumen=p_id_resumen))THEN
		SET mensaje='No existe el resumen diario';
	ELSE
		UPDATE resumen_diario SET enviado_sunat=1,hash_cpe=p_hash_cpe,hash_cdr=p_hash_cdr,code_respuesta_sunat=p_code_respuesta_sunat,descripcion_sunat_cdr=p_descripcion_sunat_cdr,name_file_sunat=p_name_file_sunat WHERE id_resumen=p_id_resumen;
		SET mensaje='Actualizado correctamente';
		
		block:BEGIN
		DECLARE done INT DEFAULT FALSE;
		DECLARE idven BIGINT;
		DECLARE venta CURSOR FOR SELECT dr.id_venta FROM resumen_diario AS rd INNER JOIN resumen_diario_detalle AS dr ON rd.id_resumen = dr.id_resumen WHERE dr.id_resumen = p_id_resumen;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;
		OPEN venta;
		
			read_loop: LOOP
			FETCH venta INTO idven;
				IF done THEN
					LEAVE read_loop;
				END IF;
				UPDATE tm_venta SET code_respuesta_sunat=p_code_respuesta_sunat,descripcion_sunat_cdr=p_descripcion_sunat_cdr,name_file_sunat=p_name_file_sunat,hash_cpe=p_hash_cpe,hash_cdr=p_hash_cdr WHERE id_venta = idven;
			END LOOP;
			
		CLOSE venta;
		END block;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_consultar_boletas_resumen
DELIMITER //
CREATE PROCEDURE `sp_consultar_boletas_resumen`(IN `p_fecha_resumen` DATE)
BEGIN
    SELECT
        '03' AS 'tipo_comprobante',DATE_FORMAT(v.fecha_venta,'%Y-%m-%d') AS 'fecha_resumen',IF(c.dni="" OR c.dni="-",0,1) AS 'tipo_documento',
        IF(c.dni="" OR c.dni="-","00000000",c.dni) AS "dni",c.nombres AS 'cliente',v.serie_doc AS 'serie_doc',
        v.nro_doc AS 'nro_doc',"PEN" AS 'tipo_moneda',ROUND((v.total/(1 + v.igv)) *(v.igv),2) AS 'total_igv',
        ROUND((v.total/(1 + v.igv)),2) AS 'total_gravadas',ROUND(v.total,2) AS 'total_facturado',IF(v.estado="a",1,3) AS 'status_code',v.id_venta
    FROM tm_venta v 
    INNER JOIN tm_cliente c ON c.id_cliente=v.id_cliente
    WHERE v.id_tipo_doc=1 AND v.enviado_sunat!="1" AND DATE_FORMAT(v.fecha_venta,"%Y-%m-%d") = p_fecha_resumen
    ORDER BY v.fecha_venta ASC;
END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_consultar_documento
DELIMITER //
CREATE PROCEDURE `sp_consultar_documento`(`p_id_venta` INT)
BEGIN
	SELECT
		IF(id_tipo_doc='1','03','01') AS tipo_comprobante, IF(c.dni="" OR c.dni="-",0,1) AS 'tipo_documento',
		IF(c.dni="" OR c.dni="-","00000000",c.dni) AS "dni",v.serie_doc AS 'serie_doc', v.nro_doc AS 'nro_doc',"PEN" AS 'tipo_moneda',ROUND((v.total/(1 + v.igv)) *(v.igv),2) AS 'total_igv',
		ROUND((v.total/(1 + v.igv)),2) AS 'total_gravadas',ROUND(v.total,2) AS 'total_facturado',v.id_venta, v.estado
	FROM tm_venta v INNER JOIN tm_cliente c ON c.id_cliente=v.id_cliente
	WHERE v.id_venta = p_id_venta;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_estadistica_g01
DELIMITER //
CREATE PROCEDURE `sp_estadistica_g01`(`mes_` CHAR(2), `anio_` CHAR(4))
BEGIN 
	SELECT
	v_estadistica.id_usu,
	v_estadistica.nombres,
	COUNT(v_estadistica.id_venta) AS numero_ventas,
	SUM(v_estadistica.total) AS total_ventas
	FROM
		v_estadistica
	WHERE
		MONTH(fecha_venta) = mes_ AND 
		YEAR(fecha_venta) = anio_ AND
		id_tipo_pedido = 1
	GROUP BY
		id_usu
	ORDER BY
		numero_ventas ASC,
		total_ventas ASC;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_estadistica_g02_compras
DELIMITER //
CREATE PROCEDURE `sp_estadistica_g02_compras`(`m1_` CHAR(2), `a1_` CHAR(4), `m2_` CHAR(2), `a2_` CHAR(4), `m3_` CHAR(2), `a3_` CHAR(4), `m4_` CHAR(2), `a4_` CHAR(4))
BEGIN
		SELECT
			SUM(IF(MONTH(fecha_c) = m1_ AND YEAR(fecha_c) = a1_,  total, 0)) AS compra_1,
			SUM(IF(MONTH(fecha_c) = m2_ AND YEAR(fecha_c) = a2_,  total, 0)) AS compra_2,
			SUM(IF(MONTH(fecha_c) = m3_ AND YEAR(fecha_c) = a3_,  total, 0)) AS compra_3,
			SUM(IF(MONTH(fecha_c) = m4_ AND YEAR(fecha_c) = a4_,  total, 0)) AS compra_4
		FROM tm_compra
		ORDER BY fecha_c ASC;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_estadistica_g02_ventas
DELIMITER //
CREATE PROCEDURE `sp_estadistica_g02_ventas`(`m1_` CHAR(2), `a1_` CHAR(4), `m2_` CHAR(2), `a2_` CHAR(4), `m3_` CHAR(2), `a3_` CHAR(4), `m4_` CHAR(2), `a4_` CHAR(4))
BEGIN
		SELECT
			SUM(IF(MONTH(fecha_venta) = m1_ AND YEAR(fecha_venta) = a1_,  total, 0)) AS venta_1,
			SUM(IF(MONTH(fecha_venta) = m2_ AND YEAR(fecha_venta) = a2_,  total, 0)) AS venta_2,
			SUM(IF(MONTH(fecha_venta) = m3_ AND YEAR(fecha_venta) = a3_,  total, 0)) AS venta_3,
			SUM(IF(MONTH(fecha_venta) = m4_ AND YEAR(fecha_venta) = a4_,  total, 0)) AS venta_4
		FROM v_estadistica
		ORDER BY fecha_venta ASC;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_estadistica_g03
DELIMITER //
CREATE PROCEDURE `sp_estadistica_g03`(`d1_` DATE, `d2_` DATE, `d3_` DATE, `d4_` DATE, `d5_` DATE, `d6_` DATE, `d7_` DATE)
BEGIN
		SELECT
			SUM( IF( fecha_venta BETWEEN CONCAT(d1_,' 00:00:00') AND CONCAT(d1_,' 23:59:59'),  total, 0 ) ) AS dia1,
			SUM( IF( fecha_venta BETWEEN CONCAT(d2_,' 00:00:00') AND CONCAT(d2_,' 23:59:59'),  total, 0 ) ) AS dia2,
			SUM( IF( fecha_venta BETWEEN CONCAT(d3_,' 00:00:00') AND CONCAT(d3_,' 23:59:59'),  total, 0 ) ) AS dia3,
			SUM( IF( fecha_venta BETWEEN CONCAT(d4_,' 00:00:00') AND CONCAT(d4_,' 23:59:59'),  total, 0 ) ) AS dia4,
			SUM( IF( fecha_venta BETWEEN CONCAT(d5_,' 00:00:00') AND CONCAT(d5_,' 23:59:59'),  total, 0 ) ) AS dia5,
			SUM( IF( fecha_venta BETWEEN CONCAT(d6_,' 00:00:00') AND CONCAT(d6_,' 23:59:59'),  total, 0 ) ) AS dia6,
			SUM( IF( fecha_venta BETWEEN CONCAT(d7_,' 00:00:00') AND CONCAT(d7_,' 23:59:59'),  total, 0 ) ) AS dia7
		FROM v_estadistica
		ORDER BY fecha_venta ASC;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_estadistica_g04
DELIMITER //
CREATE PROCEDURE `sp_estadistica_g04`(`m1_` CHAR(2), `a1_` CHAR(4), `m2_` CHAR(2), `a2_` CHAR(4), `m3_` CHAR(2), `a3_` CHAR(4), `m4_` CHAR(2), `a4_` CHAR(4), `m5_` CHAR(2), `a5_` CHAR(4), `m6_` CHAR(2), `a6_` CHAR(4), `m7_` CHAR(2), `a7_` CHAR(4), `m8_` CHAR(2), `a8_` CHAR(4), `m9_` CHAR(2), `a9_` CHAR(4), `m10_` CHAR(2), `a10_` CHAR(4), `m11_` CHAR(2), `a11_` CHAR(4), `m12_` CHAR(2), `a12_` CHAR(4))
BEGIN
		SELECT
			SUM(IF(MONTH(fecha_venta) = m1_ AND YEAR(fecha_venta) = a1_,  total, 0)) AS venta_1,
			SUM(IF(MONTH(fecha_venta) = m2_ AND YEAR(fecha_venta) = a2_,  total, 0)) AS venta_2,
			SUM(IF(MONTH(fecha_venta) = m3_ AND YEAR(fecha_venta) = a3_,  total, 0)) AS venta_3,
			SUM(IF(MONTH(fecha_venta) = m4_ AND YEAR(fecha_venta) = a4_,  total, 0)) AS venta_4,
			SUM(IF(MONTH(fecha_venta) = m5_ AND YEAR(fecha_venta) = a5_,  total, 0)) AS venta_5,
			SUM(IF(MONTH(fecha_venta) = m6_ AND YEAR(fecha_venta) = a6_,  total, 0)) AS venta_6,
			SUM(IF(MONTH(fecha_venta) = m7_ AND YEAR(fecha_venta) = a7_,  total, 0)) AS venta_7,
			SUM(IF(MONTH(fecha_venta) = m8_ AND YEAR(fecha_venta) = a8_,  total, 0)) AS venta_8,
			SUM(IF(MONTH(fecha_venta) = m9_ AND YEAR(fecha_venta) = a9_,  total, 0)) AS venta_9,
			SUM(IF(MONTH(fecha_venta) = m10_ AND YEAR(fecha_venta) = a10_,  total, 0)) AS venta_10,
			SUM(IF(MONTH(fecha_venta) = m11_ AND YEAR(fecha_venta) = a11_,  total, 0)) AS venta_11,
			SUM(IF(MONTH(fecha_venta) = m12_ AND YEAR(fecha_venta) = a12_,  total, 0)) AS venta_12
		FROM v_estadistica
		ORDER BY fecha_venta ASC;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_estadistica_g05
DELIMITER //
CREATE PROCEDURE `sp_estadistica_g05`(`mes_` CHAR(2), `anio_` CHAR(4))
BEGIN
		SELECT
			SUM(IF(id_tipo_pedido = 1,  total, 0)) AS mesa,
			SUM(IF(id_tipo_pedido = 2,  total, 0)) AS llevar,
			SUM(IF(id_tipo_pedido = 3,  total, 0)) AS delivery
		FROM v_estadistica
		WHERE MONTH(fecha_venta) = mes_ AND YEAR(fecha_venta) = anio_
		ORDER BY fecha_venta ASC;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_generar_numerobaja
DELIMITER //
CREATE PROCEDURE `sp_generar_numerobaja`(`p_tipo_doc` CHAR(3), OUT `numerobaja` CHAR(5))
BEGIN
	DECLARE contador INT;
	IF(NOT EXISTS(SELECT * FROM comunicacion_baja WHERE tipo_doc = p_tipo_doc))THEN
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM comunicacion_baja WHERE tipo_doc = p_tipo_doc);
		SET numerobaja:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	ELSE		
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM comunicacion_baja WHERE tipo_doc = p_tipo_doc);
		SET numerobaja:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	END IF;
END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.sp_generar_numeroresumen
DELIMITER //
CREATE PROCEDURE `sp_generar_numeroresumen`(OUT `numeroresumen` CHAR(5))
BEGIN
	DECLARE contador INT;
	IF(NOT EXISTS(SELECT * FROM resumen_diario))THEN
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM resumen_diario);
		SET numeroresumen:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	ELSE		
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM resumen_diario);
		SET numeroresumen:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para tabla factuyorest.tm_accesos_rapidos
CREATE TABLE IF NOT EXISTS `tm_accesos_rapidos` (
  `id_acceso` int(45) NOT NULL AUTO_INCREMENT,
  `icono` varchar(255) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `color` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id_acceso`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla factuyorest.tm_accesos_rapidos: ~4 rows (aproximadamente)
DELETE FROM `tm_accesos_rapidos`;
INSERT INTO `tm_accesos_rapidos` (`id_acceso`, `icono`, `titulo`, `color`, `url`) VALUES
	(1, 'ti-money', 'Punto de venta', '#ffb22b', 'http://192.168.222.222/factuyorest/facturacion/venta'),
	(2, 'ti-desktop', 'Monitor de venta', '#ffffff', 'http://192.168.222.222/factuyorest/facturacion/caja/monitor'),
	(3, 'ti-server', 'Abrir/Cerrar Caja', '#10A724', 'http://192.168.222.222/factuyorest/facturacion/caja/apercie'),
	(4, 'ti-settings', 'Arqueo de Caja', '#ffffff', 'http://192.168.222.222/factuyorest/facturacion/informe/finanza_arq');

-- Volcando estructura para tabla factuyorest.tm_almacen
CREATE TABLE IF NOT EXISTS `tm_almacen` (
  `id_alm` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `estado` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'a',
  PRIMARY KEY (`id_alm`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_almacen: ~2 rows (aproximadamente)
DELETE FROM `tm_almacen`;
INSERT INTO `tm_almacen` (`id_alm`, `nombre`, `estado`) VALUES
	(1, 'ABARROTES E INSUMOS', 'a'),
	(2, 'BEBIDAS, GASEOSAS Y CERVEZAS', 'a');

-- Volcando estructura para tabla factuyorest.tm_aper_cierre
CREATE TABLE IF NOT EXISTS `tm_aper_cierre` (
  `id_apc` int(11) NOT NULL AUTO_INCREMENT,
  `id_usu` int(11) NOT NULL,
  `id_caja` int(11) NOT NULL,
  `id_turno` int(11) NOT NULL,
  `fecha_aper` datetime DEFAULT NULL,
  `monto_aper` decimal(10,2) DEFAULT 0.00,
  `fecha_cierre` datetime DEFAULT NULL,
  `monto_cierre` decimal(10,2) DEFAULT 0.00,
  `monto_sistema` decimal(10,2) DEFAULT 0.00,
  `stock_pollo` varchar(11) NOT NULL DEFAULT '0',
  `estado` varchar(5) DEFAULT 'a',
  PRIMARY KEY (`id_apc`),
  KEY `FK_ac_caja` (`id_caja`),
  KEY `FK_ac_turno` (`id_turno`),
  KEY `FK_ac_usu` (`id_usu`),
  CONSTRAINT `FK_ac_caja` FOREIGN KEY (`id_caja`) REFERENCES `tm_caja` (`id_caja`),
  CONSTRAINT `FK_ac_turno` FOREIGN KEY (`id_turno`) REFERENCES `tm_turno` (`id_turno`),
  CONSTRAINT `FK_ac_usu` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_aper_cierre: ~2 rows (aproximadamente)
DELETE FROM `tm_aper_cierre`;
INSERT INTO `tm_aper_cierre` (`id_apc`, `id_usu`, `id_caja`, `id_turno`, `fecha_aper`, `monto_aper`, `fecha_cierre`, `monto_cierre`, `monto_sistema`, `stock_pollo`, `estado`) VALUES
	(1, 1, 1, 1, '2024-03-31 21:09:15', 50.00, '2024-04-01 01:08:52', 217.00, 237.00, '', 'c'),
	(2, 1, 1, 1, '2024-04-01 01:25:25', 100.00, NULL, 0.00, 0.00, '0', 'a');

-- Volcando estructura para tabla factuyorest.tm_area_prod
CREATE TABLE IF NOT EXISTS `tm_area_prod` (
  `id_areap` int(11) NOT NULL AUTO_INCREMENT,
  `id_imp` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_areap`),
  KEY `FK_ap_alm` (`id_imp`),
  CONSTRAINT `FK_AP_IMP` FOREIGN KEY (`id_imp`) REFERENCES `tm_impresora` (`id_imp`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_area_prod: ~4 rows (aproximadamente)
DELETE FROM `tm_area_prod`;
INSERT INTO `tm_area_prod` (`id_areap`, `id_imp`, `nombre`, `estado`) VALUES
	(1, 3, 'COCINA', 'a'),
	(2, 3, 'BAR', 'a'),
	(5, 3, 'PARRILLAS', 'a'),
	(6, 2, '234234', 'i');

-- Volcando estructura para tabla factuyorest.tm_caja
CREATE TABLE IF NOT EXISTS `tm_caja` (
  `id_caja` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  `estado` varchar(5) DEFAULT 'a',
  PRIMARY KEY (`id_caja`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_caja: ~4 rows (aproximadamente)
DELETE FROM `tm_caja`;
INSERT INTO `tm_caja` (`id_caja`, `descripcion`, `estado`) VALUES
	(1, 'CAJA PRINCIPAL', 'a'),
	(2, 'CAJA 2', 'a'),
	(3, 'CAJA 3', 'a'),
	(4, 'CAJAN', 'i');

-- Volcando estructura para tabla factuyorest.tm_cliente
CREATE TABLE IF NOT EXISTS `tm_cliente` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `tipo_cliente` int(11) NOT NULL,
  `dni` varchar(8) NOT NULL,
  `ruc` varchar(13) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `telefono` int(11) NOT NULL,
  `fecha_nac` date NOT NULL,
  `correo` varchar(100) NOT NULL,
  `direccion` varchar(100) NOT NULL DEFAULT 'S/DIRECCION',
  `referencia` varchar(100) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_cliente: ~1 rows (aproximadamente)
DELETE FROM `tm_cliente`;
INSERT INTO `tm_cliente` (`id_cliente`, `tipo_cliente`, `dni`, `ruc`, `nombres`, `razon_social`, `telefono`, `fecha_nac`, `correo`, `direccion`, `referencia`, `estado`) VALUES
	(1, 1, '00000000', '', 'PUBLICO EN GENERAL', '', 0, '1970-01-01', '', '-', '', 'a'),
	(2, 2, '', '20606682990', '', 'TALEX DS SOCIEDAD ANONIMA CERRADA', 0, '1970-01-01', '', 'PJ. 05 DE JULIO MZ. B LT. 33 A.H. MIGUEL GRAU, LORETO - MAYNAS - PUNCHANA', '', 'a'),
	(3, 1, '44396705', '', 'CARLOS OLIVA', '', 978047168, '0000-00-00', '', 'JR. YAVARI 1234', 'FRENTE AL PARQUE ZONAL, AL COSTADO DE BODEGA MECHITA', 'a');

-- Volcando estructura para tabla factuyorest.tm_comandas
CREATE TABLE IF NOT EXISTS `tm_comandas` (
  `id_pedido` int(45) NOT NULL,
  `fecha_pedido` datetime NOT NULL,
  `id_key` varchar(144) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla factuyorest.tm_comandas: ~15 rows (aproximadamente)
DELETE FROM `tm_comandas`;
INSERT INTO `tm_comandas` (`id_pedido`, `fecha_pedido`, `id_key`) VALUES
	(1, '2024-03-31 21:08:40', 'ce5814765edefe4f126786f42373a2da'),
	(1, '2024-03-31 21:09:26', 'f77971c6ee4d0ea58b03b8023998047d'),
	(3, '2024-03-31 22:34:57', '1f25577e29d0c3694f6479d1080ded16'),
	(4, '2024-03-31 22:39:27', '4a75c6bc84b7bff7400b8989e1cf73cf'),
	(5, '2024-03-31 23:20:09', 'ed4dd3a08f88adc68d379d183df054d2'),
	(2, '2024-04-01 00:29:37', '119f21a8188d0ff85c9a31b78e7e4c14'),
	(6, '2024-04-01 00:31:27', '6b702fef6818156fa97d6c2f01546a2e'),
	(7, '2024-04-01 00:40:16', 'a3fd12d0a8ffd209244b4ea74d5667b6'),
	(8, '2024-04-01 00:51:11', '7444030f389723b52b0d905f2ed42492'),
	(9, '2024-04-01 00:52:01', '2f05ed8096eccc1bcfae71fc163ecefd'),
	(10, '2024-04-01 00:55:44', '3ef58138822bdf8c1118eb1c8a6ce57e'),
	(11, '2024-04-01 01:00:15', 'ccafa0155f01f1f4b6749a1ac704c873'),
	(12, '2024-04-01 01:01:03', 'ce9e8d6b20caef9cf7e0d61a1518de75'),
	(13, '2024-04-01 01:25:03', '6811dba994cd9b32845e5a16b8dca2a4'),
	(14, '2024-04-01 01:25:53', 'd1bd966735986eda194afd25ddbd087a'),
	(15, '2024-04-01 01:26:42', '29047ba56316bbe3e95116c0f709a691'),
	(16, '2024-04-01 01:27:34', '9121a930faf4ad0e111ac9c0487d1a0a');

-- Volcando estructura para tabla factuyorest.tm_compra
CREATE TABLE IF NOT EXISTS `tm_compra` (
  `id_compra` int(11) NOT NULL AUTO_INCREMENT,
  `id_prov` int(11) NOT NULL,
  `id_tipo_compra` int(11) NOT NULL,
  `id_tipo_doc` int(11) NOT NULL,
  `id_usu` int(11) DEFAULT NULL,
  `fecha_c` date DEFAULT NULL,
  `hora_c` varchar(45) DEFAULT NULL,
  `serie_doc` varchar(45) DEFAULT NULL,
  `num_doc` varchar(45) DEFAULT NULL,
  `igv` decimal(10,2) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  `descuento` decimal(10,2) DEFAULT NULL,
  `estado` varchar(1) DEFAULT 'a',
  `observaciones` varchar(100) DEFAULT NULL,
  `fecha_reg` datetime DEFAULT NULL,
  PRIMARY KEY (`id_compra`),
  KEY `FK_comp_prov` (`id_prov`),
  KEY `FK_comp_tipoc` (`id_tipo_compra`),
  KEY `FK_comp_tipod` (`id_tipo_doc`),
  KEY `FK_comp_usu` (`id_usu`),
  CONSTRAINT `FK_comp_prov` FOREIGN KEY (`id_prov`) REFERENCES `tm_proveedor` (`id_prov`),
  CONSTRAINT `FK_comp_tipoc` FOREIGN KEY (`id_tipo_compra`) REFERENCES `tm_tipo_compra` (`id_tipo_compra`),
  CONSTRAINT `FK_comp_tipod` FOREIGN KEY (`id_tipo_doc`) REFERENCES `tm_tipo_doc` (`id_tipo_doc`),
  CONSTRAINT `FK_comp_usu` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_compra: ~0 rows (aproximadamente)
DELETE FROM `tm_compra`;

-- Volcando estructura para tabla factuyorest.tm_compra_credito
CREATE TABLE IF NOT EXISTS `tm_compra_credito` (
  `id_credito` int(11) NOT NULL AUTO_INCREMENT,
  `id_compra` int(11) NOT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  `interes` decimal(10,2) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `estado` varchar(5) DEFAULT 'p',
  PRIMARY KEY (`id_credito`),
  KEY `FK_CC_ID_COMPRA_idx` (`id_compra`),
  CONSTRAINT `FK_compcre_idcomp` FOREIGN KEY (`id_compra`) REFERENCES `tm_compra` (`id_compra`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_compra_credito: ~0 rows (aproximadamente)
DELETE FROM `tm_compra_credito`;

-- Volcando estructura para tabla factuyorest.tm_compra_detalle
CREATE TABLE IF NOT EXISTS `tm_compra_detalle` (
  `id_compra` int(11) NOT NULL,
  `id_tp` int(11) NOT NULL,
  `id_pres` int(11) NOT NULL,
  `cant` decimal(10,2) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  KEY `FK_CDET_COM` (`id_compra`),
  CONSTRAINT `FK_CDET_COM` FOREIGN KEY (`id_compra`) REFERENCES `tm_compra` (`id_compra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_compra_detalle: ~0 rows (aproximadamente)
DELETE FROM `tm_compra_detalle`;

-- Volcando estructura para tabla factuyorest.tm_configuracion
CREATE TABLE IF NOT EXISTS `tm_configuracion` (
  `id_cfg` int(11) NOT NULL AUTO_INCREMENT,
  `zona_hora` varchar(100) DEFAULT NULL,
  `trib_acr` varchar(20) DEFAULT NULL,
  `trib_car` int(5) DEFAULT NULL,
  `di_acr` varchar(20) DEFAULT NULL,
  `di_car` int(5) DEFAULT NULL,
  `imp_acr` varchar(20) DEFAULT NULL,
  `imp_val` decimal(10,2) DEFAULT NULL,
  `mon_acr` varchar(20) DEFAULT NULL,
  `mon_val` varchar(5) DEFAULT NULL,
  `pc_name` varchar(50) DEFAULT NULL,
  `pc_ip` varchar(20) DEFAULT NULL,
  `print_com` int(1) DEFAULT NULL,
  `print_pre` int(1) DEFAULT NULL,
  `print_cpe` int(1) DEFAULT NULL,
  `opc_01` int(1) DEFAULT NULL,
  `opc_02` int(1) DEFAULT NULL,
  `opc_03` int(1) DEFAULT NULL,
  `bloqueo` int(1) DEFAULT NULL,
  `cod_seg` varchar(45) DEFAULT NULL,
  `sep_items` int(11) DEFAULT 0,
  `verpdf` int(1) DEFAULT 0,
  `nota_ind` int(1) NOT NULL DEFAULT 1,
  `imp_val_bol` decimal(10,2) NOT NULL DEFAULT 0.50,
  `imp_bol` varchar(10) NOT NULL DEFAULT 'ICBPER',
  `plan` longtext DEFAULT NULL,
  `mostrarimagen` int(11) NOT NULL DEFAULT 0,
  `envios_auto` int(11) NOT NULL DEFAULT 1,
  `precio_comanda` int(11) NOT NULL DEFAULT 0,
  `direccion_comanda` int(11) NOT NULL DEFAULT 0,
  `pedido_comanda` int(11) NOT NULL DEFAULT 0,
  `multiples_precios` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_cfg`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_configuracion: ~0 rows (aproximadamente)
DELETE FROM `tm_configuracion`;
INSERT INTO `tm_configuracion` (`id_cfg`, `zona_hora`, `trib_acr`, `trib_car`, `di_acr`, `di_car`, `imp_acr`, `imp_val`, `mon_acr`, `mon_val`, `pc_name`, `pc_ip`, `print_com`, `print_pre`, `print_cpe`, `opc_01`, `opc_02`, `opc_03`, `bloqueo`, `cod_seg`, `sep_items`, `verpdf`, `nota_ind`, `imp_val_bol`, `imp_bol`, `plan`, `mostrarimagen`, `envios_auto`, `precio_comanda`, `direccion_comanda`, `pedido_comanda`, `multiples_precios`) VALUES
	(1, 'America/Lima', 'RUC', 11, 'DNI', 8, 'IGV', 18.00, 'Soles', 'S/', 'DESKTOP-FT7N1H1', '192.168.222.222', 0, 0, 0, 1, 0, 1, 0, '123', 1, 1, 1, 0.50, 'ICBPER', '{"created_at":"21-03-2023","limit_users":"","locked_users":"","limit_documents":"","locked_documents":"","wsp_token":"4ZVy7PG54DD1zxpcwTeakNQJQJOIAM","api_wsp":"0"}', 1, 1, 1, 0, 1, 1);

-- Volcando estructura para tabla factuyorest.tm_credito_detalle
CREATE TABLE IF NOT EXISTS `tm_credito_detalle` (
  `id_credito` int(11) DEFAULT NULL,
  `id_usu` int(11) DEFAULT NULL,
  `importe` decimal(10,2) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `egreso` int(1) DEFAULT 0,
  KEY `FK_cred_usu` (`id_usu`),
  KEY `FK_CRED_CRED` (`id_credito`),
  CONSTRAINT `FK_CRED_CRED` FOREIGN KEY (`id_credito`) REFERENCES `tm_compra_credito` (`id_credito`),
  CONSTRAINT `FK_cred_usu` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_credito_detalle: ~0 rows (aproximadamente)
DELETE FROM `tm_credito_detalle`;

-- Volcando estructura para tabla factuyorest.tm_detalle_pedido
CREATE TABLE IF NOT EXISTS `tm_detalle_pedido` (
  `id_pedido` int(11) NOT NULL,
  `id_usu` int(11) NOT NULL,
  `id_pres` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `cant` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `comentario` varchar(100) NOT NULL,
  `fecha_pedido` datetime NOT NULL,
  `fecha_envio` datetime NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  KEY `FK_DPED_PRES` (`id_pres`),
  KEY `FK_DPED_PED` (`id_pedido`),
  KEY `FK_DPED_USU` (`id_usu`),
  CONSTRAINT `FK_DPED_PED` FOREIGN KEY (`id_pedido`) REFERENCES `tm_pedido` (`id_pedido`),
  CONSTRAINT `FK_DPED_PRES` FOREIGN KEY (`id_pres`) REFERENCES `tm_producto_pres` (`id_pres`),
  CONSTRAINT `FK_DPED_USU` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Volcando datos para la tabla factuyorest.tm_detalle_pedido: ~34 rows (aproximadamente)
DELETE FROM `tm_detalle_pedido`;
INSERT INTO `tm_detalle_pedido` (`id_pedido`, `id_usu`, `id_pres`, `cantidad`, `cant`, `precio`, `comentario`, `fecha_pedido`, `fecha_envio`, `estado`) VALUES
	(1, 1, 1, 0, 1, 8.00, '', '2024-03-31 21:08:40', '0000-00-00 00:00:00', 'a'),
	(1, 1, 1, 0, 1, 8.00, '', '2024-03-31 21:09:26', '0000-00-00 00:00:00', 'a'),
	(3, 1, 1, 0, 1, 8.00, '', '2024-03-31 22:34:57', '0000-00-00 00:00:00', 'a'),
	(3, 1, 7, 0, 1, 18.00, '', '2024-03-31 22:34:57', '0000-00-00 00:00:00', 'a'),
	(4, 1, 2, 0, 1, 7.00, '', '2024-03-31 22:39:27', '0000-00-00 00:00:00', 'a'),
	(4, 1, 7, 0, 1, 18.00, '', '2024-03-31 22:39:27', '0000-00-00 00:00:00', 'a'),
	(4, 1, 9, 0, 1, 5.00, '', '2024-03-31 22:39:27', '0000-00-00 00:00:00', 'a'),
	(4, 1, 9, 0, 1, 5.00, '', '2024-03-31 22:39:27', '0000-00-00 00:00:00', 'a'),
	(5, 58, 2, 1, 1, 7.00, '', '2024-03-31 23:20:09', '0000-00-00 00:00:00', 'a'),
	(2, 1, 1, 0, 1, 8.00, '', '2024-04-01 00:29:37', '0000-00-00 00:00:00', 'a'),
	(6, 1, 1, 0, 1, 8.00, '', '2024-04-01 00:32:31', '0000-00-00 00:00:00', 'a'),
	(6, 1, 9, 0, 1, 5.00, '', '2024-04-01 00:32:31', '0000-00-00 00:00:00', 'a'),
	(7, 1, 1, 0, 1, 8.00, '', '2024-04-01 00:40:16', '0000-00-00 00:00:00', 'a'),
	(7, 1, 5, 0, 1, 10.00, '', '2024-04-01 00:40:16', '0000-00-00 00:00:00', 'a'),
	(7, 1, 9, 0, 1, 5.00, '', '2024-04-01 00:40:16', '0000-00-00 00:00:00', 'a'),
	(8, 1, 1, 0, 1, 8.00, '', '2024-04-01 00:51:11', '0000-00-00 00:00:00', 'a'),
	(8, 1, 9, 0, 1, 5.00, '', '2024-04-01 00:51:11', '0000-00-00 00:00:00', 'a'),
	(9, 1, 5, 0, 1, 10.00, '', '2024-04-01 00:52:01', '0000-00-00 00:00:00', 'a'),
	(9, 1, 6, 0, 1, 10.00, '', '2024-04-01 00:52:01', '0000-00-00 00:00:00', 'a'),
	(10, 1, 1, 0, 1, 8.00, '', '2024-04-01 00:55:44', '0000-00-00 00:00:00', 'a'),
	(11, 1, 1, 0, 1, 8.00, '', '2024-04-01 01:00:15', '0000-00-00 00:00:00', 'a'),
	(11, 1, 5, 0, 1, 10.00, '', '2024-04-01 01:00:15', '0000-00-00 00:00:00', 'a'),
	(11, 1, 9, 0, 1, 5.00, '', '2024-04-01 01:00:15', '0000-00-00 00:00:00', 'a'),
	(12, 1, 1, 0, 1, 8.00, '', '2024-04-01 01:01:03', '0000-00-00 00:00:00', 'a'),
	(12, 1, 2, 0, 1, 7.00, '', '2024-04-01 01:01:03', '0000-00-00 00:00:00', 'a'),
	(12, 1, 5, 0, 1, 10.00, '', '2024-04-01 01:01:03', '0000-00-00 00:00:00', 'a'),
	(13, 1, 5, 1, 1, 10.00, '', '2024-04-01 01:25:03', '0000-00-00 00:00:00', 'a'),
	(13, 1, 9, 1, 1, 5.00, '', '2024-04-01 01:25:03', '0000-00-00 00:00:00', 'a'),
	(13, 1, 6, 1, 1, 10.00, '', '2024-04-01 01:25:03', '0000-00-00 00:00:00', 'a'),
	(14, 1, 1, 0, 1, 8.00, '', '2024-04-01 01:25:53', '0000-00-00 00:00:00', 'a'),
	(14, 1, 2, 0, 1, 7.00, '', '2024-04-01 01:25:53', '0000-00-00 00:00:00', 'a'),
	(14, 1, 7, 0, 1, 18.00, '', '2024-04-01 01:25:53', '0000-00-00 00:00:00', 'a'),
	(15, 1, 6, 0, 1, 10.00, '', '2024-04-01 01:26:42', '0000-00-00 00:00:00', 'a'),
	(15, 1, 7, 0, 1, 18.00, '', '2024-04-01 01:26:42', '0000-00-00 00:00:00', 'a'),
	(16, 1, 8, 0, 1, 25.00, '', '2024-04-01 01:27:34', '0000-00-00 00:00:00', 'a');

-- Volcando estructura para tabla factuyorest.tm_detalle_venta
CREATE TABLE IF NOT EXISTS `tm_detalle_venta` (
  `id_venta` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  KEY `FK_DVEN_VEN` (`id_venta`),
  KEY `FK_DVEN_PRES` (`id_prod`),
  CONSTRAINT `FK_DVEN_VEN` FOREIGN KEY (`id_venta`) REFERENCES `tm_venta` (`id_venta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_detalle_venta: ~29 rows (aproximadamente)
DELETE FROM `tm_detalle_venta`;
INSERT INTO `tm_detalle_venta` (`id_venta`, `id_prod`, `cantidad`, `precio`) VALUES
	(2, 1, 2, 8.00),
	(3, 1, 1, 8.00),
	(3, 7, 1, 18.00),
	(4, 2, 1, 7.00),
	(4, 7, 1, 18.00),
	(4, 9, 2, 5.00),
	(5, 1, 1, 8.00),
	(6, 1, 1, 8.00),
	(6, 9, 1, 5.00),
	(7, 1, 1, 8.00),
	(7, 5, 1, 10.00),
	(7, 9, 1, 5.00),
	(8, 1, 1, 8.00),
	(8, 9, 1, 5.00),
	(9, 5, 1, 10.00),
	(9, 6, 1, 10.00),
	(10, 1, 1, 8.00),
	(11, 1, 1, 8.00),
	(11, 5, 1, 10.00),
	(11, 9, 1, 5.00),
	(12, 1, 1, 8.00),
	(12, 2, 1, 7.00),
	(12, 5, 1, 10.00),
	(13, 1, 1, 8.00),
	(13, 2, 1, 7.00),
	(13, 7, 1, 18.00),
	(14, 6, 1, 10.00),
	(14, 7, 1, 18.00),
	(15, 8, 1, 25.00);

-- Volcando estructura para tabla factuyorest.tm_empresa
CREATE TABLE IF NOT EXISTS `tm_empresa` (
  `id_de` int(11) NOT NULL AUTO_INCREMENT,
  `ruc` varchar(20) DEFAULT NULL,
  `razon_social` varchar(200) DEFAULT NULL,
  `nombre_comercial` varchar(200) DEFAULT NULL,
  `direccion_comercial` varchar(200) DEFAULT NULL,
  `direccion_fiscal` varchar(200) DEFAULT NULL,
  `ubigeo` varchar(8) DEFAULT NULL,
  `departamento` varchar(50) DEFAULT NULL,
  `provincia` varchar(50) DEFAULT NULL,
  `distrito` varchar(50) DEFAULT NULL,
  `sunat` int(1) NOT NULL,
  `modo` int(1) DEFAULT NULL,
  `paginaweb` int(11) DEFAULT NULL,
  `usuariosol` varchar(50) DEFAULT NULL,
  `clavesol` varchar(50) DEFAULT NULL,
  `certpse` int(1) NOT NULL,
  `clavecertificado` varchar(50) DEFAULT NULL,
  `client_id` varchar(45) DEFAULT NULL,
  `client_secret` varchar(45) DEFAULT NULL,
  `logo` varchar(45) DEFAULT NULL,
  `celular` varchar(50) DEFAULT NULL,
  `email` varchar(120) DEFAULT NULL,
  `ose` int(11) NOT NULL DEFAULT 0,
  `ose_url` varchar(500) DEFAULT NULL,
  `amazonas` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_de`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_empresa: ~0 rows (aproximadamente)
DELETE FROM `tm_empresa`;
INSERT INTO `tm_empresa` (`id_de`, `ruc`, `razon_social`, `nombre_comercial`, `direccion_comercial`, `direccion_fiscal`, `ubigeo`, `departamento`, `provincia`, `distrito`, `sunat`, `modo`, `paginaweb`, `usuariosol`, `clavesol`, `certpse`, `clavecertificado`, `client_id`, `client_secret`, `logo`, `celular`, `email`, `ose`, `ose_url`, `amazonas`) VALUES
	(1, '20304050607', 'DOÑA JULIA REST E.I.R.L.', 'FACTUYO SAC', 'AV. LA MARINA 1234 LORETO MAYNAS IQUITOS', 'AV. LA MARINA 1234 LORETO MAYNAS IQUITOS', '150132', 'LORETO', 'MAYNAS', 'IQUITOS', 1, 3, 0, 'MODDATOS', 'MODDATOS', 0, 'FacTuyoSAC', 'cliente_id', 'cliente_secret', 'logoprint.png', '930955778', '', 0, '', 1);

-- Volcando estructura para tabla factuyorest.tm_gastos_adm
CREATE TABLE IF NOT EXISTS `tm_gastos_adm` (
  `id_ga` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo_gasto` int(11) NOT NULL,
  `id_usu` int(11) NOT NULL,
  `id_apc` int(11) NOT NULL,
  `id_per` int(11) DEFAULT NULL,
  `importe` decimal(10,2) DEFAULT NULL,
  `responsable` varchar(100) DEFAULT NULL,
  `motivo` varchar(100) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT NULL,
  `estado` varchar(5) DEFAULT 'a',
  PRIMARY KEY (`id_ga`),
  KEY `FK_gasto_tg` (`id_tipo_gasto`),
  KEY `FK_EADM_APC` (`id_apc`),
  KEY `FK_EADM_USU` (`id_usu`),
  CONSTRAINT `FK_EADM_APC` FOREIGN KEY (`id_apc`) REFERENCES `tm_aper_cierre` (`id_apc`),
  CONSTRAINT `FK_EADM_TGAS` FOREIGN KEY (`id_tipo_gasto`) REFERENCES `tm_tipo_gasto` (`id_tipo_gasto`),
  CONSTRAINT `FK_EADM_USU` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_gastos_adm: ~0 rows (aproximadamente)
DELETE FROM `tm_gastos_adm`;

-- Volcando estructura para tabla factuyorest.tm_impresora
CREATE TABLE IF NOT EXISTS `tm_impresora` (
  `id_imp` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_imp`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_impresora: ~4 rows (aproximadamente)
DELETE FROM `tm_impresora`;
INSERT INTO `tm_impresora` (`id_imp`, `nombre`, `estado`) VALUES
	(1, 'NINGUNO', 'a'),
	(2, 'COCINA', 'a'),
	(3, 'CAJA', 'a'),
	(6, 'CAJAN', 'i');

-- Volcando estructura para tabla factuyorest.tm_ingresos_adm
CREATE TABLE IF NOT EXISTS `tm_ingresos_adm` (
  `id_ing` int(11) NOT NULL AUTO_INCREMENT,
  `id_usu` int(11) NOT NULL,
  `id_apc` int(11) NOT NULL,
  `importe` decimal(10,2) DEFAULT NULL,
  `responsable` varchar(100) DEFAULT NULL,
  `motivo` varchar(200) DEFAULT NULL,
  `fecha_reg` datetime DEFAULT NULL,
  `estado` varchar(5) DEFAULT 'a',
  PRIMARY KEY (`id_ing`),
  KEY `FK_IADM_USU` (`id_usu`),
  KEY `FK_IADM_APC` (`id_apc`),
  CONSTRAINT `FK_IADM_APC` FOREIGN KEY (`id_apc`) REFERENCES `tm_aper_cierre` (`id_apc`),
  CONSTRAINT `FK_IADM_USU` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_ingresos_adm: ~0 rows (aproximadamente)
DELETE FROM `tm_ingresos_adm`;

-- Volcando estructura para tabla factuyorest.tm_insumo
CREATE TABLE IF NOT EXISTS `tm_insumo` (
  `id_ins` int(11) NOT NULL AUTO_INCREMENT,
  `id_catg` int(11) NOT NULL,
  `id_med` int(11) NOT NULL,
  `cod_ins` varchar(10) DEFAULT NULL,
  `nomb_ins` varchar(45) DEFAULT NULL,
  `stock_min` int(11) DEFAULT NULL,
  `cos_uni` decimal(10,2) DEFAULT NULL,
  `estado` varchar(5) DEFAULT 'a',
  PRIMARY KEY (`id_ins`),
  KEY `FK_ins_catg` (`id_catg`),
  KEY `FK_ins_med` (`id_med`),
  CONSTRAINT `FK_ins_catg` FOREIGN KEY (`id_catg`) REFERENCES `tm_insumo_catg` (`id_catg`),
  CONSTRAINT `FK_ins_med` FOREIGN KEY (`id_med`) REFERENCES `tm_tipo_medida` (`id_med`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Volcando datos para la tabla factuyorest.tm_insumo: ~0 rows (aproximadamente)
DELETE FROM `tm_insumo`;

-- Volcando estructura para tabla factuyorest.tm_insumo_catg
CREATE TABLE IF NOT EXISTS `tm_insumo_catg` (
  `id_catg` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  `estado` varchar(5) DEFAULT 'a',
  PRIMARY KEY (`id_catg`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_insumo_catg: ~0 rows (aproximadamente)
DELETE FROM `tm_insumo_catg`;

-- Volcando estructura para tabla factuyorest.tm_inventario
CREATE TABLE IF NOT EXISTS `tm_inventario` (
  `id_inv` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo_ope` int(11) NOT NULL,
  `id_ope` int(11) NOT NULL,
  `id_tipo_ins` int(11) NOT NULL,
  `id_ins` int(11) NOT NULL,
  `cos_uni` decimal(10,2) NOT NULL,
  `cant` float NOT NULL,
  `fecha_r` datetime NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_inv`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_inventario: ~0 rows (aproximadamente)
DELETE FROM `tm_inventario`;

-- Volcando estructura para tabla factuyorest.tm_inventario_entsal
CREATE TABLE IF NOT EXISTS `tm_inventario_entsal` (
  `id_es` int(11) NOT NULL AUTO_INCREMENT,
  `id_usu` int(11) NOT NULL,
  `id_tipo` int(11) NOT NULL,
  `id_responsable` int(11) NOT NULL,
  `motivo` varchar(200) NOT NULL,
  `fecha` datetime NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_es`),
  KEY `FK_INVES_USU` (`id_usu`),
  KEY `FK_INVES_RESP` (`id_responsable`),
  CONSTRAINT `FK_INVES_RESP` FOREIGN KEY (`id_responsable`) REFERENCES `tm_usuario` (`id_usu`),
  CONSTRAINT `FK_INVES_USU` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_inventario_entsal: ~0 rows (aproximadamente)
DELETE FROM `tm_inventario_entsal`;

-- Volcando estructura para tabla factuyorest.tm_margen_venta
CREATE TABLE IF NOT EXISTS `tm_margen_venta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cod_dia` int(11) NOT NULL,
  `dia` varchar(45) NOT NULL,
  `margen` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_margen_venta: ~7 rows (aproximadamente)
DELETE FROM `tm_margen_venta`;
INSERT INTO `tm_margen_venta` (`id`, `cod_dia`, `dia`, `margen`) VALUES
	(1, 1, 'Lunes', 150.00),
	(2, 2, 'Martes', 750.00),
	(3, 3, 'Miércoles', 750.00),
	(4, 4, 'Jueves', 850.00),
	(5, 5, 'Viernes', 1200.00),
	(6, 6, 'Sábado', 1800.00),
	(7, 0, 'Domingo', 2500.00);

-- Volcando estructura para tabla factuyorest.tm_mesa
CREATE TABLE IF NOT EXISTS `tm_mesa` (
  `id_mesa` int(11) NOT NULL AUTO_INCREMENT,
  `id_salon` int(11) NOT NULL,
  `nro_mesa` varchar(5) NOT NULL,
  `forma` int(11) NOT NULL DEFAULT 1,
  `estado` varchar(45) NOT NULL DEFAULT 'a',
  `json_table` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`json_table`)),
  PRIMARY KEY (`id_mesa`),
  UNIQUE KEY `numero_mesa_unique` (`nro_mesa`,`id_salon`) USING BTREE,
  KEY `FKM_IDCATG_idx` (`id_salon`),
  CONSTRAINT `fk_mesa_salon` FOREIGN KEY (`id_salon`) REFERENCES `tm_salon` (`id_salon`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_mesa: ~8 rows (aproximadamente)
DELETE FROM `tm_mesa`;
INSERT INTO `tm_mesa` (`id_mesa`, `id_salon`, `nro_mesa`, `forma`, `estado`, `json_table`) VALUES
	(1, 1, 'M01', 1, 'a', NULL),
	(2, 1, 'M02', 1, 'a', NULL),
	(3, 1, 'M03', 1, 'a', NULL),
	(4, 1, 'M04', 1, 'a', NULL),
	(5, 1, 'M05', 1, 'a', NULL),
	(6, 2, 'S01', 2, 'a', NULL),
	(7, 2, 'S02', 2, 'a', NULL),
	(8, 2, 'S03', 2, 'a', NULL);

-- Volcando estructura para tabla factuyorest.tm_pago
CREATE TABLE IF NOT EXISTS `tm_pago` (
  `id_pago` int(2) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(50) NOT NULL,
  PRIMARY KEY (`id_pago`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_pago: ~6 rows (aproximadamente)
DELETE FROM `tm_pago`;
INSERT INTO `tm_pago` (`id_pago`, `descripcion`) VALUES
	(1, 'EFECTIVO'),
	(2, 'TARJETAS'),
	(3, 'MIXTO'),
	(4, 'EN LINEA'),
	(5, 'TRANSFERENCIAS'),
	(6, 'VALES');

-- Volcando estructura para tabla factuyorest.tm_pedido
CREATE TABLE IF NOT EXISTS `tm_pedido` (
  `id_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo_pedido` int(11) NOT NULL,
  `id_apc` int(11) DEFAULT NULL,
  `id_usu` int(11) NOT NULL,
  `fecha_pedido` datetime NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_pedido`),
  KEY `FK_ped_tp` (`id_tipo_pedido`),
  KEY `FK_ped_usu` (`id_usu`),
  KEY `FK_ped_apc` (`id_apc`),
  CONSTRAINT `FK_ped_tp` FOREIGN KEY (`id_tipo_pedido`) REFERENCES `tm_tipo_pedido` (`id_tipo_pedido`),
  CONSTRAINT `FK_ped_usu` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_pedido: ~15 rows (aproximadamente)
DELETE FROM `tm_pedido`;
INSERT INTO `tm_pedido` (`id_pedido`, `id_tipo_pedido`, `id_apc`, `id_usu`, `fecha_pedido`, `estado`) VALUES
	(1, 1, 1, 1, '2024-03-31 21:08:36', 'd'),
	(2, 2, 1, 1, '2024-03-31 22:31:19', 'b'),
	(3, 2, 1, 1, '2024-03-31 22:34:51', 'b'),
	(4, 1, 1, 1, '2024-03-31 22:37:16', 'd'),
	(5, 2, NULL, 58, '2024-03-31 23:20:03', 'z'),
	(6, 3, 1, 1, '2024-04-01 00:31:19', 'c'),
	(7, 2, 1, 1, '2024-04-01 00:40:07', 'b'),
	(8, 1, 1, 1, '2024-04-01 00:51:03', 'd'),
	(9, 2, 1, 1, '2024-04-01 00:51:57', 'b'),
	(10, 2, 1, 1, '2024-04-01 00:55:41', 'b'),
	(11, 2, 1, 1, '2024-04-01 01:00:09', 'b'),
	(12, 1, 1, 1, '2024-04-01 01:00:58', 'd'),
	(13, 2, NULL, 1, '2024-04-01 01:24:54', 'z'),
	(14, 2, 2, 1, '2024-04-01 01:25:45', 'b'),
	(15, 2, 2, 1, '2024-04-01 01:26:36', 'b'),
	(16, 2, 2, 1, '2024-04-01 01:27:30', 'b');

-- Volcando estructura para tabla factuyorest.tm_pedido_delivery
CREATE TABLE IF NOT EXISTS `tm_pedido_delivery` (
  `id_pedido` int(11) NOT NULL,
  `tipo_canal` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_repartidor` int(11) NOT NULL,
  `tipo_pago` int(11) NOT NULL,
  `tipo_entrega` int(11) NOT NULL,
  `pedido_programado` int(11) DEFAULT 0,
  `hora_entrega` time DEFAULT '00:00:00',
  `paga_con` decimal(10,2) NOT NULL,
  `comision_delivery` decimal(10,2) NOT NULL,
  `amortizacion` decimal(10,2) NOT NULL,
  `nro_pedido` varchar(10) NOT NULL,
  `nombre_cliente` varchar(100) NOT NULL,
  `telefono_cliente` varchar(20) NOT NULL,
  `direccion_cliente` varchar(100) NOT NULL,
  `referencia_cliente` varchar(100) NOT NULL,
  `email_cliente` varchar(200) NOT NULL,
  `fecha_preparacion` datetime NOT NULL,
  `fecha_envio` datetime NOT NULL,
  `fecha_entrega` datetime NOT NULL,
  KEY `FK_peddel_ped` (`id_pedido`),
  KEY `FK_peddel_cli` (`id_cliente`),
  CONSTRAINT `FK_peddel_cli` FOREIGN KEY (`id_cliente`) REFERENCES `tm_cliente` (`id_cliente`),
  CONSTRAINT `FK_peddel_ped` FOREIGN KEY (`id_pedido`) REFERENCES `tm_pedido` (`id_pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_pedido_delivery: ~0 rows (aproximadamente)
DELETE FROM `tm_pedido_delivery`;
INSERT INTO `tm_pedido_delivery` (`id_pedido`, `tipo_canal`, `id_cliente`, `id_repartidor`, `tipo_pago`, `tipo_entrega`, `pedido_programado`, `hora_entrega`, `paga_con`, `comision_delivery`, `amortizacion`, `nro_pedido`, `nombre_cliente`, `telefono_cliente`, `direccion_cliente`, `referencia_cliente`, `email_cliente`, `fecha_preparacion`, `fecha_envio`, `fecha_entrega`) VALUES
	(6, 1, 3, 53, 1, 1, NULL, '00:00:00', 20.00, 0.00, 0.00, '00001', 'CARLOS OLIVA', '978047168', 'JR. YAVARI 1234', 'FRENTE AL PARQUE ZONAL, AL COSTADO DE BODEGA MECHITA', '978047168@gmail.com', '2024-04-01 00:32:31', '2024-04-01 00:33:45', '0000-00-00 00:00:00');

-- Volcando estructura para tabla factuyorest.tm_pedido_llevar
CREATE TABLE IF NOT EXISTS `tm_pedido_llevar` (
  `id_pedido` int(11) NOT NULL,
  `nro_pedido` varchar(10) NOT NULL,
  `nomb_cliente` varchar(100) NOT NULL,
  `fecha_entrega` datetime NOT NULL,
  KEY `FK_pedlle_ped` (`id_pedido`),
  CONSTRAINT `FK_pedlle_ped` FOREIGN KEY (`id_pedido`) REFERENCES `tm_pedido` (`id_pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_pedido_llevar: ~10 rows (aproximadamente)
DELETE FROM `tm_pedido_llevar`;
INSERT INTO `tm_pedido_llevar` (`id_pedido`, `nro_pedido`, `nomb_cliente`, `fecha_entrega`) VALUES
	(2, '00001', 'VENTA RAPIDA - ADMIN', '2024-04-01 00:29:44'),
	(3, '00002', 'VENTA RAPIDA - ADMIN', '2024-03-31 22:35:15'),
	(5, '00003', 'VENTA RAPIDA - ADMIN', '0000-00-00 00:00:00'),
	(7, '00003', 'VENTA RAPIDA - ADMIN', '2024-04-01 00:40:25'),
	(9, '00004', 'VENTA RAPIDA - ADMIN', '2024-04-01 00:52:07'),
	(10, '00005', 'VENTA RAPIDA - ADMIN', '2024-04-01 00:55:48'),
	(11, '00006', 'VENTA RAPIDA - ADMIN', '2024-04-01 01:00:38'),
	(13, '00007', 'VENTA RAPIDA - ADMIN', '0000-00-00 00:00:00'),
	(14, '00007', 'VENTA RAPIDA - ADMIN', '2024-04-01 01:26:05'),
	(15, '00008', 'VENTA RAPIDA - ADMIN', '2024-04-01 01:27:01'),
	(16, '00009', 'VENTA RAPIDA - ADMIN', '2024-04-01 01:27:47');

-- Volcando estructura para tabla factuyorest.tm_pedido_mesa
CREATE TABLE IF NOT EXISTS `tm_pedido_mesa` (
  `id_pedido` int(11) NOT NULL,
  `id_mesa` int(11) NOT NULL,
  `id_mozo` int(11) NOT NULL,
  `nomb_cliente` varchar(45) NOT NULL,
  `nro_personas` int(11) NOT NULL,
  KEY `FK_pedme_ped` (`id_pedido`),
  KEY `FK_pedme_mesa` (`id_mesa`),
  KEY `FK_pedme_mozo` (`id_mozo`),
  CONSTRAINT `FK_pedme_mesa` FOREIGN KEY (`id_mesa`) REFERENCES `tm_mesa` (`id_mesa`),
  CONSTRAINT `FK_pedme_mozo` FOREIGN KEY (`id_mozo`) REFERENCES `tm_usuario` (`id_usu`),
  CONSTRAINT `FK_pedme_ped` FOREIGN KEY (`id_pedido`) REFERENCES `tm_pedido` (`id_pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_pedido_mesa: ~4 rows (aproximadamente)
DELETE FROM `tm_pedido_mesa`;
INSERT INTO `tm_pedido_mesa` (`id_pedido`, `id_mesa`, `id_mozo`, `nomb_cliente`, `nro_personas`) VALUES
	(1, 1, 58, 'Mesa: M01', 1),
	(4, 1, 58, 'Mesa: M01', 1),
	(8, 1, 58, 'Mesa: M01', 1),
	(12, 1, 58, 'Mesa: M01', 1);

-- Volcando estructura para tabla factuyorest.tm_producto
CREATE TABLE IF NOT EXISTS `tm_producto` (
  `id_prod` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo` int(11) NOT NULL,
  `id_catg` int(11) NOT NULL DEFAULT 0,
  `id_areap` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `notas` varchar(200) DEFAULT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `delivery` int(1) DEFAULT 0,
  `estado` varchar(1) DEFAULT 'a',
  `cod_pro` varchar(45) NOT NULL,
  PRIMARY KEY (`id_prod`),
  KEY `FK_prod_catg` (`id_catg`),
  KEY `FK_prod_area` (`id_areap`),
  CONSTRAINT `FK_prod_area` FOREIGN KEY (`id_areap`) REFERENCES `tm_area_prod` (`id_areap`),
  CONSTRAINT `FK_prod_catg` FOREIGN KEY (`id_catg`) REFERENCES `tm_producto_catg` (`id_catg`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_producto: ~4 rows (aproximadamente)
DELETE FROM `tm_producto`;
INSERT INTO `tm_producto` (`id_prod`, `id_tipo`, `id_catg`, `id_areap`, `nombre`, `notas`, `descripcion`, `delivery`, `estado`, `cod_pro`) VALUES
	(1, 1, 2, 1, 'POLLOS BRASA', '', NULL, 0, 'a', ''),
	(2, 1, 3, 1, 'ENTRADAS', '', NULL, 0, 'a', ''),
	(3, 1, 3, 1, 'CEVICHES', '', NULL, 1, 'a', ''),
	(4, 1, 4, 2, 'GASEOSAS', '', NULL, 0, 'a', '');

-- Volcando estructura para tabla factuyorest.tm_producto_catg
CREATE TABLE IF NOT EXISTS `tm_producto_catg` (
  `id_catg` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  `delivery` int(1) NOT NULL DEFAULT 0,
  `orden` int(11) NOT NULL DEFAULT 100,
  `imagen` varchar(200) NOT NULL DEFAULT 'default.png',
  `estado` varchar(1) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_catg`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_producto_catg: ~3 rows (aproximadamente)
DELETE FROM `tm_producto_catg`;
INSERT INTO `tm_producto_catg` (`id_catg`, `descripcion`, `delivery`, `orden`, `imagen`, `estado`) VALUES
	(1, 'COMBOS', 0, 0, 'default.png', 'a'),
	(2, 'POLLOS BRASA', 0, 100, 'default.png', 'a'),
	(3, 'PLATOS MARINOS', 1, 100, 'default.png', 'a'),
	(4, 'BEBIDAS', 0, 100, 'default.png', 'a');

-- Volcando estructura para tabla factuyorest.tm_producto_ingr
CREATE TABLE IF NOT EXISTS `tm_producto_ingr` (
  `id_pi` int(11) NOT NULL AUTO_INCREMENT,
  `id_pres` int(11) NOT NULL,
  `id_tipo_ins` int(11) NOT NULL,
  `id_ins` int(11) NOT NULL,
  `id_med` int(11) NOT NULL,
  `cant` float(10,6) NOT NULL,
  PRIMARY KEY (`id_pi`),
  KEY `FK_PING_PRES` (`id_pres`),
  KEY `FK_PING_INS` (`id_ins`),
  KEY `FK_PING_MED` (`id_med`),
  CONSTRAINT `FK_PING_MED` FOREIGN KEY (`id_med`) REFERENCES `tm_tipo_medida` (`id_med`),
  CONSTRAINT `FK_PING_PRES` FOREIGN KEY (`id_pres`) REFERENCES `tm_producto_pres` (`id_pres`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_producto_ingr: ~0 rows (aproximadamente)
DELETE FROM `tm_producto_ingr`;

-- Volcando estructura para tabla factuyorest.tm_producto_pres
CREATE TABLE IF NOT EXISTS `tm_producto_pres` (
  `id_pres` int(11) NOT NULL AUTO_INCREMENT,
  `id_prod` int(11) NOT NULL,
  `cod_prod` varchar(45) NOT NULL,
  `presentacion` mediumtext NOT NULL,
  `descripcion` mediumtext NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `precio2` decimal(10,2) NOT NULL,
  `precio_compra` decimal(10,2) NOT NULL DEFAULT 0.00,
  `precio_delivery` decimal(10,2) NOT NULL,
  `receta` int(1) NOT NULL,
  `stock_min` int(11) NOT NULL,
  `crt_stock` int(1) NOT NULL DEFAULT 0,
  `impuesto` int(1) NOT NULL,
  `impuesto_compra` int(11) NOT NULL DEFAULT 0,
  `impuesto_icbper` int(1) NOT NULL DEFAULT 0,
  `delivery` int(1) NOT NULL DEFAULT 0,
  `margen` int(11) NOT NULL DEFAULT 0,
  `igv` decimal(10,2) NOT NULL,
  `imagen` varchar(200) NOT NULL DEFAULT 'default.png',
  `ordenins` int(11) NOT NULL DEFAULT 1,
  `precios` text DEFAULT '[]',
  `favorito` int(1) NOT NULL DEFAULT 0,
  `estado` varchar(1) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_pres`),
  KEY `FK_PROP_PROD` (`id_prod`),
  CONSTRAINT `FK_PROP_PROD` FOREIGN KEY (`id_prod`) REFERENCES `tm_producto` (`id_prod`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Volcando datos para la tabla factuyorest.tm_producto_pres: ~8 rows (aproximadamente)
DELETE FROM `tm_producto_pres`;
INSERT INTO `tm_producto_pres` (`id_pres`, `id_prod`, `cod_prod`, `presentacion`, `descripcion`, `precio`, `precio2`, `precio_compra`, `precio_delivery`, `receta`, `stock_min`, `crt_stock`, `impuesto`, `impuesto_compra`, `impuesto_icbper`, `delivery`, `margen`, `igv`, `imagen`, `ordenins`, `precios`, `favorito`, `estado`) VALUES
	(1, 1, 'PO1/80', '1/8 PECHO CHAUF PAP O PLAT', '', 8.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0.10, 'default.png', 1, '[]', 0, 'a'),
	(2, 1, 'PO1/80', '1/8 PIERNA CHAUF PAP O PLAT', '', 7.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 18.00, 'default.png', 1, '[]', 0, 'a'),
	(3, 1, 'PO1 P0', '1 POLLO CHAUF PAP O PLAT', '', 60.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0.18, 'default.png', 1, '[]', 0, 'a'),
	(5, 2, 'ENLEC0', 'LECHE DE TIGRE', '', 10.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0.18, 'default.png', 1, '[]', 0, 'a'),
	(6, 2, 'ENCAU0', 'CAUSA DE POLLO', '', 10.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0.18, 'default.png', 1, '[]', 0, 'a'),
	(7, 3, 'CECEV0', 'CEVICHE SIMPLE', '', 18.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 1, 0, 0.18, 'default.png', 1, '[]', 0, 'a'),
	(8, 3, 'CECEV0', 'CEVICHE MIXTO', '', 25.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0.18, 'default.png', 1, '[]', 0, 'a'),
	(9, 4, 'GAINC0', 'INCA KOLA 500 ML', '', 5.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 18.00, 'default.png', 1, '[]', 0, 'a');

-- Volcando estructura para tabla factuyorest.tm_proveedor
CREATE TABLE IF NOT EXISTS `tm_proveedor` (
  `id_prov` int(11) NOT NULL AUTO_INCREMENT,
  `ruc` varchar(13) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `telefono` int(9) DEFAULT NULL,
  `email` varchar(45) DEFAULT NULL,
  `contacto` varchar(45) DEFAULT NULL,
  `estado` varchar(1) DEFAULT 'a',
  PRIMARY KEY (`id_prov`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_proveedor: ~0 rows (aproximadamente)
DELETE FROM `tm_proveedor`;

-- Volcando estructura para tabla factuyorest.tm_repartidor
CREATE TABLE IF NOT EXISTS `tm_repartidor` (
  `id_repartidor` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(100) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_repartidor`)
) ENGINE=InnoDB AUTO_INCREMENT=4446 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla factuyorest.tm_repartidor: ~4 rows (aproximadamente)
DELETE FROM `tm_repartidor`;
INSERT INTO `tm_repartidor` (`id_repartidor`, `descripcion`, `estado`) VALUES
	(1, 'INTERNO', 'a'),
	(2222, 'RAPPI', 'a'),
	(3333, 'UBER', 'a'),
	(4444, 'GLOVO', 'a');

-- Volcando estructura para tabla factuyorest.tm_rol
CREATE TABLE IF NOT EXISTS `tm_rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  PRIMARY KEY (`id_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_rol: ~7 rows (aproximadamente)
DELETE FROM `tm_rol`;
INSERT INTO `tm_rol` (`id_rol`, `descripcion`) VALUES
	(1, 'ADMINISTRATOR'),
	(2, 'ADMINISTRADOR'),
	(3, 'CAJERO'),
	(4, 'PRODUCCION'),
	(5, 'MOZO'),
	(6, 'REPARTIDOR'),
	(7, 'CONTADOR');

-- Volcando estructura para tabla factuyorest.tm_salon
CREATE TABLE IF NOT EXISTS `tm_salon` (
  `id_salon` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_salon`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_salon: ~2 rows (aproximadamente)
DELETE FROM `tm_salon`;
INSERT INTO `tm_salon` (`id_salon`, `descripcion`, `estado`) VALUES
	(1, 'PISO 1', 'a'),
	(2, 'BARRA', 'a');

-- Volcando estructura para tabla factuyorest.tm_tipo_compra
CREATE TABLE IF NOT EXISTS `tm_tipo_compra` (
  `id_tipo_compra` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  PRIMARY KEY (`id_tipo_compra`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_compra: ~2 rows (aproximadamente)
DELETE FROM `tm_tipo_compra`;
INSERT INTO `tm_tipo_compra` (`id_tipo_compra`, `descripcion`) VALUES
	(1, 'CONTADO'),
	(2, 'CREDITO');

-- Volcando estructura para tabla factuyorest.tm_tipo_doc
CREATE TABLE IF NOT EXISTS `tm_tipo_doc` (
  `id_tipo_doc` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  `serie` char(4) NOT NULL,
  `numero` varchar(8) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  `defecto` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_tipo_doc`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_doc: ~3 rows (aproximadamente)
DELETE FROM `tm_tipo_doc`;
INSERT INTO `tm_tipo_doc` (`id_tipo_doc`, `descripcion`, `serie`, `numero`, `estado`, `defecto`) VALUES
	(1, 'BOLETA DE VENTA', 'B001', '00000001', 'a', 1),
	(2, 'FACTURA', 'F001', '00000001', 'a', 0),
	(3, 'NOTA DE VENTA', 'NV01', '00000001', 'a', 0);

-- Volcando estructura para tabla factuyorest.tm_tipo_gasto
CREATE TABLE IF NOT EXISTS `tm_tipo_gasto` (
  `id_tipo_gasto` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  PRIMARY KEY (`id_tipo_gasto`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_gasto: ~4 rows (aproximadamente)
DELETE FROM `tm_tipo_gasto`;
INSERT INTO `tm_tipo_gasto` (`id_tipo_gasto`, `descripcion`) VALUES
	(1, 'POR COMPRAS'),
	(2, 'POR SREVICIOS'),
	(3, 'POR REMUNERACION'),
	(4, 'POR CREDITO DE COMPRAS');

-- Volcando estructura para tabla factuyorest.tm_tipo_medida
CREATE TABLE IF NOT EXISTS `tm_tipo_medida` (
  `id_med` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  `grupo` int(11) NOT NULL,
  PRIMARY KEY (`id_med`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_medida: ~8 rows (aproximadamente)
DELETE FROM `tm_tipo_medida`;
INSERT INTO `tm_tipo_medida` (`id_med`, `descripcion`, `grupo`) VALUES
	(1, 'UNIDAD', 1),
	(2, 'KILOS', 2),
	(3, 'GRAMOS', 2),
	(4, 'MILIGRAMOS', 2),
	(5, 'LITRO', 3),
	(6, 'MILILITRO', 3),
	(7, 'LIBRAS', 2),
	(8, 'ONZAS', 4);

-- Volcando estructura para tabla factuyorest.tm_tipo_pago
CREATE TABLE IF NOT EXISTS `tm_tipo_pago` (
  `id_tipo_pago` int(11) NOT NULL AUTO_INCREMENT,
  `id_pago` int(11) NOT NULL,
  `descripcion` varchar(45) NOT NULL,
  `estado` varchar(5) NOT NULL DEFAULT 'a',
  PRIMARY KEY (`id_tipo_pago`),
  KEY `FK_TIPODEPAGO` (`id_pago`),
  CONSTRAINT `FK_TIPODEPAGO` FOREIGN KEY (`id_pago`) REFERENCES `tm_pago` (`id_pago`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_pago: ~9 rows (aproximadamente)
DELETE FROM `tm_tipo_pago`;
INSERT INTO `tm_tipo_pago` (`id_tipo_pago`, `id_pago`, `descripcion`, `estado`) VALUES
	(1, 1, 'EFECTIVO', 'a'),
	(2, 2, 'TARJETA', 'a'),
	(3, 3, 'PAGO MIXTO', 'a'),
	(4, 4, 'CULQI', 'i'),
	(5, 5, 'YAPE', 'a'),
	(6, 5, 'LUKITA', 'a'),
	(7, 5, 'TRANSFERENCIA', 'a'),
	(8, 5, 'PLIN', 'a'),
	(9, 5, 'TUNKI', 'a');

-- Volcando estructura para tabla factuyorest.tm_tipo_pedido
CREATE TABLE IF NOT EXISTS `tm_tipo_pedido` (
  `id_tipo_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  PRIMARY KEY (`id_tipo_pedido`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_pedido: ~3 rows (aproximadamente)
DELETE FROM `tm_tipo_pedido`;
INSERT INTO `tm_tipo_pedido` (`id_tipo_pedido`, `descripcion`) VALUES
	(1, 'MESA'),
	(2, 'LLEVAR'),
	(3, 'DELIVERY');

-- Volcando estructura para tabla factuyorest.tm_tipo_venta
CREATE TABLE IF NOT EXISTS `tm_tipo_venta` (
  `id_tipo_venta` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  PRIMARY KEY (`id_tipo_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_tipo_venta: ~2 rows (aproximadamente)
DELETE FROM `tm_tipo_venta`;
INSERT INTO `tm_tipo_venta` (`id_tipo_venta`, `descripcion`) VALUES
	(1, 'CONTADO'),
	(2, 'CREDITO');

-- Volcando estructura para tabla factuyorest.tm_turno
CREATE TABLE IF NOT EXISTS `tm_turno` (
  `id_turno` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) NOT NULL,
  PRIMARY KEY (`id_turno`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_turno: ~2 rows (aproximadamente)
DELETE FROM `tm_turno`;
INSERT INTO `tm_turno` (`id_turno`, `descripcion`) VALUES
	(1, 'PRIMER TURNO'),
	(2, 'SEGUNDO TURNO');

-- Volcando estructura para tabla factuyorest.tm_usuario
CREATE TABLE IF NOT EXISTS `tm_usuario` (
  `id_usu` int(11) NOT NULL AUTO_INCREMENT,
  `id_rol` int(11) NOT NULL,
  `id_areap` int(11) NOT NULL,
  `dni` varchar(10) NOT NULL,
  `ape_paterno` varchar(45) DEFAULT NULL,
  `ape_materno` varchar(45) DEFAULT NULL,
  `nombres` varchar(45) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `usuario` varchar(45) DEFAULT NULL,
  `contrasena` varchar(45) DEFAULT 'cmVzdHBl',
  `estado` varchar(5) DEFAULT 'a',
  `imagen` varchar(45) DEFAULT NULL,
  `editarprecio` int(11) DEFAULT 0,
  `turno_ing` time DEFAULT NULL,
  `turno_sal` time DEFAULT NULL,
  PRIMARY KEY (`id_usu`),
  KEY `FKU_IDROL_idx` (`id_rol`),
  CONSTRAINT `FK_usu_rol` FOREIGN KEY (`id_rol`) REFERENCES `tm_rol` (`id_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_usuario: ~6 rows (aproximadamente)
DELETE FROM `tm_usuario`;
INSERT INTO `tm_usuario` (`id_usu`, `id_rol`, `id_areap`, `dni`, `ape_paterno`, `ape_materno`, `nombres`, `email`, `usuario`, `contrasena`, `estado`, `imagen`, `editarprecio`, `turno_ing`, `turno_sal`) VALUES
	(1, 1, 0, '45988786', 'Admin', 'Admin', 'Admin', 'administrador@gmail.com', 'Soporte', 'c29wb3J0ZTI0', 'a', '161117020710-avatar5.png', 1, NULL, NULL),
	(52, 2, 0, '12345678', 'ADMIN', 'ADMIN', 'ADMIN', 'admin@gmail.com', 'admin', 'YWRtaW4yMDI0', 'a', 'default-avatar.png', 0, NULL, NULL),
	(53, 6, 0, '12345698', 'REPARTIDOR', 'REPARTIDOR', 'REPARTIDOR', 'repartidos@gmail.com', 'reparto2', 'TG9yZXRvU29mdDIwMjMuLi4=', 'a', 'default-avatar.png', 0, NULL, NULL),
	(58, 5, 0, '78546840', 'MOZO', 'A', 'MOZO', 'mozo@gmail.com', '123456', 'MTIzNDU2', 'a', 'default-avatar.png', 0, NULL, NULL),
	(59, 4, 1, '45344148', 'MART', 'HART', 'JUAN', 'cocina1@gmail.com', 'cocina1', 'TG9yZXRvU29mdDIwMjMuLi4=', 'a', 'default-avatar.png', 0, NULL, NULL);

-- Volcando estructura para tabla factuyorest.tm_venta
CREATE TABLE IF NOT EXISTS `tm_venta` (
  `id_venta` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `id_tipo_pedido` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_tipo_doc` int(11) NOT NULL,
  `id_tipo_pago` int(11) NOT NULL,
  `id_usu` int(11) NOT NULL,
  `id_apc` int(11) NOT NULL,
  `serie_doc` char(4) NOT NULL,
  `nro_doc` int(8) unsigned zerofill NOT NULL,
  `pago_efe` decimal(10,2) DEFAULT 0.00,
  `pago_efe_none` decimal(10,2) DEFAULT 0.00,
  `pago_tar` decimal(10,2) DEFAULT 0.00,
  `pago_yape` decimal(10,2) DEFAULT 0.00,
  `pago_plin` decimal(10,2) DEFAULT 0.00,
  `pago_tran` decimal(10,2) DEFAULT 0.00,
  `descuento_tipo` char(1) NOT NULL DEFAULT '1',
  `descuento_personal` int(11) DEFAULT NULL,
  `descuento_monto` decimal(10,2) DEFAULT 0.00,
  `descuento_motivo` varchar(200) DEFAULT NULL,
  `comision_tarjeta` decimal(10,2) DEFAULT 0.00,
  `comision_delivery` decimal(10,2) DEFAULT 0.00,
  `icbper` decimal(10,2) NOT NULL DEFAULT 0.00,
  `igv` decimal(10,2) DEFAULT 0.00,
  `total` decimal(10,2) DEFAULT 0.00,
  `codigo_operacion` varchar(20) DEFAULT NULL,
  `fecha_venta` datetime DEFAULT NULL,
  `estado` varchar(15) DEFAULT 'a',
  `enviado_sunat` char(1) DEFAULT NULL,
  `code_respuesta_sunat` varchar(200) NOT NULL,
  `descripcion_sunat_cdr` varchar(300) NOT NULL,
  `name_file_sunat` varchar(80) NOT NULL,
  `hash_cdr` varchar(200) NOT NULL,
  `hash_cpe` varchar(200) NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `consumo` int(1) NOT NULL,
  `consumo_desc` text NOT NULL,
  `cambiomanual` int(1) NOT NULL DEFAULT 0,
  `observacion` text DEFAULT NULL,
  `nvoriginal` varchar(20) DEFAULT NULL,
  `nvfecha` date DEFAULT NULL,
  PRIMARY KEY (`id_venta`),
  UNIQUE KEY `venta_serie_num` (`serie_doc`,`nro_doc`) USING BTREE,
  KEY `FK_venta_cli` (`id_cliente`),
  KEY `FK_venta_td` (`id_tipo_doc`),
  KEY `FK_venta_tp` (`id_tipo_pago`),
  KEY `FK_venta_usu` (`id_usu`),
  KEY `FK_venta_apc` (`id_apc`),
  KEY `FK_venta_tpe` (`id_tipo_pedido`),
  CONSTRAINT `FK_venta_apc` FOREIGN KEY (`id_apc`) REFERENCES `tm_aper_cierre` (`id_apc`),
  CONSTRAINT `FK_venta_cli` FOREIGN KEY (`id_cliente`) REFERENCES `tm_cliente` (`id_cliente`),
  CONSTRAINT `FK_venta_td` FOREIGN KEY (`id_tipo_doc`) REFERENCES `tm_tipo_doc` (`id_tipo_doc`),
  CONSTRAINT `FK_venta_tp` FOREIGN KEY (`id_tipo_pago`) REFERENCES `tm_tipo_pago` (`id_tipo_pago`),
  CONSTRAINT `FK_venta_tpe` FOREIGN KEY (`id_tipo_pedido`) REFERENCES `tm_tipo_pedido` (`id_tipo_pedido`),
  CONSTRAINT `FK_venta_usu` FOREIGN KEY (`id_usu`) REFERENCES `tm_usuario` (`id_usu`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Volcando datos para la tabla factuyorest.tm_venta: ~13 rows (aproximadamente)
DELETE FROM `tm_venta`;
INSERT INTO `tm_venta` (`id_venta`, `id_pedido`, `id_tipo_pedido`, `id_cliente`, `id_tipo_doc`, `id_tipo_pago`, `id_usu`, `id_apc`, `serie_doc`, `nro_doc`, `pago_efe`, `pago_efe_none`, `pago_tar`, `pago_yape`, `pago_plin`, `pago_tran`, `descuento_tipo`, `descuento_personal`, `descuento_monto`, `descuento_motivo`, `comision_tarjeta`, `comision_delivery`, `icbper`, `igv`, `total`, `codigo_operacion`, `fecha_venta`, `estado`, `enviado_sunat`, `code_respuesta_sunat`, `descripcion_sunat_cdr`, `name_file_sunat`, `hash_cdr`, `hash_cpe`, `fecha_vencimiento`, `consumo`, `consumo_desc`, `cambiomanual`, `observacion`, `nvoriginal`, `nvfecha`) VALUES
	(2, 1, 1, 1, 1, 1, 1, 1, 'B001', 00000001, 16.00, 16.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 18.00, 16.00, '', '2024-03-31 21:09:35', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(3, 3, 2, 1, 1, 1, 1, 1, 'B001', 00000002, 26.00, 26.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 18.00, 26.00, '', '2024-03-31 22:35:15', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(4, 4, 1, 2, 2, 3, 1, 1, 'F001', 00000001, 20.00, 20.00, 15.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 18.00, 35.00, '', '2024-03-31 23:14:19', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(5, 2, 2, 1, 1, 1, 1, 1, 'B001', 00000003, 8.00, 8.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 8.00, '', '2024-04-01 00:29:44', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(6, 6, 3, 3, 1, 1, 1, 1, 'B001', 00000004, 13.00, 20.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 13.00, '', '2024-04-01 00:33:45', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(7, 7, 2, 1, 1, 1, 1, 1, 'B001', 00000005, 23.00, 23.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 23.00, '', '2024-04-01 00:40:25', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(8, 8, 1, 1, 1, 1, 1, 1, 'B001', 00000006, 13.00, 13.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 13.00, '', '2024-04-01 00:51:16', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(9, 9, 2, 1, 1, 1, 1, 1, 'B001', 00000007, 20.00, 20.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 20.00, '', '2024-04-01 00:52:07', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(10, 10, 2, 1, 1, 1, 1, 1, 'B001', 00000008, 8.00, 8.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 8.00, '', '2024-04-01 00:55:48', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(11, 11, 2, 1, 1, 3, 1, 1, 'B001', 00000009, 15.00, 15.00, 8.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 23.00, '', '2024-04-01 01:00:38', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(12, 12, 1, 1, 1, 3, 1, 1, 'B001', 00000010, 5.00, 10.00, 0.00, 20.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 25.00, '', '2024-04-01 01:01:34', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(13, 14, 2, 1, 1, 1, 1, 2, 'B001', 00000011, 33.00, 33.00, 0.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 33.00, '', '2024-04-01 01:26:05', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(14, 15, 2, 1, 1, 7, 1, 2, 'B001', 00000012, 0.00, 0.00, 28.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 28.00, 'VO1234', '2024-04-01 01:27:01', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL),
	(15, 16, 2, 1, 1, 5, 1, 2, 'B001', 00000013, 0.00, 0.00, 25.00, 0.00, 0.00, 0.00, '2', 0, 0.00, '', 0.00, 0.00, 0.00, 0.18, 25.00, 'OP 4597', '2024-04-01 01:27:47', 'a', NULL, '', '', '', '', '', '0000-00-00', 0, 'POR CONSUMO', 0, '', NULL, NULL);

-- Volcando estructura para procedimiento factuyorest.usp_cajaAperturar
DELIMITER //
CREATE PROCEDURE `usp_cajaAperturar`(IN `_flag` INT(11), IN `_id_usu` INT(11), IN `_id_caja` INT(11), IN `_id_turno` INT(11), IN `_fecha_aper` DATETIME, IN `_monto_aper` DECIMAL(10,2))
BEGIN
	DECLARE _filtro INT DEFAULT 1;
	
	IF _flag = 1 THEN
	
		SELECT COUNT(*) INTO _filtro FROM tm_aper_cierre WHERE (id_usu = _id_usu or id_caja = _id_caja) AND estado = 'a';
		
		IF _filtro = 0 THEN
			INSERT INTO tm_aper_cierre (id_usu,id_caja,id_turno,fecha_aper,monto_aper) VALUES (_id_usu, _id_caja, _id_turno, _fecha_aper, _monto_aper);
			
			SELECT @@IDENTITY INTO @id;
			
			SELECT @id AS id_apc, _filtro AS cod;
		ELSE
			SELECT _filtro AS cod;
		END IF;
		
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_cajaCerrar
DELIMITER //
CREATE PROCEDURE `usp_cajaCerrar`(IN `_flag` INT(11), IN `_id_apc` INT(11), IN `_fecha_cierre` DATETIME, IN `_monto_cierre` DECIMAL(10,2), IN `_monto_sistema` DECIMAL(10,2), IN `_stock_pollo` VARCHAR(11))
BEGIN
		DECLARE _filtro INT DEFAULT 0;
		DECLARE _id_usu INT DEFAULT 0;
		
		IF _flag = 1 THEN
		
			SELECT COUNT(*) INTO _filtro FROM tm_aper_cierre WHERE id_apc = _id_apc AND estado = 'a';
			SELECT id_usu INTO _id_usu FROM tm_aper_cierre WHERE id_apc = _id_apc AND estado = 'a';
			
			IF _filtro = 1 THEN
			
				UPDATE tm_aper_cierre SET fecha_cierre = _fecha_cierre, monto_cierre = _monto_cierre, monto_sistema = _monto_sistema, stock_pollo = _stock_pollo, estado = 'c' 
				WHERE id_apc = _id_apc;
				
				SELECT _filtro AS cod, _id_usu AS id_usu;
			ELSE
				SELECT _filtro AS cod, _id_usu AS id_usu;
			END IF;
		END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_comprasAnular
DELIMITER //
CREATE PROCEDURE `usp_comprasAnular`(IN `_flag` INT(11), IN `_id_compra` INT(11))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	if _flag = 1 then
	
		SELECT COUNT(*) INTO _filtro FROM tm_compra WHERE estado = 'a' AND id_compra = _id_compra;
		
		IF _filtro = 1 THEN
			UPDATE tm_compra SET estado = 'i' WHERE id_compra = _id_compra;
			DELETE FROM tm_inventario WHERE id_tipo_ope = 1 AND id_ope = _id_compra;
			SELECT _filtro AS cod;
		ELSE
			SELECT _filtro AS cod;
		END IF;
	end if;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_comprasCreditoCuotas
DELIMITER //
CREATE PROCEDURE `usp_comprasCreditoCuotas`(IN `_flag` INT(11), IN `_id_credito` INT(11), IN `_id_usu` INT(11), IN `_id_apc` INT(11), IN `_importe` DECIMAL(10,2), IN `_fecha` DATETIME, IN `_egreso` INT(11), IN `_monto_egreso` DECIMAL(10,2), IN `_monto_amortizado` DECIMAL(10,2), IN `_total_credito` DECIMAL(10,2))
BEGIN
	DECLARE tcuota DECIMAL(10,2) DEFAULT 0;
	DECLARE motivo VARCHAR(100);
	
	IF _flag = 1 THEN
	
		INSERT INTO tm_credito_detalle (id_credito,id_usu,importe,fecha,egreso)
		VALUES (_id_credito, _id_usu, _importe, _fecha, _egreso);
	
			IF (_egreso = 1) THEN
	
				SELECT v.desc_prov INTO @descP
				FROM v_compras AS v INNER JOIN tm_compra_credito AS c ON v.id_compra = c.id_compra
				WHERE c.id_credito = _id_credito;
		
			SET motivo = @descP;
		
				INSERT INTO tm_gastos_adm (id_tipo_gasto,id_usu,id_apc,importe,motivo,fecha_registro)
				VALUES (4,_id_usu,_id_apc,_monto_egreso,motivo,_fecha);
	
			END IF;
	
		SET tcuota = _monto_amortizado + _importe;
	
		IF ( _total_credito <= tcuota ) THEN
	
			UPDATE tm_compra_credito SET estado = 'a' WHERE id_credito = _id_credito;
	
		END IF;
	
	END IF;
	
END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_comprasRegProveedor
DELIMITER //
CREATE PROCEDURE `usp_comprasRegProveedor`(IN `_flag` INT(11), IN `_id_prov` INT(11), IN `_ruc` VARCHAR(13), IN `_razon_social` VARCHAR(100), IN `_direccion` VARCHAR(100), IN `_telefono` INT(9), IN `_email` VARCHAR(45), IN `_contacto` VARCHAR(45))
BEGIN
		DECLARE _filtro INT DEFAULT 1;
		
		IF _flag = 1 THEN
		
			SELECT count(*) INTO _filtro FROM tm_proveedor WHERE ruc = _ruc;
		
			IF _filtro = 0 THEN
			
				INSERT INTO tm_proveedor (ruc,razon_social,direccion,telefono,email,contacto) 
				VALUES (_ruc, _razon_social, _direccion, _telefono, _email, _contacto);
				
				SELECT @@IDENTITY INTO @id;
			
				SELECT _filtro AS cod,@id AS id_prov;
			ELSE
				SELECT _filtro AS cod;
			END IF;	
			
		END IF;
		
		if _flag = 2 then
		
			UPDATE tm_proveedor SET ruc = _ruc, razon_social = _razon_social, direccion = _direccion, telefono = _telefono, email = _email, contacto = _contacto
			WHERE id_prov = _id_prov;
			
		end if;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configAlmacenes
DELIMITER //
CREATE PROCEDURE `usp_configAlmacenes`(IN `_flag` INT(11), IN `_nombre` VARCHAR(45), IN `_estado` VARCHAR(5), IN `_idAlm` INT(11))
BEGIN
	DECLARE _cont INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
		SELECT COUNT(*) INTO _cont FROM tm_almacen WHERE nombre = _nombre;
	
		IF _cont = 0 THEN
			INSERT INTO tm_almacen (nombre,estado) VALUES (_nombre, _estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	END IF;
	
	IF _flag = 2 THEN
		SELECT COUNT(*) INTO _cont FROM tm_almacen WHERE nombre = _nombre AND estado = _estado;
	
		IF _cont = 0 THEN
			UPDATE tm_almacen SET nombre = _nombre, estado = _estado WHERE id_alm = _idAlm;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configAreasProd
DELIMITER //
CREATE PROCEDURE `usp_configAreasProd`(IN `_flag` INT(11), IN `_id_areap` INT(11), IN `_id_imp` INT(11), IN `_nombre` VARCHAR(45), IN `_estado` VARCHAR(5))
BEGIN
	DECLARE _cont INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
		SELECT COUNT(*) INTO _cont FROM tm_area_prod WHERE nombre = _nombre;
	
		IF _cont = 0 THEN
			INSERT INTO tm_area_prod (id_imp,nombre,estado) VALUES (_id_imp, _nombre, _estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	END IF;
	
	IF _flag = 2 THEN
		SELECT COUNT(*) INTO _cont FROM tm_area_prod WHERE id_imp = _id_imp AND nombre = _nombre AND estado = _estado;
	
		IF _cont = 0 THEN
			UPDATE tm_area_prod SET id_imp = _id_imp, nombre = _nombre, estado = _estado WHERE id_areap = _id_areap;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configCajas
DELIMITER //
CREATE PROCEDURE `usp_configCajas`(IN `_flag` INT(11), IN `_id_caja` INT(11), IN `_descripcion` VARCHAR(45), IN `_estado` VARCHAR(5))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
		SELECT COUNT(*) INTO _filtro FROM tm_caja WHERE descripcion = _descripcion;
	
		IF _filtro = 0 THEN
			INSERT INTO tm_caja (descripcion,estado) VALUES (_descripcion, _estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	END IF;
	
	IF _flag = 2 THEN
	
		SELECT COUNT(*) INTO _filtro FROM tm_caja WHERE descripcion = _descripcion AND estado = _estado;
	
		IF _filtro = 0 THEN
			UPDATE tm_caja SET descripcion = _descripcion, estado = _estado WHERE id_caja = _id_caja;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configEliminarCategoriaIns
DELIMITER //
CREATE PROCEDURE `usp_configEliminarCategoriaIns`(IN `_id_catg` INT(11))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	
	SELECT COUNT(*) INTO _filtro FROM tm_insumo WHERE id_catg = _id_catg;
	IF _filtro = 0 THEN
		DELETE FROM tm_insumo_catg WHERE id_catg = _id_catg;
		SELECT _cod1 AS cod;
	ELSE
		SELECT _cod0 AS cod;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configEliminarCategoriaProd
DELIMITER //
CREATE PROCEDURE `usp_configEliminarCategoriaProd`(IN `_id_catg` INT(11))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	
	SELECT COUNT(*) INTO _filtro FROM tm_producto WHERE id_catg = _id_catg;
	IF _filtro = 0 THEN
		DELETE FROM tm_producto_catg WHERE id_catg = _id_catg;
		SELECT _cod1 AS cod;
	ELSE
		SELECT _cod0 AS cod;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configImpresoras
DELIMITER //
CREATE PROCEDURE `usp_configImpresoras`(IN `_flag` INT(11), IN `_id_imp` INT(11), IN `_nombre` VARCHAR(50), IN `_estado` VARCHAR(5))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
		SELECT COUNT(*) INTO _filtro FROM tm_impresora WHERE nombre = _nombre;
	
		IF _filtro = 0 THEN
			INSERT INTO tm_impresora (nombre,estado) VALUES (_nombre,_estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	END IF;
	
	IF _flag = 2 THEN
		SELECT COUNT(*) INTO _filtro FROM tm_impresora WHERE nombre = _nombre AND estado = _estado;
	
		IF _filtro = 0 THEN
			UPDATE tm_impresora SET nombre = _nombre, estado = _estado WHERE id_imp = _id_imp;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configInsumo
DELIMITER //
CREATE PROCEDURE `usp_configInsumo`(IN `_flag` INT(11), IN `_idCatg` INT(11), IN `_idMed` INT(11), IN `_cod` VARCHAR(10), IN `_nombre` VARCHAR(45), IN `_stock` INT(11), IN `_costo` DECIMAL(10,2), IN `_estado` VARCHAR(5), IN `_idIns` INT(11))
BEGIN
	DECLARE _cont INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_insumo WHERE nomb_ins = _nombre and cod_ins = _cod and id_catg = _idCatg;
	
		IF _cont = 0 THEN
			INSERT INTO tm_insumo (id_catg,id_med,cod_ins,nomb_ins,stock_min,cos_uni) VALUES ( _idCatg, _idMed, _cod, _nombre, _stock, _costo);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
		
	END IF;
	
	IF _flag = 2 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_insumo WHERE id_catg = _idCatg AND id_med = _idMed AND cod_ins = _cod AND nomb_ins = _nombre AND stock_min = _stock AND cos_uni = _costo AND estado = _estado;
	
		IF _cont = 0 THEN
			UPDATE tm_insumo SET id_catg = _idCatg, id_med = _idMed, cod_ins = _cod, nomb_ins = _nombre, stock_min = _stock, cos_uni = _costo, estado = _estado WHERE id_ins = _idIns;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configInsumoCatgs
DELIMITER //
CREATE PROCEDURE `usp_configInsumoCatgs`(IN `_flag` INT(11), IN `_descC` VARCHAR(45), IN `_idCatg` INT(11))
BEGIN
	DECLARE _cont INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_insumo_catg WHERE descripcion = _descC;
		
		IF _cont = 0 THEN
			INSERT INTO tm_insumo_catg (descripcion) VALUES (_descC);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	
	END IF;
	
	IF _flag = 2 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_insumo_catg WHERE descripcion = _descC;
		
		IF _cont = 0 THEN
			UPDATE tm_insumo_catg SET descripcion = _descC WHERE id_catg = _idCatg;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configMesas
DELIMITER //
CREATE PROCEDURE `usp_configMesas`(IN `_flag` INT(11), IN `_id_mesa` INT(11), IN `_id_salon` INT(11), IN `_nro_mesa` VARCHAR(5), IN `_forma` INT(11), IN `_estado` VARCHAR(45))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
	
		-- SELECT COUNT(*) INTO _filtro FROM tm_mesa WHERE id_salon = _id_salon AND nro_mesa = _nro_mesa COLLATE utf8_unicode_ci ;
	
		-- IF _filtro = 0 THEN
			INSERT INTO tm_mesa (id_salon,nro_mesa,forma) VALUES (_id_salon, _nro_mesa, _forma);
			SELECT _cod1 AS cod;
		-- ELSE
		-- 	SELECT _cod0 AS cod;
		-- END IF;
	
	end if;
	
	IF _flag = 2 THEN

		-- SELECT COUNT(*) INTO _filtro FROM tm_mesa WHERE id_salon = _id_salon AND nro_mesa = _nro_mesa AND estado = _estado AND  forma  COLLATE utf8_unicode_ci = _forma  COLLATE utf8_unicode_ci;

		-- IF _filtro = 0 THEN

			UPDATE tm_mesa SET nro_mesa = _nro_mesa,  forma = _forma, estado = _estado WHERE id_mesa = _id_mesa;

			SELECT _cod2 AS cod;

		-- ELSE

		-- 	SELECT _cod2 AS cod;

		-- END IF;
	
	END IF;
	
	IF _flag = 3 THEN
	
		SELECT count(*) INTO _filtro FROM tm_pedido_mesa WHERE id_mesa = _id_mesa;
	
		IF _filtro = 0 THEN
			DELETE FROM tm_mesa WHERE id_mesa = _id_mesa;
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configProducto
DELIMITER //
CREATE PROCEDURE `usp_configProducto`(IN `_flag` INT(11), IN `_id_prod` INT(11), IN `_id_tipo` INT(11), IN `_id_catg` INT(11), IN `_id_areap` INT(11), IN `_nombre` VARCHAR(45), IN `_notas` VARCHAR(200), IN `_delivery` INT(1), IN `_estado` VARCHAR(1))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
		SELECT COUNT(*) INTO _filtro FROM tm_producto WHERE id_tipo = _id_tipo AND id_catg = _id_catg AND id_areap = _id_areap AND nombre = _nombre;
		IF _filtro = 0 THEN
			INSERT INTO tm_producto (id_tipo,id_catg,id_areap,nombre,notas,delivery) 
			VALUES ( _id_tipo, _id_catg, _id_areap, _nombre, _notas, _delivery);
			SELECT _cod1 AS cod;
		else
			SELECT _cod0 AS cod;
		end if;
	end if;
	
	if _flag = 2 then
		SELECT COUNT(*) INTO _filtro FROM tm_producto WHERE id_tipo = _id_tipo AND id_catg = _id_catg AND id_areap = _id_areap AND nombre = _nombre AND notas = _notas AND delivery = _delivery and estado = _estado;
		IF _filtro = 0 THEN
			UPDATE tm_producto SET id_tipo = _id_tipo, id_catg = _id_catg, id_areap = _id_areap, nombre = _nombre, notas = _notas, delivery = _delivery, estado = _estado 
			WHERE id_prod = _id_prod;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	end if;
	
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configProductoCatgs
DELIMITER //
CREATE PROCEDURE `usp_configProductoCatgs`(IN `_flag` INT(11), IN `_id_catg` INT(11), IN `_descripcion` VARCHAR(45), IN `_delivery` INT(1), IN `_orden` INT(11), IN `_imagen` VARCHAR(200), IN `_estado` VARCHAR(1))
BEGIN	
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN	
		
		SELECT COUNT(*) INTO _filtro FROM tm_producto_catg WHERE descripcion = _descripcion;
		IF _filtro = 0 THEN
			INSERT INTO tm_producto_catg (descripcion,delivery,orden,imagen,estado) VALUES (_descripcion,_delivery,100,_imagen,_estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	end if;
		
	IF _flag = 2 THEN
		SELECT COUNT(*) INTO _filtro FROM tm_producto_catg WHERE descripcion = _descripcion and delivery = _delivery and orden = _orden AND imagen = _imagen AND estado = _estado;
		IF _filtro = 0 THEN
			UPDATE tm_producto_catg SET descripcion = _descripcion, delivery = _delivery, orden =_orden, imagen = _imagen, estado = _estado WHERE id_catg = _id_catg;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	END IF;
	
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configProductoIngrs
DELIMITER //
CREATE PROCEDURE `usp_configProductoIngrs`(IN `_flag` INT(11), IN `_id_pi` INT(11), IN `_id_pres` INT(11), IN `_id_tipo_ins` INT(11), IN `_id_ins` INT(11), IN `_id_med` INT(11), IN `_cant` FLOAT)
BEGIN
	if _flag = 1 then
		INSERT INTO tm_producto_ingr (id_pres,id_tipo_ins,id_ins,id_med,cant) VALUES (_id_pres, _id_tipo_ins, _id_ins, _id_med, _cant);
	end if;
	if _flag = 2 then
		UPDATE tm_producto_ingr SET cant = _cant WHERE id_pi = _id_pi;
	end if;
	if _flag = 3 then
		DELETE FROM tm_producto_ingr WHERE id_pi = _id_pi;
	end if;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configProductoPres
DELIMITER //
CREATE PROCEDURE `usp_configProductoPres`(IN `_flag` INT(11), IN `_id_pres` INT(11), IN `_id_prod` INT(11), IN `_cod_prod` VARCHAR(45), IN `_presentacion` VARCHAR(45), IN `_descripcion` VARCHAR(200), IN `_precio` DECIMAL(10,2), IN `_precio2` DECIMAL(10,2), IN `_precio_delivery` DECIMAL(10,2), IN `_receta` INT(1), IN `_stock_min` INT(11), IN `_stock_limit` INT(1), IN `_impuesto` INT(1), IN `_impuesto_icbper` INT(1), IN `_delivery` INT(1), IN `_margen` INT(1), IN `_igv` DECIMAL(10,2), IN `_imagen` VARCHAR(200), IN `_ordenins` INT(11), IN `_favorito` INT(11), IN `_estado` VARCHAR(1))
BEGIN
		
	DECLARE _cont INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	IF _flag = 1 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_producto_pres WHERE presentacion = _presentacion AND id_prod = _id_prod;
		
		IF _cont = 0 THEN
			INSERT INTO tm_producto_pres (id_prod,cod_prod,presentacion,descripcion,precio,precio2,precio_delivery,receta,stock_min,crt_stock,impuesto,impuesto_icbper,delivery,margen,igv,imagen,ordenins,favorito,estado) 
			VALUES (_id_prod, _cod_prod, _presentacion, _descripcion, _precio, _precio2, _precio_delivery, _receta, _stock_min, _stock_limit, _impuesto, _impuesto_icbper, _delivery, _margen, _igv, _imagen, _ordenins, _favorito, _estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
		
	end if;
	
	IF _flag = 2 THEN
	
		UPDATE tm_producto_pres SET cod_prod = _cod_prod, presentacion = _presentacion, descripcion = _descripcion, precio = _precio, precio2 = _precio2, precio_delivery = _precio_delivery, receta = _receta, stock_min = _stock_min, crt_stock = _stock_limit, impuesto = _impuesto, impuesto_icbper = _impuesto_icbper, delivery = _delivery, margen = _margen, igv = _igv, imagen = _imagen, ordenins = _ordenins, favorito = _favorito, estado = _estado 
		WHERE id_pres = _id_pres;
		SELECT _cod2 AS cod;
		
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configRol
DELIMITER //
CREATE PROCEDURE `usp_configRol`(IN `_flag` INT(11), IN `_desc` VARCHAR(45), IN `_idRol` INT(11))
BEGIN
		DECLARE _duplicado INT DEFAULT 1;
		
		IF _flag = 1 THEN
		
				SELECT count(*) INTO _duplicado FROM tm_rol WHERE descripcion = _desc;
			
			IF _duplicado = 0 THEN
				INSERT INTO tm_rol (descripcion) VALUES (_desc);
				
				SELECT _duplicado AS dup;
			ELSE
				SELECT _duplicado AS dup;
			END IF;
		
		end if;
		
		IF _flag = 2 THEN
		
				SELECT COUNT(*) INTO _duplicado FROM tm_rol WHERE descripcion = _desc;
			
			IF _duplicado = 0 THEN
				UPDATE tm_rol SET descripcion = _desc WHERE id_rol = _idRol;
				
				SELECT _duplicado AS dup;
			ELSE
				SELECT _duplicado AS dup;
			END IF;
		
		END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configSalones
DELIMITER //
CREATE PROCEDURE `usp_configSalones`(IN `_flag` INT(11), IN `_id_salon` INT(11), IN `_descripcion` VARCHAR(45), IN `_estado` VARCHAR(5))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _filtro2 INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	
	IF _flag = 1 THEN
	
		SELECT COUNT(*) INTO _filtro FROM tm_salon WHERE descripcion = _descripcion AND estado = _estado;
	
		IF _filtro = 0 THEN
			INSERT INTO tm_salon (descripcion,estado) VALUES (_descripcion,_estado);
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	
	end if;
	
	IF _flag = 2 THEN
	
		SELECT COUNT(*) INTO _filtro FROM tm_salon WHERE descripcion = _descripcion AND estado = _estado;
	
		IF _filtro = 0 THEN
			UPDATE tm_salon SET descripcion = _descripcion, estado = _estado WHERE id_salon = _id_salon;
			SELECT _cod2 AS cod;
		ELSE
			SELECT _cod2 AS cod;
		END IF;
	
	END IF;
	
	IF _flag = 3 THEN
	
		SELECT count(*) INTO _filtro FROM tm_mesa WHERE id_salon = _id_salon;
	
		IF _filtro = 0 THEn
			
			SELECT COUNT(*) AS _filtro2 FROM tm_salon;
			
			if _filtro2 = 1 then
			
				DELETE FROM tm_salon WHERE id_salon = _id_salon;
				ALTER TABLE tm_salon AUTO_INCREMENT = 1;
				SELECT _cod1 AS cod;
			
			else 
		
				DELETE FROM tm_salon WHERE id_salon = _id_salon;
				SELECT _cod1 AS cod;
	
			end if;		
			
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_configUsuario
DELIMITER //
CREATE PROCEDURE `usp_configUsuario`(IN `_flag` INT(11), IN `_id_usu` INT(11), IN `_id_rol` INT(11), IN `_id_areap` INT(11), IN `_dni` VARCHAR(10), IN `_ape_paterno` VARCHAR(45), IN `_ape_materno` VARCHAR(45), IN `_nombres` VARCHAR(45), IN `_email` VARCHAR(100), IN `_usuario` VARCHAR(45), IN `_contrasena` VARCHAR(45), IN `_imagen` VARCHAR(45), IN `_editarprecio` INT(11), IN `_turno_ing` VARCHAR(45), IN `_turno_sal` VARCHAR(45))
BEGIN

		DECLARE _filtro INT DEFAULT 1;

		

		IF _flag = 1 THEN

		

			SELECT count(*) INTO _filtro FROM tm_usuario WHERE usuario = _usuario;

		

			IF _filtro = 0 THEN

			

				INSERT INTO tm_usuario (id_rol,id_areap,dni,ape_paterno,ape_materno,nombres,email,usuario,contrasena,imagen,editarprecio,turno_ing,turno_sal) 

				VALUES (_id_rol,_id_areap,_dni,_ape_paterno,_ape_materno,_nombres,_email,_usuario,_contrasena,_imagen,_editarprecio,_turno_ing,_turno_sal);

				

				SELECT _filtro AS cod;

			ELSE

				SELECT _filtro AS cod;

			END IF;

		

		end if;

		

		IF _flag = 2 THEN

			UPDATE tm_usuario SET id_rol = _id_rol, id_areap = _id_areap, dni = _dni, ape_paterno = _ape_paterno, ape_materno = _ape_materno, nombres = _nombres, email = _email, usuario = _usuario, contrasena = _contrasena, imagen = _imagen, editarprecio = _editarprecio, turno_ing = _turno_ing, turno_sal = _turno_sal

			WHERE id_usu = _id_usu;

		END IF;

	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_invESAnular
DELIMITER //
CREATE PROCEDURE `usp_invESAnular`(IN `_flag` INT(11), IN `_id_es` INT(11), IN `_id_tipo` INT(11))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	IF _flag = 1 THEN
	
		SELECT COUNT(*) INTO _filtro FROM tm_inventario_entsal WHERE estado = 'a' AND id_es = _id_es;
		
		IF _filtro = 1 THEN
			UPDATE tm_inventario_entsal SET estado = 'i' WHERE id_es = _id_es;
			UPDATE tm_inventario SET estado = 'i' WHERE id_tipo_ope = _id_tipo AND id_ope = _id_es;
			SELECT _filtro AS cod;
		ELSE
			SELECT _filtro AS cod;
		END IF;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_optPedidos
DELIMITER //
CREATE PROCEDURE `usp_optPedidos`(IN `_flag` INT(11))
BEGIN
	DECLARE _cont INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	
	IF _flag = 1 THEN
	
		/*SELECT COUNT(*) AS cod FROM tm_aper_cierre WHERE estado = 'a';*/
		
		IF _cont = 0 THEN
			DELETE FROM tm_detalle_pedido;
			UPDATE tm_pedido SET estado = 'z' WHERE estado = 'a';
			/*mostrador*/
			UPDATE tm_pedido SET estado = 'd' WHERE estado = 'b' AND id_tipo_pedido = 2;
			/*delivery*/
			UPDATE tm_pedido SET estado = 'd' WHERE estado = 'c' AND id_tipo_pedido = 3;
			UPDATE tm_pedido SET estado = 'z' WHERE estado = 'b' AND id_tipo_pedido = 3;
			UPDATE tm_mesa SET estado = 'a';
			SELECT _cod1 AS cod;
            DELETE FROM tm_comandas;	
		ELSE
			SELECT _cod0 AS cod;
		END IF;
	
	END IF;
	
	IF _flag = 2 THEN
	
		DELETE FROM tm_detalle_pedido;
		DELETE FROM tm_pedido_mesa;
		DELETE FROM tm_pedido_llevar;
		DELETE FROM tm_pedido_delivery;
		DELETE FROM tm_pedido;
		ALTER TABLE tm_pedido AUTO_INCREMENT = 1;
		DELETE FROM tm_compra_detalle;
		DELETE FROM tm_credito_detalle;
		DELETE FROM tm_compra_credito;
		ALTER TABLE tm_compra_credito AUTO_INCREMENT = 1;
		DELETE FROM tm_compra;
		ALTER TABLE tm_compra AUTO_INCREMENT = 1;
		DELETE FROM tm_gastos_adm;
		ALTER TABLE tm_gastos_adm AUTO_INCREMENT = 1;
		DELETE FROM tm_ingresos_adm;
		ALTER TABLE tm_ingresos_adm AUTO_INCREMENT = 1;
		DELETE FROM tm_detalle_venta;
		DELETE FROM comunicacion_baja;
		ALTER TABLE comunicacion_baja AUTO_INCREMENT = 1;
		DELETE FROM resumen_diario_detalle;
		ALTER TABLE resumen_diario_detalle AUTO_INCREMENT = 1;
		DELETE FROM resumen_diario;
		ALTER TABLE resumen_diario AUTO_INCREMENT = 1;			
		DELETE FROM tm_venta;
		ALTER TABLE tm_venta AUTO_INCREMENT = 1;
		DELETE FROM tm_aper_cierre;
		ALTER TABLE tm_aper_cierre AUTO_INCREMENT = 1;
		DELETE FROM tm_inventario_entsal;
		ALTER TABLE tm_inventario_entsal AUTO_INCREMENT = 1;
		DELETE FROM tm_inventario;
		ALTER TABLE tm_inventario AUTO_INCREMENT = 1;
		UPDATE tm_mesa SET estado = 'a' WHERE estado <> 'm';
        /* contador comensales */
		DELETE FROM tm_comandas;
		SELECT _cod1 AS cod;
		
	END IF;
	
	IF _flag = 3 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_detalle_venta;
		
		IF _cont = 0 THEN
			DELETE FROM tm_producto_ingr;
			ALTER TABLE tm_producto_ingr AUTO_INCREMENT = 1;
			DELETE FROM tm_producto_pres;
			ALTER TABLE tm_producto_pres AUTO_INCREMENT = 1;
			DELETE FROM tm_producto;
			ALTER TABLE tm_producto AUTO_INCREMENT = 1;
			DELETE FROM tm_producto_catg WHERE id_catg <> 1;
			ALTER TABLE tm_producto_catg AUTO_INCREMENT = 1;
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
		
	END IF;
	
	IF _flag = 4 THEN
	
		SELECT COUNT(*) INTO _cont FROM tm_producto_ingr;
		
		IF _cont = 0 THEN
			DELETE FROM tm_insumo;
			ALTER TABLE tm_insumo AUTO_INCREMENT = 1;
			DELETE FROM tm_insumo_catg;
			ALTER TABLE tm_insumo_catg AUTO_INCREMENT = 1;
			SELECT _cod1 AS cod;
		ELSE
			SELECT _cod0 AS cod;
		END IF;
		
	END IF;
	
	IF _flag = 5 THEN
	
		DELETE FROM tm_cliente where id_cliente <> 1;
		ALTER TABLE tm_cliente AUTO_INCREMENT = 2;
		SELECT _cod1 AS cod;
		
	END IF;
	
	IF _flag = 6 THEN
	
		DELETE FROM tm_proveedor;
		ALTER TABLE tm_proveedor AUTO_INCREMENT = 1;
		SELECT _cod1 AS cod;
		
	END IF;
	
	IF _flag = 7 THEN
	
		DELETE FROM tm_mesa;
		ALTER TABLE tm_mesa AUTO_INCREMENT = 1;
		DELETE FROM tm_salon;
		ALTER TABLE tm_salon AUTO_INCREMENT = 1;
		SELECT _cod1 AS cod;
		
	END IF;
	
	IF _flag = 8 THEN
	
		TRUNCATE TABLE tm_inventario;
		TRUNCATE TABLE tm_inventario_entsal;
		SELECT _cod1 AS cod;
		
	END IF;
			
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restCancelarPedido
DELIMITER //
CREATE PROCEDURE `usp_restCancelarPedido`(IN `_flag` INT(11), IN `_id_usu` INT(11), IN `_id_pres` INT(11), IN `_id_pedido` INT(11), IN `_estado_pedido` VARCHAR(5), IN `_fecha_pedido` DATETIME, IN `_fecha_envio` DATETIME, IN `_codigo_seguridad` VARCHAR(50), IN `_filtro_seguridad` VARCHAR(50))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	DECLARE _cod0 INT DEFAULT 0;
	DECLARE	_cod1 INT DEFAULT 1;
	DECLARE	_cod2 INT DEFAULT 2;
	DECLARE _fecha_envio datetime;
	
	IF _flag = 1 THEN
		/*
		SELECT COUNT(*) INTO _filtro FROM tm_detalle_pedido WHERE id_pedido = _id_pedido AND id_pres = _id_pres AND fecha_pedido = _fecha_pedido AND (_estado_pedido = 'a' OR _estado_pedido = 'y');
		*/
		iF _estado_pedido = 'a' or _estado_pedido = 'y' THEN		
			if _codigo_seguridad = _filtro_seguridad then
				UPDATE tm_detalle_pedido SET estado = 'z', id_usu = _id_usu, fecha_envio = _fecha_envio WHERE id_pedido = _id_pedido AND id_pres = _id_pres AND fecha_pedido = _fecha_pedido AND estado = _estado_pedido LIMIT 1;
				SELECT _cod1 AS cod;			
			else
				SELECT _cod0 AS cod;
			end if;			
		ELSE
			SELECT _cod2 AS cod;
		END IF;	
	END IF;
	
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restDesocuparMesa
DELIMITER //
CREATE PROCEDURE `usp_restDesocuparMesa`(`_flag` INT(11), `_id_pedido` INT(11))
BEGIN
	DECLARE result INT DEFAULT 1;
	IF _flag = 1 THEN
		SELECT id_mesa INTO @codmesa FROM tm_pedido_mesa WHERE id_pedido = _id_pedido;
		UPDATE tm_mesa SET estado = 'a' WHERE id_mesa = @codmesa;
		UPDATE tm_pedido SET estado = 'z' WHERE id_pedido = _id_pedido;
		SELECT result AS resultado;
	END IF;
END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restEditarVentaDocumento
DELIMITER //
CREATE PROCEDURE `usp_restEditarVentaDocumento`(`_flag` INT(11), `_id_venta` INT(11), `_id_cliente` INT(11), `_id_tipo_documento` INT(11))
BEGIN
	DECLARE _cod INT DEFAULT 1;
	 
	IF _flag = 1 THEN
		SELECT td.serie,CONCAT(LPAD(COUNT(id_venta)+(td.numero),8,'0')) AS numero INTO @serie, @numero
		FROM tm_venta AS v INNER JOIN tm_tipo_doc AS td ON v.id_tipo_doc = td.id_tipo_doc
		WHERE v.id_tipo_doc = _id_tipo_documento AND v.serie_doc = td.serie;
		UPDATE tm_venta SET id_cliente = _id_cliente, id_tipo_doc = _id_tipo_documento, serie_doc = @serie, nro_doc = @numero WHERE id_venta = _id_venta;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restEmitirVenta
DELIMITER //
CREATE PROCEDURE `usp_restEmitirVenta`(`_flag` INT(11), `_dividir_cuenta` INT(11), `_id_pedido` INT(11), `_tipo_pedido` INT(11), `_tipo_entrega` VARCHAR(1), `_id_cliente` INT(11), `_id_tipo_doc` INT(11), `_id_tipo_pago` INT(11), `_id_usu` INT(11), `_id_apc` INT(11), `_pago_efe_none` DECIMAL(10,2), `_pago_tar` DECIMAL(10,2), `_pago_yape` DECIMAL(10,2), `_pago_plin` DECIMAL(10,2), `_pago_tran` DECIMAL(10,2), `_descuento_tipo` CHAR(1), `_descuento_personal` INT(11), `_descuento_monto` DECIMAL(10,2), `_descuento_motivo` VARCHAR(200), `_comision_tarjeta` DECIMAL(10,2), `_comision_delivery` DECIMAL(10,2), `_igv` DECIMAL(10,2), `_total` DECIMAL(10,2), `_codigo_operacion` VARCHAR(20), `_fecha_venta` DATETIME)
BEGIN
	DECLARE pago_efe DECIMAL(10,2) DEFAULT 0;
	DECLARE pago_tar DECIMAL(10,2) DEFAULT 0;
	DECLARE pago_yape DECIMAL(10,2) DEFAULT 0;
	DECLARE pago_plin DECIMAL(10,2) DEFAULT 0;
	DECLARE pago_tran DECIMAL(10,2) DEFAULT 0;

	if (_descuento_tipo = 1 or _descuento_tipo = 3) then
		SET pago_efe = 0;
		SET pago_tar = 0;
		SET pago_yape = 0;
		SET pago_plin = 0;
		SET pago_tran = 0;
	else 
		IF _id_tipo_pago = 1 THEN
			SET pago_efe = ( _total + _comision_delivery - _descuento_monto);
			SET pago_tar = 0;
			SET pago_yape = 0;
			SET pago_plin = 0;
			SET pago_tran = 0;
		ELSEIF _id_tipo_pago = 2 THEN
			SET pago_efe = 0;
			SET pago_tar = ( _total + _comision_delivery - _descuento_monto);
		ELSEIF _id_tipo_pago = 3 THEN
			SET pago_efe = ( _total + _comision_delivery - _descuento_monto) - _pago_tar - _pago_yape - _pago_plin - _pago_tran;
			SET pago_tar = _pago_tar;
			SET pago_yape = _pago_yape;
			SET pago_plin = _pago_plin;
			SET pago_tran = _pago_tran;
		ELSE
			SET pago_efe = 0;
			SET pago_tar = ( _total + _comision_delivery - _descuento_monto);
			SET pago_yape = 0;
			SET pago_plin = 0;
			SET pago_tran = 0;
		END IF;
	end if;
	
	IF _flag = 1 THEN
		
		-- // Obtenemos la serie y el numero en que se inicia la serie
		SELECT serie,numero INTO @serie, @numinit
		FROM tm_tipo_doc 
		WHERE id_tipo_doc = _id_tipo_doc;

		SET @numactual = 0;
		
		-- // revisamos las emisiones en la BD con el numero de serie, y sacamos el nmero actual en la que esta  
		SELECT nro_doc INTO @numactual
		FROM tm_venta
		WHERE id_tipo_doc = _id_tipo_doc AND serie_doc = @serie
		ORDER BY nro_doc DESC LIMIT 1;

		-- hacemos comparaciones para dar el número correcto
		IF (SELECT @numactual) > (SELECT @numinit) THEN

			SET @numero = @numactual+1;

		ELSEIF (SELECT @numactual) < (SELECT @numinit) THEN

			SET @numero = @numinit;

		ELSEIF (SELECT @numactual) = (SELECT @numinit) THEN

			SET @numero = @numinit+1;

		END IF;

		
		INSERT INTO tm_venta (id_pedido, id_tipo_pedido, id_cliente, id_tipo_doc, id_tipo_pago, id_usu, id_apc, serie_doc, nro_doc, pago_efe, pago_efe_none, pago_tar, pago_yape, pago_plin, pago_tran, descuento_tipo, descuento_personal, descuento_monto, descuento_motivo, comision_tarjeta, comision_delivery, igv, total, codigo_operacion, fecha_venta)
		VALUES (_id_pedido, _tipo_pedido, _id_cliente, _id_tipo_doc, _id_tipo_pago,_id_usu,_id_apc, @serie,@numero, pago_efe, _pago_efe_none, pago_tar, pago_yape, pago_plin, pago_tran, _descuento_tipo, _descuento_personal, _descuento_monto, _descuento_motivo, _comision_tarjeta, _comision_delivery, _igv, _total, _codigo_operacion, _fecha_venta );
		
		SELECT @@IDENTITY INTO @id;
		
		/* DIVIDIR CUENTA 1 = FALSE, 2 = TRUE */
		IF _dividir_cuenta = 1 THEN
		
			IF _tipo_pedido = 1 THEN	
				SELECT id_mesa INTO @idMesa FROM tm_pedido_mesa WHERE id_pedido = _id_pedido;
				UPDATE tm_mesa SET estado = 'a' WHERE id_mesa = @idMesa;
				UPDATE tm_pedido SET estado = 'd' WHERE id_pedido = _id_pedido;
			elseIF _tipo_pedido = 2 then
				UPDATE tm_pedido SET estado = 'b' WHERE id_pedido = _id_pedido;
				UPDATE tm_pedido_llevar SET fecha_entrega = _fecha_venta WHERE id_pedido = _id_pedido;
			ELSEIF _tipo_pedido = 3 THEN
			
				UPDATE tm_pedido SET id_apc = _id_apc, id_usu = _id_usu, estado = _tipo_entrega WHERE id_pedido = _id_pedido;
				
				if _tipo_entrega = 'c' then
					UPDATE tm_pedido_delivery SET fecha_envio = _fecha_venta WHERE id_pedido = _id_pedido;
				elseif _tipo_entrega = 'd' then
					UPDATE tm_pedido_delivery SET fecha_entrega = _fecha_venta WHERE id_pedido = _id_pedido;
				end if;
				/*
				UPDATE tm_pedido SET id_apc = _id_apc, id_usu = _id_usu, estado = 'b' WHERE id_pedido = _id_pedido;
				UPDATE tm_pedido_delivery SET fecha_preparacion = _fecha_venta WHERE id_pedido = _id_pedido;
				*/
			END IF;
			
		END IF;
			
		SELECT @id AS id_venta;
			
	END IF;
	
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restEmitirVentaDet
DELIMITER //
CREATE PROCEDURE `usp_restEmitirVentaDet`(IN `_flag` INT(11), IN `_id_venta` INT(11), IN `_id_pedido` INT(11), IN `_fecha` DATETIME)
BEGIN
    
	DECLARE _idprod INT; 
	DECLARE _cantidad1 INT;
	DECLARE _precio1 FLOAT;
	DECLARE _receta INT;
	DECLARE _tipopedido INT;
	DECLARE _controlstock INT;
	DECLARE done INT DEFAULT 0;
	
	DECLARE _cantidadi INT;
	DECLARE _resultado INT;
	DECLARE _contador INT;
	
	DECLARE primera CURSOR FOR SELECT dv.id_prod, SUM(dv.cantidad) AS cantidad, dv.precio, pp.receta, p.id_tipo, pp.crt_stock  FROM tm_detalle_venta AS dv INNER JOIN tm_producto_pres AS pp
	ON dv.id_prod = pp.id_pres LEFT JOIN tm_producto AS p ON pp.id_prod = p.id_prod WHERE dv.id_venta = _id_venta GROUP BY dv.id_prod;
	DECLARE segunda CURSOR FOR SELECT i.id_tipo_ins,i.id_ins,i.cant,v.ins_cos FROM tm_producto_ingr AS i INNER JOIN v_insprod AS v ON i.id_ins = v.id_ins AND i.id_tipo_ins = v.id_tipo_ins WHERE i.id_pres = _idprod;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	OPEN primera;
	REPEAT
	
	FETCH primera INTO _idprod, _cantidad1, _precio1, _receta, _tipopedido, _controlstock;
	IF NOT done THEN
			
		
	
	UPDATE tm_detalle_pedido SET cantidad = (cantidad - _cantidad1) WHERE id_pedido = _id_pedido AND id_pres = _idprod AND estado <> 'i' AND cantidad > 0 ORDER BY fecha_pedido ASC LIMIT 1;
	
	 	SELECT COUNT(1) INTO _contador FROM tm_detalle_pedido WHERE id_pedido = _id_pedido AND id_pres = _idprod AND estado <> 'i' AND cantidad < 0 ORDER BY fecha_pedido ASC LIMIT 1;

		while _contador <> 0 do
			SELECT IFNULL(cantidad,0) INTO _resultado FROM tm_detalle_pedido WHERE id_pedido = _id_pedido AND id_pres = _idprod AND estado <> 'i' AND cantidad < 0 ORDER BY fecha_pedido ASC LIMIT 1;

	IF _resultado < 0 THEN
        UPDATE tm_detalle_pedido SET cantidad = 0 WHERE id_pedido = _id_pedido AND id_pres = _idprod AND estado <> 'i' AND cantidad < 0 ORDER BY fecha_pedido ASC LIMIT 1;
		
		UPDATE tm_detalle_pedido SET cantidad = (cantidad + _resultado) WHERE id_pedido = _id_pedido AND id_pres = _idprod AND estado <> 'i' AND cantidad <> 0 ORDER BY fecha_pedido ASC LIMIT 1; 
    END IF;
	
	SELECT COUNT(1) INTO _contador FROM tm_detalle_pedido WHERE id_pedido = _id_pedido AND id_pres = _idprod AND estado <> 'i' AND cantidad < 0 ORDER BY fecha_pedido ASC LIMIT 1;
    end while;
			
	 
	
		IF _receta = 1 OR _controlstock = 1 THEN
			
			IF _tipopedido = 2 OR (_controlstock = 1 AND _tipopedido = 1) THEN
				
				INSERT INTO tm_inventario (id_tipo_ope,id_ope,id_tipo_ins,id_ins,cos_uni,cant,fecha_r) VALUES (2,_id_venta,2,_idprod,_precio1,_cantidad1,_fecha);
			
			ELSEIF _tipopedido = 1 THEN
				
				block2: BEGIN
				
						DECLARE donesegunda INT DEFAULT 0;
						DECLARE _tipoinsumo2 INT;
						DECLARE _idinsumo2 INT;
						DECLARE xx FLOAT;
						DECLARE _cantidad2 DECIMAL(10,3);
						DECLARE _precio2 FLOAT;
						DECLARE tercera CURSOR FOR SELECT i.id_tipo_ins,i.id_ins,i.cant,v.ins_cos FROM tm_producto_ingr AS i INNER JOIN v_insprod AS v ON i.id_ins = v.id_ins AND i.id_tipo_ins = v.id_tipo_ins WHERE i.id_pres = _idinsumo2;
						DECLARE CONTINUE HANDLER FOR NOT FOUND SET donesegunda = 1;
					
					OPEN segunda;
					REPEAT
			
					FETCH segunda INTO _tipoinsumo2,_idinsumo2,_cantidad2, _precio2;
						IF NOT donesegunda THEN
						
							IF _tipoinsumo2 = 1 OR _tipoinsumo2 = 2 THEN
							
								SET xx = _cantidad2 * _cantidad1;
								INSERT INTO tm_inventario (id_tipo_ope,id_ope,id_tipo_ins,id_ins,cos_uni,cant,fecha_r) VALUES (2,_id_venta,_tipoinsumo2,_idinsumo2,_precio2,xx,_fecha);
							
							ELSEIF _tipoinsumo2 = 3 then
							
								block3: BEGIN
										DECLARE donetercera INT DEFAULT 0;
										DECLARE _tipoinsumo3 INT;
										DECLARE _idinsumo3 INT;
										DECLARE yy FLOAT;
										DECLARE _cantidad3 FLOAT;
										DECLARE _precio3 FLOAT;
										DECLARE CONTINUE HANDLER FOR NOT FOUND SET donetercera = 1;
							
									OPEN tercera;
									REPEAT
							
									FETCH tercera INTO _tipoinsumo3,_idinsumo3,_cantidad3,_precio3;
										IF NOT donetercera THEN
											
										SET yy = _cantidad1 * _cantidad2 * _cantidad3;
										INSERT INTO tm_inventario (id_tipo_ope,id_ope,id_tipo_ins,id_ins,cos_uni,cant,fecha_r) VALUES (2,_id_venta,_tipoinsumo3,_idinsumo3,_precio3,yy,_fecha);
									
										END IF;
									UNTIL donetercera END REPEAT;
									CLOSE tercera;
									
								END block3;
								
							end if;
							
						END IF;
							
					UNTIL donesegunda END REPEAT;
					CLOSE segunda;
					
				END block2;
				
			END IF;
		END IF;	
	END IF;
	UNTIL done END REPEAT;
	CLOSE primera;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restOpcionesMesa
DELIMITER //
CREATE PROCEDURE `usp_restOpcionesMesa`(IN `_flag` INT(11), IN `_cod_mesa_origen` INT(11), IN `_cod_mesa_destino` INT(11))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	if _flag = 1 then
			
			SELECT COUNT(*) INTO _filtro FROM tm_mesa WHERE id_mesa = _cod_mesa_origen AND estado = 'i';
		
		if _filtro = 1 then 
			SELECT id_pedido INTO @cod FROM v_listar_mesas WHERE id_mesa = _cod_mesa_origen;
			UPDATE tm_mesa SET estado = 'a' WHERE id_mesa = _cod_mesa_origen;
			UPDATE tm_mesa SET estado = 'i' WHERE id_mesa = _cod_mesa_destino;
			UPDATE tm_pedido_mesa SET id_mesa = _cod_mesa_destino WHERE id_pedido = @cod;
			
			SELECT _filtro AS cod;
		ELSE
			SELECT _filtro AS cod;
		end if;
	end if;
	
	IF _flag = 2 THEN
			
			SELECT COUNT(*) INTO _filtro FROM tm_mesa WHERE id_mesa = _cod_mesa_origen AND estado = 'i';
		
		IF _filtro = 1 THEN 
			SELECT id_pedido INTO @cod_1 FROM v_listar_mesas WHERE id_mesa = _cod_mesa_origen;
			SELECT id_pedido INTO @cod_2 FROM v_listar_mesas WHERE id_mesa = _cod_mesa_destino;
			UPDATE tm_detalle_pedido SET id_pedido = @cod_2 WHERE id_pedido = @cod_1;
			
				if _cod_mesa_origen = _cod_mesa_destino then
					UPDATE tm_mesa SET estado = 'i' WHERE id_mesa = _cod_mesa_origen;
				else
					UPDATE tm_mesa SET estado = 'a' WHERE id_mesa = _cod_mesa_origen;
					UPDATE tm_pedido SET estado = 'z' WHERE id_pedido = @cod_1;
				end if;
			
			SELECT _filtro AS cod;
		ELSE
			SELECT _filtro AS cod;
		END IF;
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restRegCliente
DELIMITER //
CREATE PROCEDURE `usp_restRegCliente`(IN `_flag` INT(11), IN `_id_cliente` INT(11), IN `_tipo_cliente` INT(11), IN `_dni` VARCHAR(10), IN `_ruc` VARCHAR(13), IN `_nombres` VARCHAR(200), IN `_razon_social` VARCHAR(100), IN `_telefono` INT(11), IN `_fecha_nac` DATE, IN `_correo` VARCHAR(100), IN `_direccion` VARCHAR(100), IN `_referencia` VARCHAR(100))
BEGIN
	DECLARE _filtro INT DEFAULT 1;
	DECLARE _numero_documento INT DEFAULT 0;
	
	IF _flag = 1 THEN
	
		IF _tipo_cliente = 1 THEN
			SELECT COUNT(*) INTO _filtro FROM tm_cliente WHERE dni = _dni;
			SET _numero_documento = _dni;
		ELSEIF _tipo_cliente = 2 THEN
			SELECT COUNT(*) INTO _filtro FROM tm_cliente WHERE ruc = _ruc;
			SET _numero_documento = '2';
		END IF;
	
		IF _filtro = 0 OR _numero_documento = '00000000' THEN
		
			INSERT INTO tm_cliente (tipo_cliente,dni,ruc,nombres,razon_social,telefono,fecha_nac,correo,direccion,referencia) 
			VALUES (_tipo_cliente, _dni, _ruc, _nombres, _razon_social, _telefono, _fecha_nac, _correo, _direccion, _referencia);
			
			SELECT @@IDENTITY INTO @id;
			
			SELECT _filtro AS cod,@id AS id_cliente;
		ELSE
			SELECT _filtro AS cod;
		END IF;
	END IF;
	
	IF _flag = 2 THEN
	
		UPDATE tm_cliente SET tipo_cliente = _tipo_cliente, dni = _dni, ruc = _ruc, nombres = _nombres, 
		razon_social = _razon_social, telefono = _telefono, fecha_nac = _fecha_nac, correo = _correo, direccion = _direccion, referencia = _referencia
		WHERE id_cliente = _id_cliente;
		
		SELECT _id_cliente AS id_cliente;
		
	END IF;
END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restRegDelivery
DELIMITER //
CREATE PROCEDURE `usp_restRegDelivery`(IN `_flag` INT(11), IN `_tipo_canal` INT(11), IN `_id_tipo_pedido` INT(11), IN `_id_apc` INT(11), IN `_id_usu` INT(11), IN `_fecha_pedido` DATETIME, IN `_id_cliente` INT(11), IN `_id_repartidor` INT(11), IN `_tipo_entrega` INT(11), IN `_tipo_pago` INT(11), IN `_pedido_programado` INT(11), IN `_hora_entrega` TIME, IN `_nombre_cliente` VARCHAR(100), IN `_telefono_cliente` VARCHAR(20), IN `_direccion_cliente` VARCHAR(100), IN `_referencia_cliente` VARCHAR(100), IN `_email_cliente` VARCHAR(200), IN `_id_tdoc` INT(11), IN `_num_cliente` VARCHAR(11))
BEGIN
	DECLARE _filtro INT DEFAULT 1;
	
	IF _flag = 1 THEN
		
		INSERT INTO tm_pedido (id_tipo_pedido,id_apc,id_usu,fecha_pedido) VALUES (_id_tipo_pedido, _id_apc, _id_usu, _fecha_pedido);
		
		SELECT @@IDENTITY INTO @id;
		
		SELECT CONCAT(LPAD(count(t.nro_pedido)+1,5,'0')) AS codigo INTO @nro_pedido FROM tm_pedido_delivery AS t INNER JOIN tm_pedido AS p ON t.id_pedido = p.id_pedido WHERE p.id_tipo_pedido = 3 AND p.estado <> 'z'; 
		
			IF _id_cliente = 1 THEN

				IF _id_tdoc = 2 THEN

					INSERT INTO tm_cliente (tipo_cliente,ruc,nombres,telefono,direccion,referencia) VALUES (_id_tdoc,_num_cliente,_nombre_cliente,_telefono_cliente,_direccion_cliente,_referencia_cliente);

				ELSE

					INSERT INTO tm_cliente (tipo_cliente,dni,nombres,telefono,direccion,referencia) VALUES (_id_tdoc,_num_cliente,_nombre_cliente,_telefono_cliente,_direccion_cliente,_referencia_cliente);

				END IF;



				SELECT @@IDENTITY INTO @id_cliente;

				INSERT INTO tm_pedido_delivery (id_pedido,tipo_canal,id_cliente,id_repartidor,tipo_entrega,tipo_pago,pedido_programado,hora_entrega,nro_pedido,nombre_cliente,telefono_cliente,direccion_cliente,referencia_cliente,email_cliente) VALUES (@id, _tipo_canal, @id_cliente, _id_repartidor, _tipo_entrega, _tipo_pago, _pedido_programado, _hora_entrega, @nro_pedido, _nombre_cliente, _telefono_cliente, _direccion_cliente, _referencia_cliente, _email_cliente);


			ELSE
				UPDATE tm_cliente SET nombres = _nombre_cliente, telefono = _telefono_cliente, direccion = _direccion_cliente, referencia = _referencia_cliente WHERE id_cliente = _id_cliente; 		
				INSERT INTO tm_pedido_delivery (id_pedido,tipo_canal,id_cliente,id_repartidor,tipo_entrega,tipo_pago,pedido_programado,hora_entrega,nro_pedido,nombre_cliente,telefono_cliente,direccion_cliente,referencia_cliente,email_cliente) VALUES (@id, _tipo_canal, _id_cliente, _id_repartidor, _tipo_entrega, _tipo_pago, _pedido_programado, _hora_entrega, @nro_pedido, _nombre_cliente, _telefono_cliente, _direccion_cliente, _referencia_cliente, _email_cliente);
			END IF;
			
		SELECT _filtro AS fil, @id AS id_pedido;
	
	END IF;
    END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restRegMesa
DELIMITER //
CREATE PROCEDURE `usp_restRegMesa`(IN `_flag` INT(11), IN `_id_tipo_pedido` INT(11), IN `_id_apc` INT(11), IN `_id_usu` INT(11), IN `_fecha_pedido` DATETIME, IN `_id_mesa` INT(11), IN `_id_mozo` INT(11), IN `_nomb_cliente` VARCHAR(45), IN `_nro_personas` INT(11))
BEGIN
	DECLARE _filtro INT DEFAULT 0;
	
		IF _flag = 1 THEN
		
			SELECT COUNT(*) INTO _filtro FROM tm_mesa WHERE id_mesa = _id_mesa AND estado = 'a';
			
			if _filtro = 1 THEN
				
				INSERT INTO tm_pedido (id_tipo_pedido,id_apc,id_usu,fecha_pedido) VALUES (_id_tipo_pedido, _id_apc, _id_usu, _fecha_pedido);
				
				SELECT @@IDENTITY INTO @id;
				
				INSERT INTO tm_pedido_mesa (id_pedido,id_mesa,id_mozo,nomb_cliente,nro_personas) VALUES (@id, _id_mesa, _id_mozo, _nomb_cliente, _nro_personas);
				
				SELECT _filtro AS fil, @id AS id_pedido;
				
				UPDATE tm_mesa SET estado = 'i' WHERE id_mesa = _id_mesa;
			ELSE
				SELECT _filtro AS fil;
			END IF;
		END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_restRegMostrador
DELIMITER //
CREATE PROCEDURE `usp_restRegMostrador`(IN `_flag` INT(11), IN `_id_tipo_pedido` INT(11), IN `_id_apc` INT(11), IN `_id_usu` INT(11), IN `_fecha_pedido` DATETIME, IN `_nomb_cliente` VARCHAR(45))
BEGIN
	DECLARE _filtro INT DEFAULT 1;
	
	IF _flag = 1 THEN
		
		INSERT INTO tm_pedido (id_tipo_pedido,id_apc,id_usu,fecha_pedido) VALUES (_id_tipo_pedido, _id_apc, _id_usu, _fecha_pedido);
		
		SELECT @@IDENTITY INTO @id;
		
		SELECT CONCAT(LPAD(count(t.nro_pedido)+1,5,'0')) AS codigo INTO @nro_pedido FROM tm_pedido_llevar AS t INNER JOIN tm_pedido AS p ON t.id_pedido = p.id_pedido WHERE p.id_tipo_pedido = 2 and p.estado <> 'z'; 
		
		INSERT INTO tm_pedido_llevar (id_pedido,nro_pedido,nomb_cliente) VALUES (@id, @nro_pedido, _nomb_cliente);
		
		SELECT _filtro AS fil, @id AS id_pedido;
	
	END IF;
	END//
DELIMITER ;

-- Volcando estructura para procedimiento factuyorest.usp_tableroControl
DELIMITER //
CREATE PROCEDURE `usp_tableroControl`(IN `_flag` INT(11), IN `_codDia` INT(11), IN `_fecha` DATE, IN `_feSei` DATE, IN `_feCin` DATE, IN `_feCua` DATE, IN `_feTre` DATE, IN `_feDos` DATE, IN `_feUno` DATE)
BEGIN
	if _flag = 1 then
				SELECT dia,margen into @dia,@margen FROM tm_margen_venta WHERE cod_dia = _codDia;
				SELECT IFNULL(SUM(total-descuento),0) into @siete FROM tm_venta WHERE DATE(fecha_venta) = _fecha;
				SELECT IFNULL(SUM(total-descuento),0) into @seis FROM tm_venta WHERE DATE(fecha_venta) = _feSei;
				SELECT IFNULL(SUM(total-descuento),0) into @cinco FROM tm_venta WHERE DATE(fecha_venta) = _feCin;
				SELECT IFNULL(SUM(total-descuento),0) into @cuatro FROM tm_venta WHERE DATE(fecha_venta) = _feCua;
				SELECT IFNULL(SUM(total-descuento),0) into @tres FROM tm_venta WHERE DATE(fecha_venta) = _feTre;
				SELECT IFNULL(SUM(total-descuento),0) into @dos FROM tm_venta WHERE DATE(fecha_venta) = _feDos;
				SELECT IFNULL(SUM(total-descuento),0) into @uno FROM tm_venta WHERE DATE(fecha_venta) = _feUno;
		
		select @dia as dia,@margen as margen,@siete as siete,@seis as seis,@cinco as cinco,@cuatro as cuatro,@tres as tres,@dos as dos,@uno as uno;	
	end if;
    END//
DELIMITER ;

-- Volcando estructura para vista factuyorest.v_caja_aper
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_caja_aper` (
	`id_apc` INT(11) NOT NULL,
	`id_usu` INT(11) NOT NULL,
	`id_caja` INT(11) NOT NULL,
	`id_turno` INT(11) NOT NULL,
	`fecha_aper` DATETIME NULL,
	`monto_aper` DECIMAL(10,2) NULL,
	`fecha_cierre` DATETIME NULL,
	`monto_cierre` DECIMAL(10,2) NULL,
	`monto_sistema` DECIMAL(10,2) NULL,
	`stock_pollo` VARCHAR(11) NOT NULL COLLATE 'utf8_general_ci',
	`estado` VARCHAR(5) NULL COLLATE 'utf8_general_ci',
	`desc_per` VARCHAR(137) NULL COLLATE 'utf8_general_ci',
	`desc_caja` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_turno` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_clientes
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_clientes` (
	`id_cliente` INT(11) NOT NULL,
	`tipo_cliente` INT(11) NOT NULL,
	`dni` VARCHAR(8) NOT NULL COLLATE 'utf8_general_ci',
	`ruc` VARCHAR(13) NOT NULL COLLATE 'utf8_general_ci',
	`nombre` VARCHAR(200) NOT NULL COLLATE 'utf8_general_ci',
	`telefono` INT(11) NOT NULL,
	`fecha_nac` DATE NOT NULL,
	`direccion` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`referencia` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_cocina_de
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_cocina_de` (
	`id_pedido` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`id_tipo` INT(11) NOT NULL,
	`id_pres` INT(11) NOT NULL,
	`cantidad` INT(11) NOT NULL,
	`comentario` VARCHAR(100) NOT NULL COLLATE 'utf8_unicode_ci',
	`fecha_pedido` DATETIME NOT NULL,
	`fecha_envio` DATETIME NOT NULL,
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
	`nro_pedido` VARCHAR(10) NOT NULL COLLATE 'utf8_general_ci',
	`id_usu` INT(11) NOT NULL,
	`nombre_prod` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pres_prod` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`ape_paterno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`ape_materno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`nombres` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_cocina_me
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_cocina_me` (
	`id_pedido` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`id_tipo` INT(11) NOT NULL,
	`id_pres` INT(11) NOT NULL,
	`cantidad` INT(11) NOT NULL,
	`comentario` VARCHAR(100) NOT NULL COLLATE 'utf8_unicode_ci',
	`fecha_pedido` DATETIME NOT NULL,
	`fecha_envio` DATETIME NOT NULL,
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
	`id_mesa` INT(11) NOT NULL,
	`id_mozo` INT(11) NOT NULL,
	`nombre_prod` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pres_prod` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`nro_mesa` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`desc_salon` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`ape_paterno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`ape_materno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`nombres` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_cocina_mo
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_cocina_mo` (
	`id_pedido` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`id_tipo` INT(11) NOT NULL,
	`id_pres` INT(11) NOT NULL,
	`cantidad` INT(11) NOT NULL,
	`comentario` VARCHAR(100) NOT NULL COLLATE 'utf8_unicode_ci',
	`fecha_pedido` DATETIME NOT NULL,
	`fecha_envio` DATETIME NOT NULL,
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
	`nro_pedido` VARCHAR(10) NOT NULL COLLATE 'utf8_general_ci',
	`id_usu` INT(11) NOT NULL,
	`nombre_prod` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pres_prod` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`ape_paterno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`ape_materno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`nombres` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_compras
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_compras` (
	`id_compra` INT(11) NOT NULL,
	`id_prov` INT(11) NOT NULL,
	`id_tipo_compra` INT(11) NOT NULL,
	`id_tipo_doc` INT(11) NOT NULL,
	`fecha_c` DATE NULL,
	`fecha_r` DATETIME NULL,
	`hora_c` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`serie_doc` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`num_doc` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`igv` DECIMAL(10,2) NULL,
	`total` DECIMAL(10,2) NULL,
	`estado` VARCHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`desc_tc` VARCHAR(45) NOT NULL COLLATE 'latin1_swedish_ci',
	`desc_td` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_prov` VARCHAR(100) NOT NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_det_delivery
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_det_delivery` (
	`id_pedido` INT(11) NOT NULL,
	`id_pres` INT(11) NOT NULL,
	`cantidad` INT(11) NOT NULL,
	`precio` DECIMAL(10,2) NOT NULL,
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
	`nombre_prod` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pres_prod` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_det_llevar
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_det_llevar` (
	`id_pedido` INT(11) NOT NULL,
	`id_pres` INT(11) NOT NULL,
	`cantidad` INT(11) NOT NULL,
	`precio` DECIMAL(10,2) NOT NULL,
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
	`nombre_prod` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pres_prod` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_estadistica
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_estadistica` (
	`id_venta` INT(11) NOT NULL,
	`id_pedido` INT(11) NOT NULL,
	`id_tipo_pedido` INT(11) NOT NULL,
	`id_apc` INT(11) NOT NULL,
	`total` DECIMAL(10,2) NULL,
	`id_usu` INT(11) NULL,
	`nombres` VARCHAR(48) NULL COLLATE 'utf8_general_ci',
	`ape_materno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`ape_paterno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`fecha_venta` DATETIME NULL,
	`tipo_entrega` INT(11) NULL,
	`id_repartidor` INT(11) NULL,
	`repartidor_abrv` VARCHAR(48) NULL COLLATE 'utf8_general_ci',
	`repartidor` VARCHAR(137) NULL COLLATE 'utf8_general_ci',
	`estado` VARCHAR(15) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_gastosadm
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_gastosadm` (
	`id_ga` INT(11) NOT NULL,
	`id_tg` INT(11) NOT NULL,
	`id_per` INT(11) NULL,
	`id_usu` INT(11) NOT NULL,
	`id_apc` INT(11) NOT NULL,
	`importe` DECIMAL(10,2) NULL,
	`responsable` VARCHAR(100) NULL COLLATE 'utf8_general_ci',
	`motivo` VARCHAR(100) NULL COLLATE 'utf8_general_ci',
	`fecha_re` DATETIME NULL,
	`estado` VARCHAR(5) NULL COLLATE 'utf8_general_ci',
	`des_tg` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_usu` VARCHAR(137) NULL COLLATE 'utf8_general_ci',
	`desc_per` VARCHAR(137) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_insprod
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_insprod` (
	`id_tipo_ins` INT(1) NOT NULL,
	`id_ins` INT(11) NOT NULL,
	`id_med` VARCHAR(11) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`id_gru` VARCHAR(11) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`precio_compra` DECIMAL(10,2) NULL,
	`ins_cod` VARCHAR(45) NULL COLLATE 'utf8_unicode_ci',
	`ins_nom` MEDIUMTEXT NULL COLLATE 'utf8_unicode_ci',
	`ins_cat` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`ins_med` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`ins_rec` INT(11) NOT NULL,
	`ins_cos` DECIMAL(10,2) NULL,
	`ins_sto` INT(11) NULL,
	`est_a` VARCHAR(5) NULL COLLATE 'utf8_unicode_ci',
	`est_b` VARCHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`est_c` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`crt_stock` VARCHAR(11) NOT NULL COLLATE 'utf8mb4_unicode_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_insumos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_insumos` (
	`id_ins` INT(11) NOT NULL,
	`id_catg` INT(11) NOT NULL,
	`id_med` INT(11) NOT NULL,
	`cos_uni` DECIMAL(10,2) NULL,
	`id_gru` INT(11) NOT NULL,
	`ins_cod` VARCHAR(10) NULL COLLATE 'utf8_unicode_ci',
	`ins_nom` VARCHAR(45) NULL COLLATE 'utf8_unicode_ci',
	`ins_sto` INT(11) NULL,
	`ins_cos` DECIMAL(10,2) NULL,
	`ins_est` VARCHAR(5) NULL COLLATE 'utf8_unicode_ci',
	`ins_cat` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`ins_med` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_inventario
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_inventario` (
	`id_tipo_ins` INT(11) NOT NULL,
	`id_ins` INT(11) NOT NULL,
	`ent` VARCHAR(23) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`sal` VARCHAR(23) NOT NULL COLLATE 'utf8mb4_unicode_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_inventario_ent
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_inventario_ent` (
	`id_tipo_ins` INT(11) NOT NULL,
	`id_ins` INT(11) NOT NULL,
	`total` DOUBLE NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_inventario_sal
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_inventario_sal` (
	`id_tipo_ins` INT(11) NOT NULL,
	`id_ins` INT(11) NOT NULL,
	`total` DOUBLE NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_listar_mesas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_listar_mesas` (
	`id_mesa` INT(11) NOT NULL,
	`forma` INT(11) NOT NULL,
	`id_salon` INT(11) NOT NULL,
	`nro_mesa` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`estado` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_salon` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`id_pedido` INT(11) NULL,
	`fecha_pedido` DATETIME NULL,
	`nro_personas` INT(11) NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_mesas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_mesas` (
	`id_mesa` INT(11) NOT NULL,
	`id_salon` INT(11) NOT NULL,
	`forma` INT(11) NOT NULL,
	`nro_mesa` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`estado` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_salon` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_pedidos_agrupados
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_pedidos_agrupados` (
	`tipo_atencion` INT(1) NOT NULL,
	`id_pedido` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`id_tipo` INT(11) NOT NULL,
	`id_pres` INT(11) NOT NULL,
	`cantidad` DECIMAL(32,0) NULL,
	`comentario` VARCHAR(100) NOT NULL COLLATE 'utf8_unicode_ci',
	`fecha_pedido` DATETIME NOT NULL,
	`fecha_envio` DATETIME NOT NULL,
	`estado` VARCHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
	`nombre_prod` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pres_prod` LONGTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`nro_mesa` VARCHAR(10) NOT NULL COLLATE 'utf8_general_ci',
	`desc_salon` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`ape_paterno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`ape_materno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`nombres` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_pedido_delivery
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_pedido_delivery` (
	`id_pedido` INT(11) NOT NULL,
	`id_tipo_pedido` INT(11) NOT NULL,
	`id_usu` INT(11) NOT NULL,
	`desc_tp` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`id_repartidor` INT(11) NOT NULL,
	`fecha_pedido` DATETIME NOT NULL,
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`tipo_entrega` INT(11) NOT NULL,
	`pedido_programado` INT(11) NULL,
	`hora_entrega` TIME NULL,
	`amortizacion` DECIMAL(10,2) NOT NULL,
	`tipo_pago` INT(11) NOT NULL,
	`id_tpag` INT(11) NOT NULL,
	`paga_con` DECIMAL(10,2) NOT NULL,
	`comision_delivery` DECIMAL(10,2) NOT NULL,
	`nro_pedido` VARCHAR(10) NOT NULL COLLATE 'utf8_general_ci',
	`id_cliente` INT(11) NOT NULL,
	`tipo_cliente` INT(11) NOT NULL,
	`dni_cliente` VARCHAR(8) NOT NULL COLLATE 'utf8_general_ci',
	`ruc_cliente` VARCHAR(13) NOT NULL COLLATE 'utf8_general_ci',
	`nombre_cliente` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`telefono_cliente` VARCHAR(20) NOT NULL COLLATE 'utf8_general_ci',
	`direccion_cliente` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`referencia_cliente` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci',
	`email_cliente` VARCHAR(200) NOT NULL COLLATE 'utf8_general_ci',
	`desc_repartidor` VARCHAR(137) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_pedido_llevar
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_pedido_llevar` (
	`id_pedido` INT(11) NOT NULL,
	`id_tipo_pedido` INT(11) NOT NULL,
	`id_usu` INT(11) NOT NULL,
	`fecha_pedido` DATETIME NOT NULL,
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`nro_pedido` VARCHAR(10) NOT NULL COLLATE 'utf8_general_ci',
	`nombre_cliente` VARCHAR(100) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_pedido_mesa
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_pedido_mesa` (
	`id_pedido` INT(11) NOT NULL,
	`id_tipo_pedido` INT(11) NOT NULL,
	`id_usu` INT(11) NOT NULL,
	`id_mesa` INT(11) NOT NULL,
	`fecha_pedido` DATETIME NOT NULL,
	`estado_pedido` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`nombre_cliente` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`nro_personas` INT(11) NOT NULL,
	`nro_mesa` VARCHAR(5) NOT NULL COLLATE 'utf8_general_ci',
	`desc_salon` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`estado_mesa` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`nombre_mozo` VARCHAR(91) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_productos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_productos` (
	`id_pres` INT(11) NOT NULL,
	`id_prod` INT(11) NOT NULL,
	`impuesto_icbper` INT(1) NOT NULL,
	`impuesto_compra` INT(11) NOT NULL,
	`precio_compra` DECIMAL(10,2) NOT NULL,
	`id_tipo` INT(11) NOT NULL,
	`id_catg` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`pro_cat` VARCHAR(45) NOT NULL COLLATE 'latin1_swedish_ci',
	`pro_cod` VARCHAR(45) NOT NULL COLLATE 'utf8_unicode_ci',
	`pro_nom` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pro_pre` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`pro_des` LONGTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`pro_cos` DECIMAL(10,2) NOT NULL,
	`pro_cos2` DECIMAL(10,2) NOT NULL,
	`ordenins` INT(11) NOT NULL,
	`pro_cos_del` DECIMAL(10,2) NOT NULL,
	`pro_rec` INT(1) NOT NULL,
	`pro_sto` INT(11) NOT NULL,
	`pro_imp` INT(1) NOT NULL,
	`pro_mar` INT(11) NOT NULL,
	`favorito` INT(1) NOT NULL,
	`precios` TEXT NULL COLLATE 'utf8_unicode_ci',
	`pro_igv` DECIMAL(10,2) NOT NULL,
	`pro_img` VARCHAR(200) NOT NULL COLLATE 'utf8_unicode_ci',
	`del_a` INT(1) NOT NULL,
	`del_b` INT(1) NULL,
	`del_c` INT(1) NOT NULL,
	`est_a` VARCHAR(1) NOT NULL COLLATE 'latin1_swedish_ci',
	`est_b` VARCHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`est_c` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`crt_stock` INT(1) NOT NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_prod_favorito
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_prod_favorito` (
	`id_pres` INT(11) NOT NULL,
	`id_prod` INT(11) NOT NULL,
	`impuesto_icbper` INT(1) NOT NULL,
	`impuesto_compra` INT(11) NOT NULL,
	`precio_compra` DECIMAL(10,2) NOT NULL,
	`id_tipo` INT(11) NOT NULL,
	`id_catg` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`pro_cat` VARCHAR(45) NOT NULL COLLATE 'latin1_swedish_ci',
	`pro_cod` VARCHAR(45) NOT NULL COLLATE 'utf8_unicode_ci',
	`pro_nom` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`pro_pre` MEDIUMTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`pro_des` LONGTEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`pro_cos` DECIMAL(10,2) NOT NULL,
	`pro_cos2` DECIMAL(10,2) NOT NULL,
	`ordenins` INT(11) NOT NULL,
	`pro_cos_del` DECIMAL(10,2) NOT NULL,
	`pro_rec` INT(1) NOT NULL,
	`pro_sto` INT(11) NOT NULL,
	`pro_imp` INT(1) NOT NULL,
	`pro_mar` INT(11) NOT NULL,
	`favorito` INT(1) NOT NULL,
	`precios` TEXT NULL COLLATE 'utf8_unicode_ci',
	`pro_igv` DECIMAL(10,2) NOT NULL,
	`pro_img` VARCHAR(200) NOT NULL COLLATE 'utf8_unicode_ci',
	`del_a` INT(1) NOT NULL,
	`del_b` INT(1) NULL,
	`del_c` INT(1) NOT NULL,
	`est_a` VARCHAR(1) NOT NULL COLLATE 'latin1_swedish_ci',
	`est_b` VARCHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`est_c` VARCHAR(1) NOT NULL COLLATE 'utf8_unicode_ci',
	`crt_stock` INT(1) NOT NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_repartidores
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_repartidores` (
	`id_repartidor` INT(11) NOT NULL,
	`desc_repartidor` VARCHAR(137) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_stock
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_stock` (
	`id_tipo_ins` INT(11) NOT NULL,
	`id_ins` INT(11) NOT NULL,
	`ent` DOUBLE NULL,
	`sal` DOUBLE NULL,
	`est_a` VARCHAR(5) NULL COLLATE 'utf8_unicode_ci',
	`est_b` VARCHAR(1) NULL COLLATE 'latin1_swedish_ci',
	`debajo_stock` INT(1) NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_stock_pedido
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_stock_pedido` (
	`id_ins` INT(11) NOT NULL,
	`ent` DOUBLE NOT NULL,
	`sal` DECIMAL(32,0) NOT NULL,
	`control` INT(11) NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_usuarios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_usuarios` (
	`id_usu` INT(11) NOT NULL,
	`id_rol` INT(11) NOT NULL,
	`id_areap` INT(11) NOT NULL,
	`dni` VARCHAR(10) NOT NULL COLLATE 'utf8_general_ci',
	`editarprecio` INT(11) NULL,
	`ape_paterno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`ape_materno` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`nombres` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`email` VARCHAR(100) NULL COLLATE 'utf8_general_ci',
	`usuario` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`contrasena` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`estado` VARCHAR(5) NULL COLLATE 'utf8_general_ci',
	`imagen` VARCHAR(45) NULL COLLATE 'utf8_general_ci',
	`desc_r` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_ap` VARCHAR(45) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_ventas_con
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_ventas_con` (
	`id_ven` INT(11) NOT NULL,
	`id_ped` INT(11) NOT NULL,
	`nvoriginal` VARCHAR(20) NULL COLLATE 'utf8_general_ci',
	`nvfecha` DATE NULL,
	`id_tped` INT(11) NOT NULL,
	`id_cli` INT(11) NOT NULL,
	`id_tdoc` INT(11) NOT NULL,
	`id_tpag` INT(11) NOT NULL,
	`id_usu` INT(11) NOT NULL,
	`id_apc` INT(11) NOT NULL,
	`ser_doc` CHAR(4) NOT NULL COLLATE 'utf8_general_ci',
	`nro_doc` INT(8) UNSIGNED ZEROFILL NOT NULL,
	`cambiomanual` INT(1) NOT NULL,
	`pago_efe` DECIMAL(10,2) NULL,
	`pago_efe_none` DECIMAL(10,2) NULL,
	`pago_tar` DECIMAL(10,2) NULL,
	`pago_yape` DECIMAL(10,2) NULL,
	`pago_plin` DECIMAL(10,2) NULL,
	`pago_tran` DECIMAL(10,2) NULL,
	`desc_monto` DECIMAL(10,2) NULL,
	`desc_tipo` CHAR(1) NOT NULL COLLATE 'utf8_general_ci',
	`desc_personal` INT(11) NULL,
	`desc_motivo` VARCHAR(200) NULL COLLATE 'utf8_general_ci',
	`comis_tar` DECIMAL(10,2) NULL,
	`comis_del` DECIMAL(10,2) NULL,
	`igv` DECIMAL(10,2) NULL,
	`total` DECIMAL(10,2) NULL,
	`codigo_operacion` VARCHAR(20) NULL COLLATE 'utf8_general_ci',
	`fec_ven` DATETIME NULL,
	`estado` VARCHAR(15) NULL COLLATE 'utf8_general_ci',
	`enviado_sunat` CHAR(1) NULL COLLATE 'utf8_general_ci',
	`code_respuesta_sunat` VARCHAR(200) NOT NULL COLLATE 'utf8_general_ci',
	`descripcion_sunat_cdr` VARCHAR(300) NOT NULL COLLATE 'utf8_general_ci',
	`name_file_sunat` VARCHAR(80) NOT NULL COLLATE 'utf8_general_ci',
	`hash_cdr` VARCHAR(200) NOT NULL COLLATE 'utf8_general_ci',
	`hash_cpe` VARCHAR(200) NOT NULL COLLATE 'utf8_general_ci',
	`fecha_vencimiento` DATE NOT NULL,
	`desc_td` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`desc_tp` VARCHAR(45) NOT NULL COLLATE 'utf8_general_ci',
	`consumo` INT(1) NOT NULL,
	`consumo_desc` TEXT NOT NULL COLLATE 'utf8_general_ci',
	`observacion` TEXT NULL COLLATE 'utf8_general_ci',
	`desc_usu` VARCHAR(137) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista factuyorest.v_caja_aper
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_caja_aper`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_caja_aper` AS select `apc`.`id_apc` AS `id_apc`,`apc`.`id_usu` AS `id_usu`,`apc`.`id_caja` AS `id_caja`,`apc`.`id_turno` AS `id_turno`,`apc`.`fecha_aper` AS `fecha_aper`,`apc`.`monto_aper` AS `monto_aper`,`apc`.`fecha_cierre` AS `fecha_cierre`,`apc`.`monto_cierre` AS `monto_cierre`,`apc`.`monto_sistema` AS `monto_sistema`,`apc`.`stock_pollo` AS `stock_pollo`,`apc`.`estado` AS `estado`,concat(`tp`.`nombres`,' ',`tp`.`ape_paterno`,' ',`tp`.`ape_materno`) AS `desc_per`,`tc`.`descripcion` AS `desc_caja`,`tt`.`descripcion` AS `desc_turno` from (((`tm_aper_cierre` `apc` join `tm_usuario` `tp` on(`apc`.`id_usu` = `tp`.`id_usu`)) join `tm_caja` `tc` on(`apc`.`id_caja` = `tc`.`id_caja`)) join `tm_turno` `tt` on(`apc`.`id_turno` = `tt`.`id_turno`)) order by `apc`.`id_apc` desc ;

-- Volcando estructura para vista factuyorest.v_clientes
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_clientes`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_clientes` AS select `tm_cliente`.`id_cliente` AS `id_cliente`,`tm_cliente`.`tipo_cliente` AS `tipo_cliente`,`tm_cliente`.`dni` AS `dni`,`tm_cliente`.`ruc` AS `ruc`,concat(ifnull(`tm_cliente`.`razon_social`,''),'',`tm_cliente`.`nombres`) AS `nombre`,`tm_cliente`.`telefono` AS `telefono`,`tm_cliente`.`fecha_nac` AS `fecha_nac`,`tm_cliente`.`direccion` AS `direccion`,`tm_cliente`.`referencia` AS `referencia`,`tm_cliente`.`estado` AS `estado` from `tm_cliente` order by `tm_cliente`.`id_cliente` desc ;

-- Volcando estructura para vista factuyorest.v_cocina_de
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_cocina_de`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_cocina_de` AS select `dp`.`id_pedido` AS `id_pedido`,`vp`.`id_areap` AS `id_areap`,`vp`.`id_tipo` AS `id_tipo`,`dp`.`id_pres` AS `id_pres`,if(`dp`.`cantidad` < `dp`.`cant`,`dp`.`cant`,`dp`.`cantidad`) AS `cantidad`,`dp`.`comentario` AS `comentario`,`dp`.`fecha_pedido` AS `fecha_pedido`,`dp`.`fecha_envio` AS `fecha_envio`,`dp`.`estado` AS `estado`,`pd`.`nro_pedido` AS `nro_pedido`,`tp`.`id_usu` AS `id_usu`,`vp`.`pro_nom` AS `nombre_prod`,`vp`.`pro_pre` AS `pres_prod`,`vu`.`ape_paterno` AS `ape_paterno`,`vu`.`ape_materno` AS `ape_materno`,`vu`.`nombres` AS `nombres`,`tp`.`estado` AS `estado_pedido` from ((((`tm_detalle_pedido` `dp` join `tm_pedido_delivery` `pd` on(`dp`.`id_pedido` = `pd`.`id_pedido`)) join `tm_pedido` `tp` on(`dp`.`id_pedido` = `tp`.`id_pedido`)) join `v_productos` `vp` on(`dp`.`id_pres` = `vp`.`id_pres`)) join `v_usuarios` `vu` on(`tp`.`id_usu` = `vu`.`id_usu`)) ;

-- Volcando estructura para vista factuyorest.v_cocina_me
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_cocina_me`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_cocina_me` AS select `dp`.`id_pedido` AS `id_pedido`,`vp`.`id_areap` AS `id_areap`,`vp`.`id_tipo` AS `id_tipo`,`dp`.`id_pres` AS `id_pres`,`dp`.`cantidad` AS `cantidad`,`dp`.`comentario` AS `comentario`,`dp`.`fecha_pedido` AS `fecha_pedido`,`dp`.`fecha_envio` AS `fecha_envio`,`dp`.`estado` AS `estado`,`pm`.`id_mesa` AS `id_mesa`,`pm`.`id_mozo` AS `id_mozo`,`vp`.`pro_nom` AS `nombre_prod`,`vp`.`pro_pre` AS `pres_prod`,`vm`.`nro_mesa` AS `nro_mesa`,`vm`.`desc_salon` AS `desc_salon`,`vu`.`ape_paterno` AS `ape_paterno`,`vu`.`ape_materno` AS `ape_materno`,`vu`.`nombres` AS `nombres`,`tp`.`estado` AS `estado_pedido` from (((((`tm_detalle_pedido` `dp` join `tm_pedido_mesa` `pm` on(`dp`.`id_pedido` = `pm`.`id_pedido`)) join `tm_pedido` `tp` on(`dp`.`id_pedido` = `tp`.`id_pedido`)) join `v_productos` `vp` on(`dp`.`id_pres` = `vp`.`id_pres`)) join `v_mesas` `vm` on(`pm`.`id_mesa` = `vm`.`id_mesa`)) join `v_usuarios` `vu` on(`pm`.`id_mozo` = `vu`.`id_usu`)) ;

-- Volcando estructura para vista factuyorest.v_cocina_mo
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_cocina_mo`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_cocina_mo` AS select `dp`.`id_pedido` AS `id_pedido`,`vp`.`id_areap` AS `id_areap`,`vp`.`id_tipo` AS `id_tipo`,`dp`.`id_pres` AS `id_pres`,if(`dp`.`cantidad` < `dp`.`cant`,`dp`.`cant`,`dp`.`cantidad`) AS `cantidad`,`dp`.`comentario` AS `comentario`,`dp`.`fecha_pedido` AS `fecha_pedido`,`dp`.`fecha_envio` AS `fecha_envio`,`dp`.`estado` AS `estado`,`pm`.`nro_pedido` AS `nro_pedido`,`tp`.`id_usu` AS `id_usu`,`vp`.`pro_nom` AS `nombre_prod`,`vp`.`pro_pre` AS `pres_prod`,`vu`.`ape_paterno` AS `ape_paterno`,`vu`.`ape_materno` AS `ape_materno`,`vu`.`nombres` AS `nombres`,`tp`.`estado` AS `estado_pedido` from ((((`tm_detalle_pedido` `dp` join `tm_pedido_llevar` `pm` on(`dp`.`id_pedido` = `pm`.`id_pedido`)) join `tm_pedido` `tp` on(`dp`.`id_pedido` = `tp`.`id_pedido`)) join `v_productos` `vp` on(`dp`.`id_pres` = `vp`.`id_pres`)) join `v_usuarios` `vu` on(`tp`.`id_usu` = `vu`.`id_usu`)) ;

-- Volcando estructura para vista factuyorest.v_compras
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_compras`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_compras` AS select `c`.`id_compra` AS `id_compra`,`c`.`id_prov` AS `id_prov`,`c`.`id_tipo_compra` AS `id_tipo_compra`,`c`.`id_tipo_doc` AS `id_tipo_doc`,`c`.`fecha_c` AS `fecha_c`,`c`.`fecha_reg` AS `fecha_r`,`c`.`hora_c` AS `hora_c`,`c`.`serie_doc` AS `serie_doc`,`c`.`num_doc` AS `num_doc`,`c`.`igv` AS `igv`,`c`.`total` AS `total`,`c`.`estado` AS `estado`,`tc`.`descripcion` AS `desc_tc`,`td`.`descripcion` AS `desc_td`,`tp`.`razon_social` AS `desc_prov` from (((`tm_compra` `c` join `tm_tipo_compra` `tc` on(`c`.`id_tipo_compra` = `tc`.`id_tipo_compra`)) join `tm_tipo_doc` `td` on(`c`.`id_tipo_doc` = `td`.`id_tipo_doc`)) join `tm_proveedor` `tp` on(`c`.`id_prov` = `tp`.`id_prov`)) where `c`.`id_compra` <> 0 order by `c`.`id_compra` desc ;

-- Volcando estructura para vista factuyorest.v_det_delivery
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_det_delivery`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_det_delivery` AS select `dp`.`id_pedido` AS `id_pedido`,`dp`.`id_pres` AS `id_pres`,if(`dp`.`cantidad` < `dp`.`cant`,`dp`.`cant`,`dp`.`cantidad`) AS `cantidad`,`dp`.`precio` AS `precio`,`dp`.`estado` AS `estado`,`vp`.`pro_nom` AS `nombre_prod`,`vp`.`pro_pre` AS `pres_prod` from (((`tm_detalle_pedido` `dp` join `tm_pedido_delivery` `pd` on(`dp`.`id_pedido` = `pd`.`id_pedido`)) join `tm_pedido` `tp` on(`dp`.`id_pedido` = `tp`.`id_pedido`)) join `v_productos` `vp` on(`dp`.`id_pres` = `vp`.`id_pres`)) where `dp`.`estado` <> 'z' ;

-- Volcando estructura para vista factuyorest.v_det_llevar
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_det_llevar`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_det_llevar` AS select `dp`.`id_pedido` AS `id_pedido`,`dp`.`id_pres` AS `id_pres`,if(`dp`.`cantidad` < `dp`.`cant`,`dp`.`cant`,`dp`.`cantidad`) AS `cantidad`,`dp`.`precio` AS `precio`,`dp`.`estado` AS `estado`,`vp`.`pro_nom` AS `nombre_prod`,`vp`.`pro_pre` AS `pres_prod` from (((`tm_detalle_pedido` `dp` join `tm_pedido_llevar` `pm` on(`dp`.`id_pedido` = `pm`.`id_pedido`)) join `tm_pedido` `tp` on(`dp`.`id_pedido` = `tp`.`id_pedido`)) join `v_productos` `vp` on(`dp`.`id_pres` = `vp`.`id_pres`)) where `dp`.`estado` <> 'z' ;

-- Volcando estructura para vista factuyorest.v_estadistica
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_estadistica`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_estadistica` AS SELECT
	`v`.`id_venta`,
	`v`.`id_pedido`,
	`v`.`id_tipo_pedido`,
	`v`.`id_apc`, 
	`v`.`total`, 
	`p`.`id_mozo` AS `id_usu`, 
	CONCAT(`u`.`nombres`, ' ', SUBSTR(`u`.`ape_paterno`, 1, 1), '.') AS `nombres`,
	`u`.`ape_materno`, 
	`u`.`ape_paterno`, 
	`v`.`fecha_venta`,
	`d`.`tipo_entrega`,
	`d`.`id_repartidor`,
	CONCAT(`r`.`nombres`, ' ', SUBSTR(`r`.`ape_paterno`, 1, 1), '.') AS `repartidor_abrv`,
	CONCAT(`r`.`nombres`, ' ', `r`.`ape_paterno`, ' ', `r`.`ape_materno`) AS `repartidor`,
	`v`.`estado`
FROM
	`tm_venta` `v`
	LEFT JOIN
	`tm_pedido_mesa` `p`
	ON 
		`v`.`id_pedido` = `p`.`id_pedido`
	LEFT JOIN
	`tm_usuario` `u`
	ON 
		`p`.`id_mozo` = `u`.`id_usu`
	LEFT JOIN
	`tm_pedido_delivery` `d`
	ON 
		`d`.`id_pedido` = `v`.`id_pedido`
	LEFT JOIN
	`tm_usuario` `r`
	ON 
		`d`.`id_repartidor` = `r`.`id_usu`
WHERE
	`v`.`estado` = 'a' ;

-- Volcando estructura para vista factuyorest.v_gastosadm
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_gastosadm`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_gastosadm` AS select `ga`.`id_ga` AS `id_ga`,`ga`.`id_tipo_gasto` AS `id_tg`,`ga`.`id_per` AS `id_per`,`ga`.`id_usu` AS `id_usu`,`ga`.`id_apc` AS `id_apc`,`ga`.`importe` AS `importe`,`ga`.`responsable` AS `responsable`,`ga`.`motivo` AS `motivo`,`ga`.`fecha_registro` AS `fecha_re`,`ga`.`estado` AS `estado`,`tg`.`descripcion` AS `des_tg`,concat(`tu`.`nombres`,' ',`tu`.`ape_paterno`,' ',`tu`.`ape_materno`) AS `desc_usu`,if(`ga`.`id_per` = '0','',concat(`tus`.`nombres`,' ',`tus`.`ape_paterno`,' ',`tus`.`ape_materno`)) AS `desc_per` from (((`tm_gastos_adm` `ga` join `tm_tipo_gasto` `tg` on(`ga`.`id_tipo_gasto` = `tg`.`id_tipo_gasto`)) join `tm_usuario` `tu` on(`ga`.`id_usu` = `tu`.`id_usu`)) left join `tm_usuario` `tus` on(`ga`.`id_per` = `tus`.`id_usu`)) where `ga`.`id_ga` <> 0 order by `ga`.`id_ga` desc ;

-- Volcando estructura para vista factuyorest.v_insprod
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_insprod`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_insprod` AS select 1 AS `id_tipo_ins`,`i`.`id_ins` AS `id_ins`,`i`.`id_med` AS `id_med`,`i`.`id_gru` AS `id_gru`,`i`.`cos_uni` as `precio_compra`,`i`.`ins_cod` AS `ins_cod`,`i`.`ins_nom` AS `ins_nom`,`i`.`ins_cat` AS `ins_cat`,`i`.`ins_med` AS `ins_med`,1 AS `ins_rec`,`i`.`ins_cos` AS `ins_cos`,`i`.`ins_sto` AS `ins_sto`,`i`.`ins_est` AS `est_a`,'a' AS `est_b`,'a' AS `est_c`,'' AS `crt_stock` from `v_insumos` `i` union select 2 AS `id_tipo_ins`,`p`.`id_pres` AS `id_pres`,'1' AS `1`,'1' AS `1`,`p`.`precio_compra`,`p`.`pro_cod` AS `pro_cod`,concat(`p`.`pro_nom`,' ',`p`.`pro_pre`) AS `pro_nom`,`p`.`pro_cat` AS `pro_cat`,'UNIDAD' AS `UNIDAD`,`p`.`pro_rec` AS `pro_rec`,`p`.`pro_cos` AS `pro_cos`,`p`.`pro_sto` AS `pro_sto`,`p`.`est_a` AS `est_a`,`p`.`est_b` AS `est_b`,`p`.`est_c` AS `est_c`,`p`.`crt_stock` AS `crt_stock` from `v_productos` `p` where `p`.`id_tipo` = 2 and `p`.`id_catg` <> 1 union select if(`p`.`crt_stock` = 1,2,3) AS `id_tipo_ins`,`p`.`id_pres` AS `id_pres`,'1' AS `1`,'1' AS `1`,`p`.`precio_compra`,`p`.`pro_cod` AS `pro_cod`,concat(`p`.`pro_nom`,' ',`p`.`pro_pre`) AS `pro_nom`,`p`.`pro_cat` AS `pro_cat`,'UNIDAD' AS `UNIDAD`,`p`.`pro_rec` AS `pro_rec`,`p`.`pro_cos` AS `pro_cos`,`p`.`pro_sto` AS `pro_sto`,`p`.`est_a` AS `est_a`,`p`.`est_b` AS `est_b`,`p`.`est_c` AS `est_c`,`p`.`crt_stock` AS `crt_stock` from `v_productos` `p` where `p`.`id_tipo` = 1 and `p`.`id_catg` <> 1 ;

-- Volcando estructura para vista factuyorest.v_insumos
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_insumos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_insumos` AS select `i`.`id_ins` AS `id_ins`,`i`.`id_catg` AS `id_catg`,`i`.`id_med` AS `id_med`,`i`.`cos_uni`,`m`.`grupo` AS `id_gru`,`i`.`cod_ins` AS `ins_cod`,`i`.`nomb_ins` AS `ins_nom`,`i`.`stock_min` AS `ins_sto`,`i`.`cos_uni` AS `ins_cos`,`i`.`estado` AS `ins_est`,`ic`.`descripcion` AS `ins_cat`,`m`.`descripcion` AS `ins_med` from ((`tm_insumo` `i` join `tm_insumo_catg` `ic` on(`i`.`id_catg` = `ic`.`id_catg`)) join `tm_tipo_medida` `m` on(`i`.`id_med` = `m`.`id_med`)) ;

-- Volcando estructura para vista factuyorest.v_inventario
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_inventario`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_inventario` AS select `e`.`id_tipo_ins` AS `id_tipo_ins`,`e`.`id_ins` AS `id_ins`,ifnull(`e`.`total`,0) AS `ent`,'0' AS `sal` from `v_inventario_ent` `e` union select `s`.`id_tipo_ins` AS `id_tipo_ins`,`s`.`id_ins` AS `id_ins`,'0' AS `ent`,ifnull(`s`.`total`,0) AS `sal` from `v_inventario_sal` `s` ;

-- Volcando estructura para vista factuyorest.v_inventario_ent
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_inventario_ent`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_inventario_ent` AS select `tm_inventario`.`id_tipo_ins` AS `id_tipo_ins`,`tm_inventario`.`id_ins` AS `id_ins`,if(`tm_inventario`.`id_tipo_ope` = 1 or `tm_inventario`.`id_tipo_ope` = 3,sum(`tm_inventario`.`cant`),0) AS `total` from `tm_inventario` where `tm_inventario`.`id_tipo_ope` <> 2 and `tm_inventario`.`id_tipo_ope` <> 4 and `tm_inventario`.`estado` <> 'i' group by `tm_inventario`.`id_tipo_ins`,`tm_inventario`.`id_ins` ;

-- Volcando estructura para vista factuyorest.v_inventario_sal
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_inventario_sal`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_inventario_sal` AS select `tm_inventario`.`id_tipo_ins` AS `id_tipo_ins`,`tm_inventario`.`id_ins` AS `id_ins`,if(`tm_inventario`.`id_tipo_ope` = 2 or `tm_inventario`.`id_tipo_ope` = 4,sum(`tm_inventario`.`cant`),0) AS `total` from `tm_inventario` where `tm_inventario`.`id_tipo_ope` <> 1 and `tm_inventario`.`id_tipo_ope` <> 3 and `tm_inventario`.`estado` <> 'i' group by `tm_inventario`.`id_tipo_ins`,`tm_inventario`.`id_ins` ;

-- Volcando estructura para vista factuyorest.v_listar_mesas
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_listar_mesas`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_listar_mesas` AS select `vm`.`id_mesa` AS `id_mesa`,`vm`.`forma` AS `forma`,`vm`.`id_salon` AS `id_salon`,`vm`.`nro_mesa` AS `nro_mesa`,`vm`.`estado` AS `estado`,`vm`.`desc_salon` AS `desc_salon`,`vo`.`id_pedido` AS `id_pedido`,`vo`.`fecha_pedido` AS `fecha_pedido`,`vo`.`nro_personas` AS `nro_personas` from (`v_mesas` `vm` left join `v_pedido_mesa` `vo` on(`vm`.`id_mesa` = `vo`.`id_mesa`)) order by `vm`.`nro_mesa` ;

-- Volcando estructura para vista factuyorest.v_mesas
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_mesas`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_mesas` AS select `m`.`id_mesa` AS `id_mesa`,`m`.`id_salon` AS `id_salon`,`m`.`forma` AS `forma`,`m`.`nro_mesa` AS `nro_mesa`,`m`.`estado` AS `estado`,`cm`.`descripcion` AS `desc_salon` from (`tm_mesa` `m` join `tm_salon` `cm` on(`m`.`id_salon` = `cm`.`id_salon`)) where `m`.`id_mesa` <> 0 and `cm`.`estado` <> 'i' order by `m`.`id_mesa` ;

-- Volcando estructura para vista factuyorest.v_pedidos_agrupados
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_pedidos_agrupados`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_pedidos_agrupados` AS select 1 AS `tipo_atencion`,`v_cocina_me`.`id_pedido` AS `id_pedido`,`v_cocina_me`.`id_areap` AS `id_areap`,`v_cocina_me`.`id_tipo` AS `id_tipo`,`v_cocina_me`.`id_pres` AS `id_pres`,sum(`v_cocina_me`.`cantidad`) AS `cantidad`,`v_cocina_me`.`comentario` AS `comentario`,`v_cocina_me`.`fecha_pedido` AS `fecha_pedido`,`v_cocina_me`.`fecha_envio` AS `fecha_envio`,`v_cocina_me`.`estado` AS `estado`,`v_cocina_me`.`nombre_prod` AS `nombre_prod`,`v_cocina_me`.`pres_prod` AS `pres_prod`,`v_cocina_me`.`nro_mesa` AS `nro_mesa`,`v_cocina_me`.`desc_salon` AS `desc_salon`,`v_cocina_me`.`ape_paterno` AS `ape_paterno`,`v_cocina_me`.`ape_materno` AS `ape_materno`,`v_cocina_me`.`nombres` AS `nombres`,`v_cocina_me`.`estado_pedido` AS `estado_pedido` from `v_cocina_me` group by `v_cocina_me`.`id_pedido`,`v_cocina_me`.`id_pres`,`v_cocina_me`.`fecha_pedido`,`v_cocina_me`.`comentario` union select 2 AS `tipo_atencion`,`v_cocina_mo`.`id_pedido` AS `id_pedido`,`v_cocina_mo`.`id_areap` AS `id_areap`,`v_cocina_mo`.`id_tipo` AS `id_tipo`,`v_cocina_mo`.`id_pres` AS `id_pres`,sum(`v_cocina_mo`.`cantidad`) AS `cantidad`,`v_cocina_mo`.`comentario` AS `comentario`,`v_cocina_mo`.`fecha_pedido` AS `fecha_pedido`,`v_cocina_mo`.`fecha_envio` AS `fecha_envio`,`v_cocina_mo`.`estado` AS `estado`,`v_cocina_mo`.`nombre_prod` AS `nombre_prod`,`v_cocina_mo`.`pres_prod` AS `pres_prod`,`v_cocina_mo`.`nro_pedido` AS `nro_pedido`,'MOSTRADOR' AS `MOSTRADOR`,`v_cocina_mo`.`ape_paterno` AS `ape_paterno`,`v_cocina_mo`.`ape_materno` AS `ape_materno`,`v_cocina_mo`.`nombres` AS `nombres`,`v_cocina_mo`.`estado_pedido` AS `estado_pedido` from `v_cocina_mo` group by `v_cocina_mo`.`id_pedido`,`v_cocina_mo`.`id_pres`,`v_cocina_mo`.`fecha_pedido`,`v_cocina_mo`.`comentario` union select 3 AS `tipo_atencion`,`v_cocina_de`.`id_pedido` AS `id_pedido`,`v_cocina_de`.`id_areap` AS `id_areap`,`v_cocina_de`.`id_tipo` AS `id_tipo`,`v_cocina_de`.`id_pres` AS `id_pres`,sum(`v_cocina_de`.`cantidad`) AS `cantidad`,`v_cocina_de`.`comentario` AS `comentario`,`v_cocina_de`.`fecha_pedido` AS `fecha_pedido`,`v_cocina_de`.`fecha_envio` AS `fecha_envio`,`v_cocina_de`.`estado` AS `estado`,`v_cocina_de`.`nombre_prod` AS `nombre_prod`,`v_cocina_de`.`pres_prod` AS `pres_prod`,`v_cocina_de`.`nro_pedido` AS `nro_pedido`,'DELIVERY' AS `DELIVERY`,`v_cocina_de`.`ape_paterno` AS `ape_paterno`,`v_cocina_de`.`ape_materno` AS `ape_materno`,`v_cocina_de`.`nombres` AS `nombres`,`v_cocina_de`.`estado_pedido` AS `estado_pedido` from `v_cocina_de` group by `v_cocina_de`.`id_pedido`,`v_cocina_de`.`id_pres`,`v_cocina_de`.`fecha_pedido`,`v_cocina_de`.`comentario` ;

-- Volcando estructura para vista factuyorest.v_pedido_delivery
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_pedido_delivery`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_pedido_delivery` AS select `p`.`id_pedido` AS `id_pedido`,`p`.`id_tipo_pedido` AS `id_tipo_pedido`,`p`.`id_usu` AS `id_usu`,`tp`.`descripcion` AS `desc_tp`,`pd`.`id_repartidor` AS `id_repartidor`,`p`.`fecha_pedido` AS `fecha_pedido`,`p`.`estado` AS `estado_pedido`,`pd`.`tipo_entrega` AS `tipo_entrega`,`pd`.`pedido_programado` AS `pedido_programado`,`pd`.`hora_entrega` AS `hora_entrega`,`pd`.`amortizacion` AS `amortizacion`,`pd`.`tipo_pago` AS `tipo_pago`,`pd`.`tipo_pago` AS `id_tpag`,`pd`.`paga_con` AS `paga_con`,`pd`.`comision_delivery` AS `comision_delivery`,`pd`.`nro_pedido` AS `nro_pedido`,`pd`.`id_cliente` AS `id_cliente`,`c`.`tipo_cliente` AS `tipo_cliente`,`c`.`dni` AS `dni_cliente`,`c`.`ruc` AS `ruc_cliente`,`pd`.`nombre_cliente` AS `nombre_cliente`,`pd`.`telefono_cliente` AS `telefono_cliente`,`pd`.`direccion_cliente` AS `direccion_cliente`,`pd`.`referencia_cliente` AS `referencia_cliente`,`pd`.`email_cliente` AS `email_cliente`,`r`.`desc_repartidor` AS `desc_repartidor` from (((`tm_pedido` `p` join `tm_pedido_delivery` `pd` on(`p`.`id_pedido` = `pd`.`id_pedido`)) join `v_repartidores` `r` on(`pd`.`id_repartidor` = `r`.`id_repartidor`)) join `tm_tipo_pago` `tp` on(`pd`.`tipo_pago` = `tp`.`id_tipo_pago`) join `tm_cliente` `c` on(`pd`.`id_cliente` = `c`.`id_cliente`)) where `p`.`id_pedido` <> 0 order by `p`.`id_pedido` desc ;

-- Volcando estructura para vista factuyorest.v_pedido_llevar
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_pedido_llevar`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_pedido_llevar` AS select `p`.`id_pedido` AS `id_pedido`,`p`.`id_tipo_pedido` AS `id_tipo_pedido`,`p`.`id_usu` AS `id_usu`,`p`.`fecha_pedido` AS `fecha_pedido`,`p`.`estado` AS `estado_pedido`,`pl`.`nro_pedido` AS `nro_pedido`,`pl`.`nomb_cliente` AS `nombre_cliente` from (`tm_pedido` `p` join `tm_pedido_llevar` `pl` on(`p`.`id_pedido` = `pl`.`id_pedido`)) where `p`.`id_pedido` <> 0 order by `p`.`id_pedido` desc ;

-- Volcando estructura para vista factuyorest.v_pedido_mesa
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_pedido_mesa`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_pedido_mesa` AS select `p`.`id_pedido` AS `id_pedido`,`p`.`id_tipo_pedido` AS `id_tipo_pedido`,`p`.`id_usu` AS `id_usu`,`pm`.`id_mesa` AS `id_mesa`,`p`.`fecha_pedido` AS `fecha_pedido`,`p`.`estado` AS `estado_pedido`,`pm`.`nomb_cliente` AS `nombre_cliente`,`pm`.`nro_personas` AS `nro_personas`,`vm`.`nro_mesa` AS `nro_mesa`,`vm`.`desc_salon` AS `desc_salon`,`vm`.`estado` AS `estado_mesa`,concat(`u`.`nombres`,' ',`u`.`ape_paterno`) AS `nombre_mozo` from (((`tm_pedido` `p` join `tm_pedido_mesa` `pm` on(`p`.`id_pedido` = `pm`.`id_pedido`)) join `v_mesas` `vm` on(`pm`.`id_mesa` = `vm`.`id_mesa`)) join `tm_usuario` `u` on(`pm`.`id_mozo` = `u`.`id_usu`)) where `p`.`id_pedido` <> 0 and `p`.`estado` = 'a' order by `p`.`id_pedido` desc ;

-- Volcando estructura para vista factuyorest.v_productos
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_productos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_productos` AS select `pp`.`id_pres` AS `id_pres`,`pp`.`id_prod` AS `id_prod`,`pp`.`impuesto_icbper`,`pp`.`impuesto_compra`,`pp`.`precio_compra`,`p`.`id_tipo` AS `id_tipo`,`p`.`id_catg` AS `id_catg`,`p`.`id_areap` AS `id_areap`,`cp`.`descripcion` AS `pro_cat`,`pp`.`cod_prod` AS `pro_cod`,`p`.`nombre` AS `pro_nom`,`pp`.`presentacion` AS `pro_pre`,ifnull(`pp`.`descripcion`,'') AS `pro_des`,`pp`.`precio` AS `pro_cos`,`pp`.`precio2` AS `pro_cos2`,`pp`.`ordenins` AS `ordenins`,`pp`.`precio_delivery` AS `pro_cos_del`,`pp`.`receta` AS `pro_rec`,`pp`.`stock_min` AS `pro_sto`,`pp`.`impuesto` AS `pro_imp`,`pp`.`margen` AS `pro_mar`,`pp`.`favorito` AS `favorito`,`pp`.`precios` AS `precios`,`pp`.`igv` AS `pro_igv`,`pp`.`imagen` AS `pro_img`,`cp`.`delivery` AS `del_a`,`p`.`delivery` AS `del_b`,`pp`.`delivery` AS `del_c`,`cp`.`estado` AS `est_a`,`p`.`estado` AS `est_b`,`pp`.`estado` AS `est_c`,`pp`.`crt_stock` AS `crt_stock` from ((`tm_producto_pres` `pp` join `tm_producto` `p` on(`pp`.`id_prod` = `p`.`id_prod`)) join `tm_producto_catg` `cp` on(`p`.`id_catg` = `cp`.`id_catg`)) where `pp`.`id_pres` <> 0 order by `pp`.`id_pres` desc ;

-- Volcando estructura para vista factuyorest.v_prod_favorito
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_prod_favorito`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_prod_favorito` AS select `pp`.`id_pres` AS `id_pres`,`pp`.`id_prod` AS `id_prod`,`pp`.`impuesto_icbper`,`pp`.`impuesto_compra`,`pp`.`precio_compra`,`p`.`id_tipo` AS `id_tipo`,`p`.`id_catg` AS `id_catg`,`p`.`id_areap` AS `id_areap`,`cp`.`descripcion` AS `pro_cat`,`pp`.`cod_prod` AS `pro_cod`,`p`.`nombre` AS `pro_nom`,`pp`.`presentacion` AS `pro_pre`,ifnull(`pp`.`descripcion`,'') AS `pro_des`,`pp`.`precio` AS `pro_cos`,`pp`.`precio2` AS `pro_cos2`,`pp`.`ordenins` AS `ordenins`,`pp`.`precio_delivery` AS `pro_cos_del`,`pp`.`receta` AS `pro_rec`,`pp`.`stock_min` AS `pro_sto`,`pp`.`impuesto` AS `pro_imp`,`pp`.`margen` AS `pro_mar`,`pp`.`favorito` AS `favorito`,`pp`.`precios` AS `precios`,`pp`.`igv` AS `pro_igv`,`pp`.`imagen` AS `pro_img`,`cp`.`delivery` AS `del_a`,`p`.`delivery` AS `del_b`,`pp`.`delivery` AS `del_c`,`cp`.`estado` AS `est_a`,`p`.`estado` AS `est_b`,`pp`.`estado` AS `est_c`,`pp`.`crt_stock` AS `crt_stock` from ((`tm_producto_pres` `pp` join `tm_producto` `p` on(`pp`.`id_prod` = `p`.`id_prod`)) join `tm_producto_catg` `cp` on(`p`.`id_catg` = `cp`.`id_catg`)) where `pp`.`id_pres` <> 0  and `pp`.`favorito` = 1 order by `pp`.`id_pres` desc ;

-- Volcando estructura para vista factuyorest.v_repartidores
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_repartidores`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_repartidores` AS select `tm_usuario`.`id_usu` AS `id_repartidor`,concat(`tm_usuario`.`nombres`,' ',`tm_usuario`.`ape_paterno`,' ',`tm_usuario`.`ape_materno`) AS `desc_repartidor` from `tm_usuario` where `tm_usuario`.`id_rol` = 6 union select `tm_repartidor`.`id_repartidor` AS `id_repartidor`,`tm_repartidor`.`descripcion` AS `desc_repartidor` from `tm_repartidor` ;

-- Volcando estructura para vista factuyorest.v_stock
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_stock`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_stock` AS (select `a`.`id_tipo_ins` AS `id_tipo_ins`,`a`.`id_ins` AS `id_ins`,sum(`a`.`ent`) AS `ent`,sum(`a`.`sal`) AS `sal`,`b`.`est_a` AS `est_a`,`b`.`est_b` AS `est_b`,if(`a`.`ent` - `a`.`sal` > `b`.`ins_sto`,1,0) AS `debajo_stock` from (`v_inventario` `a` join `v_insprod` `b` on(`a`.`id_tipo_ins` = `b`.`id_tipo_ins` and `a`.`id_ins` = `b`.`id_ins`)) where `b`.`est_a` = 'a' and `b`.`est_b` = 'a' group by `a`.`id_tipo_ins`,`a`.`id_ins`) ;

-- Volcando estructura para vista factuyorest.v_stock_pedido
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_stock_pedido`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_stock_pedido` AS (select `c`.`id_pres` AS `id_ins`,ifnull((select sum(`b`.`ent`) from `v_inventario` `b` where `b`.`id_ins` = `c`.`id_pres` group by `c`.`id_pres`),0) AS `ent`,ifnull((select sum(`a`.`cant`) from `tm_detalle_pedido` `a` where `a`.`id_pres` = `c`.`id_pres` and `a`.`estado` = 'a' group by `c`.`id_pres`),0) AS `sal`,(select `d`.`crt_stock` from `tm_producto_pres` `d` where `d`.`id_pres` = `c`.`id_pres` group by `c`.`id_pres`) AS `control` from `tm_producto_pres` `c` where `c`.`crt_stock` = 1 group by `c`.`id_pres`) ;

-- Volcando estructura para vista factuyorest.v_usuarios
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_usuarios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_usuarios` AS select `u`.`id_usu` AS `id_usu`,`u`.`id_rol` AS `id_rol`,`u`.`id_areap` AS `id_areap`,`u`.`dni` AS `dni`,`u`.`editarprecio` AS `editarprecio`,`u`.`ape_paterno` AS `ape_paterno`,`u`.`ape_materno` AS `ape_materno`,`u`.`nombres` AS `nombres`,`u`.`email` AS `email`,`u`.`usuario` AS `usuario`,`u`.`contrasena` AS `contrasena`,`u`.`estado` AS `estado`,`u`.`imagen` AS `imagen`,`r`.`descripcion` AS `desc_r`,`p`.`nombre` AS `desc_ap` from ((`tm_usuario` `u` join `tm_rol` `r` on(`u`.`id_rol` = `r`.`id_rol`)) left join `tm_area_prod` `p` on(`u`.`id_areap` = `p`.`id_areap`)) where `u`.`id_usu` <> 0 order by `u`.`id_usu` desc ;

-- Volcando estructura para vista factuyorest.v_ventas_con
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_ventas_con`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_ventas_con` AS select `v`.`id_venta` AS `id_ven`,`v`.`id_pedido` AS `id_ped`,`v`.`nvoriginal`,`v`.`nvfecha`,`v`.`id_tipo_pedido` AS `id_tped`,`v`.`id_cliente` AS `id_cli`,`v`.`id_tipo_doc` AS `id_tdoc`,`v`.`id_tipo_pago` AS `id_tpag`,`v`.`id_usu` AS `id_usu`,`v`.`id_apc` AS `id_apc`,`v`.`serie_doc` AS `ser_doc`,`v`.`nro_doc` AS `nro_doc`,`v`.`cambiomanual` AS `cambiomanual`,`v`.`pago_efe` AS `pago_efe`,`v`.`pago_efe_none` AS `pago_efe_none`,`v`.`pago_tar` AS `pago_tar`,`v`.`pago_yape` AS `pago_yape`,`v`.`pago_plin` AS `pago_plin`,`v`.`pago_tran` AS `pago_tran`,`v`.`descuento_monto` AS `desc_monto`,`v`.`descuento_tipo` AS `desc_tipo`,`v`.`descuento_personal` AS `desc_personal`,`v`.`descuento_motivo` AS `desc_motivo`,`v`.`comision_tarjeta` AS `comis_tar`,`v`.`comision_delivery` AS `comis_del`,`v`.`igv` AS `igv`,`v`.`total` AS `total`,`v`.`codigo_operacion` AS `codigo_operacion`,`v`.`fecha_venta` AS `fec_ven`,`v`.`estado` AS `estado`,`v`.`enviado_sunat` AS `enviado_sunat`,`v`.`code_respuesta_sunat` AS `code_respuesta_sunat`,`v`.`descripcion_sunat_cdr` AS `descripcion_sunat_cdr`,`v`.`name_file_sunat` AS `name_file_sunat`,`v`.`hash_cdr` AS `hash_cdr`,`v`.`hash_cpe` AS `hash_cpe`,`v`.`fecha_vencimiento` AS `fecha_vencimiento`,`td`.`descripcion` AS `desc_td`,`tp`.`descripcion` AS `desc_tp`,`v`.`consumo` AS `consumo`,`v`.`consumo_desc` AS `consumo_desc`,`v`.`observacion` AS `observacion`,concat(`tu`.`ape_paterno`,' ',`tu`.`ape_materno`,' ',`tu`.`nombres`) AS `desc_usu` from (((`tm_venta` `v` join `tm_tipo_doc` `td` on(`v`.`id_tipo_doc` = `td`.`id_tipo_doc`)) join `tm_tipo_pago` `tp` on(`v`.`id_tipo_pago` = `tp`.`id_tipo_pago`)) join `tm_usuario` `tu` on(`v`.`id_usu` = `tu`.`id_usu`)) where `v`.`id_venta` <> 0 order by `v`.`id_venta` desc ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
