$(function() {
    $('#config').addClass("active");
    DatosGrles();
    comboAreaProd();

    $('#start').bootstrapMaterialDatePicker({
        format: 'LT',
        date: false,
        lang: 'es-do',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('#end').bootstrapMaterialDatePicker({
        format: 'LT',
        date: false,
        lang: 'es-do',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });
    $('#horario').val('0');
    $('#form').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {
            dni: {
                validators: {
                    stringLength: {
                        message: 'El '+$(".c-dni").text()+' debe tener '+$("#dni").attr("maxlength")+' digitos'
                    }
                }
            }
        }
    }).on('success.form.fv', function(e) {
        // Prevent form submission
        e.preventDefault();
        var $form = $(e.target),
        fv = $form.data('formValidation');
        var form = $(this);

        var parametros = new FormData($('#form')[0]);

        $.ajax({
            type: 'POST',
            dataType: 'JSON',
            data: parametros,
            url: $('#url').val()+'ajuste/usuario_crud',
            contentType: false,
            processData: false,
        })
        .done(function(response){
            if(response == 1 || response == 2){
                if(response==1){
                    var text = 'registrados';
                } else if(response == 2){
                    var text = 'actualizados';
                }
                var html_terminado = '<div>Datos '+text+' correctamente</div>\
                    <br><a href="'+$("#url").val()+'ajuste/usuario" class="btn btn-success">Aceptar</button>'
                Swal.fire({
                    title: 'Proceso Terminado',
                    html: html_terminado,
                    icon: 'success',
                    showConfirmButton: false
                });
            } else{
                Swal.fire({
                    title: 'Proceso No Culminado',
                    html: 'Datos duplicados',
                    icon: 'error',
                    showConfirmButton: true
                });
            }
        })
        .fail(function(){
            Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
        });
    });
});

var DatosGrles = function(){
    $('#id_rol').selectpicker('refresh');
    $('#id_rol').selectpicker('val', $('#cod_rol').val());
    $('#id_areap').selectpicker('refresh');
    $('#id_areap').selectpicker('val', $('#cod_area').val());
}

/* Combo area de produccion */
var comboAreaProd = function(){
    if($("#id_rol").selectpicker('val') == 4){
        $('#col-areap').css('display','block');
        $("#id_areap").prop('disabled', false);
    }else{
        $('#col-areap').css('display','none');
        $("#id_areap").prop('disabled', true);
    }
}

/* Combinacion del combo rol - area produccion */
$('#id_rol').change( function() {
    if($("#id_rol").selectpicker('val') == 4){
        $('#col-areap').css('display','block');
        $("#id_areap").prop('disabled', false);
        $('#form').formValidation('revalidateField', 'id_areap');

    }else if(($("#id_rol").selectpicker('val') == '3') || ($("#id_rol").selectpicker('val') == '5')){
        console.log('si');
        $('#horario_s').css('display','block');
    }else{
        $('#col-areap').css('display','none');
        $('#horario_s').css('display','none');
        $("#id_areap").val('').selectpicker('refresh');
        $("#id_areap").prop('disabled', true);
    }

});

$("#dni").keyup(function(event) {
    var that = this,
    value = $(this).val();
    if (value.length == $("#dni").attr("maxlength")) {
        $.getJSON($('#url').val()+"api/dni/"+$("#dni").val(), {
            format: "json"
        })
        .done(function(data) {
            $("#dni").val(data.dni);
            $("#nombres").val(data.nombres);
            $("#ape_paterno").val(data.apellidoPaterno);
            $("#ape_materno").val(data.apellidoMaterno);
            $('#form').formValidation('revalidateField', 'nombres');
            $('#form').formValidation('revalidateField', 'ape_paterno');
            $('#form').formValidation('revalidateField', 'ape_materno');
        });
    } else if($("#dni").val() == "") {
        $('#dni').val("");
        $('#nombres').val("");
        $('#ape_paterno').val("");
        $('#ape_materno').val("");
        $('#form').formValidation('resetForm', true);
    }
});

// $('#tipo_pago').change( function() { 
//     var x = document.getElementById("tipo_pago").selectedIndex;
//     value = document.getElementsByTagName("option")[x].label;
//     if(value == 1){
//         limpiar_pagos_a();
//         $('.mensaje-pago').hide();
//         $('.display-pago-efectivo').show();

//     }
// });

/* Opcion egreso de caja */
$('.horario').on('click', function(event){
    if( $(this).is(':checked') ) {
        $('#horario').val('1');
        $('.display_horario').css('display','block');
        $("#start").prop('disabled', false);
        $("#end").prop('disabled', false);
    } else {
        $('#horario').val('0');
        $('.display_horario').css('display','none');
        $("#start").prop('disabled', true);
        $("#end").prop('disabled', true);
    }
});