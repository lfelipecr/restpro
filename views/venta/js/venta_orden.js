var searchRequest = null;
var moneda = $("#moneda").val();
$(function() {
    $('#restau').addClass("active");
    $('.btn-stock-pollo').show();
    $('.search-products').show();
    defaultdata();
    listarCategorias();
    listarCategoriasMovil();
    listarProdsMasVend();
    listarPedidos();
    listarComandas();
    $('body').addClass('body-pos');
    $('.scroll_list_items_facturar').slimscroll({
        height: '100%'
    });
    var scroll_list_items_facturar = function () {
        var topOffset = 400;
        var height = ((window.innerHeight > 0) ? window.innerHeight : this.screen.height) - 1;
        height = height - topOffset;
        $(".scroll_list_items_facturar").css("height", (height) + "px");
    };
    
    $(window).ready(scroll_list_items_facturar);
    $(window).on("resize", scroll_list_items_facturar);

    var minlength = 1;
    $("#buscar_producto").keyup(function () {
        
        var prodwidth = ($('#rol_usr').val() == 5) ? 'p-w-t' : 'p-w-t'; 
        $(".catP").removeClass("active");
        $(".catS").removeClass("active"); 
        var moneda = $("#moneda").val();
        $('#list-productos').empty();

        var that = this,
        value = $(this).val();

        if (value.length >= minlength ) {

            if(event.keyCode==13){ //enter 
                // alert("hola")
                setTimeout(function(){
                    $('#pres_'+value+'').trigger('click');
                    // alert('#pres_'+value+'')
                }, 500);
            }
            
            if (searchRequest != null) 
                searchRequest.abort();
                searchRequest = $.ajax({
                type: "POST",
                url: $('#url').val()+"venta/buscar_producto",
                data: {
                    cadena : value,
                    codtipoped : $('#codtipoped').val(),
                    codrepartidor : $('#codrepartidor').val()
                },
                dataType: "JSON",
                success: function(data){
                    //we need to check if the value is the same
                    if (data.length != 0) {
                        var htmlProducto = '\
                           <table class="table table-hover table-striped tablaProdcutos" style="margin: 10px">\
                                <thead>\
                                    <tr class="table-info">\
                                      <th class="tablaProdcutosTitulo">Cod.</th>\
                                      <th class="tablaProdcutosTitulo">Producto</th>\
                                      <th class="tablaProdcutosTitulo">Presentación</th>\
                                      <th class="tablaProdcutosTitulo">Precio</th>\
                                    </tr>\
                                </thead>\
                          <tbody>';
                        if (value==$(that).val()) {
                            $.each(data, function(i, item) {
                                if (item.Stock) {
                                    var queda_stock = ((Number(item.Stock.ent) - Number(item.Stock.sal) ));
                                    stock = '<span class="stock-tag stock_producto_'+item.id_pres+'">Queda: '+queda_stock+'</span>';
                                } else {
                                    stock = '';
                                }
                    
                                sessionStorage.setItem('precios_'+item.id_pres+'', '');
                                sessionStorage.setItem('precios_'+item.id_pres+'', item.precios);

                                if ($("#mostrarimagen").val()==1) {
                                    $('#list-productos')
                                        .append(
                                        $('<article id="pres_'+item.pro_cod+'" class="product '+prodwidth+' animated fadeIn" onclick="add2('+item.id_areap+','+item.id_pres+',\''+item.pro_nom+'\',\''+item.pro_pre+'\','+item.pro_cos+',\''+item.Impresora.nombre+'\');"/>')
                                        .append(
                                            $('<div class="product-img"/>')
                                            .html('<img src="'+$("#url").val()+'public/images/productos/'+item.pro_img+'"></img><span class="price-tag">'+moneda+' '+item.pro_cos+'</span><span class="pres-tag">'+item.pro_pre+'</span>'+stock)
                                        )
                                        .append(
                                            $('<div class="product-nam"/>')
                                            .html(item.pro_nom)
                                        )
                                    );
                                }else{
                                    htmlProducto += '\
                                        <tr ondblclick="add2('+item.id_areap+','+item.id_pres+',\''+item.pro_nom+'\',\''+item.pro_pre+'\','+item.pro_cos+',\''+item.Impresora.nombre+'\');">\
                                          <th>'+item.pro_cod+'</th>\
                                          <th>'+item.pro_nom+'</th>\
                                          <th>'+item.pro_pre+'</th>\
                                          <th>'+moneda+' '+item.pro_cos+'</th>\
                                        </tr>';
                                }
                            });
                            
                            if ($("#mostrarimagen").val()!=1) {
                                htmlProducto += '</tbody>\
                                </table>';
                                $('#list-productos').html(htmlProducto)
                            }
                        }
                    } else {
                        $('#list-productos').html('<div class="text-center"><h4 class="ich m-t-none" style="color: #d3d3d3;"><br><br><br><br><br><br><br><br><br><i class="mdi mdi-star-circle display-4"></i><br>No se han encontrado resultados</h4></div>');
                    }
                }
            });
        } else {
            $(".catP").addClass("active");
            listarProdsMasVend();
            return false;
        }
    });

    $("#buscar_cliente").autocomplete({
        delay: 1,
        autoFocus: true,
        source: function (request, response) {
            $.ajax({
                url: $('#url').val()+'venta/buscar_cliente',
                type: "post",
                dataType: "json",
                data: {
                    cadena: request.term,
                    tipo_cliente: $('#cliente_tipo').val()
                },
                success: function (data) {
                    response($.map(data, function (item) {
                        tipo_cli = (item.tipo_cliente == 1) ? $("#diAcr").val() : $("#tribAcr").val();
                        return {
                            id: item.id_cliente,
                            dni: item.dni,
                            ruc: item.ruc,
                            tipo: item.tipo_cliente,
                            nombres: item.nombre,
                            fecha_n: item.fecha_nac,
                            label: tipo_cli+': '+item.dni+''+item.ruc+' | '+item.nombre,
                            value: tipo_cli+': '+item.dni+''+item.ruc+' | '+item.nombre
                        }
                    }))
                }
            })
        },
        select: function (e, ui) {
            $("#cliente_id").val(ui.item.id);
            $(this).blur();
            $("#btn-submit-facturar").removeAttr('disabled');
            $("#btn-submit-facturar").removeClass('disabled');
            $('.opcion-cliente').html('<a class="input-group-prepend" href="javascript:void(0)"'
                +'onclick="editar_cliente('+ui.item.id+');" data-original-title="Editar cliente" data-toggle="tooltip"'
                +'data-placement="top">'
                    +'<span class="input-group-text bg-header">'
                        +'<small><i class="fas fa-user text-info"></i></small>'
                   +'</span>'
                +'</a>');
        }
    });
    $("#buscar_cliente").autocomplete("option", "appendTo", ".form-facturar");

    $('#form-facturar').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {
        }
    })
    .on('success.form.fv', function(e) {
        // Prevent form submission
        e.preventDefault();
        var $form = $(e.target);
        var fv = $form.data('formValidation');
        var current_invoices = parseInt($("#current_invoices").val());
        var limits_invoices  = parseInt($("#limits_invoices").val());

        if ($("#cliente_id").val() == ''){
            Swal.fire({   
                title:'Advertencia',   
                text: 'Ingrese un cliente para el comprobante de pago',
                icon: "warning", 
                confirmButtonColor: "#34d16e",   
                confirmButtonText: "Aceptar",
                allowOutsideClick: false,
                showCancelButton: false,
                showConfirmButton: true
            }, function() {
                return false
            });

        }else if ($('#descuento_tipo_hidden').val() != '1' && ($('#tipo_pago').val() == '1' && Number($('.totalPedido').val()) > Number($('#pago_efe').val()))    ){
                Swal.fire({   
                    title:'Advertencia',   
                    text: 'Ingrese un monto mayor o igual al total',
                    icon: "warning", 
                    confirmButtonColor: "#34d16e",   
                    confirmButtonText: "Aceptar",
                    allowOutsideClick: false,
                    showCancelButton: false,
                    showConfirmButton: true
                }, function() {
                    return false
                });

        }else{

            // if ( (current_invoices >= limits_invoices)  && $("input[name=tipo_doc]:checked").val() !== '3'  && $("#locked_invoices").val() == '1'   ){ 
            if ( (current_invoices >= limits_invoices)  &&  $("#locked_invoices").val() == '1'   ){ 
                // console.log(current_invoices+" >= "+limits_invoices);
                Swal.fire({   
                    title:'Alcanzó el límite',   
                    text: 'Alcanzó el límite permitido para la emisión de comprobantes',
                    icon: "error", 
                    confirmButtonColor: "#34d16e",   
                    confirmButtonText: "Aceptar",
                    allowOutsideClick: false,
                    showCancelButton: false,
                    showConfirmButton: true
                }, function() {
                    return false
                });

            }else {

                if ((current_invoices >= limits_invoices) && $("input[name=tipo_doc]:checked").val() !== '3'){

                    $.toast({
                        text: 'Alcanzó el límite permitido para la emisión de comprobantes',
                        position: 'top-right',
                        loaderBg:'#696969',
                        icon: 'error',
                        hideAfter: 3000, 
                        stack: 20,
                        allowToastClose: false,
                    });

                }
                var form = $(this);
                var venta = {
                    tipo_pedido: 0,
                    tipo_entrega: 0,
                    dividir_cuenta: 0,
                    id_pedido: 0,
                    cliente_id: 0,  
                    tipo_doc: 0,
                    tipo_pago: 0,
                    pago_efe: 0,
                    pago_tar: 0,
                    pago_yape: 0,
                    pago_plin: 0,
                    pago_tran: 0,
                    ibcper: 0,
                    descuento_tipo: 0,
                    descuento_personal: 0,
                    descuento_monto: 0,
                    descuento_motivo: 0,
                    comision_tarjeta: 0,
                    comision_delivery: 0,
                    codigo_operacion: 0,
                    venta_por_consumo: 0,
                    venta_por_consumo_concepto: 0,
                    observacion: 0,
                    total: 0,
                    idProd: [],
                    cantProd: [],
                    precProd: []
                }

                var tipo_descuento = ($('#descuento_tipo_hidden').val() == '') ? '2' : $('#descuento_tipo_hidden').val();

                venta.tipo_pedido = $('#codtipoped').val();
                venta.tipo_entrega = $('#codtipopedentrega').val();
                venta.dividir_cuenta = $('#dividir_cuenta').val();
                venta.id_pedido = $('#id_pedido').val();
                venta.cliente_id = $('#cliente_id').val();
                venta.tipo_doc = $('input:radio[name="tipo_doc"]:checked').val();
                venta.tipo_pago = $('#tipo_pago').val();
                venta.pago_efe = $('#pago_efe').val().replace(/,/g, "");
                venta.pago_tar = $('#pago_tar').val();
                venta.pago_yape = $('#pago_yape').val();
                venta.pago_plin = $('#pago_plin').val();
                venta.pago_tran = $('#pago_tran').val();
                venta.icbper = parseFloat($("#monto_icbper").val());
                venta.descuento_tipo = tipo_descuento;
                venta.descuento_personal = $('#descuento_personal_hidden').val();
                venta.descuento_monto = $('#descuento_monto_hidden').val();
                venta.descuento_motivo = $('#descuento_motivo_hidden').val();
                venta.comision_tarjeta = $('#comision_tarjeta').val();
                venta.comision_delivery = $('#comision_delivery').val();
                venta.codigo_operacion = $('#codigo_operacion').val();
                venta.venta_por_consumo = $("input[name='venta_por_consumo']").val();
                venta.venta_por_consumo_concepto = $('#venta_por_consumo_concepto').val();
                venta.observacion = $('#observacion').val();
                venta.total = $('#total_venta').val();
                venta.idProd = $("input[name='idProd[]']").map(function(){return $(this).val();}).get();
                venta.cantProd = $("input[name='cantProd[]']").map(function(){return $(this).val();}).get();
                venta.precProd = $("input[name='precProd[]']").map(function(){return $(this).val();}).get();

                var cod_ped = $('#id_pedido').val();
            
                var cod_ven = 0;

                let total=0,
                numeros = venta.cantProd;
                numeros.forEach(function(a){total += parseInt(a);});

                if (total==0) {
                    swal.close();
                        Swal.fire({   
                            title:'Advertencia',   
                            html: 'Seleccione un producto,<br>para poder cobrar',
                            icon: "warning", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    total=0
                    return false
                }
                value = $('input:radio[name="tipo_doc"]:checked').val();
                if (value == undefined || value == "undefined") {
                    Swal.fire({
                        title: 'Seleccione tipo de documento',
                        icon: 'error',
                        showCancelButton: false,
                        showConfirmButton: true,
                    });
                    return false;
                }

                html_confirm = '<div>Se creará el documento electrónico<br> con los siguientes datos</div>';

                Swal.fire({
                    title: 'Necesitamos de tu Confirmación',
                    html: html_confirm,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#34d16e',
                    cancelButtonText: "No!",
                    confirmButtonText: 'Si, Adelante!',
                    showLoaderOnConfirm: true
                }).then((result) => {
                    if (result.value) {

                        html_confirm = '<h4 class="m-t-20 font-bold">Registrando venta</h4></div>'
                            +'<div class="p-0">Espere un momento por favor...</div>';

                        Swal.fire({    
                            html: html_confirm,
                            timer: 100000,
                            allowOutsideClick: false,
                            allowEscapeKey : false,
                            showCancelButton: false,
                            showConfirmButton: false,
                            closeOnConfirm: false,
                            closeOnCancel: false,
                            onBeforeOpen: () => {
                                Swal.showLoading ()
                            }
                        });
						
						

                        $('.swal2-actions').addClass('p-b-20');

                        $.ajax({
                            type: 'POST',
                            url: $('#url').val()+'venta/RegistrarVenta',
                            data: venta,
                            success: function (dato) {
                                if(dato == '"error"'){
                                    var html_footer = $("#url").val()+'venta/orden/'+cod_ped;
                                    Swal.fire({   
                                        title:'Error',   
                                        text: 'Falta agregar productos',
                                        icon: "error", 
                                        footer: '<div><a class="btn btn-orange" href="'+html_footer+'" target="_self">Aceptar <i class="fas fa-arrow-right"></i></a></div>',
                                        allowOutsideClick: false,
                                        showCancelButton: false,
                                        showConfirmButton: false,
                                        closeOnConfirm: false,
                                        closeOnCancel: false
                                    }, function() {
                                        return false
                                    });                                  

                                }else{ 
                                    cod_ven = dato.replace(/['"]+/g, '');
                                    var urlticketreparto = $("#url").val()+'venta/impresion_reparto/'+cod_ven;
                                    // si es que esta activo el ver pdf
                                    if ($('#verpdf').val()==1) {
                                        var Urlpdfiframe = '<div class="col-6 col-md-6 hidden-md-down"><iframe src="'+$("#url").val()+'informe/venta_all_imp/'+cod_ven+'#toolbar=0" style="border:none;width: 100%;height: 100%;" /></div>';
                                        var withmodal = 800;
                                        var cantcolumn = 6;
                                    }else{var Urlpdfiframe = ''; var withmodal = 400;var cantcolumn = 12;}

                                    // var Urlpdfiframe = $("#url").val()+'informe/venta_all_imp/'+cod_ven; 
                                    if(1 == $('#dividir_cuenta').val()){
                                        var html_footer = $("#url").val()+'venta';
                                        //return true;
                                    } else if (2 == $('#dividir_cuenta').val()){
                                        var html_footer = $("#url").val()+'venta/orden/'+cod_ped;
                                        //return true; 
                                    }

                                    if($('#print_cpe').val() == 1){
                                        // imprimir directo  
                                        var linkpdf     = '<a href="'+$("#url").val()+'informe/venta_all_imp_/'+cod_ven+'" target="_blank" class="link"><i class="mdi mdi-receipt text-muted"></i></a>';
                                        var linkpdff    = '<a class="link" href="'+$("#url").val()+'informe/venta_all_imp_/'+cod_ven+'" target="_blank"><small>Imprimir comprobante</small></a>';
                                        var linkrep     = '<a class="link" href="'+$("#url").val()+'venta/impresion_reparto/'+cod_ven+'" target="_blank"><i class="fas fa-print text-muted"></i></a>';
                                        var linkrepp    = '<a class="link" href="'+$("#url").val()+'venta/impresion_reparto/'+cod_ven+'" target="_blank"><small>Ticket reparto</small></a>';
                                        // Agregar el botón "GAVETA" al lado del botón "Imprimir Comprobante"
                                        var linkgaveta = '<a class="link" href="' + $("#url").val() + 'imprimir/gaveta.php" target="_blank"><i class="fas fa-print text-muted"></i></a>';
                                        var linkgavetap = '<a class="link" href="' + $("#url").val() + 'imprimir/gaveta.php" target="_blank"><small>GAVETA</small></a>';                                        
                                    }else{
                                        // vista previa
                                        var linkrep     = '<a class="link" onclick="printPdf(\''+urlticketreparto+'\',true);" href="javascript:void(0)"><i class="fas fa-print text-muted"></i></a>';
                                        var linkrepp    = '<a class="link" onclick="printPdf(\''+urlticketreparto+'\',true);" href="javascript:void(0)"><small>Ticket reparto</small></a>';
                                        var linkpdf     = '<a href="javascript:void(0)" onclick="printPdf('+cod_ven+');" class="link"><i class="mdi mdi-receipt text-muted"></i></a>';
                                        var linkpdff    = '<a class="link" href="javascript:void(0)" onclick="printPdf('+cod_ven+');"><small>Imprimir comprobante</small></a>';
                                        // Agregar el botón "GAVETA" al lado del botón "Imprimir Comprobante"
                                        var linkgaveta = '<a class="link" href="' + $("#url").val() + 'imprimir/gaveta.php" target="_blank"><i class="fas fa-print text-muted"></i></a>';
                                        var linkgavetap = '<a class="link" href="' + $("#url").val() + 'imprimir/gaveta.php" target="_blank"><small>GAVETA</small></a>';
                                    }

                                    if($('#codtipoped').val() == 3){
                                        html_confirm =  '<div class="row"> <div class="col-'+cantcolumn+' col-md-'+cantcolumn+'">'
                                        +'<div class="text-center p-20"><i class="fas fa-check-circle display-3 text-success"></i>'
                                        +'<h4 class="m-t-20 font-bold">¡Venta completada!</h4></div>'
                                        +'<div class="card-body text-center">'
                                            +'<div class="row">'
                                                +'<div class="col-6 text-center">'
                                                    +'<h1 class="font-light m-b-0">'+linkpdf+'</h1>'
                                                    +''+linkpdff+''
                                                +'</div>'
                                                +'<div class="col-6 text-center">'
                                                    +'<h1 class="font-light m-b-0">'+linkgaveta+'</h1>'
                                                    +''+linkgavetap+''
                                                +'</div>' 
                                                +'<div class="col-6 text-center">'
                                                    +'<h1 class="font-light m-b-0">'+linkrep+'</h1>'
                                                    +''+linkrepp+''
                                                +'</div>'
                                            +'</div>'
                                            +'<div class="row mt-5">'
                                                +'<div class="col-12 text-center">'
                                                    +'<span class="mb-2 text-center" style="display: block;">Enviar comprobante por WhatsApp</span>'
                                                    +'<div class="input-group">'
                                                        +'<div class="input-group-prepend">'
                                                            +'<span class="input-group-text">Nº</span>'
                                                        +'</div>'
                                                        +'<input type="text" id="numero_cliente" value="51" class="form-control" placeholder="51999999999" aria-label="51999999999" aria-describedby="button-addon2">'
                                                        +'<div class="input-group-append">'
                                                            +'<button class="btn btn-success" type="button" id="button-addon2" onclick="clickSendWhatsapp('+cod_ven+');">enviar <i class="fab fa-whatsapp"></i></button>'
                                                        +'</div>'
                                                    +'</div>'
                                                    // +'<div class="input-group mt-1">'
                                                    //     +'<div class="input-group-prepend">' 
                                                    //         +'<span class="input-group-text">@</span>'
                                                    //     +'</div>'
                                                    //     +'<input type="text" id="correo_cliente" value="" class="form-control" placeholder="cliente@dominio.com" aria-label="cliente@dominio.com" aria-describedby="button-addon2">'
                                                    //     +'<div class="input-group-append">'
                                                    //         +'<button class="btn btn-success" type="button" id="button-SendEmail" onclick="clickSendEmail('+ cod_ven+',\''+$("#entorno").val()+'/\');">enviar <i class="fa fa-envelope"></i></button>'
                                                    //     +'</div>'
                                                    // +'</div>'
                                                    //     +'<code style="display:inline-block" id="msj-SendEmail">Enviando email, espere por favor</code>'
                                                +'</div>'
                                            +'</div>'
                                        +'</div>'
                                        +'</div>'
                                        +''+Urlpdfiframe+''
                                        // +'<iframe src="'+Urlpdfiframe+'#toolbar=0" style="border:none;width: 100%;height: 100%;" />' //
                                        +'</div>';

                                    } else {
                                        html_confirm = '<div class="row"> <div class="col-'+cantcolumn+' col-md-'+cantcolumn+'">'
                                        +'<div class="text-center p-20"><i class="fas fa-check-circle display-3 text-success"></i>'
                                        +'<h4 class="m-t-20 font-bold">¡Venta completada!</h4></div>'
                                        +'<div class="card-body text-center">'
                                            +'<div class="row">'
                                                +'<div class="col-12 text-center">' 
                                                    +'<h1 class="font-light m-b-0">'+linkpdf+'</h1>'
                                                    +''+linkpdff+''
                                                +'</div>'
                                                +'<div class="col-12 text-center">'
                                                    +'<h1 class="font-light m-b-0">'+linkgaveta+'</h1>'
                                                    +''+linkgavetap+''
                                                +'</div>'
                                            +'</div>'
                                            +'<div class="row mt-5">'
                                                +'<div class="col-12 text-center">'
                                                    +'<span class="mb-2 text-center" style="display: block;">Enviar comprobante por WhatsApp</span>'
                                                    +'<div class="input-group">'
                                                        +'<div class="input-group-prepend">'
                                                            +'<span class="input-group-text">Nº</span>'
                                                        +'</div>'
                                                        +'<input type="text" id="numero_cliente" value="51" class="form-control" placeholder="51999999999" aria-label="51999999999" aria-describedby="button-addon2">'
                                                        +'<div class="input-group-append">'
                                                            +'<button class="btn btn-success" type="button" id="button-addon2" onclick="clickSendWhatsapp('+cod_ven+');">enviar <i class="fab fa-whatsapp"></i></button>'
                                                        +'</div>'
                                                    +'</div>'
                                                    // +'<div class="input-group mt-1">'
                                                    //     +'<div class="input-group-prepend">'
                                                    //         +'<span class="input-group-text">@</span>'
                                                    //     +'</div>'
                                                    //     +'<input type="text" id="correo_cliente" value="" class="form-control" placeholder="cliente@dominio.com" aria-label="cliente@dominio.com" aria-describedby="button-addon2">'
                                                    //     +'<div class="input-group-append">'
                                                    //         +'<button class="btn btn-success" type="button" id="button-SendEmail" onclick="clickSendEmail('+ cod_ven+',\''+$("#entorno").val()+'/\');">enviar <i class="fa fa-envelope"></i></button>'
                                                    //     +'</div>'
                                                    // +'</div>'
                                                    //     +'<code style="display:none" id="msj-SendEmail">Enviando email, espere por favor</code>'
                                                +'</div>'
                                            +'</div>'
                                        +'</div>'
                                        +'</div>'
                                        +''+Urlpdfiframe+''
                                        // +'<iframe src="'+Urlpdfiframe+'#toolbar=0" style="border:none;width: 100%;height: 100%;" />' //
                                        +'</div>';

                                    }
                                    Swal.fire({
                                        html: html_confirm,
                                        width: withmodal,
                                        footer: '<div><a class="btn btn-orange" href="'+html_footer+'" target="_self">Continuar <i class="fas fa-arrow-right"></i></a></div>',
                                        allowOutsideClick: false,
                                        allowEscapeKey : false,
                                        showCancelButton: false,
                                        showConfirmButton: false,
                                        closeOnConfirm: false,
                                        closeOnCancel: false,
                                        backdrop: '#34d16e'
                                    });
                                    $('.swal2-modal').addClass('card-shadow');

                                    if($('#codtipoped').val() == 2){
                                        // impresion_ticket($('#id_pedido').val());
                                    }  
                                
                                }
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                console.log(errorThrown + ' ' + textStatus);
                            }   
                        });
                        
                    } else if (result.dismiss === Swal.DismissReason.cancel) {
                        //$("#modal-facturar").modal('show');
                    }

                });
            }


        }
    });
    $('#modal-facturar').on('shown.bs.modal', function() {
        $(document).off('focusin.modal');
    });
});
 
var defaultdata = function(){
    $.ajax({
        async: false,
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'venta/defaultdata',
        data: {
            id_pedido: $('#codped').val(),
            tipo_pedido: $('#codtipoped').val()
        },
        success: function (data) {
            var sbtot = 0;
            var total = 0;

          var imp_bol = $("#imp_icbper").val();
          $.each(data.Detalle, function (i, item) {
            var precio_imp_bol = 0;

            if (item.impuesto_icbper == "1") {
              precio_imp_bol = parseFloat(item.precio) + parseFloat(imp_bol);
            } else {
              precio_imp_bol = item.precio;
            }

            var importe = parseFloat(item.cantidad * precio_imp_bol) ;
            if (item.estado != "i" && item.cantidad > 0) {
              sbtot = parseFloat(importe) + parseFloat(sbtot);
            }
          });

            total = parseFloat(sbtot) + parseFloat(total);

            $('#totalPagar').text(moneda+' '+formatNumber(total));
            $('.totalPagar').text(moneda+' '+formatNumber(total));
            $('#total_pedido').val(total.toFixed(2));
            $('#pago_efe').val(formatNumber(total));
            $('.opc-01').text(formatNumber(total));
            $('.totalPedidoMenosTarjeta').text(formatNumber(total));

            $('.opcion-cliente').html('<a class="input-group-prepend" href="javascript:void(0)"'
                +'onclick="nuevoCliente();" data-original-title="Registrar nuevo cliente" data-toggle="tooltip"'
                +'data-placement="top">'
                    +'<span class="input-group-text bg-header">'
                        +'<small><i class="fas fa-user-plus"></i></small>'
                   +'</span>'
                +'</a>');

            if(total != '0.00'){
                if(data.id_tipo_pedido == 3){
                    // if(data.estado_pedido != 'a'){                            
                    //     $('#list-productos').css('visibility','hidden');
                    //     $('.opc1').css('display','block');
                    //     $('.opc2').css('display','none');   
                    // } else {
                        $('.opc1').css('display','none');
                        $('.opc2').css('display','none'); 
                        $('.opc3').css('display','block');
                        if($('#rol_usr').val() == 5){
                           $('.opc1').css('display','block'); 
                        }
                    // }
                } else {
                    $('.opc1').css('display','block');
                    $('.opc2').css('display','none'); 
                }
            }else{
                $('.opc1').css('display','none');
                $('.opc2').css('display','block');
            };
            
            if(data.id_tipo_pedido == 1){
                $('.pedido-numero-icono').text('');
                $('.pedido-cliente-icono').removeClass('far fa-user');
                $('.pedido-numero').text(data.desc_salon);
                $('#nombre_salon').val(data.desc_salon);
                $('#nombre_mozo').val(data.nombre_mozo);
                $('.pedido-cliente').text('MESA: '+data.nro_mesa);
                // if($("#print_pre").val() == 1){ // impresion por comanda
                //     $('.btn-imp').html('<a href="'+$("#url").val()+'venta" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Monitor de mesas"><i class="fas fa-desktop"></i></a> <button onclick="impPreCuenta('+data.id_pedido+','+data.id_mesa+',\''+data.estado_mesa+'\')" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Imprimir pre cuenta"><i class="fas fa-print"></i></button>'); 
                // }else{ // impresion por view print 
                //     $('.btn-imp').html('<a href="'+$("#url").val()+'venta" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Monitor de mesas"><i class="fas fa-desktop"></i></a> <button  onclick="impPreCuenta('+data.id_pedido+','+data.id_mesa+',\''+data.estado_mesa+'\',true)" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Imprimir pre cuenta"><i class="fas fa-print"></i></button>');                    
                // }
                if($("#print_pre").val() == 1){ // impresion por comanda
                    $('.btn-imp').html('<a href="'+$("#url").val()+'venta" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Monitor de mesas"><i class="fas fa-desktop"></i></a> <button onclick="impPreCuenta('+data.id_pedido+','+data.id_mesa+',\''+data.estado_mesa+'\')" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Imprimir pre cuenta"><i class="fas fa-print"></i></button> <div class="btn-group" data-toggle="tooltip" title="Imprimir Comanda"><button type="button" class="btn btn-warning dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="fas fa-print"></i></button><div class="dropdown-menu" id="list-comandas"></div></div>'); 
                }else{ // impresion por view print 
                    $('.btn-imp').html('<a href="'+$("#url").val()+'venta" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Monitor de mesas"><i class="fas fa-desktop"></i></a> <button  onclick="impPreCuenta('+data.id_pedido+','+data.id_mesa+',\''+data.estado_mesa+'\',true)" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Imprimir pre cuenta"><i class="fas fa-print"></i></button> <div class="btn-group" data-toggle="tooltip" title="Imprimir Comanda"><button type="button" class="btn btn-warning dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="fas fa-print"></i></button><div class="dropdown-menu" id="list-comandas"></div></div>');                    
                }
                $('#cliente_id').val(1);
                $('#buscar_cliente').val('DNI: 00000000 | PUBLICO EN GENERAL');
            }else if(data.id_tipo_pedido == 2 || data.id_tipo_pedido == 3){
                $('.pedido-numero-icono').text('Pedido: ');
                $('.pedido-cliente-icono').addClass('far fa-user');
                $('.pedido-numero').text(data.nro_pedido);
                $('#btn-confirmar').text('AÑADIR');
                if(data.id_tipo_pedido == 2){
                    $('.pedido-cliente').text(data.nombre_cliente);
                    $('.btn-imp').html('<a href="'+$("#url").val()+'venta?tip=2&cod='+$('#codped').val()+'&est='+data.estado_pedido+'" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Monitor de ventas"><i class="fas fa-desktop"></i></a>');
                    $('#cliente_id').val(1);
                    $('#buscar_cliente').val('DNI: 00000000 | PUBLICO EN GENERAL');
                }else if(data.id_tipo_pedido == 3){
                    //$('.mensaje-pago-2-text').html('PAGA CON: S/'+data.paga_con+'<br>COMISION DELIVERY: S/'+data.comision_delivery);
                    console.log(data.paga_con)
                    $('.comision_delivery').val(data.comision_delivery);
                    $('.comision_delivery').text(formatNumber(data.comision_delivery));
                    $('#pago_efe').val(formatNumber(data.paga_con));
                    $(".opc-01").text(formatNumber(parseFloat(total) + parseFloat(data.comision_delivery)));
                    var tipo_entrega = (data.tipo_entrega == 1) ? 'c' : 'd';
                    $('#codtipopedentrega').val(tipo_entrega);
                    if(data.estado_pedido == 'a'){
                        $('.btn-imp').html('<a href="'+$("#url").val()+'venta?tip=3&cod='+$('#codped').val()+'&est='+data.estado_pedido+'" class="btn btn-orange" data-toggle="tooltip" data-placement="top" data-original-title="Continuar">Continuar <i class="fas fa-arrow-right"></i></a>');                    
                    } else if(data.estado_pedido == 'b'){
                        $('.btn-imp').html('<a href="'+$("#url").val()+'venta?tip=3&cod='+$('#codped').val()+'&est='+data.estado_pedido+'" class="btn btn-inverse" data-toggle="tooltip" data-placement="top" data-original-title="Monitor de ventas"><i class="fas fa-desktop"></i></a>');
                    } else{
                        $('#list-productos').css('visibility','hidden');  
                    }
                    //$('.pedido-cliente').text(data.desc_repartidor);
                    $('.pedido-cliente').text(data.nombre_cliente.substr(0,13));
                    $('#cliente_id').val(data.id_cliente);
                    $('#cliente_tipo').val(data.tipo_cliente);
                    $('#tipo_cliente').val(data.tipo_cliente);
                    var tipo = (data.tipo_cliente == 1) ? $('#diAcr').val() : $('#tribAcr').val();
                    $('#buscar_cliente').val(tipo+': '+data.dni_cliente+''+data.ruc_cliente+' | '+data.nombre_cliente);
                    //$('#buscar_cliente').val('PUBLICO EN GENERAL');
                    $('.opcion-cliente').html('<a class="input-group-prepend" href="javascript:void(0)"'
                    +'onclick="editar_cliente('+data.id_cliente+');" data-original-title="Editar cliente" data-toggle="tooltip"'
                    +'data-placement="top">'
                        +'<span class="input-group-text bg-header">'
                            +'<small><i class="fas fa-user text-info"></i></small>'
                       +'</span>'
                    +'</a>');
                }
            }
            
            if (data.tipo_cliente == 2){
                $('.btn-tipo-doc-2').addClass('active');
                $("input[name=tipo_doc][value='2']").attr("checked",true);
            } else if(tdoc_defecto){
                $('.btn-tipo-doc-'+tdoc_defecto).addClass('active');
                $("input[name=tipo_doc][value='"+tdoc_defecto+"']").attr("checked",true);
            } else {
                $('.btn-tipo-doc-1').addClass('active');
                $("input[name=tipo_doc][value='1']").attr("checked",true);

                if($("input[name=tipo_doc][value='1']").length == false){
                    $('.btn-tipo-doc-3').addClass('active');
                    $("input[name=tipo_doc][value='3']").attr("checked",true);
                }
            }

            // $('.btn-tipo-doc-3').addClass('disabled');
            // $("input[name=tipo_doc][value='2']").attr("disabled",false);

            if (data.tipo_pago == 1){
                $('#tipo_pago').selectpicker('val', data.tipo_pago);
                $('.mensaje-pago').hide();
                $('.display-pago-efectivo').show();
                $('.display-pago-tarjeta').hide();
                $('.display-pago-default').show();
                $('.display-pago-rapido-efectivo').show();
                $('.display-codigo-operacion').hide();
            } else if (data.tipo_pago != 3 && (data.tipo_pago == 2 || data.tipo_pago >= 4)) {
                $('#tipo_pago').selectpicker('val', data.tipo_pago);
                $('.mensaje-pago').hide();
                $('.display-pago-efectivo').hide();
                $('.display-pago-tarjeta').hide();
                $('.display-pago-default').hide();
                $('.display-pago-rapido-efectivo').hide();
                $('.display-descuento').show();
                $('.display-codigo-operacion').show();
            } else {
                $('#tipo_pago').selectpicker('val', 1);
                $('.mensaje-pago').hide();
                $('.display-pago-efectivo').show();
                $('.display-pago-tarjeta').hide();
                $('.display-pago-default').show();
                $('.display-pago-rapido-efectivo').show();
                $('.display-codigo-operacion').hide();
            }

            if(data.amortizacion > 0){
                $('.mensaje-amortizacion').show();
                $('.mensaje-amortizacion-text').html('Existe una amortizaci&oacute;n de pago con un monto de '+moneda+' '+formatNumber(data.amortizacion));
            } else {
                $('.mensaje-amortizacion').hide();
            }

            /*
            if(data.id_repartidor == 1){
                if (data.tipo_pago == 4) { 
                    $('.display-comision-delivery').hide(); 
                } else {
                    $('.display-comision-delivery').show();
                }
            } else {
                $('.display-comision-delivery').hide();
            }
            */
            if (data.tipo_pago == 4) { 
                $('.display-comision-delivery').hide(); 
            } else {
                $('.display-comision-delivery').show();
            }
            $('#codtipoped').val(data.id_tipo_pedido);
            $('.display-comision-tarjeta').hide();

            if(data.id_repartidor == 2222 || data.id_repartidor == 3333 || data.id_repartidor == 4444){
                $('#codrepartidor').val(2);
            } else {
                $('#codrepartidor').val(1);
            }
        }
    });
};

var listarCategorias = function(){
    $('#list-catgrs').empty();
    $('#list-catgrs').html('<li class="nav-item list-salones m-t-10"><a class="nav-link active" data-toggle="list" href="javascript:void(0)"href="javascript:void(0)" onclick="listarProdsMasVend();"><b>FAVORITOS</b></a></li>');
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        data: {
            codtipoped : $('#codtipoped').val()
        },
        url: $('#url').val()+'venta/listarCategorias',
        success: function (data) {
            $.each(data, function(i, item) {
                $('#list-catgrs')
                    // .append(
                    //     $('<a class="catS b-0 list-group-item list-group-item-action" data-toggle="list" href="javascript:void(0)" onclick="listarProductos('+item.id_catg+');"/>')
                    //     .html(item.descripcion) 
                    .append($('<li class="nav-item list-salones m-t-10">').append($('<a class="nav-link" data-toggle="list" href="javascript:void(0)" onclick="listarProductos('+item.id_catg+');"/ >').html(item.descripcion))   );
            });
        }
    });
}
var listarCategoriasMovil = function(){
    $('#list-catgrs-movil').empty();
    $('#list-catgrs-movil').html('<a class="catP b-0 list-group-item list-group-item-action active" style="border-radius: 0px;" data-toggle="list" href="javascript:void(0)" onclick="listarProdsMasVend(1);"><b>FAVORITOS</b></a>');
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        data: {
            codtipoped : $('#codtipoped').val()
        },
        url: $('#url').val()+'venta/listarCategorias',
        success: function (data) {
            $.each(data, function(i, item) {
                $('#list-catgrs-movil')
                    .append(
                        $('<a class="catS b-0 list-group-item list-group-item-action" data-toggle="list" href="javascript:void(0)" onclick="listarProductos('+item.id_catg+',1);"/>')
                        .html(item.descripcion)
                    
                );
            });
        }
    });
}

