
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

  update: ->

  startPhysics: ->
    @game.physics.startSystem Phaser.Physics.P2JS
    @game.physics.p2.gravity.y = 500
    @game.physics.p2.restitution = 0.2;

    @game.physics.p2.convertTilemap @map, @tileLayer

  loadGroups: ->
    @players = @game.add.group()

  loadMap: ->
    @map = @game.add.tilemap "world-#{@levelNumber}"
    @map.addTilesetImage 'tiles', 'tiles'

    @map.setCollisionByExclusion [0]
    @game.stage.backgroundColor = '#aaaaaa'

    @tileLayer = @map.createLayer 'MainLayer'
    @tileLayer.resizeWorld()

  loadPlayer: ->
    @player = new Player @game, 96, 96, 'player'
    @players.add @player
    @game.physics.p2.enable @player
    @player.body.fixedRotation = yes
    @player.body.collideWorldBounds = yes

    @game.camera.follow @player

class GameLevel extends Playing
  constructor: (@levelNumber) ->

  preload: ->
    @game.load.tilemap "world-#{@levelNumber}", "./assets/maps/world-#{@levelNumber}.json", null, Phaser.Tilemap.TILED_JSON

window.GameLevel = GameLevel