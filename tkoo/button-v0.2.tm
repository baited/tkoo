package provide tkoo::button 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::button {
	superclass tkoo::ttk_button
	mixin tkoo::mixin::help
}