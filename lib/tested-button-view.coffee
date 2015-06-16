{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedButtonView extends View
	content: ->
		"<div class='tested-btn-runner'>" +
			"<div class='tested-start ion ion-ios-play'></div>" +
			"<div class='tested-stop ion ion-android-checkbox-blank'></div>" +
		"</div>"

	constructor: (toolBar) ->
		@toolBar = toolBar
		$(toolBar.element).find("button[data-original-title='Dub test']").append @content()

		@btn = $(toolBar.element).find("button[data-original-title='Dub test'] .tested-btn-runner");

	start: ->
		@btn.addClass "tested-running"

	stop: ->
		@btn.removeClass "tested-running"
