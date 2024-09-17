<input type="hidden" id="bloqueo_id" value="<?php print (Session::get('bloqueo_id')); ?>"/>
<div class="row page-titles">
    <div class="col-md-5 col-8 align-self-center">
        <h4 class="m-b-0 m-t-0">Ajustes</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>ajuste" class="link">Inicio</a></li>
            <li class="breadcrumb-item active">Panel de opciones</li>
        </ol>
    </div>
</div>
<div class="wrapper wrapper-content animated fadeIn ng-scope">
    <div class="row">
        <div class="col-lg-4">
            <div class="card card-body p-0">
                <h4 class="card-title p-t-20 p-l-20 p-r-20 m-b-0">Sistema</h4>
                <div class="message-box">
                    <div class="message-widget m-t-10">                        
                        <a href="ajuste/sistema">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-warning"><i class="fas fa-cog"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Configuraci&oacute;n inicial</h5> <span class="mail-desc">Caracter&iacute;sticas, opciones, otros.</span>
                            </div>
                        </a>
                        <a href="ajuste/printer">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-warning"><i class="fas fa-print"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Impresoras</h5> <span class="mail-desc">Creaci&oacute;n, modificaci&oacute;n.</span>
                            </div>
                        </a>
                        <?php if (Session::get('rol') == 1):?> 
                        <a href="ajuste/optimizar">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-warning"><i class="fas fa-random"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Optimizaci&oacute;n de procesos</h5> <span class="mail-desc">Reducir o eliminar la p&eacute;rdida de tiempo y recursos</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="btn-plataforma">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-warning"><i class="fas fa-server"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Ajustes Plataforma</h5> <span class="mail-desc">Administra tu plataforma</span>
                            </div>
                        </a>
                        
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card card-body p-0">
                <h4 class="card-title p-t-20 p-l-20 p-r-20 m-b-0">Empresa</h4>
                <div class="message-box">
                    <div class="message-widget m-t-10">
                        <a href="ajuste/datosempresa">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-primary"><i class="fas fa-building"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Datos de la empresa</h5> <span class="mail-desc">Modificar los datos de la empresa.</span>
                            </div>
                        </a>                        
                        <a href="ajuste/usuario">
                            <div class="m-t-10"></div>
                            <div class="user-img"> <span class="round bg-primary"><i class="fas fa-user"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Usuarios / Roles</h5> <span class="mail-desc">Creaci&oacute;n, modificaci&oacute;n.</span>
                            </div>
                        </a>
                        <a href="ajuste/tipodoc">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-primary"><i class="fas fa-file-alt"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Tipo de documentos </h5> <span class="mail-desc">Modificar los tipos de documentos.</span>
                            </div>
                        </a>
                        <a href="ajuste/tipopago">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-primary"><i class="fas fa-credit-card"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Tipos de pago </h5> <span class="mail-desc">Modificar los tipos de pagos.</span>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card card-body p-0">
                <h4 class="card-title p-t-20 p-l-20 p-r-20 m-b-0">Restaurante</h4>
                <div class="message-box">
                    <div class="message-widget m-t-10">
                        <a href="ajuste/caja">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-success"><i class="fas fa-desktop"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Cajas</h5> <span class="mail-desc">Creaci&oacute;n, modificaci&oacute;n.</span>
                            </div>
                        </a>
                        <a href="ajuste/areaprod">
                            <div class="m-t-10"></div>
                            <div class="user-img"><span class="round bg-success"><i class="ti-layout-accordion-separated"></i></span></div>
                            <div class="mail-contnet">
                                <h5>&Aacute;reas de Producci&oacute;n</h5> <span class="mail-desc">Creaci&oacute;n, modificaci&oacute;n.</span>
                            </div>
                        </a>
                        <a href="ajuste/salon-mesa">
                            <div class="m-t-10"></div>
                            <div class="user-img"> <span class="round bg-success"><i class="ti-layout-slider-alt"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Salones y mesas</h5> <span class="mail-desc">Creaci&oacute;n, modificaci&oacute;n.</span>
                            </div>
                        </a>
                        <a href="ajuste/producto">
                            <div class="m-t-10"></div>
                            <div class="user-img"> <span class="round bg-success"><i class="fas fa-archive"></i></span></div>
                            <div class="mail-contnet">
                                <h5>Productos</h5> <span class="mail-desc">Creaci&oacute;n, modificaci&oacute;n.</span>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>        
    </div>
</div>

