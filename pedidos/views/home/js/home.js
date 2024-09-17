$(function() {
    listarCategorias();
});

var listarCategorias = function(){
    $('.category-list').empty();
    $.ajax({
    	async: false,
        dataType: 'JSON',
        type: 'POST',
        url: $('#url').val()+'home/listarCategorias',
        success: function (data) {
            $.each(data, function(i, item) {
                $('.category-list')
                .append(
                    $('<div class="menu-sample"/>')
                    .html('<a href="'+$('#url').val()+'menu#'+((item.descripcion).replace(/ /g, "")).toLowerCase()+'">'
	                        +'<img src="'+$("#url2").val()+'public/images/productos/'+item.imagen+'" alt="" class="image" style="height:400px; opacity: 0.5;">'
	                        +'<h6 class="title">'+(item.descripcion).substr(0,1).toUpperCase()+(item.descripcion).substr(1).toLowerCase()+'<br><span class="badge badge-success font-16">PÍDELO YA</span></h6>'
	                    +'</a>')
                );
            });
        }
    });
}

