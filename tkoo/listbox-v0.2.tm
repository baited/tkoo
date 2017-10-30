package provide tkoo::listbox 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::listbox {
	superclass tkoo::tk_listbox
	mixin tkoo::mixin::help
}