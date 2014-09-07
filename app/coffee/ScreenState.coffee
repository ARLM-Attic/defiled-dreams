class ScreenState extends Phaser.State

  loadTitleText: ->
    style = {font: "64px Arial", fill: "#fff"}
    @ddText = @game.add.text (@game.canvas.width/3.5), 30, "Defiled Dreams", style

window.ScreenState = ScreenState