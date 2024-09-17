$(function() {
    $('#contable').addClass("active");
    moment.locale('es');
    // listar();

    $('#start').bootstrapMaterialDatePicker({
        time: false,
        format: 'DD-MM-YYYY',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('#end').bootstrapMaterialDatePicker({
        time: false,
        format: 'DD-MM-YYYY',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('.scroll_detalle').slimscroll({
        height: '100%'
    });
    var scroll_detalle = function () {
        var topOffset = 405;
        var height = ((window.innerHeight > 0) ? window.innerHeight : this.screen.height) - 1;
        height = height - topOffset;
        $(".scroll_detalle").css("height", (height) + "px");
    };
    $(window).ready(scroll_detalle);
    $(window).on("resize", scroll_detalle);

    /* BOTON DATATABLES */
    var org_buildButton = $.fn.DataTable.Buttons.prototype._buildButton;
    $.fn.DataTable.Buttons.prototype._buildButton = function(config, collectionButton) {
    var button = org_buildButton.apply(this, arguments);
    $(document).one('init.dt', function(e, settings, json) {
        if (config.container && $(config.container).length) {
           $(button.inserter[0]).detach().appendTo(config.container)
        }
    })    
    return button;
    }
    $("#generarvalidador").click(function(){ 
        ifecha = $("#start").val();
        ffecha = $("#end").val();
        tdoc = $("#tipo_doc").selectpicker('val');

        // alert(tdoc);
        listar();
        // $("#myForm").submit(); // Submit the form
    });



});

var listar = function(){

    var moneda = $("#moneda").val();
    ifecha = $("#start").val();
    ffecha = $("#end").val();
    desde  = $("#desde").val();
    hasta  = $("#hasta").val();
    tipoBusqueda_hidden  = $("#tipoBusqueda_hidden").val();
    tdoc   = $("#tipo_doc").selectpicker('val');

    var table = $('#table').DataTable({
        "destroy": true,
        "responsive": true,
        "dom": "tip",
        "bSort": true,
        "order": [[0,"desc"]],
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"contable/validador_list",
            "data": {
                ifecha   : ifecha,
                ffecha   : ffecha,
                desde    : desde,
                hasta    : hasta,
                tbusqueda: tipoBusqueda_hidden,
                tdoc     : tdoc
            }
        },
        "columns":[
            {"data":"fec_ven","render": function ( data, type, row ) {
                return '<i class="ti-calendar"></i> '+moment(data).format('DD-MM-Y')
                +'<br><span class="font-12"><i class="ti-time"></i> '+moment(data).format('h:mm A')+'</span>';
            }},
            {"data":"Cliente.nombre","render": function ( data, type, row ) {
                return '<div class="mayus">'+data+'</div>';
            }},
            {"data":null,"render": function ( data, type, row ) {
                if(data.desc_tipo == 1){
                    var tooltip = ' <i class="ti-info-alt text-warning font-10" data-original-title="Cortesia" data-toggle="tooltip" data-placement="top"></i>';
                } else if(data.desc_tipo == 3){
                    var tooltip = ' <i class="ti-info-alt text-warning font-10" data-original-title="Credito Personal: '+data.Personal.nombres+'" data-toggle="tooltip" data-placement="top"></i>';
                } else {
                    var tooltip = '';
                }
                return data.desc_td
                +'<br><span class="font-12">'+data.ser_doc+'-'+data.nro_doc+'</span>'+tooltip;
            }},
            {"data":null,"render": function ( data, type, row ) {
                console.log(data)
                if(data.estado == 'a' && data.enviado_sunat == '1'){
                    return '<span class="label label-primary">ENVIADO A SUNAT</span></a>';
                }else if(data.estado == 'i'){
                    return '<span class="label label-danger">ANULADO</span></a></div>';
                } else {
                    return '<span class="label label-warning">SIN ENVIAR</span></a></div>';
                }
            }},
            {"data":null,"render": function ( data, type, row ) {
                if(data.Estado_Sunat == '1'){
                    return '<span class="label label-success">ACEPTADO</span></a>';
                }else if(data.Estado_Sunat== '2'){
                    return '<span class="label label-danger">ANULADO</span></a></div>';
                } else {
                    return '<span class="label label-warning">NO EXISTE</span></a></div>';
                }
            }},
            {"data":null,"render": function ( data, type, row ) {
                var estadoSunat = ''
                if(data.Estado_Sunat == '1'){
                    estadoSunat = null
                }else if(data.Estado_Sunat== '2'){
                    estadoSunat = '11'
                } else {
                    estadoSunat = '0'
                }
                console.log(data)
                return '<span class="btn btn-sm btn-info" onclick="reenvio('+data.id_ven+',\''+data.ser_doc+'-'+data.nro_doc+'\',\''+estadoSunat+'\')"">REGULARIZAR</span>';
            }},
           
        ],
    });

};

var reenvio = function(cod_ven,doc, estado = null){
    console.log
    var text1 = 'El documento  N°: '+doc+' será modificado el estado <br>Actualizaremos los datos en el sistema!..';
    Swal.fire({
        title: 'Debes Confirmar!',
        html: text1,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true,
        preConfirm: function() {
          return new Promise(function(resolve) {
             $.ajax({
                url: $('#url').val()+'facturacion/reenvio',
                type: 'POST',
                data: {cod_ven: cod_ven, estado: estado},
                dataType: 'json'
             })
             .done(function(response){
                console.log(response)
                Swal.fire({
                    title: 'Proceso Terminado',
                    text: 'El documento  N°: '+doc+' a sido actualizado',
                    icon: 'success',
                    confirmButtonColor: "#34d16e",   
                    confirmButtonText: "OK"
                })
             })
             .fail(function(){
                Swal.fire('Oops...', 'Problemas cambiar estado!', 'error');
             });
          });
        },
        allowOutsideClick: false              
    });
    contadorSunatSinEnviar();
}

$(".numeracion").keyup(function(e) {
    $(this).val(String(parseInt($(this).val())).padStart(8, '0'));
});

$('#buscarNumeros').on('change', function(event){
    if($(this).prop('checked')){
        $('#tipoBusqueda_hidden').val('1');
        $('.porfechas').hide()
        $('.pornumeros').show()
    }else{
        $('#tipoBusqueda_hidden').val('0');
        $('.porfechas').show()
        $('.pornumeros').hide()
    }
});