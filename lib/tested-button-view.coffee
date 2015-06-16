{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedButtonView extends View


	constructor: (toolBar, button) ->
		@toolBar = toolBar
		@button = button

	start: ->
		@button.addClass "tested-running"

	stop: ->
		@button.removeClass "tested-running"
