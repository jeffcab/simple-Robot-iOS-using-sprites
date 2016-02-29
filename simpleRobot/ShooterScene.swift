//
//  ShooterScene.swift
//  simpleRobot
//
//  Created by Jeffrey Cabrera
//  Copyright © 2016 jcab. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class ShooterScene: SKScene, SKPhysicsContactDelegate {

    //Declare here
    var mainShooter = SKSpriteNode()
    var bullet = SKSpriteNode()
    var muzzle = SKSpriteNode()
    var bground = SKSpriteNode()
    var bomb = SKSpriteNode()
    
    var score = 0
    var enemyCount = 10
    var shootAtlas = SKTextureAtlas()
    var idleAtlas = SKTextureAtlas()
    var bulletAtlas = SKTextureAtlas()
    var muzzleAtlas = SKTextureAtlas()
    
    var shootArray = [SKTexture]()
    var idleArray = [SKTexture]()
    var bulletArray = [SKTexture]()
    var muzzleArray = [SKTexture]()
    
    let bulletCategory: UInt32 = 0x1 << 0
    let bombCategory: UInt32 = 0x1 << 1
    
    var audioPlayer : AVAudioPlayer?
    var sfxPlayer : AVAudioPlayer?
    var bgAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bgaudio2", ofType: "mp3")!)
    var shootAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("shoot", ofType: "wav")!)
    
    override func didMoveToView(view: SKView) {
        
        //initialize play bg music
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: bgAudio)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
        } catch _ {
            audioPlayer = nil
        }
        
        //initialize play sfx
        do {
            sfxPlayer = try AVAudioPlayer(contentsOfURL: shootAudio)
            sfxPlayer!.prepareToPlay()
        } catch _ {
            sfxPlayer = nil
        }
        
        //NSLog("\(shootAtlas.textureNames)")
        
        //decrease y gravity
        self.physicsWorld.gravity = CGVectorMake(0, -1.0)
        self.physicsWorld.contactDelegate = self
        self.initShooterScene()
        
    }
    
    func initShooterScene() {
        
        //initially load animations
        shootAtlas = SKTextureAtlas(named: "shoot")
        idleAtlas = SKTextureAtlas(named: "idle")
        bulletAtlas = SKTextureAtlas(named: "Bullet")
        muzzleAtlas = SKTextureAtlas(named: "Muzzle")
        
        //add animations to array
        for i in 1...shootAtlas.textureNames.count{
            let imgShoot = "shoot\(i).png"
            shootArray.append(SKTexture(imageNamed: imgShoot))
        }
        for i in 1...idleAtlas.textureNames.count{
            let imgIdle = "Idle\(i).png"
            idleArray.append(SKTexture(imageNamed: imgIdle))
        }
        for i in 1...bulletAtlas.textureNames.count{
            let imgBullet = "Bullet\(i).png"
            bulletArray.append(SKTexture(imageNamed: imgBullet))
        }
        for i in 1...muzzleAtlas.textureNames.count{
            let imgMuzzle = "Muzzle\(i).png"
            muzzleArray.append(SKTexture(imageNamed: imgMuzzle))
        }
        
        //add background
        bground = SKSpriteNode(imageNamed: "bg.png")
        bground.size = CGSize(width: 546+30, height: 291+30)
        bground.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bground.zPosition = 1
        self.addChild(bground)
        
        //add shooter
        mainShooter = SKSpriteNode(imageNamed: idleAtlas.textureNames[0])
        mainShooter.size = CGSize(width: 67+50, height: 56+50)
        mainShooter.position = CGPoint(x: self.size.width/8, y: self.size.height/4)
        mainShooter.zPosition = 2
        self.addChild(mainShooter)
        
        mainShooter.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(idleArray, timePerFrame: 0.12)))
        
        audioPlayer!.play()
        
        let dropBombs = SKAction.sequence([SKAction.runBlock({
            self.createBomb() }),
            SKAction.waitForDuration(1.0) ])
        
        self.runAction(SKAction.repeatAction(dropBombs, count: enemyCount), completion: {
            let sequence = SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.runBlock({ self.gameOver() })])
            self.runAction(sequence)
        })
        //self.runAction(SKAction.repeatActionForever(dropBombs))
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let muzzleNode = self.childNodeWithName("muzzleNode")
        self.muzzle.removeFromParent()
        self.bullet.removeFromParent()
        muzzle = SKSpriteNode(imageNamed: muzzleAtlas.textureNames[0])
        muzzle.size = CGSize(width: 9, height: 81)
        muzzle.position = CGPointMake(mainShooter.position.x + mainShooter.frame.size.width/3, mainShooter.position.y)
        muzzle.zPosition = 2
        self.addChild(muzzle)
        
        bullet = SKSpriteNode(imageNamed: bulletAtlas.textureNames[0])
        bullet.size = CGSize(width: 42, height: 29)
        //bullet.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(bulletArray, timePerFrame: 0.12)))
        let animation = SKAction.animateWithTextures(shootArray, timePerFrame: 0.12)
        let muzzleAnim = SKAction.animateWithTextures(muzzleArray, timePerFrame: 0.12)
        
        let shootBullet = SKAction.runBlock({
            let bulletNode = self.createBulletNode()
            self.sfxPlayer!.play()
            self.zPosition = 2
            self.addChild(bulletNode)
            bulletNode.physicsBody?.applyImpulse(CGVector(dx: 120, dy: 8.5)) //(10.0, 22))
            bulletNode.physicsBody?.categoryBitMask = self.bulletCategory
//            bulletNode.physicsBody?.applyForce(CGVector(dx: 2500,dy: 600))

        })
        
        let sequence = SKAction.sequence([animation, shootBullet])
        let muzzleSequence = SKAction.sequence([muzzleAnim])
        
        mainShooter.runAction(sequence)
        muzzle.runAction(muzzleSequence, completion: { self.muzzle.removeFromParent() })
      
    }
    
    // create bullet Node
    func createBulletNode() -> SKSpriteNode {
        
        let shooterNode = self.childNodeWithName("shooterNode")
        let shooterPosition = shooterNode?.position
        let shooterWidth = shooterNode?.frame.size.width
        //let shooterPosition = mainShooter.position
        //let shooterWidth = mainShooter.frame.size.width
        //var bulletFire = SKAction.animateWithTextures(bulletArray, timePerFrame: 0.20)
        let bulletFire = SKSpriteNode(imageNamed: "Bullet1.png")
        
        bulletFire.size = CGSize(width: 32, height: 19)
        bulletFire.position = CGPointMake(mainShooter.position.x + 10, mainShooter.position.y)
        bulletFire.zPosition = 2
        bulletFire.name = "bulletNode"
        bulletFire.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
        bulletFire.physicsBody?.usesPreciseCollisionDetection = true
        bulletFire.physicsBody?.categoryBitMask = bulletCategory
        bulletFire.physicsBody?.collisionBitMask = bulletCategory | bombCategory
        bulletFire.physicsBody?.contactTestBitMask = bulletCategory | bombCategory
        return bulletFire
    }
    
    // create bombs
    func createBomb() {
        
        bomb = SKSpriteNode(imageNamed: "bomb.png")
        bomb.name = "ballNode"
        bomb.size = CGSize(width: 62, height: 62)
        bomb.position = CGPointMake(randomNumber(self.size.width), self.size.height)
        bomb.zPosition = 2
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width/2)
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(bomb)
    }
    
    // random number between 0 and width
    func randomNumber(maximum: CGFloat) -> CGFloat{
        let maxInt = UInt32(maximum)
        let result = arc4random() % maxInt
        //let result = arc4random_addrandom(0, maxInt)
        return CGFloat(result)
    }
    
    // contact
    func didBeginContact(contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
        if(contact.bodyA.categoryBitMask == bulletCategory) && (contact.bodyB.categoryBitMask == bombCategory){
            let contactPoint = contact.contactPoint
            let contact_x = contactPoint.x
            let contact_y = contactPoint.y
            let target_y = secondNode.position.y
            let margin = secondNode.frame.size.height/2 - 25
            
            if(contact_y > (target_y - margin)) && (contact_y < (target_y + margin)){

            }
            
            let texture = SKTexture(imageNamed: "boom.png")
            firstNode.texture = texture
            let joint = SKPhysicsJointFixed.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB, anchor: CGPointMake(contact_x, contact_y))
            self.physicsWorld.addJoint(joint)
            secondNode.removeFromParent()
            score++

        }
    }
    
    //scoring
    func createScoreNode() -> SKLabelNode {
        let scoreNode = SKLabelNode(fontNamed: "Helvetica")
        scoreNode.name = "scoreNode"
        
        let newScore = "Game Over! Your Score is \(score)"
        
        scoreNode.text = newScore
        scoreNode.fontSize = 40
        scoreNode.fontColor = SKColor.redColor()
        scoreNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        return scoreNode
    }
    
    //gameover
    func gameOver() {
        
        let scoreNode = self.createScoreNode()
        self.addChild(scoreNode)
//        let fadeOut = SKAction.fadeOutWithDuration(5.0)
//        
//        let titleReturn = SKAction.runBlock({
//            let transition = SKTransition.doorwayWithDuration(0.5) //SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
//            let titleScene = GameScene(fileNamed: "GameScene")
//            self.view?.presentScene(titleScene!, transition: transition)
//        })
//        
//        let sequence = SKAction.sequence([fadeOut, titleReturn])
//        self.runAction(sequence)
        
        let fadeOut = SKAction.fadeOutWithDuration(2.0)
        self.runAction(fadeOut, completion: {
            scoreNode.removeFromParent()
            let doorsAnim = SKTransition.doorwayWithDuration(0.5)
            let titleScene = GameScene(fileNamed: "GameScene")
            self.view?.presentScene(titleScene!)
        })
    }
}
