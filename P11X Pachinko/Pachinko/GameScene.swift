//
//  GameScene.swift
//  Pachinko
//
//  Created by Julian Moorhouse on 06/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballsLabel: SKLabelNode!
    
    var ballCount = 5 {
        didSet {
            ballsLabel.text = "Balls: \(ballCount)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var numberOfBoxes = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        // draw in centre of the screen
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)

        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls: 5"
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.position = CGPoint(x: 980, y: 660)
        addChild(ballsLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                // create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                
                // rotation about 180 randomly
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
                numberOfBoxes += 1
            } else {
                let balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
                let ballName = balls[Int.random(in: 0...6)]
                let ball = SKSpriteNode(imageNamed: ballName)
                
                // Behave as a ball not a square,  radius half width of ball
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                
                // Bounciness 0 - none, 1 - super bouncy
                ball.physicsBody?.restitution  = 0.4
                
                // Which collisons do you want to know about, tell us about all collisions, not efficient in complicated games
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                
                let topLocaltion = CGPoint(x: location.x, y: 700)
                ball.position = topLocaltion
                ball.name = "ball"
                ballCount -= 1
                addChild(ball)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        
        // object will collide, but won't move as a result
        bouncer.physicsBody?.isDynamic = false
        
        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        // Spin half a circle over 10 seconds
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballCount += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box" {
            object.removeFromParent()
            numberOfBoxes -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let firePartices = SKEmitterNode(fileNamed: "FireParticles") {
            firePartices.position = ball.position
            addChild(firePartices)
        }
        
        ball.removeFromParent()
        
        if ballCount <= 0 {
            if numberOfBoxes <= 0 {
                let alert = UIAlertController(title: "Game", message: "Congratulations you cleared all the pins!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                return
            }
            
            if ballCount <= 0 {
                let alert = UIAlertController(title: "Game", message: "Sorry failed to clear all the pins", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
