root = exports ? this

root.Node = Em.Object.extend
  title: 'hullo'
  children: null
  
  init: ->
    @children = Em.A()
  
  _serialize: ->
    text: @get('title')
    children: @get('children').map (child) -> child._serialize()
    id: @_attached['id']