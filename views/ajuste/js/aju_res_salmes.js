$(function() {
    $('#config').addClass("active");
    listarSalones();
});

/* Mostrar datos en la tabla salones */ 
var listarSalones = function(){

    function filterGlobal () {
        $('#table01').DataTable().search( 
            $('#global_filter_01').val()
        ).draw();
    }

    var table = $('#table01')
    .DataTable({
        "destroy": true,
        "responsive": true,
        "dom": "tip",
        "bSort": true,
        "order": true,
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"ajuste/salon_list"
        },
        "columns":[
            {"data":"descripcion"},
            {"data":"Mesas.total"},
            {"data":null,"render": function ( data, type, row) {
                if(data.estado == 'a'){
                  return '<span class="label label-success">ACTIVO</span>';
                } else if (data.estado == 'i'){
                  return '<span class="label label-danger">INACTIVO</span>';
                }
            }},
            {"data":null,"render": function ( data, type, row ) {
                return '<div class="text-right"><a href="javascript:void(0)" class="text-primary config" style="margin-top:5px" onclick="ordenarMesas('+data.id_salon+',\''+data.descripcion+'\');"><i class="fa fa-cogs fill-white"></i></a>&nbsp;'
                +'<a href="javascript:void(0)" class="text-success edit" onclick="listarMesas('+data.id_salon+',\''+data.descripcion+'\');"><i data-feather="eye" class="feather-sm fill-white"></i></a>'
                    +'&nbsp;<a href="javascript:void(0)" class="text-info edit ms-2" onclick="editarSalon('+data.id_salon+',\''+data.descripcion+'\',\''+data.abreviatura+'\',\''+data.estado+'\');"><i data-feather="edit" class="feather-sm fill-white"></i></a>'
                    +'&nbsp;<a href="javascript:void(0)" class="text-danger delete ms-2" onclick="eliminarSalon('+data.id_salon+',\''+data.descripcion+'\');"><i data-feather="trash-2" class="feather-sm fill-white"></i></a></div>';
            }}
        ]
    });

    $('input.global_filter_01').on( 'keyup click', function () {
        filterGlobal();
    });

    $('#table01').DataTable().on("draw", function(){
        feather.replace();
    });
}

/* Mostrar datos en la tabla mesas */ 
var listarMesas = function(id_salon,descripcion){
    var mesaNueva = '';
    /* Ocultar panel mensaje 'seleccione un salon' */
    $('#lizq-s').css("display","none");
    $('#ordenar-m').css("display","none");
    /* Mostrar tabla mesas por salon */ 
    $('#lizq-i').css("display","block");
    $('#btn-nuevo').html('<button type="button" class="btn btn-circle btn-lg btn-orange waves-effect waves-dark" onclick="editarMesa('+mesaNueva+');"><i class="ti-plus"></i></button>');
    $('#id_salon_1').val(id_salon);
    $('#title-mesa').text(descripcion);

    function filterGlobal () {
        $('#table02').DataTable().search( 
            $('#global_filter_02').val()
        ).draw();
    }

    var table = $('#table02')
    .DataTable({
        "destroy": true,
        "responsive": true,
        "dom": "tip",
        "bSort": true,
        "ajax":{
            "method": "POST",
            "url": $('#url').val()+"ajuste/mesa_list",
            "data": { id_salon : id_salon }
        },
        "columns":[
            {"data":"nro_mesa"},
            {"data":"Salon.descripcion"},
            {"data":null,"render": function ( data, type, row) {
                if(data.estado == 'a'){
                  return '<span class="label label-success">ACTIVO</span>';
                } else if (data.estado == 'i' || data.estado == 'p'){
                  return '<span class="label label-warning">OCUPADO</span>'
                }
                else if (data.estado == 'm'){
                  return '<span class="label label-danger">INACTIVO</span>'
                } 
            }},
            {"data":null,"render": function ( data, type, row) {
                if(data.forma == 2){
                  return '<span class="label label-info">REDONDO</span>';
                } else {
                  return '<span class="label label-primary">CUADRADO</span>'
                } 
            }},
            {"data":null,"render": function ( data, type, row ) {
                return '<div class="text-right"><a href="javascript:void(0)" class="text-info edit" onclick="editarMesa('+data.id_mesa+',\''+data.nro_mesa+'\',\''+data.forma+'\',\''+data.estado+'\');"><i data-feather="edit" class="feather-sm fill-white"></i></a>'
                    +'&nbsp;<a href="javascript:void(0)" class="text-danger delete ms-2" onclick="eliminarMesa('+data.id_mesa+',\''+data.nro_mesa+'\');"><i data-feather="trash-2" class="feather-sm fill-white"></i></a></div>';
            }}
        ]
    });

    $('input.global_filter_02').on('keyup click', function () {
        filterGlobal();
    });

    $('#table02').DataTable().on("draw", function(){
        feather.replace();
    });
}

