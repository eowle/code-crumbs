CodeCrumbsView = require './code-crumbs-view'
{CompositeDisposable} = require 'atom'
{$, TextEditorView} = require 'atom-space-pen-views'

module.exports = CodeCrumbs =
  codeCrumbsView: null
  modalPanel: null
  subscriptions: null
  annotationModal: null

  activate: (state) ->
    @codeCrumbsView = new CodeCrumbsView(state.codeCrumbsViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @codeCrumbsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'code-crumbs:toggle': => @toggle()
    atom.commands.add 'atom-workspace', 'code-crumbs:add', => @add()
    atom.commands.add 'atom-workspace', 'code-crumbs:remove', => @remove()
    atom.commands.add 'atom-workspace', 'code-crumbs:annotate', => @annotate()

  add: ->
    editor = atom.workspace.getActivePaneItem()
    if typeof editor.getTitle is 'function' and typeof editor.getPath is 'function'
      fileTitle = editor.getTitle()
      filePath = editor.getPath()
      screenRow = editor.getLastCursor().getScreenRow()
      markedText = editor.lineTextForScreenRow(screenRow)
      newElement = document.createElement('div')
      newElement.classList.add('crumb')
      newElement.innerHTML = fileTitle + ':' + screenRow + ': ' + markedText

      newElement.onclick = ->
        atom.workspace.open(filePath, initialLine: screenRow)
      newElement.oncontextmenu = ->
        CodeCrumbs.deselect()
        newElement.classList.add('selected')
      @codeCrumbsView.getElement().appendChild(newElement)

  remove: ->
    $(".crumb.selected").remove()

  deselect: ->
    $(".crumb.selected").removeClass('selected')

  annotate: ->
    modalContent = new TextEditorView(mini: true)
    $(modalContent).keyup (e) ->

      if e.which is 13
        annotation = modalContent.getText()
        $(".crumb.selected").text(annotation)
        CodeCrumbs.annotationModal.destroy()
      else if e.which is 27
        CodeCrumbs.annotationModal.destroy()

    @annotationModal = atom.workspace.addModalPanel(item: modalContent, visible: true)
    $(modalContent).focus()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @codeCrumbsView.destroy()

  serialize: ->
    codeCrumbsViewState: @codeCrumbsView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
