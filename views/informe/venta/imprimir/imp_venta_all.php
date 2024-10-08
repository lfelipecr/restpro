<?php
require_once ('public/lib/print/num_letras.php');
require_once ('public/lib/pdf/cellfit.php');
require_once ('public/lib/phpqrcode/qrlib.php');

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
// echo json_encode($this->dato->Config->pedido_comanda);
// return;
define('EURO',chr(128));

$cantidad_items=count($this->dato->Detalle);
$espacioxitem=20;
$atura_minima=250;
$altura_actual=($cantidad_items*$espacioxitem)+$atura_minima;

$pdf = new FPDF_CellFiti('P','mm',array(72,$altura_actual));
$pdf->AddPage();
$pdf->SetMargins(0,0,0,0);
$pdf->SetTitle(utf8_decode($this->dato->ser_doc).'-'.utf8_decode($this->dato->nro_doc));

// dimension de 
// CABECERA
if($this->empresa['logo']){
	$url_logo = URL."public/images/".$this->empresa['logo'];
	$pdf->Image($url_logo,L_CENTER,2,L_DIMENSION,0,L_FORMATO);
	$pdf->Cell(72,L_ESPACIO,'',0,1,'C');
}
$pdf->SetFont('Helvetica','',7);
$pdf->Cell(72,4,'',0,1,'C');
$pdf->SetFont('Helvetica','',12);
//$pdf->MultiCell(72,4,utf8_decode($this->empresa['nombre_comercial']),0,'C');
$pdf->SetFont('Helvetica','',9);
$pdf->MultiCell(72,4,utf8_decode($this->empresa['razon_social']),0,'C');
// $pdf->Cell(72,4,utf8_decode($url_logo),0,1,'C');
$pdf->SetFont('Helvetica','',9);
$pdf->Cell(72,4,utf8_decode('RUC').': '.utf8_decode($this->empresa['ruc']),0,1,'C');
$pdf->MultiCell(72,4,utf8_decode($this->empresa['direccion_comercial']),0,'C');
$pdf->Cell(72,4,'TELF: '.utf8_decode($this->empresa['celular']),0,1,'C');
 
// DATOS FACTURA
$elec = (($this->dato->id_tdoc == 1 || $this->dato->id_tdoc == 2) && $this->empresa['sunat'] == 1) ? 'ELECTRONICA' : '';     
$pdf->Ln(3);
$pdf->SetFont('Helvetica', 'B', 10);
$pdf->Cell(72,4,utf8_decode($this->dato->desc_td).' '.$elec,0,1,'C');
$pdf->Cell(72,4,utf8_decode($this->dato->ser_doc).'-'.utf8_decode($this->dato->nro_doc),0,1,'C');
$pdf->Ln(2);

$pdf->SetFont('Helvetica', 'B', 9);
if ($this->dato->Config->pedido_comanda == 1) {
	$pdf->MultiCell(72,4,'PED: '.str_pad($this->dato->id_ped, 5, "0", STR_PAD_LEFT).'',0,'L');
	//$pdf->Ln(2);
}

$pdf->SetFont('Helvetica', '', 9);
$pdf->Cell(72,4,'F. EMISION: '.date('d-m-Y h:i A',strtotime($this->dato->fec_ven)),0,1,'');
if($this->dato->id_tped == 1){
	$pdf->Cell(72,4,utf8_decode('ATENCION').': '.utf8_decode($this->dato->Pedido->desc_salon).' - MESA: '.utf8_decode($this->dato->Pedido->nro_mesa),0,1,'');
}else if ($this->dato->id_tped == 2){
	$pdf->Cell(72,4,'ATENCION: MOSTRADOR',0,1,'');
}else if ($this->dato->id_tped == 3){
	$pdf->Cell(72,4,'ATENCION: DELIVERY',0,1,'');
}
$pdf->MultiCell(72,4,'CLIENTE: '.utf8_decode($this->dato->Cliente->nombre),0,1,'');
if($this->dato->Cliente->tipo_cliente == 1){
$pdf->Cell(72,4,utf8_decode('DNI').': '.utf8_decode($this->dato->Cliente->dni),0,1,'');
}else{
$pdf->Cell(72,4,utf8_decode('RUC').': '.utf8_decode($this->dato->Cliente->ruc),0,1,'');
}
if ($this->dato->Cliente->telefono != '0') {
	$pdf->MultiCell(72,4,'TELEFONO: '.utf8_decode($this->dato->Cliente->telefono),0,1,'');
}
$pdf->MultiCell(72,4,'DIRECCION: '.utf8_decode($this->dato->Cliente->direccion),0,1,'');
if ($this->dato->Cliente->referencia != '') {
	$pdf->MultiCell(72,4,'REFERENCIA: '.utf8_decode($this->dato->Cliente->referencia),0,1,'');
}
if ($this->dato->Pedido->mozo) {
	$pdf->MultiCell(72,4,'MOZO: '.utf8_decode($this->dato->Pedido->mozo),0,1,'');
}

