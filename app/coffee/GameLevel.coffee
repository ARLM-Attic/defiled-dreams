
class Playing extends Phaser.State
  noises:
    spring: null
    death: null
    save: null
    bgm: null

  gids:
    PLATFORM_VERTICAL: 40
    PLATFORM_HORIZONTAL: 41

    LADDER: 32

    SAVE: 20

    BLOCK_FADE: 24
    SPRING_UP: 36

    SPIKE_HIDDEN: 33
    SPIKE_FLOOR: 31

    SLOPE_EQUILATERAL: 29

    SHOOTER_PEWPEW: 39
    SHOOTER_LASER: 38
    SHOOTER_ARROW: 37

    WARP: 43

  create: ->
    @loadMap()
    @startPhysics()

    @loadGroups()
    @loadPlayer()
    @loadPlatformLayer()

  update: ->

  startPhysics: ->
    @game.physics.startSystem Phaser.Physics.P2JS
    @game.physics.p2.gravity.y = 1000
    @game.physics.p2.restitution = 0.2

    @game.physics.p2.convertTilemap @map, @tileLayer

    @game.physics.p2.setBoundsToWorld yes, yes, yes, yes, no

    @game.physics.p2.setImpactEvents yes
    @game.world.enableBodySleeping = yes

    @game.playerMaterial = @game.physics.p2.createMaterial 'player'
    @game.platformMaterial = @game.physics.p2.createMaterial 'platform'

    @game.physics.p2.createContactMaterial @game.playerMaterial, @game.platformMaterial, {friction: 10, restitution: 0}

  loadGroups: ->
    @players = @game.add.group()

    @game.cg =
      player: @game.physics.p2.createCollisionGroup()
      platform: @game.physics.p2.createCollisionGroup()

  loadMap: ->
    @map = @game.add.tilemap "world-#{@levelNumber}"
    @map.addTilesetImage 'tiles', 'tiles'

    @map.setCollisionByExclusion [0]
    @game.stage.backgroundColor = '#aaaaaa'

    @tileLayer = @map.createLayer 'MainLayer'
    @tileLayer.resizeWorld()

  loadPlayer: ->
    @game.player = @player = new Player @game, 96, @game.world.height-96, 'player'
    @players.add @player
    @game.physics.p2.enable @player
    @player.body.fixedRotation = yes

    @player.body.setMaterial @game.playerMaterial
    @player.body.setCollisionGroup @game.cg.player
    @player.body.collides @game.cg.platform

    console.log @game.cg.player, @game.cg.platform
    console.log @player.body.data.shapes[0], @game.physics.p2.boundsCollisionGroup.mask

    @game.camera.follow @player

  loadPlatformLayer: ->
    @map.createFromObjects 'PlatformLayer', @gids.PLATFORM_HORIZONTAL, 'platforms', 1, true, false, undefined, HorizontalPlatform
    @map.createFromObjects 'PlatformLayer', @gids.PLATFORM_VERTICAL, 'platforms', 0, true, false, undefined, VerticalPlatform

class GameLevel extends Playing
  constructor: (@levelNumber) ->

  preload: ->
    @game.load.tilemap "world-#{@levelNumber}", "./assets/maps/world-#{@levelNumber}.json", null, Phaser.Tilemap.TILED_JSON

window.GameLevel = GameLevel