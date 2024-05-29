/*
 * Copyright (c) 2016 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */ 

import SpriteKit
import CoreMotion

struct PhysicsCategory {
  static let None: UInt32              = 0
  static let Player: UInt32            = 0b1      // 1
  static let PlatformNormal: UInt32    = 0b10     // 2
  static let PlatformBreakable: UInt32 = 0b100    // 4
  static let CoinNormal: UInt32        = 0b1000   // 8
  static let CoinSpecial: UInt32       = 0b10000  // 16
  static let Edges: UInt32             = 0b100000 // 32
}

// MARK: - Game States
enum GameStatus: Int {
  case waitingForTap = 0
  case waitingForBomb = 1
  case playing = 2
  case gameOver = 3
}

enum PlayerStatus: Int {
  case idle = 0
  case jump = 1
  case fall = 2
  case lava = 3
  case dead = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {

  // MARK: - Properties
  var bgNode: SKNode!
  var fgNode: SKNode!
  var backgroundOverlayTemplate: SKNode!
  var backgroundOverlayHeight: CGFloat!
  var player: SKSpriteNode!
  
  var platform5Across: SKSpriteNode!
  var coinArrow: SKSpriteNode!
  var platformArrow: SKSpriteNode!
  var platformDiagonal: SKSpriteNode!
  var breakArrow: SKSpriteNode!
  var break5Across: SKSpriteNode!
  var breakDiagonal: SKSpriteNode!
  var coin5Across: SKSpriteNode!
  var coinDiagonal: SKSpriteNode!
  var coinCross: SKSpriteNode!
  var coinS5Across: SKSpriteNode!
  var coinSDiagonal: SKSpriteNode!
  var coinSCross: SKSpriteNode!
  var coinSArrow: SKSpriteNode!
  
  var lastOverlayPosition = CGPoint.zero
  var lastOverlayHeight: CGFloat = 0.0
  var levelPositionY: CGFloat = 0.0
  
  var gameState = GameStatus.waitingForTap
  var playerState = PlayerStatus.idle
  var lives = 3
  
  let motionManager = CMMotionManager()
  var xAcceleration = CGFloat(0)
  let cameraNode = SKCameraNode()
  var lava: SKSpriteNode!
  var lastUpdateTimeInterval: TimeInterval = 0
  var deltaTime: TimeInterval = 0

  override func didMove(to view: SKView) {
    setupNodes()
    setupLevel()
    setupPlayer()
    setupCoreMotion()
    
    physicsWorld.contactDelegate = self
    camera?.position = CGPoint(x: size.width/2, y: size.height/2)
    
    let scale = SKAction.scale(to: 1.0, duration: 0.5)
    fgNode.childNode(withName: "Ready")!.run(scale)
  }
  
  func setupNodes() {
    let worldNode = childNode(withName: "World")!
    bgNode = worldNode.childNode(withName: "Background")!
    backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy()
      as! SKNode
    backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
    fgNode = worldNode.childNode(withName: "Foreground")!
    player = fgNode.childNode(withName: "Player") as! SKSpriteNode
    fgNode.childNode(withName: "Bomb")?.run(SKAction.hide())
    
    setupLava()
    
    platformArrow = loadForegroundOverlayTemplate("PlatformArrow")
    platform5Across = loadForegroundOverlayTemplate("Platform5Across")
    platformDiagonal = loadForegroundOverlayTemplate("PlatformDiagonal")
    breakArrow = loadForegroundOverlayTemplate("BreakArrow")
    break5Across = loadForegroundOverlayTemplate("Break5Across")
    breakDiagonal = loadForegroundOverlayTemplate("BreakDiagonal")
    coin5Across = loadForegroundOverlayTemplate("Coin5Across")
    coinDiagonal = loadForegroundOverlayTemplate("CoinDiagonal")
    coinCross = loadForegroundOverlayTemplate("CoinCross")
    coinArrow = loadForegroundOverlayTemplate("CoinArrow")
    coinS5Across = loadForegroundOverlayTemplate("CoinS5Across")
    coinSDiagonal = loadForegroundOverlayTemplate("CoinSDiagonal")
    coinSCross = loadForegroundOverlayTemplate("CoinSCross")
    coinSArrow = loadForegroundOverlayTemplate("CoinSArrow")

    addChild(cameraNode)
    camera = cameraNode
  }
  
  func setupLevel() {
    // Place initial platform
    let initialPlatform = platform5Across.copy() as! SKSpriteNode
    var overlayPosition = player.position
    overlayPosition.y = player.position.y -
      ((player.size.height * 0.5) + 
        (initialPlatform.size.height * 0.20))
    initialPlatform.position = overlayPosition
    fgNode.addChild(initialPlatform)
    lastOverlayPosition = overlayPosition
    lastOverlayHeight = initialPlatform.size.height / 2.0
    
    // Create random level
    levelPositionY = bgNode.childNode(withName: "Overlay")!.position.y + backgroundOverlayHeight
    while lastOverlayPosition.y < levelPositionY {
      addRandomForegroundOverlay()
    }
    
  }
  
  func setupPlayer() {
    player.physicsBody = SKPhysicsBody(circleOfRadius:
      player.size.width * 0.3)
    player.physicsBody!.isDynamic = false
    player.physicsBody!.allowsRotation = false
    player.physicsBody!.categoryBitMask = PhysicsCategory.Player
    player.physicsBody!.collisionBitMask = 0
  }
  
  func setupCoreMotion() {
    motionManager.accelerometerUpdateInterval = 0.2
    let queue = OperationQueue()
    motionManager.startAccelerometerUpdates(to: queue, withHandler:
      {
        accelerometerData, error in
        guard let accelerometerData = accelerometerData else {
          return
        }
        let acceleration = accelerometerData.acceleration
        self.xAcceleration = (CGFloat(acceleration.x) * 0.75) +
          (self.xAcceleration * 0.25)
      })
  }
  
  // MARK: - Overlay nodes

  func loadForegroundOverlayTemplate(_ fileName: String) -> SKSpriteNode {
    let overlayScene = SKScene(fileNamed: fileName)!
    let overlayTemplate =
      overlayScene.childNode(withName: "Overlay")
    return overlayTemplate as! SKSpriteNode
  }

  func createForegroundOverlay(_ overlayTemplate: SKSpriteNode, flipX: Bool) {
    let foregroundOverlay = overlayTemplate.copy() as!
    SKSpriteNode
    lastOverlayPosition.y = lastOverlayPosition.y + (lastOverlayHeight + (foregroundOverlay.size.height / 2.0))
    lastOverlayHeight = foregroundOverlay.size.height / 2.0
    foregroundOverlay.position = lastOverlayPosition
    if flipX == true {
      foregroundOverlay.xScale = -1.0
    }
    fgNode.addChild(foregroundOverlay)
  }
  
  func addRandomForegroundOverlay() {
    let overlaySprite: SKSpriteNode!
    var flipH = false
    let platformPercentage = 60
    
    if Int.random(min: 1, max: 100) <= platformPercentage {
      if Int.random(min: 1, max: 100) <= 75 {
        // Create standard platforms 75%
        switch Int.random(min: 0, max: 3) {
        case 0:
          overlaySprite = platformArrow
        case 1:
          overlaySprite = platform5Across
        case 2:
          overlaySprite = platformDiagonal
        case 3:
          overlaySprite = platformDiagonal
          flipH = true
        default:
          overlaySprite = platformArrow
        }
      } else {
        // Create breakable platforms 25%
        switch Int.random(min: 0, max: 3) {
        case 0:
          overlaySprite = breakArrow
        case 1:
          overlaySprite = break5Across
        case 2:
          overlaySprite = breakDiagonal
        case 3:
          overlaySprite = breakDiagonal
          flipH = true
        default:
          overlaySprite = breakArrow
        }
      }
    } else {
      if Int.random(min: 1, max: 100) <= 75 {
        // Create standard coins 75%
        switch Int.random(min: 0, max: 4) {
        case 0:
          overlaySprite = coinArrow
        case 1:
          overlaySprite = coin5Across
        case 2:
          overlaySprite = coinDiagonal
        case 3:
          overlaySprite = coinDiagonal
          flipH = true
        case 4:
          overlaySprite = coinCross
        default:
          overlaySprite = coinArrow
        }
      } else {
        // Create special coins 25%
        switch Int.random(min: 0, max: 4) {
        case 0:
          overlaySprite = coinSArrow
        case 1:
          overlaySprite = coinS5Across
        case 2:
          overlaySprite = coinSDiagonal
        case 3:
          overlaySprite = coinSDiagonal
          flipH = true
        case 4:
          overlaySprite = coinSCross
        default:
          overlaySprite = coinSArrow
        }
      }
    }
    
    createForegroundOverlay(overlaySprite, flipX: flipH)
  }
  
  func createBackgroundOverlay() {
    let backgroundOverlay = backgroundOverlayTemplate.copy() as! SKNode
    backgroundOverlay.position = CGPoint(x: 0.0, y: levelPositionY)
    bgNode.addChild(backgroundOverlay)
    levelPositionY += backgroundOverlayHeight
  }
  
  // MARK: - Events

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameState == .waitingForTap {
      bombDrop()
    } else if gameState == .gameOver {
      let newScene = GameScene(fileNamed:"GameScene")
      newScene!.scaleMode = .aspectFill
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      self.view?.presentScene(newScene!, transition: reveal)
    }
  }

