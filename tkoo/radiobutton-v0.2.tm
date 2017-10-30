package provide tkoo::radiobutton 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::radiobutton {
	superclass tkoo::ttk_radiobutton
	mixin tkoo::mixin::help
}