var listarProductos = function(id_catg,side = false){
    if(side){
        $(".right-sidebar").slideDown(50), $(".right-sidebar").toggleClass("shw-rside")
    }

    $('#buscar_producto').val('');
    $('#list-productos').empty();
    var prodwidth = ($('#rol_usr').val() == 5) ? 'p-w-t' : 'p-w-t'; 
    $.ajax({
        url: $('#url').val()+'venta/listarProductos',
        dataType: 'JSON',
        type: 'POST',
        data: {
            id_catg: id_catg,
            codtipoped: $('#codtipoped').val(),
            codrepartidor : $('#codrepartidor').val()
        },
        success: function (data) {
            if (data.length != 0) {
                var htmlProducto = '\
                   <table class="table table-hover table-striped tablaProdcutos" style="margin: 10px">\
                        <thead>\
                            <tr class="table-info">\
                              <th class="tablaProdcutosTitulo">Cod.</th>\
                              <th class="tablaProdcutosTitulo">Producto</th>\
                              <th class="tablaProdcutosTitulo">Presentación</th>\
                              <th class="tablaProdcutosTitulo">Precio</th>\
                            </tr>\
                        </thead>\
                  <tbody>';
                $.each(data, function(i, item) {
                    if (item.Stock) {
                        var queda_stock = ((Number(item.Stock.ent) - Number(item.Stock.sal) ));
                        stock = '<span class="stock-tag stock_producto_'+item.id_pres+'">Queda: '+queda_stock+'</span>';
                    } else {
                        stock = '';
                    }

                    sessionStorage.setItem('precios_'+item.id_pres+'', '');
                    sessionStorage.setItem('precios_'+item.id_pres+'', item.precios);

                    if ($("#mostrarimagen").val()==1) {
                        $('#list-productos')
                            .append(
                            $('<article id="pres_'+item.pro_cod+'" class="product '+prodwidth+' animated fadeIn" onclick="add2('+item.id_areap+','+item.id_pres+',\''+item.pro_nom+'\',\''+item.pro_pre+'\','+item.pro_cos+',\''+item.Impresora.nombre+'\');"/>')
                            .append(
                                $('<div class="product-img"/>')
                                .html('<img src="'+$("#url").val()+'public/images/productos/'+item.pro_img+'"></img><span class="price-tag">'+moneda+' '+item.pro_cos+'</span><span class="pres-tag">'+item.pro_pre+'</span>'+stock)
                            )
                            .append(
                                $('<div class="product-nam"/>')
                                .html(item.pro_nom)
                            )
                        );
                    }else{
                        htmlProducto += '\
                            <tr ondblclick="add2('+item.id_areap+','+item.id_pres+',\''+item.pro_nom+'\',\''+item.pro_pre+'\','+item.pro_cos+',\''+item.Impresora.nombre+'\');">\
                              <th>'+item.pro_cod+'</th>\
                              <th>'+item.pro_nom+'</th>\
                              <th>'+item.pro_pre+'</th>\
                              <th>'+moneda+' '+item.pro_cos+'</th>\
                            </tr>';
                    }
                });

                    if ($("#mostrarimagen").val()!=1) {
                        htmlProducto += '</tbody>\
                        </table>';
                        $('#list-productos').html(htmlProducto)
                    }
            } else {
                $('#list-productos').html('<div class="text-center"><h4 class="ich m-t-none" style="color: #d3d3d3;"><br><br><br><br><br><br><br><br><br><i class="mdi mdi-star-circle display-4"></i><br>No se han encontrado resultados</h4></div>');
            }
        }
    });
};

