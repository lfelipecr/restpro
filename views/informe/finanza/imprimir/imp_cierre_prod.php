<?php
// /venta/impresion_comanda/
require_once ('public/lib/print/num_letras.php');
require_once ('public/lib/pdf/cellfit.php');
require_once ('public/lib/vendor/autoload.php');


date_default_timezone_set('America/Lima');
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$hora = date("g:i:s A");
$fecha = date("d/m/Y");

$data = json_decode($_GET['data'],true);

// echo json_encode($this->dato->Principal->descu_cortesia);
// return false;
// echo __DIR__ . ''.DIRECTORY_SEPARATOR.'style.css';

$defaultConfig = (new Mpdf\Config\ConfigVariables())->getDefaults();
$fontDirs = $defaultConfig['fontDir'];

$defaultFontConfig = (new Mpdf\Config\FontVariables())->getDefaults();
$fontData = $defaultFontConfig['fontdata'];

            $mpdf = new \Mpdf\Mpdf([
                'mode' => 'utf-8',
				    'fontDir' => array_merge($fontDirs, [
				        __DIR__ . ''.DIRECTORY_SEPARATOR.'fonts',
				    ]),
				    'fontdata' => $fontData + [
				        'couriernewb' => [
				            'R' => 'couriernew.ttf',
				            'I' => 'couriernew.ttf',
				        ]
				    ],
    			'default_font' => 'couriernewb', 
                'format' => [78,800],
                'margin_top' => 0,
                'margin_right' => 4,
                'margin_bottom' => 0,
                'margin_left' => 4
            ]);

$html = '';

if($this->dato->estado == 'a'){
	$estado = 'ABIERTO';
	$fecha_cierre = '-----';
}else{
	$estado = 'CERRADO';
	$fecha_cierre = date('d-m-Y h:i A',strtotime($this->dato->fecha_cierre));
}

$html .= '<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8" />
</head>
<body>
	<table class="full-width">
		<tr>
			<td width="60%" class="text-center">
				<div class="font-bold size11">ARQUEO DE CAJA</div>
				<div class="font-bold size11">CORTE DE TURNO #COD0'.$this->dato->id_apc.'</div>
				<div class="font-bold size11">ESTADO: '.$estado.'</div>
			</td>
		</tr>
	</table>
	<table class="full-width">
		<tr>
			<td width="35%" class="font-bold size11 text-left">CAJERO</td>
			<td width="1%" class="font-bold size11 text-left">:</td>
			<td width="70%" class="font-bold size11 text-left">'.utf8_decode($this->dato->desc_per).'</td>
		</tr>
		<tr>
			<td width="35%" class="font-bold size11 text-left">CAJA</td>
			<td width="1%" class="font-bold size11 text-left">:</td>
			<td width="70%" class="font-bold size11 text-left">'.utf8_decode($this->dato->desc_caja).'</td>
		</tr>
		<tr>
			<td width="35%" class="font-bold size11 text-left">TURNO</td>
			<td width="1%" class="font-bold size11 text-left">:</td>
			<td width="70%" class="font-bold size11 text-left">'.utf8_decode($this->dato->desc_turno).'</td>
		</tr>
		<tr>
			<td width="35%" class="font-bold size11 text-left">FECHA APERTURA</td>
			<td width="1%" class="font-bold size11 text-left">:</td>
			<td width="70%" class="font-bold size11 text-left">'.date('d-m-Y h:i A',strtotime($this->dato->fecha_aper)).'</td>
		</tr>
		<tr>
			<td width="35%" class="font-bold size11 text-left">FECHA CIERRE</td>
			<td width="1%" class="font-bold size11 text-left">:</td>
			<td width="70%" class="font-bold size11 text-left">'.$fecha_cierre.'</td>
		</tr>
	</table>
	<div class="text-center size15 font-bold">== PRODUCTOS VENDIDOS ==</div>
	<table class="full-width">
		<thead>
			<tr>
				<td width="45%" class="font-bold size11 text-center bordertable">PRODUCTO</td>
				<td width="17%" class="font-bold size11 text-right bordertable">CANT.</td>
				<td width="17%" class="font-bold size11 text-right bordertable">P.U.</td>
				<td width="23%" class="font-bold size11 text-right bordertable">IMP.</td>
			</tr>
		</thead>
		<tbody>