  func bombDrop() {
    gameState = .waitingForBomb
    // Scale out title & ready label.
    let scale = SKAction.scale(to: 0, duration: 0.4)
    fgNode.childNode(withName: "Title")!.run(scale)
    fgNode.childNode(withName: "Ready")!.run(
      SKAction.sequence(
        [SKAction.wait(forDuration: 0.2), scale]))
    
    // Bounce bomb
    let scaleUp = SKAction.scale(to: 1.25, duration: 0.25)
    let scaleDown = SKAction.scale(to: 1.0, duration: 0.25)
    let sequence = SKAction.sequence([scaleUp, scaleDown])
    let repeatSeq = SKAction.repeatForever(sequence)
    fgNode.childNode(withName: "Bomb")!.run(SKAction.unhide())
    fgNode.childNode(withName: "Bomb")!.run(repeatSeq)
    run(SKAction.sequence([
      SKAction.wait(forDuration: 2.0),
      SKAction.run(startGame)
      ]))
  }

  func startGame() {
    let bomb = fgNode.childNode(withName: "Bomb")!
    let bombBlast = explosion(intensity: 2.0)
    bombBlast.position = bomb.position
    fgNode.addChild(bombBlast)
    bomb.removeFromParent()
    gameState = .playing
    player.physicsBody!.isDynamic = true
    superBoostPlayer()
  }
  
