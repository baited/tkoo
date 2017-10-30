package provide tkoo::panedwindow 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::panedwindow {
	superclass tkoo::ttk_panedwindow
	mixin tkoo::mixin::help
}