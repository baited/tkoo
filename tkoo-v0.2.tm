package provide tkoo 0.2

namespace eval ::tkoo {
	namespace eval define  {
		#import every method from oo::define
		#tkoo::class will eval the body in this namespace
		apply [list [list] {
			lappend cList {*}[info commands ::oo::define::*]
			lappend cList {*}[info procs ::oo::define::*]
			set cList [lsort -dictionary -unique $cList]
			foreach c $cList {
				set c [namespace tail $c]
				proc $c {args} [string map [list !!CMD!! $c] {upvar 2 class class;uplevel 1 [list oo::define $class !!CMD!! {*}$args]}]
			}
		} [namespace current]]
	}
	#procs in this namespace are available to classes of tkoo::widget
	namespace eval Helpers {
		namespace eval Option {
			namespace export *
			namespace ensemble create
		}
		namespace export *
	}
}

proc ::tkoo::class {class body} {
	#create the class
	set class [uplevel 1 [list oo::class create $class {
		self {
			method unknown {args} {
				set w [lindex $args 0]
				if {[string match .* $w]} {
					#set cmd [list [self] new {*}$args]
					my new {*}$args
					return $w
				} else {
					next {*}$args
				}
			}
			unexport unknown
			unexport new
			unexport create
			unexport destroy
		}
	}]]
	oo::define $class variable widCmd pathname options exists
	apply [list [list] $body ::tkoo::define]
}

#procs for tkoo::define
proc ::tkoo::define::constructor {argList body} {
	upvar 2 class class
	lappend b {namespace eval [self] {namespace import ::tkoo::Helpers::*}}
	lappend b $body
	set body [join $b \n]
	uplevel 1 [list oo::define $class constructor $argList $body]
}
proc ::tkoo::define::variable {args} {
	upvar 2 class class
	lappend args widCmd pathname options exists
	set args [lsort -unique $args]
	uplevel 1 [list oo::define $class variable {*}$args]
}
proc ::tkoo::define::bind {sequence body} {
	upvar 2 class class
	set tag [string trimleft $class :]
	::bind $tag $sequence [list apply [list {body} {
		set class %W
		set ns [info object namespace $class]
		apply [list {} $body $ns]
	}] $body]
}

