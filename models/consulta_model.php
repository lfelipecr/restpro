<?php

class Consulta_Model extends Model
{
    public function __construct()
    {
        parent::__construct();
    }
	public function datosempresa_data()
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

    public function buscar($data)
    {
        try
        {
            error_reporting(0);
            $fecha = date('Y-m-d',strtotime($data['fecha']));

            $empresa    = $this->db->selectOne("SELECT ruc, modo FROM tm_empresa");
            $id_cliente = $this->db->selectOne("SELECT * FROM tm_cliente WHERE ruc LIKE '{$data['numero_cliente']}' OR dni LIKE '{$data['numero_cliente']}' LIMIT 1");
            $comprobante = $this->db->prepare("SELECT * FROM tm_venta WHERE DATE(fecha_venta) = ? AND id_tipo_doc = ? AND total = ? AND serie_doc = ? AND nro_doc LIKE ?  AND id_cliente LIKE ?");

            $comprobante->execute(array($fecha, $data['tipo_comprobante'], $data['monto_total'], $data['serie'] , $data['numero'], $id_cliente['id_cliente']));
            $c = $comprobante->fetch(PDO::FETCH_ASSOC);


            if ($c) {

                $url_entorno =  URL.'api_fact/UBL21/archivos_xml_sunat/cpe_xml/'.(($empresa['modo'] == 1)?'produccion':'beta').'/'.$empresa['ruc'].'/';
                $url_pdf     =  URL.'comprobante/ticket/'.base64_encode($c['id_venta']);

                return $arr  = [
                    "cliente"       => ($id_cliente['ruc'])? $id_cliente['ruc'] : $id_cliente['dni'] ,
                    "id_venta"       => $c['id_venta'] ,
                    "comprobante"   => $c['serie_doc']."-".$c['nro_doc'],
                    "total"         => $c['total'],
                    "url_xml"       => $url_entorno."".$c['name_file_sunat'].".XML", 
                    "url_cdr"       => $url_entorno."R-".$c['name_file_sunat'].".XML",
                    "url_pdf"       => $url_pdf,
                ];
            } else {
                return FALSE;
            }
            
        }
        catch(Exception $e)
        {
            die($e->getMessage());
        }
    }
}
