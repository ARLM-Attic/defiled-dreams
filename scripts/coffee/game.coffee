class Game extends Phaser.Game

	MAX_LEVELS: 2

	constructor: () ->
		super 32*24, 32*20, Phaser.CANVAS, 'Defiled Dreams', null
		
		@state.add 'Boot', Boot, false
		@state.add 'Preloader', Preloader, false
		@state.add 'MainMenu', MainMenu, false

		@state.start 'Boot'

	saveData: (savePoint, mapName) ->
		localforage.setItem "savePoint-#{mapName}", {x: savePoint.x, y: savePoint.y, map: mapName}
		@player.savedX = savePoint.x
		@player.savedY = savePoint.y

	loadData: (mapName, callback) ->
		localforage.getItem "savePoint-#{mapName}", (coordinates) =>
			callback?(if coordinates then coordinates else {x: null, y: null, map: null} )
			@isLoaded = true
