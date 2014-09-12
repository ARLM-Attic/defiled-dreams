class FadingBlock extends GameObject
  constructor: (@game, x, y) ->
    super @game, x, y,'fading-block', 0
    @animations.add 'fade', [0,0,0,0,1,2,3,2,1,0,0,0,0], 4, true
    @animations.add 'fade_once', [0,0,1,2,3,2,1,0,0,0,0], 4

  initialize: ->
    return if not @auto
    delay = +@delay or 0
    @game.time.events.add delay, @disappear, @

  disappear: ->
    @animations.play 'fade' if @auto
    @animations.play 'fade_once' if not @auto

  collide: ->
    return if @auto
    @disappear()

  canCollide: ->
    console.log 'test'
    if @animations.currentFrame then @animations.currentFrame?.index is 0 else yes

window.FadingBlock = FadingBlock