<?php 
    Session::init(); 
    $ver = (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3 OR Session::get('rol') == 5 OR Session::get('rol') == 7) ? '' :  header('location: ' . URL . 'err/danger'); 
    $ver = (Session::get('bloqueo') == 0 OR Session::get('bloqueo') == null) ? '' :  header('location: ' . URL . 'err/bloqueo');
?>
<?php
require_once 'public/lib/print/num_letras.php';
require_once 'models/ajuste_model.php';
require_once 'models/comprobante_model.php';

class Whatsapp extends Controller {

	function __construct() {
		parent::__construct();
	}
    
    function send_wsp_invoice(){

        $ajuste = new Ajuste_Model();
        $ajustes = $ajuste->datoplataforma_data();

        $this->checkApiStatus($ajustes->api_wsp);
        
        $numCliente = preg_replace("/[^0-9-.]/", "", $_REQUEST['num_cliente']);
        $idVenta = preg_replace("/[^0-9-.]/", "", $_REQUEST['id_venta']);
        $urlServer = "https://social.apiperudev.com/";
        $NumSender = $ajustes->wsp_number;
        // $NumSender = "51930369468";

        $datos1 = new Comprobante_Model();
        $empresa = $datos1->Empresa();
        $venta = $datos1->venta_all_imp_($idVenta);

        $curl = curl_init();
        $urlMedia = ''.$urlServer.'send-media?api_key='.$ajustes->wsp_token.'&sender='.$NumSender.'&number='.$numCliente.'&media_type=pdf&caption='.$empresa["ruc"].'-'.$venta->ser_doc.'-'.$venta->nro_doc.'&url='.URL.'comprobante/ticket/'.base64_encode($idVenta).'';

        $urlMsg = ''.$urlServer.'send-message?api_key='.$ajustes->wsp_token.'&sender='.$NumSender.'&number='.$numCliente.'&message=Estimado%20cliente%3A'.$this->sanitizar($venta->Cliente->nombre).'%3A%20%0Aadjuntamos%20su%20comprobante%20por%20consumo.%0ADetalles%3A%0ANúmero%3A%20'.$venta->ser_doc.'-'.$venta->nro_doc.'%0AFecha%3A%20'.date('d-m-Y',strtotime($venta->fec_ven)).'%0ATotal%3A%20'.$venta->total.'%0ATotal%20en%20letras%3A%20'.$this->sanitizar(numtoletras($venta->total)).'%0A%0Aatte%3A%0A'.$this->sanitizar($empresa["razon_social"]).'';

        curl_setopt_array($curl, array(
            CURLOPT_URL => $urlMedia,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_TIMEOUT => 0,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
            CURLOPT_POSTFIELDS =>'',
        ));

        $response = curl_exec($curl);

        curl_close($curl);
        $curl2 = curl_init();
        curl_setopt_array($curl2, array(
            CURLOPT_URL => $urlMsg,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_TIMEOUT => 0,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
            CURLOPT_POSTFIELDS =>'',
        ));

        $response2 = curl_exec($curl2);

        curl_close($curl2);

        $RestMedia = json_decode($response, true);
        $RestMsg = json_decode($response2, true);
        // echo urldecode($urlMsg);
        if ($RestMedia["status"] == true || $RestMsg["status"] == true) {
            echo json_encode(array('status' => true, 'msg' => "Respuesta envio PDF: ".$RestMedia["status"] == true ? $RestMedia["msg"] : ""." | Respuesta envio texto: ".$RestMsg["status"] == true ? $RestMsg["msg"] : "".""));
        }else{
            echo $response;
        }
        
        // echo $urlMedia;

    }

    function send_wsp_txt(){

        $ajuste = new Ajuste_Model();
        $ajustes = $ajuste->datoplataforma_data();

        $this->checkApiStatus($ajustes->api_wsp);

        $numCliente = preg_replace("/[^0-9-.]/", "", $_REQUEST['num_cliente']);
        $mensaje = $this->sanitizar($_REQUEST['mensaje']);
        $urlServer = "https://social.apiperudev.com/";
        $NumSender = $ajustes->wsp_number;

        $urlMsg = ''.$urlServer.'send-message?api_key='.$ajustes->wsp_token.'&sender='.$NumSender.'&number='.$numCliente.'&message='.$mensaje.'';

        $curl = curl_init();
        curl_setopt_array($curl, array(
            CURLOPT_URL => $urlMsg,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_TIMEOUT => 0,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
            CURLOPT_POSTFIELDS =>'',
        ));

        $response = curl_exec($curl);

        curl_close($curl);
        
        echo $response;

    }


    function sanitizar($texto){
        $ntexto = strip_tags($texto);
        $ntexto = str_replace("\n", '%0A', $texto);;
        $ntexto = str_replace(" ","%20",$texto);
        return $ntexto;
    }

    function sanitizarTxt($texto){
        $ntexto = strip_tags($texto);
        $ntexto = str_replace(" ","%20",$texto);
        return $ntexto;
    }

    function checkApiStatus($status){
        if ($status != 1) {
            echo json_encode(array('status' => false, 'msg' => "No tiene habilitado los permisos de envios por API Whatsapp"));
            return;
        }
    }
}