if ($this->dato->id_tped == 3 && $this->dato->Cliente->id_cliente != $this->dato->Cliente_pedido->id_cliente){
	$pdf->Ln(2);
	$pdf->SetFont('Helvetica', 'B', 10);
	$pdf->Cell(72,4,'DATOS DELIVERY:',0,1,'');
	$pdf->SetFont('Helvetica', '', 9);
	$pdf->Cell(72,4,'NOMBRE: '.$this->dato->Cliente_pedido->nombre_cliente.'',0,1,'');
	$pdf->Cell(72,4,'TELEFONO: '.$this->dato->Cliente_pedido->telefono_cliente.'',0,1,'');
	$pdf->Cell(72,4,'DIRECCION: '.$this->dato->Cliente_pedido->direccion_cliente.'',0,1,'');
	$pdf->Cell(72,4,'REFERENCIA: '.$this->dato->Cliente_pedido->referencia_cliente.'',0,1,'');
}
// COLUMNAS
$pdf->SetFont('Helvetica', 'B', 9);
$pdf->Cell(5, 10, 'CANT.',0,0);
$pdf->Cell(42, 10, 'PRODUCTO', 0,0,'C');
$pdf->Cell(10, 10, 'P.U.',0,0,'R');
$pdf->Cell(15, 10, 'IMP.',0,0,'R');
$pdf->Ln(8);
$pdf->Cell(72,0,'','T');
$pdf->Ln(1);
 
// PRODUCTOS
$total = 0;
$total_ope_gravadas = 0;
$total_igv_gravadas = 0;
$total_ope_exoneradas = 0;
$total_igv_exoneradas = 0;

foreach($this->dato->Detalle as $d){

	if($d->codigo_afectacion == '10'){
        $total_ope_gravadas = $total_ope_gravadas + $d->valor_venta;
        $total_igv_gravadas = $total_igv_gravadas + $d->total_igv;
        $total_ope_exoneradas = $total_ope_exoneradas + 0;
        $total_igv_exoneradas = $total_igv_exoneradas + 0;
    } else{
        $total_ope_gravadas = $total_ope_gravadas + 0;
        $total_igv_gravadas = $total_igv_gravadas + 0;
        $total_ope_exoneradas = $total_ope_exoneradas + $d->valor_venta;
        $total_igv_exoneradas = $total_igv_exoneradas + $d->total_igv;
    }

	if ($this->dato->consumo == '0') {
		$pdf->SetFont('Helvetica', '', 7);
		$pdf->Cell(10, 4, $d->cantidad,0,0,'L');
		$pdf->MultiCell(42,4,utf8_decode($d->nombre_producto),0,'L'); 
		$pdf->Cell(57, -4, $d->precio_unitario,0,0,'R');
		$pdf->Cell(15, -4, number_format(($d->cantidad * $d->precio_unitario),2),0,0,'R');
		$pdf->Ln(1);
	}


	if($d->cantidad > 0){
		$total = ($d->cantidad * $d->precio_unitario) + $total;
	}
}
 
if ($this->dato->consumo == '1') {
	$pdf->SetFont('Helvetica', '', 9);
	$pdf->Cell(10, 4, '1',0,0,'L');
	$pdf->MultiCell(42,4,utf8_decode($this->dato->consumo_desc),0,'L'); 
	$pdf->Cell(57, -4, number_format(($this->dato->total),2),0,0,'R');
	$pdf->Cell(15, -4, number_format(($this->dato->total),2),0,0,'R');
	$pdf->Ln(1);
}

 $pdf->Ln(0); 
// SUMATORIO DE LOS PRODUCTOS Y EL IVA
$sbt = (($this->dato->total + $this->dato->comis_tar + $this->dato->comis_del - $this->dato->desc_monto) / (1 + $this->dato->igv));
$igv = ($sbt * $this->dato->igv);
$pdf->SetFont('Helvetica', '', 9);
$pdf->Cell(72,0,'','T');
$pdf->Ln(0);    
$pdf->Cell(37, 10, 'SUB TOTAL', 0);    
$pdf->Cell(20, 10, '', 0);
$igvv = ($total_ope_gravadas > 0)? ''.igv_dec2.'' : '1';
$pdf->Cell(15, 10, number_format(((($this->dato->total - $this->dato->desc_monto) +$this->dato->comis_del) / $igvv),2),0,0,'R');

