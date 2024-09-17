<?php
    // opc_01: GLOVO,RAPPI,ETC
    // opc_02: ver stock de pollo
    // opc_03: imprimir ticket en mesa
// session_start();
    // Session::init();
    $_SESSION["zona_horaria"] = Session::get('zona_hor');
    // $_SESSION["accesosrapido"] = Session::get('accesosrapido');
    $accesosrapido = Session::get('accesosrapido');
    // echo json_encode($accesosrapido);
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <meta name="theme-color" content="#444">
    <meta name="msapplication-navbutton-color" content="#444">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <link rel="icon" type="image/png" sizes="16x16" href="<?=URL?>public/images/favicons/favicon-512x512.png">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="theme-color" content="#ffffff">
    <meta name="googlebot" content="noindex">
    <meta name="robots" content="noindex">
    
    <?php
        if (isset($this->title_page))
        {
            echo '<title>'.copyright.' | '.$this->title_page.'</title>';
        }
        else{
            echo '<title>'.copyright.' </title>';
        }
    ?>
    
    <!-- Bootstrap Core CSS -->
    <link href="<?php echo URL; ?>public/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="<?php echo URL; ?>public/plugins/toast-master/css/jquery.toast.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="<?php echo URL; ?>public/css/style.css?v=<?php echo date('ymd'); ?>" rel="stylesheet">
    <link href="<?php echo URL; ?>public/css/colors/<?=css_selector?>.css?v=<?php echo date('ymd'); ?>" id="theme" rel="stylesheet">
    
    <!-- You can change the theme colors from here -->
    <link href="<?php echo URL; ?>public/plugins/bootstrap-material-datetimepicker/css/bootstrap-material-datetimepicker.css" rel="stylesheet">
    <link href="<?php echo URL; ?>public/plugins/datatables.net-bs4/css/dataTables.bootstrap4.css" rel="stylesheet" type="text/css">
    <link href="<?php echo URL; ?>public/plugins/bootstrap-select/bootstrap-select.min.css" rel="stylesheet"/>
    <link href="<?php echo URL; ?>public/plugins/formvalidation/formValidation.min.css" rel="stylesheet">
    <link href="<?php echo URL; ?>public/plugins/bootstrap-touchspin/dist/jquery.bootstrap-touchspin.min.css" rel="stylesheet"/>
    <link href="<?php echo URL; ?>public/plugins/bootstrap-tagsinput/dist/bootstrap-tagsinput.css" rel="stylesheet"/>
    <link href="<?php echo URL; ?>public/plugins/bootstrap-tour/css/bootstrap-tour-standalone.min.css" rel="stylesheet"/>
    <link href="<?php echo URL; ?>public/plugins/wizard/wizard.css" rel="stylesheet">
    <link href="<?php echo URL; ?>public/plugins/jquery-ui-1.12.1/jquery-ui.css" rel="stylesheet">
    <link href="<?php echo URL; ?>public/css/style_all.css?v=<?php echo date('ymd'); ?>" rel="stylesheet">
    <link href="<?php echo URL; ?>public/js/bootstrap-datepicker.min.css" rel="stylesheet"/>
    <script type="text/javascript" src="<?php echo URL; ?>public/plugins/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="<?php echo URL; ?>public/js/feather.min.js"></script>
    <script type="text/javascript" src="<?php echo URL; ?>public/js/custom.js"></script>
    <input type="hidden" id="url" value="<?php echo URL; ?>"/>
</head>

