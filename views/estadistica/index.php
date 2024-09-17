<div class="row page-titles">
    <div class="col-md-5 col-8 align-self-center">
        <h4 class="m-b-0 m-t-0">Cuadros Estadísticos</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>ajuste" class="link">Inicio</a></li>
            <li class="breadcrumb-item active">Estadística</li>
        </ol>
    </div>
</div>
<?php
    date_default_timezone_set($_SESSION["zona_horaria"]);
    setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
    $fecha = date("d-m-Y h:i A");
    $fechaa = date("d-m-Y 07:00");
?>
<input type="hidden" id="moneda" value="<?php echo Session::get('moneda'); ?>"/>
<input type="hidden" id="bloqueo" value="<?php echo Session::get('bloqueo'); ?>"/>
<div class="row">
    <!-- <div class="col-sm-12 col-lg-3">
            <div>
                <div class="row floating-labels m-t-20">
                    <div class="col-sm-12">
                        <div class="form-group">
                            <select class="selectpicker form-control" name="id_caja" id="id_caja" data-style="form-control btn-default" data-size="5" data-live-search-style="begins" data-live-search="true" autocomplete="off" required>
                                <?php foreach($this->Caja as $key => $value): ?>
                                    <option value="<?php echo $value['id_apc']; ?>"><?php echo $value['desc_caja']; ?></option>
                                <?php endforeach; ?>
                            </select>
                            <span class="bar"></span>
                            <label for="id_caja">Seleccione Caja</label>
                        </div>
                    </div>
                </div>
            </div>
    </div> -->

    <div class="col-sm-12 col-lg-12">
        <div class="row">
            <div class="col-sm-12 col-lg-6">
                <div class="card card-outline-success">
                    <div class="card-body">
                        <h4 class="card-title">VENTAS POR MOZOS</h4>
                        <div class="floating-labels pt-3">
                            <div class="form-row mb-2">
                                <div class="form-group col-lg-6 col-md-12">
                                    <label for="mozos_tipo">Mostrar por: </label>
                                    <select name="mozos_tipo" id="mozos_tipo" class="form-control">
                                        <option value="1">PEDIDOS ATENDIDOS</option>
                                        <option value="2">TOTAL DE VENTAS</option>
                                    </select>
                                </div>
                                <div class="form-group col-lg-6 col-md-12">
                                    <label for="mozos_mes">Filtrar por Mes: </label>
                                    <input type="month" name="mozos_mes" id="mozos_mes" class="form-control">
                                </div>
                            </div>
                            <canvas id="chart1" height="235" style="display: block; width: 470px; height: 235px;" width="470" class="chartjs-render-monitor"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-lg-6">
                <div class="card card-outline-success">
                    <div class="card-body">
                        <h4 class="card-title">PEDIDOS POR DELIVERY</h4>
                        <div class="text-center">
                            <canvas id="chart6" height="235" style="display: block; width: 470px; height: 235px;" width="470" class="chartjs-render-monitor"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-lg-6">
                <div class="card card-outline-info">
                    <div class="card-body">
                        <h4 class="card-title">COMPRAS vs VENTAS</h4>
                        <div class="text-center">
                            <canvas id="chart2" height="235" style="display: block; width: 470px; height: 235px;" width="470" class="chartjs-render-monitor"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-lg-6">
                <div class="card card-outline-success">
                    <div class="card-body">
                        <h4 class="card-title">VENTAS POR DÍA</h4>
                        <div class="text-center">
                            <canvas id="chart3" height="235" style="display: block; width: 470px; height: 235px;" width="470" class="chartjs-render-monitor"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-lg-6">
                <div class="card card-outline-success">
                    <div class="card-body">
                        <h4 class="card-title">VENTAS POR MESES</h4>
                        <div class="text-center">
                            <canvas id="chart4" height="235" style="display: block; width: 470px; height: 235px;" width="470" class="chartjs-render-monitor"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-lg-6">
                <div class="card card-outline-success">
                    <div class="card-body">
                        <h4 class="card-title">VENTAS POR CANAL</h4>
                        <div class="floating-labels pt-3">
                            <div class="form-row mb-2">
                                <div class="form-group col-lg-6 col-md-12">
                                    <label for="tipo_mes">Filtrar por Mes: </label>
                                    <input type="month" name="tipo_mes" id="tipo_mes" class="form-control">
                                </div>
                            </div>
                            <canvas id="chart5" height="235" style="display: block; width: 470px; height: 235px;" width="470" class="chartjs-render-monitor"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>