#helper procedures
proc ::tkoo::Helpers::ClassList {} {
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	set class [info object class $object]
	set ret [list $class]
	lappend check $class
	while {[llength $check]} {
		lappend ret {*}[info class superclasses [lindex $check 0]] {*}[info class mixins [lindex $check 0]]
		lappend check {*}[info class superclasses [lindex $check 0]] {*}[info class mixins [lindex $check 0]]
		set check [lrange $check 1 end]
	}
	set ret [lsearch -all -inline -not $ret ::oo::object]
	if {![llength $ret]} {
		return tkoo::widget
	}
	return $ret
}
proc ::tkoo::Helpers::Exists {wid} {
	#Exists wid
	#Check to see if a widget has already been created
	variable [uplevel 1 my varname exists]
	if {![info exists exists]} {set exists 0}
	if {!$exists} {
		if {[llength [info commands $wid]]} {
			error [msgcat::mc "window name \"%s\" already exists in parent" [lindex [split $wid .] end]]
		}
	}
	set exists 1
}
proc ::tkoo::Helpers::Option::add {option dbName dbClass default body args} {
	#default info and vars
	upvar 1 options options
	upvar 1 pathname pathname
	if {[catch {info object class [uplevel 1 self]} class]} {
		unset class
		upvar 1 class class
	}
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	
	#error checking
	if {![string match -* $option]} {
		return -code error [msgcat::mc "bad option name \"%s\"" $option]
	}
	
	if {![info complete $body]} {
		return -code error [msgcat::mc "invalid body script for option \"%s\" in class \"%s\"" $option $class]
	}
	
	#store info
	dict set options $option name $dbName
	dict set options $option class $dbClass
	dict set options $option default $default
	dict set options $option value $default
	dict set options $option body $body
}
proc ::tkoo::Helpers::Option::eval {option} {
	#default info and vars
	upvar 1 options options
	upvar 1 pathname pathname
	if {[catch {info object class [uplevel 1 self]} class]} {
		unset class
		upvar 1 class class
	}
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	::set namespace [info object namespace $object]
	
	#find the option
	::set o [lookup $option]
	if {![string length $o]} {
		return -code error [msgcat::mc "unknown option \"%s\"" $option]
	}
	
	#get the value
	::set value [dict get $options $o value]
	::set old [dict get $options $o old]
	
	#construct body of the option
	::set body [list]
	if {[llength [info object vars $object]]} {
		lappend body "my variable [info object vars $object]"
	}
	lappend body [dict get $options $o body]
	::set body [join $body \n]
	apply [list [list option value old] $body $namespace] $o $value $old
}
proc ::tkoo::Helpers::Option::get {{option ""}} {
	#default info and vars
	upvar 1 options options
	upvar 1 pathname pathname
	if {[catch {info object class [uplevel 1 self]} class]} {
		unset class
		upvar 1 class class
	}
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	
	if {[string length $option]} {
		::set o [lookup $option]
		if {![string length $o]} {
			return -code error [msgcat::mc "unknown option \"%s\"" $option]
		}
		::set option $o
		lappend ret $option
		lappend ret [dict get $options $option name]
		lappend ret [dict get $options $option class]
		lappend ret [dict get $options $option default]
		lappend ret [dict get $options $option value]
		return $ret
	}
	::set ret [list]
	foreach k [lsort -dictionary [dict keys $options]] {
		::set o [lookup $k]
		if {![string length $o]} {
			return -code error [msgcat::mc "unknown option \"%s\"" $k]
		}
		::set r [list]
		lappend r $o
		lappend r [dict get $options $o name]
		lappend r [dict get $options $o class]
		lappend r [dict get $options $o default]
		lappend r [dict get $options $o value]
		lappend ret $r
	}
	return $ret
}
proc ::tkoo::Helpers::Option::remove {option} {
	#default info and vars
	upvar 1 options options
	upvar 1 pathname pathname
	if {[catch {info object class [uplevel 1 self]} class]} {
		unset class
		upvar 1 class class
	}
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	catch {dict unset options $option}
}
proc ::tkoo::Helpers::Option::set {option value} {
	#default info and vars
	upvar 1 options options
	upvar 1 pathname pathname
	if {[catch {info object class [uplevel 1 self]} class]} {
		unset class
		upvar 1 class class
	}
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	
	::set opt [lookup $option]
	if {$opt eq ""} {
		return -code error [msgcat::mc "unknown option \"%s\"" $option]
	}
	::set option $opt
	
	#store old value
	::set old [dict get $options $option value]
	dict set options $option old $old
	
	#store the new value
	dict set options $option value $value
	#eval code for option
	if {[catch {eval $option} err]} {
		dict set options $option value $old
		tailcall return -code error $err
	}
}
proc ::tkoo::Helpers::Option::lookup {option} {
	upvar 1 options options
	upvar 1 pathname pathname
	if {[catch {info object class [uplevel 1 self]} class]} {
		unset class
		upvar 1 class class
	}
	if {[catch {uplevel 1 self} object]} {
		unset object
		upvar 1 object object
	}
	
	if {[dict exists $options $option]} {
		return $option
	}
	::set oList [dict filter $options key ${option}*]
	if {[llength $oList] == 2} {
		return [lindex $oList 0]
	} else {
		return
	}
}

