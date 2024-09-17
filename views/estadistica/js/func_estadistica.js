$(function() {  
    $('#estadistica').addClass("active");
    moment.locale('es');
    const hoy = moment();
    const day = moment();
    const mes = hoy.format('M');
    const anio = hoy.format('YYYY');
    const meses = ['Mes', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre']
    const meses_abr = ['Mes', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'];
    const dias = ['Dias', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    //$('#mozos_tipo option[value="1"]').attr("selected", "selected");
    $("#mozos_mes").val(hoy.format('YYYY-MM'));
    $("#delivery_mes").val(hoy.format('YYYY-MM'));
    $("#tipo_mes").val(hoy.format('YYYY-MM'));

    //******************* */ GRAFICO DE BARRAS 1: VENTAS POR MOZOS
    var $g1Chart = document.getElementById("chart1");
    var g1Chart = new Chart($g1Chart,
    {
        type:"bar",
        data:{
            labels: ["Mozo 1"],
            datasets: [
                {
                    label: "N° de Ventas",
                    data: [0],
                    fill: false,
                    backgroundColor: "rgba(75, 192, 192, 0.2)",
                    borderColor: "rgb(54, 162, 235)",
                    borderWidth: 1
                }
            ]
        },
        options:{
            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
        }
    });

    //******************* */ GRAFICO DE BARRAS 6: VENTAS POR DELIVERY
    var $g6Chart = document.getElementById("chart6");
    var g6Chart = new Chart($g6Chart,
    {
        type:"bar",
        data:{
            labels: ["Rappi 1"],
            datasets: [
                {
                    label: "Total de Pedidos",
                    data: [0],
                    fill: false,
                    backgroundColor: "rgba(228, 0, 46, 0.2)",
                    borderColor: "rgb(228, 0, 46)",
                    borderWidth: 1
                }
            ]
        },
        options:{
            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
        }
    });

    //************** */ GRAFICO DE BARRAS 2: VENTAS VS COMPRAS
    let mes1_g2 = parseInt(mes);
    const label_meses = [];
    const label_ma = [];
    let anterior = mes1_g2;
    for (let ig2 = 1; ig2 <= 12; ig2++) {
        label_meses.push(meses[anterior]);
        label_ma.push(meses_abr[anterior]);
        if (anterior == 1) {
            anterior = 12;
        } else {
            anterior--;
        }
    }
    const labelsg2 = [label_meses[3], label_meses[2], label_meses[1], label_meses[0]]
    const ventasg2 = {
        label: "Compras",
        data: [0, 0, 0, 0],
        backgroundColor: 'rgba(255, 0, 0, 0.5)',
        borderColor: 'rgba(255, 0, 0, 1)',
        borderWidth: 1,
    };
    const comprasg2 = {
        label: "Ventas",
        data: [0, 0, 0, 0],
        backgroundColor: 'rgba(47, 255, 92, 0.5)',
        borderColor: 'rgba(47, 255, 92, 1)',
        borderWidth: 1,
    };
    var $g2Chart = document.getElementById("chart2");
    var g2Chart = new Chart($g2Chart,
    {
        type:"bar",
        data:{
            labels:labelsg2,
            datasets:[
                ventasg2,
                comprasg2,
            ]
        },
        options:{
            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
        }
    });

    //******************* */ GRAFICO DE BARRAS 3: VENTAS POR DIA
    const label_dias = [];
    let dday = moment();
    let danterior = dday;
    for (let ig2 = 1; ig2 <= 7; ig2++) {
        label_dias.push(Mayus(danterior.format('dddd')));
        danterior.subtract(1, 'days');
    }
    var $g3Chart = document.getElementById("chart3");
    var g3Chart = new Chart($g3Chart, {
        type: "horizontalBar",
        data: {
            labels: [label_dias[6], label_dias[5], label_dias[4], label_dias[3], label_dias[2], label_dias[1], label_dias[0]+'(hoy)'],
            datasets: [
                {
                    label: "Total venta (S/.)",
                    data: [0, 0, 0, 0, 0, 0, 0],
                    fill: false,
                    backgroundColor: ["rgb(252, 75, 108)","rgb(255, 159, 64)","rgb(255, 178, 43)","rgb(38, 198, 218)","rgb(54, 162, 235)","rgb(153, 102, 255)","rgb(201, 203, 207)"],
                    borderWidth: 1
                },
            ],
        },
        options: {
            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
        },
    });
    
    //******************* */ GRAFICO DE BARRAS 4: VENTAS POR MESES
    var $g4Chart = document.getElementById("chart4");
    var g4Chart = new Chart($g4Chart, {
        type: "line",
        data: {
            labels: [label_ma[11], label_ma[10], label_ma[9], label_ma[8], label_ma[7], label_ma[6], label_ma[5], label_ma[4], label_ma[3], label_ma[2], label_ma[1], label_ma[0]],
            datasets: [
                {
                    fill: false,
                    lineTension: 0,
                    backgroundColor: ["rgb(252, 75, 108)"],
                    borderColor: ["rgb(252, 75, 108, 0.6)"],
                    label: "Total venta (S/.)",
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    /*pointStyle: 'circle',
                    pointRadius: 10,
                    pointHoverRadius: 15,*/
                    borderWidth: 1
                },
            ],
        },
        options: {
            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
        },
    });

    //******************* */ GRAFICO DE BARRAS 5: VENTAS POR CANAL
    var $g5Chart = document.getElementById("chart5");
    var g5Chart = new Chart($g5Chart, {
        type: "pie",
        data: {
            labels: ["Salon", "Llevar", "Delivery"],
            datasets: [
                {
                    label: "Population (millions)",
                    backgroundColor: [
                        "#36a2eb",
                        "#ff6384",
                        "#ffcd56",
                    ],
                    data: [0, 0, 0],
                },
            ],
        },
        /*options: {
            legend: {
                labels: {
                fontColor: "#b2b9bf",
                },
            },
            title: {
                display: true,
                fontColor: "#b2b9bf",
                text: "Predicted world population (millions) in 2050",
            },
        },
        scales: {
            yAxes: [
                {
                ticks: {
                    fontColor: "#b2b9bf",
                    fontSize: 12,
                },
                },
            ],
            xAxes: [
                {
                ticks: {
                    fontColor: "#b2b9bf",
                    fontSize: 12,
                },
                },
            ],
        },*/
    });

    var datosGenerales = function(){
        /*SearchG1();
        SearchG2();
        SearchG3();*/
        //GRAFICO 1
        let mozos_tipo = $("#mozos_tipo").val();
        let mozos_mes = $("#mozos_mes").val();
        //GRAFICO 3
        let dia_1 = day.format('YYYY-MM-DD');
        let dia_2 = day.subtract(1, 'days').format('YYYY-MM-DD');
        let dia_3 = day.subtract(1, 'days').format('YYYY-MM-DD');
        let dia_4 = day.subtract(1, 'days').format('YYYY-MM-DD');
        let dia_5 = day.subtract(1, 'days').format('YYYY-MM-DD');
        let dia_6 = day.subtract(1, 'days').format('YYYY-MM-DD');
        let dia_7 = day.subtract(1, 'days').format('YYYY-MM-DD');
        //GRAFICO 3
        let tipo_mes = $("#tipo_mes").val();
        $.ajax({
            type: "POST",
            url: $('#url').val()+"estadistica/estadistica_datos",
            data: {
                mes: mes,
                anio: anio,
                mmes: mozos_mes,
                tmes: tipo_mes,
                d1: dia_1,
                d2: dia_2,
                d3: dia_3,
                d4: dia_4,
                d5: dia_5,
                d6: dia_6,
                d7: dia_7,
            },
            dataType: "json",
            success: function(item){
                //console.log(item);
                if (item.grafico1) {
                    //GRAFICO 1
                    let g1_labels = [];
                    let g1_total = [];
                    let g1_texto = "N° de Pedidos";
                    if (mozos_tipo == 2) {
                        g1_texto = "Total en Ventas S/";
                    }
                    (item.grafico1).forEach(mozo => {
                        g1_labels.push(mozo.nombres);
                        g1_total.push(mozo.numero_ventas)
                    });
                    g1Chart.destroy();
                    g1Chart = new Chart($g1Chart,
                    {
                        type:"bar",
                        data:{
                            labels: g1_labels,
                            datasets: [
                                {
                                    label: g1_texto,
                                    data: g1_total,
                                    fill: false,
                                    backgroundColor: "rgba(75, 192, 192, 0.2)",
                                    borderColor: "rgb(54, 162, 235)",
                                    borderWidth: 1
                                }
                            ]
                        },
                        options:{
                            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
                        }
                    });
                }

                //GRAFICO 2
                let datacg2 = item.grafico2.Compras;
                let datavg2 = item.grafico2.Ventas;
                let cg2 = {
                    label: "Compras S/",
                    data: [datacg2.compra_4, datacg2.compra_3, datacg2.compra_2, datacg2.compra_1],
                    backgroundColor: 'rgba(255, 0, 0, 0.5)',
                    borderColor: 'rgba(255, 0, 0, 1)',
                    borderWidth: 1,
                };
                let vg2 = {
                    label: "Ventas S/",
                    data: [datavg2.venta_4, datavg2.venta_3, datavg2.venta_2, datavg2.venta_1],
                    backgroundColor: 'rgba(47, 255, 92, 0.5)',
                    borderColor: 'rgba(47, 255, 92, 1)',
                    borderWidth: 1,
                };
                g2Chart.destroy();
                g2Chart = new Chart($g2Chart,
                {
                    type:"bar",
                    data:{
                        labels:labelsg2,
                        datasets:[
                            cg2,
                            vg2,
                        ]
                    },
                    options:{
                        scales:{yAxes:[{ticks:{beginAtZero:true}}]}
                    }
                });

                //GRAFICO 3
                let datag3 = item.grafico3;
                g3Chart.destroy();
                g3Chart = new Chart($g3Chart, {
                    type: "horizontalBar",
                    data: {
                        labels: [label_dias[6], label_dias[5], label_dias[4], label_dias[3], label_dias[2], label_dias[1], label_dias[0]+' (hoy)'],
                        datasets: [
                            {
                                label: "Total venta (S/)",
                                data: [datag3.dia7, datag3.dia6, datag3.dia5, datag3.dia4, datag3.dia3, datag3.dia2, datag3.dia1],
                                fill: false,
                                backgroundColor: ["rgb(252, 75, 108)","rgb(255, 159, 64)","rgb(255, 178, 43)","rgb(38, 198, 218)","rgb(54, 162, 235)","rgb(153, 102, 255)","rgb(201, 203, 207)"],
                                borderWidth: 1
                            },
                        ],
                    },
                    options: {
                        scales:{yAxes:[{ticks:{beginAtZero:true}}]}
                    },
                });

                //GRAFICO 4
                let datag4 = item.grafico4;
                g4Chart.destroy();
                g4Chart = new Chart($g4Chart, {
                    type: "line",
                    data: {
                        labels: [label_ma[11], label_ma[10], label_ma[9], label_ma[8], label_ma[7], label_ma[6], label_ma[5], label_ma[4], label_ma[3], label_ma[2], label_ma[1], label_ma[0]],
                        datasets: [
                            {
                                fill: false,
                                lineTension: 0,
                                backgroundColor: ["rgb(252, 75, 108)"],
                                borderColor: ["rgb(252, 75, 108, 0.6)"],
                                label: "Total venta (S/)",
                                data: [datag4.venta_12, datag4.venta_11, datag4.venta_10, datag4.venta_9, datag4.venta_8, datag4.venta_7, datag4.venta_6, datag4.venta_5, datag4.venta_4, datag4.venta_3, datag4.venta_2, datag4.venta_1],
                                //borderWidth: 1
                            },
                        ],
                    },
                    options: {
                        scales:{yAxes:[{ticks:{beginAtZero:true}}]}
                    },
                });

                //GRAFICO 5
                let datag5 = item.grafico5;
                g5Chart.destroy();
                g5Chart = new Chart($g5Chart, {
                    type: "pie",
                    data: {
                        labels: ["Salon S/", "Llevar S/", "Delivery S/"],
                        datasets: [
                            {
                                label: "Population (millions)",
                                backgroundColor: ["#36a2eb","#ff6384","#ffcd56"],
                                data: [datag5.mesa, datag5.llevar, datag5.delivery],
                            },
                        ],
                    },
                });

                //GRAFICO 6
                if (item.grafico6) {
                    let g6_labels = [];
                    let g6_total = [];
                    (item.grafico6).forEach(ele => {
                        g6_labels.push(ele.repartidor_abrv);
                        g6_total.push(ele.pedidos)
                    });
                    g6Chart.destroy();
                    g6Chart = new Chart($g6Chart,
                    {
                        type:"bar",
                        data:{
                            labels: g6_labels,
                            datasets: [
                                {
                                    label: "Total de Pedidos",
                                    data: g6_total,
                                    fill: false,
                                    backgroundColor: "rgba(228, 0, 46, 0.2)",
                                    borderColor: "rgb(228, 0, 46)",
                                    borderWidth: 1
                                }
                            ]
                        },
                        options:{
                            scales:{yAxes:[{ticks:{beginAtZero:true}}]}
                        }
                    });
                }
            }
        });
    }

    $("#mozos_mes, #mozos_tipo").change(function(){
        SearchG1();
    });
    function SearchG1() {
        let mozos_tipo = $("#mozos_tipo").val();
        let mozos_mes = $("#mozos_mes").val();
        $.ajax({
            type: "POST",
            url: $('#url').val()+"estadistica/estadistica_g1",
            data: {
                mmes: mozos_mes,
            },
            dataType: "json",
            success: function(item){
                g1Chart.destroy();
                let g1_labels = [];
                let g1_total = [];
                let g1_texto = "N° de Pedidos";

                if (mozos_tipo == 2) {
                    g1_texto = "Total en Ventas S/";
                    (item.data).forEach(mozo => {
                        g1_labels.push(mozo.nombres);
                        g1_total.push(mozo.total_ventas)
                    });
                } else {
                    (item.data).forEach(mozo => {
                        g1_labels.push(mozo.nombres);
                        g1_total.push(mozo.numero_ventas)
                    });
                }
                
                //VENTAS POR MOZOS
                g1Chart = new Chart($g1Chart,
                {
                    type:"bar",
                    data:{
                        labels: g1_labels,
                        datasets: [
                            {
                                label: g1_texto,
                                data: g1_total,
                                fill: false,
                                backgroundColor: "rgba(75, 192, 192, 0.2)",
                                borderColor: "rgb(54, 162, 235)",
                                borderWidth: 1
                            }
                        ]
                    },
                    options:{
                        scales:{yAxes:[{ticks:{beginAtZero:true}}]}
                    }
                });
            }
        });
    }

    $("#tipo_mes").change(function(){
        SearchG5();
    });
    function SearchG5() {
        let tipo_mes = $("#tipo_mes").val();
        $.ajax({
            type: "POST",
            url: $('#url').val()+"estadistica/estadistica_g5",
            data: {
                tmes: tipo_mes,
            },
            dataType: "json",
            success: function(item){
                let datag5 = item.data;
                g5Chart.destroy();
                g5Chart = new Chart($g5Chart, {
                    type: "pie",
                    data: {
                        labels: ["Salon S/", "Llevar S/", "Delivery S/"],
                        datasets: [
                            {
                                label: "Population (millions)",
                                backgroundColor: ["#36a2eb","#ff6384","#ffcd56"],
                                data: [datag5.mesa, datag5.llevar, datag5.delivery],
                            },
                        ],
                    },
                });
            }
        });
    }

    function Mayus(string) {
        return string[0].toUpperCase() + string.slice(1); 
    }

    datosGenerales();
})