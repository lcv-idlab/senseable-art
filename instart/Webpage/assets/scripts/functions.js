/*
function img(){
	var img = "assets/img/snail_1924.jpg";
	var	box = "#img_box";

	Caman(box, img, function () {
		// manipulate image here
		//this.contrast(0)
		this.render();
	});
	console.log()
}

function update(contrast){
	Caman("#img_box", function () {
		this.exposure();

		this.newLayer(function () {
			this.setBlendingMode("multiply");
			this.filter.contrast(contrast); //this.contrast(contrast);
		})

		this.clip(10);
		this.render();
		console.log()
 	});
}

function get_data(){

	$(".contrast [type=range]").change(function() {
		contrast = Number($(this).val());
		$("#contrast_value").text(contrast);
		
		update(contrast);
		console.log(contrast)
	})
}
*/

files = [];
old_files = [];
var b = window.pageYOffset;
var b_1 = document.documentElement.scrollTop;
//var h = window.innerWidth;

function highlight(){
	height = 2;
	width = 2;
	scale_zoom = "scale(" + width + "," + height + ")";
	scale_normal = "scale(1,1)";
	console.log()

	$(".thumb").click(function() {
		$("#highlight").empty();

		$(this).find(".dida").show();
		$(this).clone().appendTo("#highlight");
		$(this).find(".dida").hide();
		//$(this).children(".dida").css("background-color","white").css("position","relative").css("top","-5px");
		
		

		$("#highlight").click(function() {
			$("#highlight").empty();
			$(".dida").hide();
		})
	});	
}

function statement(){
	/*
	function getOffset(el) {
		el = el.getBoundingClientRect();
		return {
			left: el.left + window.scrollX,
			top: el.top + window.scrollY
		}
	}
	getOffset("body").top
	getOffset("title").top

	console.log(el.left)
	*/
}

function get_images() {

	var getUrl = window.location;
	var folder =  "assets/img/";
	var fileextension = ".jpg";
	var interval = 1000;
	console.log()

	setInterval(function(){

		$.ajax({
			url: folder,
			cache: false,
			beforeSend: function(){
				//$("#gallery").fadeIn(100)
		 		//$("#gallery").empty();  
			},
			success: function(data) {
				//console.log(data)
				
				files = $(data).find("a:contains(" + fileextension + ")");
				//console.log(files)
				
				if (old_files.length != files.length){
					$("#gallery").empty(); 

					imgs = [];
					dida = [];
					var items = 24;
					var index = 0;

					files.each(function () {
						var filename = this.href.replace(getUrl,"").replace(folder,"");
						img_src = folder + filename;
						img_file = "<img src='" + img_src + "' alt='" + filename + "' id='" + filename + "' class='g_img'>";

						file = filename.replace(".jpg","");
			 			contrast = Number(file.split("-")[1]);
						brightness = Number(file.split("-")[2])-100;
						filter = file.split("-")[3];

						if (brightness > 0) {
							brightness = "+" + brightness;
						}

			 			con_ = "<div class='dida'><div class='values'><i class='fa fa-adjust fa-2x' aria-hidden='true'></i> " + contrast + "x</div>" 
			 			bri_ = "<div class='values'><i class='fa fa-sun-o fa-2x' aria-hidden='true'></i> " + brightness + "%</div>";
			 			fil_ = "<div class='values'><i class='fa fa-eye fa-2x' aria-hidden='true'></i>" + filter + "</div></div>"

			 			d_ = con_ + bri_ + fil_;

			 			imgs.push(img_file);
			 			dida.push(d_);
			 		});

			 		imgs.reverse();
			 		dida.reverse();

			 		if (imgs.lenght < items){
			 			items = imgs.lenght;
			 		}
			 		else{
			 			items = items;
			 		}
					for (i = 0; i < items; i++) { 

						var html = "<div class='thumb'>" + (imgs[i]) + (dida[i]) + "</div>";
						$("#gallery").append(html);
					}
					
					$(".dida").hide();
					//$("#artworks").hide();

			 		//window.scroll(0, b);  // scroll(0,b) // x,y
			 		
			 		//window.scroll(0,800);

			 		old_files = files;
			 		//console.log(b)

			 		highlight();
			 	}
			},
			fail: function() {
				console.log("error")
		   }
		})

		

	}, interval);
}

function scroll_test(){

	$("#test").click(function() {
		$('body').scroll(0,800);
	})
}

$(document).ready(function(){
	get_images();
	scroll_test();
})
