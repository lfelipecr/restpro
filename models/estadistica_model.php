<?php

class Estadistica_Model extends Model {

	public function __construct() {
		parent::__construct();
	}

    public function Caja()
    {
        try
        {      
            return $this->db->selectAll("SELECT id_apc,id_caja,id_turno,desc_caja,desc_turno FROM v_caja_aper WHERE estado = 'a'");
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
	
	public function estadistica_datos()
    {
        $mmes = date('m',strtotime($_POST['mmes']));
        $manio = date('Y',strtotime($_POST['mmes']));
        $sql_grafico1 = $this->db->prepare("call sp_estadistica_g01( :mes, :anio);");
        $sql_grafico1->execute(array(':mes'=>$mmes,':anio'=>$manio));
        $grafico1 = $sql_grafico1->fetchAll(PDO::FETCH_ASSOC);
        $sql_grafico1->closeCursor();
        /*if ( $sql_grafico1->execute(array(':mes'=>$mmes,':anio'=>$manio)) ) {
            while ($fila = $sql_grafico1->fetchAll(PDO::FETCH_ASSOC)) {
                $grafico1 = $fila;
                $sql_grafico1->closeCursor();
            }
        } else {
            $grafico2->{'Ventas'} = $sql_grafico2->errorInfo();
        }*/

        $mes = $_POST['mes'];
        $anio = $_POST['anio'];
        $m1 = $mes;
        $a1 = $anio;
        if ($m1 == 1) { $m2 = 12; $a2 = $a1-1; } else { $m2 = $m1-1; $a2 = $a1; }
        if ($m2 == 1) { $m3 = 12; $a3 = $a2-1; } else { $m3 = $m2-1; $a3 = $a2; }
        if ($m3 == 1) { $m4 = 12; $a4 = $a3-1; } else { $m4 = $m3-1; $a4 = $a3; }
        if ($m4 == 1) { $m5 = 12; $a5 = $a4-1; } else { $m5 = $m4-1; $a5 = $a4; }
        if ($m5 == 1) { $m6 = 12; $a6 = $a5-1; } else { $m6 = $m5-1; $a6 = $a5; }
        if ($m6 == 1) { $m7 = 12; $a7 = $a6-1; } else { $m7 = $m6-1; $a7 = $a6; }
        if ($m7 == 1) { $m8 = 12; $a8 = $a7-1; } else { $m8 = $m7-1; $a8 = $a7; }
        if ($m8 == 1) { $m9 = 12; $a9 = $a8-1; } else { $m9 = $m8-1; $a9 = $a8; }
        if ($m9 == 1) { $m10 = 12; $a10 = $a9-1; } else { $m10 = $m9-1; $a10 = $a9; }
        if ($m10 == 1) { $m11 = 12; $a11 = $a10-1; } else { $m11 = $m10-1; $a11 = $a10; }
        if ($m11 == 1) { $m12 = 12; $a12 = $a11-1; } else { $m12 = $m11-1; $a12 = $a11; }

        $sql_grafico2 = $this->db->prepare("call sp_estadistica_g02_ventas( :m1, :a1, :m2, :a2, :m3, :a3, :m4, :a4);");
        $sql_grafico2->execute(array(':m1'=>$m1, ':a1'=>$a1, 'm2'=>$m2, 'a2'=>$a2, 'm3'=>$m3, 'a3'=>$a3, 'm4'=>$m4, 'a4'=>$a4));
        $grafico2->{'Ventas'} = $sql_grafico2->fetch(PDO::FETCH_ASSOC);
        $sql_grafico2->closeCursor();
        /*if ( $sql_grafico2->execute(array(':m1'=>$m1, ':a1'=>$a1, 'm2'=>$m2, 'a2'=>$a2, 'm3'=>$m3, 'a3'=>$a3, 'm4'=>$m4, 'a4'=>$a4)) ) {
            while ($fila2 = $sql_grafico2->fetch(PDO::FETCH_ASSOC)) {
                $grafico2->{'Ventas'} = $fila2;
                $sql_grafico2->closeCursor();
            }
        } else {
            $grafico2->{'Ventas'} = $sql_grafico2->errorInfo();
        }*/
        
        $sql_grafico21 = $this->db->prepare("call sp_estadistica_g02_compras( :m1, :a1, :m2, :a2, :m3, :a3, :m4, :a4)");
        $sql_grafico21->execute(array(':m1'=>$m1, ':a1'=>$a1, 'm2'=>$m2, 'a2'=>$a2, 'm3'=>$m3, 'a3'=>$a3, 'm4'=>$m4, 'a4'=>$a4));
        $grafico2->{'Compras'} = $sql_grafico21->fetch(PDO::FETCH_ASSOC);
        $sql_grafico21->closeCursor();
        /*if ( $sql_grafico21->execute(array(':m1'=>$m1, ':a1'=>$a1, 'm2'=>$m2, 'a2'=>$a2, 'm3'=>$m3, 'a3'=>$a3, 'm4'=>$m4, 'a4'=>$a4)) ) {
            while ($fila21 = $sql_grafico21->fetch(PDO::FETCH_ASSOC)) {
                $grafico2->{'Compras'} = $fila21;
                $sql_grafico21->closeCursor();
            }
        } else {
            $grafico2->{'Compras'} = $sql_grafico21->errorInfo();
        }*/

        $arrayParam3 =  array(
            ':d1' => $_POST['d1'],
            ':d2' => $_POST['d2'],
            ':d3' => $_POST['d3'],
            ':d4' => $_POST['d4'],
            ':d5' => $_POST['d5'],
            ':d6' => $_POST['d6'],
            ':d7' => $_POST['d7'],
        );
        $sql_grafico3 = $this->db->prepare("call sp_estadistica_g03( :d1, :d2, :d3, :d4, :d5, :d6, :d7)");
        $sql_grafico3->execute($arrayParam3);
        $grafico3 = $sql_grafico3->fetch(PDO::FETCH_ASSOC);
        $sql_grafico3->closeCursor();
        /*if ( $sql_grafico3->execute($arrayParam3) ) {
            while ($fila3 = $sql_grafico3->fetch(PDO::FETCH_ASSOC)) {
                $grafico3 = $fila3;
                $sql_grafico3->closeCursor();
            }
        } else {
            $grafico3 = $sql_grafico3->errorInfo();
        }*/


        $arrayParam4 =  array(
            ':m1' => $m1,
            ':a1' => $a1,
            ':m2' => $m2,
            ':a2' => $a2,
            ':m3' => $m3,
            ':a3' => $a3,
            ':m4' => $m4,
            ':a4' => $a4,
            ':m5' => $m5,
            ':a5' => $a5,
            ':m6' => $m6,
            ':a6' => $a6,
            ':m7' => $m7,
            ':a7' => $a7,
            ':m8' => $m8,
            ':a8' => $a8,
            ':m9' => $m9,
            ':a9' => $a9,
            ':m10' => $m10,
            ':a10' => $a10,
            ':m11' => $m11,
            ':a11' => $a11,
            ':m12' => $m12,
            ':a12' => $a12,
        );
        $sql_grafico4 = $this->db->prepare("call sp_estadistica_g04( :m1, :a1, :m2, :a2, :m3, :a3, :m4, :a4, :m5, :a5, :m6, :a6, :m7, :a7, :m8, :a8, :m9, :a9, :m10, :a10, :m11, :a11, :m12, :a12)");
        $sql_grafico4->execute($arrayParam4);
        $grafico4 = $sql_grafico4->fetch(PDO::FETCH_ASSOC);
        $sql_grafico4->closeCursor();
        /*if ( $sql_grafico4->execute($arrayParam4) ) {
            while ($fila4 = $sql_grafico4->fetch(PDO::FETCH_ASSOC)) {
                $grafico4 = $fila4;
                $sql_grafico4->closeCursor();
            }
        } else {
            $grafico4 = $sql_grafico4->errorInfo();
        }*/

        $mes_tipo = date('m',strtotime($_POST['tmes']));
        $anio_tipo = date('Y',strtotime($_POST['tmes']));
        $sql_grafico5 = $this->db->prepare("call sp_estadistica_g05( :mes, :anio)");
        $sql_grafico5->execute(array(':mes'=>$mes_tipo, ':anio'=>$anio_tipo));
        $grafico5 = $sql_grafico5->fetch(PDO::FETCH_ASSOC);
        $sql_grafico5->closeCursor();
        /*if ( $sql_grafico5->execute(array(':mes'=>$mes_tipo, ':anio'=>$anio_tipo)) ) {
            while ($fila5 = $sql_grafico5->fetch(PDO::FETCH_ASSOC)) {
                $grafico5 = $fila5;
                $sql_grafico5->closeCursor();
            }
        } else {
            $grafico5 = $sql_grafico5->errorInfo();
        }*/

        $sql_grafico6 = $this->db->prepare("call sp_estadistica_g06( :d1, :d7)");
        $sql_grafico6->execute(array(':d1' => $_POST['d1'],':d7' => $_POST['d7']));
        $grafico6 = $sql_grafico6->fetchAll(PDO::FETCH_ASSOC);
        $sql_grafico6->closeCursor();

        $data = array("grafico1" => $grafico1, "grafico2" => $grafico2, "grafico3" => $grafico3, "grafico4" => $grafico4, "grafico5" => $grafico5, "grafico6" => $grafico6);
        $json = json_encode($data);
        echo $json;
    }

    public function estadistica_datos_new()
    {
        $mes = date('m',strtotime($_POST['mmes']));
        $anio = date('Y',strtotime($_POST['mmes']));
        $sql_grafico1 = $this->db->prepare("SELECT v_estadistica.id_usu, 
            v_estadistica.nombres, 
            COUNT(v_estadistica.id_venta) AS numero_ventas, 
            SUM(v_estadistica.total) AS total_ventas
            FROM v_estadistica WHERE MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ? AND id_tipo_pedido = 1 GROUP BY id_usu ORDER BY numero_ventas ASC, total_ventas ASC;");
        $sql_grafico1->execute(array($mes,$anio));
        $grafico1 = $sql_grafico1->fetchAll(PDO::FETCH_OBJ);

        $mes = $_POST['mes'];
        $anio = $_POST['anio'];
        $m1 = $mes;
        $a1 = $anio;
        if ($m1 == 1) { $m2 = 12;$a2 = $a1-1; } else { $m2 = $m1-1;$a2 = $a1; }
        if ($m2 == 1) { $m3 = 12;$a3 = $a2-1; } else { $m3 = $m2-1;$a3 = $a2; }
        if ($m3 == 1) { $m4 = 12;$a4 = $a3-1; } else { $m4 = $m3-1;$a4 = $a3; }
        if ($m4 == 1) { $m5 = 12;$a5 = $a4-1; } else { $m5 = $m4-1;$a5 = $a4; }
        if ($m5 == 1) { $m6 = 12;$a6 = $a5-1; } else { $m6 = $m5-1;$a6 = $a5; }
        if ($m6 == 1) { $m7 = 12;$a7 = $a6-1; } else { $m7 = $m6-1;$a7 = $a6; }
        if ($m7 == 1) { $m8 = 12;$a8 = $a7-1; } else { $m8 = $m7-1;$a8 = $a7; }
        if ($m8 == 1) { $m9 = 12;$a9 = $a8-1; } else { $m9 = $m8-1;$a9 = $a8; }
        if ($m9 == 1) { $m10 = 12;$a10 = $a9-1; } else { $m10 = $m9-1;$a10 = $a9; }
        if ($m10 == 1) { $m11 = 12;$a11 = $a10-1; } else { $m11 = $m10-1;$a11 = $a10; }
        if ($m11 == 1) { $m12 = 12;$a12 = $a11-1; } else { $m12 = $m11-1;$a12 = $a11; }
        $sql_grafico2 = $this->db->prepare("SELECT
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_1,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_2,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_3,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_4
            FROM v_estadistica
            ORDER BY fecha_venta ASC;");
        $sql_grafico2->execute(array($m1, $a1, $m2, $a2, $m3, $a3, $m4, $a4));
        $grafico2->{'Ventas'} = $sql_grafico2->fetch(PDO::FETCH_ASSOC);
        
        $sql_grafico21 = $this->db->prepare("SELECT
            SUM(IF(MONTH(fecha_c) = ? AND YEAR(fecha_c) = ?,  total, 0)) AS compra_1,
            SUM(IF(MONTH(fecha_c) = ? AND YEAR(fecha_c) = ?,  total, 0)) AS compra_2,
            SUM(IF(MONTH(fecha_c) = ? AND YEAR(fecha_c) = ?,  total, 0)) AS compra_3,
            SUM(IF(MONTH(fecha_c) = ? AND YEAR(fecha_c) = ?,  total, 0)) AS compra_4
            FROM tm_compra ORDER BY fecha_c ASC;");
        $sql_grafico21->execute(array($m1, $a1, $m2, $a2, $m3, $a3, $m4, $a4));
        $grafico2->{'Compras'} = $sql_grafico21->fetch(PDO::FETCH_ASSOC);

        $arrayParam =  array(
            $_POST['d1'].' 00:00:00',
            $_POST['d1'].' 23:59:59',
            $_POST['d2'].' 00:00:00',
            $_POST['d2'].' 23:59:59',
            $_POST['d3'].' 00:00:00',
            $_POST['d3'].' 23:59:59',
            $_POST['d4'].' 00:00:00',
            $_POST['d4'].' 23:59:59',
            $_POST['d5'].' 00:00:00',
            $_POST['d5'].' 23:59:59',
            $_POST['d6'].' 00:00:00',
            $_POST['d6'].' 23:59:59',
            $_POST['d7'].' 00:00:00',
            $_POST['d7'].' 23:59:59',
        );
        
        $sql_grafico3 = $this->db->prepare("SELECT SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia1, 
        SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia2, 
        SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia3, 
        SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia4, 
        SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia5, 
        SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia6, 
        SUM( IF( fecha_venta BETWEEN ? AND ?,  total, 0 ) ) AS dia7 
        FROM v_estadistica ORDER BY fecha_venta ASC;");
        $sql_grafico3->execute($arrayParam);
        $grafico3 = $sql_grafico3->fetch(PDO::FETCH_ASSOC);

        $sql_grafico4 = $this->db->prepare("SELECT
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_1,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_2,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_3,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_4,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_5,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_6,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_7,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_8,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_9,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_10,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_11,
            SUM(IF(MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?,  total, 0)) AS venta_12
            FROM v_estadistica
            ORDER BY fecha_venta ASC;");
        $sql_grafico4->execute(array($m1, $a1, $m2, $a2, $m3, $a3, $m4, $a4, $m5, $a5, $m6, $a6, $m7, $a7, $m8, $a8, $m9, $a9, $m10, $a10, $m11, $a11, $m12, $a12));
        $grafico4 = $sql_grafico4->fetch(PDO::FETCH_ASSOC);

        $mes_tipo = date('m',strtotime($_POST['tmes']));
        $anio_tipo = date('Y',strtotime($_POST['tmes']));
        $sql_grafico5 = $this->db->prepare("SELECT
            SUM(IF(id_tipo_pedido = 1,  total, 0)) AS mesa,
            SUM(IF(id_tipo_pedido = 2,  total, 0)) AS llevar,
            SUM(IF(id_tipo_pedido = 3,  total, 0)) AS delivery
            FROM v_estadistica
            WHERE MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?
            ORDER BY fecha_venta ASC;");
        $sql_grafico5->execute(array($mes_tipo, $anio_tipo));
        $grafico5 = $sql_grafico5->fetch(PDO::FETCH_ASSOC);

        $data = array("grafico1" => $grafico1, "grafico2" => $grafico2, "grafico3" => $grafico3, "grafico4" => $grafico4, "grafico5" => $grafico5);
        $json = json_encode($data);
        echo $json;
    }

	public function estadistica_g1()
    {
        try
        {
            $mes = date('m',strtotime($_POST['mmes']));
            $anio = date('Y',strtotime($_POST['mmes']));

            $sql_grafico1 = $this->db->prepare("SELECT v_estadistica.id_usu, 
                v_estadistica.nombres, 
                COUNT(v_estadistica.id_venta) AS numero_ventas, 
                SUM(v_estadistica.total) AS total_ventas
                FROM v_estadistica WHERE MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ? AND id_tipo_pedido = 1 GROUP BY id_usu ORDER BY numero_ventas ASC, total_ventas ASC;");
            $sql_grafico1->execute(array($mes,$anio));
            $grafico1 = $sql_grafico1->fetchAll(PDO::FETCH_OBJ);
            $data = array("data" => $grafico1);
            $json = json_encode($data);

            echo $json;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

	public function estadistica_g5()
    {
        try
        {
            $mes_tipo = date('m',strtotime($_POST['tmes']));
            $anio_tipo = date('Y',strtotime($_POST['tmes']));
            $sql_grafico5 = $this->db->prepare("SELECT
                SUM(IF(id_tipo_pedido = 1,  total, 0)) AS mesa,
                SUM(IF(id_tipo_pedido = 2,  total, 0)) AS llevar,
                SUM(IF(id_tipo_pedido = 3,  total, 0)) AS delivery
                FROM v_estadistica
                WHERE MONTH(fecha_venta) = ? AND YEAR(fecha_venta) = ?
                ORDER BY fecha_venta ASC;");
            $sql_grafico5->execute(array($mes_tipo, $anio_tipo));
            $grafico5 = $sql_grafico5->fetch(PDO::FETCH_ASSOC);

            $data = array("data" => $grafico5);
            $json = json_encode($data);
            echo $json;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
}