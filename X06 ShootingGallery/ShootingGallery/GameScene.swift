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
    
    var timerBottom: Timer?
    var timerMiddle: Timer?
    var timerTop: Timer?
    var timerIntervalBottom: Double = 1.0
    var timerIntervalMiddle: Double = 0.7
    var timerIntervalTop: Double = 0.5

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
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self // tell us when contacts happen
        
        topRow()
        middleRow()
        bottomRow()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        var hitSomething = false
        
        for node in tappedNodes {
            //print("tapped \(String(describing: node.name))")
            
            if (node.name == "bad") {
                print("play bad")
                run(sound[sounds.whackBad.rawValue])
                
            } else if (node.name == "good") {
                print("play good")
                run(sound[sounds.whackGood.rawValue])

                let goodScore = SKLabelNode(fontNamed: "Chalkduster")
                goodScore.text = "+10"
                goodScore.horizontalAlignmentMode = .center
                goodScore.zPosition = 40
                let x = location.x - node.frame.width / 2
                let y = location.y + node.frame.height / 2
                goodScore.position = CGPoint(x: x, y: y)

                addChild(goodScore)
                
                goodScore.run(fadeGroup())
            }
            
            if (node.name == "bad") || (node.name == "good") {
                hitSomething = true
                node.run(fadeGroup())
            }
        }
        
        if !hitSomething {
            print("play miss")
            run(sound[sounds.shot.rawValue])

        }
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    func fadeGroup() -> SKAction {
        let scale = SKAction.scale(to: 0.1, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        return SKAction.group([scale, fade])
    }
    
    @objc func topRow() {
        
        timerTop?.invalidate()
        
        slideDuck(row: 2, yPos: 567, xPos: 1024, slide: -500, zPosition: 9)
        
        timerTop = Timer.scheduledTimer(timeInterval: timerIntervalTop, target: self, selector: #selector(topRow), userInfo: nil, repeats: true)

        timerIntervalTop = 0.5
    }

    @objc func middleRow() {
        timerMiddle?.invalidate()
        
        slideDuck(row: 1,yPos: 399, xPos: 0, slide: 350, zPosition: 19)
        
        timerMiddle = Timer.scheduledTimer(timeInterval: timerIntervalMiddle, target: self, selector: #selector(middleRow), userInfo: nil, repeats: true)
        
        timerIntervalMiddle = 0.7
    }
    
    @objc func bottomRow() {
        timerBottom?.invalidate()

        slideDuck(row: 0,yPos: 239, xPos: 1024, slide: -300, zPosition: 29)
        
        timerBottom = Timer.scheduledTimer(timeInterval: timerIntervalBottom, target: self, selector: #selector(bottomRow), userInfo: nil, repeats: true)
        
        timerIntervalBottom = 1.0
    }
    
    @objc func slideDuck(row: Int, yPos: Int, xPos: Int , slide: Int, zPosition: CGFloat) {

        let spriteNum: Int = Int.random(in: 0...3)

        let sprite = SKSpriteNode(imageNamed: "target\(spriteNum)")
        sprite.position = CGPoint(x: xPos, y: yPos)
        sprite.name = "good"
        
        sprite.zPosition = zPosition
        
        if !(Int.random(in: 0...10) % 5 == 0) {
            sprite.color = .lightGray
            sprite.colorBlendFactor = 1
            sprite.name = "bad"
        }
        
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: slide, dy: 0)
    }
}
