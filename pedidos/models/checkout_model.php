<?php

class Checkout_Model extends Model
{
	public function __construct()
	{
		parent::__construct();
	}

	public function run($data)
	{
		$stm = $this->db->prepare("SELECT id_cliente, nombre AS nombre_cliente, telefono AS telefono_cliente, direccion AS direccion_cliente, referencia AS referencia_cliente FROM v_clientes WHERE estado <> 'i' AND telefono = ?");
        $stm->execute(array($data['userlogin']));
        $c = $stm->fetchAll(PDO::FETCH_OBJ);
        return $c;
        /*
        $stm = $this->db->prepare("SELECT p.id_pedido, pd.telefono_cliente, pd.nombre_cliente, pd.direccion_cliente, pd.referencia_cliente FROM tm_pedido_delivery AS pd INNER JOIN tm_pedido AS p ON pd.id_pedido = p.id_pedido WHERE pd.telefono_cliente = ? AND pd.id_pedido = (SELECT MAX(id_pedido) FROM tm_pedido_delivery WHERE telefono_cliente = ?) GROUP BY pd.telefono_cliente LIMIT 1");
		$stm->execute(array($data['userlogin'],$data['userlogin']));
        $c = $stm->fetchAll(PDO::FETCH_OBJ);
        return $c;
        */
	}

	public function cliente_crud_create($data)
    {
        try 
        {
            $consulta = "call usp_restRegCliente( :flag, @a, :tipo_cliente, :dni, :ruc, :ape_paterno, :ape_materno, :nombres, :razon_social, :telefono, :fecha_nac, :correo, :direccion, :referencia);";
            $arrayParam =  array(
                ':flag' => 1,
                ':tipo_cliente' => 1,
                ':dni' => $data['dni'],
                ':ruc' => '',
                ':ape_paterno' => $data['ape_paterno'],
                ':ape_materno' => $data['ape_materno'],
                ':nombres' => $data['nombres'],
                ':razon_social' => '',
                ':telefono' => $data['telefono'],
                ':fecha_nac' => '',
                ':correo' => '',
                ':direccion' => $data['direccion'],
                ':referencia' => $data['referencia']
              );
            $st = $this->db->prepare($consulta);
            $st->execute($arrayParam);
            $row = $st->fetch(PDO::FETCH_ASSOC);
            return $row;
        } catch (Exception $e) 
        {
            die($e->getMessage());
        }
    }

    public function RegistrarPedido($data)
    {
        try
        {
            date_default_timezone_set('America/Lima');
            setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
            $fecha = date("Y-m-d H:i:s");

            if($data['hora_entrega'] == 2){
                $pedido_programado = '';
                $hora_entrega = '00:00:00';
            } else {
                $pedido_programado = 1;
                $hora_entrega = $data['hora_entrega'];
            }

            $consulta = "call usp_restRegDelivery( :flag, :tipo_canal, :id_tipo_pedido, :id_apc, :id_usu, :fecha_pedido, :id_cliente, :id_repartidor, :tipo_entrega, :tipo_pago, :pedido_programado, :hora_entrega, :nombre_cliente, :telefono_cliente, :direccion_cliente, :referencia_cliente, :email_cliente);";
            $arrayParam =  array(
                ':flag' => 1,
                ':tipo_canal' => 2,
                ':id_tipo_pedido' => 3,
                ':id_apc' => '',
                ':id_usu' => 1,
                ':fecha_pedido' => $fecha,
                ':id_cliente' => $data['id_cliente'],
                ':id_repartidor' => 1,
                ':tipo_entrega' => $data['tipo_entrega'],
                ':tipo_pago' => $data['tipo_pago'],
                ':pedido_programado' => $pedido_programado,
                ':hora_entrega' => $hora_entrega,
                ':nombre_cliente' => $data['nombre_cliente'],
                ':telefono_cliente' => $data['telefono_cliente'],
                ':direccion_cliente' => $data['direccion_cliente'],
                ':referencia_cliente' => $data['referencia_cliente'],
                ':email_cliente' => $data['email_cliente']
            );
            $st = $this->db->prepare($consulta);
            $st->execute($arrayParam);

            while ($row = $st->fetch(PDO::FETCH_ASSOC)) {
                $id_pedido = $row['id_pedido'];
            }

            $this->db = new Database(DB_TYPE, DB_HOST, DB_NAME, DB_USER, DB_PASS, DB_CHARSET);

            foreach($data['detalle_pedido'] as $d)
            {
                $sql = "INSERT INTO tm_detalle_pedido (id_pedido, id_usu, id_pres, cantidad, cant, precio, comentario, fecha_pedido,estado) VALUES (?,?,?,?,?,?,?,?,?);";
                $this->db->prepare($sql)->execute(array(
                    $id_pedido,
                    1,
                    $d['id'],
                    $d['cantidad'],
                    $d['cantidad'],
                    $d['precio'],
                    $d['nota'],
                    $fecha,
                    'y'));
            }

            /*
            $sql2 = "UPDATE tm_cliente SET telefono = ?, correo = ?, direccion = ?, referencia = ? WHERE id_cliente = ?";
            $this->db->prepare($sql2)->execute(array($data['telefono_cliente'],$data['email_cliente'], $data['direccion_cliente'], $data['referencia_cliente'], $data['id_cliente']));
            */
            
            return;

        } catch (Exception $e) 
        {
            die($e->getMessage());
        }
    }  
}