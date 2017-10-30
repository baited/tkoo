package provide tkoo::scrollbar 0.2
package require tkoo::mixin::help

tkoo::class tkoo::scrollbar {
	superclass tkoo::ttk_scrollbar
	mixin tkoo::mixin::help
	variable widCmd pathname options exists grid time
	constructor {wid args} {
		#check to see if the class already exists
		Exists $wid
		
		#defaults
		set time 0
		
		#default code
		next $wid {*}$args
	}
	method CreateOptions {} {
		next;#default code
		
		#add extra options
		Option add -auto auto Auto false {
			if {![string is bool $value]} {error [msgcat::mc "expected boolean value but got \"%s\"" $value]}
			if {[winfo exists $pathname]} {
				my set {*}[my get]
			}
		}
	}
	method set {min max} {
		if {$min <= 0 && $max >= 1 && [my cget -auto]} {
			#no scrollbar needed
			if {![info exists grid]} {
				#prevent flick effects
				if {[expr [clock milliseconds] - $time] < 50} {return}
				
				#hide the scrollbar
				switch -exact -- [winfo manager $pathname] {
					grid {
						lappend grid "[list grid $pathname] [grid info $pathname]"
						grid forget $pathname
					}
					pack {
						foreach x [pack slaves [winfo parent $w]] {
							lappend grid "[list pack $x] [pack info $x]"
						}
						pack forget $pathname
					}
				}
			}
		} elseif {[info exists grid]} {
			#store the time the scroll bar was shown
			set time [clock milliseconds]
			
			#show the scrollbar
			eval [join $grid \;]
			unset grid
		}
		tailcall $widCmd set $min $max
	}
	method map {} {wm geometry [winfo toplevel $pathname] [wm geometry [winfo toplevel $pathname]]}
	bind <Map> {%W map}
}