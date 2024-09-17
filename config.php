<?php
error_reporting(0);

// CONFIGURAR AQUI EL NOMBRE DEL NEGOCIO
define('NAME_NEGOCIO', 'ARTINDEV');

// CONFIGURAR AQUI EL ENVIO DE COMPROBANTES POR CORREO (SERVIDOR SMTP)
define('SERVER_SMTP', 'mail.factuyo.com');
define('EMAIL_SMTP', 'comprobantes@factuyo.com');
define('PASS_SMTP', 'F4CTUY02024');


define('MENSAJE_WHATSAPP', 'Su comprobante de pago electr贸nico ha sido generado correctamente, puede revisarlo en el siguiente enlace:');

//dise帽o css
define('css_selector', 'factuyorest');

//configuracion del logo print 
define('L_ALTURA','10'); // altura de sepacion del logo en pdf que se envia a correo
define('L_ALTURA_NOMBRE','25'); // altura de sepacion de la razon social en pdf que se envia a correo (calcular para que el logo no se pegue)
define('L_DIMENSION','25'); // dimenciona en largo como alto 
define('L_CENTER', '10'); // DE IZQUIERDA A DERECHA PARA PODER CENTRARL LA IMAGEN 
define('L_ESPACIO', '25'); // DARA EL ESPACIO ENTRE EL LOGO Y EL NOMBRE COMERCIAL 
define('L_FORMATO' , 'png'); // png, jpg, gif
// define();

//datos de bloqueos
define('numero_contacto', '+50686109613');
define('link_bloqueo', 'https://wa.me/50686109613');
define('btn_delivery',true); // activar o desactivar boton delivery en la venta

//datos de copyright
define('copyright', 'XALACHI');
define('link_copyright', 'https://www.xalachi.com');

//datos de footer cpe
define('footercpe', true); // si no desea el footer en el pdf de venta poner en false
define('desarrollador', 'Desarrollado por xalachi.com'); //dejar en blanco si no desean estos textos asi define('desarrollador', '');
define('webdesarrollador', 'www.xalachi.com'); //dejar en blanco si no desean estos textos asi define('webdesarrollador', '');
define('descripcion', 'Si requiere el software: 50686109613'); //dejar en blanco si no desean estos textos asi define('descripcion', '');


//configuraciones generales
define('ConcatProd', false); // esto es para concatenar el nombre del producto con presentacion o no


//constants
define('HASH_GENERAL_KEY', 'FacTuy0S0ft2022');
define('HASH_PASSWORD_KEY', 'KUjKYfkuigh2022KHd');

//database
define('DB_TYPE', 'mysql');
define('DB_HOST', 'localhost');
define('DB_NAME', 'schhrgyh_rest');
define('DB_USER', 'schhrgyh_artindev');
define('DB_PASS', 'Artindev@');
define('DB_CHARSET', 'utf8');

define('API_TOKEN', '1898c0771214e8c21343a89e97b7474f87e476ff');
define('API_SERVER', 'apiperu.dev');

// define('API_TOKEN', 'jrwRVYnqBZj7QRa5cyrr3psVp4PQK6YZxriodf5stp2ab9sXsF');
// define('API_SERVER', 'apiperu.net.pe');

//path
define('URL', 'https://rest.artindev.net/'); //aqui poner la url del sistema
define('LIBS', 'libs/');

//igv
define('igv_int', '18.00'); //igv entero
define('igv_dec', '0.10'); //igv decimales
define('igv_dec2', '1.10'); //igv decimales
define('fecha_igv', '2022-09-20 07:54:58'); //fecha de inicio emisi贸n 10%