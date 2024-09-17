<?php
date_default_timezone_set($_SESSION["zona_horaria"]);
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$fecha = date("d-m-Y");
$fechaa = date("m-Y");
?>
<input type="hidden" id="moneda" value="<?php echo Session::get('moneda'); ?>"/>
<div class="row page-titles">
    <div class="col-md-5 col-8 align-self-center">
        <h4 class="m-b-0 m-t-0">Exportar</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>contable" class="link">Inicio</a></li>
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>contable" class="link">Contable</a></li>
            <li class="breadcrumb-item active">Exportar</li>
        </ol>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="card">        
            <form action="<?php echo URL; ?>contable/excel" method="post" target="_blank" id="myForm">  
                <div class="card-body p-b-0">
                    <h4 class="card-title">Exportar ventas </h4> 
                    <div class="message-box contact-box">
                        <div class="row floating-labels mt-5">
                            <div class="col-2">Por mes</div>
                            <div class="switch col-2">
                                <label><input type="checkbox" id="tipoBusqueda"><span class="lever switch-col-light-green"></span></label>
                            </div>
                            <div class="col-2">Por fechas</div>
                            <input type="hidden" name="tipoBusqueda_hidden" id="tipoBusqueda_hidden" value="0">
                        <!-- </div>
                        <div style="clear: both;"></div>
                        <div class="row floating-labels mt-5"> -->
                            <!-- <div class="col-lg-12" id="porfechas"> -->
                            <div class="col-lg-6" id="porfechas" style="display: none">
                                <div class="form-group m-b-40">
                                    <div class="input-group">
                                        <input type="text" class="form-control font-14 text-center" name="start" id="start" value="<?php echo '01-'.$fechaa; ?>" autocomplete="off"/>
                                        <span class="input-group-text bg-gris">al</span>
                                        <input type="text" class="form-control font-14 text-center" name="end" id="end" value="<?php echo $fecha; ?>" autocomplete="off"/>
                                    </div>
                                    <label>Seleccione rango de fechas</label>
                                </div>
                            </div>
                            <div class="col-lg-6" id="pormes">
                                <div class="form-group m-b-40">
                                    <div class="input-group">
                                        <span class="input-group-text bg-gris"><i class="fa fa-calendar"></i></span>
                                        <input type="text" class="form-control font-14 text-center" name="month" id="month" value="<?=date("m-Y")?>" autocomplete="off"/>
                                    </div>
                                    <label>Seleccione mes a exportar</label>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <input type="checkbox" name="estadocpe" id="estadocpe" class="chk-col-green" />
                                <label for="estadocpe">Agregar columna estado de CPE</label>
                            </div>
                            <div class="col-lg-6">
                                <input type="checkbox" name="formapago" id="formapago" class="chk-col-green" />
                                <label for="formapago">Argegar columna Forma de pago</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-footer text-right">
                    <button id="generarexcel" class="btn btn-success">Generar</button>
                </div>
            </form>

        </div>
    </div>
</div>