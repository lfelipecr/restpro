
DELIMITER $$
--
-- Procedimientos
--

DROP PROCEDURE IF EXISTS `sp_actualizar_cdr_baja`$$
CREATE PROCEDURE `sp_actualizar_cdr_baja` (`p_id_comunicacion` INT, `p_hash_cpe` VARCHAR(100), `p_hash_cdr` VARCHAR(100), `p_code_respuesta_sunat` VARCHAR(5), `p_descripcion_sunat_cdr` VARCHAR(300), `p_name_file_sunat` VARCHAR(80), OUT `mensaje` VARCHAR(100))  BEGIN
	IF(NOT EXISTS(SELECT * FROM comunicacion_baja WHERE id_comunicacion=p_id_comunicacion))THEN
		SET mensaje='No existe la comunicación de baja';
	ELSE
		UPDATE comunicacion_baja SET enviado_sunat=1,hash_cpe=p_hash_cpe,hash_cdr=p_hash_cdr,code_respuesta_sunat=p_code_respuesta_sunat,descripcion_sunat_cdr=p_descripcion_sunat_cdr,name_file_sunat=p_name_file_sunat WHERE id_comunicacion=p_id_comunicacion;
		SET mensaje='Actualizado correctamente';
	END IF;
END$$


DROP PROCEDURE IF EXISTS `sp_actualizar_cdr_resumen`$$
CREATE PROCEDURE `sp_actualizar_cdr_resumen` (`p_id_resumen` INT, `p_hash_cpe` VARCHAR(100), `p_hash_cdr` VARCHAR(100), `p_code_respuesta_sunat` VARCHAR(5), `p_descripcion_sunat_cdr` VARCHAR(300), `p_name_file_sunat` VARCHAR(80), OUT `mensaje` VARCHAR(100))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `sp_consultar_boletas_resumen`$$
CREATE PROCEDURE `sp_consultar_boletas_resumen` (IN `p_fecha_resumen` DATE)  BEGIN
    SELECT
        '03' AS 'tipo_comprobante',DATE_FORMAT(v.fecha_venta,'%Y-%m-%d') AS 'fecha_resumen',IF(c.dni="" OR c.dni="-",0,1) AS 'tipo_documento',
        IF(c.dni="" OR c.dni="-","00000000",c.dni) AS "dni",c.nombres AS 'cliente',v.serie_doc AS 'serie_doc',
        v.nro_doc AS 'nro_doc',"PEN" AS 'tipo_moneda',ROUND((v.total/(1 + v.igv)) *(v.igv),2) AS 'total_igv',
        ROUND((v.total/(1 + v.igv)),2) AS 'total_gravadas',ROUND(v.total,2) AS 'total_facturado',IF(v.estado="a",1,3) AS 'status_code',v.id_venta
    FROM tm_venta v 
    INNER JOIN tm_cliente c ON c.id_cliente=v.id_cliente
    WHERE v.id_tipo_doc=1 AND v.enviado_sunat!="1" AND DATE_FORMAT(v.fecha_venta,"%Y-%m-%d") = p_fecha_resumen
    ORDER BY v.fecha_venta ASC;
END$$


DROP PROCEDURE IF EXISTS `sp_consultar_documento`$$
CREATE PROCEDURE `sp_consultar_documento` (`p_id_venta` INT)  BEGIN
	SELECT
		IF(id_tipo_doc='1','03','01') AS tipo_comprobante, IF(c.dni="" OR c.dni="-",0,1) AS 'tipo_documento',
		IF(c.dni="" OR c.dni="-","00000000",c.dni) AS "dni",v.serie_doc AS 'serie_doc', v.nro_doc AS 'nro_doc',"PEN" AS 'tipo_moneda',ROUND((v.total/(1 + v.igv)) *(v.igv),2) AS 'total_igv',
		ROUND((v.total/(1 + v.igv)),2) AS 'total_gravadas',ROUND(v.total,2) AS 'total_facturado',v.id_venta, v.estado
	FROM tm_venta v INNER JOIN tm_cliente c ON c.id_cliente=v.id_cliente
	WHERE v.id_venta = p_id_venta;
    END$$


