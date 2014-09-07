
class MainMenu extends ScreenState

  preload: () ->
    @loadTitleText()

    #reset old data
    #@game.physics.gravity.y = 0
    @game.camera.follow null
    @buttons = []

    @load.spritesheet 'electric', './assets/img/game/electric.png', 32, 32

    @game.stage.backgroundColor = '#aaaaaa'

  create: () ->
    for i in [1..@game.MAX_LEVELS]
      @buttons.push new MenuTextButton @game, 140+(32*i-1)+(3*i-1), 140, "#{i}"

class MenuTextButton
  constructor: (@game, x, y, text) ->
    @button = @game.add.button x,y,'electric', (()->@game.state.start "world-#{text}"), @, 1,0,2
    @text = @game.add.text x+9, y, text, @style

window.MainMenu = MainMenu