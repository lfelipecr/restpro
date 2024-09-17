$(function() {
    $('#contable').addClass("active");
    moment.locale('es');

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

    $("#month").datepicker({
        autoclose:true,
        minViewMode:1,
        format:"mm-yyyy",
        locale: 'es'
    });

    $('#tipoBusqueda_hidden').val(0);
    $('#tipoBusqueda').prop('checked', false);

    $('#tipoBusqueda').on('change', function(event){
        if($(this).prop('checked')){
            $('#tipoBusqueda_hidden').val('1');
            $('#porfechas').show()
            $('#pormes').hide()
        }else{
            $('#tipoBusqueda_hidden').val('0');
            $('#pormes').show()
            $('#porfechas').hide()
        }
    });

});

