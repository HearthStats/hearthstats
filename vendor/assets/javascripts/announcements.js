$(function() {

    $('.hide_announcement, .close').click(function() {
        var a_id = $(this).data("announcementid");
        createCookie("announcement_" + a_id, "hidden", 45);
        $(this).parent().slideUp();
    });

    function createCookie(name, value, days) {
        var expires = "";
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days*24*60*60*1000));
            expires = "; expires=" + date.toGMTString();
        } else {
            expires = "";
        }

        document.cookie = name + "=" + value + expires + "; path=/";
    }
});