{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedTabView extends View
	@content: ->
		@ul class: 'list-inline tab-bar', =>
			@li "data-name": "results", class: 'tab active tested-tab tested-tab-results', =>
				@div class: 'title', outlet: 'results'
			@li "data-name": "console", class: 'tab tested-tab tested-tab-console', =>
				@div class: 'title', outlet: 'console'

	initialize: (state) ->
		@results.html "Results"
		@console.html "Console"

		@handleEvents()

	handleEvents: ->
		@on 'mousedown', '.tested-tab', (e) =>
			@onTabSelect( $(e.currentTarget).attr("data-name") )

			$('.tested-tab').removeClass "active"
			$(e.currentTarget).addClass "active"