<?php Session::init(); ?>
<?php if (Session::get('loggedIn') == true):?>
<body class="fix-header fix-sidebar card-no-border" id="card1">
    <!-- ============================================================== -->
    <!-- Preloader - style you can find in spinners.css -->
    <!-- ============================================================== -->
    <div class="preloader">
        <svg class="circular" viewBox="25 25 50 50">
            <circle class="path" cx="50" cy="50" r="20" fill="none" stroke-width="2" stroke-miterlimit="10" /> </svg>
    </div>
    <!-- ============================================================== -->
    <!-- Main wrapper - style you can find in pages.scss -->
    <!-- ============================================================== -->
    <div id="main-wrapper">
        <!-- ============================================================== -->
        <!-- Topbar header - style you can find in pages.scss -->
        <!-- ============================================================== -->
        
        <header class="topbar" style="width: 100% !important;">
            <nav class="navbar top-navbar navbar-expand-md navbar-light">
                <!-- ============================================================== -->
                <!-- Logo -->
                <!-- ============================================================== -->
                <div class="navbar-header">
                    <?php if(Session::get('rol') == 5) { ?>
                    <a class="navbar-brand" href="javascript:void(0)">
                    <?php } else { ?>
                    <a class="navbar-brand" href="<?php echo URL; ?>tablero">
                    <?php } ?>
                        <!-- Logo icon -->
                        <b>
                            <img src="<?=URL?>public/images/logos/icon-factuyo-rest.png" width="35px"/>
                        </b>
                        <!--End Logo icon -->
                        <!-- Logo text -->
                        <span>
                        <img src="<?=URL?>public/images/logos/logo-factuyo-header.png" width="150px"/>
                        </span> 
                    </a>
                </div>
                <!-- ============================================================== -->
                <!-- End Logo -->
                <!-- ============================================================== -->
                <div class="navbar-collapse">
                    <!-- ============================================================== -->
                    <!-- toggle and nav items -->
                    <!-- ============================================================== -->
                    <ul class="navbar-nav mr-auto mt-md-0">
                        <!-- This is  -->
                        <li class="nav-item"> <a class="nav-link nav-toggler hidden-md-up text-muted waves-effect waves-dark" href="javascript:void(0)"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg></a> </li>
                        <li class="nav-item"> <a class="nav-link sidebartoggler hidden-sm-down text-muted waves-effect waves-dark" href="javascript:void(0)"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg></a> </li>
                        <?php if(Session::get('rol') == 5) { ?>
                        <li class="nav-item"> <a class="nav-link text-muted waves-effect waves-dark" href="<?php echo URL; ?>venta"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg></a> </li>
                        <?php } ?>
                        <li class="nav-item search-box search-products" style="display: none"> <a class="nav-link text-muted waves-effect waves-dark" id="click_buscar"  href="javascript:void(0)" onclick="focusB()"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></a>
                            <span class="app-search">
                            <!-- <form class="app-search"> -->
                                <input type="text" class="form-control" name="buscar_producto" id="buscar_producto" placeholder="Buscar productos..." autocomplete="off"> <a class="srh-btn"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></a>
                            <!-- </form> -->
                            </span>
                        </li>                    
                        
                        <div class="navbar-collapse no-xs">
                        <?php if((Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3) AND Session::get('sunat') == 1) { ?>
                            <?php foreach($accesosrapido as $key => $value): 
                                if($value['url']!=''){
                                ?>  
                                <a href="<?=$value['url']?>" class="no-xs"><button class="btn" type="button"><span class="btn-rapidos" style="color: <?=$value['color']?>"><i class="<?=$value['icono']?>" data-original-title="<?=$value['titulo']?>" data-toggle="tooltip" data-placement="top"></i></span></button></a>
                            <?php } endforeach; ?>
                        <?php } ?>
                    </ul>
                    <!-- ============================================================== -->
                    <!-- User profile and search -->
                    <!-- ============================================================== -->
                    <ul class="navbar-nav my-lg-0">
                        <!-- ============================================================== -->
                        <!-- Comment -->
                        <!-- ============================================================== -->
                        <li class="nav-item sunat_btn" style="padding-top: 13px; margin-right: 6px;">
                            <?php if((Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3 ) AND Session::get('sunat') == 1) { ?>
                                <a href="<?php echo URL; ?>ajuste/datosempresa" class="no-xs">
                            <?php if(Session::get('modo') == 1) { ?>
                                    <button class="btn btn-success waves-effect waves-light border-0" type="button"><span class=""><i class="fa fa-check"></i> PROD</span></button>
                            <?php } else { ?>
                                    <button class="btn btn-warning waves-effect waves-light border-0" type="button"><span class=""><i class="fa fa-check"></i> DEMO</span></button>
                            <?php } ?>
                                </a>
                            <?php } ?>
                        </li>
                        <?php if((Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3 OR Session::get('rol') == 7) AND Session::get('sunat') == 1) {  ?>
                        <li class="nav-item sunat_btn" style="padding-top: 13px; margin-right: 6px;">
                            <a href="<?php echo URL; ?>facturacion">
                                <button class="btn btn-outline-danger" type="button">
                                    <img src="<?php echo URL; ?>public/images/logo-sunat.png" width="20px" height="20px" /> 
                                    <span class="cont-sunat sunat_cont"></span>
                                </button>
                            </a>
                        </li>
                        <?php } ?>
                        	<?php if(Session::get('opc_02') == 1) { ?>
                        <li class="nav-item dropdown">
                            <button style="margin-top: 13px; margin-left: 10px" type="button" class="btn waves-effect waves-light btn-primary btn-stock-pollo" style="display: none;" onclick="stock_pollo();">Stock de pollo</button>
                        </li>
                            <?php } ?>
                            <?php if(Session::get('rol') == 4) { ?>
                        <li class="nav-item dropdown">
                            <button style="margin-top: 13px; margin-left: 10px" type="button" class="btn waves-effect waves-light btn-primary" onclick="listarPedidos();">Por orden de llegada</button>
                        </li>
                        <li class="nav-item dropdown">
                            <button style="margin-top: 13px; margin-left: 10px" type="button" class="btn waves-effect waves-light btn-warning" onclick="agruparPlatos();">Ordenar por tipo de plato o bebida</button>
                        </li>
                        <li class="nav-item dropdown">
                            <button style="margin-top: 13px; margin-left: 10px" type="button" class="btn waves-effect waves-light btn-success" onclick="agruparPedidos();">Ordenar por pedidos</button>
                        </li>
                            <?php } ?>
                            <?php if(Session::get('rol') <> 4) { ?>
                        <li class="nav-item sunat_btn" style=" margin-right: 6px;">
                            <a class="">
                            <button style="margin-top: 13px; margin-left: 10px" type="button" class="btn btn-outline-light" data-toggle="tooltip" title="" data-original-title="Cantidad de Comensales Actual"> <i class="fas fa-users"></i> <span class="cont-comensal">0</span></button>
                            </a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle text-muted text-muted waves-effect waves-dark listar-pedidos-preparados" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> <svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
                                <div class="t-notify"> <span class="heartbit"></span> <span class="point"></span> </div>
                            </a>                            
                            <div class="dropdown-menu dropdown-menu-right mailbox scale-up">
                                <ul>
                                    <li>
                                        <div class="drop-title">Pedidos preparados</div>
                                    </li>
                                    <li>
                                        <div class="message-center lista-pedidos-preparados"></div>
                                    </li>
                                </ul>
                            </div>
                        </li>
                            <?php } ?>

                        <?php if(Session::get('rol') <> 4) { ?>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle text-muted text-muted waves-effect waves-dark listar-contador-plan" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                    <div class="t-notify"> <span class="heartbit"></span> <span class="point"></span> </div>
                                </a>                            
                                <div class="dropdown-menu dropdown-menu-right mailbox scale-up">

                                <div class="d-flex no-block align-items-center p-3 mb-2">
                                    <div class="">
                                    <img src="https://demos.wrappixel.com/premium-admin-templates/bootstrap/monster-bootstrap/package/assets/images/users/1.jpg" alt="user" class="rounded-circle" width="60">
                                    </div>
                                    <div class="ml-2">
                                    <h4 class="mb-0 p_empresa">Empresa SAC</h4>
                                    <p class="mb-0 p_ruc"></p>
                                    </div>
                                </div>
                                <div class="dropdown-divider"></div>
                                    <ul>
                                        <li >
                                            <div class="drop-title border-0 text-center">USO DE PLAN MENSUAL</div>
                                        </li>
                                        <li class="px-2 mt-2">
                                            <h6>Periodo actual</h6>
                                            <span class="p_intervalo">-</span>
                                        </li>
                                        <li class="px-2 mt-2">
                                            <h6 class="mb-0">Usuarios <b class="p_user">-</b>/<span class="p_user_limit">-</span></h6>
                                            <div class="progress mt-2">
                                                <div class="progress-bar p_user_progressbar" style="width: 10%; height: 6px" role="progressbar">
                                                </div>
                                            </div>
                                        </li>
                                        <li class="px-2 mt-4">
                                            <h6 class="mb-0">Comprobantes <b class="p_cpe">-</b>/<span class="p_cpe_limit">-</span> <i class="ti-info-alt text-warning font-10" data-original-title="Se renueva mensual"data-toggle="tooltip" data-placement="top"></i></h6>
                                            <div class="progress mt-2">
                                                <div class="progress-bar p_cpe_progressbar" style="width: 25%; height: 6px" role="progressbar">
                                                </div>
                                            </div>
                                        </li>
                                        <li class="mt-4"></li>
                                    </ul>
                                </div>
                            </li>
                        <?php } ?>                            
                        <li class="nav-item" >
                        <?php if(Session::get('rol') == 5) { ?>
                            <a href="<?php echo URL; ?>tablero/logoutmozo" class="nav-link text-muted waves-effect waves-dark" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i></a>
                            <?php }else { ?>
                            <a href="<?php echo URL; ?>tablero/logout" class="nav-link text-muted waves-effect waves-dark" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i></a>
                            <?php } ?>
                        </li>
                        <!-- ============================================================== -->
                        <!-- End Comment -->
                        <!-- ============================================================== -->
                    </ul>
                </div>
            </nav>
        </header>
        <!-- ============================================================== -->
        <!-- End Topbar header -->
        <!-- ============================================================== -->
        <!-- ============================================================== -->
        <!-- Left Sidebar - style you can find in sidebar.scss  -->
        <!-- ============================================================== -->
        <aside class="left-sidebar">
            <!-- Sidebar scroll-->
            <div class="scroll-sidebar">
                <!-- User profile -->
                <div class="user-profile" style="background: url(<?php echo URL; ?>public/images/background/user-info.jpg) no-repeat;">
                    <!-- User profile image -->
                    <div class="profile-img"> <img src="<?php echo URL; ?>public/images/users/<?php echo Session::get('imagen'); ?>" alt="user" /> </div>
                    <!-- User profile text-->
                    <div class="profile-text"> <a href="#" class="dropdown-toggle u-dropdown" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="true"><?php echo Session::get('nombres'); ?></a>
                        <div class="dropdown-menu animated flipInY"> 
                            <a href="<?php echo URL; ?>tablero/logout" class="dropdown-item"><i class="fa fa-power-off"></i> Salir</a> 
                        </div>
                    </div>
                </div>
                <!-- End User profile text-->
                <!-- Sidebar navigation-->
                <nav class="sidebar-nav">
                    <ul id="sidebarnav">
                    <?php if (Session::get('rol') == 4):?> 
                        <li id="area-p"><a class="waves-effect waves-dark" href="<?php echo URL; ?>produccion" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><rect x="4" y="2" width="16" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12.01" y2="18"></line></svg><span class="hide-menu"> Producci&oacute;n</span></a>
                        </li>
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 or Session::get('rol') == 2 or Session::get('rol') == 3 or Session::get('rol') == 5 or Session::get('rol') == 6):?>                     
                        <li id="restau"><a class="waves-effect waves-dark" href="<?php echo URL; ?>venta" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg><span class="hide-menu"> Punto de Venta </span></a>
                        </li>  
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3):?>                       
                        <li id="caja"><a class="has-arrow waves-effect waves-dark" href="#" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg><span class="hide-menu"> Caja </span></a>
                            <ul aria-expanded="false" class="collapse">
                                <li><a href="<?php echo URL; ?>caja/apercie" id="c-apc"> Apertura y cierre</a></li>
                                <li><a href="<?php echo URL; ?>caja/ingreso" id="c-ing"> Ingresos</a></li>
                                <li><a href="<?php echo URL; ?>caja/egreso" id="c-egr"> Egresos</a></li>
                                <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3):?> 
                                <li><a href="<?php echo URL; ?>caja/monitor" id="c-mon"> Monitor de ventas</a></li>
                                <?php endif; ?>
                            </ul>
                        </li>
                        <li id="clientes"><a class="waves-effect waves-dark" href="<?php echo URL; ?>cliente" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg><span class="hide-menu"> Clientes </span></a>
                        </li>
                        <li id="compras"><a class="has-arrow waves-effect waves-dark" href="#" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg><span class="hide-menu"> Compras </span></a>
                            <ul aria-expanded="false" class="collapse">
                                <li><a href="<?php echo URL; ?>compra/nueva-compra" id="c-compras"> Nueva compra</a></li>
                                <li><a href="<?php echo URL; ?>compra" id="c-compras"> Todas las compras</a></li>
                                <li><a href="<?php echo URL; ?>compra/proveedor" id="c-proveedores"> Proveedores</a></li>
                            </ul>
                        </li>
                        <li id="creditos"><a class="has-arrow waves-effect waves-dark" href="#" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg><span class="hide-menu"> Creditos </span></a>
                            <ul aria-expanded="false" class="collapse">
                                <li><a href="<?php echo URL; ?>credito" id="cr-compras"> Compras</a></li>
                            </ul>
                        </li> 
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3):?>  
                        <li id="inventario"><a class="has-arrow waves-effect waves-dark" href="#" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="21 8 21 21 3 21 3 8"></polyline><rect x="1" y="3" width="22" height="5"></rect><line x1="10" y1="12" x2="14" y2="12"></line></svg><span class="hide-menu"> Inventario </span></a>
                            <ul aria-expanded="false" class="collapse">                                
                                <li><a href="<?php echo URL; ?>inventario/stock" id="i-stock"> Stock</a></li>
                                <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2):?> 
                                <!-- <li><a href="<?php echo URL; ?>inventario/kardex" id="i-karval"> Kardex valorizado</a></li>                                 -->
                                <li><a href="<?php echo URL; ?>inventario/ajuste" id="i-entsal"> Ajuste de stock</a></li>
                                <?php endif; ?>                            
                            </ul>
                        </li>
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 7):?> 
                        <li id="contable"><a class="waves-effect waves-dark" href="<?php echo URL; ?>contable" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg><span class="hide-menu"> Contable </span></a>
                        </li>
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3):?>
                        <li id="informes"><a class="waves-effect waves-dark" href="<?php echo URL; ?>informe" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg><span class="hide-menu"> Informes </span></a>
                        </li>
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2):?>
                        <li id="inventario"><a class="has-arrow waves-effect waves-dark" href="#" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg><span class="hide-menu"> Ajustes </span></a>
                            <ul aria-expanded="false" class="collapse">                                
                                <li><a href="<?php echo URL; ?>ajuste"> Todos</a></li>
                                <li><a href="<?php echo URL; ?>ajuste/sistema"> Configuracion</a></li>
                                <li><a href="<?php echo URL; ?>ajuste/producto"> Productos</a></li>
                                <li><a href="<?php echo URL; ?>ajuste/tipopago"> Tipo de pagos</a></li>
                                <li><a href="<?php echo URL; ?>ajuste/datosempresa"> Datos de empresa</a></li>
                                <li><a href="<?php echo URL; ?>ajuste/tipopago"> Datos de empresa</a></li>
                                <li><a href="<?php echo URL; ?>ajuste/salon-mesa"> Salones y mesa</a></li>
                            </ul>
                        </li>
                    <?php endif; ?>
                    <?php if (Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3):?>
                        <li id="tablero"><a class="waves-effect waves-dark" href="<?php echo URL; ?>tablero" aria-expanded="false"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg><span class="hide-menu"> Tablero </span></a>
                        </li>
                        <li id="estadistica"><a class="waves-effect waves-dark" href="<?php echo URL; ?>estadistica" aria-expanded="false"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-bar-chart-2 feather-sm"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg><span class="hide-menu">  Estadística </span></a>
                        </li>
                    <?php endif; ?>
                    </ul>
                </nav>
                <!-- End Sidebar navigation -->
            </div>
        </aside>
        <script type="text/javascript">
            var focusB = function () {
                setTimeout(function(){
                    $( "#buscar_producto" ).focus();
                }, 200);
            };
            $(function() {
                $(document).on('keydown', 'body', function(event) {
                    if(event.keyCode==114){ //F3
                        event.preventDefault();
                        $('#click_buscar').trigger('click');
                        setTimeout(function(){
                            $( "#buscar_producto" ).focus();
                        }, 200);
                     }
                 });
             });
        </script>
        
        <div class="page-wrapper">
            <div class="container-fluid">
            
<?php endif; ?>

    