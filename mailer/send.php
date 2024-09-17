<?php

// require('fpdf/fpdf.php');
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'Exception.php';
require 'PHPMailer.php';
require 'SMTP.php';
require_once ('public/lib/phpqrcode/qrlib.php');
// require 'config.php';
//require 'vendor/autoload.php';
//require 'Constantes.php';

class Email
{
    public function __construct() {
        //$this->db = new Database(DB_TYPE, DB_HOST, DB_NAME, DB_USER, DB_PASS, DB_CHARSET);
    }

    public function sendEmail($correo_cliente,$documento_cliente,$n_documento_cliente,$datos_factura,$negocio,$server_smtp,$email_smtp,$pass_smtp) {

        try {
            require('fpdf/fpdf.php');
            $pdf = new FPDF();
            $pdf->AddPage('PORTRAIT', 'a4');
            $data = json_decode($datos_factura,true);
         
            
            if($data['Empresa']['logo']!=''){
                $url_logo = URL."public/images/".$data['Empresa']['logo'];
                $pdf->Image($url_logo,L_CENTER,10,L_DIMENSION,0,L_FORMATO);
                $pdf->Cell(200,L_ALTURA_NOMBRE,'',0,1,'C');
            }else{
                $pdf->Cell(200,10,'',0,1,'C');
            }
            $pdf->SetFont('Arial','B',11);
            $pdf->Cell( 200, 5, utf8_decode($data['Empresa']['nombre_comercial']) , 0, 1, '');
            $pdf->SetFont('Arial','B',11);
            $pdf->Cell( 200, 5, utf8_decode($data['Empresa']['razon_social']) , 0, 1, '');
            $pdf->SetFont('Arial','',10);
            $pdf->MultiCell( 100, 5, ''.utf8_decode($data['Empresa']['direccion_comercial']).' ' , 0, 'L');
            // $pdf->Cell( 200, 5, 'TELF: '.utf8_decode($data['Empresa']['celular']) , 0, 1, '');
            
            //DATOS DE CLIENTE 
            $textypos = 5;
            $pdf->SetFont('Arial','B',10);    
            $pdf->setY(50);$pdf->setX(10);
            $pdf->Cell(5,$textypos,"Cliente: ");
            $pdf->SetFont('Arial','',10);    
            $pdf->setY(50);$pdf->setX(30);
            $pdf->Cell(5,$textypos,utf8_decode($data['Cliente']['nombre']));
            
            if ($data['Cliente']['tipo_cliente'] == 1){
                $tipodoc = 'DNI';
                $nrodoc = $data['Cliente']['dni'];
            }else if ($data['Cliente']['tipo_cliente'] == 2){
                $tipodoc = 'RUC';
                $nrodoc = $data['Cliente']['ruc'];
            }
            $pdf->SetFont('Arial','B',10);    
            $pdf->setY(55);$pdf->setX(10);
            $pdf->Cell(5,$textypos, $tipodoc);
            $pdf->SetFont('Arial','',10);    
            $pdf->setY(55);$pdf->setX(30);
            $pdf->Cell(5,$textypos, $nrodoc);
            
            $pdf->SetFont('Arial','B',10);
            $pdf->setY(60);$pdf->setX(10);
            $pdf->Cell(5,$textypos,"Direccion: ");
            $pdf->SetFont('Arial','',10);    
            $pdf->setY(60);$pdf->setX(30);
            $pdf->MultiCell( 100, 5, utf8_decode($data['Cliente']['direccion']), 0, 'L');
            
            // NRO DE FACTURA
            $elec = (($data['id_tdoc'] == 1 || $data['igv'] == 2) && $data['Empresa']['sunat'] == 1) ? 'ELECTRONICA' : '';
            $pdf->SetLineWidth(0.1); $pdf->SetFillColor(500); 
            $pdf->Rect(120, 10, 85, 30);
            $pdf->SetXY( 120, 15 ); 
            $pdf->SetFont( "Arial", "B", 12 ); 
            $pdf->Cell( 85, 4, 'R.U.C. Nro. '.utf8_decode($data['Empresa']['ruc']), 0, 0, 'C');
            $pdf->SetXY( 120, 15 ); 
            $pdf->Cell( 85, 20, $data['desc_td'].' '.$elec, 0, 0, 'C');
            $pdf->SetXY( 120, 15 ); 
            $pdf->Cell( 85, 36, $data['ser_doc'].'-'.$data['nro_doc'] , 0, 0, 'C');
            
            $pdf->SetFont('Arial','B',10);    
            $pdf->setY(55);$pdf->setX(135);
            $pdf->Cell(5,$textypos,"F. Emision: ");
            $pdf->SetFont('Arial','',10);    
            $pdf->setY(55);$pdf->setX(168);
            $pdf->Cell(5,$textypos, date('d-m-Y h:i A',strtotime($data['fec_ven'])));
            
            $pdf->SetFont('Arial','B',10); 
            $pdf->setY(60);$pdf->setX(135);
            $pdf->Cell(5,$textypos,"Moneda: ");
            $pdf->SetFont('Arial','',10);    
            $pdf->setY(60);$pdf->setX(168);
            $pdf->Cell(5,$textypos,"SOLES");
            
            /// Apartir de aqui empezamos con la tabla de productos
            $pdf->setY(70);$pdf->setX(135);
            $pdf->Ln();
            /////////////////////////////
            //// Array de Cabecera

$mystring = $data['igv'];
$igv_buscar   = '18';
$pos = strpos($mystring, $igv_buscar);

if ($pos === false) {
    $igv_dec2 = "0.10";
    $igv_dec = "1.10";
    $igv_int = "10";

} else {
    $igv_dec2 = "0.18";
    $igv_dec = "1.18";
    $igv_int = "18";
}

            $header = array("Descripcion","Cant.","P. Unitario","Importe");
            //// Arreglo de Productos
            
                // Column widths
                $w = array(126, 20, 25, 25);
                // Header, el numero 7 define el alto de la cabecera
                $pdf->SetFont('Arial','B',10); 
                for($i=0;$i<count($header);$i++)
                    
                $pdf->Cell($w[$i],7,$header[$i],1,0,'C');
                $pdf->Ln();
                // Data
                $pdf->SetFont('Arial','',10);
                
                $total = 0;
                $total_ope_gravadas = 0;
                $total_igv_gravadas = 0;
                $total_ope_exoneradas = 0;
                $total_igv_exoneradas = 0;
                foreach($data['Detalle'] as $row)
                {
                    if($row['codigo_afectacion'] == '10'){
                        $total_ope_gravadas = $total_ope_gravadas + $row['valor_venta'];
                        $total_igv_gravadas = $total_igv_gravadas + $row['total_igv'];
                        $total_ope_exoneradas = $total_ope_exoneradas + 0;
                        $total_igv_exoneradas = $total_igv_exoneradas + 0;
                    } else{
                        $total_ope_gravadas = $total_ope_gravadas + 0;
                        $total_igv_gravadas = $total_igv_gravadas + 0;
                        $total_ope_exoneradas = $total_ope_exoneradas + $row['valor_venta'];
                        $total_igv_exoneradas = $total_igv_exoneradas + $row['total_igv'];
                    }

                    $pdf->SetFont('Arial','',7);    
                    $pdf->Cell($w[0],6,utf8_decode($row['nombre_producto']),1);
                    $pdf->SetFont('Arial','',10);    
                    $pdf->Cell($w[1],6,number_format($row['cantidad']),'1',0,'C');
                    $pdf->Cell($w[2],6,"S/  ".number_format($row['precio_unitario'],2,".",","),'1',0,'R');
                    $pdf->Cell($w[3],6,"S/  ".number_format($row['cantidad']*$row['precio_unitario'],2,".",","),'1',0,'R');
            
                    $pdf->Ln();
                    //// aqui multiplica la cantidad por elprecio unitario
                    $total = ($row['cantidad'] * $row['precio_unitario']) + $total;
                }
            /////////////////////////////
            //// Apartir de aqui esta la tabla con los subtotales y totales
            //$yposdinamic = 70 + (count($products)*10);
            
            $pdf->setX(215);
            $pdf->Ln();
            /////////////////////////////
                        

            $pdf->Ln(3);
            // CODIGO QR
            if(($data['id_tdoc'] == 1 || $data['id_tdoc'] == 2) && Session::get('sunat') == 1){
                $td="";
                $tc="";
                $tdc="";
                if($data['id_tdoc']==1){
                    $tc="03";
                    $tdd="1";
                    $tdc=$nrodoc;
                }
                if($data['id_tdoc']==2){
                    $tc="01";
                    $tdd="6";
                    $tdc=$nrodoc;
                }
                $nombreqr=$tc."-".$td.$data['ser_doc']."-".$data['nro_doc'];
                $text_qr = $data['Empresa']['ruc'] . '|' . $tc . '|' . $data['ser_doc'] . '|' . $data['nro_doc'] . '|' . $tdd . '|' . $tdc . '|';
                $ruta_qr = 'api_fact/UBL21/archivos_xml_sunat/imgqr/QR_' . $nombreqr . '.png';
                $qr = 'api_fact/UBL21/archivos_xml_sunat/imgqr/QR_' . $nombreqr . '.png';

                if (!file_exists($ruta_qr)) {
                    QRcode::png($text_qr, $qr, 'Q', 15, 0);
                }

            }

                // $pdf->SetFont('Helvetica', 'B', 7);
                $pdf->Ln();
                $pdf->setX(10);
                $pdf->Cell(40,0,$pdf->Image($ruta_qr,20,$pdf->GetY(),35),0,0,'C');
                // $pdf->Cell(36,6,"",'1',0,'R');
                $pdf->Ln();
                $pdf->setX(130);
                $pdf->Cell(40,6,"Subtotal",1);
                $pdf->Cell(36,6,"S/ ".number_format($data['total'], 2, ".",","),'1',0,'R');
                $pdf->Ln();
                $pdf->setX(130);
                $pdf->Cell(40,6,"Costo delivery",1);
                $pdf->Cell(36,6,"S/ ".number_format($data['comis_del'], 2, ".",","),'1',0,'R');
                $pdf->Ln();
                $pdf->setX(130);
                $pdf->Cell(40,6,"Descuento",1);
                $pdf->Cell(36,6,"S/ ".number_format($data['desc_monto'], 2, ".",","),'1',0,'R');
                $pdf->Ln();
                $pdf->setX(130);
                $pdf->Cell(40,6,"Operacion Gravada",1);

$sbt = (($data['total'] + $data['comis_tar'] + $data['comis_del'] - $data['desc_monto']) / ($igv_dec));

$igv = ($sbt * $igv_dec2);

// $sbt = (($data['total'] + $data['comis_del'] - $data['desc_monto']) / (1 + $data['igv']));

    // $igv_int = "1.".intval($data['igv']);

    if ($data['desc_monto']>0) {
        $pdf->Cell(36,6,"S/ ".number_format(  ($data['total'] + $data['comis_tar'] + $data['comis_del'] - $data['desc_monto']) / ($igv_dec)  ,2, ".",","),'1',0,'R');

    }else{
        $pdf->Cell(36,6,"S/ ".number_format(($data['total'] + $data['comis_tar'] + $data['comis_del']) / ($igv_dec),2, ".",","),'1',0,'R');
    }


                $pdf->Ln();
                $pdf->setX(130);
                $pdf->Cell(40,6,"Operacion Exonerada",1);
                $pdf->Cell(36,6,"S/ ".number_format($total_ope_exoneradas, 2, ".",","),'1',0,'R');
                $pdf->Ln();
                $pdf->setX(130);
                $pdf->Cell(40,6,"IGV ".$igv_int."%",1);
                $pdf->Cell(36,6,"S/ ".number_format($igv, 2, ".",","),'1',0,'R');
                $pdf->Ln();

if($data['rc_val'] > 0){
                $pdf->setX(130);
                $pdf->Cell(40,6,"RECARGO AL CONSUMO ".$data['rc_val']."%",1);
                $pdf->Cell(36,6,"S/ ".number_format($data['rc_total'], 2, ".",","),'1',0,'R');
                $pdf->Ln();
}


                $pdf->setX(130);
                $pdf->Cell(40,6,"Importe Total",1);
                $pdf->Cell(36,6,"S/ ".number_format($data['total'] + $data['comis_del'] + $data['rc_total'] - $data['desc_monto'], 2, ".",","),'1',0,'R');
                $pdf->Ln();

                // Data
                // foreach($data2 as $row)
                // {
                //     $pdf->setX(130);
                //     $pdf->Cell($w2[0],6,$row[0],1);
                //     $pdf->Cell($w2[1],6,"S/ ".number_format($row[1], 2, ".",""),'1',0,'R');
                //     $pdf->Ln();
                // }
            /////////////////////////////
            
            //$yposdinamic += (count($data2)*10);
            $pdf->SetFont('Arial','B',10);    
            $pdf->setX(10);
            $pdf->Ln();
            $pdf->Cell(5,$textypos,'SON: '.numtoletras($data['total'].''));
            $pdf->SetFont('Arial','',8);
            $pdf->Ln(5);
            $pdf->setX(10);
            $pdf->Cell(5,$textypos,utf8_decode('Consultar la validez del comprobante en https://ww3.sunat.gob.pe/ol-ti-itconsvalicpe/ConsValiCpe.htm'),'C');
            $pdf->Ln(5);
            $pdf->setX(10);
            $pdf->Cell(5,$textypos,utf8_decode('Representación impresa de '.$data['desc_td'].' '.$elec));
            $pdfdoc = $pdf->Output('', 'S');










            $mail = new PHPMailer(true);
            $mail->SMTPDebug = 0;
            $mail->isSMTP();
            
            $mail->CharSet = 'UTF-8';
            
            $mail->Host = ''.$server_smtp.'';
            $mail->SMTPAuth = true;

            $mail->Username = ''.$email_smtp.'';
            $mail->Password = ''.$pass_smtp.'';

            $mail->SMTPSecure = 'ssl';
            $mail->Port = 465;
            
            if ($data['id_tdoc']==1) {
                $tipo_doc = '03';
            }

            if ($data['id_tdoc']==2) {
                $tipo_doc = '01';
            }


            if ($data['id_tdoc']==2 || $data['id_tdoc']==1) {
                //para enviar xml
                $xml = "".$documento_cliente."".utf8_decode($data['Empresa']['ruc']).'-'.$tipo_doc.'-'.$data['ser_doc'].'-'.$data['nro_doc'].'.XML'."";
                $fxml = file_get_contents($xml);
                $mail->addStringAttachment($fxml, utf8_decode($data['Empresa']['ruc']).'-'.$data['ser_doc'].'-'.$data['nro_doc'].'.XML');

                //para enviar cdr
                $cdr = "".$documento_cliente."R-".utf8_decode($data['Empresa']['ruc']).'-'.$tipo_doc.'-'.$data['ser_doc'].'-'.$data['nro_doc'].'.XML'."";
                $body_cdr = @file_get_contents( "".$cdr."", NULL );

                if (strpos($body_cdr, 'gina no encontrad') === false) {
                    $fcdr = file_get_contents($cdr);
                    $mail->addStringAttachment($fcdr, 'CDR-'.utf8_decode($data['Empresa']['ruc']).'-'.$data['ser_doc'].'-'.$data['nro_doc'].'.XML');
                }

            }


            
            $mail->AddStringAttachment($pdfdoc, utf8_decode($data['Empresa']['ruc']).'-'.$data['ser_doc'].'-'.$data['nro_doc'].'.pdf', 'base64', 'application/pdf');
                
            ## MENSAJE A ENVIAR
            $mail->setFrom(''.$email_smtp.'', $negocio);
            $mail->addAddress($correo_cliente);

            $mail->isHTML(true);
            $mail->Subject = 'Envio de Comprobante de Pago Electrónico';
            // $mail->Body = 'Estimad@: ss, informamos que su comprobante electrónico ha sido emitido exitosamente. <br> dd';
            $mail->Body = 'Estimad@: <strong> '.utf8_decode($data['Cliente']['nombre']).' </strong>, informamos que su comprobante electrónico ha sido emitido exitosamente. <br> <br>
                            Los datos de su comprobante electrónico son: <br><br>
                            Razon social: '.utf8_decode($data['Empresa']['razon_social']).' <br>
                            RUC: '.utf8_decode($data['Empresa']['ruc']).' <br>
                            Fecha de emisión: '.date('d-m-Y h:i A',strtotime($data['fec_ven'])).' <br>
                            Nro. de comprobante: '.$data['ser_doc'].'-'.$data['nro_doc'].' <br>
                            Total: '.number_format(($data['total'] + $data['comis_del'] + $data['rc_total'] - $data['desc_monto']),2).' <br> <br>
                            <strong>Gracias por su compra.</strong>
                            ';

            $isSent = $mail->send();
            if($isSent){
                echo json_encode(1);
            }else{
                echo json_encode(2);
            }
            // echo $mail->Body;






        } catch (Exception $exception) {
            echo 'Error:', $exception->getMessage();
            echo json_encode(2);
        }
    }
}
