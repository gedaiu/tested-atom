TestedViewTab     = require './tested-view-tab'
TestedViewConsole = require './tested-view-console'
TestedViewResults = require './tested-view-results'
{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedView extends View

      @content: ->
            @div class: 'tested tested-resizer tool-panel', =>
                @div class: 'tested-tabs', outlet: 'tabs', =>
                @div class: 'tested-scroller show-results', outlet: 'scroller', =>
                @div class: 'tested-resize-handle', outlet: 'resizeHandle'

      handleEvents: ->
            @on 'mousedown', '.tested-resize-handle', (e) => @resizeStarted(e)

      resizeStarted: =>
            $(document).on('mousemove', @resizeTreeView)
            $(document).on('mouseup', @resizeStopped)

      resizeStopped: =>
            $(document).off('mousemove', @resizeTreeView)
            $(document).off('mouseup', @resizeStopped)

      resizeTreeView: ({pageX, which}) =>
            return @resizeStopped() unless which is 1

            width = $(document.body).width() - pageX
            @width(width)

      initialize: (state) ->
            parent = this

            state.tests ?= {}

            @testedViewTab = new TestedViewTab()
            @tabs.append @testedViewTab.element
            @testedViewTab.onTabSelect = (tab) ->
                parent.showComponent tab

            @testedViewResults = new TestedViewResults()
            @testedViewResults.expansionStates = state.expansionStates
            @scroller.append @testedViewResults.element

            @testedViewConsole = new TestedViewConsole()
            @scroller.append @testedViewConsole.element

            @width(state.width)
            @handleEvents()

      showComponent: (tab) ->
          @scroller.removeClass "show-console show-results"
          @scroller.addClass "show-"+tab

      clear: ->
          @testedViewResults.clear()
          @testedViewConsole.clear()

      width: (value) ->
            if value? then $(".tested").width value
            $(".tested").width

      serialize: ->
          width: @width
          expansionStates: @testedViewResults.expansionStates