if(isset($this->dato->icbper) &&$this->dato->icbper != '0.00'){
	$pdf->Ln(4); 
	$pdf->Cell(37, 10, 'ICBPER', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, ''.number_format(($this->dato->icbper),2),0,0,'R');
}

if($this->dato->id_tped == 3){
	if($this->dato->comis_del > 0){
		$pdf->Ln(4); 
		$pdf->Cell(37, 10, 'COSTO POR DELIVERY', 0);    
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format(($this->dato->comis_del),2),0,0,'R');
	}
}
if($this->dato->desc_monto > 0){
$pdf->Ln(4); 
$pdf->Cell(37, 10, 'DESCUENTO', 0);    
$pdf->Cell(20, 10, '', 0);
$pdf->Cell(15, 10, '-'.number_format(($this->dato->desc_monto),2),0,0,'R');
}

$pdf->Ln(4); 

if ($this->dato->id_tdoc==1 || $this->dato->id_tdoc==2) {
	if ($total_ope_gravadas>0) {
		$pdf->Cell(37, 10, 'OP. GRAVADA', 0);   
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format($total_ope_gravadas,2),0,0,'R');
		$pdf->Ln(4);
	}
	$pdf->Cell(37, 10, 'OP. EXONERADA', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, number_format($total_ope_exoneradas,2),0,0,'R');
	$pdf->Ln(4);    
	$pdf->Cell(37, 10,'IGV '.igv_int.'%', 0);
	$pdf->Cell(20, 10, '', 0);
	if ($total_ope_gravadas>0) {
		$pdf->Cell(15, 10, number_format(((($this->dato->total- $this->dato->desc_monto) +$this->dato->comis_del) - ((($this->dato->total - $this->dato->desc_monto) +$this->dato->comis_del) / igv_dec2)),2),0,0,'R');
	}else{
		$pdf->Cell(15, 10, number_format(0,2),0,0,'R');
	}

	$pdf->Ln(9); 
}else{
	$pdf->Ln(6); 
}


// if ($total_ope_gravadas > 0 ) {
// 	$pdf->Cell(37, 10,'IGV '.igv_int.'%', 0);    
// 	$pdf->Cell(20, 10, '', 0);
// 	$pdf->Cell(15, 10, number_format(((($this->dato->total- $this->dato->desc_monto) +$this->dato->comis_del) - ((($this->dato->total - $this->dato->desc_monto) +$this->dato->comis_del) / igv_dec2)),2),0,0,'R');
// 	$pdf->Ln(4);
// }

$pdf->SetFont('Helvetica', 'B', 9);
$pdf->Cell(37, 10, 'TOTAL', 0);    
$pdf->Cell(20, 10, '', 0);
$pdf->Cell(15, 10, number_format(($this->dato->total + $this->dato->comis_del - $this->dato->desc_monto ),2),0,0,'R');
$pdf->Ln(8);

$pdf->Ln(2);
$pdf->SetFont('Helvetica', '', 9);
$pdf->MultiCell(72,4,'SON: '.numtoletras($this->dato->total + $this->dato->comis_del - $this->dato->desc_monto),0,'L');
$pdf->Ln(2);

$pdf->Cell(72,0,'','T');

	// $pdf->Ln(0);
	// $pdf->Cell(37, 10, 'EFECTIVO', 0);    

