package provide tkoo::combobox 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::combobox {
	superclass tkoo::ttk_combobox
	mixin tkoo::mixin::help
}