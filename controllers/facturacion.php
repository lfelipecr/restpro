<?php 
    Session::init(); 
    $ver = (Session::get('bloqueo') == 0 OR Session::get('bloqueo') == null) ? '' :  header('location: ' . URL . 'err/bloqueo');
?>
<?php
require_once 'public/lib/print/num_letras.php';
require_once 'api_fact/controller/api.php';
require_once 'mailer/send.php';

class Facturacion extends Controller {

	function __construct() {
		parent::__construct();
		Auth::handleLogin();
	}

	function Index(){
        $this->view->title_page = 'Facturación Electrónica';
        $this->view->js = array('venta/js/jquery-ui.min.js','facturacion/js/facturacion.js');
		$this->view->render('facturacion/index', false);
    }

    function Datos1(){
        $this->model->Datos1($_POST);
    }

    function Datos2(){
        $this->model->Datos2($_POST);
    }

    function Datos3(){
        $this->model->Datos3($_POST);
    }

    function Datos4(){
        $this->model->Datos4($_POST);
    }

    function Datos5(){
        $this->model->Datos5($_POST);
    }

    function Detalle(){
        $this->model->Detalle($_POST);
    }

    function Invoice(){
        $cod_ven = $_POST['cod_ven'];
        $invoice = new ApiSunat();
        $data = $invoice->sendDocSunaht($cod_ven,1);    
    }

    function ComunicacionBaja(){
        $api = new ApiSunat();
        $api->postComunicacionBaja($_POST);
    }

    function reenvio(){
        $this->model->reenvio($_POST);
        print_r(json_encode(1));
    }
    
    function cambioFecha(){
        $this->model->cambioFecha($_POST);
        print_r(json_encode(1));
    }

    function Resumen_boletas(){
        $api = new ApiSunat();
        $api->postResumenDiario($_POST);
    }  

    function send_mailer(){
        $negocio = "".NAME_NEGOCIO."";
        $server_smtp = "".SERVER_SMTP."";
        $email_smtp = "".EMAIL_SMTP."";
        $pass_smtp = "".PASS_SMTP."";
        $datos_factura = $this->model->pdf_factura($_POST['id_venta']);
        $api = new Email();
        // echo $_POST['id_venta'];
        // return;
        $api->sendEmail($_POST['correo_cliente'],$_POST['documento_cliente'],$_POST['n_documento_cliente'],json_encode($datos_factura),$negocio,$server_smtp,$email_smtp,$pass_smtp);
    }

}