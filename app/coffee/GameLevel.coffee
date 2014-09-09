
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
    @loadGroups()
    @loadMap()
    @startPhysics()

    @loadPlayer()
    @loadPlatformLayer()

  update: ->

  startPhysics: ->
    @game.physics.startSystem Phaser.Physics.P2JS
    @loadCollisionGroups()

    @game.physics.p2.gravity.y = 3000
    @game.physics.p2.restitution = 0.2
    @game.physics.p2.friction = 0

    @game.physics.p2.setBoundsToWorld yes, yes, yes, yes, no

    @game.physics.p2.setImpactEvents yes

    @loadCollisionMaterials()

  loadGroups: ->
    @players = @game.add.group()

  loadCollisionMaterials: ->

    @game.mat =
      world:    @game.physics.p2.createMaterial 'world'
      floor:    @game.physics.p2.createMaterial 'floor'
      player:   @game.physics.p2.createMaterial 'player'
      platform: @game.physics.p2.createMaterial 'platform'

    @game.physics.p2.setWorldMaterial @game.mat.world, yes, yes, yes, yes

    @game.physics.p2.createContactMaterial @game.mat.player, @game.mat.world,
      restitution: 0.7

    @game.physics.p2.createContactMaterial @game.mat.player, @game.mat.platform,
      friction: 1
      restitution: 0

    @game.physics.p2.createContactMaterial @game.mat.player, @game.mat.floor,
      friction: 1
      restitution: 0.7

  loadCollisionGroups: ->
    @game.cg =
      player:     @game.physics.p2.createCollisionGroup()
      platform:   @game.physics.p2.createCollisionGroup()
      tiles:      @game.physics.p2.createCollisionGroup()

    @game.physics.p2.updateBoundsCollisionGroup()

    _.each (@game.physics.p2.convertTilemap @map, @tileLayer), (body) =>
      body.setCollisionGroup @game.cg.tiles
      body.collides @game.cg.player
      body.static = yes

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
    #@player.body.setCircle 16, 0, 0

    @player.body.setMaterial @game.mat.player
    @player.body.setCollisionGroup @game.cg.player
    @player.body.collides @game.cg.tiles
    @player.body.collides @game.cg.platform, (player, platform) -> console.log "test"

    @game.camera.follow @player

  loadPlatformLayer: ->
    @map.createFromObjects 'PlatformLayer', @gids.PLATFORM_HORIZONTAL, 'platforms', 1, true, false, undefined, HorizontalPlatform
    @map.createFromObjects 'PlatformLayer', @gids.PLATFORM_VERTICAL, 'platforms', 0, true, false, undefined, VerticalPlatform

class GameLevel extends Playing
  constructor: (@levelNumber) ->

  preload: ->
    @game.load.tilemap "world-#{@levelNumber}", "./assets/maps/world-#{@levelNumber}.json", null, Phaser.Tilemap.TILED_JSON

window.GameLevel = GameLevel