package provide tkoo::message 0.2
package require tkoo
package require tkoo::mixin::help

tkoo::class tkoo::message {
	superclass tkoo::tk_message
	mixin tkoo::mixin::help
}