var listarProdsMasVend = function(side = false){
    if(side){
        $(".right-sidebar").slideDown(50), $(".right-sidebar").toggleClass("shw-rside")
    }
    $('#buscar_producto').val('');
    $('#list-productos').empty();
    var prodwidth = ($('#rol_usr').val() == 5) ? 'p-w-t' : 'p-w-t'; 
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        data: {
            codtipoped : $('#codtipoped').val(),
            codrepartidor : $('#codrepartidor').val()
        },
        url: $('#url').val()+'venta/listarProdsMasVend',
        success: function (data) {
            if (data.length != 0) {
                var htmlProducto = '\
                   <table class="table table-hover table-striped tablaProdcutos" style="margin: 10px">\
                        <thead>\
                            <tr class="table-info">\
                              <th class="tablaProdcutosTitulo">Cod.</th>\
                              <th class="tablaProdcutosTitulo">Producto</th>\
                              <th class="tablaProdcutosTitulo">Presentación</th>\
                              <th class="tablaProdcutosTitulo">Precio</th>\
                            </tr>\
                        </thead>\
                  <tbody>';
                $.each(data, function(i, item) {
                    if (item.Stock) {
                        var queda_stock = ((Number(item.Stock.ent) - Number(item.Stock.sal) ));
                        stock = '<span class="stock-tag stock_producto_'+item.id_pres+'">Queda: '+queda_stock+'</span>';
                    } else {
                        stock = '';
                    }

                    sessionStorage.setItem('precios_'+item.id_pres+'', '');
                    sessionStorage.setItem('precios_'+item.id_pres+'', item.precios);

                    if ($("#mostrarimagen").val()==1) {
                        $('#list-productos')
                            .append(
                            $('<article id="pres_'+item.pro_cod+'" class="product '+prodwidth+' animated fadeIn" onclick="add2('+item.id_areap+','+item.id_pres+',\''+item.pro_nom+'\',\''+item.pro_pre+'\','+item.pro_cos+',\''+item.Impresora.nombre+'\');"/>')
                            .append(
                                $('<div class="product-img"/>')
                                .html('<img src="'+$("#url").val()+'public/images/productos/'+item.pro_img+'"></img><span class="price-tag">'+moneda+' '+item.pro_cos+'</span><span class="pres-tag">'+item.pro_pre+'</span>'+stock)
                            )
                            .append(
                                $('<div class="product-nam"/>')
                                .html(item.pro_nom)
                            )
                        );
                    }else{
                        htmlProducto += '\
                            <tr ondblclick="add2('+item.id_areap+','+item.id_pres+',\''+item.pro_nom+'\',\''+item.pro_pre+'\','+item.pro_cos+',\''+item.Impresora.nombre+'\');">\
                              <th>'+item.pro_cod+'</th>\
                              <th>'+item.pro_nom+'</th>\
                              <th>'+item.pro_pre+'</th>\
                              <th>'+moneda+' '+item.pro_cos+'</th>\
                            </tr>';
                    }
                });

                    if ($("#mostrarimagen").val()!=1) {
                        htmlProducto += '</tbody>\
                        </table>';
                        $('#list-productos').html(htmlProducto)
                    }

            } else{
                $('#list-productos').html('<div class="text-center"><h4 class="ich m-t-none" style="color: #d3d3d3;"><br><br><br><br><br><br><br><br><br><i class="mdi mdi-star-circle display-4"></i><br>No se han encontrado resultados</h4></div>');
            }
        }
    });
}

