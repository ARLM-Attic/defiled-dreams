(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ArcCannon, Arrow, ArrowCannon, Boot, Bullet, FadingBlock, Game, GameLevel, GameObject, HiddenSpike, HorizontalPlatform, Ladder, Laser, LaserCannon, MainMenu, MenuTextButton, Platform, Player, Playing, Preloader, Projectile, SavePoint, Shooter, Slope, SpikeFloor, Spring, Trap, VerticalPlatform, Warp, game,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Boot = (function(_super) {
  __extends(Boot, _super);

  function Boot() {
    return Boot.__super__.constructor.apply(this, arguments);
  }

  Boot.prototype.preload = function() {
    return this.load.image('preloadBar', './assets/img/pregame/loader.png');
  };

  Boot.prototype.create = function() {
    return this.game.state.start('Preloader', true, false);
  };

  return Boot;

})(Phaser.State);

Game = (function(_super) {
  __extends(Game, _super);

  Game.prototype.MAX_LEVELS = 2;

  function Game() {
    Game.__super__.constructor.call(this, 32 * 24, 32 * 20, Phaser.CANVAS, 'Defiled Dreams', null);
    this.state.add('Boot', Boot, false);
    this.state.add('Preloader', Preloader, false);
    this.state.add('MainMenu', MainMenu, false);
    this.state.start('Boot');
  }

  Game.prototype.saveData = function(savePoint, mapName) {
    localforage.setItem("savePoint-" + mapName, {
      x: savePoint.x,
      y: savePoint.y,
      map: mapName
    });
    this.player.savedX = savePoint.x;
    return this.player.savedY = savePoint.y;
  };

  Game.prototype.loadData = function(mapName, callback) {
    return localforage.getItem("savePoint-" + mapName, (function(_this) {
      return function(coordinates) {
        if (typeof callback === "function") {
          callback(coordinates ? coordinates : {
            x: null,
            y: null,
            map: null
          });
        }
        return _this.isLoaded = true;
      };
    })(this));
  };

  return Game;

})(Phaser.Game);

GameObject = (function(_super) {
  __extends(GameObject, _super);

  function GameObject(game, x, y, key, frame) {
    GameObject.__super__.constructor.call(this, game, x, y, key, frame);
  }

  GameObject.prototype.rotateObj = function(angle) {
    this.angle = angle;
    if (angle > 0) {
      this.y -= 32;
    }
    if (angle < 0 || angle === 180) {
      this.x += 32;
    }
    this.body.polygon.translate(0, -this.height);
    this.body.polygon.rotate(angle * Math.PI / 180);
    return this.body.polygon.translate(0, this.height);
  };

  GameObject.prototype.isReady = function() {
    if (!('rotate' in this)) {
      return;
    }
    return this.rotateObj(+this.rotate);
  };

  return GameObject;

})(Phaser.Sprite);

Slope = (function(_super) {
  __extends(Slope, _super);

  function Slope(game, x, y) {
    Slope.__super__.constructor.call(this, game, x, y, 'slopes', 4);
    this.body.moves = false;
    this.body.setPolygon(0, 32, 32, 32, 32, 0);
  }

  return Slope;

})(GameObject);

Ladder = (function(_super) {
  __extends(Ladder, _super);

  function Ladder(game, x, y) {
    Ladder.__super__.constructor.call(this, game, x, y, 'environment_16', 1);
    this.body.moves = false;
    this.angle = 90;
    this.x += 8;
    this.y -= 32;
    this.body.setRectangle(16, 32, 0, 0);
  }

  return Ladder;

})(GameObject);

SavePoint = (function(_super) {
  __extends(SavePoint, _super);

  function SavePoint(game, x, y) {
    SavePoint.__super__.constructor.call(this, game, x, y, 'save', 0);
    this.body.moves = false;
    this.body.setCircle(10);
    this.animations.add('ping', [3, 2, 1, 2, 3, 1, 2, 3, 2, 1, 3, 1, 2, 3, 1, 0], 10, false);
    this.frame = 0;
  }

  return SavePoint;

})(GameObject);

Warp = (function(_super) {
  __extends(Warp, _super);

  function Warp(game, x, y) {
    Warp.__super__.constructor.call(this, game, x, y, 'warp', 0);
    this.body.moves = false;
    this.animations.add('warp', [0, 1, 2, 3, 4], 10, true);
    this.animations.play('warp');
  }

  Warp.prototype.isReady = function() {
    this.offX = +this.offX || 0;
    return this.offY = +this.offY || 0;
  };

  return Warp;

})(GameObject);

MainMenu = (function(_super) {
  __extends(MainMenu, _super);

  function MainMenu() {
    return MainMenu.__super__.constructor.apply(this, arguments);
  }

  MainMenu.prototype.preload = function() {
    this.game.physics.gravity.y = 0;
    this.game.camera.follow(null);
    this.buttons = [];
    this.load.spritesheet('electric', './assets/img/game/electric.png', 32, 32);
    this.style = {
      font: "32px Arial",
      fill: "#fff",
      align: "center"
    };
    this.headText = this.game.add.text((this.game.canvas.width / 2) - 130, 0, "Defiled Dreams", this.style);
    return this.game.stage.backgroundColor = '#aaaaaa';
  };

  MainMenu.prototype.create = function() {
    var i, _i, _ref, _results;
    _results = [];
    for (i = _i = 1, _ref = this.game.MAX_LEVELS; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      _results.push(this.buttons.push(new MenuTextButton(this.game, 140 + (32 * i - 1) + (3 * i - 1), 140, "" + i)));
    }
    return _results;
  };

  return MainMenu;

})(Phaser.State);

MenuTextButton = (function() {
  function MenuTextButton(game, x, y, text) {
    this.game = game;
    this.button = this.game.add.button(x, y, 'electric', (function() {
      return this.game.state.start("world-" + text);
    }), this, 1, 0, 2);
    this.text = this.game.add.text(x + 8, y, text, this.style);
  }

  return MenuTextButton;

})();

Platform = (function(_super) {
  __extends(Platform, _super);

  function Platform(game, x, y, key, frame) {
    Platform.__super__.constructor.call(this, game, x, y, key, frame);
    this.body.allowGravity = false;
    this.body.immovable = true;
  }

  Platform.prototype.isReady = function() {
    var opposite;
    this.moveMod = +this.moveMod || 0;
    this.delay = +this.delay || 0;
    this.calcDist = Math.abs(this.moveMod);
    opposite = String.fromCharCode(!(this.platType.charCodeAt() - 120) + 120);
    if (this.moveMod !== 0) {
      return this.game.time.events.loop(1, function() {
        var cur, type;
        type = this.platType;
        this[opposite] = this.base;
        this.body.velocity[opposite] = 0;
        this.basePos = this.basePos || Math.floor(this[type] / 32);
        this.destPos = this.destPos || this.basePos + this.calcDist;
        this.prevPos = this.prevPos || this.basePos;
        cur = Math.floor(this[type] / 32);
        this.body.velocity[type] = (this.destPos - cur < 0 ? -100 : 100);
        if (cur === this.destPos && this.prevPos !== this.destPos) {
          this.destPos = this.prevPos - cur > 0 ? this.basePos + this.calcDist : this.basePos - this.calcDist;
        }
        return this.prevPos = cur;
      }, this);
    }
  };

  return Platform;

})(Phaser.Sprite);

HorizontalPlatform = (function(_super) {
  __extends(HorizontalPlatform, _super);

  function HorizontalPlatform(game, x, y) {
    this.platType = 'x';
    this.base = y;
    HorizontalPlatform.__super__.constructor.call(this, game, x, y, 'platforms', 1);
  }

  return HorizontalPlatform;

})(Platform);

VerticalPlatform = (function(_super) {
  __extends(VerticalPlatform, _super);

  function VerticalPlatform(game, x, y) {
    this.platType = 'y';
    this.base = x;
    VerticalPlatform.__super__.constructor.call(this, game, x, y, 'platforms', 0);
  }

  return VerticalPlatform;

})(Platform);

Player = (function() {
  Player.prototype.moveSpeed = 250;

  Player.prototype.jumpSpeed = 350;

  Player.prototype.climbSpeed = 150;

  Player.prototype.pendingCallbacks = {};

  function Player(game, savedX, savedY, name) {
    this.game = game;
    this.savedX = savedX;
    this.savedY = savedY;
    this.ref = this.game.add.sprite(this.savedX, this.savedY, name);
    this.ref.body.maxVelocity.x = 400;
    this.cursors = this.game.input.keyboard.createCursorKeys();
    this.ref.body.bounce.y = 0.01;
    this.ref.body.collideWorldBounds = true;
    this.ref.body.rebound = false;
    this.ref.animations.add('right', [14, 18, 22, 26], 10, true);
    this.ref.animations.add('left', [15, 19, 23, 27], 10, true);
    this.ref.animations.add('death', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 20);
    this.respawnKey = this.game.input.keyboard.addKey(Phaser.Keyboard.R);
    this.game.camera.follow(this.ref);
    this.initControllers();
  }

  Player.prototype.initControllers = function() {
    return this.game.input.gamepad.start();
  };

  Player.prototype.update = function() {
    var climbButtonIsDown, delta, isOnFloor, jumpButtonIsDown, moveLeftButtonIsDown, moveRightButtonIsDown, moveTolerance, respawnButtonIsDown, _ref;
    respawnButtonIsDown = this.respawnKey.isDown || this.game.input.gamepad.isDown(Phaser.Gamepad.XBOX360_RIGHT_TRIGGER);
    if (respawnButtonIsDown) {
      this.respawn();
    }
    if (!this.ref.alive) {
      return;
    }
    moveLeftButtonIsDown = this.cursors.left.isDown || this.game.input.gamepad.isDown(Phaser.Gamepad.XBOX360_DPAD_LEFT);
    moveRightButtonIsDown = this.cursors.right.isDown || this.game.input.gamepad.isDown(Phaser.Gamepad.XBOX360_DPAD_RIGHT);
    jumpButtonIsDown = this.cursors.up.isDown || this.game.input.gamepad.isDown(Phaser.Gamepad.XBOX360_A);
    climbButtonIsDown = this.cursors.up.isDown || this.game.input.gamepad.isDown(Phaser.Gamepad.XBOX360_DPAD_UP);
    isOnFloor = this.ref.body.onFloor() || this.ref.body.touching.down;
    moveTolerance = this.moveSpeed * (this.game.time.elapsed / 1000);
    if ((!moveLeftButtonIsDown) && (!moveRightButtonIsDown)) {
      if ((-moveTolerance < (_ref = this.ref.body.velocity.x) && _ref < moveTolerance)) {
        this.ref.body.velocity.x = 0;
        this.ref.body.acceleration.x = 0;
      } else {
        delta = this.ref.body.deltaX();
        this.ref.body.acceleration.x = -this.moveSpeed * delta;
      }
    }
    if (climbButtonIsDown && this.canLadder) {
      this.ref.body.allowGravity = false;
      this.ref.body.velocity.y = -this.climbSpeed;
      this.ref.frame = 13;
    } else {
      this.ref.body.allowGravity = true;
    }
    if (moveLeftButtonIsDown) {
      this.ref.body.acceleration.x = -this.moveSpeed;
      this.ref.animations.play('left');
    } else if (moveRightButtonIsDown) {
      this.ref.body.acceleration.x = this.moveSpeed;
      this.ref.animations.play('right');
    } else if (!(this.canLadder && climbButtonIsDown)) {
      this.ref.animations.stop();
      this.ref.frame = this.ref.body.velocity.y > 60 && !isOnFloor ? 16 : 0;
    }
    if (jumpButtonIsDown && isOnFloor) {
      return this.ref.body.velocity.y = -this.jumpSpeed;
    }
  };

  Player.prototype.die = function(trap, pendingCallback) {
    this.pendingCallbacks[trap.x + "," + trap.y] = pendingCallback;
    if (!this.ref.alive) {
      return;
    }
    this.ref.alive = false;
    this.ref.body.velocity.y = 0;
    this.ref.body.velocity.x = 0;
    this.ref.body.acceleration.x = 0;
    this.ref.body.acceleration.y = 0;
    return this.ref.animations.play('death');
  };

  Player.prototype.respawn = function() {
    if (this.ref.alive) {
      return;
    }
    this.ref.x = this.savedX;
    this.ref.y = this.savedY;
    return this.game.time.events.add(50, (function(_this) {
      return function() {
        var obj, _base;
        _this.ref.alive = true;
        _this.ref.frame = 0;
        for (obj in _this.pendingCallbacks) {
          if (typeof (_base = _this.pendingCallbacks)[obj] === "function") {
            _base[obj]();
          }
        }
        return _this.pendingCallbacks = {};
      };
    })(this));
  };

  return Player;

})();

Playing = (function(_super) {
  __extends(Playing, _super);

  function Playing() {
    return Playing.__super__.constructor.apply(this, arguments);
  }

  Playing.prototype.noises = {
    spring: null,
    death: null,
    save: null,
    bgm: null
  };

  Playing.prototype.gids = {
    PLATFORM_VERTICAL: 40,
    PLATFORM_HORIZONTAL: 41,
    LADDER: 32,
    SAVE: 20,
    BLOCK_FADE: 24,
    SPRING_UP: 36,
    SPIKE_HIDDEN: 33,
    SPIKE_FLOOR: 31,
    SLOPE_EQUILATERAL: 29,
    SHOOTER_PEWPEW: 39,
    SHOOTER_LASER: 38,
    SHOOTER_ARROW: 37,
    WARP: 43
  };

  Playing.prototype.create = function() {
    this.setupGroups();
    this.setupGameSettings();
    this.loadSounds();
    this.loadMapData();
    this.loadPlatforms();
    this.loadTraps();
    this.loadSlopes();
    this.loadShooters();
    this.loadSaves();
    this.loadWarps();
    this.loadPlayer();
    this.setupText();
    return this.postLoad();
  };

  Playing.prototype.setupGroups = function() {
    this.fadingBlocks = this.game.add.group();
    this.ladders = this.game.add.group();
    this.hiddenSpikeTraps = this.game.add.group();
    this.normalSpikeTraps = this.game.add.group();
    this.horizPlatforms = this.game.add.group();
    this.vertPlatforms = this.game.add.group();
    this.springs = this.game.add.group();
    this.platforms = this.game.add.group();
    this.platforms.add(this.horizPlatforms);
    this.platforms.add(this.vertPlatforms);
    this.slopes = this.game.add.group();
    this.lasers = this.game.add.group();
    this.arrows = this.game.add.group();
    this.arcs = this.game.add.group();
    this.shooters = this.game.add.group();
    this.shooters.add(this.lasers);
    this.shooters.add(this.arrows);
    this.shooters.add(this.arcs);
    return Playing.prototype.bullets = this.game.add.group();
  };

  Playing.prototype.setupText = function() {
    var style;
    this.text = this.game.add.group();
    style = {
      font: "32px Arial",
      fill: "#000",
      align: "left"
    };
    this.respawnText = this.game.add.text(0, 0, "press r to respawn", style, this.text);
    this.respawnText.fixedToCamera = true;
    this.respawnText.alpha = 0.3;
    this.respawnText.cameraOffset = new Phaser.Point(10, 10);
    this.respawnText.renderable = false;
    this.saveText = this.game.add.text(0, 0, "saving...", style, this.text);
    this.saveText.fixedToCamera = true;
    this.saveText.alpha = 0.3;
    this.saveText.cameraOffset = new Phaser.Point(10, 10);
    this.saveText.renderable = false;
    this.game.add.tween(this.respawnText).to({
      alpha: 1
    }, 1000, Phaser.Easing.Circular.InOut, true, 0, 1000, true);
    return this.game.add.tween(this.saveText).to({
      alpha: 1
    }, 1000, Phaser.Easing.Circular.InOut, true, 0, 1000, true);
  };

  Playing.prototype.loadSounds = function() {
    this.noises.spring = game.add.audio('spring', 1, false);
    this.noises.death = game.add.audio('death', 1, false);
    this.noises.save = game.add.audio('save', 1, false);
    return this.noises.bgm = game.add.audio('bgm', 0.5, true);
  };

  Playing.prototype.setupGameSettings = function() {
    this.game.stage.backgroundColor = '#aaaaaa';
    return this.game.physics.gravity.y = 730;
  };

  Playing.prototype.injectMapFunctionality = function(map) {
    return map.createFromObjects = function(name, gid, key, frame, exists, autoCull, group, ctor) {
      var i, len, property, sprite, _results;
      if (exists == null) {
        exists = true;
      }
      if (autoCull == null) {
        autoCull = true;
      }
      if (group == null) {
        group = this.game.world;
      }
      if (ctor == null) {
        ctor = Phaser.Sprite;
      }
      if (!this.objects[name]) {
        console.warn("Tilemap.createFromObjects: invalid objectgroup name given: " + name);
        return;
      }
      i = 0;
      len = this.objects[name].length;
      _results = [];
      while (i < len) {
        if (this.objects[name][i].gid === gid) {
          sprite = new ctor(this.game, this.objects[name][i].x, this.objects[name][i].y, key, frame);
          sprite.exists = exists;
          sprite.anchor.setTo(0, 1);
          sprite.name = this.objects[name][i].name;
          sprite.visible = this.objects[name][i].visible;
          sprite.autoCull = autoCull;
          group.add(sprite);
          for (property in this.objects[name][i].properties) {
            group.set(sprite, property, this.objects[name][i].properties[property], false, false, 0);
          }
          if ('isReady' in sprite && typeof sprite.isReady === 'function') {
            sprite.isReady();
          }
        }
        _results.push(i++);
      }
      return _results;
    };
  };

  Playing.prototype.loadMapData = function() {
    this.map = this.game.add.tilemap("world-" + this.levelNumber);
    this.map.addTilesetImage('tiles', 'tiles');
    this.injectMapFunctionality(this.map);
    this.tileLayer = this.map.createLayer('MainLayer');
    return this.tileLayer.resizeWorld();
  };

  Playing.prototype.loadPlatforms = function() {
    this.map.createFromObjects('PlatformLayer', this.gids.LADDER, 'environment_16', 1, true, false, this.ladders, Ladder);
    this.map.createFromObjects('PlatformLayer', this.gids.PLATFORM_HORIZONTAL, 'platforms', 2, true, false, this.horizPlatforms, HorizontalPlatform);
    return this.map.createFromObjects('PlatformLayer', this.gids.PLATFORM_VERTICAL, 'platforms', 1, true, false, this.vertPlatforms, VerticalPlatform);
  };

  Playing.prototype.loadTraps = function() {
    this.map.createFromObjects('TrapLayer', this.gids.BLOCK_FADE, 'fading-block', 0, true, false, this.fadingBlocks, FadingBlock);
    this.map.createFromObjects('TrapLayer', this.gids.SPRING_UP, 'environment_8', 2, true, false, this.springs, Spring);
    this.map.createFromObjects('TrapLayer', this.gids.SPIKE_HIDDEN, 'environment_8', 1, true, false, this.hiddenSpikeTraps, HiddenSpike);
    return this.map.createFromObjects('TrapLayer', this.gids.SPIKE_FLOOR, 'environment_16', 0, true, false, this.normalSpikeTraps, SpikeFloor);
  };

  Playing.prototype.loadSlopes = function() {
    return this.map.createFromObjects('SlopeLayer', this.gids.SLOPE_EQUILATERAL, 'slopes', 4, true, false, this.slopes, Slope);
  };

  Playing.prototype.loadShooters = function() {
    this.map.createFromObjects('TrapLayer', this.gids.SHOOTER_ARROW, 'shooters', 0, true, false, this.arrows, ArrowCannon);
    this.map.createFromObjects('TrapLayer', this.gids.SHOOTER_LASER, 'shooters', 1, true, false, this.lasers, LaserCannon);
    return this.map.createFromObjects('TrapLayer', this.gids.SHOOTER_PEWPEW, 'shooters', 2, true, false, this.lasers, ArcCannon);
  };

  Playing.prototype.loadSaves = function() {
    this.saves = this.game.add.group();
    return this.map.createFromObjects('SaveLayer', this.gids.SAVE, 'save', 0, true, false, this.saves, SavePoint);
  };

  Playing.prototype.loadWarps = function() {
    this.warps = this.game.add.group();
    return this.map.createFromObjects('TrapLayer', this.gids.WARP, 'warp', 0, true, false, this.warps, Warp);
  };

  Playing.prototype.postLoad = function() {
    return this.map.setCollisionByExclusion([0]);
  };

  Playing.prototype.loadPlayer = function() {
    this.players = this.game.add.group();
    return this.game.loadData(this.map.key, (function(_this) {
      return function(coordinates) {
        if (_this.map.key !== coordinates.map) {
          coordinates.x = 96;
          coordinates.y = _this.map.heightInPixels - 96;
        }
        if (coordinates.x === null || coordinates.y === null) {
          if (coordinates.x == null) {
            coordinates.x = 96;
          }
          if (coordinates.y == null) {
            coordinates.y = _this.map.heightInPixels - 96;
          }
        }
        _this.game.player = new Player(_this.game, coordinates.x, coordinates.y, 'player');
        return _this.players.add(_this.game.player.ref);
      };
    })(this));
  };

  Playing.prototype.update = function() {
    var oldVelX, oldVelY, restoreVelocity, _ref, _ref1;
    if (!this.game.isLoaded) {
      return;
    }
    this.respawnText.renderable = !this.game.player.ref.alive;
    _ref = [this.game.player.ref.body.velocity.x, this.game.player.ref.body.velocity.y], oldVelX = _ref[0], oldVelY = _ref[1];
    restoreVelocity = false;
    this.game.physics.collide(this.game.player.ref, this.tileLayer);
    this.game.physics.collide(this.game.player.ref, this.slopes);
    this.game.physics.collide(this.bullets, this.tileLayer, (function(_this) {
      return function(bullet) {
        return bullet.kill();
      };
    })(this));
    this.game.physics.collide(this.game.player.ref, this.bullets, (function(_this) {
      return function(player, bullet) {
        _this.killPlayer(bullet);
        return bullet.kill();
      };
    })(this), (function(_this) {
      return function(player, bullet) {
        return player.alive;
      };
    })(this));
    this.game.physics.collide(this.game.player.ref, this.fadingBlocks, (function(_this) {
      return function(ref, block) {
        if (ref.body.touching.down) {
          return _this.game.player.onBlock = true;
        } else {
          return restoreVelocity = true;
        }
      };
    })(this), (function(_this) {
      return function(ref, block) {
        if (!('auto' in block)) {
          block.animations.play('fade_once');
        }
        return block.currentFrame.index === 0;
      };
    })(this));
    this.game.physics.collide(this.game.player.ref, this.platforms, (function(_this) {
      return function(player, platform) {
        if (player.body.touching.down) {
          _this.game.player.onPlatform = true;
          player.x += platform.body.deltaX();
          return player.y += platform.body.deltaY();
        } else {
          return restoreVelocity = true;
        }
      };
    })(this));
    this.game.physics.overlap(this.game.player.ref, this.hiddenSpikeTraps, (function(_this) {
      return function(player, trap) {
        trap.frame = 0;
        return _this.killPlayer(trap, function() {
          return trap.frame = 1;
        });
      };
    })(this), (function(_this) {
      return function(player, trap) {
        return player.alive;
      };
    })(this));
    this.game.physics.collide(this.game.player.ref, this.normalSpikeTraps, (function(_this) {
      return function(player, trap) {
        return _this.killPlayer(trap);
      };
    })(this), (function(_this) {
      return function(player, trap) {
        return player.alive;
      };
    })(this));
    this.game.physics.overlap(this.game.player.ref, this.springs, (function(_this) {
      return function(player, spring) {
        spring.animations.play('spring');
        _this.noises.spring.play('', 0, 0.5);
        return _this.game.player.ref.body.velocity.add(spring.forceX, spring.forceY);
      };
    })(this), (function(_this) {
      return function(player, spring) {
        return player.alive;
      };
    })(this));
    this.game.physics.overlap(this.game.player.ref, this.saves, (function(_this) {
      return function(player, save) {
        if (!_this.game.player.ref.alive) {
          return;
        }
        if (save.animRef && save.animRef.isPlaying) {
          return;
        }
        return _this.savePlayer(save);
      };
    })(this));
    this.game.physics.overlap(this.game.player.ref, this.ladders, (function(_this) {
      return function(player, ladder) {
        return _this.game.player.canLadder = true;
      };
    })(this));
    if (restoreVelocity) {
      _ref1 = [oldVelX, oldVelY], this.game.player.ref.body.velocity.x = _ref1[0], this.game.player.ref.body.velocity.y = _ref1[1];
    }
    this.game.player.update();
    this.game.physics.overlap(this.game.player.ref, this.warps, (function(_this) {
      return function(player, warp) {
        if (warp.offX === 0 && warp.offY === 0) {
          return _this.finishLevel();
        } else {
          _this.game.player.ref.x = warp.x + warp.offX;
          return _this.game.player.ref.y = warp.y + warp.offY;
        }
      };
    })(this));
    this.game.player.canLadder = false;
    this.game.player.onPlatform = false;
    return this.game.player.onBlock = false;
  };

  Playing.prototype.showSaveText = function() {
    this.saveText.renderable = true;
    return this.game.time.events.add(2000, (function(_this) {
      return function() {
        return _this.saveText.renderable = false;
      };
    })(this));
  };

  Playing.prototype.savePlayer = function(save) {
    save.animRef = save.animations.play('ping');
    this.game.saveData(save, this.map.key);
    this.noises.save.play('', 0, 0.5);
    return this.showSaveText();
  };

  Playing.prototype.killPlayer = function(trap, callback) {
    if (this.game.player.ref.alive) {
      this.noises.death.play('', 0, 0.5);
    }
    return this.game.player.die(trap, callback);
  };

  Playing.prototype.finishLevel = function() {
    return this.game.state.start('MainMenu');
  };

  return Playing;

})(Phaser.State);

GameLevel = (function(_super) {
  __extends(GameLevel, _super);

  function GameLevel(levelNumber) {
    this.levelNumber = levelNumber;
  }

  GameLevel.prototype.preload = function() {
    return this.game.load.tilemap("world-" + this.levelNumber, "./assets/maps/world-" + this.levelNumber + ".json", null, Phaser.Tilemap.TILED_JSON);
  };

  return GameLevel;

})(Playing);

Preloader = (function(_super) {
  __extends(Preloader, _super);

  function Preloader() {
    return Preloader.__super__.constructor.apply(this, arguments);
  }

  Preloader.prototype.preload = function() {
    var i, style, _i, _ref, _results;
    this.preloadBar = this.add.sprite(175, 250, 'preloadBar');
    this.load.setPreloadSprite(this.preloadBar);
    style = {
      font: "32px Arial",
      fill: "#fff",
      align: "left"
    };
    this.loadText = this.game.add.text((this.game.canvas.width / 2) - 50, this.game.canvas.height / 2, "loading...", style);
    this.load.spritesheet('save', './assets/img/game/save.png', 32, 32);
    this.load.spritesheet('player', './assets/img/game/player.png', 32, 32);
    this.load.spritesheet('warp', './assets/img/game/warp.png', 32, 32);
    this.load.spritesheet('slopes', './assets/img/game/tiles/slopes.png', 32, 32);
    this.load.spritesheet('bullets', './assets/img/game/bullets.png', 16, 8);
    this.load.spritesheet('shooters', './assets/img/game/shooters.png', 32, 8);
    this.load.spritesheet('platforms', './assets/img/game/tiles/platforms.png', 32, 16);
    this.load.spritesheet('environment_8', './assets/img/game/tiles/environment_8.png', 32, 8);
    this.load.spritesheet('environment_16', './assets/img/game/tiles/environment_16.png', 32, 16);
    this.load.spritesheet('environment_32', './assets/img/game/tiles/environment_32.png', 32, 32);
    this.load.spritesheet('fading-block', './assets/img/game/tiles/fading-block.png', 32, 32);
    this.load.image('tiles', './assets/img/game/tiles/tiles.png');
    this.load.audio('bgm', ['./assets/sfx/bg.wav']);
    this.load.audio('save', ['./assets/sfx/save.wav']);
    this.load.audio('death', ['./assets/sfx/death.wav']);
    this.load.audio('spring', ['./assets/sfx/spring.wav']);
    _results = [];
    for (i = _i = 1, _ref = this.game.MAX_LEVELS; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      _results.push(this.game.state.add("world-" + i, new GameLevel(i, false)));
    }
    return _results;
  };

  Preloader.prototype.create = function() {
    return this.startMainMenu();
  };

  Preloader.prototype.update = function() {
    return this.loadText.content = this.load.progress + "%";
  };

  Preloader.prototype.startMainMenu = function() {
    return this.game.state.start('MainMenu');
  };

  return Preloader;

})(Phaser.State);

Projectile = (function(_super) {
  __extends(Projectile, _super);

  function Projectile(game, x, y, key, frame, velX, velY) {
    Projectile.__super__.constructor.call(this, game, x, y, key, frame);
    this.outOfBoundsKill = true;
    this.body.velocity = new Phaser.Point(velX, velY);
  }

  Projectile.prototype.rotateProj = function(angle) {
    this.angle = angle;
    if (angle !== 0 && angle !== 180) {
      this.body.polygon.translate(0, -this.height);
      this.body.polygon.rotate((angle - 180) * Math.PI / 180);
      return this.body.polygon.translate(0, this.height);
    }
  };

  return Projectile;

})(Phaser.Sprite);

Arrow = (function(_super) {
  __extends(Arrow, _super);

  function Arrow(game, x, y, velX, velY) {
    Arrow.__super__.constructor.call(this, game, x, y, 'bullets', 5, velX, velY);
    this.body.linearDamping = 0.1;
  }

  return Arrow;

})(Projectile);

Laser = (function(_super) {
  __extends(Laser, _super);

  function Laser(game, x, y, velX, velY) {
    Laser.__super__.constructor.call(this, game, x, y, 'bullets', 4, velX, velY);
    this.body.allowGravity = false;
  }

  return Laser;

})(Projectile);

Bullet = (function(_super) {
  __extends(Bullet, _super);

  function Bullet(game, x, y, velX, velY) {
    Bullet.__super__.constructor.call(this, game, x, y, 'bullets', 3, velX, velY);
    this.body.allowGravity = false;
  }

  return Bullet;

})(Projectile);

Shooter = (function(_super) {
  __extends(Shooter, _super);

  Shooter.prototype.projectileMap = {
    "Arrow": Arrow,
    "Laser": Laser,
    "Bullet": Bullet
  };

  function Shooter(game, x, y, key, frame) {
    Shooter.__super__.constructor.call(this, game, x, y, key, frame);
    this.body.moves = false;
    this.projectile = "Arrow";
    this.projAngle = 0;
  }

  Shooter.prototype.recalculate = function() {};

  Shooter.prototype.isReady = function() {
    var projectileClass;
    this.delay = +this.delay || 2000;
    this.projOffX = +this.projOffX || 0;
    this.projOffY = +this.projOffY || 0;
    this.projVelX = +this.projVelX || 0;
    this.projVelY = +this.projVelY || 0;
    this.minProjAngle = +this.minProjAngle || 0;
    this.maxProjAngle = +this.maxProjAngle || 0;
    this.projAngle = +this.projAngle || 0;
    this.force = +this.force || 200;
    this.rotate = +this.rotate || 0;
    this.setBaseVariables();
    projectileClass = Shooter.prototype.projectileMap[this.projectile];
    this.game.time.events.loop(this.delay, function() {
      var bullet;
      bullet = new projectileClass(this.game, this.x + this.projOffX, this.y + this.projOffY, this.projVelX, this.projVelY);
      Playing.prototype.bullets.add(bullet);
      bullet.rotateProj(this.projAngle);
      return this.recalculate(bullet);
    }, this);
    return Shooter.__super__.isReady.call(this);
  };

  Shooter.prototype.setBaseVariables = function() {
    switch (this.rotate) {
      case 0:
        this.projOffX = this.projOffX || 22;
        this.projOffY = this.projOffY || -8;
        this.projAngle = this.projAngle || 90;
        return this.projVelY = this.projVelY || -this.force;
      case 90:
        this.projOffY = this.projOffY || 10;
        this.projOffX = this.projOffX || 4;
        return this.projVelX = this.projVelX || this.force;
      case -90:
        this.projOffY = this.projOffY || -21;
        this.projOffX = this.projOffX || -18;
        return this.projVelX = this.projVelX || -this.force;
      case 180:
      case -180:
        this.projOffX = this.projOffX || -10;
        this.projOffY = this.projOffY || 4;
        this.projAngle = this.projAngle || 90;
        return this.projVelY = this.projVelY || this.force;
    }
  };

  return Shooter;

})(GameObject);

ArrowCannon = (function(_super) {
  __extends(ArrowCannon, _super);

  function ArrowCannon(game, x, y) {
    ArrowCannon.__super__.constructor.call(this, game, x, y, 'shooters', 0);
  }

  return ArrowCannon;

})(Shooter);

LaserCannon = (function(_super) {
  __extends(LaserCannon, _super);

  function LaserCannon(game, x, y) {
    LaserCannon.__super__.constructor.call(this, game, x, y, 'shooters', 1);
    this.projectile = "Laser";
  }

  return LaserCannon;

})(Shooter);

ArcCannon = (function(_super) {
  __extends(ArcCannon, _super);

  function ArcCannon(game, x, y) {
    ArcCannon.__super__.constructor.call(this, game, x, y, 'shooters', 2);
    this.projectile = "Bullet";
    this.projAngle = 90;
  }

  ArcCannon.prototype.recalculate = function(bullet) {
    var angle;
    this.projOffX = (this.projOffX + 1) % 32;
    if (this.projOffX === 0) {
      this.projOffX = 8;
    }
    angle = ((bullet.x - this.x) / 32) * (this.maxProjAngle - this.minProjAngle) + this.minProjAngle;
    bullet.body.velocity.rotate(this.x + this.width / 2, this.y + this.height / 2, angle, true);
    return bullet.angle = angle;
  };

  return ArcCannon;

})(Shooter);

Trap = (function(_super) {
  __extends(Trap, _super);

  function Trap(game, x, y, key, frame) {
    Trap.__super__.constructor.call(this, game, x, y, key, frame);
    this.body.moves = false;
  }

  return Trap;

})(GameObject);

FadingBlock = (function(_super) {
  __extends(FadingBlock, _super);

  function FadingBlock(game, x, y) {
    FadingBlock.__super__.constructor.call(this, game, x, y, 'fading-block', 0);
    this.animations.add('fade', [0, 0, 0, 0, 1, 2, 3, 2, 1, 0, 0, 0, 0], 4, true);
    this.animations.add('fade_once', [0, 0, 1, 2, 3, 2, 1, 0, 0, 0, 0], 4);
  }

  FadingBlock.prototype.isReady = function() {
    var delay;
    if (!this.auto) {
      return;
    }
    delay = +this.delay || 0;
    return this.game.time.events.add(delay, (function() {
      return this.animations.play('fade');
    }), this);
  };

  return FadingBlock;

})(Trap);

Spring = (function(_super) {
  __extends(Spring, _super);

  function Spring(game, x, y) {
    Spring.__super__.constructor.call(this, game, x, y, 'environment_8', 2);
    this.animations.add('spring', [3, 2], 10, false);
    this.body.setRectangle(24, 8, 4, 0);
  }

  Spring.prototype.isReady = function() {
    this.forceX = +this.forceX || 0;
    this.forceY = +this.forceY || 0;
    this.frame = 2;
    return Spring.__super__.isReady.call(this);
  };

  return Spring;

})(Trap);

HiddenSpike = (function(_super) {
  __extends(HiddenSpike, _super);

  function HiddenSpike(game, x, y) {
    HiddenSpike.__super__.constructor.call(this, game, x, y, 'environment_8', 1);
    this.animations.add('reveal', [0, 1], 4);
    this.frame = 1;
  }

  return HiddenSpike;

})(Trap);

SpikeFloor = (function(_super) {
  __extends(SpikeFloor, _super);

  function SpikeFloor(game, x, y) {
    SpikeFloor.__super__.constructor.call(this, game, x, y, 'environment_16', 0);
    this.body.setRectangle(32, 16, 0, 0);
  }

  return SpikeFloor;

})(Trap);

game = new Game();


},{}]},{},[1])