if($this->dato->id_tpag == 1){
	$pdf->Ln(0);
	$pdf->Cell(37, 10, 'EFECTIVO', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, number_format(($this->dato->pago_efe),2),0,0,'R');
} else if($this->dato->id_tpag == 2){
	$pdf->Ln(0);
	$pdf->Cell(37, 10, 'TARJETA', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, number_format(($this->dato->pago_tar),2),0,0,'R');
} else if($this->dato->id_tpag == 3){
	$pdf->Ln(0);
	$pdf->Cell(37, 10, 'EFECTIVO', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, number_format(($this->dato->pago_efe),2),0,0,'R');
	if ($this->dato->pago_tar != 0) {
		$pdf->Ln(4);
		$pdf->Cell(37, 10, 'TARJETA', 0);    
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format(($this->dato->pago_tar),2),0,0,'R');
	}
	if ($this->dato->pago_culqui != 0) {
		$pdf->Ln(4);
		$pdf->Cell(37, 10, 'CULQI', 0);    
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format(($this->dato->pago_culqui),2),0,0,'R');
	}
	if ($this->dato->pago_tran != 0) {
		$pdf->Ln(4);
		$pdf->Cell(37, 10, 'TRANSFERENCIA', 0);    
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format(($this->dato->pago_tran),2),0,0,'R');
	}
	if ($this->dato->pago_plin != 0) {
		$pdf->Ln(4);
		$pdf->Cell(37, 10, 'PLIN', 0);    
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format(($this->dato->pago_plin),2),0,0,'R');
	}
	if ($this->dato->pago_yape != 0) {
		$pdf->Ln(4);
		$pdf->Cell(37, 10, 'YAPE', 0);    
		$pdf->Cell(20, 10, '', 0);
		$pdf->Cell(15, 10, number_format(($this->dato->pago_yape),2),0,0,'R');
	}
}
if($this->dato->id_tpag == 1 OR $this->dato->id_tpag == 3){
	$pdf->Ln(8);
	$pdf->Cell(72,0,'','T');
	$pdf->Ln(0);
	$pdf->Cell(37, 10, 'PAGO CON', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, number_format(($this->dato->pago_efe_none),2),0,0,'R');
	$pdf->Ln(4);
	$pdf->Cell(37, 10, 'VUELTO', 0);    
	$pdf->Cell(20, 10, '', 0);
	$vuelto = ($this->dato->pago_efe_none - $this->dato->pago_efe);
	$pdf->Cell(15, 10, strtoupper(number_format(($vuelto),2)),0,0,'R');
} 

if($this->dato->id_tpag > 3) {
	$pdf->Ln(0);
	$pdf->Cell(37, 10, 'PAGO CON', 0);    
	$pdf->Cell(20, 10, '', 0);
	$pdf->Cell(15, 10, $this->dato->desc_tp,0,0,'R');
}
$pdf->Ln(10);

if($this->dato->id_tpag > 3) {
$pdf->Ln(0);
$pdf->Cell(37, 10, $this->dato->desc_tp, 0);    
$pdf->Cell(20, 10, '', 0);
$pdf->Cell(15, 10, number_format(($this->dato->pago_tar),2),0,0,'R');
}
if($this->dato->desc_tipo == 1){
$pdf->Ln(2);
$pdf->Cell(37, 4, 'CORTESIA', 0);   
$pdf->Cell(20, 4, '',0,0,'R');
$pdf->Cell(15, 4, '0.00',0,0,'R');
}
if($this->dato->desc_tipo == 3){
$pdf->Ln(2);
$pdf->Cell(37, 4, 'CREDITO PERSONAL', 0);   
$pdf->Cell(20, 4, '',0,0,'R');
$pdf->Cell(15, 4, number_format(($this->dato->desc_monto),2),0,0,'R');
}
$pdf->Ln(3);



$pdf->SetFont('Helvetica', 'B', 9);
$pdf->Cell(72,0,utf8_decode('CONDICION DE PAGO: CONTADO'),0,1,'L');
$pdf->Ln(4);
$pdf->Cell(72,0,'','T');
$pdf->Ln(3);

if ($this->dato->observacion!=null) {
	$pdf->SetFont('Helvetica', 'B', 9);
	$pdf->Cell(72,0,utf8_decode('OBSERVACIONES:'),0,1,'L');
	$pdf->Ln(4);
	$pdf->SetFont('Helvetica', 'B', 9);
	$pdf->Cell(72,0,utf8_decode($this->dato->observacion),0,1,'L');
	$pdf->Ln(4);
	$pdf->Cell(72,0,'','T');
	$pdf->Ln(3);
}

// CODIGO QR
$pdf->SetFont('Helvetica', 'B', 7);
if ($this->dato->id_tdoc==3) {
	
	$pdf->MultiCell(72,4,utf8_decode('Puede ser cambiado o canjeado por otro documento de compra.'),0,'C');
	$pdf->Ln(2);
}

