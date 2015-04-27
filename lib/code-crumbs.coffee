CodeCrumbsView = require './code-crumbs-view'
{CompositeDisposable} = require 'atom'

module.exports = CodeCrumbs =
  codeCrumbsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @codeCrumbsView = new CodeCrumbsView(state.codeCrumbsViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @codeCrumbsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'code-crumbs:toggle': => @toggle()
    atom.commands.add 'atom-workspace', 'code-crumbs:add', => @add()

  add: ->
    editor = atom.workspace.getActivePaneItem()
    if typeof editor.getTitle is 'function' and typeof editor.getPath is 'function'
      fileTitle = editor.getTitle()
      filePath = editor.getPath()
      screenRow = editor.getCursor().getScreenRow()
      markedText = editor.lineTextForScreenRow(screenRow)
      newElement = document.createElement('div')
      newElement.classList.add('crumb')
      newElement.innerHTML = fileTitle + ':' + screenRow + ': ' + markedText
      newElement.onclick = ->
        atom.workspace.open(filePath, initialLine: screenRow)
      newElement.oncontextmenu = ->
        newElement.remove()
      @codeCrumbsView.getElement().appendChild(newElement)

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @codeCrumbsView.destroy()

  serialize: ->
    codeCrumbsViewState: @codeCrumbsView.serialize()

  toggle: ->
    console.log 'CodeCrumbs was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
