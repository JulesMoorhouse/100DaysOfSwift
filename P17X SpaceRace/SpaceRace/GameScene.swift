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
    var timerInterval: Double = 1
    var enemiesCreated = 0

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")! // file built into bundle / essential to app, therefore fore unwrap is justified and should crash if the file isn't present
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            gameOver()
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // end game when player hits a piece of space debris
        
        gameOver()
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736)) // right of screen / variable y position
        sprite.name = "enemy"
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1 // can collide with player
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0) // move very hard to the left
        sprite.physicsBody?.angularVelocity = 5 // constant spin
        sprite.physicsBody?.linearDamping = 0 // how fast things slow down over time
        sprite.physicsBody?.angularDamping = 0 // never stop spinning
        
        enemiesCreated += 1
        
        if enemiesCreated % 20 == 0 {
            if timerInterval <= 0.1 { return }
            
            gameTimer?.invalidate()
            
            // Make enemies faster
            timerInterval -= 0.1
            gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    func gameOver() {
        // show explosion when player died
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
        
        for child in children {
            if child.name == "enemy"  {
                child.removeFromParent()
            }
        }
    }
}