DROP PROCEDURE IF EXISTS `sp_generar_numerobaja`$$
CREATE PROCEDURE `sp_generar_numerobaja` (`p_tipo_doc` CHAR(3), OUT `numerobaja` CHAR(5))  BEGIN
	DECLARE contador INT;
	IF(NOT EXISTS(SELECT * FROM comunicacion_baja WHERE tipo_doc = p_tipo_doc))THEN
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM comunicacion_baja WHERE tipo_doc = p_tipo_doc);
		SET numerobaja:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	ELSE		
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM comunicacion_baja WHERE tipo_doc = p_tipo_doc);
		SET numerobaja:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	END IF;
END$$


DROP PROCEDURE IF EXISTS `sp_generar_numeroresumen`$$
CREATE PROCEDURE `sp_generar_numeroresumen` (OUT `numeroresumen` CHAR(5))  BEGIN
	DECLARE contador INT;
	IF(NOT EXISTS(SELECT * FROM resumen_diario))THEN
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM resumen_diario);
		SET numeroresumen:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	ELSE		
		SET contador:= (SELECT IFNULL(MAX(correlativo), 0)+1 AS 'codigo' FROM resumen_diario);
		SET numeroresumen:= (SELECT LPAD(contador,5,'0') AS 'correlativo');
	END IF;
    END$$


