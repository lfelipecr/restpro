<?php
date_default_timezone_set('America/Lima');
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$hora = date("g:i:s A");

require __DIR__ . '/num_letras.php';
require __DIR__ . '/autoload.php';
require __DIR__ . '/phpqrcode/qrlib.php';

use Mike42\Escpos\Printer;
use Mike42\Escpos\EscposImage;
use Mike42\Escpos\PrintConnectors\WindowsPrintConnector;

$date = date('d-m-Y H:i:s');
$data = json_decode($_GET['data'],true);
echo $_GET['data'];
// return false;
//AQUI CAMBIAR EL NOMBRE DE LA PC, NOMBRE IMPRESORA
$connector = new WindowsPrintConnector("smb://192.168.1.5/cpe");
// $connector = new WindowsPrintConnector("smb://192.168.1.101/".$data['nombre_imp']."");
$printer = new Printer($connector);
$copias = 1;
$conigv = "SI"; //NO para exonerado
try {
	
for($i = 0; $i < $copias; $i++){

	///////////////descomentar esto para logo
	 $logo = EscposImage::load("logo.png", false);
   	$printer -> setJustification(Printer::JUSTIFY_CENTER);
	 $printer -> bitImage($logo);
	 // $printer -> feed();

	 $printer -> text("===============================================\n");
	///////////////hasta aqui descomentar esto para logo

	$printer -> setJustification(Printer::JUSTIFY_CENTER);
$printer -> setEmphasis(true);

	$printer -> text(utf8_decode($data['Empresa']['nombre_comercial'])."\n");
	$printer -> text(utf8_decode($data['Empresa']['razon_social'])."\n");
	$printer -> setEmphasis(false);
	$printer -> text("RUC: ".utf8_decode($data['Empresa']['ruc'])."\n");

	if ($data['Empresa']['direccion_comercial']!='-') {
		$printer -> text(utf8_decode($data['Empresa']['direccion_comercial'])."\n");
	}

	if ($data['Empresa']['celular']!='') {
		$printer -> text("TELF: ".utf8_decode($data['Empresa']['celular'])."\n");
	}

	$printer -> setJustification(Printer::JUSTIFY_CENTER);
	$printer -> text("-----------------------------------------------\n");

	$elec = (($data['id_tdoc'] == 1 || $data['id_tdoc'] == 2) && $data['Empresa']['sunat'] == 1) ? 'ELECTRONICA' : '';
	$printer -> text($data['desc_td']." ".$elec."\n");
	$printer -> text($data['ser_doc']."-".$data['nro_doc']."\n");
	$printer -> text("-----------------------------------------------\n");
	$printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_LEFT);
	$printer -> text("FECHA DE EMISION: ".date('d-m-Y h:i A',strtotime($data['fec_ven']))."\n");
	
	if($data['id_tped'] == 1){
		$tipo_atencion = utf8_decode($data['Pedido']['desc_salon']).' - MESA: '.utf8_decode($data['Pedido']['nro_mesa']);
	}else if ($data['id_tped'] == 2){
		$tipo_atencion = "MOSTRADOR";
	}else if ($data['id_tped'] == 3){
		$tipo_atencion = "DELIVERY";
	}
	$printer -> text("TIPO DE ATENCION: ".$tipo_atencion."\n");
	$printer -> text("------------------------------------------------\n");

$printer -> setEmphasis(true);
	$printer -> text("CLIENTE: ".utf8_decode($data['Cliente']['nombre'])."\n");

 
	if ($data['Cliente']['tipo_cliente'] == 1){
		$printer -> text("DNI: ".$data['Cliente']['dni']."\n");
	}else if ($data['Cliente']['tipo_cliente'] == 2){
		$printer -> text("RUC: ".$data['Cliente']['ruc']."\n");
	}
$printer -> setEmphasis(false);

	if ($data['Cliente']['direccion']!='-') {
		$printer -> text("DIRECCION: ".utf8_decode($data['Cliente']['direccion'])."\n");
	}

	if ($data['Cliente']['telefono']!='0') {
		$printer -> text("TELEFONO: ".$data['Cliente']['telefono']."\n");
	}

	if ($data['Cliente']['referencia']!='') {
		$printer -> text("REFERENCIA: ".utf8_decode($data['Cliente']['referencia'])."\n");
	}

	if ($data['Pedido']['mozo']!='') {
		$printer -> text("Mozo: ".utf8_decode($data['Pedido']['mozo'])."\n");
	}

	if ($data['id_tped'] == 3 && $data['Cliente']['id_cliente'] != $data['Cliente_pedido']['id_cliente']){
		$printer -> text("DATOS DELIVERY:\n");
		$printer -> text("NOMBRE: ".$data['Cliente_pedido']['nombre_cliente']."\n");
		$printer -> text("TELEFONO: ".$data['Cliente_pedido']['telefono_cliente']."\n");
		$printer -> text("DIRECCION: ".$data['Cliente_pedido']['direccion_cliente']."\n");
		$printer -> text("REFERENCIA: ".$data['Cliente_pedido']['referencia_cliente']."\n");
	}

	$printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_LEFT);
	$printer -> text("------------------------------------------------\n");
	$printer -> text("PRODUCTO                    CANT   P.U   IMPORTE\n");
	$printer -> text("------------------------------------------------\n");
	
	$total = 0;


	if ($data['consumo'] == '0') {
		foreach($data['Detalle'] as $d){
			if($d['cantidad'] > 0){

		$limite = 26;
		$listItems = '';

		$descripcionprod = utf8_decode($d['nombre_producto']);

		  $division = round(strlen($descripcionprod)/$limite, 0, PHP_ROUND_HALF_UP);
		  if ($division<1) {
		  	$division=1;
		  }
		// echo	$division;
		// echo "---11111---";
		  $cont = -$limite;
		  for ($i = 0; $i < $division; $i++) {
		    $cont = $cont+$limite;
		      $contar = ($limite)-(strlen($descripcionprod)+2);
		      $espacios='';
		      for ($f = 0; $f < $contar; $f++) {
		        $espacios .= ' ';
		      }

		    if($i===0){
		      $listItems .= "".substr($descripcionprod,$cont, $limite)." ".$espacios." ".$d['cantidad']."   ".number_format(($d['precio_unitario']),2)."  ".number_format(($d['cantidad'] * $d['precio_unitario']),2)."\n";
					$printer -> text("".$listItems."");
		    }else{
		      $listItems = "".substr($descripcionprod,$cont, $limite)."\n";
					$printer -> text($listItems);
		    }

		  }

		$listItems = '';

				// $printer -> text("  ".$d['cantidad'].' '.utf8_decode($d['Producto']['pro_pre']).' | '.number_format(($d['precio_unitario']),2).'  '.number_format(($d['cantidad'] * $d['precio_unitario']),2)."\n");
				
				$total = ($d['cantidad'] * $d['precio_unitario']) + $total;


			}
		}
	
	}	

	if ($data['consumo'] == '1') {
		$totalCaracteres = utf8_decode($data['consumo_desc']);
	    $contar = ($limite)-(strlen($totalCaracteres));
	    $espacios='';
	    for ($f = 0; $f < $contar; $f++) {
			$espacios .= ' ';
	    }

		$listItems .= "".utf8_decode($data['consumo_desc'])." ".$espacios."  1   ".number_format(($d['precio_unitario']),2)."  ".number_format(($data['total']),2)."\n";
		$printer -> text("".$listItems."");

	}

	$printer -> text("-----------------------------------------------\n");
	$printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_LEFT);
	

