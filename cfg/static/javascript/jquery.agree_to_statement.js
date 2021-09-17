// GDPR addition
//
jQuery( document ).ready(function($){
	var $ag_st = $('.agree-statement-input');
	$ag_st.addClass('form-inline');
	$ag_st.find('input[type=checkbox]').css({'margin-right':'10px'});
	$ag_st.addClass( 'disabled' );
	$ag_st.find('input').prop('disabled', 'disabled');
	$ag_st.closest('form').find('input[type="submit"]').prop('disabled', 'disabled');

	$ag_st.find('input[type=checkbox]').on("change", function(){
		if( $(this).prop("checked") ){
			$ag_st.closest('form').find('input[type="submit"]').prop('disabled', false);
		} else {
			$ag_st.closest('form').find('input[type="submit"]').prop('disabled', 'disabled');
		}
	});

	$('#agree-statement-full').addClass('jqmodal').append('<p><a href="#close" rel="jqmodal:close">Close window</a></p>');

        $('<div><p><a href="#agree-statement-full">Please read the full agreement before accepting it.</a></p></div>').insertBefore('#agree-statement-full').on("click",function(){
	  $('#agree-statement-full').jqmodal();
	  return false;
	});

	$('#agree-statement-full').on($.jqmodal.BEFORE_CLOSE, function(event, modal) {
	  $ag_st.removeClass( 'disabled' );
	  $ag_st.find('input').prop('disabled', false );
	  //$ag_st.closest('form').find('input[type="submit"]').prop('disabled', false);
	  //$('.agree-statement-input').removeClass( 'disabled' );
	  //$('.agree-statement-input input').prop('disabled', false );
	});
	
	
});
