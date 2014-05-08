root = exports ? this

root.EmberJsTree = Em.Mixin.create
  ##
  # Component.
  ##
  JsTreeComponent: Em.Component.extend  
    # Properties
    roots: Em.A()
    selected: Em.A()
    
    # Private
    _tree: null
    _lastNodeId: 0
    _ignoreSelectedProperty: false

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
      # TODO

    ##
    # Reloads the whole tree recursively.
    ##
    refreshTree: (->
      Em.run.once =>
        @_attachNodes()
        @_tree.refresh()
    ).observes 'roots.[]'


    _updateSelectedProperty: (selectedIds) ->
      selected = selectedIds.map (id) => @_tree.get_node(id).original.model
      @_ignoreSelectedProperty = true
      @set('selected', selected)
      @_ignoreSelectedProperty = false      

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
                      
        node.addObserver('title', this, '_nodeTitleDidChange')
        node.addObserver('disabled', this, '_nodeDisabledDidChange')
        node.addObserver('children.[]', this, 'refreshTree')  # We'll just refresh the whole tree
        
        @_attachNodes(node.get('children'))
    ).on 'init'

    
    ##
    # Update jstree according to the selection change.
    ##
    _selectedDidChange: (->
      if !@_ignoreSelectedProperty
        ids = @get('selected').map (model) -> model._attached['id']
        @_tree.deselect_all()
        @_tree.select_node(ids, true)
    ).observes 'selected'

    _nodeTitleDidChange: (sender) ->
      @_tree.set_text(sender._attached['id'], sender.get('title')) # rename_node = not working

    _nodeDisabledDidChange: (sender) ->
      if sender.get('disabled')
        @_tree.disable_node(sender._attached['id'])
      else
        @_tree.enable_node(sender._attached['id'])
    
    ##
    # Serializes the roots into jstree-friendly json.
    # Recurses down over children.
    ##
    _serializeTree: (nodes) ->
      nodes ||= @get('roots')
      selectedNodes = @get('selected')
      
      nodes.map (node) =>
        opts = node._serialize()
        opts['id'] = node._attached['id']
        opts['state'] ||= {}
        opts['state']['selected'] = (selectedNodes.indexOf(node) != -1) # fixes selection flickering
        opts['children'] = @_serializeTree(node.get('children'))
        opts