if (footercpe==true) {


if(($this->dato->id_tdoc == 1 || $this->dato->id_tdoc == 2) && $this->empresa['sunat'] == 1){
	$td="";
	$tc="";
	$tdc="";
	if($this->dato->id_tdoc==1){
		$tc="03";
		$tdd="1";
		$tdc=$this->dato->Cliente->dni;
	}
	if($this->dato->id_tdoc==2){
		$tc="01";
		$tdd="6";
		$tdc=$this->dato->Cliente->ruc;
	}
	$nombreqr=$tc."-".$td.$this->dato->ser_doc."-".$this->dato->nro_doc;
		$text_qr = $this->empresa['ruc'] . '|' . $tc . '|' . $this->dato->ser_doc . '|' . $this->dato->nro_doc .'|'.number_format(($total_igv_gravadas + $total_igv_exoneradas),2).'|'.number_format(($this->dato->total),2).'|'.date('Y-m-d',strtotime($this->dato->fec_ven)).'|'. $tdd . '|' . $tdc . '|'.$this->dato->hash_cdr;
    $ruta_qr = 'api_fact/UBL21/archivos_xml_sunat/imgqr/QR_' . $nombreqr . '.png';
    $qr = 'api_fact/UBL21/archivos_xml_sunat/imgqr/QR_' . $nombreqr . '.png';

    if (!file_exists($ruta_qr)) {
        QRcode::png($text_qr, $qr, 'Q', 15, 0);
    }
	$pdf->Cell(25, 10,$pdf->Image($ruta_qr,2,$pdf->GetY(),20), 0); 
}
	
    $copyright='';

	if (desarrollador!='') {
		$copyright.=copyright;
		$copyright.="\n";
	}
	if (webdesarrollador!='') {
		$copyright.=webdesarrollador;
		$copyright.="\n";
	}
	if (descripcion!='') {
		$copyright.=descripcion;
	}

	if ($this->dato->id_tdoc==3) {
		$pdf->MultiCell(70,5,$copyright,0,'C');
	}else{
		$pdf->MultiCell(45,5,$copyright,0,'C');
	}
	
	$pdf->Ln(7);
}else{   


if(($this->dato->id_tdoc == 1 || $this->dato->id_tdoc == 2) && $this->empresa['sunat'] == 1){
	$td="";
	$tc="";
	$tdc="";
	if($this->dato->id_tdoc==1){
		$tc="03";
		$tdd="1";
		$tdc=$this->dato->Cliente->dni;
	}
	if($this->dato->id_tdoc==2){
		$tc="01";
		$tdd="6";
		$tdc=$this->dato->Cliente->ruc;
	}
	$nombreqr=$tc."-".$td.$this->dato->ser_doc."-".$this->dato->nro_doc;
		$text_qr = $this->empresa['ruc'] . '|' . $tc . '|' . $this->dato->ser_doc . '|' . $this->dato->nro_doc .'|'.number_format(($total_igv_gravadas + $total_igv_exoneradas),2).'|'.number_format(($this->dato->total),2).'|'.date('Y-m-d',strtotime($this->dato->fec_ven)).'|'. $tdd . '|' . $tdc . '|'.$this->dato->hash_cdr;
    $ruta_qr = 'api_fact/UBL21/archivos_xml_sunat/imgqr/QR_' . $nombreqr . '.png';
    $qr = 'api_fact/UBL21/archivos_xml_sunat/imgqr/QR_' . $nombreqr . '.png';

    if (!file_exists($ruta_qr)) {
        QRcode::png($text_qr, $qr, 'Q', 15, 0);
    }
	$pdf->Cell(25, 10,$pdf->Image($ruta_qr,2,$pdf->GetY(),20), 0); 
}

	$pdf->Ln(20);
}

$pdf->MultiCell(72,4,utf8_decode('Representacion impresa de la '.$this->dato->desc_td).' '.$elec.' consulte en',0,'C');
// $pdf->Cell(25, 10,' ',0);
//$pdf->MultiCell(72,4,URL.'consulta',0,'C'); // ACTIVAR PARA CONSULTAS ONLINE
$pdf->MultiCell(72,4,'https://bit.ly/ConsultaValidezCPE',0,'C'); //ACTIVAR PARA CONSULTAS OFFLINE
$pdf->Ln(2);

if ($this->empresa['amazonas'] == 1) {
	if ($total_ope_exoneradas > 0 ) {
	$pdf->SetFont('Helvetica', '', 7);
	$pdf->MultiCell(72,4,utf8_decode('BIENES TRANSFERIDOS EN LA AMAZONÍA PARA SER CONSUMIDOS EN LA MISMA'),0,'C');
	$pdf->Ln(5);
	}
}
// $pdf->SetFont('Helvetica', 'B', 9);
// $pdf->Cell(72,0,'GRACIAS POR SU PREFERENCIA',0,1,'C');
// $pdf->Ln(10);
//$pdf->Output('ticket.pdf','F');
// $pdf->Output('ticket.pdf','I');
$pdf->Output(utf8_decode($this->dato->ser_doc).'-'.utf8_decode($this->dato->nro_doc).'.pdf','I');
?>