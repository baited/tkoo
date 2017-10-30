package provide tkoo::text 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::text {
	superclass tkoo::tk_text
	mixin tkoo::mixin::help
	variable widCmd pathname options exists busy
	constructor {wid args} {
		#does a widget already exist with this name
		Exists $wid
		
		#set defaults, only reason for this constructor
		set busy 0
		
		#default code
		next $wid {*}$args
	}
	method CreateOptions {} {
		next
		#add "readonly" to state
		Option add -state state State normal {
			switch -exact -- $value {
				normal -
				disabled {
					set state $value
				}
				readonly {
					set state normal
				}
				default {
					return -code error [msgcat::mc "bad state \"%s\": must be normal, disabled, or readonly" $value]
				}
			}
			if {[winfo exists $pathname]} {
				$widCmd configure -state $state
			}
		}
		
		#textvariable option
		Option add -textvariable textVariable Variable "" {
			#delete old trace
			if {[string length $old]} {
				trace remove variable $old [list read write unset] [namespace code [list my TextVariable]]
			}
			
			if {[string length $value]} {
				upvar \#0 $value var
				
				if {[winfo exists $pathname] && [info exists var]} {
					set busy 1
					set state [my cget -state]
					my configure -state normal
					$widCmd delete 1.0 end
					$widCmd insert 1.0 $var
					my configure -state $state
					set busy 0
				} elseif {[winfo exists $pathname]} {
					set var [my get 1.0 end-1c]
				}
				#create a trace on the variable
				trace add variable ::$value [list read write unset] [namespace code [list my TextVariable]]
			}
		}
	}
	method insert args {
		set state [my cget -state]
		if {$state ne "readonly"} {
			set ret [$widCmd insert {*}$args]
			my TextVariable [my cget -textvariable] {} edit
			return $ret
		}
	}
	method delete args {
		set state [my cget -state]
		if {$state ne "readonly"} {
			set ret [$widCmd delete {*}$args]
			my TextVariable [my cget -textvariable] {} edit
			return $ret
		}
	}
	method replace args {
		set state [my cget -state]
		if {$state ne "readonly"} {
			set ret [$widCmd replace {*}$args]
			my TextVariable [my cget -textvariable] {} edit
			return $ret
		}
	}
	method TextVariable {name1 name2 op} {
		upvar \#0 [my cget -textvariable] var
		switch -glob -- $op {
			w* {
				if {$busy} {return}
				#get the contents of the variable
				if {[array exists var]} {
					set content $var($name2)
				} else {
					set content $var
				}
				#change the contents of the text widget
				set state [my cget -state]
				my configure -state normal
				my delete 1.0 end
				my insert 1.0 $content
				my configure -state $state
			}
			e* -
			u* -
			r* {
				if {$busy} {return}
				set busy 1
				#if the variable is read or unset, set it to the contents of the widget
				if {[array exists var]} {
					set var($name2) [my get 1.0 end-1c]
				} else {
					set var [my get 1.0 end-1c]
				}
				set busy 0
			}
		}
	}
}
