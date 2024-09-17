<?php Session::init(); ?>
<?php

class Contable_Model extends Model
{
    public function __construct()
    {
        parent::__construct();
    }

    public function TipoDocumento()
    {
        try
        {   
            return $this->db->selectAll('SELECT * FROM tm_tipo_doc WHERE id_tipo_doc != "3" AND estado = "a"');
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
    public function Empresa()
    {
        try
        {      
            return $this->db->selectOne("SELECT * FROM tm_empresa");
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function venta_all_list($data)
    {
        try
        {
            if ($data['tipoBusqueda_hidden']==1) {
                $ifecha = ''.date('Y-m-d',strtotime($data['start'])).' 00:00:00';
                $ffecha = ''.date('Y-m-d',strtotime($data['end'])).' 23:59:59';
            }else{
                $fechaData = explode("-", $data['month']);
                $day = date("d", mktime(0,0,0, $fechaData[0]+1, 0, $fechaData[1]));
                // $anio = explode("-", $data['month']);
                // $ifecha = ''.date('Y-m-01',strtotime('01-'.$data['month'])).' 00:00:00';
                // $ffecha = ''.date('Y-m-t',strtotime('31-'.$data['month'])).' 23:59:59';
                $ifecha = ''.$fechaData[1].'-'.$fechaData[0].'-01 00:00:00';
                $ffecha = ''.$fechaData[1].'-'.$fechaData[0].'-'.$day.' 23:59:59';

            }
            // $my_date = new DateTime();
            // echo $ffecha;
            // return;
            // $stm = $this->db->prepare("SELECT v.id_ven,v.id_ped,v.id_tped,v.id_tpag,v.desc_tp,v.pago_efe,v.pago_tar,v.desc_monto,v.comis_tar,v.comis_del,v.total AS stotal,v.fec_ven,v.desc_td,v.ser_doc,v.nro_doc,v.estado,IFNULL((v.pago_efe + v.pago_tar),0) AS total,v.id_cli,v.igv,v.id_usu,v.desc_tipo,v.desc_personal,c.desc_caja FROM v_ventas_con AS v INNER JOIN v_caja_aper AS c ON v.id_apc = c.id_apc WHERE (DATE(v.fec_ven) >= ? AND DATE(v.fec_ven) <= ?) AND v.id_tped like '%' AND v.id_tdoc <> '3' AND v.id_cli like '%' AND v.estado like '%'  GROUP BY v.id_ven");
            $stm = $this->db->prepare("SELECT v.id_ven,v.id_ped,v.id_tped,v.id_tpag,v.desc_tp,v.pago_efe,v.pago_tar,v.desc_monto,v.comis_tar,v.comis_del,v.total AS stotal,v.fec_ven,v.desc_td,v.ser_doc,v.nro_doc,v.estado,v.enviado_sunat,IFNULL((v.pago_efe + v.pago_tar),0) AS total,v.id_cli,v.igv,v.id_usu,v.desc_tipo,v.desc_personal,c.desc_caja FROM v_ventas_con AS v INNER JOIN v_caja_aper AS c ON v.id_apc = c.id_apc WHERE  (DATE_FORMAT(v.fec_ven,'%Y-%m-%d %H:%i:%S') >= ? AND DATE_FORMAT(v.fec_ven,'%Y-%m-%d %H:%i:%S') <= ?) AND v.id_tped like '%' AND v.id_tdoc <> '3' AND v.id_cli like '%' AND v.estado like '%' GROUP BY v.id_ven");

            $stm->execute(array($ifecha, $ffecha));
            $c = $stm->fetchAll(PDO::FETCH_OBJ);
                       
            foreach($c as $k => $d)
            {
                $c[$k]->{'Pedido'} = $this->db->query("SELECT vm.desc_salon, vm.nro_mesa FROM tm_pedido_mesa AS pm INNER JOIN v_mesas AS vm ON pm.id_mesa = vm.id_mesa WHERE pm.id_pedido = ".$d->id_ped)
                    ->fetch(PDO::FETCH_OBJ);

                if (strtotime($d->fec_ven) < strtotime(fecha_igv)) {
                    $igv=0.18;
                }else{
                    $igv=0.10;
                }

                $c[$k]->{'Detalle'} = $this->db->query("SELECT v_productos.pro_cod AS codigo_producto, 
                    /*CONCAT(v_productos.pro_nom,' ',v_productos.pro_pre) AS nombre_producto, */
                    CONCAT(v_productos.pro_pre) AS nombre_producto,
                    IF(v_productos.pro_imp='1','10','20') AS codigo_afectacion, 
                    CAST(tm_detalle_venta.cantidad AS DECIMAL(7,2)) AS cantidad, 
                    IF(v_productos.pro_imp='1',ROUND((tm_detalle_venta.precio/(1 + ".$igv.")),2),tm_detalle_venta.precio) AS valor_unitario,
                    tm_detalle_venta.precio AS precio_unitario,
                    IF(v_productos.pro_imp='1',ROUND((tm_detalle_venta.precio/(1 + ".$igv."))*tm_detalle_venta.cantidad,2),
                    ROUND(tm_detalle_venta.precio*tm_detalle_venta.cantidad,2)) AS valor_venta,
                    IF(v_productos.pro_imp='1',ROUND((tm_detalle_venta.precio/(1 + ".$igv.")*tm_detalle_venta.cantidad)*".$igv.",2),0) AS total_igv 
                    FROM tm_detalle_venta 
                    INNER JOIN tm_venta ON tm_detalle_venta.id_venta = tm_venta.id_venta 
                    INNER JOIN v_productos ON tm_detalle_venta.id_prod = v_productos.id_pres 
                    WHERE tm_venta.id_tipo_doc  IN ('1','2','3') AND tm_detalle_venta.precio > 0 AND tm_detalle_venta.id_venta = ".$d->id_ven)
                    ->fetchAll(PDO::FETCH_OBJ);

            }
            
            foreach($c as $k => $d)
            {
                $c[$k]->{'Cliente'} = $this->db->query("SELECT * FROM v_clientes WHERE id_cliente = ".$d->id_cli)
                    ->fetch(PDO::FETCH_OBJ);
            }

            return $c;      
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function validador_list($data)
    {
        try
        {
            $empresa = $this->Empresa();

            $ifecha    = date('Y-m-d',strtotime($data['ifecha']));
            $ffecha    = date('Y-m-d',strtotime($data['ffecha']));
            $desde     = $data['desde'];
            $hasta     = $data['hasta'];
            $tbusqueda = $data['tbusqueda'];

            if ($tbusqueda == '0') {
                if($data['tdoc'] == '%'):
                    $estado = "v.id_tdoc <> 3";
                else: 
                    $estado = "v.id_tdoc = ".$data['tdoc'];
                endif;

                $stm = $this->db->prepare("SELECT v.id_cli, v.desc_td, v.ser_doc, v.nro_doc, v.fec_ven, v.id_ven, v.enviado_sunat, v.estado,IFNULL((v.total+v.comis_del-v.desc_monto),0) AS total FROM v_ventas_con AS v INNER JOIN v_caja_aper AS c ON v.id_apc = c.id_apc WHERE (DATE_FORMAT(v.fec_ven,'%Y-%m-%d') >= ? AND DATE_FORMAT(v.fec_ven,'%Y-%m-%d') <= ?) AND v.id_tdoc like ? AND ".$estado." GROUP BY v.id_ven");
                $stm->execute(array($ifecha,$ffecha,$_POST['tdoc']));
            }else{
                if ($hasta) {
                    $stm = $this->db->prepare("SELECT v.id_cli, v.desc_td, v.ser_doc, v.nro_doc, v.fec_ven, v.id_ven, v.enviado_sunat, v.estado,IFNULL((v.total+v.comis_del-v.desc_monto),0) AS total 
                        FROM v_ventas_con AS v 
                        WHERE v.id_tdoc = ".$data['tdoc']." AND v.nro_doc BETWEEN ? AND ?
                        GROUP BY v.id_ven");
                    $stm->execute(array($desde,$hasta));
                }else{
                    $stm = $this->db->prepare("SELECT v.id_cli, v.desc_td, v.ser_doc, v.nro_doc, v.fec_ven, v.id_ven, v.enviado_sunat, v.estado,IFNULL((v.total+v.comis_del-v.desc_monto),0) AS total 
                        FROM v_ventas_con AS v 
                        WHERE v.id_tdoc = ".$data['tdoc']." AND v.nro_doc = ?
                        GROUP BY v.id_ven");
                    $stm->execute(array($desde));
                }
            }

            $c = $stm->fetchAll(PDO::FETCH_OBJ);
            foreach($c as $k => $d)
            {
                $c[$k]->{'Cliente'} = $this->db->query("SELECT dni,ruc,nombre FROM v_clientes WHERE id_cliente = ".$d->id_cli)
                    ->fetch(PDO::FETCH_OBJ);
            }
            foreach($c as $k => $d)
            {
                $codComp = array('BOLETA DE VENTA'=> "03", "FACTURA" => '01');
                $form_params = [
                    'numRuc' => $empresa['ruc'],
                    'codComp' => $codComp[$d->desc_td],
                    'numeroSerie' => $d->ser_doc,
                    'numero' => $d->nro_doc,
                    'fechaEmision' => date('d/m/Y',strtotime($d->fec_ven)),
                    'monto' => $d->total,
                ];
                $c[$k]->{'Estado_Sunat'} = $this->search($form_params);
            }
            $data = array("data" => $c);
            $json = json_encode($data);
            echo $json;       
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
    /* funcion consulta key para el validador   */
    public function api_validador()
    {
        $empresa = $this->Empresa();
        $GRANT_TYPE = 'client_credentials';
        $SCOPE = 'https://api.sunat.gob.pe/v1/contribuyente/contribuyentes';

        $curl = curl_init();
            
        $form_params = [
            'grant_type' => $GRANT_TYPE,
            'scope' => $SCOPE,
            'client_id' => $empresa['client_id'] ,
            'client_secret' => $empresa['client_secret'], 
        ];

        curl_setopt_array($curl, array(
            CURLOPT_URL => "https://api-seguridad.sunat.gob.pe/v1/clientesextranet/".$empresa['client_id']."/oauth2/token",
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 0,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'POST',
            CURLOPT_POSTFIELDS => http_build_query($form_params),
            CURLOPT_HTTPHEADER => array(
                'Content-Type: application/x-www-form-urlencoded',
            ),
        ));

        $response = curl_exec($curl);

        curl_close($curl);
        $data = json_decode($response, true);

        if(array_key_exists('access_token', $data)){
            
            return [
                'success' => true,
                'data' => [
                    'access_token' => $data['access_token'],
                    'token_type' => $data['token_type'],
                    'expires_in' => $data['expires_in'],
                ],
            ];
        }

        $error_description = $data['error_description'] ?? '';
        $error = $data['error'] ?? '';
        
        return [
            'success' => false,
            'message' => 'Error al obtener token - error_description: '.$error_description.' error: '.$error
        ];
    }
    /*  VALIDARA POR COMPROBANTE INDIVIDUAL */
    public function validar_cpe()
    {
        // datos y config de empresa
        $empresa = $this->Empresa();
        $rptSunat = '';
        //extramos datos del cpe
        $stm = $this->db->prepare("SELECT v.ser_doc,v.nro_doc,v.fec_ven,v.desc_td,IFNULL((v.total+v.comis_del-v.desc_monto),0) AS total 
            FROM v_ventas_con AS v 
            WHERE v.id_ven = ? AND  v.id_tdoc <> 3 GROUP BY v.id_ven");
        $stm->execute(array($_POST['id_venta']));
        $d = $stm->fetch(PDO::FETCH_OBJ);


        $codComp = array('BOLETA DE VENTA'=> "03", "FACTURA" => '01');
        $form_params = [
            'numRuc' => $empresa['ruc'],
            'codComp' => $codComp[$d->desc_td],
            'numeroSerie' => $d->ser_doc,
            'numero' => $d->nro_doc,
            'fechaEmision' => date('d/m/Y',strtotime($d->fec_ven)),
            'monto' => $d->total,
        ];

        $rptSunat = $this->search($form_params, true);

        if($rptSunat['status'] == 401){
            $response = [
                'success' => false,
                'message' => 'No autorizado, debe configurar en el modulo empresa.'
            ];
            echo json_encode($response);
            return;
        }else{
            if ($rptSunat['success'] == false) {
                $response = [
                    'success'   => $rptSunat['success'],
                    'message'   => $rptSunat['message'],
                    'errorCode' => $rptSunat['errorCode']
                ];
                echo json_encode($response);
                return;
            }
            $response = [
                'success' => true,
                'message' => 'Consultado con exito.',
                'sunat'   => $rptSunat
                // 'sistema' => $d
            ];
            echo json_encode($response);
            return;
        }
    }
    public function search($parametros, $cpe = false)
    {
        try {
            $BASE_URL = 'https://api.sunat.gob.pe/v1/contribuyente/contribuyentes';
            $empresa = $this->Empresa();
            $token   = $this->api_validador();

            $form_params = [
                'numRuc' => $parametros['numRuc'],
                'codComp' => $parametros['codComp'],
                'numeroSerie' => $parametros['numeroSerie'],
                'numero' => $parametros['numero'],
                'fechaEmision' => $parametros['fechaEmision'],
                'monto' => $parametros['monto'],
            ];


            $curl = curl_init();
            
            curl_setopt_array($curl, array(
                CURLOPT_URL => $BASE_URL."/".$empresa['ruc']."/validarcomprobante",
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_ENCODING => '',
                CURLOPT_MAXREDIRS => 10,
                CURLOPT_TIMEOUT => 0,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
                CURLOPT_CUSTOMREQUEST => 'POST',
                CURLOPT_POSTFIELDS => json_encode($form_params),
                CURLOPT_HTTPHEADER => array(
                    "Authorization: Bearer ".$token['data']['access_token'],
                    'Content-Type: application/json'
                ),
            ));
            
            $response = curl_exec($curl);
            
            curl_close($curl);

            $res = json_decode($response, true);
            if($res['success']){
                if ($cpe == true) {
                    return [
                        'success'        => $res['success'],
                        'estadoCp_id'    => $res['data']['estadoCp'],
                        'estadoCp'       => $this->estadoCp($res['data']['estadoCp']),
                        'condDomiRuc_id' => $res['data']['condDomiRuc'],
                        'condDomiRuc'    => $this->condDomiRuc($res['data']['condDomiRuc']),
                        'estadoRuc_id'   => $res['data']['estadoRuc'],
                        'estadoRuc'      => $this->estadoRuc($res['data']['estadoRuc']),
                        'observaciones'  => $res['data']['observaciones']
                    ];
                }else{
                    return $res['data']['estadoCp'] ?? null;
                }
            }

            return $res;

        } catch (Exception $e) {

            die($e->getMessage());

        }

    }

    public function estadoCp($estado)
    {
        $document_state = [
            '0' => 'NO EXISTE', //'NO EXISTE' custom code
            '1' => 'ACEPTADO', //'ACEPTADO'
            '2' => 'ANULADO', //'ANULADO'
        ];
        return $document_state[$estado];
    }
    public function estadoRuc($estado)
    {
        $company_state = [
            '-'  => '-',
            '00' => 'ACTIVO',
            '01' => 'BAJA PROVISIONAL',
            '02' => 'BAJA PROV. POR OFICIO',
            '03' => 'SUSPENSION TEMPORAL',
            '10' => 'BAJA DEFINITIVA',
            '11' => 'BAJA DE OFICIO',
            '12' => 'BAJA MULT.INSCR. Y OTROS ',
            '20' => 'NUM. INTERNO IDENTIF.',
            '21' => 'OTROS OBLIGADOS',
            '22' => 'INHABILITADO-VENT.UNICA',
            '30' => 'ANULACION - ERROR SUNAT   '
        ];
        return $company_state[$estado];
    }
    public function condDomiRuc($condicion)
    {
        $company_condition = [
            '-'  => '-',
            '00' => 'HABIDO',
            '01' => 'NO HALLADO SE MUDO DE DOMICILIO',
            '02' => 'NO HALLADO FALLECIO',
            '03' => 'NO HALLADO NO EXISTE DOMICILIO',
            '04' => 'NO HALLADO CERRADO',
            '05' => 'NO HALLADO NRO.PUERTA NO EXISTE',
            '06' => 'NO HALLADO DESTINATARIO DESCONOCIDO',
            '07' => 'NO HALLADO RECHAZADO',
            '08' => 'NO HALLADO OTROS MOTIVOS',
            '09' => 'PENDIENTE',
            '10' => 'NO APLICABLE',
            '11' => 'POR VERIFICAR',
            '12' => 'NO HABIDO',
            '20' => 'NO HALLADO',
            '21' => 'NO EXISTE LA DIRECCION DECLARADA',
            '22' => 'DOMICILIO CERRADO',
            '23' => 'NEGATIVA RECEPCION X PERSONA CAPAZ',
            '24' => 'AUSENCIA DE PERSONA CAPAZ',
            '25' => 'NO APLICABLE X TRAMITE DE REVERSION',
            '40' => 'DEVUELTO'
        ];
        return $company_condition[$condicion];
    }

    // public function getConsulta($endpoint)
    // {       
    //     $client = new SoapClient($endpoint . '?wsdl'); 
    //     $client->setCredentials(strtoupper('20000000000ABCDEFGH'), 'password');
    //     $client->setService($endpoint);
    //     $sunat = new ExtService();
    //     $sunat->setClient($client);
    //     return $sunat;
    // }

}