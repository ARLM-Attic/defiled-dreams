class Player

    moveSpeed: 250
    jumpSpeed: 350
    climbSpeed: 150

    pendingCallbacks: {}

    constructor: (@game, @savedX, @savedY, name) ->
        @ref = @game.add.sprite @savedX, @savedY, name

        @ref.body.maxVelocity.x = 400

        @cursors = @game.input.keyboard.createCursorKeys()

        @ref.body.bounce.y = 0.01
        @ref.body.collideWorldBounds = true
        @ref.body.rebound = false

        @ref.animations.add 'right', [14, 18, 22, 26], 10, true
        @ref.animations.add 'left', [15, 19, 23, 27], 10, true
        @ref.animations.add 'death', [0,1,2,3,4,5,6,7,8,9], 20

        @respawnKey = @game.input.keyboard.addKey Phaser.Keyboard.R

        @game.camera.follow @ref

        @initControllers()

    initControllers: () ->
        @game.input.gamepad.start()

    update: () ->

        #handle respawns
        respawnButtonIsDown = @respawnKey.isDown or
                @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_RIGHT_TRIGGER

        @respawn() if respawnButtonIsDown

        return if not @ref.alive

        moveLeftButtonIsDown = @cursors.left.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_DPAD_LEFT

        moveRightButtonIsDown = @cursors.right.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_DPAD_RIGHT

        jumpButtonIsDown = @cursors.up.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_A

        climbButtonIsDown = @cursors.up.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_DPAD_UP

        isOnFloor = @ref.body.onFloor() or @ref.body.touching.down

        moveTolerance = @moveSpeed * (@game.time.elapsed / 1000)

        if (not moveLeftButtonIsDown) and 
           (not moveRightButtonIsDown)
            if -moveTolerance < @ref.body.velocity.x < moveTolerance
                @ref.body.velocity.x = 0
                @ref.body.acceleration.x = 0
            else
                delta = @ref.body.deltaX()
                @ref.body.acceleration.x = -@moveSpeed*delta

        #ladders
        if climbButtonIsDown and @canLadder
            @ref.body.allowGravity = false
            @ref.body.velocity.y = -@climbSpeed
            @ref.frame = 13

        else
            @ref.body.allowGravity = true

        #horizontal movement
        if moveLeftButtonIsDown
            @ref.body.acceleration.x = -@moveSpeed
            @ref.animations.play 'left'

        else if moveRightButtonIsDown
            @ref.body.acceleration.x = @moveSpeed
            @ref.animations.play 'right'

        else if not (@canLadder and climbButtonIsDown)
            @ref.animations.stop()
            @ref.frame = if @ref.body.velocity.y > 60 and not isOnFloor then 16 else 0

        #jump
        if jumpButtonIsDown and isOnFloor
            @ref.body.velocity.y = -@jumpSpeed

    die: (trap, pendingCallback) ->
        @pendingCallbacks[trap.x+","+trap.y] = pendingCallback
        return if not @ref.alive
        @ref.alive = false
        @ref.body.velocity.y = 0
        @ref.body.velocity.x = 0
        @ref.body.acceleration.x = 0
        @ref.body.acceleration.y = 0
        @ref.animations.play 'death'

    respawn: () ->
        return if @ref.alive
        @ref.x = @savedX
        @ref.y = @savedY

        @game.time.events.add 50, () =>
            @ref.alive = true
            @ref.frame = 0
            @pendingCallbacks[obj]?() for obj of @pendingCallbacks
            @pendingCallbacks = {}