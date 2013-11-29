var Index = function () {


    return {

        //main function
        init: function () {
            App.addResponsiveHandler(function () {
                jQuery('.vmaps').each(function () {
                    var map = jQuery(this);
                    map.width(map.parent().width());
                });
            });
        },

        initJQVMAP: function () {

            var showMap = function (name) {
                jQuery('.vmaps').hide();
                jQuery('#vmap_' + name).show();
            }

            var setMap = function (name) {
                var data = {
                    map: 'world_en',
                    backgroundColor: null,
                    borderColor: '#333333',
                    borderOpacity: 0.5,
                    borderWidth: 1,
                    color: '#c6c6c6',
                    enableZoom: true,
                    hoverColor: '#c9dfaf',
                    hoverOpacity: null,
                    values: sample_data,
                    normalizeFunction: 'linear',
                    scaleColors: ['#b6da93', '#909cae'],
                    selectedColor: '#c9dfaf',
                    selectedRegion: null,
                    showTooltip: true,
                    onLabelShow: function (event, label, code) {

                    },
                    onRegionOver: function (event, code) {
                        if (code == 'ca') {
                            event.preventDefault();
                        }
                    },
                    onRegionClick: function (element, code, region) {
                        var message = 'You clicked "' + region + '" which has the code: ' + code.toUpperCase();
                        alert(message);
                    }
                };

                data.map = name + '_en';
                var map = jQuery('#vmap_' + name);
                if (!map) {
                    return;
                }
                map.width(map.parent().parent().width());
                map.show();
                map.vectorMap(data);
                map.hide();
            }

            setMap("world");
            setMap("usa");
            setMap("europe");
            setMap("russia");
            setMap("germany");
            showMap("world");

            jQuery('#regional_stat_world').click(function () {
                showMap("world");
            });

            jQuery('#regional_stat_usa').click(function () {
                showMap("usa");
            });

            jQuery('#regional_stat_europe').click(function () {
                showMap("europe");
            });
            jQuery('#regional_stat_russia').click(function () {
                showMap("russia");
            });
            jQuery('#regional_stat_germany').click(function () {
                showMap("germany");
            });

            $('#region_statistics_loading').hide();
            $('#region_statistics_content').show();
        },

        initCalendar: function () {
            if (!jQuery().fullCalendar) {
                return;
            }

            var date = new Date();
            var d = date.getDate();
            var m = date.getMonth();
            var y = date.getFullYear();

            var h = {};

            if ($('#calendar').width() <= 400) {
                $('#calendar').addClass("mobile");
                h = {
                    left: 'title, prev, next',
                    center: '',
                    right: 'today,month,agendaWeek,agendaDay'
                };
            } else {
                $('#calendar').removeClass("mobile");
                if (App.isRTL()) {
                    h = {
                        right: 'title',
                        center: '',
                        left: 'prev,next,today,month,agendaWeek,agendaDay'
                    };
                } else {
                    h = {
                        left: 'title',
                        center: '',
                        right: 'prev,next,today,month,agendaWeek,agendaDay'
                    };
                }
            }

            $('#calendar').fullCalendar('destroy'); // destroy the calendar
            $('#calendar').fullCalendar({ //re-initialize the calendar
                disableDragging: false,
                header: h,
                editable: true,
                events: [{
                        title: 'All Day Event',
                        start: new Date(y, m, 1),
                        backgroundColor: App.getLayoutColorCode('yellow')
                    }, {
                        title: 'Long Event',
                        start: new Date(y, m, d - 5),
                        end: new Date(y, m, d - 2),
                        backgroundColor: App.getLayoutColorCode('green')
                    }, {
                        title: 'Repeating Event',
                        start: new Date(y, m, d - 3, 16, 0),
                        allDay: false,
                        backgroundColor: App.getLayoutColorCode('red')
                    }, {
                        title: 'Repeating Event',
                        start: new Date(y, m, d + 4, 16, 0),
                        allDay: false,
                        backgroundColor: App.getLayoutColorCode('green')
                    }, {
                        title: 'Meeting',
                        start: new Date(y, m, d, 10, 30),
                        allDay: false,
                    }, {
                        title: 'Lunch',
                        start: new Date(y, m, d, 12, 0),
                        end: new Date(y, m, d, 14, 0),
                        backgroundColor: App.getLayoutColorCode('grey'),
                        allDay: false,
                    }, {
                        title: 'Birthday Party',
                        start: new Date(y, m, d + 1, 19, 0),
                        end: new Date(y, m, d + 1, 22, 30),
                        backgroundColor: App.getLayoutColorCode('purple'),
                        allDay: false,
                    }, {
                        title: 'Click for Google',
                        start: new Date(y, m, 28),
                        end: new Date(y, m, 29),
                        backgroundColor: App.getLayoutColorCode('yellow'),
                        url: 'http://google.com/',
                    }
                ]
            });
        },
        initMiniCharts: function () {

            $('.easy-pie-chart .number.transactions').easyPieChart({
                animate: 1000,
                size: 75,
                lineWidth: 3,
                barColor: App.getLayoutColorCode('yellow')
            });

            $('.easy-pie-chart .number.visits').easyPieChart({
                animate: 1000,
                size: 75,
                lineWidth: 3,
                barColor: App.getLayoutColorCode('green')
            });

            $('.easy-pie-chart .number.bounce').easyPieChart({
                animate: 1000,
                size: 75,
                lineWidth: 3,
                barColor: App.getLayoutColorCode('red')
            });

            $("#sparkline_bar").sparkline([8,9,10,11,10,10,12,10,10,11,9,12,11,10,9,11,13,13,12], {
                type: 'bar',
                width: '100',
                barWidth: 5,
                height: '55',
                barColor: '#35aa47',
                negBarColor: '#e02222'}
            );

            $("#sparkline_bar2").sparkline([9,11,12,13,12,13,10,14,13,11,11,12,11,11,10,12,11,10], {
                type: 'bar',
                width: '100',
                barWidth: 5,
                height: '55',
                barColor: '#ffb848',
                negBarColor: '#e02222'}
            );

            $("#sparkline_line").sparkline([9,10,9,10,10,11,12,10,10,11,11,12,11,10,12,11,10,12], {
                type: 'line',
                width: '100',
                height: '55',
                lineColor: '#ffb848'
            });

        },
        initIntro: function () {
            if ($.cookie('intro_show')) {
                return;
            }

            $.cookie('intro_show', 1);

            setTimeout(function () {
                var unique_id = $.gritter.add({
                    // (string | mandatory) the heading of the notification
                    title: 'Meet Metronic!',
                    // (string | mandatory) the text inside the notification
                    text: 'Metronic is a brand new Responsive Admin Dashboard Template you have always been looking for!',
                    // (string | optional) the image to display on the left
                    image: './assets/img/avatar1.jpg',
                    // (bool | optional) if you want it to fade out on its own or just sit there
                    sticky: true,
                    // (int | optional) the time you want it to be alive for before fading out
                    time: '',
                    // (string | optional) the class name you want to apply to that specific message
                    class_name: 'my-sticky-class'
                });

                // You can have it return a unique id, this can be used to manually remove it later using
                setTimeout(function () {
                    $.gritter.remove(unique_id, {
                        fade: true,
                        speed: 'slow'
                    });
                }, 12000);
            }, 2000);

            setTimeout(function () {
                var unique_id = $.gritter.add({
                    // (string | mandatory) the heading of the notification
                    title: 'Buy Metronic!',
                    // (string | mandatory) the text inside the notification
                    text: 'Metronic comes with a huge collection of reusable and easy customizable UI components and plugins. Buy Metronic today!',
                    // (string | optional) the image to display on the left
                    image: './assets/img/avatar1.jpg',
                    // (bool | optional) if you want it to fade out on its own or just sit there
                    sticky: true,
                    // (int | optional) the time you want it to be alive for before fading out
                    time: '',
                    // (string | optional) the class name you want to apply to that specific message
                    class_name: 'my-sticky-class'
                });

                // You can have it return a unique id, this can be used to manually remove it later using
                setTimeout(function () {
                    $.gritter.remove(unique_id, {
                        fade: true,
                        speed: 'slow'
                    });
                }, 13000);
            }, 8000);

            setTimeout(function () {

                $('#styler').pulsate({
                    color: "#bb3319",
                    repeat: 10
                });

                $.extend($.gritter.options, {
                    position: 'top-left'
                });

                var unique_id = $.gritter.add({
                    position: 'top-left',
                    // (string | mandatory) the heading of the notification
                    title: 'Customize Metronic!',
                    // (string | mandatory) the text inside the notification
                    text: 'Metronic allows you to easily customize the theme colors and layout settings.',
                    // (string | optional) the image to display on the left
                    image1: './assets/img/avatar1.png',
                    // (bool | optional) if you want it to fade out on its own or just sit there
                    sticky: true,
                    // (int | optional) the time you want it to be alive for before fading out
                    time: '',
                    // (string | optional) the class name you want to apply to that specific message
                    class_name: 'my-sticky-class'
                });

                $.extend($.gritter.options, {
                    position: 'top-right'
                });

                // You can have it return a unique id, this can be used to manually remove it later using
                setTimeout(function () {
                    $.gritter.remove(unique_id, {
                        fade: true,
                        speed: 'slow'
                    });
                }, 15000);

            }, 23000);

            setTimeout(function () {

                $.extend($.gritter.options, {
                    position: 'top-left'
                });

                var unique_id = $.gritter.add({
                    // (string | mandatory) the heading of the notification
                    title: 'Notification',
                    // (string | mandatory) the text inside the notification
                    text: 'You have 3 new notifications.',
                    // (string | optional) the image to display on the left
                    image1: './assets/img/image1.jpg',
                    // (bool | optional) if you want it to fade out on its own or just sit there
                    sticky: true,
                    // (int | optional) the time you want it to be alive for before fading out
                    time: '',
                    // (string | optional) the class name you want to apply to that specific message
                    class_name: 'my-sticky-class'
                });

                setTimeout(function () {
                    $.gritter.remove(unique_id, {
                        fade: true,
                        speed: 'slow'
                    });
                }, 4000);

                $.extend($.gritter.options, {
                    position: 'top-right'
                });

                var number = $('#header_notification_bar .badge').text();
                number = parseInt(number);
                number = number + 3;
                $('#header_notification_bar .badge').text(number);
                $('#header_notification_bar').pulsate({
                    color: "#66bce6",
                    repeat: 5
                });

            }, 40000);

            setTimeout(function () {

                $.extend($.gritter.options, {
                    position: 'top-left'
                });

                var unique_id = $.gritter.add({
                    // (string | mandatory) the heading of the notification
                    title: 'Inbox',
                    // (string | mandatory) the text inside the notification
                    text: 'You have 2 new messages in your inbox.',
                    // (string | optional) the image to display on the left
                    image1: './assets/img/avatar1.jpg',
                    // (bool | optional) if you want it to fade out on its own or just sit there
                    sticky: true,
                    // (int | optional) the time you want it to be alive for before fading out
                    time: '',
                    // (string | optional) the class name you want to apply to that specific message
                    class_name: 'my-sticky-class'
                });

                $.extend($.gritter.options, {
                    position: 'top-right'
                });

                setTimeout(function () {
                    $.gritter.remove(unique_id, {
                        fade: true,
                        speed: 'slow'
                    });
                }, 4000);

                var number = $('#header_inbox_bar .badge').text();
                number = parseInt(number);
                number = number + 2;
                $('#header_inbox_bar .badge').text(number);
                $('#header_inbox_bar').pulsate({
                    color: "#dd5131",
                    repeat: 5
                });

            }, 60000);
        }

    };

}();