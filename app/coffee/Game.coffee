class DefiledDreams extends Phaser.Game
  MAX_LEVELS: 2
  width: 32*28
  height: 32*16

  debugMode: yes

  constructor: ->
    super @width, @height, Phaser.AUTO, 'game'

window.DefiledDreams = DefiledDreams