/* Mostrar para ordenar con ubicacion en la tabla mesas */ 
var guardarDisenio = function(id_salon,descripcion){
    // console.log("ddd")
    // var data_json = canvas.objects
    console.log(canvas)
    console.log(canvas._objects)
    console.log(canvas.toJSON())
    // canvas.toJSON()
}


/* Mostrar para ordenar con ubicacion en la tabla mesas */ 
var ordenarMesas = function(id_salon,descripcion){
    // alert("d")
    var mesaNueva = '';
    /* Ocultar panel mensaje 'seleccione un salon' */
    $('#lizq-i').css("display","none");
    $('#lizq-s').css("display","none");
    $('#ordenar-m').css("display","block");
    $('#id_salon_1').val(id_salon);
    $('#title-mesa2').text(descripcion);
    
    $.ajax({
        url: $('#url').val()+"ajuste/mesa_list",
        type: 'POST',
        data: {id_salon: id_salon},
        dataType: 'json'
    })
    .done(function(response){
        console.log(response.data)

        var data_mesas = response.data

        $( "#contenedor_mesas" ).html('')

        $.each(data_mesas, function(i, mesa) {
            $( "#contenedor_mesas" ).append('<div id="draggable" class="btn btn-green btn-mesa" idmesa="'+mesa.id_mesa+'">'+mesa.nro_mesa+'</div>');
            // $( "#contenedor_mesas" ).append('<div id="draggable_'+mesa.id_mesa+'" class="btn btn-green btn-mesa" idmesa="'+mesa.id_mesa+'">'+mesa.nro_mesa+'</div>');
        });

// console.log(localStorage.positions)
        if (localStorage.positions) {
            var positions = JSON.parse(localStorage.positions);
        }else{
        var positions = JSON.parse("{}");
        }
        $(function() {

        setTimeout(() => {
        
                var d = $("[id=draggable]").attr("id", function(i) {
                    return "draggable_" + i
                })
// console.log(d)
                $.each(positions, function(id, pos) {
                    if (positions != undefined) {
                        if (pos.valueOf.length != undefined) {
                            $("#" + id).css('width',pos.size ? pos.size.width : 100)
                            $("#" + id).css('height',pos.size ? pos.size.height : 100)
                            $("#" + id).css('left',pos.position ? pos.position.left : 0)
                            $("#" + id).css('top',pos.position ? pos.position.top : 0)
                        }
                    }
                })

                d.resizable({
                    containment: "#contenedor_mesas",
                    stop: function(event, ui) {
                        if (positions[this.id] == undefined) {
                            positions[this.id] = {}
                            positions[this.id].size = {}
                        }
                        positions[this.id].size = ui.size
                        localStorage.positions = JSON.stringify(positions)
                        console.log(positions)
                    }
                })
                d.draggable({
                    containment: "#contenedor_mesas",
                    scroll: false,
                    stop: function(event, ui) {
                        if (positions[this.id] == undefined) {
                            positions[this.id] = {}
                            positions[this.id].position = {}
                        }
                        console.log(ui)
                        positions[this.id].position = ui.position
                        localStorage.positions = JSON.stringify(positions)
                        console.log(positions)
                    }
                });
            }, 1000);
        });
    })
    .fail(function(){
        Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
    });

// console.log(id_salon)
}

/* Editar datos del salon */
var editarSalon = function(id_salon,descripcion,abreviatura,estado){
    $(".f").addClass("focused");
    $('#id_salon').val(id_salon);
    $('#descripcion').val(descripcion);
    $('#abreviatura').val(abreviatura);
    $('#estado').selectpicker('val', estado);    
    $("#modal01").modal('show');
}

