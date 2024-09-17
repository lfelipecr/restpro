<?php

date_default_timezone_set('America/Lima');
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$hora = date("g:i:s A");
$fecha = date("d/m/y");

require __DIR__ . '/autoload.php';
use Mike42\Escpos\Printer;
use Mike42\Escpos\PrintConnectors\WindowsPrintConnector;

$data = json_decode($_GET['data'], true);

$connector = new WindowsPrintConnector("smb://DESKTOP-O3M71A9/CPE");

$printer = new Printer($connector);

$printer -> pulse();

$printer -> close();

?>
echo "<script lenguaje="JavaScript">window.close();</script>";