proc ::tkoo::Helpers::mc {src args} {
	#hope msgcat doesn't change the way it stores messages
	#most of the code is ripped straight from msgcat::mc, with minor modifications
	variable ::msgcat::Msgs
	variable ::msgcat::Loclist
	variable ::msgcat::Locale
	
	#other variables
	set searched [list]
	set nslist [list]
	
	#search classes for the string
	foreach cls [uplevel 1 {ClassList}] {
		#only search each class once, incase of multiple inheritance
		if {$cls in $searched} {continue}
		
		#search each locale for the string
		foreach loc $Loclist {
			if {[dict exists $Msgs $loc $cls $src]} {
				if {[llength $args] == 0} {
					return [dict get $Msgs $loc $cls $src]
				} else {
					return [format [dict get $Msgs $loc $cls $src] {*}$args]
				}
			}
	    }
			
		#add class to the list of searched classes
		lappend searched $cls
		
		#add the class namespace to the list of namespaces to be searched later
		#cannot use [namespace parent] because the namespace may not exist
		lappend nslist [join [lrange [split [string map {:: :} $cls] :] 0 end-1] ::]
	}
	
	#clear the searched list
	set searched [list]
	foreach ns $nslist {
		#only search each class once, incase of multiple inheritance
		if {$ns in $searched} {continue}
		
		#search all namespaces and parents
		while {$ns != ""} {
			foreach loc $Loclist {
				if {[dict exists $Msgs $loc $ns $src]} {
					if {[llength $args] == 0} {
						return [dict get $Msgs $loc $ns $src]
					} else {
						return [format [dict get $Msgs $loc $ns $src] {*}$args]
					}
				}
		    }

		
			set ns [namespace parent $ns]
		}
		
		#add class to the list of searched classes
		lappend searched $ns
	}
	# we have not found the translation
	return [uplevel 1 [list [namespace origin msgcat::mcunknown]  $Locale $src {*}$args]]
}

proc ::tkoo::Helpers::mcmax {args} [info body ::msgcat::mcmax]

proc ::tkoo::wrap {original {new {}}} {
	#if $new was not specified, figure it out
	if {![string length $new]} {
		set new [string map [list :: _] [string trimleft $widget :]]
		set new [lindex [auto_qualify $new [uplevel 1 {namespace current}]] 0]
	}
	
	#create a dummy widget, to get options and commands
	set dummy .t
	for {set i 0} {[winfo exists $dummy]} {incr i} {set dummy .t$i}
	$original $dummy

	#get a list of supported commands
	catch {$dummy [clock clicks]} msg
	set msg [string range $msg [expr [string first : $msg] + 2] end]
	foreach c [lsearch -glob -all -inline $msg *,] {
		lappend cmds [string range $c 0 end-1]
	}
	lappend cmds [lindex $msg end]
	
	#get a list of supported options
	set opts [$dummy configure]
	
	#destroy dummy
	destroy $dummy
	
	#create class body
	set map [list !OPTIONS! $opts !COMMANDS! $cmds !CLASS! $new !WIDGET! $original]
	set cBody [string map $map {
		tkoo::class !CLASS! {
			superclass tkoo::widget
			variable options widCmd pathname exists
			method Create {wid args} {
				if {![winfo exists $wid]} {
					set option(pass) [dict create]
					set option(readonly) [dict create]
					foreach {o v} $args {
						switch -exact -- [Option lookup $o] {
							-class -
							-container -
							-orient -
							-use -
							-visual {
								dict set option(pass) $o $v
								dict set options [Option lookup $o] value $v
							}
							default {
								dict set option(readonly) $o $v
							}
						}
					}
					!WIDGET! $wid {*}$option(pass)
					next $wid {*}$option(readonly)
				} else {next $wid {*}$args}
			}
			method CreateOptions {} {
				foreach o [list !OPTIONS!] {
					if {[llength $o] != 5} continue
					foreach {1 2 3 4 5} $o {}
					Option add $1 $2 $3 $4 {
						if {![info exist $pathname]} {
							$widCmd configure $option $value
						}
					}
				}
			}
			foreach c [list !COMMANDS!] {
				switch -exact -- $c {
					configure -
					cget {}
					default {
						method $c {args} [string map [list !METHOD! $c] {
							tailcall $widCmd !METHOD! {*}$args
						}]
					}
				}
			}
		}
	}]
	apply [list {} $cBody [uplevel 1 {namespace current}]]
}

