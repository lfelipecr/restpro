//Culqi.publicKey = 'pk_test_25E7HHJpVTXS26cr';
Culqi.publicKey = 'pk_test_0c429dc04f2f2ea1';

function culqi() {

    html_confirm = '<h4 class="m-t-20 font-bold">Validando sus datos</h4></div>'
                    +'<div class="p-0">Espere un momento por favor...</div>';

    Swal.fire({    
        html: html_confirm,
        timer: 3000,
        allowOutsideClick: false,
        allowEscapeKey : false,
        showCancelButton: false,
        showConfirmButton: false,
        closeOnConfirm: false,
        closeOnCancel: false,
        onBeforeOpen: () => {
            Swal.showLoading ()
        }
    });

    getCarrito = JSON.parse(localStorage.getItem("carrito"));
    var total = 0;
    for (i of getCarrito) {
        total += parseFloat(i.cantidad) * parseFloat(i.precio);
    }

    var total_ = total.toFixed(2).toString();
    var amount = total_.replace(".", "");

    if (Culqi.token) { // ¡Objeto Token creado exitosamente!
        var token = Culqi.token.id;
        var email = Culqi.token.email;

        var data = { 
            producto:'Productos varios', 
            precio: amount, 
            token:token, 
            customer_id: '44827499',
            address: 'Jr Drenaje',
            address_city: 'Ancash - Chimbote',
            first_name: 'Tommy Leonard',
            email: email 
        };

        var url = $('#url').val()+"views/checkout/proceso.php";

        $.post(url,data,function(res){
            
            if (res=="exito") {
                guardarPedido(email);
            }else{
                Swal.fire({
                  icon: 'error',
                  title: 'Oops...',
                  text: 'No se pudo realizar el pago!',
                  confirmButtonColor: '#4aa36b'
                });
            }
        });

        //En esta linea de codigo debemos enviar el "Culqi.token.id"
        //hacia tu servidor con Ajax
    } else { // ¡Hubo algún problema!
        // Mostramos JSON de objeto error en consola
        //console.log(Culqi.error);
        alert(Culqi.error.user_message);
    }
};