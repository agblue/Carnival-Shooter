//
//  GameScene.swift
//  Carnival Shooter
//
//  Created by Danny Tsang on 7/15/21.
//

import SpriteKit

class GameScene: SKScene {
    
    enum enemyType: String, CaseIterable {
        case bomb
        case duck
        case boat
        case target
    }
    
    enum dropType: String, CaseIterable {
        case bomb
        case missile
        case target
        case duck
    }
    
    enum bounds: CGFloat {
        case top = 868
        case topOver = 869
        case right = 1124
        case rightOver = 1125
        case bottom = -100
        case bottomOver = -101
    }
    
    enum row: CGFloat {
        case number1 = 600
        case number2 = 400
        case number3 = 200
    }
    
    var gameTimer: Timer!
    var enemyNames = [String]()
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            if score > highScore {
                highScore = score
                let defaults = UserDefaults.standard
                defaults.setValue(highScore, forKey: "highScore")
            }
        }
    }
    
    var highScoreLabel: SKLabelNode!
    var highScore = 0 {
        didSet {
            highScoreLabel.text = "High Score: \(highScore)"
        }
    }

    var titleLabel: SKLabelNode!
    var startGameLabel: SKLabelNode!
    var timeRemainingLabel: SKLabelNode!
    var timeRemaining = 0 {
        didSet {
            timeRemainingLabel.text = "\(timeRemaining)"
        }
    }
    
    var gameStarted = false {
        didSet {
            if gameStarted == true {
                titleLabel.isHidden = true
                startGameLabel.isHidden = true
                scoreLabel.isHidden = false
                highScoreLabel.isHidden = false
                timeRemainingLabel.isHidden = false
            } else {
//                titleLabel.isHidden = false
                startGameLabel.isHidden = false
//                scoreLabel.isHidden = true
//                highScoreLabel.isHidden = true
//                timeRemainingLabel.isHidden = true
            }
        }
    }
    
    var streakLabel: SKLabelNode!
    var streakBonus = 0
    var streak = 0 {
        didSet {
            if streak > 1 {
                streakLabel.isHidden = false
                streakLabel.text = "Streak: \(streak)"
            } else {
                streakLabel.isHidden = true
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -2
        background.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        background.blendMode = .replace
        addChild(background)
        
        titleLabel = SKLabelNode(text: "Carnival Shooter")
        titleLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 100)
        titleLabel.zPosition = 5
        titleLabel.blendMode = .replace
        titleLabel.fontSize = 96
        titleLabel.fontName = "Chalkduster"
        addChild(titleLabel)
        
        startGameLabel = SKLabelNode(text: "Start Game")
        startGameLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 175)
        startGameLabel.zPosition = 5
        startGameLabel.blendMode = .replace
        startGameLabel.fontSize = 64
        startGameLabel.fontName = "Chalkduster"
        addChild(startGameLabel)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 50, y: self.frame.height - 50)
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 32
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.isHidden = true
        addChild(scoreLabel)

        streakLabel = SKLabelNode(text: "Streak: 0")
        streakLabel.position = CGPoint(x: 50, y: self.frame.height - 100)
        streakLabel.zPosition = 5
        streakLabel.fontSize = 32
        streakLabel.horizontalAlignmentMode = .left
        streakLabel.fontName = "Chalkduster"
        streakLabel.isHidden = true
        addChild(streakLabel)
        
        highScoreLabel = SKLabelNode(text: "High Score: 0")
        highScoreLabel.position = CGPoint(x: self.frame.width - 50, y: self.frame.height - 50)
        highScoreLabel.zPosition = 5
        highScoreLabel.fontSize = 32
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Chalkduster"
        highScoreLabel.isHidden = true
        addChild(highScoreLabel)
        
        timeRemainingLabel = SKLabelNode(text: "0")
        timeRemainingLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 50)
        timeRemainingLabel.zPosition = 5
        timeRemainingLabel.fontSize = 32
        timeRemainingLabel.horizontalAlignmentMode = .center
        timeRemainingLabel.fontName = "Chalkduster"
        timeRemainingLabel.isHidden = true
        addChild(timeRemainingLabel)
        
        addWaves()

        buildEnemyNames()
        loadHighScore()
        gameStarted = false
    }

    func startGame() {
        gameStarted = true
        score = 0
        timeRemaining = 60
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(executeTimer), userInfo: nil, repeats: true)
    }
    
    func gameOver () {
        gameStarted = false
        gameTimer.invalidate()
    }
    
    func addWaves() {
        
        for i in stride(from: bounds.bottom.rawValue, through: bounds.right.rawValue, by: 95) {
           
            let wave = SKSpriteNode(imageNamed: "waveRight")
            wave.position = CGPoint (x: i, y: row.number1.rawValue - 60)
            wave.zPosition = 1
            addChild(wave)

            let wave2 = SKSpriteNode(imageNamed: "waveLeft")
            wave2.position = CGPoint (x: i, y: row.number2.rawValue - 60)
            wave2.zPosition = 1
            addChild(wave2)

            let wave3 = SKSpriteNode(imageNamed: "waveRight")
            wave3.position = CGPoint (x: i, y: row.number3.rawValue - 60)
            wave3.zPosition = 1
            addChild(wave3)
            
            let waveUp = SKAction.moveBy(x: 16, y: 25, duration: 0.5)
            let waveDown = SKAction.moveBy(x: 16, y: -25, duration: 0.5)
            let waveBack = SKAction.moveBy(x: -32, y: 0, duration: 0.5)
            let waveSequence = SKAction.sequence([waveUp, waveDown, waveBack])
            let waveRepeat = SKAction.repeatForever(waveSequence)

            let waveUp2 = SKAction.moveBy(x: -16, y: 32, duration: 0.5)
            let waveDown2 = SKAction.moveBy(x: -16, y: -32, duration: 0.5)
            let waveBack2 = SKAction.moveBy(x: 32, y: 0, duration: 0.5)
            let waveSequence2 = SKAction.sequence([waveUp2, waveDown2, waveBack2])
            let waveRepeat2 = SKAction.repeatForever(waveSequence2)

            wave.run(waveRepeat)
            wave2.run(waveRepeat2)
            wave3.run(waveRepeat)
        }
        
        let shelf = SKSpriteNode(color: .brown, size: CGSize(width: self.frame.width, height: 30))
        shelf.position = CGPoint(x: self.frame.width/2, y: row.number1.rawValue - 90)
        shelf.zPosition = 2
        shelf.blendMode = .replace
        addChild(shelf)

        let shelf2 = SKSpriteNode(color: .brown, size: CGSize(width: self.frame.width, height: 30))
        shelf2.position = CGPoint(x: self.frame.width/2, y: row.number2.rawValue - 90)
        shelf2.zPosition = 2
        shelf2.blendMode = .replace
        addChild(shelf2)

        let shelf3 = SKSpriteNode(color: .brown, size: CGSize(width: self.frame.width, height: 30))
        shelf3.position = CGPoint(x: self.frame.width/2, y: row.number3.rawValue - 90)
        shelf3.zPosition = 2
        shelf3.blendMode = .replace
        addChild(shelf3)

        
    }
    
    func buildEnemyNames() {
        let enemyTypes = enemyType.allCases
        
        for enemy in enemyTypes {
            enemyNames.append(enemy.rawValue)
        }
    }
    
    func loadHighScore() {
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
    }
    
    @objc func executeTimer() {
        timeRemaining -= 1
        if timeRemaining <= 0 {
            gameOver()
            return
        }
        addEnemy()
    }
    
    func addEnemy() {
        // Add an enemy crossing line one going from left to right.
        
        
        let enemy1Name = getEnemyType()
        let enemy1 = SKSpriteNode(imageNamed:enemy1Name)
        enemy1.position = CGPoint(x: bounds.bottom.rawValue, y: row.number1.rawValue)
        enemy1.name = enemy1Name
        addChild(enemy1)
        
        let bounceLeft = SKAction.rotate(byAngle: 1, duration: 0.25)
        let bounceRight = SKAction.rotate(byAngle: -1, duration: 0.25)
        let bounceSequence = SKAction.sequence([bounceLeft, bounceRight, bounceRight, bounceLeft])
        let repeatSequence = SKAction.repeatForever(bounceSequence)
        let moveRight = SKAction.moveTo(x: bounds.rightOver.rawValue, duration: 3)
        let row1Group = SKAction.group([repeatSequence, moveRight])
        enemy1.run(row1Group)
        
        let enemy2Name = getEnemyType()
        let enemy2 = SKSpriteNode(imageNamed:enemy2Name)
        enemy2.position = CGPoint(x: bounds.right.rawValue, y: row.number2.rawValue)
        enemy2.name = enemy2Name
        addChild(enemy2)
        
        let rotate2 = SKAction.rotate(byAngle: 1, duration: 1)
        let repeat2 = SKAction.repeatForever(rotate2)
        let move2 = SKAction.moveTo(x: bounds.bottomOver.rawValue, duration: 6)
        let group2 = SKAction.group([repeat2, move2])
        enemy2.run(group2)
        
        let enemy3Name = getEnemyType()
        let enemy3 = SKSpriteNode(imageNamed:enemy3Name)
        enemy3.position = CGPoint(x: bounds.bottom.rawValue, y: row.number3.rawValue)
        enemy3.name = enemy3Name
        addChild(enemy3)
            
        let move3 = SKAction.moveBy(x: 200, y: 0, duration: 0.25)
        let wait3 = SKAction.wait(forDuration: 0.25)
        let jumpUp3 = SKAction.moveBy(x: 0, y: 50, duration: 0.25)
        let jumpDown3 = SKAction.moveBy(x: 0, y: -50, duration: 0.25)
        let sequence3 = SKAction.sequence([move3, wait3, jumpUp3, jumpDown3])
        let repeat3 = SKAction.repeatForever(sequence3)
        enemy3.run(repeat3)
        
        // Random Drop
        addRandomDrop()
        
    }
    
    func addRandomDrop() {
        let random = Int.random(in: 1 ... 3)
        if random == 3 {
            let enemyName = getEnemyType()
            let drop = SKSpriteNode(imageNamed: enemyName)
            
            let randomX = Int.random(in: 100 ... 800)
            drop.position = CGPoint(x: CGFloat(randomX), y: bounds.top.rawValue)
            drop.zPosition = 3
            drop.name = enemyName
            addChild(drop)
            
            // Animate drop.
            let bounceLeft = SKAction.rotate(byAngle: 1, duration: 0.25)
            let bounceRight = SKAction.rotate(byAngle: -1, duration: 0.25)
            let bounceSequence = SKAction.sequence([bounceLeft, bounceRight, bounceRight, bounceLeft])
            let repeatSequence = SKAction.repeatForever(bounceSequence)

            let dropAction = SKAction.moveTo(y: bounds.bottomOver.rawValue, duration: Double.random(in: 1 ... 2))
            let group = SKAction.group([repeatSequence, dropAction])
            drop.run(group)
        }
    }
    
    
    func getEnemyType() -> String {
        let enemyTypes = enemyType.allCases
        guard let enemy = enemyTypes.randomElement() else { return "target" }
        return enemy.rawValue
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Check for nodes going off the screen.
        
        guard let nodes = scene?.children else { return }
        
        for node in nodes {
            if node.position.x < bounds.bottomOver.rawValue || node.position.x > bounds.rightOver.rawValue || node.position.y < bounds.bottomOver.rawValue || node.position.y > bounds.topOver.rawValue {
                node.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        // Add blast
        let blast = SKSpriteNode(imageNamed: "blast")
        blast.position = location
        blast.zPosition = 4
        blast.zRotation = CGFloat.random(in: 0 ... 5)
        addChild(blast)
        
        // Animate out.
        let fadeout = SKAction.fadeOut(withDuration: 0.25)
        let sequence = SKAction.sequence([fadeout, .removeFromParent()])
        blast.run(sequence)

        if gameStarted == false {
            if nodes.contains(startGameLabel) {
                startGame()
            }
            return
        } else {
            // Check for hit.
            var foundHit = false
            for node in nodes {
                if let name = node.name {
                    if enemyNames.contains(name) {
                        let scaleDown = SKAction.scaleY(to: 0.25, duration: 0.25)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
                        let animateGroup = SKAction.group([scaleDown, fadeOut])
                        let removeNode = SKAction.removeFromParent()
                        let sequence = SKAction.sequence([animateGroup, removeNode])
                        
                        node.run(sequence)
                        
                        switch name {
                        case enemyType.boat.rawValue:
                            score += 5 + streakBonus
                            streakBonus += 5
                            streak += 1
                            foundHit = true
                        case enemyType.duck.rawValue:
                            score += 3 + streakBonus
                            streakBonus += 3
                            streak += 1
                            foundHit = true
                        case enemyType.target.rawValue:
                            score += 1 + streakBonus
                            streakBonus += 1
                            streak += 1
                            foundHit = true
                        case enemyType.bomb.rawValue:
                            score -= 5
                            streakBonus = 0
                            streak = 0
                            foundHit = true
                        default:
                            streakBonus = 0
                            streak = 0
                            break
                        }
                    }
                }
            }
            if foundHit == false {
                streakBonus = 0
                streak = 0
            }
        }
    }
}