tkoo::class ::tkoo::widget {
	variable widCmd pathname options exists
	constructor {wid args} {
		#has the widget already been created
		Exists $wid
		
		#store the widget pathname & defaults
		set pathname $wid
		set widCmd $wid ;#it's not renamed yet
		set options [dict create]
		
		#create options
		my CreateOptions
		
		#create the widget
		my Create $wid {*}$args
		
		#create bindings
		my CreateBindings
		
		#rename the widget command
		set widCmd _$wid
		for {set i 0} {[llength [info commands ::$widCmd]]} {incr i} {set widCmd _${i}_$wid}
		rename ::$wid ::$widCmd
		
		#rename this object
		rename [self] ::$wid
		
		#default bindings
	}
	destructor {
		#get rid of the widget
		if {[info exists pathname] && [winfo exists $pathname]} {
			bind $pathname <Destroy> {}
			destroy $pathname
		}
		
		#get rid of widget commands
		if {[info exists widCmd] && [llength [info commands $widCmd]]} {
			rename $widCmd {}
		}
		if {[info exists pathname] && [llength [info commands $pathname]]} {
			rename $pathname {}
		}
	}
	method unknown {args} {
		set methods [info object methods [self] -all]
		set methods [lsearch -glob -all -inline $methods [lindex $args 0]*]
		if {[llength $methods] == 1} {
			[self] [lindex $methods 0] {*}[lrange $args 1 end]
		} else {
			next {*}$args
		}
	}
	method Create {wid args} {
		if {![winfo exists $wid]} {
			ttk::frame $wid
		}
		my configure {*}$args
	}
	method CreateOptions {} {}
	method CreateBindings {} {
		set bList [bindtags $pathname]
		foreach c [ClassList] {
			lappend bList [string trimleft $c :]
		}
		bindtags $pathname $bList
	}
	method BindDestroy {} {
		if {[lsearch [info commands [self]] [self]] >= 0} {
			my destroy
		}
	}
	method configure {args} {
		if {(![llength $args]) || ([llength $args] == 1)} {
			#no options or one option specified, return options
			Option get {*}$args
		} elseif {[llength $args] % 2} {
			#odd number of arguments specified, invalid
			return -code error [mc "value for \"%s\" missing" [lindex args end]]
		} else {
			#even number of arguments specified, set option value pairs
			foreach {o v} $args {
				Option set $o $v
			}
		}
	}
	method cget {option} {
		set r [Option get $option]
		return [lindex $r end]
	}
	bind <Destroy> {my BindDestroy}
	unexport destroy
	unexport unknown
}

#init
apply {{} {
	#wrap all default tk widgets, so they can be superclassed easily
	lappend widgets ::tk::button ::tk::canvas ::tk::checkbutton ::tk::entry ::tk::frame ::tk::label
	lappend widgets ::tk::labelframe ::tk::listbox ::tk::menubutton ::tk::message
	lappend widgets ::tk::panedwindow ::tk::radiobutton ::tk::scale ::tk::toplevel
	lappend widgets ::tk::scrollbar ::tk::spinbox ::tk::text ::ttk::button
	lappend widgets ::ttk::checkbutton ::ttk::entry ::ttk::frame ::ttk::label
	lappend widgets ::ttk::labelframe ::ttk::menubutton ::ttk::notebook
	lappend widgets ::ttk::panedwindow ::ttk::progressbar ::ttk::radiobutton
	lappend widgets ::ttk::scale ::ttk::scrollbar ::ttk::separator
	lappend widgets ::ttk::sizegrip ::ttk::spinbox ::ttk::treeview ::ttk::combobox
	foreach w $widgets {
		set new [namespace current]::[string map [list :: _] [string trimleft $w :]]
		if {[catch {wrap $w $new} msg]} {
			#puts $w
			#puts $msg
		}
	}
} ::tkoo}
