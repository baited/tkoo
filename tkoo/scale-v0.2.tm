package provide tkoo::scale 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::scale {
	superclass tkoo::ttk_scale
	mixin tkoo::mixin::help
}