var listarPedidos = function(){
    $('#list-detped').empty();
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'venta/listarPedidos',
        data: {
            id_pedido: $('#codped').val(),
            codpagina: $('#codpagina').val()
        },
        success: function (data) {
            if (data.length != 0) {
                $.each(data, function(i, item) {
                    var textIcbper = '';

                    if (item.Producto.impuesto_icbper==1) {
                        textIcbper = '| <span class="font-bold"> ICBPER= </span><span class="label label-primary text-right"><span class="font-bold" style="font-size:12px">'+$("#imp_icbper").val()+'</span></span>'
                    }
                    var total = (item.cantidad * item.precio).toFixed(2);
                    $('#list-detped')
                        .append(
                            $('<div class="d-flex flex-row comment-row comment-list" onclick="subPedido(2,'+$('#codped').val()+','+item.id_pres+',\''+item.precio+'\');"/>')
                            .append('<div class="comment-text w-100 p-0 m-b-10n"><span style="display: inline-block;">'
                            +'<h6 class="m-b-5">'+item.Producto.pro_nom+' <span class="label label-warning">'+item.Producto.pro_pre+'</span> </h6>'
                            +'<div class="m-b-0 font-13 font-black">'+item.cantidad+' Unidad(es) en '+moneda+' '+formatNumber(item.precio)+'   '+textIcbper+'</div></span>'
                            +'<span class="price">'+moneda+' '+formatNumber(total)+'</span></div>'));                      
                });
            }else{
                $('#list-detped').html('<div class="justify-center" style="height: 100%;"><div class="text-center"><h2><i class="fas fa-shopping-basket display-4" style="color: #d3d3d3;"></i></h2><h4 style="color: #d3d3d3;">Agregue productos</h4><h6 style="color: #d3d3d3;">Seleccione categorías y productos<br> del panel de la izquierda</h6></div></div>');
            }
        }
    });
};

