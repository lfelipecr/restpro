var moneda = $("#moneda").val();
$(function() {
    moment.locale('es');
    listar();
    stock_pollo();
    cajas_aperturadas();
    $('#form-apertura').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {
        }
    }).on('success.form.fv', function(e) {
        // Prevent form submission
        e.preventDefault();
        var $form = $(e.target),
        fv = $form.data('formValidation');

        var parametros = {
            "id_apc" : '',
            "id_caja" : $('#id_caja').val(),
            "id_turno" : $('#id_turno').val(),
            "monto_aper" : $('#monto_aper').val()
        };

        var html_confirm = '<div>Se creará una apertura de caja con los siguientes datos:</div>\
            <br><div style="width: 100% !important; float: none !important;">\
            <table class="table m-b-0">\
            <tr><td class="text-left">Caja: </td><td class="text-right">'+$('select[name="id_caja"] option:selected').text()+'</td></tr>\
            <tr><td class="text-left">Turno: </td><td class="text-right">'+$('select[name="id_turno"] option:selected').text()+'</td></tr>\
            <tr><td class="text-left">Monto: </td><td class="text-right">'+moneda+' '+formatNumber($('#monto_aper').val())+'</td></tr>\
            </table>\
            </div><br>\
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
                    url: $('#url').val()+'caja/apercie_crud',
                    type: 'POST',
                    data: parametros,
                    dataType: 'json'
                 })
                 .done(function(response){
                    if(response == 1){
                    Swal.fire({
                        title: 'Proceso Terminado',
                        text: 'Datos registrados correctamente',
                        icon: 'success',
                        confirmButtonColor: "#34d16e",   
                        confirmButtonText: "Aceptar"
                    });
                    $("#modal-apertura").modal('hide');
                    }else{
                        Swal.fire({
                            title: 'Proceso No Culminado',
                            text: 'Datos duplicados',
                            icon: 'error',
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar"
                        });
                    }
                    listar();
                    cajas_aperturadas();
                 })
                 .fail(function(){
                    Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
                 });
              });
            },
            allowOutsideClick: false              
        });
    });

    $('#form-cierre').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {
        }
    }).on('success.form.fv', function(e) {
        // Prevent form submission
        e.preventDefault();
        var $form = $(e.target);
        var fv = $form.data('formValidation');
        cierre();
    });

    $('#caja').addClass("active");
    $('#c-apc').addClass("active");
});

var listar = function(){
    $.ajax({ 
        url:   $('#url').val()+'caja/apercie_list',
        type:  'POST',
        dataType: 'json',
        success: function(data) {
            if(data == false){
                $('.display-apertura').css('display','block');
                $('.display-cierre').css('display','none');
            } else {
                $('.display-apertura').css('display','none');
                $('.display-cierre').css('display','block');
                $('#id_apc').val(data.id_apc);
                $('.fecha-apertura').text(moment(data.fecha_aper).format('[Abierto el día ]dddd, D [de] MMMM [a las] h:mm:ss a'));
                //$('.fecha-apertura').text(moment(data.fecha_aper).format('DD-MM-Y')+' | '+moment(data.fecha_aper).format('h:mm A'));
                monto_sistema(data.id_apc);
                mesa_list();
                delivery_list_a();
                mostrador_list_a();
            }
        }
    });
}

var delivery_list_a = function(){
     $.ajax({
        url: $('#url').val()+'venta/delivery_list',
        type: 'POST',
        data: {estado: 'a'},
        dataType: 'json'
     })
     .done(function(response){
            $('#count_pedidos').val(response.data.length);
     })
     .fail(function(){
        Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
     });    
}

var mostrador_list_a = function(){  //          "url": $('#url').val()+"venta/mostrador_list",
     $.ajax({
        url: $('#url').val()+'venta/mostrador_list',
        type: 'POST',
        data: {estado: 'a'},
        dataType: 'json'
     })
     .done(function(response){
            $('#count_mostrador').val(response.data.length);
     })
     .fail(function(){
        Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
     });
}

