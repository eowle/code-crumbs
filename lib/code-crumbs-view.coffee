{$, View} = require 'atom-space-pen-views'

module.exports =
class CodeCrumbsView extends View
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('code-crumbs', 'tree-view-resizer')

    resizer = document.createElement('div')
    resizer.classList.add('tree-view-resize-handle')
    resizer.setAttribute('outlet', 'resizeHandle')

    @list = document.createElement('div')
    @list.classList.add('crumb-list')

    # Create message element
    message = document.createElement('div')
    message.classList.add('header')
    message.textContent = "Code Crumbs"
    message.classList.add('message')
    @element.appendChild(message)
    @element.appendChild(@list)
    @element.appendChild(resizer)

  handleEvents: ->
    $('.code-crumbs .tree-view-resize-handle').on('mousedown', (e) =>
      @resizeStarted(e)
    )

  resizeStarted: =>
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)

  resizeTreeView: ({pageX, which}) =>
    return @resizeStopped() unless which is 1

    width = $(document.body).width() - pageX
    $('.code-crumbs').css('width', width)

  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  detached: ->
    @resizeStopped()
