<?php

class Pedidos_Model extends Model
{
	public function __construct()
	{
		parent::__construct();
	}

    public function pedidos_list($data)
    {
        try
        {   
            if($data['estado'] == 'd'){
                $estado = " AND estado_pedido = 'd'";
            }else{
                $estado = " AND estado_pedido <> 'd'";
            }

            $stm = $this->db->prepare("SELECT * FROM v_pedido_delivery WHERE telefono_cliente = ?".$estado);
            $stm->execute(array($data['telefono_cliente']));
            $c = $stm->fetchAll(PDO::FETCH_OBJ);
            foreach($c as $k => $d)
            {
                $c[$k]->{'Monto'} = $this->db->query("SELECT IFNULL(SUM(precio*cantidad),0) AS total FROM v_det_delivery WHERE estado <> 'z' AND id_pedido = " . $d->id_pedido)
                    ->fetch(PDO::FETCH_OBJ);
            }          
            $datos = array("data" => $c);
            $json = json_encode($datos);
            echo $json; 
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function pedidos_productos_list($data)
    {
        try
        {   
            $stm = $this->db->prepare("SELECT d.cantidad, d.precio, d.nombre_prod, d.pres_prod, p.estado FROM v_det_delivery AS d INNER JOIN tm_pedido AS p ON d.id_pedido = p.id_pedido WHERE d.id_pedido = ?");
            $stm->execute(array($data['id_pedido']));
            $c = $stm->fetchAll(PDO::FETCH_OBJ);          
            return $c;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
}