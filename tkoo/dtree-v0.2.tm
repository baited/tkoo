package provide tkoo::dtree 0.2
package require tkoo

tkoo::class tkoo::dtree {
	superclass tkoo::treeview
	variable PopulateDepth location
	method Create {wid args} {
		set PopulateDepth 1
		next $wid -columns [list fullpath expanded] -displaycolumns [list] -show tree {*}$args
	}
	method CreateOptions {} {
		next
		
		#what items to list, should be a list of the following, or all
		#directory files hidden
		#defaults to all
		Option add -list list List [list directory files hidden] {
			set list [list]
			foreach v $value {
				switch -exact -- $v {
					hidden {lappend list $v}
					directory - directories - folder - folders {lappend list directory}
					file - files {lappend list files}
					all {set list [list directory files hidden]}
					default {error [msgcat::mc "bad type \"$v\" for \"-list\": must be a list containing current, directory, drives, files, hidden, or up"]}
				}
			}
			dict set options -list value [lsort -dictionary -unique $list]
		}
		
		#override -columns to force "fullpath" and "expanded" to remain
		#they can be hidden
		Option add -columns columns Columns [list fullpath expanded] {
			foreach v [list fullpath expanded] {
				if {[lsearch -exact $value $v] < 0} {
					lappend value $v
				}
				dict set options -columns value $value
				if {[winfo exists $pathname]} {
					$pathname configure -columns $value
				}
			}
		}
		
		#-images [list drive driveimage directory dirimage file fileimage]
		#use in list of pairs, list type and image
		#use dict
		Option add -images images Images [list] {
			if {[llength $value] % 2} {
				return -code error [msgcat::mc "value for \"%s\" missing" [lindex $value end]]
			}
		}
	}
	method location {{directory ""}} {
		if {$directory ne ""} {
			if {[file isdirectory $directory]} {
				my Populate {} $directory $PopulateDepth
				set location $directory
			}
		}
		return $location
	}
	method get {args} {
		set nodes [my selection]
		set ret [list]
		
		foreach n $nodes {
			set f [my set $n fullpath]
			lappend ret $n $f
		}
		
		return $ret
	}
	method Populate {node {dir {}} {expand 0}} {
		#set the dir variable properly
		if {$node eq {} && $dir eq ""} {
			set dir [file normalize ~]
		} elseif {$node ne {}} {
			#has the tree already been expanded
			if {[my set $node expanded]} {
				if {$expand} {
					foreach c [my children $node] {
						my Populate $c
					}
				}
				return
			}
			set dir [my set $node fullpath]
		} else {
			set dir [file normalize $dir]
		}
		
		#clear children
		my delete [my children $node]
		
		#get options
		set list [my cget -list]
		
		#list directories
		if {"directory" in $list} {
			set dList [list]
			if {"hidden" in $list} {
				catch {lappend dList {*}[glob -directory $dir -nocomplain -types [list d hidden] *]}
			}
			catch {lappend dList {*}[glob -directory $dir -nocomplain -types d *]}
			set dList [lsort -dictionary -unique $dList]
			foreach d $dList {
				set id [my ListFile $node directory $d]
				if {$expand} {
					my Populate $id
				}
			}
		}
		
		if {"files" in $list} {
			set dList [list]
			if {"hidden" in $list} {
				catch {lappend dList {*}[glob -directory $dir -nocomplain -types [list f hidden] *]}
			}
			catch {lappend dList {*}[glob -directory $dir -nocomplain -types f *]}
			set dList [lsort -dictionary -unique $dList]
			foreach d $dList {
				my ListFile $node file $d
			}
		}
		
		#set flag that tells us not to run next time
		my set $node expanded yes
	}
	method ListFile {node type file} {
		set a [list]
		set imgs [my cget -images]
		switch -exact -- $type {
			file {
				set ext [string tolower [file extension $file]]
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
				if {[dict exists $imgs directory]} {
					set img [dict get $imgs directory]
					lappend a -image $img
				}
			}
			volume -
			drive {
				if {[dict exists $imgs drive]} {
					set img [dict get $img drive]
					lappend a -image $img
				}
			}
			default {return}
		}
		
		if {[string length file]} {
			set id [my insert $node end -text [file tail $file] {*}$a]
			my set $id expanded no
			my set $id fullpath $file
			if {$type ne "file"} {
				my insert $id 0 -text <load>
			}
		}
		return $id
	}
	method Expand {node} {
		set nList $node
		while {[llength $nList]} {
			set n [lindex $nList 0]
			set nList [lrange $nList 1 end]
			my item $n -open true
			my Populate $n
			foreach cn [my children $n] {
				if {$cn ne ""} {
					lappend nList $cn
				}
			}
		}
	}
	method BindTreeviewOpen {} {
		if {[my cget -singleexpand]} {
			set node [my focus]
			#get siblings
			set siblings [lsearch -exact -all -inline -not [my children [my parent $node]] $node]
			
			#collapse siblings
			foreach s $siblings {
				my Collapse $s
			}
			
			#scroll to show node
			my see $node
		}
		my Populate [my focus] "" $PopulateDepth
	}
	method BindF5 {} {
		set node [my focus]
		my set $node expanded no
		my Populate $node "" $PopulateDepth
	}
	bind <F5> {my BindF5}
}