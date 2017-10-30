package provide tkoo::frame 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::frame {
	superclass tkoo::ttk_frame
	mixin tkoo::mixin::help
}