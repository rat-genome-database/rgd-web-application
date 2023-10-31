/* Page Sideview Menu
* Author: Dynamic Drive at http://www.dynamicdrive.com/
* Visit http://www.dynamicdrive.com/ for full source code
*/

var sideviewmenu = (function(win, $){

	var defaults = {
		main_transition_duration: 0.3,
		menu_transition: {duration: 0.4, delay: 0.4},
		list_transition: {listclass: 'menulinks', duration: 0.5, basedelay: 0.4, delay: 0.3},
		menusource: 'menucontents.txt',
		menuid: 'sideviewmenu',
		onopenclose:function(state){
			// event handler
		}
	}

	var transform = typeof $(document.documentElement).css('perspective') != "undefined" // test for support for CSS3 transform
	var menuloaded = false

	function getajaxcontent(url, options){
		$.ajax({
			url: url,
			dataType: 'html',
			error:function(ajaxrequest){
				alert('Error fetching content.<br />Server Response: '+ajaxrequest.responseText)
			},
			success:function(content){
				menuloaded = true
				options.menuref = $(content)
				sideviewmenu(options)
			}
		})
	}

	function sideviewmenu(options){

		var menusource = options.menusource || defaults.menusource
		if (!menuloaded && menusource != 'inline'){
			getajaxcontent(menusource, options)
			return
		}

		var s = $.extend({}, defaults, options),
				$bod = $(document.body),
				$content = $('#contentwrapper')

		var $menu = s.menuref || $('#' + s.menuid)

		if ($content.length == 0){
			$bod.wrapInner('<div id="contentwrapper" />')
			$content = $('#contentwrapper')
		}

		$bod.prepend( $menu )
		var $menubackdrop = $('<div class="backdrop" />').prependTo($menu)

		function togglescrollbars(state){
			if (state == 'open'){
				$menu.css({overflow: 'auto'})
				$menubackdrop.css({height: $menu.get(0).scrollHeight})
				s.onopenclose('opened')			
			}
			else{
				$content.css({height: '', overflow: ''})
				$bod.css('overflow', 'auto')
				$menu.css({overflow: ''})
				s.onopenclose('closed')
			}
		}

		if (transform){
			$content.css({'transitionDuration': s.main_transition_duration + 's'})
			$menu.css({transitionDuration: s.menu_transition.duration + 's', transitionDelay: s.menu_transition.delay + 's'})
			$menu.find('.' + s.list_transition.listclass + ' li').each(function(i){ // loop through LI elements within UL menu
				$(this).css({
					transitionDuration: s.list_transition.duration + 's',
					transitionDelay: s.list_transition.basedelay + s.list_transition.delay * i + 's'
				})
			})
	
			$bod.on('transitionend webkitTransitionEnd', function(e){
				if (/transform/i.test(e.originalEvent.propertyName) && e.target.getAttribute('id') == s.menuid){ // check event fired on "transform" prop
					if ( !$bod.hasClass('opensideviewmenu') ){ // if menu is hidden (at end of animation)
						togglescrollbars('close')
					}
					else{ // if menu is visible (at end of animation)
						togglescrollbars('open')
					}
				}
			})
		}
		else{ // no CSS3 transform support
			$menu.css({left: '-100%', visibility: 'visible'})
		}


		sideviewmenu.toggle = function(state){
		 	$bod.css('overflow', 'hidden')
			$content.css({height: window.innerHeight, overflow: 'hidden'})
			var actionfunc = (state == 'open')? 'addClass' : (state == 'close')? 'removeClass' : 'toggleClass'
			setTimeout(function(){
				$bod[actionfunc]('opensideviewmenu')
			}, transform? 25 : 0)
			if (!transform) { // fall back animation
				var leftval = (state == 'open')? 0 : (state == 'close')? '-100%' : ($bod.hasClass('opensideviewmenu'))? '-100%' : 0
				$menu.animate({left: leftval}, s.menu_transition.duration +'ms', function(){
					if (leftval == 0){ // if menu is visible (at end of animation)
						togglescrollbars('open')
					}
					else{ // if menu is hidden (at end of animation)
						togglescrollbars('close')
					}
				})
			}
		}

		$menu.add($content).on('click', function(){ // close menu when clicking on menu or content (main BODY)
			if ($bod.hasClass('opensideviewmenu')){
				sideviewmenu.toggle('close')
			}
		})
		
	} // end sideviewmenu function


	return sideviewmenu

}) (window, jQuery);