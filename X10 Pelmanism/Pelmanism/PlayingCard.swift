//
//  PlayingCard.swift
//  Pelmanism
//
//  Created by Julian Moorhouse on 10/09/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import SpriteKit
import UIKit

class PlayingCard: SKSpriteNode {
    var faceUp: Bool = false
    var cardBackTextture: SKTexture!
    var cardFrontTexture: SKTexture!
    
    var cardSymbol: String = ""
    
    func setup(symbol: String) {
        name = "playingCard"
        cardSymbol = symbol
        
        let currentImage: UIImage = drawCardBack(size: size)
        let cardFrontImage: UIImage = drawCardFront(size: size, symbol: cardSymbol)
        
        cardBackTextture = SKTexture(image: currentImage)
        cardFrontTexture = SKTexture(image: cardFrontImage)
        
        texture = cardBackTextture
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
    }
    
    func drawCardBack(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            
            let numRows: Int = Int(UInt(size.width / 5))
            let numCols: Int = Int(UInt(size.height / 5))
            let maxItems = numRows > numCols ? numRows : numCols
            for col in 0 ..< maxItems {
                for row in 0 ..< maxItems {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 5, y: row * 5, width: 5, height: 5))
                    }
                }
            }
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            ctx.cgContext.setLineWidth(20)

            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        return img
    }
    
    func drawCardFront(size: CGSize, symbol: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let color: UIColor = .white
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            UIRectFill(CGRect(origin: .zero, size: size))
            
            UIColor.clear.set()
            let rect = CGRect(origin: CGPoint(x: 10, y: 20), size: size)
            symbol.draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 80)])
            
            ctx.cgContext.drawPath(using: .fill)
        }
        
        return img
    }
    
    func flip() {
        let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.4)
        let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.4)
        
        setScale(1.0)
        
        if faceUp {
            run(firstHalfFlip) {
                self.texture = self.cardBackTextture
                self.run(secondHalfFlip)
            }
        } else {
            run(firstHalfFlip) {
                self.texture = self.cardFrontTexture
                self.run(secondHalfFlip)
            }
        }
        faceUp = !faceUp
    }
}
