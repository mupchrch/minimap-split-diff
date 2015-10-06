{CompositeDisposable} = require 'event-kit'

module.exports =
class MinimapSplitDiffBinding
  constructor: (@minimap) ->
    @editor = @minimap.getTextEditor()
    @subscriptions = new CompositeDisposable

    @subscriptions.add @editor.displayBuffer.onDidCreateMarker (marker) =>
      @handleCreatedMarker(marker)

  destroy: ->
    @subscriptions.dispose()
    @minimap = null
    @editor = null

  handleCreatedMarker: (marker) ->
    if marker.matchesProperties(class: 'split-diff-added')
      #scope: '.minimap .line.split-diff-added'
      @minimap.decorateMarker(marker, type: 'line', class: 'added')
    else if marker.matchesProperties(class: 'split-diff-removed')
      #scope: '.minimap .line.split-diff-removed'
      @minimap.decorateMarker(marker, type: 'line', class: 'removed')
