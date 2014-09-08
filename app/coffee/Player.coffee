class Player extends Phaser.Sprite

  moveSpeed: 150
  jumpSpeed: 750
  climbSpeed: 150
  jumpTimer: 0

  constructor: (@game, x, y, img) ->
    super @game, x, y, img

    @cursors = @game.input.keyboard.createCursorKeys()

    @animations.add 'right', [14, 18, 22, 26], 10, yes
    @animations.add 'left', [15, 19, 23, 27], 10, yes

    @facing = ''
    @respawnKey = @game.input.keyboard.addKey Phaser.Keyboard.R

  update: ->
    #handle respawns
    respawnButtonIsDown = @respawnKey.isDown or
      @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_RIGHT_TRIGGER

    @respawn() if respawnButtonIsDown

    return if not @alive

    moveLeftButtonIsDown = @cursors.left.isDown

    moveRightButtonIsDown = @cursors.right.isDown

    jumpButtonIsDown = @cursors.up.isDown

    climbButtonIsDown = @cursors.up.isDown

    if moveLeftButtonIsDown
      @body.moveLeft @moveSpeed
      @changeFace 'left'

    else if moveRightButtonIsDown
      @body.moveRight @moveSpeed
      @changeFace 'right'

    else
      @body.velocity.x = 0

      if @facing isnt ''
        @animations.stop()

        @frame = 15 if @facing is 'left'
        @frame = 14 if @facing is 'right'

        @facing = ''

    if jumpButtonIsDown and @game.time.now > @jumpTimer && @canJump()
      @body.moveUp @jumpSpeed
      @jumpTimer = @game.time.now + 500

  changeFace: (face) ->
    return if @facing is face
    @facing = face
    @animations.play face

  canJump: ->
    return yes
    yAxis = p2.vec2.fromValues 0, 1
    result = no

    arr = @game.physics.p2.world.narrowphase.contactEquations

    for i in [0...arr.length]
      c = arr[i]

      if c.bodyA is @body.data or c.bodyB is @body.data
        d = p2.vec2.dot c.normalA, yAxis
        d*= -1 if c.bodyA is @body.data
        result = yes if d > 0.5

    result

window.Player = Player