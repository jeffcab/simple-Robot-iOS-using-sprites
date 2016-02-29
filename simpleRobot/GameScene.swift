//
//  GameScene.swift
//  simpleRobot
//
//  Created by Jeffrey Cabrera
//  Copyright (c) 2016 jcab. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var titleName = SKSpriteNode()
    var tapLabel = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        
        initGameScene()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        let fadeOut = SKAction.fadeOutWithDuration(1.0)
        tapLabel.runAction(fadeOut, completion: {
            let doorsAnim = SKTransition.doorsOpenHorizontalWithDuration(0.5) //SKTransition.doorwayWithDuration(0.5)
            let shooterScene = ShooterScene(fileNamed: "ShooterScene")
            self.view?.presentScene(shooterScene!, transition: doorsAnim)
        })
        
    }
    
    func initGameScene() {
        
        titleName = SKSpriteNode(imageNamed: "title.png")
        titleName.name = "titleNode"
        titleName.size = CGSize(width: 747, height: 102)
        titleName.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
        titleName.zPosition = 2
        self.addChild(titleName)
        
        tapLabel = SKSpriteNode(imageNamed: "tap.png")
        tapLabel.name = "tapNode"
        tapLabel.size = CGSize(width: 433, height: 69)
        tapLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/4)
        tapLabel.zPosition = 2
        self.addChild(tapLabel)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
