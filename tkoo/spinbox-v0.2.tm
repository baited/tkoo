package provide tkoo::spinbox 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::spinbox {
	superclass tkoo::ttk_spinbox
	mixin tkoo::mixin::help
}