';

$prod_total = 0;
foreach($this->dato->Detalle as $d){ 
	$prod_total =$d->cantidad * $d->precio;
	$html .= '
			<tr>
			<!-- <td class="font-bold size11 text-left">'.utf8_decode($d->Producto->pro_nom).' '.utf8_decode($d->Producto->pro_pre).'</td> -->
			<td class="font-bold size11 text-left">'.utf8_decode($d->Producto->pro_pre).'</td>
				<td class="font-bold size11 text-right">'.$d->cantidad.'</td>
				<td class="font-bold size11 text-right">'.$d->precio.'</td>
				<td class="font-bold size11 text-right">'.number_format(($d->cantidad * $d->precio),2).'</td>
			</tr>
			';
	$total_caja+=$prod_total;
}
 
$html .= '</tbody>
</table>
<table class="full-width">
	<tr>
		<td class="text-center size11" colspan="2">--------------------------------------</td>
	</tr>
	<tr>
		<td class="font-bold size11 text-left" colspan="2">Total productos vendidos: '.count($this->dato->Detalle).'</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size15 text-right">TOTAL S/</td>
		<td width="40%" class="font-bold size15 text-right">'.number_format($total_caja,2).'</td>
	</tr>
</table>
	';
 

$html .= '
<table class="full-width">
	<tr>
		<td class="text-center size11" colspan="2">--------------------------------------</td>
	</tr>
	<!--tr>
		<td width="60%" class="font-bold size15 text-right">TOTAL S/</td>
		<td width="40%" class="font-bold size15 text-right">'.number_format($total_caja_anul,2).'</td>
	</tr-->
	<!--tr>
		<td class="text-center size11" colspan="2">=====================================</td>
	</tr-->
	<tr>
		<td width="60%" class="font-bold size11 text-right">TOTAL VENDIDOS</td>
		<td width="40%" class="font-bold size11 text-right">'.number_format($total_caja,2).' +</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size11 text-right">COMISION DELIVERY</td>
		<td width="40%" class="font-bold size11 text-right">'.number_format($this->dato->Principal->comis_del,2).'  -</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size11 text-right">TOTAL CORTESIA</td>
		<td width="40%" class="font-bold size11 text-right">'.number_format($this->dato->Principal->descu_cortesia,2).'  -</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size11 text-right">TOTAL DESCUENTOS </td>
		<td width="40%" class="font-bold size11 text-right">'.number_format($this->dato->Principal->descu_descuento,2).'  -</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size11 text-right">TOTAL CREDITO PERSONAL </td>
		<td width="40%" class="font-bold size11 text-right">'.number_format($this->dato->Principal->descu_personal,2).'  -</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size11 text-right"></td>
		<td width="40%" class="font-bold size11 text-right">----------- </td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size11 text-right">TOTAL VENTAS</td>
		<td width="40%" class="font-bold size11 text-right">'.number_format(($total_caja+$this->dato->Principal->comis_del)-$this->dato->Principal->descu,2).' &nbsp;</td>
	</tr>
	<tr>
		<td class="text-center size11" colspan="2">=====================================</td>
	</tr>
</table>
	<div class="text-center size13 font-bold">== PRODUCTOS ANULADOS EN MESAS ==</div>
	<table class="full-width">
		<thead>
			<tr>
				<td width="45%" class="font-bold size11 text-center bordertable">PRODUCTO</td>
				<td width="17%" class="font-bold size11 text-center bordertable">CANT.</td>
				<td width="17%" class="font-bold size11 text-right bordertable">P.U.</td>
			</tr>
		</thead>
		<tbody>
	';

$prod_total_anul = 0;
$prod_total_anul2 = 0;
foreach($this->dato->Anulados as $d){ 
	$prod_total_anul =$d->cantidad * $d->precio;
	$html .= '
			<tr>
				<td class="font-bold size11 text-left">'.utf8_decode($d->Producto->pro_nom).' '.utf8_decode($d->Producto->pro_pre).'</td>
				<td class="font-bold size11 text-right">'.$d->cant.'</td>
				<td class="font-bold size11 text-right">'.$d->cant*$d->precio.'</td>
			</tr>
			';
	$total_caja_anul+=$d->precio;
	$total_caja_anul2+=$d->cant;
}

