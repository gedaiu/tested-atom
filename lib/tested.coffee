TestedView = require './tested-view'
TestedButtonView = require './tested-button-view'
TestedRunner = require './tested-runner'
TestedParserAtom = require './tested-parser-atom'
TestedParserDefault = require './tested-parser-default'

{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'


module.exports = Tested =
  testedView: null
  modalPanel: null
  subscriptions: null
  testedRunner: null

  config:
    dubPath:
      type: 'string'
      default: "dub"
    dubArguments:
      type: 'string'
      default: ""
    testedWriter:
      type: 'string'
      default: "ConsoleTestResultWriter"
      enum: ["ConsoleTestResultWriter", "AtomTestResultWriter"]

  activate: (state) ->

      state.testedViewState ?= {
            tests: {},
            width: 200,
            expansionStates: {}
      }

      @testedView = new TestedView(state.testedViewState, {})
      @testedRunner = new TestedRunner(@parser())

      @modalPanel = atom.workspace.addRightPanel(item: @testedView.element, visible: false)

      # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
      @subscriptions = new CompositeDisposable

      # Register command that toggles this view
      @subscriptions.add atom.commands.add 'atom-workspace', 'tested:toggle': => @toggle()

      # Register command that starts the tests
      @subscriptions.add atom.commands.add 'atom-workspace', 'tested:run': => @run()

      # Register command that starts the tests
      @subscriptions.add atom.commands.add 'atom-workspace', 'tested:toggleExecution': => @toggleExecution()

  deactivate: ->
      @modalPanel.destroy()
      @subscriptions.dispose()
      @testedView.destroy()

  serialize: ->
      testedViewState: @testedView.serialize()

  parser: ->
      writer = atom.config.get('tested.dubArguments')
      if writer == "AtomTestResultWriter" then new TestedParserAtom else new TestedParserDefault

  toggle: ->
      if @modalPanel.isVisible()
            @modalPanel.hide()
      else
            @modalPanel.show()

  toggleExecution: ->
      running = @testedRunner.isRunning()
      @kill() if running
      @run()  if not running

  kill: ->
      @testedRunner.kill()

  run: ->
      parent = this
      @testedView.update {}

      @modalPanel.show()

      @testedRunner.run (tests) ->
            parent.testedView.update tests

  consumeToolBar: (toolBar) ->
      parent = this;
      @toolBar = toolBar 'main-tool-bar'

      @toolBar.addButton
            icon: 'ios-flask-outline'
            callback: 'tested:toggleExecution'
            tooltip: 'Dub test'
            iconset: 'ion'

      @testedButton = new TestedButtonView @toolBar.toolBar

      @testedRunner.onStart = ->
            parent.testedButton.start()

      @testedRunner.onStop = (code) ->
            parent.testedButton.stop()
            atom.notifications.addError("Dub exited with code " + code) if code != 0

      @testedRunner.onSuccess = (nrTests, nrTestsSuccess) ->
            atom.notifications.addSuccess(nrTests + " tests passed") if nrTests == nrTestsSuccess and nrTests > 0

            failed = nrTests - nrTestsSuccess

            atom.notifications.addError("1 test failed") if failed == 1 and nrTests > 0
            atom.notifications.addError(failed + " tests failed") if failed > 1 and nrTests > 0
