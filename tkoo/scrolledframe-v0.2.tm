package provide tkoo::scrolledframe 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::scrolledframe {
	superclass tkoo::widget
	mixin tkoo::mixin::help
	variable widCmd pathname options exists children
	
	constructor {wid args} {
		next $wid {*}$args
		my resize
	}
	
	method Create {wid args} {
		#defaults
		set c [set children(canvas) $wid.c];#canvas widget pathname
		set f [set children(frame) $wid.f];#containing frame pathname
		set x [set children(xscroll) $wid.x];#x scrollbar pathname
		set y [set children(yscroll) $wid.y];#y scrollbar pathname
		set d [set children(dummy) $wid.d];#dummy frame for bottom right corner
		
		#create widgets
		ttk::frame $wid
		canvas $c -xscrollcommand [list $x set] -yscrollcommand [list $y set] -background red -borderwidth 0 -highlightthickness 0
		tkoo::scrollbar $x -command [list $c xview] -auto true -orient horizontal
		tkoo::scrollbar $y -command [list $c yview] -auto true
		ttk::frame $d
		$c create window 0 0 -window [ttk::frame $f -borderwidth 0] -anchor nw -tags scrolled
		
		#show widgets
		grid $c $y -sticky nwes
		grid $x $d -sticky nwes
		grid columnconfigure $wid 0 -weight 1
		grid rowconfigure $wid 0 -weight 1
		raise $x
		raise $y
		raise $d
		
		next $wid {*}$args
	}
	
	method CreateOptions {} {
		Option add -xscroll xscroll XScroll always {
			set x $children(xscroll)
			switch -exact -- $value {
				always {
					if {[winfo exists $pathname]} {
						grid $x -row 1 -column 0 -sticky news
						$x configure -auto 0
					}
				}
				auto {
					if {[winfo exists $pathname]} {
						grid $x -row 1 -column 0 -sticky news
						$x configure -auto 1
					}
				}
				never {
					if {[winfo exists $pathname]} {
						grid forget $x
						$x configure -auto 0
					}
				}
				default {
					error [msgcat::mc "bad xscroll \"%s\": must be always, auto, or never"]
				}
			}
		}
		Option add -yscroll yscroll YScroll always {
			set y $children(yscroll)
			switch -exact -- $value {
				always {
					if {[winfo exists $pathname]} {
						grid $y -row 0 -column 1 -sticky news
						$y configure -auto 0
					}
				}
				auto {
					if {[winfo exists $pathname]} {
						grid $y -row 0 -column 1 -sticky news
						$y configure -auto 1
					}
				}
				never {
					if {[winfo exists $pathname]} {
						grid forget $y
						$y configure -auto 0
					}
				}
				default {
					error [msgcat::mc "bad xscroll \"%s\": must be always, auto, or never"]
				}
			}
		}
	}
	
	method CreateBindings {} {
		next
		bind $children(canvas) <Configure> +[list $pathname resize %W %w %h]
		bind $children(frame) <Configure> +[list $pathname resize %W %w %h]
	}
	
	method frame {} {
		return $children(frame)
	}
	
	method resize {args} {
		#children
		set c $children(canvas)
		set f $children(frame)
		
		#width & height
		set fw [winfo reqwidth $f]
		set fh [winfo reqheight $f]
		set cw [winfo width $c]
		set ch [winfo height $c]
		set w [expr $fw > $cw ? $fw : $cw]
		set h [expr $fh > $ch ? $fh : $ch]
		$c itemconfigure scrolled -width $w -height $h
		$c configure -scrollregion [list 0 0 $w $h]
		
		#raise the scrollbars
		raise $children(xscroll)
		raise $children(yscroll)
	}
}