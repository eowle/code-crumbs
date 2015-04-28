CodeCrumbsView = require './code-crumbs-view'
{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports = CodeCrumbs =
  codeCrumbsView: null
  modalPanel: null
  subscriptions: null
  annotationModal: null
  crumbs: {}

  activate: (state) ->
    atom.deserializers.add(this)

    @codeCrumbsView = new CodeCrumbsView(state.codeCrumbsViewState)

    if state
      atom.deserializers.deserialize(state)

    @modalPanel = atom.workspace.addRightPanel(item: @codeCrumbsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'code-crumbs:toggle': => @toggle()
    atom.commands.add 'atom-workspace', 'code-crumbs:add', => @add()
    atom.commands.add 'atom-workspace', 'code-crumbs:remove', => @remove()
    atom.commands.add 'atom-workspace', 'code-crumbs:annotate', => @annotate()

  addFromParams: (title, path, row, text, annotation) ->
    newElement = document.createElement('div')
    newElement.classList.add('crumb')
    crumbId = @getCrumbId(title, row)

    if annotation
      newElement.innerHTML = crumbId + ': ' + annotation
    else
      newElement.innerHTML = crumbId + ': ' + text

    newElement.setAttribute('crumb-id', crumbId)

    @crumbs[crumbId] = {
        title: title,
        path: path,
        row: row,
        rowText: text,
        annotation: annotation
    }

    newElement.onclick = ->
      atom.workspace.open(path, initialLine: row)
    newElement.oncontextmenu = ->
      CodeCrumbs.deselect()
      newElement.classList.add('selected')
    @codeCrumbsView.getElement().appendChild(newElement)

  add: ->
    editor = atom.workspace.getActivePaneItem()
    if typeof editor.getTitle is 'function' and typeof editor.getPath is 'function'
      fileTitle = editor.getTitle()
      filePath = editor.getPath()
      screenRow = editor.getLastCursor().getScreenRow()
      markedText = editor.lineTextForScreenRow(screenRow)
      @addFromParams(fileTitle, filePath, screenRow, markedText, '')

  remove: ->
    crumbId = $(".crumb.selected").attr('crumb-id');
    delete(@crumbs[crumbId])
    $(".crumb.selected").remove()

  deselect: ->
    $(".crumb.selected").removeClass('selected')

  annotate: ->
    modalContent = new TextEditorView(mini: true)
    crumbId = $('.crumb.selected').attr('crumb-id')
    $(modalContent).keyup (e) ->
      if e.which is 13
        annotation = modalContent.getText()
        $(".crumb.selected").text(crumbId + ': ' + annotation)
        CodeCrumbs.crumbs[crumbId].annotation = annotation
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
    JSON.stringify({deserializer: 'CodeCrumbs', data: @crumbs})

  deserialize: (state) ->
    obj = state

    if typeof state is 'string'
        obj = JSON.parse(state)

    if obj.hasOwnProperty('data')
      data = obj.data

      $.each(Object.keys(obj.data), (index, d) ->
        CodeCrumbs.addFromParams(data[d].title, data[d].path, data[d].row, data[d].rowText, data[d].annotation)
      )

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  getCrumbId: (fileTitle, row) ->
    return fileTitle + ':' + row
