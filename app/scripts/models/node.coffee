root = exports ? this

##
# Wrapper object for nodes in the jstree component.
##
root.Node = Em.Object.extend
  # Properties
  title: 'hullo'
  children: null
  disabled: false
  editing: false
  
  ##
  # Constructor
  ##
  init: ->
    @children = Em.A()
  
  
  ##
  # Returns jstree-json. No recursing here.
  ##
  _serialize: ->
    text: @get('title')
    model: this
    state:
      disabled: @get('disabled')