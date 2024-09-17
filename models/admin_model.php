<?php Session::init(); /*add*/?>
<?php

class Admin_Model extends Model
{
    public function __construct()
    {
        parent::__construct();
    }

    public function seguridad($token){
        
        try
        {
            $mesa = $this->db->prepare("SELECT * FROM token WHERE token = '".$token."' and estado = 'a'");
            $mesa->execute();
            $m = $mesa->fetchColumn();
            return $m;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }

    }

    // bloqueoplataforma
    public function bloqueoplataforma($accion)
    {
        try
        {    

            $stm = $this->db->prepare("UPDATE tm_configuracion SET bloqueo = ? WHERE tm_configuracion.id_cfg = '1' ");
            $stm->execute(array($accion));

            if($stm){
                // Session::set('bloqueo_id', $data['tipo_bloqueo']); 
                return [
                    'success' => true,
                    'message' => ($accion==1) ? 'Se bloqueó el cliente exitosamente.' : 'Se desbloqueó el cliente exitosamente',
                ];
            }else{
                return [
                    'success' => false,
                    'message' => 'Error al ejecutar acción.',
                ];
            }
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
    // fin bloqueoplataforma


    /* INICIO COMPROBANTE SIN ENVIAR SUNAT */

    public function datosEmpresa()
    {
        try
        {
            $ds = $this->db->prepare("SELECT bloqueo FROM tm_configuracion");
            $ds->execute();
            $data_s = $ds->fetch();

            //comprobantes sin enviar
            $stm = $this->db->prepare("SELECT COUNT(v.id_ven) AS sinenviar FROM v_ventas_con AS v INNER JOIN v_caja_aper AS c ON v.id_apc = c.id_apc INNER JOIN tm_tipo_doc AS d ON v.id_tdoc = d.id_tipo_doc WHERE v.ser_doc = d.serie AND v.id_tdoc <> 3 AND v.estado = 'a' AND (v.enviado_sunat = '' OR v.enviado_sunat = '0' OR v.enviado_sunat IS NULL)");
            $stm->execute();        
            $c = $stm->fetch(PDO::FETCH_OBJ);

            //comprobantes sin enviar
            $tdoc = $this->db->prepare("SELECT COUNT(v.id_ven) AS total_doc FROM v_ventas_con AS v INNER JOIN v_caja_aper AS c ON v.id_apc = c.id_apc INNER JOIN tm_tipo_doc AS d ON v.id_tdoc = d.id_tipo_doc WHERE v.ser_doc = d.serie AND v.id_tdoc <> 3 AND v.estado = 'a'");
            $tdoc->execute();        
            $tdoc_ = $tdoc->fetch(PDO::FETCH_OBJ);
            
            //notas de ventas
            $notv = $this->db->prepare("SELECT COUNT(v.id_ven) AS notas FROM v_ventas_con AS v INNER JOIN v_caja_aper AS c ON v.id_apc = c.id_apc INNER JOIN tm_tipo_doc AS d ON v.id_tdoc = d.id_tipo_doc WHERE v.ser_doc = d.serie AND v.id_tdoc = 3 AND v.estado = 'a'");
            $notv->execute();        
            $notv_ = $notv->fetch(PDO::FETCH_OBJ);

            //ultimo login
            $llog = $this->db->prepare("SELECT nombres, fecha_login FROM tm_usuario WHERE fecha_login IS NOT NULL ORDER BY fecha_login DESC LIMIT 1");
            $llog->execute();        
            $llog_ = $llog->fetch(PDO::FETCH_OBJ);

            $resultados = array('sinenviar' => $c->sinenviar, 'total_doc' => $tdoc_->total_doc, 'total_nv' => $notv_->notas, 'last_login' => $llog_);

            return $resultados;

        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    /* FIN COMPROBANTE SIN ENVIAR SUNAT */

    public function cron($data)
    {
        try 
        {
            Session::set('rol', '2');
            require_once 'api_fact/controller/api.php';
            $db = new Database(DB_TYPE, DB_HOST, DB_NAME, DB_USER, DB_PASS, DB_CHARSET);
            $ds = $db->prepare("SELECT * FROM tm_venta WHERE estado <> 'i' AND id_tipo_doc != '3' AND (enviado_sunat is null or enviado_sunat = '0') ORDER BY id_venta DESC");
            $ds->execute();
            $data_s = $ds->fetchAll();
            $rspta = [];
            if (count($data_s) > 0) {
                foreach($data_s as $row):
                    $cod_ven = $row['id_venta'];
                    $invoice = new ApiSunat();
                    $data = $invoice->sendDocSunaht($cod_ven,1); 
                    $rspta = json_decode($data);
                endforeach;
                echo $rspta;
            }else{
                echo "No hay comprobantes por enviar";
            }
        }
        catch (Exception $e) 
        {
            return false;
        }
    }

    /* INICIO PEDIDOS PREPARADOS */

    public function contadorPedidosPreparados()
    {
        try
        {      
            if(Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3){
                $stm = $this->db->prepare("SELECT COUNT(id_pedido) AS cantidad FROM v_cocina_me WHERE id_tipo = 1 AND cantidad > 0 AND estado = 'c'");
                $stm->execute();   
            } elseif(Session::get('rol') == 5){
                $stm = $this->db->prepare("SELECT COUNT(id_pedido) AS cantidad FROM v_cocina_me WHERE id_tipo = 1 AND id_mozo = ? AND cantidad > 0 AND estado = 'c'");
                $stm->execute(array(Session::get('usuid')));   
            }
            $stm->execute();            
            $c = $stm->fetchAll(PDO::FETCH_OBJ);
            return $c;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function listarPedidosPreparados()
    {
        try
        {      
            if(Session::get('rol') == 1 OR Session::get('rol') == 2 OR Session::get('rol') == 3){
                $stm = $this->db->prepare("SELECT * FROM v_cocina_me WHERE id_tipo = 1 AND cantidad > 0 AND estado = 'c'");
                $stm->execute();   
            } elseif(Session::get('rol') == 5){
                $stm = $this->db->prepare("SELECT * FROM v_cocina_me WHERE id_tipo = 1 AND id_mozo = ? AND cantidad > 0 AND estado = 'c'");
                $stm->execute(array(Session::get('usuid')));   
            } 
            $c = $stm->fetchAll(PDO::FETCH_OBJ);
            $data = array("data" => $c);
            $json = json_encode($data);
            echo $json;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function pedidoEntregado($data)
    {
        try
        {   
            $sql = "UPDATE tm_detalle_pedido SET estado = 'd' WHERE id_pedido = ? AND id_pres = ? AND fecha_pedido = ?";
            $this->db->prepare($sql)
              ->execute(array(
                $data['id_pedido'],
                $data['id_pres'],
                $data['fecha_pedido']
                ));
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function pedido_estado_update($data)
    {
        try 
        {
            if($data['estado']=='i'){$estado='p';}elseif($data['estado']=='p'){$estado='i';};
            $sql = "UPDATE tm_mesa SET estado = ? WHERE id_mesa = ?";
            $this->db->prepare($sql)->execute(array($estado,$data['id_mesa']));
        }
        catch (Exception $e) 
        {
            return false;
        }
    }

    /* FIN PEDIDOS PREPARADOS */


    /* FIN PEDIDOS PREPARADOS */

}

