//
//  GameViewController.swift
//  SkyBattle
//
//  Created by Петр Блинов on 19.02.2021.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    // Plane speed (duration of the plane animation)
    var duration: TimeInterval = 10
    
    /// Put the label on the screen to show the score
    let scoreLabel = UILabel()
    
    /// Create the score to count the number of killed planes
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    /// The ship which is present on the sene
    var ship: SCNNode?
    
    
    
    func addShip() {
        
        // Get a scene with the ship (this scene we shall not use)
        let tempScene = SCNScene(named: "art.scnassets/ship.scn")!

        // Get the ship from the scene
        ship = tempScene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // Set coordinates for ship
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -88

        ship?.position = SCNVector3(x, y, z)
        
        ship?.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        
        
        // MARK: GAME OVER
        
        // Animate the ship - to fly from far to us
        ship?.runAction(SCNAction.move(to: SCNVector3(), duration: duration)) {
            DispatchQueue.main.async {
                self.scoreLabel.text = "GAME OVER\nFinal score: \(self.score)"
            }
            self.ship?.removeFromParentNode()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.duration = 10
                self.score = 0
                self.scoreLabel.text = "NEW GAME STARTED\nScore: \(self.score)"
                self.addShip()
            }
        }
        
        //Get the scene (which we use)
        let scnView = self.view as! SCNView
        
        // Add the ship th out scene
        if let ship = ship {
            scnView.scene?.rootNode.addChildNode(ship)
        }
    }

    
    func setUpUI() {
        
        score = 0
        
        scoreLabel.font = UIFont.systemFont(ofSize: 15)
        scoreLabel.frame = CGRect(x: 0, y: view.frame.height - 85, width: view.frame.width, height: 50)
        scoreLabel.numberOfLines = 2
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)

        view.addSubview(scoreLabel)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.magenta
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        ship.removeFromParentNode()
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        //Add the ship to the scene
        addShip()
        
        // Set up UI
        setUpUI()
        self.scoreLabel.text = "HIT THE ENEMY\nScore: \(self.score)"

    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped (получаем двумерные координаты точки, на которую тапнули на экране)
        let p = gestureRecognize.location(in: scnView)
        
        //передаем p (двумерные координаты нажатой точки) в функц hitTest, которая возвращает массив, в котором каждое значение показывает с каким объектом мы пересеклись. То есть если ни с чем не пересеклись, то массив пустой
        let hitResults = scnView.hitTest(p, options: [:])
        
        // check that we clicked on at least one object (то есть если хоть с чем-то пересеклись)
        if hitResults.count > 0 {
            
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material (получаем оболочку объекта с которым пересеклись)
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            
            
            // MARK: KILL THE PLANE
            SCNTransaction.completionBlock = {
                self.duration *= 0.94
                self.score += 1
                self.ship?.removeFromParentNode()
                self.addShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
