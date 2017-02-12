{CompositeDisposable} = require 'event-kit'

module.exports =
  active: false
  bindingsById: {}
  subscriptionsById: {}
  subscriptions: {}

  isActive: -> @active

  activate: (state) ->
    @subscriptions = new CompositeDisposable

  consumeMinimapServiceV1: (@minimap) ->
    @minimap.registerPlugin 'split-diff', this

  deactivate: ->
    @minimap.unregisterPlugin 'split-diff'
    @minimap = null

  activatePlugin: ->
    return if @active

    @active = true

    @subscriptions.add @minimap.observeMinimaps (minimap) =>
      MinimapSplitDiffBinding = require './minimap-split-diff-binding'

      binding = new MinimapSplitDiffBinding(minimap)
      @bindingsById[minimap.id] = binding

      @subscriptionsById[minimap.id] = minimap.onDidDestroy =>
        @subscriptionsById[minimap.id]?.dispose()
        @bindingsById[minimap.id]?.destroy()

        delete @bindingsById[minimap.id]
        delete @subscriptionsById[minimap.id]

  deactivatePlugin: ->
    return unless @active

    @active = false
    for i of @bindingsById
      @bindingsById[i].destroy()
    @subscriptions.dispose()
