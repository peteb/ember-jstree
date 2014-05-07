root = exports ? this

root.EmberJsTree = Em.Mixin.create
  JsTreeComponent: Em.Component.extend
  
    # Properties
    roots: []
    
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


    ##
    # Unregister observers etc.
    ##
    willDestroyElement: ->

      
    ##
    # Reloads the whole tree recursively.
    ##
    refreshTree: (->
      Em.run.once =>
        @_attachNodes()
        @_tree.refresh()
    ).observes 'roots.[]'


    ##
    # Registers observers and generates ids for new nodes
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
                      
        node.addObserver('title', this, '_updateNodeTitle')
        node.addObserver('children.[]', this, 'refreshTree')  # We'll just refresh the whole tree
        
        @_attachNodes(node.get('children'))
    ).on 'init'

    _updateNodeTitle: (sender) ->
      @_tree.set_text(sender._attached['id'], sender.get('title')) # rename_node = not working

    
    ##
    # Serializes the roots into jstree-friendly json.
    ##
    _serializeTree: ->
      @roots.map (root) -> root._serialize()
