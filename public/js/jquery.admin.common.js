function loadingView() {
	var loadingStatus = null;
	
	if($("#modal-bg").length == 0) {
		$("<div id='modal-bg'><img id='loading-icon' src='/images/default/loading.gif' width='91' height='120' alt='로딩이미지'/></div>")
		.css({'display':'block','background-color': 'black', 'position': 'absolute', 'top': '0', 'left': '0','z-index':'10000'})
		.appendTo('body')
	}
	if(!loadingStatus) {
		loadingStatus = "view";
		startX = ($(document).width()/2)-(91/2);
		startY = ($(window).height()/2)-(120/2)+$(document).scrollTop();
		$("#loading-icon").css({"position": "absolute","top":startY,"left":startX}).show()
		$("#modal-bg")
			.css({"width": "100%","min-width":"960px", "height": $(document).height()})
			.stop().fadeTo(0,"0.5")
	} else {
		if(popupStatus) {
			if(loadingStatus == "view") {
				loadingStatus = "top";
				$("#modal-bg").css("z-index","130");	
			} else {
				loadingStatus = "view";
				$("#modal-bg").css("z-index","10");
			}
		} else {
			loadingStatus = null;
			$("#modal-bg").stop().fadeOut(0,function() {$("#loading-icon").hide();});
		}
	}
}

function to_comma(price){
	char_price = price;
	// 콤마찍기
	var reg = /(^[+-]?\d+)(\d{3})/;   // 정규식
	char_price += '';                // 숫자를 문자열로 변환

	while (reg.test(char_price))
	char_price = char_price.replace(reg, '$1' + ',' + '$2');
	
	return char_price;
}



$('.check_all').live("click", function(){
	if ( $('#all_checked').val() == "false" ){
		
		$('.chk_box').each(function(){
			$(this).attr("checked", true);
		})
		
		$('#all_checked').val("true");
	}else{
		$('.chk_box').each(function(){
			$(this).attr("checked", false);
		})
		
		$('#all_checked').val("false");
	}
})

// 입력값의 한문자씩의 ascii 코드값을 가져와서, 0~127까지면 정상적인 값이며,
// 그외는 특수문자나 한글임을 판단하고 처리하는 함수
function input_check(string) {
 var txt = string;
 var cnt = 0;
 for(i=0; i<txt.length; i++) {
  if(txt.charCodeAt(i)>=0 && txt.charCodeAt(i)<=127) {
   // ascii
  } else {
   // not ascii
   cnt++;
  }
  if(cnt!=0) return false; 
 } 
}