var mesa_list = function(cod){
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'venta/mesa_list',
        success: function (item) {
            var count_ocupadas = 0
            $.each(item['mesa'], function(i, mesa) {
                z = (mesa.estado == 'i') ? count_ocupadas++ : 'NINGUNO';
            });
            $('#count_ocupadas').val(count_ocupadas);
        }
    });
}

var monto_sistema = function(id_apc){
    $.ajax({
        //async: false,
        data: { id_apc : id_apc },
        type:  'POST',
        dataType: 'json',
        url:   $('#url').val()+'caja/apercie_montosist',
        success: function(data) {
            if (data.total != '') {
                var montoSist = (parseFloat(data.Apertura.monto_aper) + parseFloat(data.total) - parseFloat(data.pago_tar) + parseFloat(data.Ingresos.total) - parseFloat(data.EgresosA.total) - parseFloat(data.EgresosB.total)).toFixed(2);
                $("#monto_sistema").val(montoSist);
            }
        }
    });
}

var cierre = function(){

    var parametros = {
        "id_apc" : $('#id_apc').val(),
        "monto_cierre" : $('#monto_cierre').val(),
        "monto_sistema" : $('#monto_sistema').val(),
        "stock_pollo" : $('#stock_pollo').val()
    };
    if ($('#count_ocupadas').val() != 0) {
        var color_font_m = "red"
    }else{
        var color_font_m = "black"
    }
    if ($('#count_pedidos').val() != 0) {
        var color_font_p = "red"
    }else{
        var color_font_p = "black"
    }
    if ($('#count_mostrador').val() != 0) {
        var color_font_mo = "red"
    }else{
        var color_font_mo = "black"
    }
    
    var html_confirm = '<div>Se cerrará el turno de caja con los siguientes datos:</div>\
        <br><div style="width: 100% !important; float: none !important;">\
        <table class="table">\
        <tr><td class="text-left" style="color: '+color_font_m+'; font-weight: bold">Mesas Abiertas: </td><td class="text-right" style="color: '+color_font_m+'; font-weight: bold; font-size: 18px">'+$('#count_ocupadas').val()+'</td></tr>\
        <tr><td class="text-left" style="color: '+color_font_mo+'; font-weight: bold">Mostrador abiertos: </td><td class="text-right" style="color: '+color_font_mo+'; font-weight: bold; font-size: 18px">'+$('#count_mostrador').val()+'</td></tr>\
        <tr><td class="text-left" style="color: '+color_font_p+'; font-weight: bold">Delivery abiertos: </td><td class="text-right" style="color: '+color_font_p+'; font-weight: bold; font-size: 18px">'+$('#count_pedidos').val()+'</td></tr>\
        <tr><td class="text-left">Importe: </td><td class="text-right">'+moneda+' '+formatNumber($('#monto_cierre').val())+'</td></tr>\
        </table>\
        </div>\
        <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';

    var html_print = '<div>El turno de caja ha sido cerrada.<br>Puede imprimir el arqueo de caja, para obtener el detalle de sus procesos.</div>\
        <br><div class="text-center"><a href="'+$("#url").val()+'informe/finanza_arq_imp/'+$('#id_apc').val()+'" target="_blank"><i class="fas fa-print font-20 text-primary"></i><br>Arqueo de caja</a></div><br>\
        ';
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
                url: $('#url').val()+'caja/apercie_crud',
                type: 'POST',
                data: parametros,
                dataType: 'json'
             })
             .done(function(response){
 
                var html_print = '<div>El turno de caja ha sido cerrada.<br>\
                Puede imprimir el arqueo de caja, para obtener el detalle de sus procesos.</div>\
                <div style="margin-top: 20px">\
                    <div style="width:49.5%; display: inline-block; float:left">\
                        <a href="'+$("#url").val()+'informe/finanza_arq_imp/'+$('#id_apc').val()+'" target="_blank">\
                        <i class="fas fa-print font-20 text-primary"></i>\
                        <br>Imprimir<br>Arqueo de caja</a></div><br>\
                    </div>\
                    <div style="width:49.5%; display: inline-block; float:right; margin-top: -20px">\
                        <a href="'+$("#url").val()+'informe/finanza_arq_imp_prod/'+$('#id_apc').val()+'" target="_blank">\
                        <i class="fas fa-list font-20 text-primary"></i>\
                        <br>Imprimir<br>Productos Vendidos</a></div><br><br><br>\
                    </div><div style="clear: both"></div>\
                    <div style="width:100%; display: inline-block; float:right; margin-top: -10px">\
                        <a href="'+$("#url").val()+'informe/finanza_arq_imp_gastos/'+$('#id_apc').val()+'" target="_blank">\
                        <i class="fas fa-download font-20 text-primary"></i>\
                        <br>Imprimir<br>Gastos</a></div><br><br><br>\
                    </div><div style="clear: both"></div>\
                    <div style="width:100%; display: inline-block; float:center; margin-top: -10px">\
                        <button type="button" class="btn btn-primary" onclick="pregunta_cierre()">Cerrar</button><span >\
                        <br>\
                    </div>\
                    <div style="clear:both"></div>\
                </div>\
                ';
                Swal.fire({
                    title: 'Proceso Terminado',
                    html: html_print,
                    icon: 'success',
                    showCancelButton: false,
                    showConfirmButton: false,
                    allowOutsideClick: false
                    // confirmButtonColor: "#34d16e",   
                    // confirmButtonText: "Aceptar"
                });
                $("#modal-cierre").modal('hide');
                listar();
                cajas_aperturadas();
             })
             .fail(function(){
                Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
             });
          });
        },
        allowOutsideClick: false              
    });
}

