game = new DefiledDreams()

game.state.add 'Boot', Boot
game.state.add 'Preloader', Preloader
game.state.add 'MainMenu', MainMenu
game.state.add 'Debug', (new GameLevel "test"), no
#game.state.add 'Play', PlayScene

game.state.start 'Boot'