var pedido = {
    detalle: {
        cod_ped:    0,
        items: []
    },

    /* Encargado de agregar un producto a nuestra colección */
    registrar: function(item)
    {
        var existe = false;
        
        if ($('#sep_items').val()==1) {

            item.total = (item.cantidad * item.precio);
            this.detalle.items.push(item);

        }else{

            item.total = (item.cantidad * item.precio);
            this.detalle.items.forEach(function(x){
                var cantidad = Number(x.cantidad)
                var cantidad2 = Number(item.cantidad)
                if((x.producto_id === item.producto_id) && (x.precio === item.precio)) {
                    x.cantidad = cantidad += cantidad2
                    x.nombreprecio = item.nombreprecio
                    x.cantidad = parseFloat(x.cantidad).toFixed($("#decimales").val())
                    x.total += item.total;
                    existe = true;
                }
            });

            if(!existe) {
                this.detalle.items.push(item);
            }

        }

        this.refrescar();

    },


    /* Encargado de actualizar el precio/cantidad de un producto */
    actualizar: function(id, row)
    {
        /* Capturamos la fila actual para buscar los controles por sus nombres */
        row = $(row).closest('.warning-element');

        /* Buscamos la columna que queremos actualizar */
        $(this.detalle.items).each(function(indice, fila){
            if(indice == id)
            {
                /* Agregamos un nuevo objeto para reemplazar al anterior */
                pedido.detalle.items[indice] = {
                    producto_id: row.find("input[name='producto_id']").val(),
                    area_id: row.find("input[name='area_id']").val(),
                    nombre_imp: row.find("input[name='nombre_imp']").val(),
                    nombreprecio: row.find("input[name='nombreprecio']").val(),
                    producto: row.find("span[name='producto']").text(),
                    presentacion: row.find("span[name='presentacion']").text(),
                    comentario: row.find("input[name='comentario']").val(),
                    cantidad: row.find("input[name='cantidad']").val(),
                    precio: row.find("input[name='precio']").val(),
                };
                pedido.detalle.items[indice].total = pedido.detalle.items[indice].precio * pedido.detalle.items[indice].cantidad;
                return false;
            }
        })

        this.refrescar();

    },

    /* Encargado de retirar el producto seleccionado */
    retirar: function(id)
    {
        /* Declaramos un ID para cada fila */
        $(this.detalle.items).each(function(indice, fila){
            if(indice == id)
            {
                pedido.detalle.items.splice(id, 1);
                return false;
            }
        })

        this.refrescar();
    },

    /* Refresca todo los productos elegidos */ 
    refrescar: function()
    {
        this.detalle.total = 0;

        /* Declaramos un id y calculamos el total */
        $(this.detalle.items).each(function(indice, fila){
            pedido.detalle.items[indice].id = indice;
            pedido.detalle.total += fila.total;
            $.ajax({
                url: $('#url').val()+'venta/control_stock_pedido',
                type: 'POST',
                dataType: 'json',
                data: {
                    id_pres : pedido.detalle.items[indice].producto_id,
                },
            success: function (datas) {
                if(datas != 0){
                    var queda_stock = ((Number(datas.ent) - Number(datas.sal) ) - Number(pedido.detalle.items[indice].cantidad));
                    if(Number(datas.ent) == (Number(datas.sal) + Number(pedido.detalle.items[indice].cantidad))){

                        Swal.fire({   
                            title:'Advertencia',   
                            html: 'Producto sin Stock, Comuniquese con el administrador',
                            icon: "warning", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    }
                    $('.stock_producto_'+pedido.detalle.items[indice].producto_id).html('Queda: '+queda_stock);
                    $('.stock_producto_'+indice).html('Queda: '+queda_stock);
                }else{
                    $('.stock_producto').html('');
                }
            }});
        })

        /* Calculamos el subtotal e IGV */
        this.detalle.igv      = (this.detalle.total * $('#igv').val()).toFixed(2); // 18 % El IGV y damos formato a 2 deciamles
        this.detalle.subtotal = (this.detalle.total - this.detalle.igv).toFixed(2); // Total - IGV y formato a 2 decimales
        this.detalle.total    = this.detalle.total.toFixed(2);

        var template   = $.templates("#nvo-ped-det-template");
        var htmlOutput = template.render(this.detalle);

        $("#nvo-ped-det").html(htmlOutput);

        /*
        if(this.detalle.total == 0){
            $("#nvo-ped").css('display','none');
            $(".bc").css('display','none');
        }
        */

        $(".touchspin1").TouchSpin({
            verticalbuttons: true,
            buttondown_class: 'btn btn-warning',
            buttonup_class: 'btn btn-warning',
            min: 1,
            max: 999,
            step: 1,
            booster: false,
            stepintervaldelay: 600000
        });
        
    }
};

var add2 = function(id_areap,id_pres,nombre_prod,pres_prod,precio_prod,nombre_imp){

    var precios = ''

    precios = JSON.parse(sessionStorage.getItem('precios_'+id_pres+''))

    if (precios.length > 0) {

        var preciosAdicionales = ''

        $.each(precios, function (ind, elem) {
            console.log(elem.precio)
            console.log(elem.nombre)
            preciosAdicionales += '<div class="col-4 text-center mt-3"><div class="text-center font-bold">'+elem.nombre+'</div>'
                +'<button class="btn btn-primary font-bold" style="width: 120px; font-size: 20px" type="button" onclick="add('+id_areap+','+id_pres+',\''+nombre_prod+'\',\''+pres_prod+'\','+elem.precio+',\''+nombre_imp+'\',\''+elem.nombre+'\');">'+parseFloat(elem.precio).toFixed(2)+' <i class="fa fa-money"></i></button>'
                +'</div>'
        });

        html_confirm =  '<div class="row"> <div class="col-12 col-md-12">'
        +'<div class="text-center p-20"><div class="text-center font-bold">Producto</div><h4 class=" font-bold btn-orange" style="padding-top: 10px; padding-bottom: 10px">'+nombre_prod+' '+pres_prod+'</h4></div>'
        +'<span class="mb-2 text-center" style="display: block;">Elija un precio para la venta</span>'
            +'<div class="row mt-3 mr-2">'
                +'<div class="col-4 text-center mt-3"><div class="text-center font-bold">Precio 1</div>'
                    +'<button class="btn btn-success font-bold" style="width: 120px; font-size: 20px" type="button" onclick="add('+id_areap+','+id_pres+',\''+nombre_prod+'\',\''+pres_prod+'\','+precio_prod+',\''+nombre_imp+'\',\'principal\');">'+parseFloat(precio_prod).toFixed(2)+' <i class="fa fa-money"></i></button>'
                +'</div>'
                +''+preciosAdicionales+'</div>'
            +'</div>'
        +'</div>'
        +'</div>';

        Swal.fire({
            html: html_confirm,
            width: 400,
            allowOutsideClick: false,
            allowEscapeKey : false,
            showCancelButton: true,
            showConfirmButton: false,
            cancelButtonText: "Cancelar",
            closeOnConfirm: false,
            closeOnCancel: false,
        });

        return false

    }else{
        this.add(id_areap,id_pres,nombre_prod,pres_prod,precio_prod,nombre_imp,'principal');
    }

}


var add = function(id_areap,id_pres,nombre_prod,pres_prod,precio_prod,nombre_imp,nombreprecio = null){
    Swal.close();
    var jqxhr = $.ajax({
        type: 'POST',
        url: $('#url').val()+'venta/ValidarEstadoPedido',
        data: {
            cod_ped : $('#codped').val()
        }
    })
    .done(function(data) {
        if(data == 1){
            $.ajax({
                url: $('#url').val()+'venta/control_stock_pedido',
                type: 'POST',
                dataType: 'json',
                data: {
                    id_pres : id_pres,
                },
            success: function (datasss) {
                if(datasss != 0){

                    if((Number(datasss.ent)) == (Number(datasss.sal))){
                        Swal.fire({   
                            title:'Advertencia',   
                            html: 'Producto sin Stock, Comuniquese con el administrador',
                            icon: "warning", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });

                    }else{

                        $("#nvo-ped").css('display','block');
                        $(".bc").css('display','block');
                        pedido.registrar({
                            area_id: id_areap,
                            nombre_imp: nombre_imp,
                            producto_id: parseInt(id_pres),
                            producto: nombre_prod,
                            presentacion: pres_prod,
                            cantidad: parseInt(1),
                            precio: parseFloat(precio_prod).toFixed(2),
                            nombreprecio: nombreprecio,
                            comentario: "",
                        });
                        $.toast({
                            text: 'Pedido agregado a la lista',
                            position: 'bottom-left',
                            loaderBg:'#696969',
                            icon: 'success',
                            hideAfter: 3000, 
                            stack: 20
                        });
                        $("#btn-confirmar").removeAttr('disabled');                       
                    }                

                }else{
                    $("#nvo-ped").css('display','block');
                    $(".bc").css('display','block');
                    pedido.registrar({
                        area_id: id_areap,
                        nombre_imp: nombre_imp,
                        producto_id: parseInt(id_pres),
                        producto: nombre_prod,
                        presentacion: pres_prod,
                        cantidad: parseInt(1),
                        precio: parseFloat(precio_prod).toFixed(2),
                        nombreprecio: nombreprecio,
                        comentario: ""
                    });
                    // if($('#rol_usr').val() == 5){
                        $.toast({
                            text: 'Pedido agregado a la lista',
                            position: 'bottom-left',
                            loaderBg:'#696969',
                            icon: 'success',
                            hideAfter: 3000, 
                            stack: 20
                        });
                    // }
                    $("#btn-confirmar").removeAttr('disabled');
                    $("#buscar_producto").val('');

                }
            }});
        } else if (data == 2){
            var html_confirm = '<div>Estas intentando agregar productos a una orden, que ya a sido facturada o cancelada anteriormente.</div>\
            <br>\
            <div><a href="'+$("#url").val()+'venta" class="btn btn-success">Continuar <i class="fas fa-arrow-alt-circle-right"></i></a>';

            Swal.fire({
                title: 'Esta orden ya ha sido LIBERADA!',
                html: html_confirm,
                icon: 'error',
                allowOutsideClick: false,
                allowEscapeKey : false,
                showCancelButton: false,
                showConfirmButton: false,
                closeOnConfirm: false,
                closeOnCancel: false
            });
        }
    });
};
 
$("#btn-confirmar").on("click", function(){
    $("#btn-confirmar").attr('disabled','true');
    if(pedido.detalle.items.length == 0)
    {
        Swal.fire({   
            title:'Advertencia',   
            html: 'Seleccione un producto,<br>para poder agregarlo a la lista de pedidos',
            icon: "warning", 
            confirmButtonColor: "#34d16e",   
            confirmButtonText: "Aceptar",
            allowOutsideClick: false,
            showCancelButton: false,
            showConfirmButton: true
        }, function() {
            return false
        });
    }else{

        pedido.detalle.cod_ped = $('#codped').val();
        pedido.detalle.codtipoped = $('#codtipoped').val();
        var codigo = 0;

        var jqxhr = $.ajax({
            type: 'POST',
            url: $('#url').val()+'venta/RegistrarPedido',
            data: pedido.detalle
        })
        .done(function(data) {
            if(data == 1){
                defaultdata();
                listarPedidos();
                pedido.detalle.items.length = 0;
                $('#nvo-ped-det').empty();
                $("#nvo-ped").css('display','none');
                $(".bc").css('display','none');
            } else if (data == 2){
                window.open($("#url").val()+'venta','_self');
            }
        })
        .fail(function() {
            console.log(errorThrown + ' ' + textStatus);
        })
        .always(function(data) {});


        if($('#codimpcomandamesa').val() == 1){
        
            if(($('#codtipoped').val() == 1) || $('#codtipoped').val() == 2){
        
                var array = pedido.detalle.items;
                var contador = new Array();
                var nuevoarray = new Array();
                var i,y,z;

                for(i=0; i < array.length; i++){
                    contador.push(parseInt(array[i].area_id));
                }

                cont = [...new Set(contador)];

                for(y=0; y < cont.length; y++){
                    for(z=0; z < array.length; z++){
                        if(array[z].area_id == cont[y]){
                            nuevoarray.push(array[z]);
                            nombre_impresora = array[z].nombre_imp;
                        }
                    }
                    var nuevopedido = {
                        pedido_tipo : $('#codtipoped').val(),
                        pedido_numero : $('.pedido-numero').text(),
                        pedido_cliente : $('.pedido-cliente').text(),
                        pedido_mozo : $('#nombre_mozo').val(), 
                        dato_usuario : $('#dato_usuario').val(), 
                        precio_comanda : $('#precio_comanda').val(), 
                        correlativo_imp : correlativo_imp(),
                        nombre_imp : nombre_impresora,
                        nombre_pc : $('#pc_name').val(),
                        codigo_anulacion : 0,
                        items : nuevoarray
                    }

                    if($('#print_com').val() == 1 ){

                        window.open('http://'+$('#pc_ip').val()+'/imprimir/comanda.php?data='+JSON.stringify(nuevopedido)+'','_blank');

                    }else{

                        window.open(''+$("#url").val()+'venta/impresion_comanda/?data='+JSON.stringify(nuevopedido)+'', "_blank", "top=500,left=500,width=400,height=400");

                    }

                    var nuevoarray = new Array();
                } 

            } 

        }

        limpiar_datos_add();
        listarComandas();
        if($('#rol_usr').val() == 5){
            Swal.fire({   
                title:'Pedido AÑADIDO!',   
                html: '¿Deseas continuar comandando?',
                icon: "warning", 
                confirmButtonColor: "#34d16e",  
                cancelButtonColor: "#fb3a3a",   
                confirmButtonText: "Continuar!!",
                cancelButtonText: "Cerrar sesión!",
                allowOutsideClick: false,
                showCancelButton: true,
                showConfirmButton: true,
            }).then((result) => {
                if (result.value) {
                    window.open($("#url").val()+'venta','_self');
                }else{
                    window.open($("#url").val()+'tablero/logoutmozo','_self');
                }
            });
        }
    }
});

/* Desocupar mesa */
var anular_pedido = function(id_pedido){

    var html_confirm = '<div>Se procederá a liberar este pedido</div><br>\
    Ingrese código de seguridad</div><br>\
    <form><input class="form-control text-center w-50" type="password" id="codigo_anular_venta_" autocomplete="off"/></form><br>\
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
                if($('#codigo_anular_venta').val() == $('#codigo_anular_venta_').val()){
                    $.ajax({
                        url: $('#url').val()+'venta/anular_pedido',
                        type: 'POST',
                        data: {
                            id_pedido : id_pedido,
                            tipo_pedido : $("#codtipoped").val()
                        },
                        dataType: 'json'
                    })
                    .done(function(response){
                        window.open($("#url").val()+'venta','_self');
                    })
                    .fail(function(){
                        Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
                    });

                } else {
                    Swal.fire({
                        title: 'Proceso No Culminado',
                        text: 'El código ingresado es incorrecto',
                        icon: 'error',
                        confirmButtonColor: '#34d16e',
                        confirmButtonText: "Aceptar"
                    });
                }
            });
        },
        allowOutsideClick: false              
    });
}

