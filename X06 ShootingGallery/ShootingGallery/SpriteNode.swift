//
//  SpriteNode.swift
//  ShootingGallery
//
//  Created by Julian Moorhouse on 13/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteNode: SKNode {
    var scoreAmount = 0
    var row = 0
    var sprite: SKSpriteNode!

    func configure(row: Int, yPos: Int, xPos: Int, slide: Int, zPosition: CGFloat) {
        let spriteNum: Int = Int.random(in: 0...3)

        self.row = row
        
        sprite = SKSpriteNode(imageNamed: "target\(spriteNum)")
        sprite.position = CGPoint(x: xPos, y: yPos)
        sprite.name = "good"

        sprite.zPosition = zPosition

        if !(Int.random(in: 0...10) % 5 == 0) {
            sprite.color = .lightGray
            sprite.colorBlendFactor = 1
            sprite.name = "bad"
        }

        switch row {
            case 0:
                sprite.setScale(1.0)
                scoreAmount = 10
            case 1:
                sprite.setScale(0.8)
                scoreAmount = 20
            case 2:
                sprite.setScale(0.6)
                scoreAmount = 30
            default:
                break
        }

        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: slide, dy: 0)
    }
}
