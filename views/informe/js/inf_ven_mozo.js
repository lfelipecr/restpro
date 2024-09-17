$(function() {
    $('#informes').addClass("active");
    moment.locale('es');
    listar();
    
    $('#start').bootstrapMaterialDatePicker({
        time: false,
        format: 'DD-MM-YYYY',
        lang: 'es-do',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('#end').bootstrapMaterialDatePicker({
        time: false,
        useCurrent: false,
        format: 'DD-MM-YYYY',
        lang: 'es-do',
        cancelText: 'Cancelar',
        okText: 'Aceptar'
    });

    $('#start,#end,#filtro_mozo').change( function() {
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
    id_mozo = $("#filtro_mozo").selectpicker('val');

    var table = $('#table')
    .DataTable({
        buttons: [
            {
                extend: 'excel', title: 'Ventas por mesero', className: 'dropdown-item p-t-0 p-b-0', text: '<i class="fas fa-file-excel"></i> Descargar en excel', titleAttr: 'Descargar Excel',
                container: '#excel', exportOptions: { columns: [0,1,2,3,4,5] }
            },
            {
                extend: 'pdf', title: 'Ventas por mesero', className: 'dropdown-item p-t-0 p-b-0', text: '<i class="fas fa-file-pdf"></i> Descargar en pdf', titleAttr: 'Descargar Pdf',
                container: '#pdf', exportOptions: { columns: [0,1,2,3,4,5] }, orientation: 'landscape', 
                customize : function(doc){ 
                    doc.styles.tableHeader.alignment = 'left'; 
                    doc.content[1].table.widths = [60,'*','*','*','*','*','*'];
                }
            }
        ],
        "destroy": true,
        "dom": "tip",
        "bSort": true,
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"informe/venta_mozo_list",
            "data": {
                ifecha: ifecha,
                ffecha: ffecha,
                id_mozo: id_mozo
            }
        },
        "columns":[
            {"data":"fec_ven","render": function ( data, type, row ) {
                return '<i class="ti-calendar"></i> '+moment(data).format('DD-MM-Y')
                +'<br><span class="font-12"><i class="ti-time"></i> '+moment(data).format('h:mm A')+'</span>';
            }},
            {"data":"Mozo.nombre","render": function ( data, type, full, meta ) {
                return '<div class="mayus">'+data+'</div>';
            }},
            {"data":"Cliente.nombre"},
            {"data":"desc_td"},
            {"data":"numero"},
            {"data":"total","render": function ( data, type, full, meta ) {
                return '<div class="text-right bold"> '+moneda+' '+formatNumber(data)+'</div>';
            }}
        ],
        "footerCallback": function ( row, data, start, end, display ) {
            var api = this.api(), data;

            var intVal = function ( i ) {
                return typeof i === 'string' ?
                    i.replace(/[\$,]/g, '')*1 :
                    typeof i === 'number' ?
                        i : 0;
            };
 
            total = api
                .column( 5 /*, { search: 'applied', page: 'current'} */)
                .data()
                .reduce( function (a, b) {
                    return intVal(a) + intVal(b);
                }, 0 );

            operaciones = api
                .rows()
                .data()
                .count();

            $('.mozo-total').text(moneda+' '+formatNumber(total));
            $('.mozo-operaciones').text(operaciones);
        }
    });
}