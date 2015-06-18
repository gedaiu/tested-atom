TestedView = require './tested-view'
TestedButtonView = require './tested-button-view'
TestedRunner = require './tested-runner'
TestedParserAtom = require './tested-parser-atom'
TestedParserDefault = require './tested-parser-default'

{CompositeDisposable, Point} = require 'atom'

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
            width: 200,
            expansionStates: {},
      }

      @testedView = new TestedView(state.testedViewState)

      @testedRunner = new TestedRunner(@parser())

      @modalPanel = atom.workspace.addRightPanel(item: @testedView.element, visible: false)

      parent = this
      @testedView.testedViewResults.onJump = @jump
      @testedView.testedViewTab.onClose = () ->
          parent.close()

      # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
      @subscriptions = new CompositeDisposable

      # Register command that toggles this view
      @subscriptions.add atom.commands.add 'atom-workspace', 'tested:stop': => @kill()

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
      writer = atom.config.get('tested.testedWriter')
      if writer == "AtomTestResultWriter" then new TestedParserAtom else new TestedParserDefault

  jump: (module, row) ->
    modulePattern = new RegExp('module ' + module, 'i');

    atom.workspace.scan(modulePattern, {}, (result) ->
      atom.workspace.open(result.filePath, {
        initialLine: row
      })
    )

  close: ->
    console.log("close" , this)
    @modalPanel.hide()

  toggleExecution: ->
      running = @testedRunner.isRunning()
      @kill() if running
      @run()  if not running

  kill: ->
      @testedRunner.kill()

  run: ->
      parent = this
      @testedView.clear()

      @modalPanel.show()

      @testedRunner.run (tests) ->
            parent.testedView.testedViewResults.update tests

  consumeToolBar: (toolBar) ->
      parent = this;
      @toolBar = toolBar 'tested-tool-bar'

      button = @toolBar.addButton
            icon: 'ios-flask'
            callback: 'tested:toggleExecution'
            tooltip: 'Dub test'
            iconset: 'ion'
            priority: 10

      @toolBar.addSpacer priority: 10

      @testedButton = new TestedButtonView(@toolBar.toolBar, button)

      @testedRunner.onConsole = (msg)->
        parent.testedView.testedViewConsole.display msg

      @testedRunner.onConsoleError = (msg)->
        parent.testedView.testedViewConsole.error msg

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
