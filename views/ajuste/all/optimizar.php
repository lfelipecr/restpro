<div class="row page-titles">
    <div class="col-md-5 col-8 align-self-center">
        <h4 class="m-b-0 m-t-0">Ajustes</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>ajuste" class="link">Inicio</a></li>
            <li class="breadcrumb-item"><a href="<?php echo URL; ?>ajuste" class="link">Sistema</a></li>
            <li class="breadcrumb-item active">Optimizaci&oacute;n de procesos</li>
        </ol>
    </div>
</div>

<div class="wrapper wrapper-content animated fadeIn ng-scope">
    <div class="row">
        <?php if(Session::get('modo') == 1) { ?>
            <div class="col-sm-12 col-lg-12">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="fas fa-window-close"></i></h1>
                        <h4 class="card-title">No esta permitido optimizar procesos cuando el sistema esta en producción.</h4>
                        <p class="card-text">Si desea restaurar datos iniciales, por favor, cambie a demo.</p>
                    </div>
                </div>
            </div>
        <?php } else { ?>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="ti ti-receipt text-success"></i></h1>
                        <h4 class="card-title">Pedidos</h4>
                        <p class="card-text">Eliminar recursos temporales</p>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-ped">Optimizar</a>
                    </div>
                </div>
            </div>
            <?php if(Session::get('usuid') == 1) { ?>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="ti ti-ticket text-success"></i></h1>
                        <h4 class="card-title">Ventas</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-ven">Restaurar</a>
                    </div>
                </div>
            </div>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="mdi mdi-food-fork-drink text-success"></i></h1>
                        <h4 class="card-title">Productos</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-prod">Restaurar</a>
                    </div>
                </div>
            </div>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="mdi mdi-food-variant text-success"></i></h1>
                        <h4 class="card-title">Insumos</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-ins">Restaurar</a>
                    </div>
                </div>
            </div>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="mdi mdi-account-multiple text-success"></i></h1>
                        <h4 class="card-title">Clientes</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-clientes">Restaurar</a>
                    </div>
                </div>
            </div>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="mdi mdi-account-location text-success"></i></h1>
                        <h4 class="card-title">Proveedores</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-proveedores">Restaurar</a>
                    </div>
                </div>
            </div>
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="mdi mdi-folder-multiple-outline text-success"></i></h1>
                        <h4 class="card-title">Salones y mesas</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-mesas">Restaurar</a>
                    </div>
                </div>
            </div>  
            <div class="col-sm-2 col-lg-2">
                <div class="card text-center">
                    <div class="card-body">
                        <h1><i class="fa fa-warehouse entory text-success"></i></h1>
                        <h4 class="card-title">Kardex/inventario</h4>
                        <a href="javascript:void(0)" class="btn btn-primary btn-block opt-inventario">Restaurar</a>
                    </div>
                </div>
            </div>  
        <?php } ?>
        <?php } ?>
        <!-- <div class="col-sm-2 col-lg-2">
            <form action="<?php echo URL; ?>ajuste/optimizar_database" method="post" target="_blank" id="myForm"> 
            <div class="card text-center">
                <div class="card-body">
                    <h1><i class="mdi mdi-database text-success"></i></h1>
                    <h4 class="card-title">Backup</h4>
                    <p class="card-text text-center">Descargar respaldo de Base de datos</p>
                    <button id="generarexcel" class="btn btn-primary btn-block opt-database">Descargar</button>
                </div>
            </div>
            </form>
        </div> -->
    </div>
</div>