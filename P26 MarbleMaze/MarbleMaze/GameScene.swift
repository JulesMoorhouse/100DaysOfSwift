//
//  GameScene.swift
//  MarbleMaze
//
//  Created by Julian Moorhouse on 18/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit

enum LetterType: Character {
    case wall = "x"
    case vortex = "v"
    case star = "s"
    case finishPoint = "f"
    case empty = " "
}

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

enum NodeNames: String {
    case wall
    case vortex
    case star
    case finish
    // case empty = " "
}

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        loadLevel()
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        // reading from bottom to top, because on inverted y access in SpriteKit
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                // 64 is the block size and 32 for the center of the block, as SpriteKit positions items from the center
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if letter == LetterType.wall.rawValue {
                    // load wall
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    
                    node.physicsBody?.isDynamic = false // will not move around with gravity
                    
                    addChild(node)
                    
                } else if letter == LetterType.vortex.rawValue {
                    // load vortex
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = NodeNames.vortex.rawValue
                    node.position = position
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1))) // spin forever
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue // it is a vortex for collision purposes
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue // we want to be told about collisions
                    node.physicsBody?.collisionBitMask = 0 // bounce off nothing
                    
                    addChild(node)
                    
                } else if letter == LetterType.star.rawValue {
                    // load star
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = NodeNames.star.rawValue
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    node.position = position
                    addChild(node)
                } else if letter == LetterType.finishPoint.rawValue {
                    // load finish point
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = NodeNames.finish.rawValue
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    node.position = position
                    addChild(node)
                } else if letter == LetterType.empty.rawValue {
                    // this is an empty space - do nothing
                } else {
                    fatalError("Unknown level letter: '\(letter)'")
                }
            }
        }
    }
}
