package provide tkoo::sizegrip 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::sizegrip {
	superclass tkoo::ttk_sizegrip
	mixin tkoo::mixin::help
}