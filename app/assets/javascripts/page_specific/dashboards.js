//= require 'plugins/flot/jquery.flot.min.js'
//= require 'plugins/flot/jquery.flot.time.min.js'
//= require 'plugins/flot/jquery.flot.curved.js'
//= require 'plugins/jquery.easy-pie-chart.js'
//= require 'redesign/index.js'

$(document).ready(function(){
  $.plot($("#winrate-by-time"), [{
              data: gon.hourly_wr,
            }
        ],
        {
            series: {
              lines: {
                show: true,
                lineWidth: 2,
                fill: true,
                fillColor: {
                    colors: [{
                            opacity: 0.05
                        }, {
                            opacity: 0.01
                        }
                    ]
                }
              },
              shadowSize: 2
            },
            grid: {
                hoverable: true,
                clickable: true,
                tickColor: "#eee",
                borderWidth: 0
            },
            colors: ["#28B779", "#37b7f3", "#52e136"],
            xaxis: {
              ticks: 24,
              tickDecimals: 0,
              max: 24
            },
            yaxis: {
                ticks: 11,
                tickDecimals: 0,
                max: 100,
                min: 0
            },
            legend: {
              position: "se"
            }
        });
});