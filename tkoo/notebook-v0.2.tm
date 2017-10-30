package provide tkoo::notebook 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::notebook {
	superclass tkoo::ttk_notebook
	mixin tkoo::mixin::help
	variable widCmd pathname scrollpos hsizes tabheight winstate
	constructor {wid args} {
		#check to see if the class already exists
		Exists $wid

		#default code
		next $wid {*}$args
		
		#defaults
		set scrollpos 0
		set startindex 0
		my UpdateHSize
		
		#children
		ttk::button $wid.escroll -style EButton.TButton -command [namespace code [list my Scroll e]]
		ttk::button $wid.wscroll -style WButton.TButton -command [namespace code [list my Scroll w]]
		
	}
	method Create {wid args} {
		#default code
		next $wid {*}$args
	}
	method BindConfigure {args} {
		my ScrollNotebook
	}
	
	method BindClick {x y args} {
		set tab [my identify tab $x $y]
		if {$tab eq "" || [my index end] <= 1} {
			return
		}
		set winstate(x) $x
		set winstate(t) [lindex [my tabs] $tab]
		set winstate(e) 0
	}
	
	method BindUClick {x y args} {
		array unset winstate ?
	}
	
	method BindDrag {x y args} {
		if {![info exists winstate(x)] || ![info exists winstate(t)] || $winstate(t) eq ""} {return}
		
		set where [my identify tab $x $y]
		if {[info exists winstate(a)]} {
			if {$x < $winstate(a) && $where < $winstate(i)} {
				unset -nocomplain winstate(a) winstate(i) winstate(j)
			} elseif {$x > $winstate(a) && $where > $winstate(i)} {
				unset -nocomplain winstate(a) winstate(i) winstate(j)
			}
		}
		if {$where ne ""} {
			set what [lindex [my tabs] $where]
		} else {
			set what ""
		}
		if {$what eq $winstate(t)} {return}
		if {$what eq ""} {
			if {$winstate(e)} {return}
			set winstate(e) 1
			if {$x < $winstate(x)} {
				my insert 0 $winstate(t)
			} else {
				my insert end $winstate(t)
			}
			set winstate(x) $x
		} else {
			set winstate(e) 0
			if {[info exists winstate(j)] && $what eq $winstate(j)} {
				if {(($x > $winstate(x) && $x > $winstate(a)) || ($x < $winstate(x) && $x < $winstate(a)))} {return}
			}
			my insert $what $winstate(t)
			set winstate(j) $what
			set winstate(a) $x
			set winstate(i) $where
		}
	}
	
	method UpdateHSize {args} {
		set ntabs [my index end]
		set tabs [my tabs]
		
		set tmp [my TempWid]
		ttk::notebook $tmp -style [my cget -style]
		set p0 [winfo reqwidth $tmp]
		set hsizes($pathname) $p0
		
		for {set i 0} {$i < $ntabs} {incr i} {
			set tab [lindex $tabs $i]
			
			eval $tmp add [ttk::frame $tmp.f$i] [$widCmd tab $tab] -state normal
			update idletasks
			set hsizes($tab) [expr [winfo reqwidth $tmp] - $p0]
			set p0 [winfo reqwidth $tmp]
		}
		destroy $tmp
		ttk::label $tmp -style TNotebook.Tab
		set tabheight [winfo reqheight $tmp]
		destroy $tmp
	}
	
	method ScrollNotebook {args} {
		set startindex $scrollpos
		for {set i 0} {$i < $startindex} {incr i} {
			$widCmd hide $i
		}
		set ntabs [my index end]
		set tabs [my tabs]
		
		set availw [winfo width $pathname]
		set reqw $hsizes($pathname)
		set overflow 0
		for {} {$i < $ntabs} {incr i} {
			set tab [lindex $tabs $i]
			incr reqw $hsizes($tab)
			$widCmd add $tab
			if {$reqw > $availw} {
				incr i
				set overflow 1
				break
			}
		}
		for {set j $i} {$j < $ntabs} {incr j} {
			$widCmd hide [lindex $tabs $j]
		}
		set h $tabheight
		
		set eh [expr 4 * $h / 5]
		if {$startindex > 0} {
			set ew [expr $eh * [winfo reqwidth $pathname.escroll] / [winfo reqheight $pathname.escroll]]
			place $pathname.escroll -x 0 -y 0 -width $ew -height $eh
		} else {
			place forget $pathname.escroll
		}
		if {$overflow} {
			set ew [expr $eh * [winfo reqwidth $pathname.wscroll] / [winfo reqheight $pathname.wscroll]]
			place $pathname.wscroll -relx 1.0 -x -$ew -y 0 -width $ew -height $eh
		} else {
			place forget $pathname.wscroll
		}
	}
	
	method Scroll {d args} {
		switch -exact -- $d {
			e {
				if {$scrollpos > 0} {
					incr scrollpos -1
					my ScrollNotebook
				}
			}
			w {
				if {$scrollpos + 1 < [llength [my tabs]]} {
					incr scrollpos
					my ScrollNotebook
				}
			}
		}
	}
	
	method TempWid {} {
		#returns an unused widget name
		set r .0
		set i 0
		while {[winfo exists $r]} {
			set r .[incr i]
		}
		return $r
	}

	foreach m [list add forget hide insert tab] {
		method $m {args} {
			::bind tkoo::notebook <Configure> {}
			set ret [next {*}$args]
			my UpdateHSize
			::bind tkoo::notebook <Configure> [namespace code [list my ScrollNotebook]]
			my ScrollNotebook
			return $ret
		}
	}
	bind <Configure> {my BindConfigure}
	bind <Button-1> {my BindClick %x %y}
	bind <ButtonRelease-1> {my BindUClick %x %y}
	bind <B1-Motion> {my BindDrag %x %y}
}
apply {{} {
	# create scroll buttons
	foreach t [ttk::style theme names] {
		ttk::style theme settings $t {  
			foreach anchor {n s e w} arrow {uparrow downarrow leftarrow rightarrow} {
				set uanchor [string toupper $anchor]
				ttk::style layout ${uanchor}Button.TButton [list Button.focus -sticky nswe -children [list ${uanchor}Button.$arrow -sticky nswe]]
			}
		}
	}
}}
