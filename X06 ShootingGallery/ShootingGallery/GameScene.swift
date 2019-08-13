//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Julian Moorhouse on 12/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    var grass: SKSpriteNode!
    var waterBg: SKSpriteNode!
    var waterFg: SKSpriteNode!
    var reloadLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var remainLabel: SKLabelNode!
    var gameOver: SKSpriteNode!
    var startGameLabel: SKLabelNode!
    
    var timerBottom: Timer?
    var timerMiddle: Timer?
    var timerTop: Timer?
    var timerRemain: Timer?
    
    var timerIntervalBottom: Double = 1.0
    var timerIntervalMiddle: Double = 0.7
    var timerIntervalTop: Double = 0.5

    var isGameOver = false
    
    var soundsFiles = ["shot.wav", "empty.wav", "reload.wav", "whack.caf", "whackBad.caf"]
    enum sounds: Int {
        case shot = 0
        case empty = 1
        case reload = 2
        case whackGood = 3
        case whackBad = 4
    }
    
    // Sounds for preload
    var sound: [SKAction] = []
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var countDown: Int = 60 {
        didSet {
            remainLabel.text = "Time Left: \(countDown)"
        }
    }
    
    var reloadMode: Bool = false {
        didSet {
            if reloadMode {
                reloadLabel.text = "Reload"
            } else {
                reloadLabel.text = ""
            }
        }
    }
    
    class Bullet {
        var x: Int
        var node: SKSpriteNode?
        var used: Bool?
        
        init(x: Int) {
            self.x = x
            self.used = false
        }
    }

    var bullets: [Bullet] = [Bullet(x: 983), Bullet(x: 962), Bullet(x: 941), Bullet(x: 920), Bullet(x: 899), Bullet(x: 878)]
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.init(red: 0.75, green: 0.84, blue: 0.96, alpha: 1)
        
        for item in soundsFiles {
            sound.append(SKAction.playSoundFileNamed(item, waitForCompletion: false))
        }

        grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 512, y: 480)
        grass.setScale(1.28)
        grass.zPosition = 10
        addChild(grass)
        
        waterBg = SKSpriteNode(imageNamed: "water-bg")
        waterBg.position = CGPoint(x: 512, y: 260)
        waterBg.setScale(1.28)
        waterBg.zPosition = 20
        addChild(waterBg)
        
        waterFg = SKSpriteNode(imageNamed: "water-fg")
        waterFg.position = CGPoint(x: 512, y: 100)
        waterFg.setScale(1.28)
        waterFg.zPosition = 30
        addChild(waterFg)
        
        reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.text = ""
        reloadLabel.position = CGPoint(x: 930, y: 90)
        reloadLabel.zPosition = 50
        addChild(reloadLabel)

        startGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        startGameLabel.text = "Start Game"
        startGameLabel.position = CGPoint(x: 512, y: 90)
        startGameLabel.zPosition = 50
        startGameLabel.horizontalAlignmentMode = .center
        //addChild(startGameLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 100, y: 20)
        scoreLabel.zPosition = 50
        addChild(scoreLabel)

        gameOver = SKSpriteNode(imageNamed: "game-over")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 50
        
        remainLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainLabel.text = "Time Left: 60"
        remainLabel.position = CGPoint(x: 20, y: 730)
        remainLabel.horizontalAlignmentMode = .left
        remainLabel.zPosition = 50
        addChild(remainLabel)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self // tell us when contacts happen
        
        for bullet in bullets {
            bullet.node = SKSpriteNode(imageNamed: "shotFull")
            bullet.node?.position = CGPoint(x: bullet.x, y: 43)
            bullet.node?.zPosition = 50
            addChild(bullet.node!)
        }
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        var hitSomething = false
        
        if isGameOver {
            if tappedNodes.contains(startGameLabel) {
                startGame()
            }
            return
        }
        
        if !bullets.contains(where: {( $0.used == false )}) {
            if tappedNodes.contains(reloadLabel) && reloadLabel.text != "" {
                //reloadMode.toggle()
                resetBullets()
                run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
            }
            return
        }
        
        useBullet()
        
        for node in tappedNodes {
            
            guard let item = node.parent as? SpriteNode else { continue }
            
            let sprite = item.sprite!
            
            if (sprite.name == "bad") {
                run(sound[sounds.whackBad.rawValue])
                
            } else if (sprite.name == "good") {
                run(sound[sounds.whackGood.rawValue])

                let goodScore = SKLabelNode(fontNamed: "Chalkduster")
                goodScore.text = "+\(item.scoreAmount)"
                goodScore.horizontalAlignmentMode = .center
                goodScore.zPosition = 40
                let x = location.x - sprite.frame.width / 2
                let y = location.y + sprite.frame.height / 2
                goodScore.position = CGPoint(x: x, y: y)

                addChild(goodScore)
                
                score += item.scoreAmount
                
                goodScore.run(fadeGroup())
            }
            
            if (sprite.name == "bad") || (sprite.name == "good") {
                hitSomething = true
                sprite.run(fadeGroup())
                
                score -= 10
            }
        }
        
        if !hitSomething {
            run(sound[sounds.shot.rawValue])
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if let item = node as? SpriteNode {
                let x = item.sprite.position.x
                if item.row == 0 || item.row == 2 {
                    if x <= 0 {
                        item.sprite.removeFromParent()
                    }
                } else {
                    if x >= 1024 {
                        item.sprite.removeFromParent()
                    }
                }
            }
        }
    }
    
    func fadeGroup() -> SKAction {
        let scale = SKAction.scale(to: 0.1, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        
        return SKAction.group([scale, fade])
    }
    
    @objc func topRow() {
        timerTop?.invalidate()
                
        let sprite = SpriteNode()
        sprite.configure(row: 2, yPos: 545, xPos: 1024, slide: -500, zPosition: 9)
        addChild(sprite)
        
        timerTop = Timer.scheduledTimer(timeInterval: timerIntervalTop, target: self, selector: #selector(topRow), userInfo: nil, repeats: true)

        timerIntervalTop = 0.5
    }

    @objc func middleRow() {
        timerMiddle?.invalidate()
                
        let sprite = SpriteNode()
        sprite.configure(row: 1, yPos: 392, xPos: 0, slide: 350, zPosition: 19)
        addChild(sprite)
        
        timerMiddle = Timer.scheduledTimer(timeInterval: timerIntervalMiddle, target: self, selector: #selector(middleRow), userInfo: nil, repeats: true)
        
        timerIntervalMiddle = 0.7
    }
    
    @objc func bottomRow() {
        timerBottom?.invalidate()

        let sprite = SpriteNode()
        sprite.configure(row: 0, yPos: 239, xPos: 1024, slide: -300, zPosition: 29)
        addChild(sprite)
        
        timerBottom = Timer.scheduledTimer(timeInterval: timerIntervalBottom, target: self, selector: #selector(bottomRow), userInfo: nil, repeats: true)
        
        timerIntervalBottom = 1.0
    }
    
    func useBullet() {
        var counter = 0
        
        for bullet in bullets {
            counter += 1
            if let used = bullet.used {
                if !used {
                    bullet.node?.texture = SKTexture(imageNamed: "shotEmpty")
                    bullet.used = true
                    
                    if counter == 6 {
                        reloadMode.toggle()
                    }
                    break
                }
            }
        }
    }
    
    @objc func countDownTimer() {
        countDown -= 1
        
        if countDown <= 0 {
            timerRemain?.invalidate()
            addChild(gameOver)
            isGameOver = true
            addChild(startGameLabel)
        } else if countDown <= 3 {
            timerTop?.invalidate()
            timerMiddle?.invalidate()
            timerBottom?.invalidate()
        }
    }
    
    func resetTimer() {
        timerRemain = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(countDownTimer), userInfo: nil, repeats: true)
    }
    
    func resetBullets() {
        bullets = bullets.map({ (bullet) -> Bullet in
            bullet.used = false
            bullet.node?.texture = SKTexture(imageNamed: "shotFull")
            return bullet
        })
        reloadMode = false
    }
    
    func startGame() {
        countDown = 60
        score = 0
        gameOver.removeFromParent()
        startGameLabel.removeFromParent()
        
        topRow()
        middleRow()
        bottomRow()
        
        isGameOver = false
        resetTimer()
    }
}
