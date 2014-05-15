root = exports ? this

root.EmberJsTree = Em.Mixin.create
  ##
  # Component.
  ##
  JsTreeComponent: Em.Component.extend  
    # Properties
    roots: Em.A()
    selected: Em.A()
    options: {}
    
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
      @$().jstree(@_opts())
      @_tree = @$().jstree(true)

      @$().on 'changed.jstree', (event, data) =>
        @_updateSelectedProperty(data.selected)

      @$().on 'select_node.jstree', (event, data) =>
        @_updateSelectedProperty(data.selected)

      @$().on 'rename_node.jstree', (obj, data) =>
        @_updateTitleProperty(data.node.original.model, data.text)
        
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

    _opts: ->
      $.extend true, @get('options'), 
        core:
          check_callback: true
          data: (_, cback) =>
            cback(@_serializeTree())
      
    _updateSelectedProperty: (selectedIds) ->
      selected = selectedIds.map (id) => @_tree.get_node(id).original.model
      @_ignoreSelectedProperty = true
      @set('selected', selected)
      @_ignoreSelectedProperty = false      

    _updateTitleProperty: (object, text) ->
      object.set('title', text)
      if object.get('editing')
        object.set('editing', false)
      
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
        node.addObserver('editing', this, '_nodeEditingDidChange')
        node.addObserver('disabled', this, '_nodeDisabledDidChange')
        node.addObserver('icon', this, '_nodeIconDidChange')
        node.addObserver('children.[]', this, 'refreshTree')  # We'll just refresh the whole tree
        
        @_attachNodes(node.get('children'))
    ).on 'init'

    
    ##
    # Update jstree according to the selection change.
    ##
    _selectedDidChange: (->
      if !@_ignoreSelectedProperty
        ids = (@get('selected') || []).map (model) -> model._attached['id']
        @_tree.deselect_all()
        @_tree.select_node(ids, true)
    ).observes 'selected'

    _nodeTitleDidChange: (sender) ->
      @_tree.set_text(sender._attached['id'], sender.get('title')) # rename_node = not working

    _nodeIconDidChange: (sender) ->
      @_tree.set_icon(sender._attached['id'], sender.get('icon'))
      
    _nodeEditingDidChange: (sender) ->
      if sender.get('editing')
        @_tree.edit(sender._attached['id'])
        
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
        opts = $.extend true, node._serialize(),
          id: node._attached['id']
          children: @_serializeTree(node.get('children'))
          icon: node.get('icon')
          state:
            selected: selectedNodes && selectedNodes.indexOf(node) != -1 # fixes selection flickering