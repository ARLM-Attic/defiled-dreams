
class GameObject extends Phaser.Sprite
  constructor: (@game, x, y, key, frame) ->
    super @game, x, y, key, frame

    @game.physics.p2.enable @
    @body.kinematic = yes
    @body.setCollisionGroup @game.cg.objects
    @body.collides @game.cg.player

  initialize: ->

  collide: (player) ->

  canCollide: (player) -> yes

window.GameObject = GameObject