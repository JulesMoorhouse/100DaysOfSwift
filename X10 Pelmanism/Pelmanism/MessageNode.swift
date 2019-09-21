//
//  MessageNode.swift
//  Pelmanism
//
//  Created by Julian Moorhouse on 20/09/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit
import UIKit

class MessageNode: SKSpriteNode {

    func setup(message: String, fontSize: CGFloat) {
        name = "message"
        
        let image: UIImage = drawCardFront(size: size, message: message, fontSize: fontSize)

        texture = SKTexture(image: image)
            configurePhysics()
        }
        
        func configurePhysics() {
            physicsBody = SKPhysicsBody(texture: texture!, size: size)
            physicsBody?.isDynamic = false
        }
    
    func drawCardFront(size: CGSize, message: String, fontSize: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rect = CGRect(origin: CGPoint(x: 10, y: 20), size: size)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.white
            shadow.shadowBlurRadius = 10
            
            let textFontAttributes: [NSAttributedString.Key : Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: color,
                .shadow: shadow
            ]
            
            let string = NSAttributedString(string: message, attributes: textFontAttributes)

            string.draw(in: rect)

            ctx.cgContext.drawPath(using: .fill)
        }
        
        return img
    }
    
}