$mystring = $data['igv'];
$findme   = '10';
$pos = strpos($mystring, $findme);

if ($pos !== false) {
    $igv_= "0.10";
} else {
	$igv_= "0.18";
}

    $igv_int = number_format((1+$igv_),2);

    if ($data['desc_monto']>0) {
        $operacion_gravada = ($data['total'] + $data['comis_del'] - $data['desc_monto']) / $igv_int;
    }else{
        $operacion_gravada = ($data['total'] + $data['comis_del']) / $igv_int;
    }

	$igv = ($operacion_gravada * $igv_);

	$printer -> text("SUB TOTAL:                            S/ ".number_format(($data['total']),2)."\n");
	if($data['id_tped'] == 3){
	$printer -> text("COSTO DELIVERY:                       S/ ".number_format(($data['comis_del']),2)."\n");
	}

	if ($data['desc_monto']!=0) {
		$printer -> text("DESCUENTO:                            S/ ".number_format(($data['desc_monto']),2)."\n");
	}

	if ($conigv=='SI') {
		$printer -> text("OP.GRAVADA:                           S/ ".number_format(($operacion_gravada),2)."\n");
		$printer -> text("IGV:                                  S/ ".number_format(($igv),2)."\n");
	}else{
		$printer -> text("OP.EXONERADA:                           S/ ".number_format(($data['total']),2)."\n");
		$printer -> text("IGV:                                  S/ 0.00\n");
	}

 
	$printer -> text("IMPORTE A PAGAR:                      S/ ".number_format(($data['total'] + $data['comis_del'] - $data['desc_monto']),2)."\n");
	$printer -> text("\n");
	$printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_LEFT);

	$total_letras = $data['total'] + $data['comis_del'] - $data['desc_monto'];
	$printer -> text("SON: ".numtoletras(number_format(($total_letras),2))."\n");

	if ($data['Config']['pedido_comanda'] == 1) {
	  	$pdf->Cell(37, 10, 'PED: '.str_pad($this->dato->id_ped, 5, "0", STR_PAD_LEFT).'', 0);
	}
	// $printer -> text("SON: ".numtoletras($data['total'] + $data['comis_del'] - $data['desc_monto'])."\n");
	$printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_CENTER);
	$printer -> text("------------ FORMA DE PAGO ------------ \n");
	$printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_LEFT);
	
	if($data['id_tpag'] == 1){
		$vuelto = $data['pago_efe_none'] - $data['pago_efe'];
		$printer -> text("PAGO CON ".$data['desc_tp'].": S/".number_format($data['pago_efe_none'],2)."\n");

		if ($vuelto!=0) {
			$printer -> text("VUELTO: S/".number_format($vuelto,2)."\n");
		}
	} else {
		$printer -> text("PAGO CON: ".$data['desc_tp']."\n");
	}

	if($data['observacion'] == '' || $data['observacion'] == ''){
		$printer -> text("OBSERVACIONES: ".$data['observacion']."\n");
	}

