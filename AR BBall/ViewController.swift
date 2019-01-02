//
//  ViewController.swift
//  AR BBall
//
//  Created by David Ilenwabor on 31/12/2018.
//  Copyright © 2018 David Ilenwabor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var startGameBtn: UIButton!
    var isBoardPlaced : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(throwBall))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    @IBAction func startGame(_ sender: UIButton) {
        startGameBtn.isHidden = true
        
        
    }
    
    @objc func throwBall(gestureRecognizer : UITapGestureRecognizer){
        
        guard let sceneView = gestureRecognizer.view as? ARSCNView else{
            return
        }
        
        guard let centerPoint = self.sceneView.pointOfView?.transform else{
            return
        }
        
        if isBoardPlaced{
            
        } else{
            guard let basketBallScene = SCNScene(named: "art.scnassets/hoop.scn") else{
                print("Scene not found")
                return
            }
            guard let basketBallNode = basketBallScene.rootNode.childNode(withName: "backboard", recursively: false) else{
                print("couldnt find backboard node")
                return
            }
            
            
            
            //basketBallNode.position = getCameraPosition(centerPoint: centerPoint)
            sceneView.debugOptions = [.showWorldOrigin]
            basketBallNode.position = SCNVector3(0,0,-3)
            sceneView.scene.rootNode.addChildNode(basketBallNode)
            isBoardPlaced = true
        }
        
        
        
    }
    
    func getCameraPosition(centerPoint : SCNMatrix4)->SCNVector3{
        //let camMatrix = SCNMatrix4(sceneView.session.currentFrame!.camera.transform)
        let camOrientation = SCNVector3(-centerPoint.m31, -centerPoint.m32, -centerPoint.m33)
        let camLocation = SCNVector3(centerPoint.m41, centerPoint.m42, centerPoint.m43)
        
        return SCNVector3Make(camOrientation.x + camLocation.x, camLocation.y + camOrientation.y, camOrientation.z + camLocation.z)
    }
    
}