/* Imprimir Pre Cuenta*/
var impPreCuenta = function(id_pedido,id_mesa,estado,wiew){
    $.ajax({
        url: $("#url").val()+'venta/pedido_estado_update',
        type: "post",
        dataType: "json",
        data: {
            id_mesa: id_mesa,
            estado: estado
        },
        success: function (r) {
            return true;
        }
    }).done(function(){
        if(wiew){
            printPdf($("#url").val()+'venta/impresion_precuenta/'+id_pedido,true);
        }else{
            window.open($("#url").val()+'venta/impresion_precuenta/'+id_pedido,'_blank');            
        }
    }); 
}

/* confirmar dividir cuenta*/
var conf_dividir = function(id_pedido,dividir_cuenta){
   
    Swal.fire({
        title: 'Confirmación',
        html: "¿Desea dividir cuenta?",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true
    }).then((result) => {
        if (result.value) {
            facturar(id_pedido,dividir_cuenta)
        } else if (result.dismiss === Swal.DismissReason.cancel) {
            return false
        }
    });
    
}


var facturar = function(id_pedido,dividir_cuenta){
    $("#btn-submit-facturar").removeAttr('disabled');
    $('#list-items-facturar').empty();
    $('#id_pedido').val(id_pedido);
    $('#dividir_cuenta').val(dividir_cuenta);
    var tipo_pedido = $('#codtipoped').val();
    var moneda = $("#moneda").val();
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'venta/ListarDetallePed',
        data: {
            id_pedido: id_pedido, 
            tipo_pedido: tipo_pedido
        },
        success: function (data) {
            var sub_total = 0;
            var precio_imp_bol = 0;
            $.each(data.Detalle, function(i, item) {

                var totped = $("#total_pedido").val();
                var imp_bol = $("#imp_icbper").val();
                if (item.Producto.impuesto_icbper == "1") {
                  precio_imp_bol = parseFloat(item.cantidad * imp_bol) + parseFloat(precio_imp_bol);
                } else {
                  precio_imp_bol = parseFloat(precio_imp_bol);
                }
                var calc = (item.cantidad * item.precio).toFixed(2);
                sub_total = (parseFloat(item.cantidad * item.precio)) + (parseFloat(sub_total));

                if (1 == dividir_cuenta && item.cantidad > 0){
                    $(".icbper").text(formatNumber(imp_bol));
                    $(".totalPedido").val(totped);
                    $(".totalPedido").text(formatNumber(totped));
                    $(".subtotal").text(formatNumber(totped));
                    $("#total_venta").val(totped);
                    $('.btn-cancel-facturar-1').show();
                    $('.btn-cancel-facturar-2').hide();
                    calculo_total();
                    calculo_efectivo();
                    $('#list-items-facturar')
                    .append(
                    $('<tr class="comment-list"/>')
                        .append(
                            $('<td width="20%"/>')
                            .html('<input type="hidden" name="cantProd[]" value="'+item.cantidad+'"/>'
                                +'<input type="hidden" name="precProd[]" value="'+item.precio+'"/>'
                                +item.cantidad)
                            )
                        .append(
                            $('<td width="60%"/>')
                            .html('<input type="hidden" name="idProd[]" value="'+item.id_pres+'"/>'
                                +item.Producto.pro_nom+' <span class="label label-warning text-uppercase">'+item.Producto.pro_pre+'</span>')
                            )
                        .append(
                            $('<td width="20%" class="text-right"/>')
                            .html(moneda+' '+formatNumber(calc))
                            )
                    );
                } else if (2 == dividir_cuenta && item.cantidad > 0){
                    limpiar_datos_add();
                    $('.display-pago-rapido-efectivo').show();
                    $(".totalPedido").val('0.00');
                    $(".totalPedido").text('0.00');
                    $("#total_venta").val('0.00');
                    $(".subtotal").text('0.00');
                    $('.btn-cancel-facturar-1').hide();
                    $('.btn-cancel-facturar-2').show();
                    calculo_total();
                    $(".opc-01").text('0.00');
                    $('#list-items-facturar')
                    .append(
                    $('<tr class="comment-list priceU" data-price="'+item.precio+'" style="cursor: pointer;"/>')
                        .append(
                            $('<td width="20%"/>')
                            .html('<input type="hidden" class="cantidad" name="cantProd[]" value="0"/>'
                                +'<input type="hidden" name="precProd[]" value="'+item.precio+'"/>'
                                +'<input type="hidden" value="'+item.cantidad+'" class="cantOrg"/>'
                                +'<input type="hidden" value="1" class="cantTemp"/>'
                                +'<b></b> '+item.cantidad)
                            )
                        .append(
                            $('<td width="60%"/>')
                            .html('<input type="hidden" name="idProd[]" value="'+item.id_pres+'"/>'
                                +item.Producto.pro_nom+' <p class="label label-warning text-uppercase">'+item.Producto.pro_pre+'</p>')
                            )
                        .append(
                            $('<td width="20%" class="text-right"/>')
                            .html(moneda+' <span>0.00</span>')
                            )
                    );
                }
            });
            $(".subtotal").text(formatNumber(sub_total));
            $(".icbper").text(formatNumber(precio_imp_bol));
            $("#monto_icbper").val(parseFloat(precio_imp_bol));

            $(".priceU").on("click",function(){
                var totalTemp = $(this).find(".cantTemp").val();
                $(this).css('cssText','background: #f9e79f !important; color: #424949 !important; cursor: pointer;');
                $(this).find(".cantTemp").val(parseInt(totalTemp)+1);
                var totalCant = $(this).find(".cantOrg").val();
                var cantB = parseInt(totalCant) - 1;
                $(this).find("b").text(totalTemp+' /');
                var valorItem = $(this).find("span").text();
                var valorPrice = $(this).attr("data-price");
                var totalItem = (parseFloat(valorItem)+parseFloat(valorPrice)).toFixed(2);
                $(this).find("span").text(totalItem);
                var totalGneral=0;
                $(this).find(".cantidad").val(totalTemp);
                if(parseInt(totalCant) < parseInt(totalTemp)){
                    $(this).find(".cantTemp").val(1);
                    $(this).css('cssText','background: transparent !important; cursor:pointer;');
                    $(this).find("span").text('0.00');
                    $(this).find("b").text('');
                    $(this).find(".cantidad").val(0);
                }
                $(".priceU").each(function() {
                  totalGneral += parseFloat($( this ).find("span").text());
                });
                $(".totalPedido").val((totalGneral).toFixed(2));
                $(".totalPedido").text(formatNumber(totalGneral));
                $('.totalPedidoMenosTarjeta').text(formatNumber(totalGneral));
                $("#total_venta").val(totalGneral);
                $(".subtotal").text(formatNumber(totalGneral));
                $("#btn-submit-facturar").removeAttr('disabled');
                $("#btn-submit-facturar").removeClass('disabled');
                limpiar_datos_add();
                $("#pago_efe").val((totalGneral).toFixed(2));
                $(".opc-01").text((totalGneral).toFixed(2));
            });
        },
        error: function(jqXHR, textStatus, errorThrown){
            console.log(errorThrown + ' ' + textStatus);
        }   
    });
    $("#modal-facturar").modal('show');
}

/* NOTA DE PRODUCTO */

var comentar = function(cod_add,cod_pres_add,nom_prod,nom_pres){
    $('.card-title-nota').html(nom_prod+' <span class="label label-warning text-uppercase">'+nom_pres+'</span>');
    $('.nota-list').css('display','block');
    $('.nota-new').css('display','none');    
    $('#modal-nota').modal('show');
    $('#cod_pres_add').val(cod_pres_add);
    $('#cod_add').val(cod_add);
    $('#notapadre').attr('class','nota'+cod_add);
    $('.checkk').prop('checked', false);
    note_list(cod_add,cod_pres_add);
};

$('.demo-checkbox').on('change', 'input.checkk', function(event){
    var arr = $('[name="checks[]"]:checked').map(function(){
      return this.value.trim();
    }).get(); 
    var str = arr.join(', ');
    var clase = $('#notapadre').attr("class");
    $('.'+clase).val(str);
    $('.'+clase).change();
    $('.txt'+clase).text(str);
    $('.txt'+clase).change();
});
 
var nota_manual_text = function(){
    if($('#nota_ind').val() == 1){
        var clase = $('#notapadre').attr("class");
        var notas_manual =  $('.nota_manual_text').val();
        var notassss = $('.'+clase).val();
        if (notas_manual!='') {
            var separadorNota = ', '
        }else{
            var separadorNota = ''
        }
        $('.'+clase).val(notassss+''+separadorNota+''+notas_manual);
        $('.'+clase).change(); 
        $('.txt'+clase).text(notassss+''+separadorNota+''+notas_manual);
        $('.txt'+clase).change(); 
    }
}

var note_list = function(cod_add,cod_pres_add){
    $('.demo-checkbox').empty();
    $.ajax({
        url: $('#url').val()+'venta/tags_list',
        type: "post",
        dataType: "json",
        data: {
            id_pres: cod_pres_add
        },
        success: function (data) {
            if(data['notas'] == null || data['notas'] == ''){
                $('.demo-checkbox').removeClass('row m-t-40');
                $('.demo-checkbox').html('<center><i class="mdi mdi-alert-circle display-4"></i><br>No tiene elementos.<br>Agregue una nota <code style="cursor: pointer;" class="btn btn-xs btn-primary">AGREGAR</code><br></center>');
                $('.nota-list').css('display','block');
                $('.notlist').css('display','none');
            }else{
                if(data['notas'].length > 0){
                    var arreglo1 = data['notas'].split(",");
                    $('.demo-checkbox').addClass('row m-t-40');
                    $('.nota-new').css('display','none');
                    $('.nota-list').css('display','block');
                    $('.notlist').css('display','block');
                    $.each(arreglo1, function (ind, elem) {
                            $('.demo-checkbox')
                                .append(
                                $('<div class="col-6 m-b-10"/>')
                                    .html('<input type="checkbox" class="checkk filled-in chk-col-light-green" id="'+elem.trim()+'" name="checks[]" value="'+elem+'">'
                                        +'<label for="'+elem.trim()+'" class="m-b-0">'+elem.trim()+'</label>')
                            )
                    });
                    $('.notlist').html('En caso de no estar en lista agregue una nota <code class="btn-nueva-nota" style="cursor: pointer;">\'NUEVA\'</code>');             
                }else{
                    $('.demo-checkbox').removeClass('row m-t-40');
                    $('.demo-checkbox').html('<center><i class="mdi mdi-alert-circle display-4"></i><br>No tiene elementos.<br>Agregue una nota <code style="cursor: pointer;">\'NUEVA\'</code><br></center>');
                    $('.nota-list').css('display','block');
                    $('.notlist').css('display','none');
                }
            }

            if($('#nota_ind').val() == 1){
                $('.nota_manual').html('<input type="text" class="nota_manual_text form-control border border-dark rounded" name="nota_manual_text" value="" placeholder="  Escribir nota manual..." />');  
            }
        }
    }).done(function(){
        var vector = $('.nota'+cod_add).val(); 
        var arreglo2 = vector.split(",");
        $.each(arreglo2, function (ind, ele) {
            var element = document.getElementById(ele);
            $(element).prop('checked', true);
        });
    });
}

var tags_list = function(cod_pres_add){
    $('#notas').tagsinput('removeAll');
    $.ajax({
        url: $('#url').val()+'venta/tags_list',
        type: "post",
        dataType: "json",
        data: {
            id_pres: cod_pres_add
        },
        success: function (data) {
            $('#cod_prod_add').val(data['id_prod']);
            $('#notas').tagsinput('add',data['notas']);
        }
    });
}

$('.demo-checkbox,.notlist').on('click', 'code', function(event){
    $('.nota-list').css('display','none');
    $('.notlist').css('display','none');
    $('.nota-new').css('display','block');
    tags_list($('#cod_pres_add').val());
});

$(".btn-guardar-nota").click(function() {
    $.ajax({
        url: $('#url').val()+'venta/tags_crud',
        type: "post",
        dataType: "json",
        data: {
            id_prod: $("#cod_prod_add").val(),
            notas: $("#notas").val().toUpperCase()
        },
        success: function (e) {
            $('.nota-list').css('display','block');
            $('.notlist').css('display','block');
            $('.nota-new').css('display','none'); 
            note_list($("#cod_add").val(),$("#cod_pres_add").val());
        }
    });
});

$(".btn-cancelar-nota").click(function() {
    $('.nota-list').css('display','block');
    $('.nota-new').css('display','none');
    note_list($("#cod_add").val(),$("#cod_pres_add").val());
});

$(".btn-acep-nota").click(function() {
    nota_manual_text();
    $("#modal-nota").modal('hide');
});

/* NOTA DE PRODUCTO */

