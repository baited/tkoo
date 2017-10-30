package provide tkoo::separator 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::separator {
	superclass tkoo::ttk_separator
	mixin tkoo::mixin::help
}