date_default_timezone_set($_SESSION["zona_horaria"]);
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$html .= '
	<tr>
		<td class="font-bold size11 text-left" colspan="2">Total productos anulados: '.$total_caja_anul2.'</td>
	</tr>
	<!--tr>
		<td width="60%" class="font-bold size11 text-right">TOTAL ANULADOS</td>
		<td width="40%" class="font-bold size11 text-right">'.number_format($total_caja_anul,2).' &nbsp;</td>
	</tr-->
	</tbody>
</table>
<br>
	<div class="text-center size11 font-bold">== DATOS DE IMPRESION ==</div>
	<table class="full-width">
		<tr>
			<td width="20%" class="font-bold size11 text-left">USUARIO</td>
			<td width="1%" class="font-bold size11 text-left">:</td>
			<td width="80%" class="font-bold size11 text-left">'.Session::get('nombres').' '.Session::get('apellidos').'</td>
		</tr>
		<tr>
			<td class="font-bold size11 text-left">FECHA</td>
			<td class="font-bold size11 text-left">:</td>
			<td class="font-bold size11 text-left">'.date("d-m-Y h:i A").'</td>
		</tr>
		<tr>
			<td class="font-bold size11 text-left">&nbsp; </td>
		</tr>
		<tr>
			<td class="font-bold size11 text-left">&nbsp; </td>
		</tr>
		<tr>
			<td class="text-center size11 font-bold" colspan="3">___________________________________</td>
		</tr>
		<tr>
			<td class="text-center size11 font-bold" colspan="3">'.utf8_decode($this->dato->desc_per).'</td>
		</tr>
	</table>
	';

$html .= '</body></html>';

$html = mb_convert_encoding($html, 'UTF-8', 'UTF-8');

$mpdf->AddPage();

$path_css = ''.__DIR__ . '\style.css';
$stylesheet = file_get_contents(str_replace('\\','/', $path_css));
$mpdf->WriteHTML($stylesheet,\Mpdf\HTMLParserMode::HEADER_CSS);

$mpdf->WriteHTML($html,\Mpdf\HTMLParserMode::HTML_BODY);

$mpdf->Output();


// require_once ('public/lib/print/num_letras.php');
// require_once ('public/lib/pdf/cellfit.php');

// class FPDF_CellFiti extends FPDF_CellFit
// {
// 	function AutoPrint($dialog=false)
// 	{
// 		//Open the print dialog or start printing immediately on the standard printer
// 		$param=($dialog ? 'true' : 'false');
// 		$script="print($param);";
// 		$this->IncludeJS($script);
// 	}

// 	function AutoPrintToPrinter($server, $printer, $dialog=false)
// 	{
// 		//Print on a shared printer (requires at least Acrobat 6)
// 		$script = "var pp = getPrintParams();";
// 		if($dialog)
// 			$script .= "pp.interactive = pp.constants.interactionLevel.full;";
// 		else
// 			$script .= "pp.interactive = pp.constants.interactionLevel.automatic;";
// 		$script .= "pp.printerName = '\\\\\\\\".$server."\\\\".$printer."';";
// 		$script .= "print(pp);";
// 		$this->IncludeJS($script);
// 	}
// }

// define('EURO',chr(128));
// $pdf = new FPDF_CellFiti('P','mm',array(80,800));
// $pdf->AddPage();
// $pdf->SetMargins(0,0,0,0);
 
// // DATOS ARQUEO DE CAJA
// if($this->dato->estado == 'a'){$estado = 'ABIERTO';}else{$estado = 'CERRADO';}
// $pdf->Ln(3);
// $pdf->SetFont('Courier','B',10);
// $pdf->Cell(72,4,'ARQUEO DE CAJA',0,1,'C');
// $pdf->Cell(72,4,'CORTE DE TURNO #COD0'.$this->dato->id_apc,0,1,'C'); 
// $pdf->SetFont('Courier','B',8); 
// $pdf->Cell(72,4,'ESTADO: '.$estado,0,1,'C');       

