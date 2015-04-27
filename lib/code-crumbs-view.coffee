module.exports =
class CodeCrumbsView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('code-crumbs')

    # Create message element
    message = document.createElement('div')
    message.classList.add('header')
    message.textContent = "Code Crumbs"
    message.classList.add('message')
    @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
