<?php
require_once ('public/lib/print/num_letras.php');
require_once ('public/lib/pdf/cellfit.php');
require_once ('public/lib/vendor/autoload.php');


date_default_timezone_set('America/Lima');
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$hora = date("g:i:s A");
$fecha = date("d/m/Y");

// $data = json_decode($_GET['data'],true);

// echo $_GET['data'];
// echo json_encode($this->dato->Pagos);
// return false; 
// echo __DIR__ . ''.DIRECTORY_SEPARATOR.'style.css';
// echo json_encode($this->dato->pagos_plin_mix->count_plin);
// return ;

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


$efectivoencaja = $this->dato->monto_aper + $this->dato->Principal->pago_efe + $this->dato->Ingresos->total - $this->dato->Egresos->total;
$efectivodiferencia = $efectivoencaja - $this->dato->monto_cierre;
$nombre_efectivodiferencia = ($efectivodiferencia > 0) ? 'FALTANTE' : 'RESTANTE';

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
	<hr >
	<div class="text-center size15 font-bold">== DINERO EN CAJA ==</div>
	<table class="full-width">
		<tbody>
			<tr>
				<td class="font-bold size11 text-left" width="55%">APERTURA DE CAJA</td>
				<td class="font-bold size11 text-left" width="2%">:</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->monto_aper),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">VENTAS EN EFECTIVO</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right">'.number_format(($this->dato->Principal->pago_efe),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">ENTRADAS EN EFECTIVO</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right">'.number_format(($this->dato->Ingresos->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">SALIDAS EN EFECTIVO</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right">- '.number_format(($this->dato->Egresos->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size8 text-center" colspan="3">-----------------------------------------------------</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">EFECTIVO EN CAJA</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right">'.number_format(($efectivoencaja),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">EFECTIVO EN CIERRE</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right">'.number_format(($this->dato->monto_cierre),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size8 text-center" colspan="3">-----------------------------------------------------</td>
			</tr>
			<tr>
				<td class="font-bold size13 text-left">'.$nombre_efectivodiferencia.'</td>
				<td class="font-bold size13 text-left">=</td>
				<td class="font-bold size13 text-right">'.number_format(($efectivodiferencia),2).'</td>
			</tr>
		</tbody>
	</table>
	<hr >
	<div class="text-center size15 font-bold">== ENTRADAS EFECTIVO ==</div>
	<table class="full-width">
		<tbody>
			<tr>
				<td class="font-bold size11 text-left" width="55%">ENTRADA DE DINERO</td>
				<td class="font-bold size11 text-left" width="2%">:</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->Ingresos->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size8 text-center" colspan="3">-----------------------------------------------------</td>
			</tr>
			<tr>
				<td class="font-bold size15 text-left">TOTAL ENTRADAS</td>
				<td class="font-bold size15 text-left">:</td>
				<td class="font-bold size15 text-right"> '.number_format(($this->dato->Ingresos->total),2).'</td>
			</tr>
		</tbody>
	</table>


	<hr >
	<div class="text-center size15 font-bold">== SALIDAS EFECTIVO ==</div>
	<table class="full-width">
		<tbody>
			<tr>
				<td class="font-bold size11 text-left" width="55%">COMPRAS</td>
				<td class="font-bold size11 text-left" width="2%">:</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->EgresosA->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">SERVICIOS</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right"> '.number_format(($this->dato->EgresosB->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">REMUNERACIONES</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right"> '.number_format(($this->dato->EgresosC->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">PAGOS A PROVEEDORES</td>
				<td class="font-bold size11 text-left">:</td>
				<td class="font-bold size11 text-right"> '.number_format(($this->dato->EgresosD->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size8 text-center" colspan="3">-----------------------------------------------------</td>
			</tr>
			<tr>
				<td class="font-bold size15 text-left">TOTAL SALIDAS</td>
				<td class="font-bold size15 text-left">=</td>
				<td class="font-bold size15 text-right"> '.number_format(($this->dato->Egresos->total),2).'</td>
			</tr>
		</tbody>
	</table>



	<hr>
	<div class="text-center size15 font-bold">== VENTAS ==</div>
	<table class="full-width">
		<thead>
			<tr>
				<td class="font-bold size11 text-left" width="55%"></td>
				<td class="font-bold size11 text-right" width="15%">OPER.</td>
				<td class="font-bold size11 text-right" width="25%">TOTAL</td>
			</tr>
		</thead>
		<tbody>
	';
// $this->dato->pagos_yape_mix->count_yape

	$montoEfectivoSolo = 0;
	$montoYapeSolo = 0;
	$montoPlinSolo = 0;
	$montoTransSolo = 0;
	$montoTarSolo = 0;
	$montoDidiSolo = 0;
	$montoRapiSolo = 0;
	$montoPedSolo = 0;
	$montoCulSolo = 0;
	$montoLukSolo = 0;
	$montoTunSolo = 0;
	$montoIziSolo = 0;
	$montoNiuSolo = 0;

foreach($this->dato->Pagos as $d){ 
	if($d->DESCRIPCION == "YAPE"){
		$countYape += $d->TRANSACCIONES;
		$montoYapeSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "PLIN"){
		$countPlin += $d->TRANSACCIONES;
		$montoPlinSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "TRANSFERENCIA"){
		$countTrans += $d->TRANSACCIONES;
		$montoTransSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "TARJETA"){
		$countTar += $d->TRANSACCIONES;
		$montoTarSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "DIDI"){
		$countDidi += $d->TRANSACCIONES;
		$montoDidiSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "RAPPI"){
		$countRapi += $d->TRANSACCIONES;
		$montoRapiSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "PEDIDOS YA"){
		$countPed += $d->TRANSACCIONES;
		$montoPedSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "PEDIDOS YA"){
		$countPed += $d->TRANSACCIONES;
		$montoPedSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "CULQI"){
		$countCul += $d->TRANSACCIONES;
		$montoCulSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "LUKITA"){
		$countLuk += $d->TRANSACCIONES;
		$montoLukSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "TUNKI"){
		$countTun += $d->TRANSACCIONES;
		$montoTunSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "IZIPAY"){
		$countIzi += $d->TRANSACCIONES;
		$montoIziSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "NIUBIZ"){
		$countNiu += $d->TRANSACCIONES;
		$montoNiuSolo += $d->MONTO;
	}else if($d->DESCRIPCION == "GIFT CARD"){
		$countGiftC += $d->TRANSACCIONES;
		$montoGiftCSolo += $d->MONTO;
	}else{
		$countEfectivo += $d->TRANSACCIONES;
		$montoEfectivoSolo += $d->MONTO;
	}
}

		$html .= '
			<tr>
				<td class="font-bold size11 text-left">EFECTIVO</td>
				<td class="font-bold size11 text-right">'.number_format($countEfectivo,0).'</td>
				<td class="font-bold size11 text-right" >'.number_format(($montoEfectivoSolo),2).'</td>
			</tr>
		';

		if ($montoTarSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">TARJETA</td>
					<td class="font-bold size11 text-right">'.number_format($this->dato->pagos_yape_mix->count_tar+$countTar,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoTarSolo),2).'</td>
				</tr>
			';
		}else{
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">TARJETA</td>
					<td class="font-bold size11 text-right">'.number_format($this->dato->pagos_yape_mix->count_tar+$countTar,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoTarSolo+$this->dato->pagos_tar_mix->total_tar),2).'</td>
				</tr>
			';
		}


		$html .= '
			<tr>
				<td class="font-bold size11 text-left">YAPE</td>
				<td class="font-bold size11 text-right">'.number_format($this->dato->pagos_yape_mix->count_yape+$countYape,0).'</td>
				<td class="font-bold size11 text-right" >'.number_format(($montoYapeSolo+$this->dato->pagos_yape_mix->total_yape),2).'</td>
			</tr>
		';
		$html .= '
			<tr>
				<td class="font-bold size11 text-left">PLIN</td>
				<td class="font-bold size11 text-right">'.number_format(($this->dato->pagos_plin_mix->count_plin+$countPlin),0).'</td>
				<td class="font-bold size11 text-right" >'.number_format(($montoPlinSolo+$this->dato->pagos_plin_mix->total_plin),2).'</td>
			</tr>
		';
		if ($montoTransSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">TRANSFERENCIA</td>
					<td class="font-bold size11 text-right">'.number_format($countTrans,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoTransSolo+$this->dato->pagos_tran_mix->total_tran),2).'</td>
				</tr>
			';
		}

		if ($montoDidiSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">DIDI</td>
					<td class="font-bold size11 text-right">'.number_format($countDidi,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoDidiSolo),2).'</td>
				</tr>
			';
		}
		
		if ($montoRapiSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">RAPPI</td>
					<td class="font-bold size11 text-right">'.number_format($countRapi,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoRapiSolo),2).'</td>
				</tr>
			';
		}

		if ($montoPedSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">PEDIDOS YA</td>
					<td class="font-bold size11 text-right">'.number_format($countPed,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoPedSolo),2).'</td>
				</tr>
			';
		}

		if ($montoCulSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">CULQI</td>
					<td class="font-bold size11 text-right">'.number_format($countCul,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoCulSolo),2).'</td>
				</tr>
			';
		}

		if ($montoLukSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">LUKITA</td>
					<td class="font-bold size11 text-right">'.number_format($countLuk,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoLukSolo),2).'</td>
				</tr>
			';
		}

		if ($montoTunSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">TUNKI</td>
					<td class="font-bold size11 text-right">'.number_format($countTun,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoTunSolo),2).'</td>
				</tr>
			';
		}

		if ($montoIziSolo != "0.00") {
			$html .= '
				<tr>
					<td class="font-bold size11 text-left">IZIPAY</td>
					<td class="font-bold size11 text-right">'.number_format($countIzi,0).'</td>
					<td class="font-bold size11 text-right" >'.number_format(($montoIziSolo),2).'</td>
				</tr>
			';
		}

		$html .= '
			<tr>
				<td class="font-bold size11 text-left">ANULACIONES</td>
				<td class="font-bold size11 text-right">'.$this->dato->Anulaciones->cant.'</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->Anulaciones->total),2).'</td>
			</tr>
		';



if(Session::get('opc_01') == 1) {
		$html .= '
			<tr>
				<td class="font-bold size11 text-left">CON GLOVO</td>
				<td class="font-bold size11 text-right">'.$this->dato->Glovo->cant.'</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->Glovo->total),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">CON RAPPI</td>
				<td class="font-bold size11 text-right">'.$this->dato->Rappi->cant.'</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->Rappi->total),2).'</td>
			</tr>
		';
}
		$totalapp = $this->dato->Glovo->total + $this->dato->Rappi->total;
		$html .= '
			<tr>
				<td class="font-bold size8 text-center" colspan="3">-----------------------------------------------------</td>
			</tr>
			<tr>
				<td class="font-bold size15 text-left">TOTAL VENTAS</td>
				<td class="font-bold size15 text-right">=</td>
				<td class="font-bold size15 text-right" >'.number_format(($this->dato->Principal->total + $this->dato->pagos_tran_mix->total_tran + $totalapp+$this->dato->pagos_yape_mix->total_yape+$this->dato->pagos_plin_mix->total_plin),2).'</td>
			</tr>
		';

 
	$html .= '
		</tbody>
	</table>
	<hr >
	<div class="text-center size15 font-bold">== OTRAS OPERACIONES ==</div>
	<table class="full-width">
		<thead>
			<tr>
				<td class="font-bold size11 text-left" width="55%"></td>
				<td class="font-bold size11 text-right" width="15%">OPER.</td>
				<td class="font-bold size11 text-right" width="25%">TOTAL</td>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td class="font-bold size11 text-left">DESCUENTOS</td>
				<td class="font-bold size11 text-left">'.$this->dato->Descuentos->cant.'</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->Principal->descu_descuento),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">CORTESÍA</td>
				<td class="font-bold size11 text-left">'.$this->dato->Principal->total_cortesia.'</td>
				<td class="font-bold size11 text-right" >'.number_format(($this->dato->Principal->descu_cortesia),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">COMISION DELIVERY</td>
				<td class="font-bold size11 text-left">'.$this->dato->ComisionDelivery->cant.'</td>
				<td class="font-bold size11 text-right"> '.number_format(($this->dato->Principal->comis_del),2).'</td>
			</tr>
			<tr>
				<td class="font-bold size11 text-left">ANULACIONES VENTAS</td>
				<td class="font-bold size11 text-left">'.$this->dato->Anulaciones->cant.'</td>
				<td class="font-bold size11 text-right"> '.number_format(($this->dato->Anulaciones->total),2).'</td>
			</tr>
		</tbody>
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