if ($data['id_tdoc']=="1" || $data['id_tdoc']=="2") {
	//codigo qr //inicio
	$codesDir = "codes/";   

    if ($data['desc_td']=="BOLETA DE VENTA") {
    	$tipo_doc = '03';
    }else{
    	$tipo_doc = '01';
    }
    $total_qr = $data['total'] + $data['comis_del'] - $data['desc_monto'];

    if ($igv==null) {
    	$igv = 0;
    }
    $dataqr = "".$data['Empresa']['ruc']."|".$tipo_doc."|".$data['ser_doc']."|".$data['nro_doc']."|".number_format(($igv),2)."|".$total_qr."|".date('d-m-Y',strtotime($data['fec_ven']))."|".$data['Cliente']['tipo_cliente']."|".$data['Cliente']['dni']."".$data['Cliente']['ruc']."";

    $codeFile = $data['ser_doc'].'-'.$data['nro_doc'].'.png';

    QRcode::png($dataqr, $codesDir.$codeFile, "H", 4); 
	$qr = EscposImage::load("".$codesDir.$codeFile."", true);

  	$printer -> setJustification(Printer::JUSTIFY_CENTER);
	$printer -> bitImage($qr);
	// $printer -> feed();

	//codigo qr //final
	// $printer -> text("\n");
	// $printer -> selectPrintMode();
	$printer -> setJustification(Printer::JUSTIFY_CENTER);
	$printer -> text("Autorizado mediante Resolucion\n");
	$printer -> text("Nro. 034-005-0005655/SUNAT\n");
	$printer -> text("Consulta CPE en:\n");
	$printer -> text("resturante.com/facturacion/consulta\n");
	$printer -> text("\n");
	$printer -> text("Emitido por: restpvsoft.pe\n");
	$printer -> text("!GRACIAS POR SU PREFERENCIA¡\n");
	$printer -> text("===============================================\n");
	$printer -> text("\n");
}
	$printer -> cut();

}

	$printer->pulse();

	$printer -> close();

} catch(Exception $e) {
	echo "No se pudo imprimir en esta impresora " . $e -> getMessage() . "\n";
}
?>
echo "<script lenguaje="JavaScript">window.close();</script>";