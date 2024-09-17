<?php 
// error_reporting(0);
// Session::init(); 

// $ver = (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3) ? '' :  header('location: ' . URL . 'err/danger'); 
?>
<?php

class Admin extends Controller {

    function __construct()
    {
        parent::__construct();
    }

    function datosEmpresa(){
// echo $this->model->seguridad($_GET["token"]);

        if ($this->model->seguridad($_GET["token"])==1) {

            print_r(json_encode($this->model->datosEmpresa($_POST)));

        }else{

            $mensaje = '{"status": false, "mensaje": "No autorizado"}';

            print_r($mensaje);

        }

    }

    function bloqueo()
    {

        if ($this->model->seguridad($_GET["token"])==1) {

            print_r(json_encode($this->model->bloqueoplataforma($_GET["accion"])));

        }else{

            $mensaje = '{"status": false, "mensaje": "No autorizado"}';

            print_r($mensaje);

        }

    }

    function cron()
    {

        if ($this->model->seguridad($_GET["token"])==1) {

            print_r(json_encode($this->model->cron($_GET["accion"])));

        }else{

            $mensaje = '{"status": false, "mensaje": "No autorizado"}';

            print_r($mensaje);

        }

    }
    
}