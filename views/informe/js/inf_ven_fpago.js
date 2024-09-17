$(function() {
    $('#informes').addClass("active");
    moment.locale('es');
    listar();

    $('#start').bootstrapMaterialDatePicker({
        format: 'DD-MM-YYYY LT',
        lang: 'es-do',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('#end').bootstrapMaterialDatePicker({
        useCurrent: false,
        format: 'DD-MM-YYYY LT',
        lang: 'es-do',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('#start,#end,#filtro_tipo_pago').change( function() {
        listar();
    });

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
  
});

var listar = function(){

    var moneda = $("#moneda").val();
    ifecha = $("#start").val();
    ffecha = $("#end").val();
    id_tpag = $("#filtro_tipo_pago").selectpicker('val');

    var table = $('#table')
    .DataTable({
        buttons: [
            {
                extend: 'excel', title: 'Formas de pagos', className: 'dropdown-item p-t-0 p-b-0', text: '<i class="fas fa-file-excel"></i> Descargar en excel', titleAttr: 'Descargar Excel',
                container: '#excel', exportOptions: { columns: [0,1,2,3,4,5,6,7,8,9] }
            },
            {
                extend: 'pdf', title: 'Formas de pagos', className: 'dropdown-item p-t-0 p-b-0', text: '<i class="fas fa-file-pdf"></i> Descargar en pdf', titleAttr: 'Descargar Pdf',
                container: '#pdf', exportOptions: { columns: [0,1,2,3,4,5,6,7,8,9] }, orientation: 'landscape', 
                customize : function(doc){ 
                    doc.styles.tableHeader.alignment = 'left'; 
                    doc.content[1].table.widths = [60,'*','*','*','*','*','*','*','*'];
                }
            }       
        ],
        "destroy": true,
        "responsive": true,
        "dom": "tip",
        "bSort": true,
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"informe/venta_fpago_list",
            "data": {
                ifecha: ifecha,
                ffecha: ffecha,
                id_tpag: id_tpag
            }
        },
        "columns":[
            {"data":"fec_ven","render": function ( data, type, row ) {
                return '<i class="ti-calendar"></i> '+moment(data).format('DD-MM-Y')
                +'<br><span class="font-12"><i class="ti-time"></i> '+moment(data).format('h:mm A')+'</span>';
            }},
            {"data":"Cliente","render": function ( data, type, row ) {
                return '<div class="mayus">'+data.nombre+' <br><span class="font-11"> '+data.dni+''+data.ruc+'</span></div>';
            }},
            {"data":null,"render": function ( data, type, row ) {
                return data.desc_td
                +'<br><span class="font-12">'+data.numero+'</span>';
            }},
            {"data":null,"render": function ( data, type, row ) {
                return '<div class="mayus">'+data.codigo_operacion+'</div>';
            }},
            {"data":null,"render": function ( data, type, row ) {
                if(data.id_tpag == 1){
                    return '<span class="label label-success">'+data.desc_tp+'</span>';
                } else if(data.id_tpag == 2){
                    return '<span class="label label-info">'+data.desc_tp+'</span>';
                } else if(data.id_tpag == 3){
                    return '<span class="label label-warning">'+data.desc_tp+'</span>';
                } else if(data.id_tpag == 4){
                    return '<span class="label label-danger text-primary font-bold">C</span> <span class="text-primary font-bold">'+data.desc_tp+'</span>';
                } else if(data.id_tpag >= 5){
                    return '<span class="label label-light-primary">'+data.desc_tp+'</span>';
                }
            }},
            /*
            {"data":null,"render": function ( data, type, row) {
                return '<div class="text-right bold">'+moneda+' '+formatNumber(parseFloat(data.total) + parseFloat(data.descu))+'</div>'
                +'<p class="text-right m-b-0"><i>Dscto.: -'+formatNumber(data.descu)+'</i></p>';
            }},
            */
            {"data":"pagos_efe.total_efe", "className": "classefectivo", "render": function ( data, type, row) {
                return '<div class="text-right">'+moneda+' '+formatNumber(data)+'</div>'; //efectivo
            }},
            {"data":"pagos_tar.total_tar", "className": "classtarjeta", "render": function ( data, type, row) {
                return '<div class="text-right">'+moneda+' '+formatNumber(data)+'</div>'; //tarjeta
            }},
            {"data":"pagos_yape.total_yape", "className": "classtarjeta", "render": function ( data, type, row) {
                return '<div class="text-right">'+moneda+' '+formatNumber(data)+'</div>'; //yape
            }},
            {"data":"pagos_plin.total_plin", "className": "classtarjeta", "render": function ( data, type, row) {
                return '<div class="text-right">'+moneda+' '+formatNumber(data)+'</div>'; //plin
            }},
            {"data":"pagos_tran.tran_plin", "className": "classtarjeta", "render": function ( data, type, row) {
                return '<div class="text-right">'+moneda+' '+formatNumber(data)+'</div>'; //plin
            }},
            {"data":"total","render": function ( data, type, row) {
                return '<div class="text-right"><b> '+moneda+' '+formatNumber(data)+'</b></div>'; //total venta
            }},
        ],
        "footerCallback": function ( row, data, start, end, display ) {
            var api = this.api(), data;

            var intVal = function ( i ) {
                return typeof i === 'string' ?
                    i.replace(/[\$,]/g, '')*1 :
                    typeof i === 'number' ?
                        i : 0;
            };
 
            efectivo_total = api
                .column( 5 )
                .data()
                .reduce( function (a, b) {
                    return intVal(a) + intVal(b);
                }, 0 );

            tarjeta_total = api
                .column( 6 )
                .data()
                .reduce( function (a, b) {
                    return intVal(a) + intVal(b);
                }, 0 );

            yape_total = api
                .column( 7 )
                .data()
                .reduce( function (a, b) {
                    return intVal(a) + intVal(b);
                }, 0 );

            plin_total = api
                .column( 8 )
                .data()
                .reduce( function (a, b) {
                    return intVal(a) + intVal(b);
                }, 0 );


            tran_total = api
                .column( 10 )
                .data()
                .reduce( function (a, b) {
                    return intVal(a) + intVal(b);
                }, 0 );

            operaciones = api
                .rows()
                .data()
                .count();

            $('.efectivo-total').text(moneda+' '+formatNumber(efectivo_total));
            $('.tarjeta-total').text(moneda+' '+formatNumber(tarjeta_total));
            $('.yape-total').text(moneda+' '+formatNumber(yape_total));
            $('.plin-total').text(moneda+' '+formatNumber(plin_total));
            $('.tran-total').text(moneda+' '+formatNumber(tran_total));
            $('.pagos-operaciones').text(operaciones);
        }
    });
}