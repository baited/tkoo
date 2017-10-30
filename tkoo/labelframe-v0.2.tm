package provide tkoo::labelframe 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::labelframe {
	superclass tkoo::ttk_labelframe
	mixin tkoo::mixin::help
}