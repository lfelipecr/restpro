<?php
date_default_timezone_set($_SESSION["zona_horaria"]);
setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
$fecha = date("d-m-Y");
$fechaa = date("m-Y");
?>
<input type="hidden" id="moneda" value="<?php echo Session::get('moneda'); ?>"/>
<div class="row page-titles">
    <div class="col-md-5 col-8 align-self-center">
        <h4 class="m-b-0 m-t-0">Validador de comprobantes
        </h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>contable" class="link">Inicio</a></li>
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>contable" class="link">Contable</a></li>
            <li class="breadcrumb-item active">Validador de comprobantes</li>
        </ol>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-body p-b-0">
                <div class="message-box contact-box">
                    <h2 class="add-ct-btn">
                        <span style="text-align:right;" id="btn-excel"></span>
                    </h2>
                    <!-- <br>  -->
                    <div class="row floating-labels m-t-5">
                        <div class="col-lg-12 mt-2">
                            <input type="checkbox" name="buscarNumeros" id="buscarNumeros" class="chk-col-green" />
                            <label for="buscarNumeros">Buscar por numeración</label>
                        </div>
                        <input type="hidden" id="tipoBusqueda_hidden" name="tipoBusqueda_hidden" value="0">
                        <div class="col-lg-4 porfechas">
                            <div class="form-group m-b-40">
                                <div class="input-group">
                                    <input type="text" class="form-control font-14 text-center" name="start" id="start" value="<?php echo '01-'.$fechaa; ?>" autocomplete="off"/>
                                    <span class="input-group-text bg-gris">al</span>
                                    <input type="text" class="form-control font-14 text-center" name="end" id="end" value="<?php echo $fecha; ?>" autocomplete="off"/>
                                </div>
                                <label>Rango de fechas</label>
                            </div>
                        </div>
                        <div class="col-lg-2 pornumeros" style="display: none">
                            <div class="form-group m-b-40">
                                <input type="text" pattern="/^-?\d+\.?\d*$/" class="form-control numeracion" name="desde" id="desde" placeholder="00000000" maxlength="9">
                                <label for="desde">Desde</label>
                            </div>
                        </div>
                        <div class="col-lg-2 pornumeros" style="display: none">
                            <div class="form-group m-b-40">
                                <input type="text" pattern="/^-?\d+\.?\d*$/" class="form-control numeracion" name="hasta" id="hasta" placeholder="00000000" maxlength="9">
                                <label for="hasta">Hasta</label>
                            </div>
                        </div>

                        <div class="col-sm-6 col-lg-2">
                            <div class="form-group m-b-40">
                                <select class="selectpicker form-control" name="tipo_doc" id="tipo_doc" data-style="form-control btn-default" data-live-search="true" autocomplete="off" data-size="5">
                                    <option value="%" active>Mostrar Todo</option>
                                    <optgroup>
                                        <?php foreach($this->TipoDocumento as $key => $value): ?>
                                            <option value="<?php echo $value['id_tipo_doc']; ?>"><?php echo $value['descripcion']; ?></option>
                                        <?php endforeach; ?>
                                    </optgroup>
                                </select>
                                <span class="bar"></span>
                                <label for="tipo_doc">Tipo Comprobante</label>
                            </div>
                        </div>
                        <div class="col-sm-8 col-lg-2">
                            <div class="form-group m-b-40">
                                <button id="generarvalidador" class="btn btn-success">Validar</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive b-t m-b-10">
                    <table id="table" class="table table-hover table-condensed stylish-table" width="100%">
                        <thead class="table-head">
                            <tr>
                                <th width="10%" class="text-center">Fecha</th>
                                <th width="20%" class="text-center">Cliente</th>
                                <th width="15%" class="text-center">Documento</th>                                                              
                                <th width="10%" class="text-center">Estado Sistema</th>
                                <th width="10%" class="text-center">Estado Sunat</th>
                                <th width="10%" class="text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody class="tb-st"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
