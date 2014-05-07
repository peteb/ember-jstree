root = exports ? this

root.EmberJsTree = Em.Mixin.create
  JsTreeComponent: Em.Component.extend
  
    # Properties
    roots: Em.A()
    selected: Em.A()
    
    # Private
    _tree: null
    _lastNodeId: 0
    

    ##
    # Loads the jstree component and initializes it with
    # configuration options and a callback that will generate
    # the json representation of our nodes.
    ##
    didInsertElement: ->
      @$().jstree
        core:
          data: (_, cback) =>
            cback(@_serializeTree())

      @_tree = @$().jstree(true)

      @$().on 'changed.jstree', (event, data) =>
        Em.run.once this, ->
          @_updateSelectedProperty(data.selected)

      @$().on 'select_node.jstree', (event, data) =>
        Em.run.once this, ->
          @_updateSelectedProperty(data.selected)


    ##
    # Unregister observers etc.
    ##
    willDestroyElement: ->

    _updateSelectedProperty: (selectedIds) ->
      selected = selectedIds.map (id) => @_tree.get_node(id).original.model
      @set('selected', selected)
      
    ##
    # Reloads the whole tree recursively.
    ##
    refreshTree: (->
      Em.run.once =>
        @_attachNodes()
        @_tree.refresh()
    ).observes 'roots.[]'


    ##
    # Registers observers and generates ids for new nodes. Binds nodes
    # to this component.
    ##
    _attachNodes: ((nodes) ->
      nodes ||= @get('roots')
      
      for node, i in nodes
        if node._attached
          Em.assert('Already attached', node._attached['component'] == @elementId)
        else
          # Setup attachment metadata
          node._attached = 
            component: @elementId
            id: ++@_lastNodeId
                      
        node.addObserver('title', this, '_didUpdateNodeTitle')
        node.addObserver('disabled', this, '_didUpdateNodeDisabled')
        node.addObserver('children.[]', this, 'refreshTree')  # We'll just refresh the whole tree
        
        @_attachNodes(node.get('children'))
    ).on 'init'

    _didUpdateNodeTitle: (sender) ->
      @_tree.set_text(sender._attached['id'], sender.get('title')) # rename_node = not working

    _didUpdateNodeDisabled: (sender) ->
      if sender.get('disabled')
        @_tree.disable_node(sender._attached['id'])
      else
        @_tree.enable_node(sender._attached['id'])
    
    ##
    # Serializes the roots into jstree-friendly json.
    ##
    _serializeTree: ->
      @roots.map (root) -> root._serialize()
