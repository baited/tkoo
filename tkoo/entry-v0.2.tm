package provide tkoo::entry 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::entry {
	superclass tkoo::ttk_entry
	mixin tkoo::mixin::help
	variable pathname options widCmd history
	constructor {wid args} {
		#check to see if the class already exists
		Exists $wid
		
		#default code
		next $wid {*}$args
		
		#default variables
		set history(index) 0
		set history(list) [list]
	}
	method add {text} {
		if {[string compare $text [lindex $history(list) end]]} {
			lappend history(list) $text
		}
		set history(index) [llength $history(list)]
		my delete 0 end
	}
	method move {offset} {
		if {![string is int -strict $offset]} {return}
		incr history(index) $offset
		if {$history(index) < 0} {
			set history(index) 0
			#set history(index) [llength $history(list)]
		}
		if {$history(index) > [llength $history(list)]} {
			#set history(index) 0
			set history(index) [llength $history(list)]
		}
		my delete 0 end
		my insert 0 [lindex $history(list) $history(index)] 
	}
	bind <Up> {%W move -1}
	bind <Down> {%W move 1}
	bind <Return> {%W add [%W get]}
}