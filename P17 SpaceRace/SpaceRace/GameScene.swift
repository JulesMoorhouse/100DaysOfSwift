//
//  GameScene.swift
//  SpaceRace
//
//  Created by Julian Moorhouse on 12/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"] // space debris
    var gameTimer: Timer?
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")!
        starField.position = CGPoint(x: 1024, y: 384) // right edge / half way off
        starField.advanceSimulationTime(10) // add 10 seconds of starfield now, so we have something at startup rather than a black screen
        addChild(starField)
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384) // half way up game screen
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) // picture inside a sprite, draw around the player with the texture
        player.physicsBody?.contactTestBitMask = 1 // other things in our game / other things we collide with in our game
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16) // bottom left corner
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0 // trigger propery observer
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self // tell us when contacts happen
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                // remove once invisible
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736)) // right of screen / variable y position
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1 // can collide with player
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0) // move very hard to the left
        sprite.physicsBody?.angularVelocity = 5 // constant spin
        sprite.physicsBody?.linearDamping = 0 // how fast things slow down over time
        sprite.physicsBody?.angularDamping = 0 // never stop spinning
        
    }
}
