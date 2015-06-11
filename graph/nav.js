        function blink(elem, times, speed) {
            if (times > 0 || times < 0) {
                if ($(elem).hasClass("blink")) $(elem).stop().toggleClass("blink");
                else $(elem).stop().toggleClass("blink");
            }
        
            clearTimeout(function () {
                blink(elem, times, speed);
            });
        
            if (times > 0 || times < 0) {
                setTimeout(function () {
                    blink(elem, times, speed);
                }, speed);
                times -= .5;
            }
        }
        
        function blink_fak(elem, times, speed) {
            if (times > 0 || times < 0) {
                if ($(elem).hasClass("blink_fak")) $(elem).stop().toggleClass("blink_fak");
                else $(elem).stop().toggleClass("blink_fak");
            }
        
            clearTimeout(function () {
                blink_fak(elem, times, speed);
            });
        
            if (times > 0 || times < 0) {
                setTimeout(function () {
                    blink_fak(elem, times, speed);
                }, speed);
                times -= .5;
            }
        }
        
        $(document).ready(function(){
        
        
        
            $("#input_comp").click(function(){
            $("#output_hori").stop().toggle('slide', {direction: 'right'}, 600);
            $("#input_adv").stop().toggleClass('fake_invi');
                if (document.getElementById("input_comp").innerHTML == "Show Compare") {
                document.getElementById("input_comp").innerHTML = "Stop Compare";
                 }else{
                 document.getElementById("input_comp").innerHTML = "Show Compare";
                }
            });
        
            blink_fak("#input_adv", -1, 700);
            blink("#name_adv", -1, 700);
            $("#input_1").click(function(){
            $("#output_1").stop().toggle('slide', {direction: 'bottom'}, 600);
            $("#input_1").toggleClass('clicked');
                if ($("#input_1").hasClass('clicked') || $("#input_2").hasClass('clicked') || $("#input_3").hasClass('clicked') || $("#input_4").hasClass('clicked')) {
                $("#input_0").animate({left:'-50%'});
                   }
                   else  {
                $("#input_0").animate({left:'15%'});
                   }
        
            $("#input_2").removeClass('invisible');
            $("#input_3").removeClass('invisible');
            $("#input_4").removeClass('invisible');
        
            $(".stats1_det").hide("slow");
          });
            $("#input_2").click(function(){
            $("#output_2").stop().toggle('slide', {direction: 'right'}, 600);
            $("#input_2").toggleClass('clicked');
                if ($("#input_1").hasClass('clicked') || $("#input_2").hasClass('clicked') || $("#input_3").hasClass('clicked') || $("#input_4").hasClass('clicked')) {
                $("#input_0").animate({left:'-50%'});
                   }
                   else  {
                $("#input_0").animate({left:'15%'});
                   }
            blink("#name2_adv", -1, 800);
        
            $("#input_1").removeClass('invisible');
            $("#input_3").removeClass('invisible');
            $("#input_4").removeClass('invisible');
        
            $(".stats2_det").hide("slow");
          });
            $("#input_3").click(function(){
            $("#output_3").stop().toggle('slide', {direction: 'bottom'}, 600);
            $("#input_3").toggleClass('clicked');
                if ($("#input_1").hasClass('clicked') || $("#input_2").hasClass('clicked') || $("#input_3").hasClass('clicked') || $("#input_4").hasClass('clicked')) {
                $("#input_0").animate({left:'-50%'});
                   }
                   else  {
                $("#input_0").animate({left:'15%'});
                   }
            blink("#name3_adv", -1, 800);
        
            $("#input_1").removeClass('invisible');
            $("#input_2").removeClass('invisible');
            $("#input_4").removeClass('invisible');
        
            $(".stats3_det").hide("slow");
          });
            $("#input_4").click(function(){
            $("#output_4").stop().toggle('slide', {direction: 'right'}, 600);;
            $("#input_4").toggleClass('clicked');;
                if ($("#input_1").hasClass('clicked') || $("#input_2").hasClass('clicked') || $("#input_3").hasClass('clicked') || $("#input_4").hasClass('clicked')) {
                $("#input_0").animate({left:'-50%'});
                   }
                   else  {
                $("#input_0").animate({left:'15%'});
                   }
            blink("#name4_adv", -1, 800);
        
            $("#input_1").removeClass('invisible');
            $("#input_2").removeClass('invisible');
            $("#input_3").removeClass('invisible');
        
            $(".stats4_det").hide("slow");
          });
            $("#name_1").click(function(){
            $("#output_1").hide("slow");
            $("#output_2").hide("slow");
            $("#output_3").hide("slow");
            $("#output_4").hide("slow");
        
            $("#input_1").removeClass('clicked');
            $("#input_2").toggleClass('invisible');
            $("#input_3").toggleClass('invisible');
            $("#input_4").toggleClass('invisible');
            $("#input_2").removeClass('clicked');
            $("#input_3").removeClass('clicked');
            $("#input_4").removeClass('clicked');
            $(".stats").hide("slow");
            $(".stats1_det").stop().toggle('slide', {direction: 'bottom'}, 600);
          });
            $("#name_2").click(function(){
            $("#output_1").hide("slow");
            $("#output_2").hide("slow");
            $("#output_3").hide("slow");
            $("#output_4").hide("slow");
        
            $("#input_2").removeClass('clicked');
            $("#input_1").removeClass('clicked');
            $("#input_3").removeClass('clicked');
            $("#input_4").removeClass('clicked');
            $("#input_1").toggleClass('invisible');
            $("#input_3").toggleClass('invisible');
            $("#input_4").toggleClass('invisible');
        
            $(".stats").hide("slow");
            $(".stats2_det").stop().toggle('slide', {direction: 'bottom'}, 600);
          });
            $("#name_3").click(function(){
            $("#output_1").hide("slow");
            $("#output_2").hide("slow");
            $("#output_3").hide("slow");
            $("#output_4").hide("slow");
            $("#input_3").removeClass('clicked');
            $("#input_1").removeClass('clicked');
            $("#input_2").removeClass('clicked');
            $("#input_4").removeClass('clicked');
            $("#input_1").toggleClass('invisible');
            $("#input_2").toggleClass('invisible');
            $("#input_4").toggleClass('invisible');
        
            $(".stats").hide("slow");
            $(".stats3_det").stop().toggle('slide', {direction: 'bottom'}, 600);
          });
            $("#name_4").click(function(){
            $("#output_1").hide("slow");
            $("#output_2").hide("slow");
            $("#output_3").hide("slow");
            $("#output_4").hide("slow");
            $("#input_4").removeClass('clicked');
            $("#input_1").removeClass('clicked');
            $("#input_2").removeClass('clicked');
            $("#input_3").removeClass('clicked');
            $("#input_1").toggleClass('invisible');
            $("#input_2").toggleClass('invisible');
            $("#input_3").toggleClass('invisible');
        
            $(".stats").hide("slow");
            $(".stats4_det").stop().toggle('slide', {direction: 'bottom'}, 600);
          });
        });
