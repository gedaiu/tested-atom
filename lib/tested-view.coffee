TestedViewTab = require './tested-view-tab'
{$, View} = require 'atom-space-pen-views'

module.exports =
class TestedView extends View

      @content: ->
            @div class: 'tested tested-resizer tool-panel', =>
                @div class: 'tested-tabs', outlet: 'tabs', =>

                @div class: 'tested-scroller show-results', outlet: 'scroller', =>
                    @div class: 'tested-results', outlet: "moduleList"
                    @div class: 'tested-console', outlet: 'console'

                @div class: 'tested-resize-handle', outlet: 'resizeHandle'

      handleEvents: ->
          @on 'mousedown', '.test', (e) =>
              @jump(e)

            @on 'mousedown', '.module', (e) =>
              @showModule(e)

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
            @testedViewTab.onTabSelect = (tab) ->
                parent.showComponent tab

            @tabs.append @testedViewTab.element

            @update state.tests

            @width(state.width)
            @updateExpansionStates(state.expansionStates)

            @handleEvents()

      showComponent: (tab) ->
          @scroller.removeClass "show-console show-results"
          @scroller.addClass "show-"+tab

      showModule: (e) ->
            e.stopPropagation()
            parent = $(e.target).parent()

            parent.toggleClass("open")

            id = parent.attr("data-id")

            if(parent.is(".open"))
                  @expansionStates[id] = true
            else
                  delete @expansionStates[id]

      jump: (e) ->
            e.stopPropagation()
            element = $(e.target)
            @onJump(element.attr("data-module"), parseInt(element.attr("data-line")))

      clear: ->
          @console.html ""
          @moduleList.html ""

      createLevel: (tests, name, id) ->
            list = for key, value of tests
                  if value.name then @createTest value else @createLevel(tests[key], key, id + "." + key)

            open = " open" if @expansionStates[id]
            open ?= ""

            "<li data-id='" + id + "' class='container" + open + "'><span class='module test-pass icon icon-file-directory'>#{name}</span><ol>" + list.join("") + "</ol></li>"

      createModules: (tests) ->
            list = for key, value of tests
                  "<ol>" + @createLevel(tests[key], key, key) + "</ol>"
            list.join("")

      createTest: (test) ->
            if test.result == "PASS"
                  "<li><span data-module='#{test.module}' data-line='#{test.line}' class='test test-pass icon icon-check'>#{test.name}</span></li>"

            else if test.result == "FAIL"
                  "<li><span data-module='#{test.module}' data-line='#{test.line}' class='test test-fail icon icon-x'>#{test.name}</span></li>"
            else
                  "<li><span data-module='#{test.module}' data-line='#{test.line}' class='test icon icon-triangle-right'>#{test.name}</span></li>"

      updateParentFailed: ->
            $(".test-fail").each ->
                  parent = $(this).parent();

                  while parent.is("ol, li")
                        parent.children().removeClass("test-pass").addClass "test-fail"
                        parent = parent.parent()

      update: (tests) ->
            @moduleList.html ""
            @moduleList.append( @createModules tests )
            @updateParentFailed()

      displayOnConsole: (msg) ->
            @console.append "<div class='line'>" + msg + "</div>"

      displayErrorOnConsole: (msg) ->
            @console.append "<div class='line error'>" + msg + "</div>"

      width: (value) ->
            if value? then $(".tested").width value
            $(".tested").width

      updateExpansionStates: (value) =>
            @expansionStates  = value
            @expansionStates ?= {}

            for id of @expansionStates
                  $('[data-id="' + id + '"]').addClass("open")

      serialize: ->
          width: @width
          expansionStates: @expansionStates
