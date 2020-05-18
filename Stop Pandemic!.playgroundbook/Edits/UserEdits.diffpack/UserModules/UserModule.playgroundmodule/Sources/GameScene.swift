
import SpriteKit
import AVFoundation

public var lol = 0
public var minX: CGFloat = 0.0
public var minY: CGFloat = 0.0
public var midX: CGFloat = 0.0
public var midY: CGFloat = 0.0
public var maxX: CGFloat = 0.0
public var maxY: CGFloat = 0.0

public class GameScene: SKScene, SKPhysicsContactDelegate{
    
    // Constants
    let numberOfPeople = 5
    let maxPersonSpeed: UInt32 = 100
    let aidTime: TimeInterval = 11
    let timeConstant: TimeInterval = 0.05
    let speedConstant: CGFloat = 0.0005
    
    
    var randomQuestion = 0
    var questionArray = [String]()
    var answerArray = [Bool]()
    var enemyWait: SKAction?
    var enemyAction: SKAction?
    var twoAction: Bool = true
    var showQuestion: Bool = true
    var answerOfQuestion: Bool = true
    
    var enemyTime: TimeInterval = 1.2
    
    var distanceBetweenObjects: CGFloat = 0.8
    
    var healthLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var health: Int32 = 100
    var player: SKSpriteNode!
    var enemy1: SKSpriteNode!
    var enemies = [SKSpriteNode]()
    var aidObjectsPlus = [SKSpriteNode]()
    var aidObjectsMinus = [SKSpriteNode]()
    var gameOver = false
    var movingPlayer = false
    var score = 0 
    var timer = Timer()
    
    var speedOfEnemy: CGFloat = 0.01
    var backgroundMusic: AVAudioPlayer?
    var shootEffect: AVAudioPlayer?
    var virusEffect: AVAudioPlayer?
    var aidPlusEffect: AVAudioPlayer?
    var aidMinusEffect: AVAudioPlayer?
    
    var restartLabel: SKLabelNode!
    var resetLabel: SKLabelNode!
    var trueLabel: SKLabelNode!
    var falseLabel: SKLabelNode!
    var questionLabel: SKLabelNode!
    
