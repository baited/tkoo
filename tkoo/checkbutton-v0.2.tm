package provide tkoo::checkbutton 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::checkbutton {
	superclass tkoo::ttk_checkbutton
	mixin tkoo::mixin::help
}