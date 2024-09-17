$(function() {
    $('#fecha').bootstrapMaterialDatePicker({
        time: false,
        format: 'DD-MM-YYYY',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

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
            url: $('#url').val()+'consulta/buscar',
            type: 'POST',
            data: parametros,
            dataType: 'json',
            contentType: false,
            processData: false,
         })
         .done(function(response){
            console.log(response)
            if (response != false) {

                $(".resultado").css('display', 'block');
                $(".respuesta").css('display', 'none');

                $('tbody').html('<tr>'
                    +'<td>'+response.cliente+'</td> '
                    +' <td>'+response.comprobante+'</td> '
                    +'<td class="text-right">'+response.total+'</td> '
                    +'<td class=""><center><a href="'+response.url_xml+'"  target="_blank"><img src="public/images/xml_cpe.svg" style="max-width: 30px;"/></a></center></td>'
                    +'<td class=""><center><a href="'+response.url_cdr+'"  target="_blank"><img src="public/images/xml_cdr.svg" style="max-width: 30px;"/></a></center></td>'
                    +'<td class=""><center><a href="'+response.url_pdf+'"  target="_blank"><img src="public/images/pdf.svg" style="max-width: 30px;"/></a></center></td>'
                    +'<td class=""><center><a href="#" onclick="send_wsp('+response.id_venta+');" ><img src="public/images/whatsapp.svg" style="max-width: 30px;"/></a></center></td>'
                    +'</tr>');
            } else {

                $(".resultado").css('display', 'none');
                $('.respuesta').text('No se encontró resultados. Verifique los datos ingresados');
            }
        })
        .fail(function(){
            $('tbody').append('no se encontro resultados');
        });
    });


});

var send_wsp = function(id_venta){
    var html_confirm = '<div>Se procederá a enviar el siguiente documento:</div><div><strong>'+$('#serie').val()+'-'+$('#numero').val()+'</strong></div><br>\
    Ingrese número del cliente <br><code>ejemplo: 51965989993</code></div><br>\
    <form><input class="form-control text-center w-100" type="text" id="num_cliente" value="51" autocomplete="off"/></form><br>\
    <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
    window.setTimeout(function(){
        var obj = $("#num_cliente"),
        val = obj.val();
        obj.focus().val("").val(val);
        obj.scrollTop(obj[0].scrollHeight);
    }, 300);

    Swal.fire({
        title: 'Debes Confirmar!',
        html: html_confirm,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true,
        preConfirm: function() {
          return new Promise(function(resolve) {
            
            var mensajewa =$("#mesaje_waz").val();
            var num_cliente = $("#num_cliente").val();
            var Urls = $("#url").val()+'comprobante/ticket/'+btoa(id_venta);

            if ($('#num_cliente').val().length!=11 && $('#num_cliente').val().length=='') {
                Swal.fire({
                    title: 'Proceso No Culminado',
                    text: 'Debe ingresar número correctamente',
                    icon: 'danger',
                    confirmButtonColor: "#34d16e",   
                    confirmButtonText: "OK"
                });
                return false;
            }
                if ($('#api_wsp').val()==1) {
                     $.ajax({
                        url: $('#url').val()+'whatsapp/send_wsp_invoice',
                        type: 'POST',
                        data: {
                            num_cliente : $('#num_cliente').val(),
                            id_venta : id_venta
                        },
                        dataType: 'json'
                     })
                     .done(function(response){
                        if(response.status == true){
                            Swal.fire({
                                title: 'Proceso Terminado',
                                html: 'Whatsapp enviado correctamente <br><br> <strong>Respuesta server: </strong>'+response.msg+'',
                                icon: 'success',
                                confirmButtonColor: "#34d16e",   
                                confirmButtonText: "OK"
                            });
                        }else{
                            Swal.fire({
                                title: 'Proceso No Culminado',
                                html: ''+response.msg+'<br>'+response.errors ? response.errors : ''+'',
                                icon: 'error',
                                confirmButtonColor: "#34d16e",   
                                confirmButtonText: "OK"
                            });
                        }
                     })
                     .fail(function(error){
                        Swal.fire('Oops...', 'Error: No se pudo enviar', 'error');
                     });
                }else{
                    var meg_com = mensajewa+' '+Urls;
                    Swal.fire({
                        title: 'Proceso Terminado',
                        html: 'Whatsapp enviado correctamente ',
                        icon: 'success',
                        confirmButtonColor: "#34d16e",   
                        confirmButtonText: "OK"
                    });
                    window.open('https://wa.me/'+num_cliente+'?text='+meg_com+'', '_blank');
                }
          });
        },
        allowOutsideClick: false              
    });
}
