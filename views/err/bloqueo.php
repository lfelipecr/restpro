<input type="hidden" id="url" value="<?php echo URL; ?>"/>
<body class="fix-header fix-sidebar card-no-border">
    <section id="wrapper" class="error-page" >
        <div class="error-box">
            <div class="error-body text-center">
            <h1 class="text-danger m-b-0"> <img src="<?php echo URL; ?>public/images/faltapago.png" width="250px" alt=""></h1>
                <span class="badge badge-pill badge-danger">
                <h3 class="text-center text-white font-weight-bold">¡Bloqueo por falta de pago!</h3>
                </span>
                <p class="text-dark font-weight-bold m-t-20 m-b-30">Su plataforma fue bloqueada por falta de pago. Comuníquese al <?= numero_contacto ?> o en el siguiente link ⬇</p>
                <a href="<?= link_bloqueo ?>" class="btn btn-success btn-lg btn-rounded waves-effect waves-light m-b-40"><i class="fab fa-whatsapp"></i> CONTACTAR</a>
                <footer class="footer text-center bg-dark"><img src="<?php echo URL; ?>public/images/logos/logo-factuyo-header.png"  alt=""></div></footer>
        </div>
    </section>
</body>
<style>
.text-warning {
    color: #ea5b5d !important;
}
</style>
<script type="text/javascript" src="<?php echo URL; ?>public/plugins/jquery/jquery.min.js"></script>
<script src="<?php echo URL; ?>public/plugins/moment/moment.js"></script>
<script type="text/javascript">
$(function() {
    liberarbloqueo();
    setInterval(liberarbloqueo, 10000);
    moment.locale('es');
});

var liberarbloqueo = function(){
    $.ajax({     
        type: "post",
        dataType: "json",
        url: $("#url").val()+'api/liberarbloqueo',
        success: function (data){
            console.log(data);
            if(data.status == 'liberado'){
                 window.location.href = $("#url").val()+'tablero';
            }           
        }
    })
}


</script>
