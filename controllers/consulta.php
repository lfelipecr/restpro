<?php

class Consulta extends Controller {

	function __construct() {
		parent::__construct();
	}
	
	function index() {
        $this->view->js = array('consulta/js/consulta.js');
		$this->view->render('consulta/index', false);
	}
    function buscar(){
        print_r(json_encode($this->model->buscar($_POST)));
    }



}