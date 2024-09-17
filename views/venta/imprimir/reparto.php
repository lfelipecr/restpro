<?php
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

// print_r($this->dato);

date_default_timezone_set('America/Lima');
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$hora = date("g:i:s A");
$fecha = date("d/m/y");

define('EURO',chr(128));
$pdf = new FPDF_CellFiti('P','mm',array(75,200));
$pdf->AddPage();
$pdf->SetMargins(0,0,0);
// CABECERA
$pdf->SetFont('Helvetica','',6);
$pdf->Cell(72,4,'',0,1,'C');
$pdf->SetFont('Helvetica','',13);
$pdf->Cell(72,4,'TICKET',0,1,'C');
$pdf->Ln(3);
$pdf->SetFont('Helvetica','',13);
$pdf->Cell(72,6,"PEDIDO NRO.: ".utf8_decode($this->dato->nro_pedido)."\n",0,1,'L');
$pdf->Cell(72,6,"TELEFONO: ".utf8_decode($this->dato->Cliente->telefono)."\n",0,1,'L');
$pdf->Ln(3);
$pdf->SetFont('Helvetica','',11);
$pdf->Cell(72,4,'CLIENTE',0,1,'C');
$pdf->Ln(3);
$pdf->SetFont('Helvetica','',9);
$pdf->MultiCell(72,6,'NOMBRE: '.utf8_decode($this->dato->Cliente->nombre)."\n",0,'L');
$pdf->MultiCell(72,6,'DIRECCION: '.utf8_decode($this->dato->Cliente->direccion)."\n",0,'L');
$pdf->MultiCell(72,6,'REFERENCIA: '.utf8_decode($this->dato->Cliente->referencia),0,'L');
$pdf->Cell(72,6,"FECHA: ".$fecha."\n",0,1,'L');
$pdf->Cell(72,6,"HORA: ".$hora."\n",0,1,'L');


// COLUMNAS
$pdf->SetFont('Helvetica', 'B', 9);
$pdf->Cell(15, 10, 'CANT.',0,0,'R');
$pdf->Cell(45, 10, 'PRODUCTO', 0);
$pdf->Cell(10, 10, 'PRECIO',0,0,'R');
$pdf->Ln(8);
$pdf->Cell(72,0,'','T');
$pdf->Ln(1);

$total = 0;
foreach($this->dato->Detalle as $d){
$pdf->SetFont('Helvetica', '', 9);
$pdf->Cell(10, 4, $d->cantidad,0,0,'R');
//$pdf->MultiCell(45,4,utf8_decode($d->Producto->pro_nom).' '.utf8_decode($d->Producto->pro_pre),0,'L'); 
$pdf->MultiCell(45, 4, utf8_decode($d->Producto->pro_pre), 0, 'L');
$pdf->Cell(70, -4, number_format(($d->cantidad * $d->precio),2),0,0,'R');
$pdf->Ln(1);
$total = ($d->cantidad * $d->precio) + $total;
}

$pdf->SetFont('Helvetica', 'B', 10);
$pdf->Cell(72,0,'','T');
$pdf->Ln(3);
$pdf->Cell(72,6,'IMPORTE TOTAL: S/ '.number_format(($this->dato->total),2),0,1,'R');    
if($this->dato->id_tpag == 1){
    $vuelto = $this->dato->pago_efe_none - $this->dato->pago_efe;
    $pdf->Cell(72,6,"PAGO CON: S/ ".number_format(($this->dato->pago_efe_none),2),0,1,'R');
    $pdf->Cell(72,6,"VUELTO: S/ ".number_format($vuelto,2),0,1,'R');
} else { 
    $pdf->Cell(72, 6,"PAGO CON: ".$this->dato->desc_tp,0,0,'R');
}
// PIE DE PAGINA
$pdf->Ln(10);
$pdf->Output('ticket.pdf','i');
?>