
class Boot extends Phaser.State

    preload: () ->
        @load.image 'preloadBar', './assets/img/pregame/loader.png'

    create: () ->
        #device settings / changing them
        
        @game.state.start 'Preloader', true, false

