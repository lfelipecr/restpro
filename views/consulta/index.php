<input type="hidden" id="mesaje_waz" value="Su comprobante de pago electrónico ha sido generado correctamente, puede revisarlo en el siguiente enlace:"/>
<div class="body-web page-wrapper">
    <div class="container">
        <div class="row">
            <div class="col-md-8">
                <div class="card">  
                    <form id="form" method="post" enctype="multipart/form-data">              
                        <div class="card-body">
                            <h4 class="card-title m-b-40">Buscar comprobante electrónico</h4>
                            <div class="row floating-labels m-t-30">
                                <div class="col-lg-8">
                                    <div class="form-group m-b-40">
                                        <select class="selectpicker form-control p-0" name="tipo_comprobante" id="tipo_comprobante" data-style="form-control btn-default" data-live-search="true" autocomplete="off">
                                            <option value="1">BOLETA DE VENTA ELECTRÓNICA</option>
                                            <option value="2">FACTURA ELECTRÓNICA</option>
                                        </select>
                                        <span class="bar"></span>
                                        <label for="tipo_comprobante">Tipo Documento *</label>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="form-group m-b-40">
                                        <div class="input-group">
                                            <input type="text" class="form-control font-14 text-center" name="fecha" id="fecha" value="" autocomplete="off" required="required"/>
                                        </div>
                                        <label>Fecha de facturación</label>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="form-group m-b-40">
                                        <input type="text" class="form-control" id="serie" name="serie" autocomplete="off" maxlength="4" minlength="4" required="required">
                                        <span class="bar"></span>
                                        <label for="serie">Serie</label>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="form-group m-b-40">
                                        <input type="text" class="form-control" id="numero" name="numero" autocomplete="off" maxlength="8" minlength="8" required="required">
                                        <span class="bar"></span>
                                        <label for="numero">Número</label>
                                    </div>
                                </div>

                                <div class="col-lg-6">
                                    <div class="form-group m-b-40">
                                        <input type="text" class="form-control" id="numero_cliente" name="numero_cliente" autocomplete="off" required="required">
                                        <span class="bar"></span>
                                        <label for="numero_cliente">Número Cliente (RUC/DNI/CE)</label>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="form-group m-b-40">
                                        <input type="text" class="form-control "  id="monto_total" name="monto_total" autocomplete="off" required="required">
                                        <span class="bar"></span>
                                        <label for="monto_total">Monto total</label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-12 mb-3">
                                <div class="text-right">
                                    <button class="btn btn-success" type="submit">Buscar</button>
                                </div>
                            </div>
                            <div class="respuesta text-center"></div>
                            <table class="table resultado" style="display:none">
                                <thead>
                                    <tr>
                                        <th>Cliente</th> 
                                        <th>Número</th> 
                                        <th class="text-right">Total</th> 
                                        <th width="5%">XML</th>
                                        <th width="5%">CDR</th>
                                        <th width="5%">PDF</th>
                                        <th width="5%">WHATSAPP</th>
                                    </tr>
                                </thead> 
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .body-web {
        height: 100vh;
    }
    .container {
        height: 100%;
    }
    .row {
        height: 100%;
        justify-content: center;
        align-items: center;
    }
    .card {
        margin: 0;
    }
    .mini-sidebar .page-wrapper {
        margin-left: 0px!important;
    }
</style>