<div class="modal inmodal" id="modal-plataforma" tabindex="-1" role="dialog" aria-hidden="true" data-backdrop="static" data-keyboard="true">
    <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content animated bounceInTop">
        <form id="form-plataforma" method="post" enctype="multipart/form-data">
            <div class="modal-header">
                <h4 class="modal-title">Configuración plataforma</h4>
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Cerrar</span></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-sm-12 b-r">
                        <div class="row m-t-20 floating-labels">
                            <div class="col-lg-4">
                                <div class="form-group m-b-40">
                                    <div class="input-group">
                                        <input type="text" class="form-control font-14 text-center" name="created_at" id="created_at" value="" autocomplete="off"/>
                                    </div>
                                    <label>Fecha de facturación</label>
                                </div>
                            </div>
                            <div class="col-sm-6 col-lg-4">
                                <div class="form-group f m-b-40 letNumMayMin">
                                    <input type="text" class="form-control input-mayus cbu text-center" name="limit_documents" id="limit_documents" autocomplete="off">
                                    <span class="bar"></span>
                                    <label for="limit_documents">Límite de CPE</label>
                                </div>
                            </div>
                            <div class="col-sm-6 col-lg-4">
                                <div class="form-group f m-b-40 letNumMayMin">
                                    <input type="text" class="form-control input-mayus cbu text-center" name="limit_users" id="limit_users" autocomplete="off">
                                    <span class="bar"></span>
                                    <label for="limit_users">Límite de usuarios</label>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="form-group m-b-40">
                                    <span class="bar"></span>
                                    <label for="cod_seg">Bloquear comprobantes</label>
                                    <div class="row">
                                        <div class="col-8">
                                        <h6 class="text-muted mt-3">Limita la creación de más comprobantes </h6>
                                        </div>
                                        <div class="col-4 text-right">
                                            <div class="switch">
                                                <label style="position: inherit;"><input type="checkbox" id="locked_documents"><span class="lever switch-col-light-green"></span></label>
                                                <input type="hidden" name="locked_documents" id="locked_documents_hidden">								
                                            </div>
                                        </div>
                                    </div>
                                </div>                            
                            </div>
                            <div class="col-md-12">
                                <div class="form-group m-b-40">
                                    <span class="bar"></span>
                                    <label for="cod_seg">Bloquear usuarios</label>
                                    <div class="row">
                                        <div class="col-8">
                                        <h6 class="text-muted mt-3">Limita la creación de más usuarios</h6>
                                        </div>
                                        <div class="col-4 text-right">
                                            <div class="switch">
                                                <label style="position: inherit;"><input type="checkbox" id="locked_users"><span class="lever switch-col-light-green"></span></label>
                                                <input type="hidden" name="locked_users" id="locked_users_hidden">								
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="form-group m-b-40">
                                    <span class="bar"></span>
                                    <label for="cod_seg">API Whatsapp</label>
                                    <div class="row">
                                        <div class="col-8">
                                        <h6 class="text-muted mt-3">Se realizará envio directo de whatsapp sin whatsapp web</h6>
                                        </div>
                                        <div class="col-4 text-right">
                                            <div class="switch">
                                                <label style="position: inherit;"><input type="checkbox" id="api_wsp"><span class="lever switch-col-light-green"></span></label>
                                                <input type="hidden" name="api_wsp" id="api_wsp_hidden">                              
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8 div_token_wsp" style="display: none">
                                <div class="form-group m-b-40">
                                    <span class="bar"></span>
                                    <label for="cod_seg">TOKEN</label>
                                    <input type="text" class="form-control text-center" name="wsp_token" id="wsp_token" autocomplete="off">
                                </div>
                            </div>
                            <div class="col-md-4 div_token_wsp" style="display: none">
                                <div class="form-group m-b-40">
                                    <span class="bar"></span>
                                    <label for="cod_seg">NÚMERO</label>
                                    <input type="text" class="form-control text-center" name="wsp_number" id="wsp_number" autocomplete="off">
                                </div>
                            </div>
                            <div class="col-md-12">
                            <?php if(Session::get('bloqueo_id') == '0'):   ?>
                                <button type="button" onclick="bloc_desbloc();" class="btn btn-outline-danger btn-block"><i class="fas fa-ban"></i> Bloquear por falta de pago</button>
                            <?php else : ?>
                                <button type="button" onclick="bloc_desbloc();" class="btn btn-outline-success btn-block"><i class="fas fa-check"></i> Desbloquear Plataforma</button>
                            <?php endif; ?>   
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-success btn-guardar">Aceptar</button>
            </div>
        </form>
        </div>
    </div>
</div>








<script type="text/javascript">
    $('#navbar-c').addClass("white-bg");
    $('#config').addClass("active");

    var bloc_desbloc = function(){

        var html_confirm = '<div><?php print (Session::get('bloqueo_id') == '0')? 'Se procederá a desbloquear la plataforma' : 'Se procederá a bloquear la plataforma'; ?></div><br>\
            <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
        Swal.fire({
            title: 'Necesitamos de tu Confirmación',
            html: html_confirm,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#34d16e',
            confirmButtonText: 'Si, Adelante!',
            cancelButtonText: "No!",
            showLoaderOnConfirm: true,
            preConfirm: function() {
            return new Promise(function(resolve) {
                $.ajax({
                    url: $('#url').val()+'ajuste/bloqueo',
                    type: 'POST',
                    data: {
                        // $ver = (Session::get('rol') == 1) ? '' :  header('location: ' . URL . 'err/danger'); 

                        tipo_bloqueo  : <?php print (Session::get('bloqueo_id') == '0')? '1' : '0';      ?>,
                        },
                    dataType: 'json'
                })
                .done(function(response){
                    if(response == 1){
                    Swal.fire({
                        title: 'Proceso Terminado',
                        text: 'Datos eliminados correctamente',
                        icon: 'success',
                        showConfirmButton: false,
                    });
                    location.reload();
                    }else{
                        Swal.fire({
                            title: 'Proceso No Culminado',
                            text: 'no se pueden eliminar',
                            icon: 'error',
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar"
                        });
                    }
                })
                .fail(function(){
                    Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
                });
            });
            },
            allowOutsideClick: false              
        });
    }



</script>