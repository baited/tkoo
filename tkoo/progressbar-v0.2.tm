package provide tkoo::progressbar 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::progressbar {
	superclass tkoo::ttk_progressbar
	mixin tkoo::mixin::help
}