DROP PROCEDURE IF EXISTS `usp_cajaAperturar`$$
CREATE PROCEDURE `usp_cajaAperturar` (IN `_flag` INT(11), IN `_id_usu` INT(11), IN `_id_caja` INT(11), IN `_id_turno` INT(11), IN `_fecha_aper` DATETIME, IN `_monto_aper` DECIMAL(10,2))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_cajaCerrar`$$
CREATE PROCEDURE `usp_cajaCerrar` (IN `_flag` INT(11), IN `_id_apc` INT(11), IN `_fecha_cierre` DATETIME, IN `_monto_cierre` DECIMAL(10,2), IN `_monto_sistema` DECIMAL(10,2), IN `_stock_pollo` VARCHAR(11))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_comprasAnular`$$
CREATE PROCEDURE `usp_comprasAnular` (IN `_flag` INT(11), IN `_id_compra` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_comprasCreditoCuotas`$$
CREATE PROCEDURE `usp_comprasCreditoCuotas` (IN `_flag` INT(11), IN `_id_credito` INT(11), IN `_id_usu` INT(11), IN `_id_apc` INT(11), IN `_importe` DECIMAL(10,2), IN `_fecha` DATETIME, IN `_egreso` INT(11), IN `_monto_egreso` DECIMAL(10,2), IN `_monto_amortizado` DECIMAL(10,2), IN `_total_credito` DECIMAL(10,2))  BEGIN
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
	
END$$


DROP PROCEDURE IF EXISTS `usp_comprasRegProveedor`$$
CREATE PROCEDURE `usp_comprasRegProveedor` (IN `_flag` INT(11), IN `_id_prov` INT(11), IN `_ruc` VARCHAR(13), IN `_razon_social` VARCHAR(100), IN `_direccion` VARCHAR(100), IN `_telefono` INT(9), IN `_email` VARCHAR(45), IN `_contacto` VARCHAR(45))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configAlmacenes`$$
CREATE PROCEDURE `usp_configAlmacenes` (IN `_flag` INT(11), IN `_nombre` VARCHAR(45), IN `_estado` VARCHAR(5), IN `_idAlm` INT(11))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configAreasProd`$$
CREATE PROCEDURE `usp_configAreasProd` (IN `_flag` INT(11), IN `_id_areap` INT(11), IN `_id_imp` INT(11), IN `_nombre` VARCHAR(45), IN `_estado` VARCHAR(5))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configCajas`$$
CREATE PROCEDURE `usp_configCajas` (IN `_flag` INT(11), IN `_id_caja` INT(11), IN `_descripcion` VARCHAR(45), IN `_estado` VARCHAR(5))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configEliminarCategoriaIns`$$
CREATE PROCEDURE `usp_configEliminarCategoriaIns` (IN `_id_catg` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_configEliminarCategoriaProd`$$
CREATE PROCEDURE `usp_configEliminarCategoriaProd` (IN `_id_catg` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_configImpresoras`$$
CREATE PROCEDURE `usp_configImpresoras` (IN `_flag` INT(11), IN `_id_imp` INT(11), IN `_nombre` VARCHAR(50), IN `_estado` VARCHAR(5))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_configInsumo`$$
CREATE PROCEDURE `usp_configInsumo` (IN `_flag` INT(11), IN `_idCatg` INT(11), IN `_idMed` INT(11), IN `_cod` VARCHAR(10), IN `_nombre` VARCHAR(45), IN `_stock` INT(11), IN `_costo` DECIMAL(10,2), IN `_estado` VARCHAR(5), IN `_idIns` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_configInsumoCatgs`$$
CREATE PROCEDURE `usp_configInsumoCatgs` (IN `_flag` INT(11), IN `_descC` VARCHAR(45), IN `_idCatg` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_configMesas`$$
CREATE PROCEDURE `usp_configMesas` (IN `_flag` INT(11), IN `_id_mesa` INT(11), IN `_id_salon` INT(11), IN `_nro_mesa` VARCHAR(5), IN `_forma` INT(11), IN `_estado` VARCHAR(45))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configProducto`$$
CREATE PROCEDURE `usp_configProducto` (IN `_flag` INT(11), IN `_id_prod` INT(11), IN `_id_tipo` INT(11), IN `_id_catg` INT(11), IN `_id_areap` INT(11), IN `_nombre` VARCHAR(45), IN `_notas` VARCHAR(200), IN `_delivery` INT(1), IN `_estado` VARCHAR(1))  BEGIN
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
	
	END$$


DROP PROCEDURE IF EXISTS `usp_configProductoCatgs`$$
CREATE PROCEDURE `usp_configProductoCatgs` (IN `_flag` INT(11), IN `_id_catg` INT(11), IN `_descripcion` VARCHAR(45), IN `_delivery` INT(1), IN `_orden` INT(11), IN `_imagen` VARCHAR(200), IN `_estado` VARCHAR(1))  BEGIN	
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
	
	END$$


DROP PROCEDURE IF EXISTS `usp_configProductoIngrs`$$
CREATE PROCEDURE `usp_configProductoIngrs` (IN `_flag` INT(11), IN `_id_pi` INT(11), IN `_id_pres` INT(11), IN `_id_tipo_ins` INT(11), IN `_id_ins` INT(11), IN `_id_med` INT(11), IN `_cant` FLOAT)  BEGIN
	if _flag = 1 then
		INSERT INTO tm_producto_ingr (id_pres,id_tipo_ins,id_ins,id_med,cant) VALUES (_id_pres, _id_tipo_ins, _id_ins, _id_med, _cant);
	end if;
	if _flag = 2 then
		UPDATE tm_producto_ingr SET cant = _cant WHERE id_pi = _id_pi;
	end if;
	if _flag = 3 then
		DELETE FROM tm_producto_ingr WHERE id_pi = _id_pi;
	end if;
    END$$


DROP PROCEDURE IF EXISTS `usp_configProductoPres`$$
CREATE PROCEDURE `usp_configProductoPres` (IN `_flag` INT(11), IN `_id_pres` INT(11), IN `_id_prod` INT(11), IN `_cod_prod` VARCHAR(45), IN `_presentacion` VARCHAR(45), IN `_descripcion` VARCHAR(200), IN `_precio` DECIMAL(10,2), IN `_precio2` DECIMAL(10,2), IN `_precio_delivery` DECIMAL(10,2), IN `_receta` INT(1), IN `_stock_min` INT(11), IN `_stock_limit` INT(1), IN `_impuesto` INT(1), IN `_impuesto_icbper` INT(1), IN `_delivery` INT(1), IN `_margen` INT(1), IN `_igv` DECIMAL(10,2), IN `_imagen` VARCHAR(200), IN `_ordenins` INT(11), IN `_favorito` INT(11), IN `_estado` VARCHAR(1))  BEGIN
		
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configRol`$$
CREATE PROCEDURE `usp_configRol` (IN `_flag` INT(11), IN `_desc` VARCHAR(45), IN `_idRol` INT(11))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configSalones`$$
CREATE PROCEDURE `usp_configSalones` (IN `_flag` INT(11), IN `_id_salon` INT(11), IN `_descripcion` VARCHAR(45), IN `_estado` VARCHAR(5))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_configUsuario`$$
CREATE PROCEDURE `usp_configUsuario` (IN `_flag` INT(11), IN `_id_usu` INT(11), IN `_id_rol` INT(11), IN `_id_areap` INT(11), IN `_dni` VARCHAR(10), IN `_ape_paterno` VARCHAR(45), IN `_ape_materno` VARCHAR(45), IN `_nombres` VARCHAR(45), IN `_email` VARCHAR(100), IN `_usuario` VARCHAR(45), IN `_contrasena` VARCHAR(45), IN `_imagen` VARCHAR(45), IN `_editarprecio` INT(11), IN `_turno_ing` VARCHAR(45), IN `_turno_sal` VARCHAR(45))  BEGIN

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

	END$$


DROP PROCEDURE IF EXISTS `usp_invESAnular`$$
CREATE PROCEDURE `usp_invESAnular` (IN `_flag` INT(11), IN `_id_es` INT(11), IN `_id_tipo` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_optPedidos`$$
CREATE PROCEDURE `usp_optPedidos` (IN `_flag` INT(11))  BEGIN
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
			
    END$$


DROP PROCEDURE IF EXISTS `usp_restCancelarPedido`$$
CREATE PROCEDURE `usp_restCancelarPedido` (IN `_flag` INT(11), IN `_id_usu` INT(11), IN `_id_pres` INT(11), IN `_id_pedido` INT(11), IN `_estado_pedido` VARCHAR(5), IN `_fecha_pedido` DATETIME, IN `_fecha_envio` DATETIME, IN `_codigo_seguridad` VARCHAR(50), IN `_filtro_seguridad` VARCHAR(50))  BEGIN
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
	
    END$$


DROP PROCEDURE IF EXISTS `usp_restEditarVentaDocumento`$$
CREATE PROCEDURE `usp_restEditarVentaDocumento` (`_flag` INT(11), `_id_venta` INT(11), `_id_cliente` INT(11), `_id_tipo_documento` INT(11))  BEGIN
	DECLARE _cod INT DEFAULT 1;
	IF _flag = 1 THEN
		-- SELECT td.serie,CONCAT(LPAD(COUNT(id_venta)+(td.numero),8,'0')) AS numero INTO @serie, @numero
		-- FROM tm_venta AS v INNER JOIN tm_tipo_doc AS td ON v.id_tipo_doc = td.id_tipo_doc
		-- WHERE v.id_tipo_doc = _id_tipo_documento AND v.serie_doc = td.serie;

		-- // Obtenemos la serie y el numero en que se inicia la serie
		SELECT serie,numero INTO @serie, @numinit
		FROM tm_tipo_doc 
		WHERE id_tipo_doc = _id_tipo_documento;

		SET @numactual = 0;
		
		-- // revisamos las emisiones en la BD con el numero de serie, y sacamos el nmero actual en la que esta
		SELECT nro_doc INTO @numactual
		FROM tm_venta
		WHERE id_tipo_doc = _id_tipo_documento AND serie_doc = @serie
		ORDER BY nro_doc DESC LIMIT 1;

		-- hacemos comparaciones para dar el número correcto
		IF (SELECT @numactual) > (SELECT @numinit) THEN

			SET @numero = @numactual+1;

		ELSEIF (SELECT @numactual) < (SELECT @numinit) THEN

			SET @numero = @numinit;

		ELSEIF (SELECT @numactual) = (SELECT @numinit) THEN

			SET @numero = @numinit+1;

		END IF;
		
		SELECT 0 INTO @num_pro;
		
		UPDATE tm_venta SET id_cliente = _id_cliente, id_tipo_doc = _id_tipo_documento, serie_doc = @serie, nro_doc = @numero, id_promo = 1 WHERE id_venta = _id_venta;

		-- SELECT @serie as cod;
	END IF;
END$$


DROP PROCEDURE IF EXISTS `usp_restEditarVentaDocumento`$$
CREATE PROCEDURE `usp_restEditarVentaDocumento` (`_flag` INT(11), `_id_venta` INT(11), `_id_cliente` INT(11), `_id_tipo_documento` INT(11))  BEGIN
	DECLARE _cod INT DEFAULT 1;
	 
	IF _flag = 1 THEN
		SELECT td.serie,CONCAT(LPAD(COUNT(id_venta)+(td.numero),8,'0')) AS numero INTO @serie, @numero
		FROM tm_venta AS v INNER JOIN tm_tipo_doc AS td ON v.id_tipo_doc = td.id_tipo_doc
		WHERE v.id_tipo_doc = _id_tipo_documento AND v.serie_doc = td.serie;
		UPDATE tm_venta SET id_cliente = _id_cliente, id_tipo_doc = _id_tipo_documento, serie_doc = @serie, nro_doc = @numero WHERE id_venta = _id_venta;
	END IF;
    END$$


DROP PROCEDURE IF EXISTS `usp_restEmitirVenta`$$
CREATE PROCEDURE `usp_restEmitirVenta` (`_flag` INT(11), `_dividir_cuenta` INT(11), `_id_pedido` INT(11), `_tipo_pedido` INT(11), `_tipo_entrega` VARCHAR(1), `_id_cliente` INT(11), `_id_tipo_doc` INT(11), `_id_tipo_pago` INT(11), `_id_usu` INT(11), `_id_apc` INT(11), `_pago_efe_none` DECIMAL(10,2), `_pago_tar` DECIMAL(10,2), `_pago_yape` DECIMAL(10,2), `_pago_plin` DECIMAL(10,2), `_pago_tran` DECIMAL(10,2), `_descuento_tipo` CHAR(1), `_descuento_personal` INT(11), `_descuento_monto` DECIMAL(10,2), `_descuento_motivo` VARCHAR(200), `_comision_tarjeta` DECIMAL(10,2), `_comision_delivery` DECIMAL(10,2), `_igv` DECIMAL(10,2), `_total` DECIMAL(10,2), `_codigo_operacion` VARCHAR(20), `_fecha_venta` DATETIME)  BEGIN
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
	
	END$$


DROP PROCEDURE IF EXISTS `usp_restEmitirVentaDet`$$
CREATE PROCEDURE `usp_restEmitirVentaDet` (IN `_flag` INT(11), IN `_id_venta` INT(11), IN `_id_pedido` INT(11), IN `_fecha` DATETIME)  BEGIN
    
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
    END$$


DROP PROCEDURE IF EXISTS `usp_restOpcionesMesa`$$
CREATE PROCEDURE `usp_restOpcionesMesa` (IN `_flag` INT(11), IN `_cod_mesa_origen` INT(11), IN `_cod_mesa_destino` INT(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_restRegCliente`$$
CREATE PROCEDURE `usp_restRegCliente` (IN `_flag` INT(11), IN `_id_cliente` INT(11), IN `_tipo_cliente` INT(11), IN `_dni` VARCHAR(10), IN `_ruc` VARCHAR(13), IN `_nombres` VARCHAR(200), IN `_razon_social` VARCHAR(100), IN `_telefono` INT(11), IN `_fecha_nac` DATE, IN `_correo` VARCHAR(100), IN `_direccion` VARCHAR(100), IN `_referencia` VARCHAR(100))  BEGIN
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
END$$


DROP PROCEDURE IF EXISTS `usp_restRegDelivery`$$
CREATE PROCEDURE `usp_restRegDelivery` (IN `_flag` INT(11), IN `_tipo_canal` INT(11), IN `_id_tipo_pedido` INT(11), IN `_id_apc` INT(11), IN `_id_usu` INT(11), IN `_fecha_pedido` DATETIME, IN `_id_cliente` INT(11), IN `_id_repartidor` INT(11), IN `_tipo_entrega` INT(11), IN `_tipo_pago` INT(11), IN `_pedido_programado` INT(11), IN `_hora_entrega` TIME, IN `_nombre_cliente` VARCHAR(100), IN `_telefono_cliente` VARCHAR(20), IN `_direccion_cliente` VARCHAR(100), IN `_referencia_cliente` VARCHAR(100), IN `_email_cliente` VARCHAR(200), IN `_id_tdoc` INT(11), IN `_num_cliente` VARCHAR(11))  BEGIN
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
    END$$


DROP PROCEDURE IF EXISTS `usp_restRegMesa`$$
CREATE PROCEDURE `usp_restRegMesa` (IN `_flag` INT(11), IN `_id_tipo_pedido` INT(11), IN `_id_apc` INT(11), IN `_id_usu` INT(11), IN `_fecha_pedido` DATETIME, IN `_id_mesa` INT(11), IN `_id_mozo` INT(11), IN `_nomb_cliente` VARCHAR(45), IN `_nro_personas` INT(11))  BEGIN
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
	END$$


DROP PROCEDURE IF EXISTS `usp_restRegMostrador`$$
CREATE PROCEDURE `usp_restRegMostrador` (IN `_flag` INT(11), IN `_id_tipo_pedido` INT(11), IN `_id_apc` INT(11), IN `_id_usu` INT(11), IN `_fecha_pedido` DATETIME, IN `_nomb_cliente` VARCHAR(45))  BEGIN
	DECLARE _filtro INT DEFAULT 1;
	
	IF _flag = 1 THEN
		
		INSERT INTO tm_pedido (id_tipo_pedido,id_apc,id_usu,fecha_pedido) VALUES (_id_tipo_pedido, _id_apc, _id_usu, _fecha_pedido);
		
		SELECT @@IDENTITY INTO @id;
		
		SELECT CONCAT(LPAD(count(t.nro_pedido)+1,5,'0')) AS codigo INTO @nro_pedido FROM tm_pedido_llevar AS t INNER JOIN tm_pedido AS p ON t.id_pedido = p.id_pedido WHERE p.id_tipo_pedido = 2 and p.estado <> 'z'; 
		
		INSERT INTO tm_pedido_llevar (id_pedido,nro_pedido,nomb_cliente) VALUES (@id, @nro_pedido, _nomb_cliente);
		
		SELECT _filtro AS fil, @id AS id_pedido;
	
	END IF;
	END$$


DROP PROCEDURE IF EXISTS `usp_tableroControl`$$
CREATE PROCEDURE `usp_tableroControl` (IN `_flag` INT(11), IN `_codDia` INT(11), IN `_fecha` DATE, IN `_feSei` DATE, IN `_feCin` DATE, IN `_feCua` DATE, IN `_feTre` DATE, IN `_feDos` DATE, IN `_feUno` DATE)  BEGIN
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
    END$$

DROP PROCEDURE IF EXISTS `sp_estadistica_g01`$$
CREATE PROCEDURE `sp_estadistica_g01`(`mes_` CHAR(2), `anio_` CHAR(4)) BEGIN 
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
	END$$

DROP PROCEDURE IF EXISTS `sp_estadistica_g02_compras`$$
CREATE PROCEDURE `sp_estadistica_g02_compras`(`m1_` CHAR(2), `a1_` CHAR(4), `m2_` CHAR(2), `a2_` CHAR(4), `m3_` CHAR(2), `a3_` CHAR(4), `m4_` CHAR(2), `a4_` CHAR(4))
	BEGIN
		SELECT
			SUM(IF(MONTH(fecha_c) = m1_ AND YEAR(fecha_c) = a1_,  total, 0)) AS compra_1,
			SUM(IF(MONTH(fecha_c) = m2_ AND YEAR(fecha_c) = a2_,  total, 0)) AS compra_2,
			SUM(IF(MONTH(fecha_c) = m3_ AND YEAR(fecha_c) = a3_,  total, 0)) AS compra_3,
			SUM(IF(MONTH(fecha_c) = m4_ AND YEAR(fecha_c) = a4_,  total, 0)) AS compra_4
		FROM tm_compra
		ORDER BY fecha_c ASC;
	END$$

DROP PROCEDURE IF EXISTS `sp_estadistica_g02_ventas`$$
CREATE PROCEDURE `sp_estadistica_g02_ventas`(`m1_` CHAR(2), `a1_` CHAR(4), `m2_` CHAR(2), `a2_` CHAR(4), `m3_` CHAR(2), `a3_` CHAR(4), `m4_` CHAR(2), `a4_` CHAR(4))
	BEGIN
		SELECT
			SUM(IF(MONTH(fecha_venta) = m1_ AND YEAR(fecha_venta) = a1_,  total, 0)) AS venta_1,
			SUM(IF(MONTH(fecha_venta) = m2_ AND YEAR(fecha_venta) = a2_,  total, 0)) AS venta_2,
			SUM(IF(MONTH(fecha_venta) = m3_ AND YEAR(fecha_venta) = a3_,  total, 0)) AS venta_3,
			SUM(IF(MONTH(fecha_venta) = m4_ AND YEAR(fecha_venta) = a4_,  total, 0)) AS venta_4
		FROM v_estadistica
		ORDER BY fecha_venta ASC;
	END$$

DROP PROCEDURE IF EXISTS `sp_estadistica_g03`$$
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
	END$$

DROP PROCEDURE IF EXISTS `sp_estadistica_g04`$$
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
	END$$

DROP PROCEDURE IF EXISTS `sp_estadistica_g05`$$
CREATE PROCEDURE `sp_estadistica_g05`(`mes_` CHAR(2), `anio_` CHAR(4))
	BEGIN
		SELECT
			SUM(IF(id_tipo_pedido = 1,  total, 0)) AS mesa,
			SUM(IF(id_tipo_pedido = 2,  total, 0)) AS llevar,
			SUM(IF(id_tipo_pedido = 3,  total, 0)) AS delivery
		FROM v_estadistica
		WHERE MONTH(fecha_venta) = mes_ AND YEAR(fecha_venta) = anio_
		ORDER BY fecha_venta ASC;
	END$$

DROP PROCEDURE IF EXISTS `usp_restDesocuparMesa`$$
CREATE PROCEDURE `usp_restDesocuparMesa` (`_flag` INT(11), `_id_pedido` INT(11))  BEGIN
	DECLARE result INT DEFAULT 1;
	IF _flag = 1 THEN
		SELECT id_mesa INTO @codmesa FROM tm_pedido_mesa WHERE id_pedido = _id_pedido;
		UPDATE tm_mesa SET estado = 'a' WHERE id_mesa = @codmesa;
		UPDATE tm_pedido SET estado = 'z' WHERE id_pedido = _id_pedido;
		SELECT result AS resultado;
	END IF;
END$$

DELIMITER ;
