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

// echo __DIR__ . ''.DIRECTORY_SEPARATOR.'style.css';

// echo $this->dato;
// return false;
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
// 
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
	<div class="text-center size15 font-bold">==== GASTOS ====</div>
	<table class="full-width">
		<thead>
			<tr>
				<td width="30%" class="font-bold size11 text-center bordertable">Entregado a</td>
				<td width="50%" class="font-bold size11 text-center bordertable">Motivo</td>
				<td width="20%" class="font-bold size11 text-center bordertable">Monto</td>
			</tr>
		</thead>
		<tbody>
';

$gastoTotal = 0;
foreach($this->dato->gastos as $d){ 
	$gastoTotal+=$d->importe;
	$html .= '
			<tr>
				<td class="font-bold size11 text-left">'.utf8_decode($d->responsable).'</td>
				<td class="font-bold size11 text-left">'.utf8_decode($d->motivo).'</td>
				<td class="font-bold size11 text-right">'.utf8_decode($d->importe).'</td>
			</tr>
			';

}

$html .= '</tbody>
</table>
<table class="full-width">
	<tr>
		<td class="text-center size11" colspan="2">--------------------------------------</td>
	</tr>
	<tr>
		<td width="60%" class="font-bold size15 text-right">TOTAL S/</td>
		<td width="40%" class="font-bold size15 text-right">'.number_format($gastoTotal, 2).'</td>
	</tr>
</table>
	';
date_default_timezone_set($_SESSION["zona_horaria"]);
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$html .= '
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

?>