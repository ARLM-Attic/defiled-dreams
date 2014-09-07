class Boot extends Phaser.State
  preload: () ->
    @load.image 'preloadBar', './assets/img/pregame/preloader_bar.png'

  create: () ->
    #device settings / changing them

    @game.state.start 'Preloader', true, false

window.Boot = Boot