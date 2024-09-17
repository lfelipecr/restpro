<?php

class Login_Model extends Model
{
	public function __construct()
	{
		parent::__construct();
	}

	public function run()
	{
		date_default_timezone_set('America/Lima');
		setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
		$fecha = (date("H:i:s"));
		$du = $this->db->prepare("SELECT * FROM tm_usuario WHERE 
				usuario = :usuario AND contrasena = :password AND estado = 'a'");
		$du->execute(array(
			':usuario' => $_POST['usuario'],
			':password' => base64_encode($_POST['password'])
		));
		
		$data_u = $du->fetch();
		
		$count_u =  $du->rowCount();
		if ($count_u > 0) {

			//datos de usuario  editarprecio
			Session::init();
			Session::set('loggedIn', true);
			Session::set('rol', $data_u['id_rol']);
			Session::set('usuid', $data_u['id_usu']);
			Session::set('areaid', $data_u['id_areap']);
			Session::set('nombres', $data_u['nombres']);
			Session::set('apellidos', $data_u['ape_paterno'].' '.$data_u['ape_materno']);
			Session::set('imagen', $data_u['imagen']);
			Session::set('editarprecio', $data_u['editarprecio']);

			//datos de empresa
			$de = $this->db->prepare("SELECT * FROM tm_empresa");
			$de->execute();
			$data_e = $de->fetch();
			Session::set('ruc', $data_e['ruc']);
			Session::set('raz_soc', $data_e['razon_social']);
			Session::set('sunat', $data_e['sunat']);
			Session::set('modo', $data_e['modo']);
			// Session::set('ose', $data_e['ose']);
			Session::set('ose', $data_e['ose']);
			Session::set('ose_url', (($data_e['ose_url'])? $data_e['ose_url'] : '' ));

			// if($data_e['ose'] = 1){
			// 	Session::set('ose', $data_e['ose']);
			// 	Session::set('ose_url', $data_e['ose_url']);
			// }

			//datos de sistema
			$ds = $this->db->prepare("SELECT * FROM tm_configuracion");
			$ds->execute();
			$data_s = $ds->fetch();
			Session::set('zona_hor', $data_s['zona_hora']);
			Session::set('moneda', $data_s['mon_val']);
			Session::set('igv', ($data_s['imp_val'] / 100));
			Session::set('tribAcr', $data_s['trib_acr']);
			Session::set('tribCar', $data_s['trib_car']);
			Session::set('diAcr', $data_s['di_acr']);
			Session::set('diCar', $data_s['di_car']);
			Session::set('impAcr', $data_s['imp_acr']);
			Session::set('monAcr', $data_s['mon_acr']);
			Session::set('pc_name', $data_s['pc_name']);
			Session::set('pc_ip', $data_s['pc_ip']);
			Session::set('print_com', $data_s['print_com']);
			Session::set('print_pre', $data_s['print_pre']);
			Session::set('print_cpe', $data_s['print_cpe']); // funcion imprimir cpe 
			Session::set('cod_seg', $data_s['cod_seg']); //funcion codigo de seguridad  
			Session::set('opc_01', $data_s['opc_01']);
			Session::set('opc_02', $data_s['opc_02']);
			Session::set('opc_03', $data_s['opc_03']);
			Session::set('sep_items', $data_s['sep_items']);
			Session::set('verpdf', $data_s['verpdf']);
			Session::set('nota_ind', $data_s['nota_ind']);
			Session::set('mostrarimagen', $data_s['mostrarimagen']);
			Session::set('envios_auto', $data_s['envios_auto']);
            Session::set('imp_val_bol', $data_s['imp_val_bol']);
            Session::set('imp_bol', $data_s['imp_bol']);
            Session::set('multiples_precios', $data_s['multiples_precios']);
            Session::set('precio_comanda', $data_s['precio_comanda']);
            Session::set('direccion_comanda', $data_s['direccion_comanda']);
            Session::set('pedido_comanda', $data_s['pedido_comanda']);
            $dataPlan = json_decode($data_s['plan'], true);
            Session::set('api_wsp', isset($dataPlan['api_wsp']) ? $dataPlan['api_wsp'] : '0');


            $accesos = $this->db->selectAll("SELECT * FROM tm_accesos_rapidos");
            Session::set('accesosrapido', $accesos);

			/* modulo de bloqueo  */
			if($data_u['id_rol'] == 1){
				Session::set('bloqueo', '0');
				Session::set('bloqueo_id', $data_s['bloqueo']);
			}else{
				Session::set('bloqueo', $data_s['bloqueo']); 
				Session::set('bloqueo_id', $data_s['bloqueo']); 
			}

			// si cumple apertura
			if($data_u['id_rol'] == 1 OR $data_u['id_rol'] == 2 OR $data_u['id_rol'] == 3){
				$da = $this->db->prepare("SELECT * FROM tm_aper_cierre WHERE id_usu = ? AND estado = 'a'");
				$da->execute(array($data_u['id_usu']));
				$data_a = $da->fetch();
				$count_a =  $da->rowCount();
				if ($count_a > 0) {
					Session::set('aperturaIn', true);
					Session::set('apcid', $data_a['id_apc']);
				} else {
					Session::set('aperturaIn', false);
				}

				//Condicionar a que el administrador no visualice el tablero
				if($data_u['turno_ing']){ // SIN  FECHA
					if ($fecha >= $data_u['turno_ing'] && $fecha < $data_u['turno_sal']) {
					//  sin comentarios
					}else {
						print_r(json_encode(6));
						Session::destroy();
						exit;
					}
				}

				if($data_u['id_rol'] == 3){
					print_r(json_encode(3));
				} else {
					print_r(json_encode(1));
				}
				
			} elseif($data_u['id_rol'] == 4){
				Session::set('aperturaIn', true);
				print_r(json_encode(2));
			} elseif($data_u['id_rol'] == 5){
				if($data_u['turno_ing']){ // SIN  FECHA
					if ($fecha >= $data_u['turno_ing'] && $fecha < $data_u['turno_sal']) {
					//  sin comentarios
					}else {
						print_r(json_encode(6));
						Session::destroy();
						exit;
					}
				}
				Session::set('aperturaIn', true);
				print_r(json_encode(3));
			} elseif($data_u['id_rol'] == 7){
				Session::set('aperturaIn', true);
				print_r(json_encode(7));
			}
	

		} else {
			print_r(json_encode(4));
		}
		
	}
	
}