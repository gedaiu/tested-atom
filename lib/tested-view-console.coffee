{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedViewConsole extends View
	@content: ->
		@div class: 'tested-console'

	initialize: (state) ->
		true

	handleEvents: ->
		true

	clear: ->
		$(@element).html ""

	display: (msg) ->
		$(@element).append "<div class='line'>" + msg + "</div>"

	error: (msg) ->
		$(@element).append "<div class='line error'>" + msg + "</div>"
