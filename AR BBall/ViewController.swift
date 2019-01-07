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

class ViewController: UIViewController, ARSCNViewDelegate , ARSessionDelegate{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var startGameBtn: UIButton!
    var isBoardPlaced : Bool = false
    var trackedCameraPositionTransform : SCNMatrix4?
    let configuration = ARWorldTrackingConfiguration()
    
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
        
        
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
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
            
            let basketBall = SCNNode(geometry: SCNSphere(radius: 0.15))
            basketBall.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "basketskin")
            basketBall.position = getCameraPosition(centerPoint: centerPoint)
            
            //let direction = SCNVector3(-centerPoint.m31, -centerPoint.m32, -centerPoint.m33)
            let physicsShape = SCNPhysicsShape(node: basketBall, options: nil)
            let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
            basketBall.physicsBody = physicsBody
            let position = getCameraPosition(centerPoint: centerPoint)
            basketBall.physicsBody?.applyForce(SCNVector3(position.x * 6, position.y * 6, position.z * 6), asImpulse: true)
            
            self.sceneView.scene.rootNode.addChildNode(basketBall)
        } else{
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateHierarchy { (node, stop) in
                node.removeFromParentNode()
            }
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            guard let basketBallScene = SCNScene(named: "art.scnassets/hoop.scn") else{
                print("Scene not found")
                return
            }
            guard let basketBallNode = basketBallScene.rootNode.childNode(withName: "backboard", recursively: false) else{
                print("couldnt find backboard node")
                return
            }

            let action = SCNAction.move(by: SCNVector3(-2, 0, 0), duration: 4)
            let rightAction = SCNAction.move(by: SCNVector3(2,0,0), duration: 4)
            let actionSequence = SCNAction.sequence([action, rightAction])
            let forever = SCNAction.repeatForever(actionSequence)
            //sceneView.debugOptions = [.showWorldOrigin]
            basketBallNode.runAction(forever)
            basketBallNode.position = SCNVector3(0,-0.2,-3)
            sceneView.scene.rootNode.addChildNode(basketBallNode)
            isBoardPlaced = true
//            let taplocation = gestureRecognizer.location(in: sceneView)
//            let hittest = sceneView.hitTest(taplocation, types: .existingPlaneUsingExtent)
//            if !hittest.isEmpty{
//                print("Touched a vertical surface")
//                self.addBackboardToView(hitTest: hittest.first!)
//
//            }
        }
        
    }
    
    
    func addBackboardToView(hitTest :ARHitTestResult){
//        guard let basketBallScene = SCNScene(named: "art.scnassets/hoop.scn") else{
//            print("Scene not found")
//            return
//        }
//        guard let basketBallNode = basketBallScene.rootNode.childNode(withName: "backboard", recursively: false) else{
//            print("couldnt find backboard node")
//            return
//        }
//
//        let hitTestTransformColumn = hitTest.worldTransform.columns.3
//
//        let action = SCNAction.move(by: SCNVector3(-2, 0, 0), duration: 4)
//        let rightAction = SCNAction.move(by: SCNVector3(2,0,0), duration: 4)
//        let actionSequence = SCNAction.sequence([action, rightAction])
//        let forever = SCNAction.repeatForever(actionSequence)
//        //sceneView.debugOptions = [.showWorldOrigin]
//        //let invisible
//        basketBallNode.runAction(forever)
//        basketBallNode.position = getCameraPosition(centerPoint: self.tr)
//        //basketBallNode.eulerAngles = SCNVector3(0, 0, 0)
//        sceneView.scene.rootNode.addChildNode(basketBallNode)
//        //isBoardPlaced = true
    }
    
    
    
    
    func getCameraPosition(centerPoint : SCNMatrix4)->SCNVector3{
        //let camMatrix = SCNMatrix4(sceneView.session.currentFrame!.camera.transform)
        let camOrientation = SCNVector3(-centerPoint.m31, -centerPoint.m32, -centerPoint.m33)
        let camLocation = SCNVector3(centerPoint.m41, centerPoint.m42, centerPoint.m43)
        
        return SCNVector3Make(camOrientation.x + camLocation.x, camLocation.y + camOrientation.y, camOrientation.z + camLocation.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor  = anchor as? ARPlaneAnchor else{
            return
        }
        
        print("vertical anchor added")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor  = anchor as? ARPlaneAnchor else{
            return
        }
        print("vertical anchor updated")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor  = anchor as? ARPlaneAnchor else{
            return
        }
        print("vertical anchor removed")
    }
}
