<?php

require 'config.php';
require 'util/Auth.php';

// __autoload / Also spl_autoload_register (Take a look at it if you like)
function banshee_autoload($class) {
	require LIBS . $class .".php";
}

if (web_delivery==false) {
	header("Location: ".URL2.""); //aqui la url de tu pagina de pedidos
	exit;
}
spl_autoload_register ("banshee_autoload");
$bootstrap = new Bootstrap();
$bootstrap->init();