var eliminarSalon = function(id_salon,descripcion){
    var html_confirm = '<div>Se eliminará el siguiente salón:<br>'+descripcion+'</div>\
        <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
    Swal.fire({
        title: 'Necesitamos de tu Confirmación',
        html: html_confirm,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true,
        preConfirm: function() {
            return new Promise(function(resolve) {
                $.ajax({
                    url: $('#url').val()+'ajuste/salon_crud_delete',
                    type: 'POST',
                    data: {id_salon: id_salon},
                    dataType: 'json'
                })
                .done(function(cod){
                    if(cod == 1){
                        listarSalones();
                        $('#table02 tbody').remove();
                        $('#lizq-s').css("display","block");
                        $('#lizq-i').css("display","none");
                        Swal.fire({   
                            title:'Proceso Terminado',   
                            text: 'Datos eliminados correctamente',
                            icon: "success", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    } else if(cod == 0){
                        Swal.fire({   
                            title:'Proceso No Culminado',   
                            text: 'Datos protegidos',
                            icon: "error", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    }
                })
                .fail(function(){
                    Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
                });
            });
        },
        allowOutsideClick: false              
    });
}

/* Editar datos de la mesa*/
var editarMesa = function(id_mesa,nro_mesa,forma,estado){
    $(".f").addClass("focused");
    $('#id_mesa').val(id_mesa);
    $('#nro_mesa').val(nro_mesa);
    $('#forma').selectpicker('val', forma);
    $('#estado_1').selectpicker('val', estado);
    $("#modal02").modal('show');
}

/* Eliminar mesa */
var eliminarMesa = function(id_mesa,nro_mesa){
    var html_confirm = '<div>Se eliminará la sigueinte mesa:<br>'+nro_mesa+'</div>\
        <div><span class="text-success" style="font-size: 17px;">¿Está Usted de Acuerdo?</span></div>';
    Swal.fire({
        title: 'Necesitamos de tu Confirmación',
        html: html_confirm,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#34d16e',
        confirmButtonText: 'Si, Adelante!',
        cancelButtonText: "No!",
        showLoaderOnConfirm: true,
        preConfirm: function() {
            return new Promise(function(resolve) {
                $.ajax({
                    url: $('#url').val()+'ajuste/mesa_crud_delete',
                    type: 'POST',
                    data: {
                        id_salon: $('#id_salon_1').val(),
                        id_mesa: id_mesa
                    },
                    dataType: 'json'
                })
                .done(function(cod){
                    if(cod == 1){
                        listarSalones();
                        listarMesas($('#id_salon_1').val());
                        Swal.fire({   
                            title:'Proceso Terminado',   
                            text: 'Datos eliminados correctamente',
                            icon: "success", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    } else if(cod == 0){
                        Swal.fire({   
                            title:'Proceso No Culminado',   
                            text: 'Datos protegidos',
                            icon: "error", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    }
                })
                .fail(function(){
                    Swal.fire('Oops...', 'Problemas con la conexión a internet!', 'error');
                });
            });
        },
        allowOutsideClick: false              
    });
}

$(function() {
    $('#form01')
      .formValidation({
          framework: 'bootstrap',
          excluded: ':disabled',
          fields: {
          }
      })
      .on('success.form.fv', function(e) {

          e.preventDefault();
          var $form = $(e.target),
          fv = $form.data('formValidation');
          
          var form = $(this);

          var salones = {
            id_salon: 0,
            descripcion: 0,
            abreviatura: 0,
            estado: 0
          }

          salones.id_salon = $('#id_salon').val();
          salones.descripcion = $('#descripcion').val();
          salones.abreviatura = $('#abreviatura').val();
          salones.estado = $('#estado').val();

          $.ajax({
              dataType: 'JSON',
              type: 'POST',
              url: $('#url').val()+'ajuste/salon_crud',
              data: salones,
              success: function (cod) {
                    if(cod == 0){
                        Swal.fire({   
                            title:'Proceso No Culminado',   
                            text: 'Datos duplicados',
                            icon: "error", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    } else if(cod == 1){
                        listarSalones();
                        $('#modal01').modal('hide');
                        $('#title-mesa').text(salones.descripcion);
                        $('#table02 tbody').remove();
                        /* Mostrar panel mensaje 'seleccione un salon' */
                        $('#lizq-s').css("display","block");
                        /* Ocultar tabla mesas */
                        $('#lizq-i').css("display","none");
                        Swal.fire({   
                            title:'Proceso Terminado',   
                            text: 'Datos registrados correctamente',
                            icon: "success", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    } else if(cod == 2) {
                        listarSalones();
                        $('#modal01').modal('hide');
                        $('#title-mesa').text(salones.descripcion);
                        $('#table02 tbody').remove();
                        /* Mostrar panel mensaje 'seleccione un salon' */
                        $('#lizq-s').css("display","block");
                        /* Ocultar tabla mesas */
                        $('#lizq-i').css("display","none");
                        Swal.fire({   
                            title:'Proceso Terminado',   
                            text: 'Datos actualizados correctamente',
                            icon: "success", 
                            confirmButtonColor: "#34d16e",   
                            confirmButtonText: "Aceptar",
                            allowOutsideClick: false,
                            showCancelButton: false,
                            showConfirmButton: true
                        }, function() {
                            return false
                        });
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    console.log(errorThrown + ' ' + textStatus);
                }   
          });

        return false;

      });

    $('#form02')
      .formValidation({
          framework: 'bootstrap',
          excluded: ':disabled',
          fields: {
          }
      })
      .on('success.form.fv', function(e) {

          e.preventDefault();
          var $form = $(e.target),
          fv = $form.data('formValidation');
          
          var form = $(this);

          var mesas = {
            id_mesa: 0,
            id_salon: 0,
            nro_mesa: 0,
            estado: 0
          }

          mesas.id_mesa = $('#id_mesa').val();
          mesas.id_salon = $('#id_salon_1').val();
          mesas.nro_mesa = $('#nro_mesa').val();
          mesas.forma = $('#forma').val();
          mesas.estado = $('#estado_1').val();

          $.ajax({
              dataType: 'JSON',
              type: 'POST',
              url: $('#url').val()+'ajuste/mesa_crud',
              data: mesas,
              success: function (cod) {
                  if(cod == 0){
                    Swal.fire({   
                        title:'Proceso No Culminado',   
                        text: 'Datos duplicados',
                        icon: "error", 
                        confirmButtonColor: "#34d16e",   
                        confirmButtonText: "Aceptar",
                        allowOutsideClick: false,
                        showCancelButton: false,
                        showConfirmButton: true
                    }, function() {
                        return false
                    });
                  } else if(cod == 1){
                    $('#modal02').modal('hide');
                    listarSalones();
                    listarMesas(mesas.id_salon);
                    Swal.fire({   
                        title:'Proceso Terminado',   
                        text: 'Datos registrados correctamente',
                        icon: "success", 
                        confirmButtonColor: "#34d16e",   
                        confirmButtonText: "Aceptar",
                        allowOutsideClick: false,
                        showCancelButton: false,
                        showConfirmButton: true
                    }, function() {
                        return false
                    });
                  } else if(cod == 2) {
                    $('#modal02').modal('hide');
                    listarSalones();
                    listarMesas(mesas.id_salon);
                    Swal.fire({   
                        title:'Proceso Terminado',   
                        text: 'Datos actualizados correctamente',
                        icon: "success", 
                        confirmButtonColor: "#34d16e",   
                        confirmButtonText: "Aceptar",
                        allowOutsideClick: false,
                        showCancelButton: false,
                        showConfirmButton: true
                    }, function() {
                        return false
                    });
                  }
              },
              error: function(jqXHR, textStatus, errorThrown){
                  console.log(errorThrown + ' ' + textStatus);
              }   
          });

        return false;

    });
});

$('#modal01').on('hidden.bs.modal', function() {
    $(this).find('form')[0].reset();
    $('#form01').formValidation('resetForm', true);
    $("#estado").selectpicker('val', 'a');
});

$('#modal02').on('hidden.bs.modal', function() {
    $(this).find('form')[0].reset();
    $('#form02').formValidation('resetForm', true);
    $("#estado_1").selectpicker('val', 'a');
});


function addRect(left, top, width, height) {
  const id = generateId()
  const o = new fabric.Rect({
    width: width,
    height: height,
    fill: tableFill,
    stroke: tableStroke,
    strokeWidth: 2,
    shadow: tableShadow,
    originX: 'center',
    originY: 'center',
    centeredRotation: true,
    snapAngle: 45,
    selectable: true
  })
  const t = new fabric.IText(number.toString(), {
    fontFamily: 'Calibri',
    fontSize: 14,
    fill: '#fff',
    textAlign: 'center',
    originX: 'center',
    originY: 'center'
  })
  const g = new fabric.Group([o, t], {
    left: left,
    top: top,
    centeredRotation: true,
    snapAngle: 45,
    selectable: true,
    type: 'table',
    id: id,
    number: number
  })
  canvas.add(g)
  number++
  // console.log(g)
  return g
}

function addCircle(left, top, radius) {
  const id = generateId()
  const o = new fabric.Circle({
    radius: radius,
    fill: tableFill,
    stroke: tableStroke,
    strokeWidth: 2,
    shadow: tableShadow,
    originX: 'center',
    originY: 'center',
    centeredRotation: true
  })
  const t = new fabric.IText(number.toString(), {
    fontFamily: 'Calibri',
    fontSize: 14,
    fill: '#fff',
    textAlign: 'center',
    originX: 'center',
    originY: 'center'
  })
  const g = new fabric.Group([o, t], {
    left: left,
    top: top,
    centeredRotation: true,
    snapAngle: 45,
    selectable: true,
    type: 'table',
    id: id,
    number: number
  })
  canvas.add(g)
  number++
  return g
}

function addChair(left, top, width, height) {
  const o = new fabric.Rect({
    left: left,
    top: top,
    width: 30,
    height: 30,
    fill: chairFill,
    stroke: chairStroke,
    strokeWidth: 2,
    shadow: chairShadow,
    originX: 'left',
    originY: 'top',
    centeredRotation: true,
    snapAngle: 45,
    selectable: true,
    type: 'chair',
    id: generateId()
  })
  canvas.add(o)
  return o
}

function addBar(left, top, width, height) {
  const o = new fabric.Rect({
    width: width,
    height: height,
    fill: barFill,
    stroke: barStroke,
    strokeWidth: 2,
    shadow: barShadow,
    originX: 'center',
    originY: 'center',
    type: 'bar',
    id: generateId()
  })
  const t = new fabric.IText(barText, {
    fontFamily: 'Calibri',
    fontSize: 14,
    fill: '#fff',
    textAlign: 'center',
    originX: 'center',
    originY: 'center'
  })
  const g = new fabric.Group([o, t], {
    left: left,
    top: top,
    centeredRotation: true,
    snapAngle: 45,
    selectable: true,
    type: 'bar'
  })
  canvas.add(g)
  return g
}

function addWall(left, top, width, height) {
  const o = new fabric.Rect({
    left: left,
    top: top,
    width: width,
    height: height,
    fill: wallFill,
    stroke: wallStroke,
    strokeWidth: 2,
    shadow: wallShadow,
    originX: 'left',
    originY: 'top',
    centeredRotation: true,
    snapAngle: 45,
    selectable: true,
    type: 'wall',
    id: generateId()
  })
  canvas.add(o)
  // console.log(canvas.objects)
  return o
}

function snapToGrid(target) {
  target.set({
    left: Math.round(target.left / (grid / 2)) * grid / 2,
    top: Math.round(target.top / (grid / 2)) * grid / 2
  })
}

function checkBoudningBox(e) {
  const obj = e.target

  if (!obj) {
    return
  }
  obj.setCoords()

  const objBoundingBox = obj.getBoundingRect()
  if (objBoundingBox.top < 0) {
    obj.set('top', 0)
    obj.setCoords()
  }
  if (objBoundingBox.left > canvas.width - objBoundingBox.width) {
    obj.set('left', canvas.width - objBoundingBox.width)
    obj.setCoords()
  }
  if (objBoundingBox.top > canvas.height - objBoundingBox.height) {
    obj.set('top', canvas.height - objBoundingBox.height)
    obj.setCoords()
  }
  if (objBoundingBox.left < 0) {
    obj.set('left', 0)
    obj.setCoords()
  }
}

function sendLinesToBack() {
  canvas.getObjects().map(o => {
    if (o.type === 'line') {
      canvas.sendToBack(o)
    }
  })
}


