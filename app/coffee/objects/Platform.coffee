class Platform extends GameObject
  constructor: (@game, x, y, key, frame) ->
    super @game, x, y, key, frame

    @body.setMaterial @game.mat.platform

    @setupMotion()

class HorizontalPlatform extends Platform
  setupMotion: ->
    @body.velocity.x = 50

    @game.time.events.loop Phaser.Timer.SECOND*5, (-> @body.velocity.x = @game.physics.p2.mpxi(@body.velocity.x*-1)), @
    #@game.add.tween @body.velocity
    # .to {x: '+100'}, 2000, Phaser.Easing.Linear.None
    # .to {x: '-100'}, 2000, Phaser.Easing.Linear.None
    # .yoyo()
    # .loop()
    # .start()

class VerticalPlatform extends Platform
  setupMotion: ->
    @body.velocity.y = 50

    @game.time.events.loop Phaser.Timer.SECOND*5, (-> @body.velocity.y = @game.physics.p2.mpxi(@body.velocity.y*-1)), @
    #@game.add.tween @body
    #.to {y: '+100'}, 2000, Phaser.Easing.Linear.None
    #.to {y: '-100'}, 2000, Phaser.Easing.Linear.None
    #.yoyo()
    #.loop()
    #.start()

window.HorizontalPlatform = HorizontalPlatform
window.VerticalPlatform = VerticalPlatform