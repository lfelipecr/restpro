$(function() {
    var elems = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));
    $('.js-switch').each(function() {
        new Switchery($(this)[0], $(this).data());
    });
    obtenerDatos();
    $('#config').addClass("active");
    $('#form').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {
        }
    }).on('success.form.fv', function(e) {
        // Prevent form submission
        e.preventDefault();
        var $form = $(e.target),
        fv = $form.data('formValidation');

        var parametros = new FormData($('#form')[0]);

        $.ajax({
            url: $('#url').val()+'ajuste/datosistema_crud',
            type: 'POST',
            data: parametros,
            dataType: 'json',
            contentType: false,
            processData: false,
         })
         .done(function(response){
            var html_terminado = '<div>Datos actualizados correctamente</div>\
                <br><a href="'+$('#url').val()+'ajuste/sistema" class="btn btn-success">Aceptar</button>'
            Swal.fire({
                title: 'Proceso Terminado',
                html: html_terminado,
                icon: 'success',
                showConfirmButton: false
            });
            obtenerDatos();
        })
        .fail(function(){
            swal('Oops...', 'Problemas con la conexión a internet!', 'error');
        });
    });
});

var obtenerDatos = function(){
    $.ajax({
        type: "POST",
        url: $('#url').val()+"ajuste/datosistema_data",
        dataType: "json",
        success: function(item){
            $('#zona_hora').val(item.zona_hora);
            $('#trib_acr').val(item.trib_acr);
            $('#trib_car').val(item.trib_car);
            $('#di_acr').val(item.di_acr);
            $('#di_car').val(item.di_car);            
            $('#imp_acr').val(item.imp_acr);
            $('#imp_val').val(item.imp_val);
            $('#mon_acr').val(item.mon_acr);
            $('#mon_val').val(item.mon_val);           
            $('#pc_name').val(item.pc_name);           
            $('#pc_ip').val(item.pc_ip);   
            $('#print_com_hidden').val(item.print_com);   
            $('#print_pre_hidden').val(item.print_pre);
            $('#print_cpe_hidden').val(item.print_cpe);
            $('#cod_seg').val(item.cod_seg); 
            $('#imp_bol').val(item.imp_bol); 
            $('#imp_val_bol').val(item.imp_val_bol); 
            $('#opc_01_hidden').val(item.opc_01);
            $('#sep_items_hidden').val(item.sep_items);
            $('#verpdf_hidden').val(item.verpdf);
            $('#nota_ind_hidden').val(item.nota_ind);
            $('#mostrarimagen_hidden').val(item.mostrarimagen);
            $('#envios_auto_hidden').val(item.envios_auto);
            $('#precio_comanda_hidden').val(item.precio_comanda);
            $('#direccion_comanda_hidden').val(item.direccion_comanda);
            $('#pedido_comanda_hidden').val(item.pedido_comanda);
            $('#multiples_precios_hidden').val(item.multiples_precios);
            if(item.print_com == '1'){$('#print_com').prop('checked', true)};
            if(item.print_pre == '1'){$('#print_pre').prop('checked', true)};
            if(item.print_cpe == '1'){$('#print_cpe').prop('checked', true)};
            if(item.opc_01 == '1'){$('#opc_01').prop('checked', true)};
            if(item.sep_items == '1'){$('#sep_items').prop('checked', true)};
            if(item.verpdf == '1'){$('#verpdf').prop('checked', true)};
            if(item.nota_ind == '1'){$('#nota_ind').prop('checked', true)};
            if(item.mostrarimagen == '1'){$('#mostrarimagen').prop('checked', true)};
            if(item.envios_auto == '1'){$('#envios_auto').prop('checked', true)};
            if(item.precio_comanda == '1'){$('#precio_comanda').prop('checked', true)};
            if(item.direccion_comanda == '1'){$('#direccion_comanda').prop('checked', true)};
            if(item.pedido_comanda == '1'){$('#pedido_comanda').prop('checked', true)};
            if(item.multiples_precios == '1'){$('#multiples_precios').prop('checked', true)};
        }
    });
}

var guardarIcono = function(id_acceso){
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'ajuste/guardaricono',
        data: {
            id_acceso: id_acceso,
            icono    : $('#icono_'+id_acceso+'').val(),
            color    : $('#color_'+id_acceso+'').val(),
            titulo    : $('#titulo_'+id_acceso+'').val(),
            url      : $('#url_'+id_acceso+'').val()
        },
        success: function (cod) {
            console.log(cod)
            Swal.fire({   
                title:'Proceso Terminado',   
                text: 'Datos registrados correctamente',
                icon: "success", 
                confirmButtonColor: "#34d16e",   
                confirmButtonText: "Aceptar",
                allowOutsideClick: false,
                showCancelButton: false,
                showConfirmButton: true
            }, function() {
                return false
            });
            // obtenerDatos();
        },
        error: function(jqXHR, textStatus, errorThrown){
            console.log(errorThrown + ' ' + textStatus);
        }   
    });
}

$('#nota_ind').on('change', function(event){
    if($(this).prop('checked')){
        $('#nota_ind_hidden').val('1');
    }else{
        $('#nota_ind_hidden').val('0');
    }
});

$('#mostrarimagen').on('change', function(event){
    if($(this).prop('checked')){
        $('#mostrarimagen_hidden').val('1');
    }else{
        $('#mostrarimagen_hidden').val('0');
    }
});

$('#envios_auto').on('change', function(event){
    if($(this).prop('checked')){
        $('#envios_auto_hidden').val('1');
    }else{
        $('#envios_auto_hidden').val('0');
    }
});

$('#precio_comanda').on('change', function(event){
    if($(this).prop('checked')){
        $('#precio_comanda_hidden').val('1');
    }else{
        $('#precio_comanda_hidden').val('0');
    }
});

$('#direccion_comanda').on('change', function(event){
    if($(this).prop('checked')){
        $('#direccion_comanda_hidden').val('1');
    }else{
        $('#direccion_comanda_hidden').val('0');
    }
});

$('#pedido_comanda').on('change', function(event){
    if($(this).prop('checked')){
        $('#pedido_comanda_hidden').val('1');
    }else{
        $('#pedido_comanda_hidden').val('0');
    }
});

$('#multiples_precios').on('change', function(event){
    if($(this).prop('checked')){
        $('#multiples_precios_hidden').val('1');
    }else{
        $('#multiples_precios_hidden').val('0');
    }
});

$('#print_com').on('change', function(event){
    if($(this).prop('checked')){
        $('#print_com_hidden').val('1');
    }else{
        $('#print_com_hidden').val('0');
    }
});

$('#print_pre').on('change', function(event){
    if($(this).prop('checked')){
        $('#print_pre_hidden').val('1');
    }else{
        $('#print_pre_hidden').val('0');
    }
});
$('#print_cpe').on('change', function(event){
    if($(this).prop('checked')){
        $('#print_cpe_hidden').val('1');
    }else{
        $('#print_cpe_hidden').val('0');
    }
});
$('#opc_01').on('change', function(event){
    if($(this).prop('checked')){
        $('#opc_01_hidden').val('1');
    }else{
        $('#opc_01_hidden').val('0');
    }
});
$('#sep_items').on('change', function(event){
    if($(this).prop('checked')){
        $('#sep_items_hidden').val('1');
    }else{
        $('#sep_items_hidden').val('0');
    }
});
$('#verpdf').on('change', function(event){
    if($(this).prop('checked')){
        $('#verpdf_hidden').val('1');
    }else{
        $('#verpdf_hidden').val('0');
    }
});