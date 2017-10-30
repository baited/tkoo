package provide tkoo::treeview 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::treeview {
	superclass tkoo::ttk_treeview
	mixin tkoo::mixin::help
	
	method CreateOptions {} {
		next
		Option add -singleexpand singleExpand SingleExpand false {
			if {![string is boolean -strict $value]} {error [msgcat::mc "expected boolean value but got \"%s\"" $value]}
		}

	}
	
	method BindTreeviewOpen {args} {
		if {[my cget -singleexpand]} {
			set node [my focus]
			#get siblings
			set siblings [lsearch -exact -all -inline -not [my children [my parent $node]] $node]
			
			#collapse siblings
			foreach s $siblings {
				my item $s -open false
			}
			
			#scroll to show node
			my see $node
		}
	}
	
	method BindAsterisk {args} {
		set node [my focus]
		if {![my cget -singleexpand]} {
			my Expand $node
		} else {
			my item $node -open true
		}
	}
	
	method BindShiftAsterisk {args} {
		set node [my focus]
		my Collapse $node
	}
	
	#method to fully expand a node
	method Expand {node} {
		if {![my cget -singleexpand]} {
			set nList $node
			while {[llength $nList]} {
				set n [lindex $nList 0]
				set nList [lrange $nList 1 end]
				my item $n -open true
				foreach cn [my children $n] {
					if {$cn ne ""} {
						lappend nList $cn
					}
				}
			}
		}
	}
	
	#method to fully collapse a node
	method Collapse {node} {
		set nList $node
		while {[llength $nList]} {
			set n [lindex $nList 0]
			set nList [lrange $nList 1 end]
			my item $n -open false
			foreach cn [my children $n] {
				if {$cn ne ""} {
					lappend nList $cn
				}
			}
		}
	}
	
	#bindings
	bind <<TreeviewOpen>> {my BindTreeviewOpen}
	bind <*> {my BindAsterisk}
	bind <Shift-*> {my BindShiftAsterisk}
}