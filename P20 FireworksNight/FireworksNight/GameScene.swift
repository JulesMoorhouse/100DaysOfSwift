//
//  GameScene.swift
//  FireworksNight
//
//  Created by Julian Moorhouse on 15/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var scoreLabel: SKLabelNode!
    
    var fireworks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16) // bottom left corner
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFireworks(xMovement: 0, x: 512, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // fire five, in a fan
            createFireworks(xMovement: 0, x: 512, y: bottomEdge)
            createFireworks(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFireworks(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFireworks(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFireworks(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // fire five, from the left to the right
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            // fire five, from the right to the left
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
    }
    
    func createFireworks(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1 // colour by the full amount we specify
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000)) // path to follow
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        fireworks.append(node)
        addChild(node)
    }
}
