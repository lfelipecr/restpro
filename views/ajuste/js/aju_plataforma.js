$(function() {
    moment.locale('es');
    obtenerDatos();
    $('#created_at').bootstrapMaterialDatePicker({
        time: false,
        format: 'DD-MM-YYYY',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });
    $('#form-plataforma').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {
        }
    }).on('success.form.fv', function(e) {
        // Prevent form submission
        e.preventDefault();
        var $form = $(e.target),
        fv = $form.data('formValidation');

        var parametros = new FormData($('#form-plataforma')[0]);

        if ($('#api_wsp_hidden').val()=='1' && $('#wsp_token').val()=='') {
            Swal.fire({
                title: 'Falta token API Whatsapp',
                text: 'Si activa el envio por api debe colocar un token válido',
                icon: 'warning',
                showConfirmButton: true,
            });
            return false;
        }

        if ($('#api_wsp_hidden').val()=='1' && $('#wsp_number').val().length != 11) {
            Swal.fire({
                title: 'Falta token API Whadddtsapp',
                text: 'Si activa el envio por api debe colocar un token válido',
                icon: 'warning',
                showConfirmButton: true,
            });
            return false;
        }

        $.ajax({
            url: $('#url').val()+'ajuste/datosplataforma_crud',
            type: 'POST',
            data: parametros,
            dataType: 'json',
            contentType: false,
            processData: false,
         })
         .done(function(response){
            var html_terminado = '<div>Datos actualizados correctamente</div>\
                <br><a href="'+$('#url').val()+'ajuste" class="btn btn-success">Aceptar</button>'
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

$('.btn-plataforma').click( function() {
    $('#modal-plataforma').modal('show');
});


var bloc_desbloc = function(){
    if($('#bloqueo_id').val() == '0'){
        var html_confirm = '<div>Se procederá a desbloquear la plataforma</div><br>\
        <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
        var bloqueo_id = 1;
    }else{
        var html_confirm = '<div>Se procederá a bloquear la plataforma</div><br>\
        <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
        var bloqueo_id = 0;
    }
    // console.log(bloqueo_id);
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
            console.log(bloqueo_id);
            $.ajax({
                url: $('#url').val()+'ajuste/bloqueo',
                type: 'POST',
                data: {
                    // $ver = (Session::get('rol') == 1) ? '' :  header('location: ' . URL . 'err/danger'); 

                    tipo_bloqueo  : bloqueo_id,
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

var obtenerDatos = function(){
    $.ajax({
        type: "POST",
        url: $('#url').val()+"ajuste/datosplataforma_data",
        dataType: "json",
        success: function(item){
            console.log(item);
            $('#created_at').val(item.created_at);
            $('#limit_users').val(item.limit_users);
            $('#limit_documents').val(item.limit_documents);
            $('#locked_users_hidden').val(item.locked_users);   
            $('#api_wsp_hidden').val(item.api_wsp);   
            $('#wsp_token').val(item.wsp_token);
            $('#wsp_number').val(item.wsp_number);
            $('#locked_documents_hidden').val(item.locked_documents);
            if(item.locked_users == '1'){$('#locked_users').prop('checked', true)};
            if(item.api_wsp == '1'){
                $('#api_wsp').prop('checked', true)
                $('.div_token_wsp').show()
            };
            if(item.locked_documents == '1'){$('#locked_documents').prop('checked', true)};
        }
    });
}
$('#locked_users').on('change', function(event){
    if($(this).prop('checked')){
        $('#locked_users_hidden').val('1');
    }else{
        $('#locked_users_hidden').val('0');
    }
});

$('#api_wsp').on('change', function(event){
    if($(this).prop('checked')){
        $('#api_wsp_hidden').val('1');
        $('.div_token_wsp').show();

    }else{
        $('#api_wsp_hidden').val('0');
        $('.div_token_wsp').hide();
    }
});

$('#locked_documents').on('change', function(event){
    if($(this).prop('checked')){
        $('#locked_documents_hidden').val('1');
    }else{
        $('#locked_documents_hidden').val('0');
    }
});