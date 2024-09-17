$(function() {
    feather.replace();
    changeThemeColor();
    contadorSunatSinEnviar();
    setInterval(contadorSunatSinEnviar, 1000000);
    contadorPedidosPreparados();
    contadorComensal();
    // setInterval(contadorPedidosPreparados, 10000);
    moment.locale('es');
    $('.scroll_pedpre').slimscroll({
        height: 300
    });
    $(".s").addClass("focused");
});

var label = function(){
    $(".s").addClass("focused");
}

$(".listar-pedidos-preparados").on("click", function(){
    listarPedidosPreparados();
});

$(".listar-contador-plan").on("click", function(){
    contadorplan();
});


var contadorSunatSinEnviar = function(){
    $.ajax({     
        type: "post",
        dataType: "json",
        url: $("#url").val()+'venta/contadorSunatSinEnviar',
        success: function (data){
            var variable = (data.total > 0) ? '<span class="badge badge-danger  badge-up cart-item-count"> '+data.total+' </span>' : '<span class="badge badge-primary  badge-up cart-item-count"> 0 </span>';
            $('.cont-sunat').html(variable);
            if(data.status == 'bloqueado'){
                window.location.href = $("#url").val();
            }
        }
    })
}

var contadorPedidosPreparados = function(){
    $('.t-notify').removeClass('notify');
    $.ajax({     
        type: "post",
        dataType: "json",
        url: $("#url").val()+'venta/contadorPedidosPreparados',
        success: function (data){
            $.each(data, function(i, item) {
                var cantidadPedido = parseInt(item.cantidad);
                if(parseInt(cantidadPedido) > 0){
                    // $('.t-notify').addClass('notify');
                    // var sound = new buzz.sound("assets/sound/ding_ding", {
                    //     formats: [ "ogg", "mp3", "aac" ]
                    // });
                    // sound.play();
                }
            });
        }
    })
}

var contadorComensal = function(){
    $.ajax({     
        type: "post",
        dataType: "json",
        url: $("#url").val()+'venta/comensal',
        success: function (data){
            $('.cont-comensal').html((data > 0) ? data : '0');
        }
    })
}

var listarPedidosPreparados = function(){
    $('.lista-pedidos-preparados').empty();
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $("#url").val()+'venta/listarPedidosPreparados',
        success: function (item) {
            if (item.data.length != 0) {
                $.each(item.data, function(i, campo) {
                    $('.lista-pedidos-preparados')
                    .append('<a href="javascript:void(0)" onclick="pedidoEntregado('+campo.id_pedido+','+campo.id_pres+',\''+campo.fecha_pedido+'\')">'
                        +'<div class="btn btn-success btn-circle"><i class="ti-check"></i></div> '
                        +'<div class="mail-contnet"><h5>'+campo.cantidad+' '+campo.nombre_prod+' <span class="label label-warning">'+campo.pres_prod+'</span></h5>'
                        +'<span class="mail-desc">'+campo.desc_salon+' - Mesa: '+campo.nro_mesa+'</span> <span class="time">'+moment(campo.fecha_envio).fromNow()+'</span>'
                        +'</div></a>');
                });
            } else {
                $('.lista-pedidos-preparados').html('<div class="col-sm-12 p-t-20 text-center"><h6>No tiene pedidos preparados</h6></div>');
            }
        }
    });
}

var pedidoEntregado = function(id_pedido,id_pres,fecha_pedido){
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: 'venta/pedidoEntregado',
        data: {
            id_pedido: id_pedido,
            id_pres: id_pres,
            fecha_pedido: fecha_pedido
        },
        success: function (data) {
            contadorPedidosPreparados();
            listarPedidosPreparados();
        },
        error: function(jqXHR, textStatus, errorThrown){
            console.log(errorThrown + ' ' + textStatus);
        }   
    });
}

var contadorplan = function(){
    $('.lista-pedidos-preparados').empty();
    $.ajax({
        dataType: 'JSON',
        type: 'POST',
        url: $("#url").val()+'ajuste/contadorplan',
        success: function (item) {
            if (item.data.length != 0) {
                // $(".p_").text(item.data.empresa.);
                $(".p_empresa").text(item.data.empresa.nombre_comercial);
                $(".p_ruc").text(item.data.empresa.ruc);
                $(".p_user").text(item.data.current.total_users);
                $(".p_user_limit").text(item.data.limits.total_users);
                $(".p_cpe").text(item.data.current.total_invoices);
                $(".p_cpe_limit").text(item.data.limits.total_invoices);
                $(".p_intervalo").text(item.data.intervals[0]+" / "+item.data.intervals[1]);
                // bar
                var user_bar = (parseFloat(item.data.current.total_users) * 100 ) / parseFloat(item.data.limits.total_users);
                var cpe_bar = (parseFloat(item.data.current.total_invoices) * 100 ) / parseFloat(item.data.limits.total_invoices);
                $(".p_user_progressbar").addClass(bgbar(user_bar));
                $('.p_user_progressbar').css('width', user_bar+"%");
                $(".p_cpe_progressbar").addClass(bgbar(cpe_bar));
                $('.p_cpe_progressbar').css('width', cpe_bar+"%");
            } else {
                
            }
        }
    });
}

var bgbar = function(data){
    if(data >= 80){
        return 'bg-danger';
    }else if(data >= 55){
        return 'bg-warning';
    }else{
        return 'bg-success';
    }
}

function formatNumber(num) {
    if (!num || num == 'NaN') return '0.00';
    if (num == 'Infinity') return '&#x221e;';
    num = num.toString().replace(/\$|\,/g, '');
    if (isNaN(num))
        num = "0";
    sign = (num == (num = Math.abs(num)));
    num = Math.floor(num * 100 + 0.50000000001);
    cents = num % 100;
    num = Math.floor(num / 100).toString();
    if (cents < 10)
        cents = "0" + cents;
    for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3) ; i++)
        num = num.substring(0, num.length - (4 * i + 3)) + ',' + num.substring(num.length - (4 * i + 3));
    return (((sign) ? '' : '-') + num + '.' + cents);
}

//BLOQUEO DE CARACTERES
$(".letMay input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[A-ZÁÉÍÓÚÑ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".letNumMay input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9,A-ZÁÉÍÓÚÑ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".letMin input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[a-záéíóúñ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".letNumMin input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9,a-záéíóúñ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".letMayMin input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[aA-zZáÁéÉíÍóÓúÚñÑ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".letNumMayMin input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9,aA-zZáÁéÉíÍóÓúÚñÑ/ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".letNumMayMin textarea").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9,aA-zZáÁéÉíÍóÓúÚñÑ/ ]')!=0 && keycode!=8 && keycode!=20){
        return false;
    }
});

$(".dec input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9.]')!=0 && keycode!=8){
        return false;
    }
});

$(".ent input").keypress(function(event) {
    var valueKey=String.fromCharCode(event.which);
    var keycode=event.which;
    if(valueKey.search('[0-9]')!=0 && keycode!=8){
        return false;
    }
});


// $("input,textarea").on('paste', function(e){
//     e.preventDefault();
// })

// $("input,textarea").on('copy', function(e){
//     e.preventDefault();
// })

$(".input-mayus").keyup(function(e) {
    $(this).val($(this).val().toUpperCase());
});

function mayus(e) {
    e.value = e.value.toUpperCase();
}

function mayusPrimera(string){
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function changeThemeColor() {
    var metaThemeColor = document.querySelector("meta[name=theme-color]");
    metaThemeColor.setAttribute("content", "#444");
    setTimeout(function() {
        changeThemeColor();
    }, 3000);
}

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
        }
    }
};