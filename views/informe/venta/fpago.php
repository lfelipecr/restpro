<?php
date_default_timezone_set($_SESSION["zona_horaria"]);
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$fecha = date("d-m-Y");
$fechaa = date("m-Y");
?>
<input type="hidden" id="moneda" value="<?php echo Session::get('moneda'); ?>"/>
<div class="row page-titles">
    <div class="col-md-5 col-8 align-self-center">
        <h4 class="m-b-0 m-t-0">Informes</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>informe" class="link">Inicio</a></li>
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>informe" class="link">Informe de ventas</a></li>
            <li class="breadcrumb-item active">Formas de pago</li>
        </ol>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-body p-b-0">
                <div class="message-box contact-box">
                    <h2 class="add-ct-btn">                 
                        <div class="ml-auto">
                            <div class="btn-group">
                            <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <i class="fas fa-download"></i>
                            </button>
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="" href="javascript:void();" id="excel"></a>
                                    <a class="" href="javascript:void();" id="pdf"></a>
                                </div>
                            </div>
                        </div>
                    </h2>
                    <br>
                    <div class="row floating-labels m-t-5">
                        <div class="col-lg-4">
                            <div class="form-group m-b-40">
                                <div class="input-group">
                                    <input type="text" class="form-control font-14 text-center" name="start" id="start" value="<?php echo '01-'.$fechaa; ?>" autocomplete="off"/>
                                    <span class="input-group-text bg-gris">al</span>
                                    <input type="text" class="form-control font-14 text-center" name="end" id="end" value="<?php echo $fecha; ?>" autocomplete="off"/>
                                </div>
                                <label>Rango de fechas</label>
                            </div>
                        </div>
                        <div class="col-lg-2 offset-lg-6">
                            <div class="form-group m-b-40">
                                <select class="selectpicker form-control" name="filtro_tipo_pago" id="filtro_tipo_pago" data-style="form-control btn-default" data-live-search="true" autocomplete="off" data-size="5">
                                    <option value="%" active>Mostrar Todo</option>
                                    <optgroup>
                                        <?php foreach($this->TipoPago as $key => $value): ?>
                                            <option value="<?php echo $value['id_tipo_pago']; ?>"><?php echo $value['descripcion']; ?></option>
                                        <?php endforeach; ?>
                                    </optgroup>
                                </select>
                                <span class="bar"></span>
                                <label for="filtro_tipo_pago">Tipo Pago</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="text-center m-b-20">
                <div class="row">
                    <div class="col-2">
                        <h2 class="font-medium text-warning m-b-0 font-30 pagos-operaciones"></h2>
                        <h6 class="font-bold m-b-10">N° Operaciones</h6>                            
                    </div>
                    <div class="col-2">
                        <h2 class="font-medium text-warning m-b-0 font-30 efectivo-total"></h2>
                        <h6 class="font-bold m-b-10">Total de Efectivo</h6>
                    </div>
                    <div class="col-2">
                        <h2 class="font-medium text-warning m-b-0 font-30 tarjeta-total"></h2>
                        <h6 class="font-bold m-b-10">Total de Tarjeta</h6>
                    </div>
                    <div class="col-2">
                        <h2 class="font-medium text-warning m-b-0 font-30 yape-total"></h2>
                        <h6 class="font-bold m-b-10">Total YAPE</h6>
                    </div>
                    <div class="col-2">
                        <h2 class="font-medium text-warning m-b-0 font-30 plin-total"></h2>
                        <h6 class="font-bold m-b-10">Total PLIN</h6>
                    </div>
                    <div class="col-2">
                        <h2 class="font-medium text-warning m-b-0 font-30 tran-total"></h2>
                        <h6 class="font-bold m-b-10">Total Trans.</h6>
                    </div>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive b-t m-b-10">
                    <table id="table" class="table table-hover table-condensed stylish-table" width="100%">
                        <thead class="table-head">
                            <tr>
                                <th width="10%">Fecha</th>
                                <th width="">Cliente</th>
                                <th width="10%">Documento</th>
                                <th width="5%">Cod. vaucher</th>
                                <th width="5%">Tipo pago</th>
                                <th class="text-right" width="9%">Efectivo</th>
                                <th class="text-right" width="9%">Tarjeta</th>
                                <th class="text-right" width="10%">YAPE</th>
                                <th class="text-right" width="10%">PLIN</th>
                                <th class="text-right" width="10%">Transf.</th>
                                <th class="text-right" width="9%">Total</th>
                            </tr>
                        </thead>
                        <tbody class="tb-st"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>