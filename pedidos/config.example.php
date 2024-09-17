<?php
error_reporting(0);
$pass = '';

//constants
define('HASH_GENERAL_KEY', 'FacTuy0S0ft2022');
define('HASH_PASSWORD_KEY', 'KUjKYfkuigh2022KHd');

//database
define('DB_TYPE', 'mysql');
define('DB_HOST', 'localhost:3308');
define('DB_NAME', 'factuyorest');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8');

//datos de copyright
define('copyright', 'FacTUYO.com');
define('link_copyright', 'https://www.factuyo.com');
define('web_delivery',true); // activar o desactivar pagina de pedidos publico

//paths
define('URL', 'http://192.168.222.222/factuyorest/pedidos/'); //aqui poner la url de la web de pedidos
define('URL2', 'http://192.168.222.222/factuyorest/facturacion/'); //aqui poner la url del sistema
define('LIBS', 'libs/'); //no modificar
define('moneda', 'S/');
define('digDoc', '8');
define('horario_atencion', 'Lunes a Domingo de 03:00 pm a 10:00 pm.'); // horario de atencion de delivery
define('title_pagina', 'Factuyo.Rest Delivery'); // titulo de la web de delivery
define('nombre_local', 'Factuyo.Rest Delivery'); // titulo de la web de delivery
define('codigo_facebook', '1'); // si quiere que se active poner 1
define('enlace_facebook', 'https://www.facebook.com/FacTUYO');
define('codigo_instagram', '0'); // si quiere que se active poner 1
define('enlace_instagram', ''); // ingresar la url 
define('codigo_yape', '0'); // si quiere que se active poner 1
define('numero_yape', ''); // ingresas el numero
define('codigo_transferencia', '0'); // si quiere que se active poner 1 
define('numero_transferencia', ''); // ingresas el numero
define('codigo_plin', '0'); // si quiere que se active poner 1
define('numero_plin', ''); // ingresas el numero
define('codigo_tunki', '0'); // si quiere que se active poner 1
define('numero_tunki', ''); // ingresas el numero
define('codigo_culqi', '0');
define('descripcion_notas', 'Indique una nota a su pedido (Opcional)');
define('modalcovid', '1'); // si quieres que se desactive ingresar 0 