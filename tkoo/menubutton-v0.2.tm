package provide tkoo::menubutton 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::menubutton {
	superclass tkoo::ttk_menubutton
	mixin tkoo::mixin::help
}