    var restartShape: SKSpriteNode!
    var trueShape: SKSpriteNode!
    var falseShape: SKSpriteNode!
    var resetShape: SKSpriteNode!
    
    
    public override func didMove(to view: SKView) {
        
        midY = frame.midY
        midX = frame.midX
        minX = frame.minX
        minY = frame.minY
        maxX = frame.maxX
        maxY = frame.maxY
        
        distanceBetweenObjects /= 2.0
        
        // Background Music
        let path = Bundle.main.path(forResource: "without.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        // Health Text
        healthLabel = SKLabelNode(text: "Health: " + String(health))
        healthLabel.fontSize = 25.0
        healthLabel.position = CGPoint(x: maxX*0.9, y: frame.maxY*0.9)
        healthLabel.zPosition = 5
        healthLabel.fontColor = .red
        addChild(healthLabel)
        
        // Score Text
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = 25.0
        scoreLabel.position = CGPoint(x: maxX*0.1, y: maxY*0.9)
        scoreLabel.zPosition = 5
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        
        
        // Score Text according to time
        let wait = SKAction.wait(forDuration: 0.5)
        let action = SKAction.run {
            if(self.health > 1){
                self.score += 10
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([wait,action])))
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0
        physicsBody?.categoryBitMask = Bitmasks.world
        physicsWorld.contactDelegate = self
        
        //Background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "back.png")))
        bg.zPosition = -10;
        bg.setScale(0.5)
        bg.position = CGPoint(x: midX, y: midY)
        addChild(bg)
        
        // Background Music
        do{
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.volume = 0.4
            backgroundMusic?.play()
        }catch{
            
        }
        
        // Player
        player = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "smiling-face-with-halo_1f607.png")), color: .clear, size: CGSize(width: size.width*0.1, height: size.width*0.1))
        player.position = CGPoint(x: midX, y: midY)
        addChild(player)
        
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width * (distanceBetweenObjects))
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = Bitmasks.player
        player.physicsBody?.contactTestBitMask = Bitmasks.enemy
        
        // Aid Spawn
        let aidWait = SKAction.wait(forDuration: aidTime)
        let aidAction = SKAction.run {
            if(self.health > 0){
                switch(self.randomize(randomMax: 4, plusFactor: 0)){
                case 0:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: 0), posY: maxY, speed: self.speedOfEnemy * 1.1, isEnemy: false)
                    break
                case 1:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: UInt32(midX)), posY: maxY, speed: self.speedOfEnemy * 1.1, isEnemy: false)
                    break
                case 2:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: 0), posY: minY, speed: self.speedOfEnemy * 1.1, isEnemy: false)
                    break
                case 3:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: UInt32(midX)), posY: minY, speed: self.speedOfEnemy * 1.1, isEnemy: false)
                    break
                default:
                    break
                }
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([aidWait,aidAction])))
        
        // Enemy Spawn
        enemyWait = SKAction.wait(forDuration: enemyTime)
        enemyAction = SKAction.run {
            if(self.health > 0){
                switch(self.randomize(randomMax: 8, plusFactor: 0)){
                case 0:
                    self.createEnemy(posX: minX, posY: self.randomize(randomMax: UInt32(midY), plusFactor: 0),speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 1:
                    self.createEnemy(posX: minX, posY:self.randomize(randomMax: UInt32(midY), plusFactor: UInt32(midY)),speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 2:
                    self.createEnemy(posX: maxX, posY: self.randomize(randomMax: UInt32(midY), plusFactor: 0),speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 3:
                    self.createEnemy(posX: maxX, posY: self.randomize(randomMax: UInt32(midY), plusFactor: UInt32(midY)),speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 4:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: 0), posY: minY,speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 5:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: UInt32(midX)), posY: minY,speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 6:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: 0), posY: maxY,speed: self.speedOfEnemy, isEnemy: true)
                    break
                case 7:
                    self.createEnemy(posX: self.randomize(randomMax: UInt32(midX), plusFactor: UInt32(midX)), posY: maxY,speed: self.speedOfEnemy, isEnemy: true)
                    break
                default:
                    break
                }
                if(self.enemyTime >= 0){
                    self.enemyTime -= self.timeConstant
                }
                self.speedOfEnemy += self.speedConstant
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([enemyWait!,enemyAction!])))
        
        
    }
    
    // If collisions are started
    public func didBegin(_ contact: SKPhysicsContact) {
        guard !gameOver else { return }
        if (contact.bodyA.categoryBitMask == Bitmasks.player){
            for enemy in enemies{
                if(contact.bodyB.node == enemy){
                    contact.bodyB.isResting = true
                    enemy.physicsBody = nil
                    
                    let wait = SKAction.wait(forDuration: 1)
                    let action = SKAction.run {
                        // Hurt player
                        if(enemy.alpha >= CGFloat(0.6)){
                            self.health -= 2
                            self.soundEffect(name: "hurt.mp3", situation: 1)
                            if(self.health <= 20){
                                self.player.alpha -= 0.1
                            }else{
                                self.player.alpha = 1.0
                            }
                            
                            contact.bodyB.isResting = true
                        }
                    }
                    run(SKAction.repeatForever(SKAction.sequence([wait,action])))
                    
                }
                
            }
        }
    }
    
    // Touch screen events
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNodes = nodes(at: touchLocation)
        
        for node in touchedNodes {
            // Restart button
            if node == restartShape{
                restartGame()
                // Reset button
            }else if node == resetShape{
                UserDefaults.standard.set(0, forKey: "highscore")
                restartGame()
                // True button
            }else if node == trueShape{
                if(answerOfQuestion){
                    answer(isCorrect: true)
                }else{
                    answer(isCorrect: false)
                }
                // False button
            }else if node == falseShape{
                if(!answerOfQuestion){
                    answer(isCorrect: true)
                }else{
                    answer(isCorrect: false)
                }
            }else{
                // Enemy objects
                for enemy in enemies{
                    if(node == enemy){
                        //Shooting
                        soundEffect(name: "laser.mp3", situation: 0)
                        enemy.alpha -= 0.2
                        if(enemy.alpha <= 0.5){
                            enemy.physicsBody?.categoryBitMask = Bitmasks.invisible
                            enemy.removeAllActions()
                            enemy.removeFromParent()
                        }
                    }
                }
                // Aid objects +
                for aid in aidObjectsPlus{
                    if(node == aid){
                        health += 20
                        soundEffect(name: "success.mp3", situation: 2)
                        aid.removeFromParent()
                    }
                }
                // Aid objects -
                for aid in aidObjectsMinus{
                    if(node == aid){
                        health -= 20
                        soundEffect(name: "fail2.mp3", situation: 3)
                        aid.removeFromParent()
                    }
                }
            } 
        }
        
    }
    
    // Update function
    public override func update(_ currentTime: TimeInterval) {
        
        // Spawning two enemies at the same time
        if(speedOfEnemy >= 0.02 && twoAction){
            run(SKAction.repeatForever(SKAction.sequence([enemyWait!,enemyAction!])))
            twoAction = false
        }
        
        // If you are not infected
        if(health >= 0){
            healthLabel.text = "Health: " + String(health)
        }else{
            healthLabel.text = "Health: 0" 
        }
        
        scoreLabel.text = "Score: " + String(self.score)
        
        // If you are infected, then question time!
        if(self.health <= 0 && showQuestion){
            self.questionTime()
            showQuestion = false
        }
        
        // Change emoji according to the health
        if(self.health >= 80){
            self.player.texture = SKTexture(image: #imageLiteral(resourceName: "grinning-face-with-star-eyes_1f929.png"))
        }else if(self.health >= 60){
            self.player.texture = SKTexture(image: #imageLiteral(resourceName: "smiling-face-with-halo_1f607.png"))
        }else if(self.health >= 40){
            self.player.texture = SKTexture(image: #imageLiteral(resourceName: "face-with-thermometer_1f912.png"))
        }else if(self.health >= 20){
            self.player.texture = SKTexture(image: #imageLiteral(resourceName: "face-with-medical-mask_1f637.png"))
        }else if(self.health >= 0){
            self.player.texture = SKTexture(image: #imageLiteral(resourceName: "dizzy-face_1f635.png"))
        }
        
    }
    
    
    
    // ***-----------------------------***
    
    // Randomize function to return a random value between specific numbers
    func randomize(randomMax: UInt32, plusFactor: UInt32) -> CGFloat{
        return CGFloat( arc4random_uniform(randomMax) + plusFactor )
    }
    
    // CreateEnemy function to spawn enemies
    func createEnemy(posX: CGFloat, posY:CGFloat, speed: CGFloat, isEnemy: Bool){
        let enemy = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "microbe.png")), color: .clear, size: CGSize(width: size.width*0.05, height: size.width*0.05))
        enemy.position = CGPoint(x: posX, y: posY)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width * (distanceBetweenObjects))    
        
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.friction = 0.0
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.restitution = 1.1
        enemy.physicsBody?.angularDamping = 0.0
        enemy.physicsBody?.categoryBitMask = Bitmasks.enemy
        enemy.physicsBody?.contactTestBitMask = Bitmasks.player
        enemy.physicsBody?.collisionBitMask = Bitmasks.player
        
        var dyComponent: CGFloat = 0
        var dxComponent: CGFloat = 0
        addChild(enemy)
        
        //If it is aid
        if(!isEnemy){
            enemy.physicsBody?.categoryBitMask = Bitmasks.aid
            enemy.physicsBody?.contactTestBitMask = Bitmasks.aid
            enemy.physicsBody?.collisionBitMask = Bitmasks.aid
            switch arc4random_uniform(4) {
            case 0:
                enemy.texture = SKTexture(image: #imageLiteral(resourceName: "syringe.png")) 
                aidObjectsPlus.append(enemy)
                break
            case 1:
                enemy.texture = SKTexture(image: #imageLiteral(resourceName: "pill.png"))
                aidObjectsPlus.append(enemy)
                break
            case 2:
                enemy.texture = SKTexture(image: #imageLiteral(resourceName: "smoking-symbol_1f6ac.png"))
                aidObjectsMinus.append(enemy)
                break
            case 3:
                enemy.texture = SKTexture(image: #imageLiteral(resourceName: "wine-glass_1f377.png"))
                aidObjectsMinus.append(enemy)
                break
            default:
                break 
            }
            dyComponent = (maxY * (randomize(randomMax: 100, plusFactor: 0) / 100)) - enemy.position.y
            dxComponent = (maxX * (randomize(randomMax: 100, plusFactor: 0) / 100)) - enemy.position.x
        }else{
            enemies.append(enemy)
            dyComponent = midY - enemy.position.y
            dxComponent = midX - enemy.position.x
        }
        
        enemy.physicsBody?.applyImpulse(CGVector(dx: dxComponent * speed, dy: dyComponent * speed ))
        
    }
    
    
    // Sound effects according to the situation
    func soundEffect (name: String, situation: UInt32){
        let path = Bundle.main.path(forResource: name, ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do{
            switch situation {
            case 0:
                //Shooting sound
                guard !gameOver else { return }
                shootEffect = try AVAudioPlayer(contentsOf: url)
                shootEffect?.play()
                shootEffect?.volume = 0.7
                break
            case 1:
                // Virus infecting sound
                guard !gameOver else { return }
                virusEffect = try AVAudioPlayer(contentsOf: url)
                virusEffect?.play()
                break
            case 2:
                // Aid Plus and True Answer sound
                aidPlusEffect = try AVAudioPlayer(contentsOf: url)
                aidPlusEffect?.play()
                aidPlusEffect?.volume = 0.7
                break
            case 3:
                // Aid Minus and Wrong Answer sound
                aidMinusEffect = try AVAudioPlayer(contentsOf: url)
                aidMinusEffect?.play()
                break
            default:
                break 
            }
            
        }catch{
            
        }
    }
    
    // Restart game (reload the scene)
    func restartGame(){
        backgroundMusic?.stop()
        let newScene = GameScene(size: self.size)
        let animation = SKTransition.fade(withDuration: 1.0)
        
        newScene.scaleMode = self.scaleMode
        self.view?.presentScene(newScene,transition: animation)
        
    }
    
    // Shows question section
    func questionTime (){
        gameOver = true
        player.texture = SKTexture(image: #imageLiteral(resourceName: "dizzy-face_1f635.png"))
        
        for enemy in enemies{
            enemy.removeFromParent()
        }
        for aid in aidObjectsPlus{
            aid.removeFromParent()
        }
        for aid in aidObjectsMinus{
            aid.removeFromParent()
        }
        
        questionLabel = SKLabelNode(text: Questions.q1)
        questionLabel.fontSize = 25.0
        questionLabel.position = CGPoint(x: midX, y: maxY * 0.6)
        questionLabel.zPosition = 5
        questionLabel.preferredMaxLayoutWidth = midX
        questionLabel.fontColor = .white
        addChild(questionLabel)
        
        
        trueLabel = SKLabelNode(text: "True")
        trueLabel.fontSize = 30.0
        trueLabel.position = CGPoint(x: midX * 0.7, y: maxY*0.3)
        trueLabel.zPosition = 0
        trueLabel.fontColor = .green
        addChild(trueLabel)
        
        trueShape = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "blank.png")), color: .clear, size: CGSize(width: size.width*0.08, height: size.width*0.08))
        trueShape.zPosition = 5
        trueShape.alpha = 1
        trueShape.position = CGPoint(x: midX * 0.7, y: maxY*0.3)
        addChild(trueShape)
        
        
        falseLabel = SKLabelNode(text: "False")
        falseLabel.fontSize = 30.0
        falseLabel.position = CGPoint(x: midX * 1.2, y: maxY*0.3)
        falseLabel.zPosition = 0
        falseLabel.fontColor = .red
        addChild(falseLabel)
        
        falseShape = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "blank.png")), color: .clear, size: CGSize(width: size.width*0.08, height: size.width*0.08))
        falseShape.zPosition = 5
        falseShape.alpha = 1
        falseShape.position = CGPoint(x: midX * 1.2, y: maxY*0.3)
        addChild(falseShape)
        
        // Getting questions from QuestionsAnswers class
        let QA = QuestionsAnswers()
        (questionArray,answerArray) = QA.getQAs()
        
        randomQuestion = Int(randomize(randomMax: UInt32(questionArray.count), plusFactor: 0))
        questionLabel.text = questionArray[randomQuestion]
        answerOfQuestion = answerArray[randomQuestion]
        
        
    }
    
    
    
    // Show answer of the question according to user's choice
    func answer( isCorrect: Bool){
        falseLabel.alpha = 0.0
        trueLabel.alpha = 0.0
        questionLabel.alpha = 0.0
        UserDefaults.standard.set(false, forKey: "isQuestion")
        
        let statementLabel = SKLabelNode(text: Questions.q1)
        statementLabel.fontSize = 80.0
        statementLabel.position = CGPoint(x: midX, y: maxY * 0.6)
        statementLabel.zPosition = 5
        statementLabel.fontColor = .white
        
        let statementLabel2 = SKLabelNode(text: Questions.q1)
        statementLabel2.fontSize = 60.0
        statementLabel2.position = CGPoint(x: midX, y: maxY * 0.45)
        statementLabel2.zPosition = 5
        statementLabel2.fontColor = .green
        
        // If it is correct
        if(isCorrect){
            soundEffect(name: "success.mp3", situation: 2)
            score += 50
            statementLabel.text = "Correct Answer!"
            statementLabel2.text = "+50 Score!"
            statementLabel.fontColor = .green
        }else{
            soundEffect(name: "fail2.mp3", situation: 3)
            statementLabel.text = "Wrong Answer! "
            statementLabel.fontColor = .red
            statementLabel2.text = ""
        }
        
        addChild(statementLabel)
        addChild(statementLabel2)
        
        
        run(SKAction.sequence([SKAction.wait(forDuration: 1.5),SKAction.run {
            statementLabel.removeFromParent()
            statementLabel2.removeFromParent()
            self.triggerGameOver()
            }])
        )
    }
    
    
    // Game Over function to show high score, reset and restart buttons
    func triggerGameOver(){
        gameOver = true
        player.texture = SKTexture(image: #imageLiteral(resourceName: "dizzy-face_1f635.png"))
        
        for enemy in enemies{
            enemy.removeFromParent()
        }
        for aid in aidObjectsPlus{
            aid.removeFromParent()
        }
        for aid in aidObjectsMinus{
            aid.removeFromParent()
        }
        
        
        scoreLabel.text = "Score: " + String(score)
        
        let gameOverLabel = SKLabelNode(text: "GAME OVER!")
        gameOverLabel.fontSize = 100.0
        gameOverLabel.position = CGPoint(x: midX, y: maxY * 0.7)
        gameOverLabel.zPosition = 5
        gameOverLabel.fontColor = .white
        addChild(gameOverLabel)
        
        
        let highScoreLabel = SKLabelNode(text: "High Score: " + String(highScore(sc: UInt32(score))))
        highScoreLabel.fontSize = 50.0
        highScoreLabel.position = CGPoint(x: midX, y: maxY*0.55)
        highScoreLabel.zPosition = 5
        highScoreLabel.fontColor = .white
        addChild(highScoreLabel)
        
        restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontSize = 40.0
        restartLabel.position = CGPoint(x: midX, y: maxY*0.2)
        restartLabel.zPosition = 0
        restartLabel.fontColor = .green
        addChild(restartLabel)
        
        restartShape = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "blank.png")), color: .clear, size: CGSize(width: size.width*0.1, height: size.width*0.1))
        restartShape.zPosition = 5
        restartShape.alpha = 1
        restartShape.position = CGPoint(x: midX, y: maxY*0.2)
        addChild(restartShape)
        
        
        resetLabel = SKLabelNode(text: "Reset")
        resetLabel.fontSize = 40.0
        resetLabel.position = CGPoint(x: midX, y: maxY*0.1)
        resetLabel.zPosition = 0
        resetLabel.fontColor = .orange
        addChild(resetLabel)
        
        resetShape = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "blank.png")), color: .clear, size: CGSize(width: size.width*0.1, height: size.width*0.1))
        resetShape.zPosition = 5
        resetShape.alpha = 1
        resetShape.position = CGPoint(x: midX, y: maxY*0.1)
        addChild(resetShape)
        
        
    }
    
    // Update High Score
    func highScore(sc: UInt32)-> UInt32{
        let defaults = UserDefaults.standard
        let hs = defaults.integer(forKey: "highscore")
        if(score > hs){
            defaults.set(sc, forKey: "highscore")
        }
        return UInt32(defaults.integer(forKey: "highscore"))
    }
    
    
    
}

