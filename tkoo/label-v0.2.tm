package provide tkoo::label 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::label {
	superclass tkoo::ttk_label
	mixin tkoo::mixin::help
}