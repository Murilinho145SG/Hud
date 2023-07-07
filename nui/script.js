let hudVisibility = true


function setVeloBar(velo) {
    let fill_value = 180 * (velo) / (300)

    let fill_element = document.querySelector('.veloFill')

    fill_element.style.width = `${fill_value}%`
}


window.addEventListener('message', function (event) {

    const response = event.data

    switch (response.action) {
        case 'changeVisibility':
            hudVisibility = !hudVisibility
            if (hudVisibility) $('body').fadeIn(500)
            else $('body').fadeOut(500)

            break;
        case 'update':
            $('.velocimetro2').fadeOut(500)

            $("#sede").css("height",100-response.sede + "%" );
            $("#vida").css("height",response.health + "%" );
            $("#fome").css("height",100-response.fome +"%" );
            $("#sede").css("height",100-response.sede +"%" );

            $(".horas").html(response.hour + ":" +response.minute);

            if (response.armour == 0){
                $("#vidadiv").css("margin-left","53px");
                $("#coletediv").hide(0);
            } else {
                $("#vidadiv").css("margin-left","5px");
                $("#coletediv").fadeIn(500);
                $("#colete").css("height",response.armour +"%");
            }
       

            break;
        case 'inCar':
            $('.upLeft .streetName').html(response.streetName)
            $('.upRight .time').html(response.time)

            $("#sede").css("height",100-response.sede + "%" );
            $("#vida").css("height",response.health + "%" );
            $("#fome").css("height",100-response.fome +"%" );
    
            if (response.armour == 0){
                $("#vidadiv").css("margin-left","53px");
                $("#coletediv").hide(0);
            } else {
                $("#vidadiv").css("margin-left","5px");
                $("#coletediv").fadeIn(500);
                $("#colete").css("height",response.armour +"%");
            }
          
            $('.velocimetro2').fadeIn(500)

            if(response.speed <= 9) {
                $('#speed').html('00' + response.speed)
               
            } else if(response.speed <= 44){
                $('#speed').html('0' + response.speed)
           
            } else if(response.speed <= 64){
                $('#speed').html('0' + response.speed)
               
            } else if(response.speed <= 65){
                $('#speed').html('0' + response.speed)
             
            } else if(response.speed <= 99){
                $('#speed').html('0' + response.speed)
              
            } else {
                $('#speed').html(response.speed)
              
            }

            

 
            break
        case 'proximity':
            if (response.number == 1) {
                $('.circle').css('background', 'white')
                $('.circle2').css('background', 'rgb(156, 155, 155,0.6)')
                $('.circle3').css('background', 'rgb(156, 155, 155,0.6)')
            } else if (response.number == 2) {
                $('.circle').css('background', 'white')
                $('.circle2').css('background', 'white')
                $('.circle3').css('background', 'rgb(156, 155, 155,0.6)')
            } else if (response.number == 3) {
                $('.circle').css('background', 'white')
                $('.circle2').css('background', 'white')
                $('.circle3').css('background', 'white')
            }
            break;
        case 'talking':
            if (response.falando) {
                $('.fa-microphone').css('color', 'rgb(16, 158, 214)')

            } else {
                $('.fa-microphone').css('color', '#fff')
            }
            break;
    }
    if (response.only == "updateSpeed") {
        $('.motor').html(response.gear)
        if(response.speed <= 9) {
            $('#speed').html('00' + response.speed)
           
        } else if(response.speed <= 44){
            $('#speed').html('0' + response.speed)
       
        } else if(response.speed <= 64){
            $('#speed').html('0' + response.speed)
           
        } else if(response.speed <= 65){
            $('#speed').html('0' + response.speed)
         
        } else if(response.speed <= 99){
            $('#speed').html('0' + response.speed)
          
        } else {
            $('#speed').html(response.speed)
          
        }

        $('#fuel').css('width',response.fuel + '%')

       
        let velo = document.querySelector('.velo')




        let velo_perc = 100 * (response.speed) / (230)

        setVeloBar(velo_perc)

    


    if(response.cinto == true) {
        $(".cinto").attr("src", "svgs/cintoon.png");
    } else {
        $(".cinto").attr("src", "svgs/cintooff.png");
    }

    if(response.locked == true) {
        $(".lock").attr("src", "svgs/lockoff.png");
   
    } else {
        
        $(".lock").attr("src", "svgs/lockon.png");
   
    }

    }
})