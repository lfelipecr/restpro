<?php 
Session::init(); 
$ver = (Session::get('rol') == 1 OR Session::get('rol') == 2) ? '' :  header('location: ' . URL . 'err/danger'); 
$ver = (Session::get('bloqueo') == 0 OR Session::get('bloqueo') == null) ? '' :  header('location: ' . URL . 'err/bloqueo');
?>
<?php

class Estadistica extends Controller {

	function __construct() {
		parent::__construct();
		Auth::handleLogin();
	}
	
	function index() 
	{
		$this->view->title_page = 'Estadistica';
		$this->view->js = array('estadistica/js/func_estadistica.js');
		$this->view->script = true;
		$this->view->Caja = $this->model->Caja();
		$this->view->render('estadistica/index');
	}
	
	function estadistica_datos()
    {
		$this->model->estadistica_datos($_POST);
    }

	function estadistica_g1()
	{
		$this->model->estadistica_g1($_POST);
	}
	
	function estadistica_g5()
	{
		$this->model->estadistica_g5($_POST);
	}
}