// $pdf->Ln(3);
// $pdf->SetFont('Courier','B',9);
// $pdf->Cell(15, 4, 'CAJERO:', 0);    
// $pdf->Cell(20, 4, '', 0);
// $pdf->Cell(37, 4, utf8_decode($this->dato->desc_per),0,1,'R');
// $pdf->Cell(15, 4, 'CAJA:', 0);    
// $pdf->Cell(20, 4, '', 0);
// $pdf->Cell(37, 4, utf8_decode($this->dato->desc_caja),0,1,'R');
// $pdf->Cell(15, 4, 'TURNO:', 0);    
// $pdf->Cell(20, 4, '', 0);
// $pdf->Cell(37, 4, utf8_decode($this->dato->desc_turno),0,1,'R');
// if($this->dato->estado == 'a'){$fecha_cierre = '';}else{$fecha_cierre = date('d-m-Y h:i A',strtotime($this->dato->fecha_cierre));}
// $pdf->Cell(15, 4, 'FECHA APERTURA:', 0);    
// $pdf->Cell(20, 4, '', 0);
// $pdf->Cell(37, 4, date('d-m-Y h:i A',strtotime($this->dato->fecha_aper)),0,1,'R');
// $pdf->Cell(15, 4, 'FECHA CIERRE:', 0);    
// $pdf->Cell(20, 4, '', 0);
// $pdf->Cell(37, 4, $fecha_cierre,0,1,'R');
// $pdf->Ln(3);

// //PRODUCTOS VENDIDOS
// $pdf->Ln(8);
// $pdf->SetFont('Courier','B',10);
// $pdf->Cell(72,4,'== PRODUCTOS VENDIDOS ==',0,1,'C');
// $pdf->Ln(1);
// // COLUMNAS
// $pdf->SetFont('Courier', 'B', 8);
// $pdf->Cell(42, 4, 'PRODUCTO', 0);
// $pdf->Cell(5, 4, 'CANT.',0,0,'R');
// $pdf->Cell(10, 4, 'P.U.',0,0,'R');
// $pdf->Cell(15, 4, 'IMP.',0,0,'R');
// $pdf->Ln(4);
// $pdf->Cell(72,0,'','T');
// $pdf->Ln(1);
// // PRODUCTOS
// $total_caja=0;
// foreach($this->dato->Detalle as $d){
// 	$prod_total =$d->cantidad * $d->precio;
// $pdf->SetFont('Courier','B', 8);
// $pdf->MultiCell(42,4,utf8_decode($d->Producto->pro_nom).' '.utf8_decode($d->Producto->pro_pre),0,'L'); 
// $pdf->Cell(47, -4, $d->cantidad,0,0,'R');
// $pdf->Cell(10, -4, $d->precio,0,0,'R');
// $pdf->Cell(15, -4, number_format(($d->cantidad * $d->precio),2),0,0,'R');
// $pdf->Ln(1);
// $total_caja+=$prod_total;
// }
// $pdf->Cell(72,0,'','T');
// $pdf->Ln(4); 
// $pdf->SetFont('Courier', 'B', 12);
// $pdf->Cell(72,0,"TOTAL S/    ".number_format($total_caja,2)."",2,2,'R');
// $pdf->Ln(6); 
// $pdf->SetFont('Courier', 'B', 8);
// $pdf->Cell(72,4,'== DATOS DE IMPRESION ==',0,1,'C');
// $pdf->Cell(72,4,'USUARIO: '.Session::get('nombres').' '.Session::get('apellidos'),0,1,'');
// date_default_timezone_set($_SESSION["zona_horaria"]);
// setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
// $pdf->Cell(72,4,'FECHA: '.date("d-m-Y h:i A"),0,1,'');
// $pdf->Ln(8);
// $pdf->Cell(72,4,'___________________________________',0,1,'C');
// $pdf->Cell(72,4,utf8_decode($this->dato->desc_per),0,1,'C');
// // PIE DE PAGINA
// $pdf->Ln(10);
// $pdf->Output('arqueo_caja_productos_'.date('d-m-Y h:i A',strtotime($this->dato->fecha_aper)).'.pdf','i');
?>