package provide tkoo::mixin::help 0.2
package require tkoo

tkoo::class tkoo::mixin::help {
	variable widCmd pathname options exists cmderr oldtext mouseover
	method CreateOptions {} {
		#defaults
		set cmderr 0
		set oldtext ""
		set mouseover 0
		
		#default code
		next
		
		#extra options
		Option add -helptext helpText HelpText {} {
			set cmderr 0
			if {$mouseover} {
				set helpVarName [my cget -helpvariable]
				upvar #0 $helpVarName helpVar
				set helpVar $value
			}
		}
		Option add -helpvariable helpVariable HelpVariable {} {
			set cmderr 0
		}
	}
	method BindEnter {args} {
		set mouseover 1
		#error detection, stop on errors
		if {!$cmderr} {
			set cmderr 1;#error flag
			
			#get option info
			set helpVarName [my cget -helpvariable]
			set helpText [my cget -helptext]
			
			#set the help variable
			if {[string length $helpVarName]} {
				upvar #0 $helpVarName helpVar
				set oldtext $helpVar
				set helpVar $helpText
			}
			
			#reset error flag
			set cmderr 0
		}
		if {[llength [self next]]} {
			next {*}$args
		}
	}
	method BindLeave {args} {
		set mouseover 0
		#error detection, stop on errors
		if {!$cmderr} {
			set cmderr 1;#error flag
			
			#get option info
			set helpVarName [my cget -helpvariable]
			set helpText [my cget -helptext]
			
			#restore help variable text
			if {[string length $helpVarName]} {
				upvar #0 $helpVarName helpVar
				set helpVar $oldtext
				#set oldtext ""
			}
			
			#reset error flag
			set cmderr 0
		}
		if {[llength [self next]]} {
			next {*}$args
		}
	}
	
	bind <Enter> {my BindEnter}
	bind <Leave> {my BindLeave}
}