/* MODAL FACTURA */

var calculo_total = function(){
    if($("#descuento_monto_hidden").val() == ''){ $("#descuento_monto_hidden").val('0.00');}
    if($("#comision_delivery").val() == ''){ $("#comision_delivery").val('0.00');}
    var calculo = parseFloat($("#total_venta").val()) + parseFloat($("#comision_delivery").val()) + parseFloat($(".comision_tarjeta").val()) - parseFloat($("#descuento_monto_hidden").val());
    $(".totalPedido").val(formatNumber(calculo));
    $(".totalPedido").text(formatNumber(calculo));
    $('.totalPedidoMenosTarjeta').text(formatNumber(calculo));
    //console.log('calculo_total: '+calculo);
}

var calculo_efectivo = function(){
    var cal1 = parseFloat($(".totalPedido").val().replace(',', "")) - parseFloat($("#pago_tar").val().replace(/,/g, ""))  - parseFloat($("#pago_yape").val().replace(/,/g, ""))  - parseFloat($("#pago_plin").val().replace(/,/g, ""))  - parseFloat($("#pago_tran").val().replace(/,/g, "")) - parseFloat($(".comision_tarjeta").val().replace(/,/g, "")) ;
    var cal2 = parseFloat($('#pago_efe').val().replace(/,/g, "")) - parseFloat(cal1);

    if(isNaN(cal2)){
        cal2 = 0;
    }

    $("#vuelto").text(formatNumber(cal2));
    //console.log('vuelto: '+cal2);
}

/* Pago efectivo */
$('#pago_efe,#pago_tar').on('keyup', function(){
    calculo_efectivo();
});

/* Pago tarjeta */
$('#pago_tar').on('keyup', function(){
    calculo_total();
    $('.totalPedidoMenosTarjeta').text(formatNumber($('.totalPedido').val() - $('#pago_tar').val()));
});

/* Pago yape */
$('#pago_yape').on('keyup', function(){
    calculo_total();
    $('.totalPedidoMenosTarjeta').text(formatNumber($('.totalPedido').val() - $('#pago_tar').val() - $('#pago_yape').val() - $('#pago_plin').val() - $('#pago_tran').val() ));
    calculo_efectivo();
});
/* Pago plin */
$('#pago_plin').on('keyup', function(){
    calculo_total();
    $('.totalPedidoMenosTarjeta').text(formatNumber($('.totalPedido').val() - $('#pago_tar').val() - $('#pago_yape').val() - $('#pago_plin').val() - $('#pago_tran').val() ));
    calculo_efectivo();
});
/* Pago transferencia */
$('#pago_tran').on('keyup', function(){
    calculo_total();
    $('.totalPedidoMenosTarjeta').text(formatNumber($('.totalPedido').val() - $('#pago_tar').val() - $('#pago_yape').val() - $('#pago_plin').val() - $('#pago_tran').val() ));
    calculo_efectivo();
});

var descuento_factura = function(){
    var html_confirm = '<div class="text-left"><form class="dec">\
    <div class="floating-labels">\
        <div class="form-group m-t-40 m-b-20">\
            <select class="form-control" id="filtro_descuento_tipo" data-style="form-control btn-default" title="Seleccionar" autocomplete="off" required="required">\
                <option value="1">Cortes&iacute;a</option>\
                <option value="2">Descuento</option>\
                <option value="3">Credito personal</option>\
            </select>\
            <span class="bar"></span>\
            <label for="filtro_descuento_tipo">Tipo</label>\
        </div>\
    </div>\
    <div class="floating-labels display-descuento-personal" style="display: block;">\
        <div class="form-group m-t-40 m-b-20">\
            <select class="form-control" id="filtro_descuento_personal" data-style="form-control btn-default" title="Seleccionar" autocomplete="off" required="required">\
            </select>\
            <span class="bar"></span>\
            <label for="filtro_descuento_personal">Personal</label>\
        </div>\
    </div>\
    <div class="display-descuento-monto" style="display: none;">\
        <label>Ingrese monto</label>\
        <div class="row">\
            <div class="col-sm-6"><div class="input-group"><input class="form-control text-center" type="text" id="filtro_descuento_monto_porcentaje" autocomplete="off"/><div class="input-group-append"><span class="input-group-text">%</span></div></div></div>\
            <div class="col-sm-6"><div class="input-group"><div class="input-group-prepend"><span class="input-group-text">S/</span></div><input class="form-control text-center" type="text" id="filtro_descuento_monto" autocomplete="off"/></div></div>\
        </div>\
    </div>\
    <div class="display-descuento-motivo" style="display: block;">\
        <label class="m-t-10">Motivo</label>\
        <textarea id="filtro_descuento_motivo" class="form-control" rows="2" required="required"></textarea>\
        </form></div><br>\
    </div>\
    <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>\
    ';
    Swal.fire({
        title: 'Cortesía / descuento',
        html: html_confirm,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true
    }).then((result) => {
        if (result.value) {
            limpiar_pagos_b();
            $('.descuento').val($("#filtro_descuento_monto").val());
            $('.descuento').text(formatNumber($("#filtro_descuento_monto").val()));
            $('#descuento_tipo_hidden').val($("#filtro_descuento_tipo").val());
            $('#descuento_motivo_hidden').val($("#filtro_descuento_motivo").val());
            $('#descuento_personal_hidden').val($("#filtro_descuento_personal").val());
            calculo_total();
            $('#pago_efe').val($('.totalPedido').val());
            $('.opc-01').text(formatNumber($('.totalPedido').val()));

            if($('#filtro_descuento_tipo').val() == 1 || $('#filtro_descuento_tipo').val() == 3){
                if ($('#filtro_descuento_tipo').val() == 1){
                    $('#descuento_monto_hidden').val('0.00');
                    $('.descuento').text('0.00');
                    $('.text-tipo-descuento').html('<span class="label label-primary">CORTESIA</span>');
                } else {
                    $('.text-tipo-descuento').html('<span class="label label-info">CREDITO PERSONAL</span>');
                }               
                $('#pago_efe').val('0.00');
                $('.totalPedido').text('0.00');
                $('.opc-01').text('0.00');
                $('.totalPedidoMenosTarjeta').text('0.00');
            } else {
                $('.text-tipo-descuento').html('');
            }
            
        } else if (result.dismiss === Swal.DismissReason.cancel) {
            //$("#modal-facturar").modal('show');
        }
    });
    $('.swal2-actions').prepend('<button class="btn btn-warning restDataDescuento" data-original-title="Restaurar datos" data-toggle="tooltip" data-placement="top"><i class="fas fa-undo-alt"></i></button>&nbsp;');
    $('#filtro_descuento_tipo').selectpicker('refresh');
    $('#filtro_descuento_tipo').selectpicker('val', $('#descuento_tipo_hidden').val());
    $("#filtro_descuento_monto").val($("#descuento_monto_hidden").val());
    $("#filtro_descuento_motivo").val($("#descuento_motivo_hidden").val());

    if($('#descuento_tipo_hidden').val() == 1){
        $('.display-descuento-monto').hide();
        $('.display-descuento-personal').hide();
    } else if($('#descuento_tipo_hidden').val() == 2){
        $('.display-descuento-monto').show();
        $('.display-descuento-personal').hide();
    } else if($('#descuento_tipo_hidden').val() == 3){
        $('.display-descuento-monto').show();
        $('.display-descuento-personal').show();
    }else{
        $('.display-descuento-monto').hide();
        $('.display-descuento-personal').hide();
    }
    $('.restDataDescuento').tooltip();
    $(".dec input").keypress(function(event) {
        var valueKey=String.fromCharCode(event.which);
        var keycode=event.which;
        if(valueKey.search('[0-9.]')!=0 && keycode!=8){
            return false;
        }
    });

    var personal = $("#filtro_descuento_personal");
    $.ajax({
        url: $('#url').val()+'venta/Personal',
        type: 'POST',
        dataType: 'json',  
        success:  function (r) 
        {
            personal.find('option').remove();
            $(r).each(function(i, v){ // indice, valor
                personal.append('<option value="'+v.id_usu+'">'+v.nombres+' '+v.ape_paterno+' '+v.ape_materno+'</option>');
            });
            $('#filtro_descuento_personal').selectpicker('refresh');
            $('#filtro_descuento_personal').selectpicker('show');
            $('#filtro_descuento_personal').selectpicker('val', $('#descuento_personal_hidden').val());
        }
    });

    $('#filtro_descuento_tipo').change( function() {

        if($('#filtro_descuento_tipo').val() == 1){
            $('.display-descuento-monto').hide();
            $('.display-descuento-personal').hide();
        } else if($('#filtro_descuento_tipo').val() == 2){
            $('.display-descuento-monto').show();
            $('.display-descuento-personal').hide();
        } else if($('#filtro_descuento_tipo').val() == 3){
            $('.display-descuento-monto').show();
            $('.display-descuento-personal').show();
        }else{
            $('.display-descuento-monto').hide();
            $('.display-descuento-personal').hide();
        }

    });

    $('.restDataDescuento').click( function() {
        $('.restDataDescuento').tooltip('hide');
        $("#descuento_monto_hidden").val('0.00');
        $(".descuento").text('0.00');
        calculo_total();
        $('#pago_efe').val($('.totalPedido').val());
        $('.opc-01').text(formatNumber($('.totalPedido').val()));
        $('#descuento_tipo_hidden').val('');
        $('#descuento_personal_hidden').val('');
        $('#descuento_motivo_hidden').val('');
        $('.text-tipo-descuento').html('');
        swal.close();
    });

    //Calculo del porcentaje desde porcentaje
    $('#filtro_descuento_monto_porcentaje').on('keyup', function(){
        var sub_total = $("#total_venta").val();
        var porcentaje = ($("#filtro_descuento_monto_porcentaje").val() / 100).toFixed(2);
        var total = (sub_total * porcentaje).toFixed(2);
        //var total = (sub_total - cal).toFixed(2);
        $("#filtro_descuento_monto").val(total);        
    });
}

var clickSendWhatsapp = function(id) {
    var mensajewa =$("#mesaje_waz").val();
    var num_cliente = $("#numero_cliente").val();
    var Urls = $("#url").val()+'comprobante/ticket/'+btoa(id);
    if($("#numero_cliente").val().length!=11){
        $.toast({
            text: 'Error: Ingrese un número válido',
            position: 'bottom-center',
            loaderBg:'#696969',
            icon: 'error',
            hideAfter: 3000, 
            stack: 20
        });
    }else{

        if ($('#api_wsp').val()==1) {
            $.ajax({
                url: $('#url').val()+'whatsapp/send_wsp_invoice',
                type: 'POST',
                data: {
                    num_cliente : num_cliente,
                    id_venta : id
                },
                dataType: 'json'
            })
            .done(function(response){
                if(response.status == true){
                    $.toast({
                        text: 'Whatsapp enviado correctamente <br><br> <strong>Respuesta server: </strong>'+response.msg+'',
                        position: 'bottom-center',
                        loaderBg:'#696969',
                        icon: 'success',
                        hideAfter: 3000, 
                        stack: 20
                    });

                }else{
                    $.toast({
                        text: ''+response.msg+'<br>'+response.errors ? response.errors : ''+'',
                        position: 'bottom-center',
                        loaderBg:'#696969',
                        icon: 'error',
                        hideAfter: 3000, 
                        stack: 20
                    });
                }
            })
            .fail(function(error){
                $.toast({
                    text: 'Error: No se pudo enviar',
                    position: 'bottom-center',
                    loaderBg:'#696969',
                    icon: 'error',
                    hideAfter: 3000, 
                    stack: 20
                });
            });
        }else{
            var meg_com = mensajewa+' '+Urls;
            window.open('https://wa.me/'+num_cliente+'?text='+meg_com+'', '_blank');
        }
    }
};

var clickSendEmail = function(id_venta, documento){

    $('#button-SendEmail').prop('disabled',true);
    $('#msj-SendEmail').css("display", "block");

     $.ajax({
        url: $('#url').val()+'facturacion/send_mailer',
        type: 'POST',
        data: {
            correo_cliente : $('#correo_cliente').val(),
            documento_cliente : documento,
            id_venta : id_venta
        },
        dataType: 'json'
     })
     .done(function(response){
        if(response == '1'){

            Swal.fire({
                title: 'Proceso Terminado',
                text: 'Correo enviado correctamente',
                footer: '<div><a class="btn btn-green" href="'+$("#url").val()+'venta'+'" target="_self">Continuar <i class="fas fa-arrow-right"></i></a></div>',
                icon: 'success',
                allowOutsideClick: false,
                allowEscapeKey : false,
                showCancelButton: false,
                showConfirmButton: false,
                closeOnConfirm: false,
                closeOnCancel: false,
                // backdrop: '#34d16e'
            });

        }else{
            Swal.fire({
                title: 'Proceso No Culminado',
                text: 'El correo no existe',
                icon: 'error',
                confirmButtonColor: "#34d16e",   
                confirmButtonText: "OK"
            });
        }
     })
     .fail(function(){
        Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
     });
}