$('.btn-aceptar-apertura').on('submit', function() {
    $('.s').addClass('focused');
});

var stock_pollo = function(){
    $.ajax({
        type:  'POST',
        dataType: 'json',
        url:   $('#url').val()+'caja/stock_pollo',
        success: function(data) {
            if (data.total != '') {
                $("#stock_pollo").val(data.total);
            }
        }
    }); 
}

var pregunta_cierre = function(){

   if (confirm("Desea Salir del proceso de impresión") == true) {
        Swal.close()
    }

}

/* Accion desde la fecha */
/*
$('#fecha_cierre').on('change', function(e) { 
    $.ajax({
        data: { id_apc : $("#id_apc").val() },
        type:  'POST',
        dataType: 'json',
        url:   $('#url').val()+'caja/apercie_montosist',
        success: function(data) {
            if (data.total != '') {
                // Se agrego parseFloat(data.pago_tar) para obtener monto de cierre en efectivo
                var montoSist = (parseFloat(data.Apertura.monto_aper) - parseFloat(data.pago_tar) + parseFloat(data.total) + parseFloat(data.Ingresos.total) - parseFloat(data.EgresosA.total) - parseFloat(data.EgresosB.total)).toFixed(2);
                $("#monto_sistema").val(montoSist);
            }
        }
    }); 
});
*/

var cajas_aperturadas = function(){
   
    $('#lista_caja').empty();
    
    $.ajax({
        type: "POST",
        url: $('#url').val()+'caja/apercie_listcaja',
        dataType: "json",
        success: function(item){
            var moneda = $("#moneda").val();
            if(item.length > 0 ){
                $.each(item, function(i, datu) {
                    $('#lista_caja')
                      .append(
                        $('<tr/>')
                        .append(
                            $('<td/>')
                            .html(''+datu.desc_caja+'')
                        )
                        .append(
                            $('<td/>')
                            .html(datu.desc_per)
                        )
                        .append(
                            $('<td class="text-right"/>')
                            .html(moneda+' '+formatNumber(datu.monto_aper))
                        )
                    )
                });
            } else {
                $('#lista_caja').html("<tr style='border-left: 2px solid #fff !important; background: #fff !important;'><td colspan='5'><div class='text-center'><h4 class='m-t-40' style='color: #d3d3d3;'><i class='fas fa-filter display-3 m-t-10 m-b-10'></i><br>Aperture una caja<br><small>No se encontraron datos <br></small></h4></div></td></tr>");
            }
        }
      });
    }