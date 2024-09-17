<?php

class Home_Model extends Model
{
	public function __construct()
	{
		parent::__construct();
	}

	public function listarCategorias()
    {
        try
        {   
            $stm = $this->db->prepare("SELECT * FROM tm_producto_catg WHERE estado = 'a' AND delivery = 1");
            $stm->execute();
            $c = $stm->fetchAll(PDO::FETCH_OBJ);
            return $c;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }

    public function defaultdata()
    {
        try
        {   
            $stm = $this->db->prepare("SELECT * FROM tm_empresa");
            $stm->execute();
            $c = $stm->fetch(PDO::FETCH_OBJ);
            return $c;
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
}