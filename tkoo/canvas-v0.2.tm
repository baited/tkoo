package provide tkoo::canvas 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::canvas {
	superclass tkoo::tk_canvas
	mixin tkoo::mixin::help
}