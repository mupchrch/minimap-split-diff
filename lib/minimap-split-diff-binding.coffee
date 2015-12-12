{CompositeDisposable} = require 'event-kit'

module.exports =
class MinimapSplitDiffBinding
  constructor: (@minimap) ->
    @editor = @minimap.getTextEditor()
    @splitDecorations = []
    @subscriptions = new CompositeDisposable

    # we will not use this binding if there was no editor associated
    if @editor
      @editor.findMarkers({class: 'split-diff-added'}).forEach (marker1) =>
        @handleMarker(marker1)
      @editor.findMarkers({class: 'split-diff-removed'}).forEach (marker2) =>
        @handleMarker(marker2)

      @subscriptions.add @editor.displayBuffer.onDidCreateMarker (marker) =>
        @handleMarker(marker)

  destroy: ->
    @removeMarkers()
    @splitDecorations = null
    @subscriptions.dispose()
    @minimap = null
    @editor = null

  removeMarkers: ->
    if @splitDecorations
      for decoration in @splitDecorations
        decoration.destroy()

  handleMarker: (marker) ->
    #this would take the line color from the theme:
    # scope: '.minimap .line.split-diff-added'
    if marker.matchesProperties(class: 'split-diff-added')
      @createDecoration(marker, 'added')
    else if marker.matchesProperties(class: 'split-diff-removed')
      @createDecoration(marker, 'removed')
    else if marker.matchesProperties(class: 'split-diff-selected')
      @createDecoration(marker, 'selected')

  createDecoration: (marker, decorationClass) ->
    minimapDecoration = @minimap.decorateMarker(marker, type: 'line', class: decorationClass)
    @splitDecorations.push minimapDecoration
