<?php

class Menu_Model extends Model
{
	public function __construct()
	{
		parent::__construct();
	}

    public function listarCategorias()
    {
        try
        {      
            return $this->db->selectAll("SELECT * FROM tm_producto_catg WHERE estado = 'a' AND delivery = 1");
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function listarProductos($data)
    {
        try
        {   
            $stm = $this->db->prepare("SELECT * FROM v_productos WHERE del_a = 1 AND del_b = 1 AND del_c = 1 AND est_a = 'a' AND est_b = 'a' AND id_catg = ? ORDER BY id_pres ASC");
            $stm->execute(array($data['id_catg']));
            $c = $stm->fetchAll(PDO::FETCH_OBJ);
            return $c;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
}