  func gameOver() {
    // 1
    gameState = .gameOver
    playerState = .dead
    // 2
    physicsWorld.contactDelegate = nil
    player.physicsBody?.isDynamic = false
    // 3
    let moveUp = SKAction.moveBy(x: 0.0, y: size.height/2.0, duration: 0.5)
    moveUp.timingMode = .easeOut
    let moveDown = SKAction.moveBy(x: 0.0, y: -(size.height * 1.5),
                                   duration: 1.0)
    moveDown.timingMode = .easeIn
    player.run(SKAction.sequence([moveUp, moveDown]))
    // 4
    let gameOverSprite = SKSpriteNode(imageNamed: "GameOver")
    gameOverSprite.position = camera!.position
    gameOverSprite.zPosition = 10
    addChild(gameOverSprite)
  }
  
  func setPlayerVelocity(_ amount:CGFloat) {
    let gain: CGFloat = 2.5
    player.physicsBody!.velocity.dy =
      max(player.physicsBody!.velocity.dy, amount * gain)
  }

  func jumpPlayer() {
    setPlayerVelocity(650)
  }

  func boostPlayer() {
    setPlayerVelocity(1200)
  }

  func superBoostPlayer() {
    setPlayerVelocity(1700)
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let other = contact.bodyA.categoryBitMask ==
      PhysicsCategory.Player ? contact.bodyB : contact.bodyA
    switch other.categoryBitMask {
    case PhysicsCategory.CoinNormal:
      if let coin = other.node as? SKSpriteNode {
        coin.removeFromParent()
        jumpPlayer()
      }
    case PhysicsCategory.CoinSpecial:
      if let coin = other.node as? SKSpriteNode {
        coin.removeFromParent()
        boostPlayer()
      }
    case PhysicsCategory.PlatformNormal:
      if let _ = other.node as? SKSpriteNode {
        if player.physicsBody!.velocity.dy < 0 {
          jumpPlayer()
        }
      }
    case PhysicsCategory.PlatformBreakable:
      if let platform = other.node as? SKSpriteNode {
        if player.physicsBody!.velocity.dy < 0 {
          platform.removeFromParent()
          jumpPlayer()
        }
      }
    default:
      break
    }
  }
  
