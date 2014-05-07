root = exports ? this

##
# Wrapper object for nodes in the jstree component.
##
root.Node = Em.Object.extend
  title: 'hullo'
  children: null
  disabled: false
  
  ##
  # Constructor
  ##
  init: ->
    @children = Em.A()
  
  
  ##
  # Returns jstree-friendly json.
  ##
  _serialize: ->
    text: @get('title')
    children: @get('children').map (child) -> child._serialize()
    id: @_attached['id']
    model: this
    state:
      disabled: @get('disabled')