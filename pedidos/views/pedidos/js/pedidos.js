$(function() {
    validarLogin();
    $('#form-login').formValidation({
        framework: 'bootstrap',
        excluded: ':disabled',
        fields: {}
    }).on('success.form.fv', function(e) {
        e.preventDefault();
        var $form = $(e.target),
        fv = $form.data('formValidation');
        var form = $(this);

        var formdata = new FormData($('#form-login')[0]);

        $.ajax({
            async: false,
            type: 'POST',
            dataType: 'JSON',
            data: formdata,
            url: $('#url').val()+'checkout/run',
            contentType: false,
            processData: false,
        })
        .done(function(data){
            if(data.length > 0){
                $.each(data, function(i, item) {
                    var infoUsuario = {
                        id : item.id_cliente,
                        nombre : item.nombre_cliente,
                        direccion : item.direccion_cliente,
                        referencia : item.referencia_cliente,
                        telefono : item.telefono_cliente
                    }
                    localStorage.setItem("usuario",JSON.stringify(infoUsuario));
                    $('#id_cliente').val(item.id_cliente);
                });
                validarLogin();
            } else {
                const Toast = Swal.mixin({
                    toast: true,
                    position: 'top-end',
                    showConfirmButton: false,
                    timer: 2000,
                    timerProgressBar: true,
                    onOpen: (toast) => {
                        toast.addEventListener('mouseenter', Swal.stopTimer)
                        toast.addEventListener('mouseleave', Swal.resumeTimer)
                    }
                });
                Toast.fire({
                    icon: 'error',
                    title: 'El número ingresado no existe'
                });
                $('#form-login').formValidation('resetForm', true);
                return;
            }
        })
        .fail(function(){
            Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
        });  
    });
});

var pedidosList = function(estado,telefono_cliente){
       
    var table = $('#table')
    .DataTable({
        "destroy": true,
        "dom": "tp",
        "bSort": false,
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"pedidos/pedidos_list",
            "data": {
                estado: estado,
                telefono_cliente: telefono_cliente
            }
        },        
        "columns":[
            {
                "data": null,
                "render": function ( data, type, row ) {
                    return '<a href="javascript::void(0)" data-toggle="modal" data-target="#modal-pedido"><span class="round round-warning" onclick="listarPedidosDetalle('+data.id_pedido+',\''+data.Monto.total+'\');">'+data.nro_pedido+'</span></a>';
                }
            },
            {
                "data":"fecha_pedido",
                "render": function ( data, type, row ) {
                    return '<h6 style="white-space: normal;"><i class="ti-time"></i> '+moment(data).format('h:mm A')+'</h6><small class="text-muted font-13"><span class="text-muted">'+moment(data).format('DD-MM-Y')+'</small>';
                }
            },
            {
                "data":"Monto.total",
                "render": function ( data, type, row ) {
                    return formatNumber(data);
                }
            },
            {
                "data":"tipo_entrega",
                "render": function ( data, type, row ) {
                    var tipo_entrega = (data == 1) ? '<div class="text-right"><span class="badge badge-success">A DOMICILIO</span></div>' : '<div class="text-right"><span class="badge badge-info">POR RECOGER</span></div>';
                    return tipo_entrega;
                }
            }
        ]
    });

    $('.dataTables_wrapper').css('padding', '0');
}

var listarPedidosDetalle = function(id_pedido,total_pedido){
    $('#modal-pedido').modal('show');
    $('.pedidos-total').text($('#moneda').val()+' '+formatNumber(total_pedido));
    $('.step').removeClass('active');

    $('#table-productos').empty();
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'pedidos/pedidos_productos_list',
        data: {
            id_pedido : id_pedido
        },
        success: function (data) {
            if(data.length > 0){
                $.each(data, function(i, item) {

                    if(item.estado == 'a'){
                        $('.step1').addClass('active');
                    } else if(item.estado == 'b'){
                        $('.step2').addClass('active');
                    } else if(item.estado == 'c'){
                        $('.step3').addClass('active');
                    } else if(item.estado == 'd'){
                        $('.step4').addClass('active');
                    }
                    
                    var pro_nom = (item.nombre_prod).substr(0,1).toUpperCase()+(item.nombre_prod).substr(1).toLowerCase();
                    var pro_pre = (item.pres_prod).substr(0,1).toUpperCase()+(item.pres_prod).substr(1).toLowerCase();
                    var importe = item.precio * item.cantidad;

                    $('#table-productos')
                    .append(
                        $('<tr/>')
                        .append(
                            $('<td />')
                            .html(item.cantidad)
                        )
                        .append(
                            $('<td />')
                            .html(pro_nom+' | '+pro_pre)
                        )
                        .append(
                            $('<td />')
                            .html(item.precio)
                        )
                        .append(
                            $('<td  class="text-right"/>')
                            .html(formatNumber(importe))
                        )
                    );

                });
            } else {
                //$('#table-productos').html("<tr style='border-left: 2px solid #fff !important; background: #fff !important;'><td colspan='4'><div class='text-center'><h4 class='m-t-20' style='color: #d3d3d3;margin-top: 100px;'><i class='mdi mdi-alert-circle display-3 m-t-40 m-b-10'></i><br><small>No se encontraron datos</small></h4></div></td></tr>");
            }
        }
    });
    
    /*
    var table = $('#table-productos')
    .DataTable({
        "destroy": true,
        "dom": "t",
        "bSort": false,
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"pedidos/pedidos_productos_list",
            "data": {
                id_pedido: id_pedido
            }
        },        
        "columns":[
            {"data": "cantidad"},
            {
                "data": null,
                "render": function ( data, type, row ) {
                    var pro_nom = (data.nombre_prod).substr(0,1).toUpperCase()+(data.nombre_prod).substr(1).toLowerCase();
                    var pro_pre = (data.pres_prod).substr(0,1).toUpperCase()+(data.pres_prod).substr(1).toLowerCase();
                    return pro_nom+' | '+pro_pre;
                }
            },
            {
                "data":"precio",
                "render": function ( data, type, row ) {
                    return data;
                }
            },
            {
                "data": null,
                "render": function ( data, type, row ) {
                    var importe = data.precio * data.cantidad;
                    return '<div class="text-right">'+formatNumber(importe)+'</div>';
                }
            }
        ]
    });

    $('.dataTables_wrapper').css('padding', '0');
    */
}

var validarLogin = function(){
    var filtro = JSON.parse(localStorage.getItem("usuario"));
    if(filtro.telefono != undefined){
        $('.display-login').css('display','none');
        $('.display-informacion').css('display','block');
        pedidosList('a',filtro.telefono);
    } else {
        $('.display-login').css('display','block');
        $('.display-informacion').css('display','none');
    }
}

$(".user-refresh").click(function() {
    localStorage.setItem('usuario','[]');
    $('#form-login').formValidation('resetForm', true);
    validarLogin();
});

$(".list-recientes").click(function() {
    $('.text-pedidos').text('Recientes');
    var filtro = JSON.parse(localStorage.getItem("usuario"));
    pedidosList('a',filtro.telefono);
});

$(".list-anteriores").click(function() {
    $('.text-pedidos').text('Anteriores');
    var filtro = JSON.parse(localStorage.getItem("usuario"));
    pedidosList('d',filtro.telefono);
});