  // MARK: - Updates

  override func update(_ currentTime: TimeInterval) {
    // 1
    if lastUpdateTimeInterval > 0 {
      deltaTime = currentTime - lastUpdateTimeInterval
    } else {
      deltaTime = 0
    }
    lastUpdateTimeInterval = currentTime
    // 2
    if isPaused {
      return
    }
    // 3
    if gameState == .playing {
      updateCamera()
      updateLevel()
      updatePlayer()
      updateLava(deltaTime)
      updateCollisionLava()
    }
  }
  
  func updateCamera() {
    // 1
    let cameraTarget = convert(player.position, from: fgNode)
    // 2
    var targetPositionY = cameraTarget.y - (size.height * 0.10)
    
    let lavaPos = convert(lava.position, from: fgNode)
    targetPositionY = max(targetPositionY, lavaPos.y)
    
    // 3
    let diff = targetPositionY - camera!.position.y
    // 4
    let cameraLagFactor = CGFloat(0.2)
    let lagDiff = diff * cameraLagFactor
    let newCameraPositionY = camera!.position.y + lagDiff
    
    // 5
    camera!.position.y = newCameraPositionY
  }
  
  func sceneCropAmount() -> CGFloat {
    guard let view = view else {
      return 0
    }
    let scale = view.bounds.size.height / self.size.height
    let scaledWidth = self.size.width * scale
    let scaledOverlap = scaledWidth - view.bounds.size.width
    return scaledOverlap / scale
  }
  
  func updatePlayer() {
    // Set velocity based on core motion
    player.physicsBody?.velocity.dx = xAcceleration * 1000.0
      
    // Wrap player around edges of screen
    var playerPosition = convert(player.position, from: fgNode)
    let leftLimit = sceneCropAmount()/2 - player.size.width/2
    let rightLimit = size.width - sceneCropAmount()/2 + player.size.width/2
    if playerPosition.x < leftLimit {
      playerPosition = convert(CGPoint(x: rightLimit, y: 0.0), to: fgNode)
      player.position.x = playerPosition.x
    }
    else if playerPosition.x > rightLimit {
      playerPosition = convert(CGPoint(x: leftLimit, y: 0.0), to: fgNode)
      player.position.x = playerPosition.x
    }
    
    // Check player state
    if player.physicsBody!.velocity.dy < CGFloat(0.0) &&
      playerState != .fall {
      playerState = .fall
      print("Falling.")
    } else if player.physicsBody!.velocity.dy > CGFloat(0.0) &&
      playerState != .jump {
      playerState = .jump
      print("Jumping.")
    }
  }
  