var printPdf = function(url,condicional) {

    var userAgent = navigator.userAgent || navigator.vendor || window.opera;
    
    if ((/android/i.test(userAgent)) || (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) ) {
        if(condicional){
            var Urlpdf = url;
        }else{
            var Urlpdf = $("#url").val()+'informe/venta_all_imp/'+url;   
        }
        window.open(Urlpdf, '_blank');
    }else{
        if(condicional){
            var Urlpdf = url;
        }else{
            var Urlpdf = $("#url").val()+'informe/venta_all_imp/'+url;   
        }
      
        var iframe = document.createElement('iframe');
        iframe.className='pdfIframe'
        document.body.appendChild(iframe);
        iframe.style.display = 'none';
        iframe.onload = function () {
            setTimeout(function () {
                iframe.focus();
                iframe.contentWindow.print();
                URL.revokeObjectURL(Urlpdf)
            }, 0);
        };
        iframe.src = Urlpdf;
        URL.revokeObjectURL(Urlpdf)
    }

};
var comision_delivery_factura = function(){
    var html_confirm = '<div>Se procederá a realizar una comisión por el servicio de delivery<br><br>\
    Ingrese monto</div>\
    <form class="dec"><input class="form-control text-center w-50" type="text" id="filtro_comision_delivery" autocomplete="off" value=""/></form><br>\
    <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
    Swal.fire({
        title: 'Necesitamos de tu Confirmación',
        html: html_confirm,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true
    }).then((result) => {
        if (result.value) {
            limpiar_pagos_b();
            $('.comision_delivery').val($("#filtro_comision_delivery").val());
            $('.comision_delivery').text(formatNumber($("#filtro_comision_delivery").val()));
            calculo_total();
            $('#pago_efe').val($('.totalPedido').val());
            $('.opc-01').text(formatNumber($('.totalPedido').val()));
        } else if (result.dismiss === Swal.DismissReason.cancel) {
            //$("#modal-facturar").modal('show');
        }
    });
    $(".dec input").keypress(function(event) {
        var valueKey=String.fromCharCode(event.which);
        var keycode=event.which;
        if(valueKey.search('[0-9.]')!=0 && keycode!=8){
            return false;
        }
    });
}

$('input[name="tipo_doc"]').on('change', function(){
    value = $('input:radio[name="tipo_doc"]:checked').val();
    $('#cliente_tipo').val(value);
    $('#tipo_cliente').val(value);
    $('#id_cliente').val('');
    // console.log(value)
    if(value == 3 || value == 1){
        $('#cliente_id').val(1);
        $('#buscar_cliente').val('DNI: 00000000 | PUBLICO EN GENERAL');
    }else{
        $('#cliente_id').val('');
        $('#buscar_cliente').val('');
    }
    $('.opcion-cliente').html('<a class="input-group-prepend" href="javascript:void(0)"'
        +'onclick="nuevoCliente();" data-original-title="Registrar nuevo cliente" data-toggle="tooltip"'
        +'data-placement="top">'
            +'<span class="input-group-text bg-header">'
                +'<small><i class="fas fa-user-plus"></i></small>'
           +'</span>'
        +'</a>');
});

$('#tipo_pago').change( function() { 
    var x = document.getElementById("tipo_pago").selectedIndex;
    value = document.getElementsByTagName("option")[x].label;
    if(value == 1){
        limpiar_pagos_a();
        $('.mensaje-pago').hide();
        $('.display-pago-efectivo').show();
        $('.display-pago-tarjeta').hide();
        $('.display-pago-default').show();
        $('.display-pago-rapido-efectivo').show();
        $('.display-codigo-operacion').hide();
        $("#pago_efe").val(formatNumber($('.totalPedido').val()));
        $('.opc-01').text(formatNumber($('.totalPedido').val()));
    } else if(value == 3){
        limpiar_pagos_a();
        $('.mensaje-pago').hide();
        $('.display-pago-efectivo').show();
        $('.display-pago-tarjeta').show();
        $('.display-pago-default').show();
        $('.display-pago-rapido-efectivo').show();
        $('.display-codigo-operacion').show();
    } else if(value == 4){
        limpiar_pagos_a();
        $('.mensaje-pago').show();
        //$('.mensaje-pago-text').text(' Esta venta ha sido pagado con Culqi');
        $('.display-pago-efectivo').hide();
        $('.display-pago-tarjeta').hide();
        $('.display-pago-default').hide();
        $('.display-pago-rapido-efectivo').hide();
        $('.display-codigo-operacion').show();
    } else if(value == 2 || value >= 5){
        limpiar_pagos_a();
        $('.mensaje-pago').hide();
        //$('.mensaje-pago-text').text(' Ingrese codigo de transferencia');
        $('.display-pago-efectivo').hide();
        $('.display-pago-tarjeta').hide();
        $('.display-pago-default').hide();
        $('.display-pago-rapido-efectivo').hide();
        $('.display-codigo-operacion').show();
    }
    calculo_total();
});

var limpiar_pagos_a = function(){
    $('#pago_efe').val('0.00');
    $('#pago_tar').val('0.00');
    $('#pago_yape').val('0.00');
    $('#pago_plin').val('0.00');
    $('#pago_tran').val('0.00');
    $('#vuelto').text('0.00');
}

var limpiar_pagos_b = function(){
    $('#pago_efe').val('0.00');
    $('#pago_tar').val('0.00');
    $('#pago_yape').val('0.00');
    $('#pago_plin').val('0.00');
    $('#pago_tran').val('0.00');
    $('#vuelto').text('0.00');
    $('.display-pago-efectivo').show();
    $('.display-pago-default').show();
    $('.display-pago-tarjeta').hide();
    $('#tipo_pago').selectpicker('val',1);
    $('.display-pago-rapido-efectivo').show();
    $('.mensaje-pago').hide();
    $('.display-codigo-operacion').hide();
}

var limpiar_datos_add = function(){
    $('#pago_efe').val('0.00');
    $('#pago_tar').val('0.00');
    $('#pago_yape').val('0.00');
    $('#pago_plin').val('0.00');
    $('#pago_tran').val('0.00');
    $('#vuelto').text('0.00');
    $('.descuento').val('0.00');
    $('.descuento').text('0.00');
    $('.comision_delivery').val('0.00');
    $('.comision_delivery').text('0.00');
    $('.comision_tarjeta').val('0.00');
    $('.comision_tarjeta').text('0.00');
    $('.display-pago-efectivo').show();
    $('.display-pago-default').show();
    $('.display-pago-tarjeta').hide();
    $('#descuento_tipo_hidden').val('');
    $('#descuento_monto_hidden').val('0.00');
    $('#descuento_motivo_hidden').val('');
    $('#tipo_pago').selectpicker('val',1);
    $('.mensaje-pago').hide();
    $('.display-codigo-operacion').hide();
    $('.display-pago-rapido-efectivo').show();
}
$('.btn-cancel-facturar-2').on('click', function(){
    limpiar_datos_add();
    calculo_total();
    $("#pago_efe").val(formatNumber($('#total_pedido').val()));
    $(".opc-01").text(formatNumber($('#total_pedido').val()));
})

$(".ent input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9]')!=0 && keycode!=8){
        return false;
    }
});

$(".dec input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9.]')!=0 && keycode!=8){
        return false;
    }
});

var opcion_pago_efectivo = function(monto){
    $("#pago_efe").val(formatNumber(monto));
    calculo_efectivo();
}

$(".opc-01").click(function() {
    $("#pago_efe").val($('.totalPedido').val());
    calculo_efectivo();
});

var stock_pollo = function(){
    $('#lista_productos').empty();
    $("#modal-stock-pollo").modal('show');
    $.ajax({
        type: "POST",
        url: $('#url').val()+"tablero/tablero_datos",
        data: {
            id_apc: $('#apcid').val()
        },
        dataType: "json",
        success: function(item){
            $('.pollos-stock').text(item['Pollostock'].total);
            var pollos_vendidos = 0;
            $.each(item['Pollosvendidos'], function(i, dato) { 
                pollos_vendidos += parseFloat(dato.cantidad) * parseFloat(dato.cant);
            });
            $('.pollos-vendidos').text(parseFloat(pollos_vendidos));

            if(item['Pollosvendidos'].length > 0){
                var cont = 1;
                $.each(item['Pollosvendidos'], function(i, datu) {
                    var importePlatos = parseFloat(datu.cantidad) * parseFloat(datu.precio);
                    var porcentajePlatos = (parseFloat(importePlatos) * 100 ) / parseFloat(item['Ventas'].total);
                    $('#lista_productos')
                      .append(
                        $('<tr/>')
                        .append(
                            $('<td/>')
                            .html('<h6>'+datu.pro_nom+' - '+datu.pro_pre+'</h6><small class="text-muted">POLLO A LA BRASA</small>')
                        )
                        .append(
                            $('<td class="text-right" />')
                            .html(formatNumber(datu.cantidad))
                        )
                    )
                });

            } else {
                $('#lista_productos').html("<tr style='border-left: 2px solid #fff !important; background: #fff !important;'><td colspan='2'><div class='text-center'><h4 class='m-t-40' style='color: #d3d3d3;'><i class='mdi mdi-receipt display-3 m-t-40 m-b-10'></i><br>Realice una venta<br><small>No se encontraron datos</small></h4></div></td></tr>");
            }
        }
    });
}

$('.venta_por_consumo').on('click', function(event){
    if( $(this).is(':checked') ) {
        $('#venta_por_consumo').val('1');
        $('.lista-producto-facturar').hide();
        $('.lista-venta-por-consumo').show();
        $('#venta_por_consumo_concepto').focus();
        $('#venta_por_consumo_concepto').select();
    } else {
        $('#venta_por_consumo').val('0');
        $('.lista-producto-facturar').show();
        $('.lista-venta-por-consumo').hide();
    }
});

var listarComandas = function(){
    $('#list-comandas').empty();
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'venta/listarComandas',
        data: {
            id_pedido: $('#codped').val()
        },
        success: function (data) {
            if (data.length != 0) {
                let comandasList = ''
                $.each(data, function (i, v){

                    comandasList +='<a class="dropdown-item"  onclick="reimpresion_comanda(\''+v.id_key+'\');" href="javascript:void(0)" >'+v.fecha_pedido+'</a>'


                    // comandasList +='<a class="dropdown-item"  href="'+$('#url').val()+'venta/impresion_comanda/'+v.id_pedido+':'+v.id_key+'" target="_blank">'+v.fecha_pedido+'</a>'
                    // comandasList +='<a class="dropdown-item"  onclick="printPdf(\''+urlticketreparto+'\',true);" href="javascript:void(0)" href="'+$('#url').val()+'venta/impresion_comanda/'+v.id_pedido+':'+v.id_key+'" target="_blank">'+v.fecha_pedido+'</a>'
                })
                $('#list-comandas').html(comandasList)
            }else{
                $('#list-comandas').html('<div class="justify-center" style="height: 100%;"><div class="text-center"><h4 style="color: #d3d3d3;">No existe Regustro</h4></div></div>');
            }
        }
    });
};

$('#tipo_pago').change( function() { 
    var x = document.getElementById("tipo_pago").selectedIndex;
    value = document.getElementsByTagName("option")[x].label;
    if(value != 2){
        $('.btn-tipo-doc-3').removeClass('disabled');
        $( "input[name=tipo_doc][value='3']" ).prop( "disabled", false );
        $( "input[name=tipo_doc][value='3']" ).prop( "readonly", false );
    }else{
        $('.btn-tipo-doc-3').removeClass('active');
        $('.btn-tipo-doc-3').addClass('disabled');
        $( "input[name=tipo_doc][value='3']" ).prop( "disabled", true );
        $( "input[name=tipo_doc][value='3']" ).prop( "checked", false );
    }
});


var preciolist = function(cod_add){
    if ($(".preciolist_"+cod_add).attr('disabled')=='disabled') {
        $(".preciolist_"+cod_add).removeAttr('disabled');
    }else{
        $(".preciolist_"+cod_add).attr('disabled', true);
    }
};
