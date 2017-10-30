package provide tkoo::browser 0.2
package require tkoo
package require tkoo::treeview
package require tkoo::mixin::help

tkoo::class tkoo::browser {
	superclass tkoo::treeview
	variable widCmd pathname options exists location
	method CreateOptions {} {
		#default code
		next
		
		#-images [list drive driveimage directory dirimage file fileimage]
		#use in list of pairs, list type and image
		#use dict
		Option add -images images Images [list] {
			if {[llength $value] % 2} {
				return -code error [msgcat::mc "value for \"%s\" missing" [lindex $value end]]
			}
		}
		
		#what items to list should be a list of the following, or all
		#current directory drives files up hidden
		#defaults to all
		Option add -list list List [list current directory drives files up hidden] {
			set list [list]
			foreach v $value {
				switch -exact -- $v {
					current - up - hidden {lappend list $v}
					directory - directories - folder - folders {lappend list directory}
					drive - drives - volume - volumes {lappend list drives}
					file - files {lappend list files}
					all {set list [list current directory drives files up hidden]}
					default {error [msgcat::mc "bad type \"$v\" for \"-list\": must be a list containing current, directory, drives, files, hidden, or up"]}
				}
			}
			dict set options -list value [lsort -dictionary -unique $list]
		}
	}
	
	#joins 'dir' with current 'location' and calls goto
	method browse {dir args} {
		global tcl_platform
		
		if {($dir eq ".." && $tcl_platform(platform) eq "windows" && [lindex [split $location /] 1] eq "") || ($dir eq ".." && $location eq "Volumes")} {
			#list volumes here
			if {"drives" in [my cget -list]} {
				my goto "<*volumes*>"
			}
		} else {
			#set the current location
			set location [file normalize [file join $location $dir]]
			my goto $location
		}
	}
	
	#change directory to 'dir' and list appropriate files
	method goto {dir args} {
		#get options
		set list [my cget -list]
		if {$dir eq "<*volumes*>"} {
			#do nothing if volumes are not to be listed
			if {"drives" ni $list} {return}
			
			#location variable
			set location "Volumes"
			
			#delete all chidren
			my delete [my children {}]
			
			#list system volumes
			foreach f [lsort -dictionary [file volumes]] {
				my ListFile volume $f
			}
		} else {
			#store location
			set location $dir
			
			#delete all chidren
			my delete [my children {}]
			
			#list '.' and '..'
			if {"current" in $list} {my ListFile directory .}
			if {"up" in $list} {my ListFile directory ..}
			
			#list directories
			if {"directory" in $list} {
				set dList [list];#directory list
				
				#hidden directories
				if {"hidden" in $list} {
					catch {lappend dList {*}[glob -directory $location -tails -types [list d hidden] -nocomplain -- *]}
				}
				
				#other directories
				catch {lappend dList {*}[glob -directory $location -tails -types [list d] -nocomplain -- *]}
				
				#list directories
				foreach f [lsort -dictionary -unique $dList] {
					my ListFile directory $f
				}
			}
			
			#list files
			if {"files" in $list} {
				set fList [list]
				
				#hidden files
				if {"hidden" in $list} {
					catch {lappend fList {*}[glob -directory $location -tails -types [list f hidden] -nocomplain -- *]}
				}
				
				#other files
				catch {lappend fList {*}[glob -directory $location -tails -types [list f] -nocomplain -- *]}
				
				#list files
				foreach f [lsort -dictionary -unique $fList] {
					my ListFile file $f
				}

			}
		}
		
		#scroll to top
		my see {}
	}
	
	#return current location
	method location {{directory ""}} {
		if {$directory ne ""} {
			if {[file isdirectory $directory]} {
				my goto $directory
			}
		}
		return $location
	}
	
	#return current selection
	method get {} {
		set nodes [my selection]
		set ret [dict create]
		
		foreach n $nodes {
			set f [my item $n -text]
			set f [file join $location $f]
			#lappend ret $n $f
			dict set ret $n $f
		}
		
		return $ret
	}
	
	#display files
	method ListFile {type name} {
		set a [list];#item options
		set imgs [my cget -images];#get images option
		switch -exact -- $type {
			file {
				set ext [string tolower [file extension $name]]
				if {[dict exists $imgs $ext]} {
					set img [dict get $imgs $ext]
					lappend a -image $img
				} elseif {[dict exists $imgs file]} {
					set img [dict get $imgs file]
					lappend a -image $img
				}
			}
			directory -
			folder {
				if {($name eq "..") && [dict exists $imgs dirup]} {
					set img [dict get $imgs dirup]
					lappend a -image $img
				} elseif {($name eq ".") && [dict exists $imgs dircurrent]} {
					set img [dict get $imgs dircurrent]
					lappend a -image $img
				} elseif {[dict exists $imgs directory]} {
					set img [dict get $imgs directory]
					lappend a -image $img
				}
			}
			volume -
			drive {
				if {[dict exists $imgs drive]} {
					set img [dict get $imgs drive]
					lappend a -image $img
				}
			}
			default {return}
		}
		if {[string length $name]} {
			my insert {} end -text $name {*}$a
		}
	}
	
	#called on double clicking an item
	method BindDClick {} {
		set select [my selection]
		if {[llength $select] != 1} {return}
		set txt [my item [my selection] -text]
		
		set f [file join $location $txt]
		if {[file isdirectory $f]} {
			my browse $txt
		}
	}
	
	#bindings
	bind <Double-1> {my BindDClick}
}