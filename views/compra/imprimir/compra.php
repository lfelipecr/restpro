<?php
error_reporting(0);
require_once ('public/lib/print/num_letras.php');
require_once ('public/lib/pdf/cellfit.php');

class FPDF_CellFiti extends FPDF_CellFit
{
	function AutoPrint($dialog=false)
	{
		//Open the print dialog or start printing immediately on the standard printer
		$param=($dialog ? 'true' : 'false');
		$script="print($param);";
		$this->IncludeJS($script);
	}

	function AutoPrintToPrinter($server, $printer, $dialog=false)
	{
		//Print on a shared printer (requires at least Acrobat 6)
		$script = "var pp = getPrintParams();";
		if($dialog)
			$script .= "pp.interactive = pp.constants.interactionLevel.full;";
		else
			$script .= "pp.interactive = pp.constants.interactionLevel.automatic;";
		$script .= "pp.printerName = '\\\\\\\\".$server."\\\\".$printer."';";
		$script .= "print(pp);";
		$this->IncludeJS($script);
	}
}

define('EURO',chr(128));
$pdf = new FPDF_CellFiti('P','mm',array(210,297));
$pdf->AddPage();
$pdf->SetMargins(5,0,0,0);
 

$pdf->Ln(3);
$pdf->SetFont('Courier','B',15);
$pdf->Cell(200,4,'DETALLE DE COMPRA',0,1,'C');
$pdf->Ln(7);
$pdf->SetFont('Courier','',10);
$pdf->MultiCell(72,4,'PROVEEDOR: '.utf8_decode($this->dato->proveedor->razon_social),0,1,'');
if($this->dato->proveedor->tipo_prov == 1){
$pdf->Cell(72,4,utf8_decode(Session::get('diAcr')).': '.utf8_decode($this->dato->proveedor->dni),0,1,'R');
}else{
$pdf->Cell(190,-4,utf8_decode(Session::get('tribAcr')).': '.utf8_decode($this->dato->proveedor->ruc),0,1,'R');
}
$pdf->Ln(6);
$pdf->MultiCell(160,4,'DIRECCION: '.utf8_decode($this->dato->proveedor->direccion),0,1,'');
$pdf->Cell(190,-4,'TELEFONO: '.utf8_decode($this->dato->proveedor->telefono),0,1,'R');
$pdf->Ln(6);

$pdf->Cell(190,4,'COMPROBANTE REF. : '.utf8_decode($this->dato->serie_doc).'-'.utf8_decode($this->dato->num_doc),0,1,'');
$pdf->Cell(190,-4,'FECHA DE INGRESO : '.utf8_decode($this->dato->fecha_c)." ".utf8_decode($this->dato->hora_c),0,1,'R');
$pdf->Ln(6);
$pdf->Cell(190,4,'CONDICION DE PAGO : '.utf8_decode($this->dato->tipocompra->descripcion),0,1,'');

$pdf->SetFont('Courier','',8); 
$pdf->Ln(10);
// Código	Categoría	Producto	Cantidad	P.U.	Importe
// COLUMNAS
$pdf->SetFont('Courier', 'B', 8);
$pdf->Cell(15, 2, utf8_decode('Código'),0,0,'L');
$pdf->Cell(45, 2, utf8_decode('Categoría.'),0,0,'L');
$pdf->Cell(74, 2, 'PRODUCTO', 0);
$pdf->Cell(17, 2, 'Cantidad',0,0,'L');
$pdf->Cell(15, 2, 'P.U.',0,0,'R');
$pdf->Cell(20, 2, 'Importe',0,0,'R');
$pdf->Ln(4);
$pdf->Cell(200,0,'','T');
$pdf->Ln(1);
$total = 0;
foreach($this->dato->detalle as $d){

$pdf->SetFont('Courier', '', 8);

$pdf->Cell(15, 6, $d->Producto->ins_cod,0,0,'L');
$pdf->Cell(45, 6, utf8_decode($d->Producto->ins_cat),0,0,'L');
$pdf->MultiCell(60, 6,utf8_decode($d->Producto->ins_nom),0,'L'); 

$pdf->Cell(150, -6, ($d->cant * 1)." (".$d->Producto->ins_med.")",0,0,'R');
$pdf->Cell(15, -6, $d->precio,0,0,'R');
$pdf->Cell(20, -6, number_format(($d->cant * $d->precio),2),0,0,'R');
$pdf->Ln(1);
$total = ($d->cant * $d->precio) + $total;
} 
     
$pdf->Cell(200,0,'','T');
$pdf->Ln(1); 
$pdf->SetFont('Courier', 'B', 9);
$pdf->Cell(185, 10, "TOTAL  S/ ".number_format(($total),2),0,0,'R');
$pdf->Ln(12); 
$pdf->SetFont('Courier', '', 8);
$pdf->Cell(190,4,'DATOS DE IMPRESION',0,1,'R');
$pdf->Cell(190,4,'USUARIO: '.Session::get('nombres').' '.Session::get('apellidos'),0,1,'R');
date_default_timezone_set($_SESSION["zona_horaria"]);
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$pdf->Cell(190,4,'FECHA: '.date("d-m-Y h:i A"),0,1,'R');
$pdf->Ln(8);
$pdf->Cell(190,4,'___________________________________',0,1,'R');
$pdf->Cell(190,4,utf8_decode($this->dato->desc_per),0,1,'R');

$pdf->Ln(10);
$pdf->Output('ticket.pdf','i');
?>