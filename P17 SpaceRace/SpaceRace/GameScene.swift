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
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