  func updateLava(_ dt: TimeInterval) {
    // 1
    let bottomOfScreenY = camera!.position.y - (size.height / 2)
    // 2
    let bottomOfScreenYFg = convert(CGPoint(x: 0, y: bottomOfScreenY), to: fgNode).y
    // 3
    let lavaVelocityY = CGFloat(120)
    let lavaStep = lavaVelocityY * CGFloat(dt)
    var newLavaPositionY = lava.position.y + lavaStep
    // 4
    newLavaPositionY = max(newLavaPositionY, (bottomOfScreenYFg - 125.0))
    // 5
    lava.position.y = newLavaPositionY
  }
  
  func updateCollisionLava() {
    if player.position.y < lava.position.y + 180 {
      if playerState != .lava {
        playerState = .lava
        let smokeTrail = addTrail(name: "SmokeTrail")
        run(SKAction.sequence([
          SKAction.wait(forDuration: 3.0),
          SKAction.run() {
            self.removeTrail(trail: smokeTrail)
          }
          ]))
      }
      boostPlayer()
      lives -= 1
      if lives <= 0 {
        gameOver()
      }
    }
  }
  
  func updateLevel() {
    let cameraPos = camera!.position
    if cameraPos.y > levelPositionY - (size.height * 0.55) {
      createBackgroundOverlay()
      while lastOverlayPosition.y < levelPositionY {
        addRandomForegroundOverlay()
      }
    }    
  }
  
  // MARK: - Particles
  func explosion(intensity: CGFloat) -> SKEmitterNode {
    let emitter = SKEmitterNode()
    let particleTexture = SKTexture(imageNamed: "spark")
    
    emitter.zPosition = 2
    emitter.particleTexture = particleTexture
    emitter.particleBirthRate = 4000 * intensity
    emitter.numParticlesToEmit = Int(400 * intensity)
    emitter.particleLifetime = 2.0
    emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
    emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
    emitter.particleSpeed = 600 * intensity
    emitter.particleSpeedRange = 1000 * intensity
    emitter.particleAlpha = 1.0
    emitter.particleAlphaRange = 0.25
    emitter.particleScale = 1.2
    emitter.particleScaleRange = 2.0
    emitter.particleScaleSpeed = -1.5

    emitter.particleColorBlendFactor = 1
    emitter.particleBlendMode = SKBlendMode.add
    emitter.run(SKAction.removeFromParentAfterDelay(2.0))
    
    let sequence = SKKeyframeSequence(capacity: 5)
    sequence.addKeyframeValue(SKColor.white, time: 0)
    sequence.addKeyframeValue(SKColor.yellow, time: 0.10)
    sequence.addKeyframeValue(SKColor.orange, time: 0.15)
    sequence.addKeyframeValue(SKColor.red, time: 0.75)
    sequence.addKeyframeValue(SKColor.black, time: 0.95)
    emitter.particleColorSequence = sequence
    
    return emitter
  }
  
  func setupLava() {
    lava = fgNode.childNode(withName: "Lava") as! SKSpriteNode
    let emitter = SKEmitterNode(fileNamed: "Lava.sks")!
    emitter.particlePositionRange = CGVector(dx: size.width
      * 1.125, dy: 0.0)
    emitter.advanceSimulationTime(3.0)
    lava.addChild(emitter)
  }
  
  func addTrail(name: String) -> SKEmitterNode {
    let trail = SKEmitterNode(fileNamed: name)!
    trail.zPosition = -1
    trail.targetNode = fgNode
    player.addChild(trail)
    return trail
  }
  
  func removeTrail(trail: SKEmitterNode) {
    trail.numParticlesToEmit = 1
    trail.run(SKAction.removeFromParentAfterDelay(1.0))
  }
  
  
  
  
  
  
  
    
}
