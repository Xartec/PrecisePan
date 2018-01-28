//
//  GameViewController.swift
//  PrecisePan
//
//  Created by Admin on 1/28/18.
//  Copyright © 2018 Xartec. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var ship = SCNNode()
    var dragginShip = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 34, z: 60)
        cameraNode.rotation = SCNVector4(-1, 0, 0, 0.714) //persp
        
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
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        ship.position = SCNVector3(0, 1.5, 0)
        
        // animate the 3d object
       // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        scnView.preferredFramesPerSecond = 120;
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
       // scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        let XZPlaneGeo = SCNPlane(width: 100, height: 100)
        let XZPlaneNode = SCNNode(geometry: XZPlaneGeo)
        XZPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        XZPlaneNode.name = "XZPlane"
        XZPlaneNode.rotation = SCNVector4(-1, 0, 0, Float.pi / 2)
        //XZPlaneNode.isHidden = true
        scene.rootNode.addChildNode(XZPlaneNode)
        
    }
    
    @objc
    func handlePan(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        if gestureRecognize.state == .began {
            // check what nodes are tapped
            let p = gestureRecognize.location(in: scnView)
            let hitResults = scnView.hitTest(p, options: [SCNHitTestOption.searchMode: 1, SCNHitTestOption.ignoreHiddenNodes: false])
            
            if hitResults.count > 0 {
                // check if the XZPlane is in the hitresults
                for result in hitResults {
                    if result.node.name == "XZPlane" {
                        //NSLog("Local Coordinates on XZPlane %f, %f, %f", result.localCoordinates.x, result.localCoordinates.y, result.localCoordinates.z)
                        
                        //NSLog("World Coordinates on XZPlane %f, %f, %f", result.worldCoordinates.x, result.worldCoordinates.y, result.worldCoordinates.z)
                        ship.position = result.worldCoordinates
                        ship.position.y += 1.5
                        return;
                    }
                }
            }
        } else if gestureRecognize.state == .changed {
         
            // check what nodes are tapped
            let p = gestureRecognize.location(in: scnView)
            let hitResults = scnView.hitTest(p, options: [SCNHitTestOption.searchMode: 1, SCNHitTestOption.ignoreHiddenNodes: false])
            
            if hitResults.count > 0 {
                // check if the XZPlane is in the hitresults
                
                for result in hitResults {
                    if result.node.name == "XZPlane" {
                        //NSLog("Local Coordinates on XZPlane %f, %f, %f", result.localCoordinates.x, result.localCoordinates.y, result.localCoordinates.z)
                        
                        //NSLog("World Coordinates on XZPlane %f, %f, %f", result.worldCoordinates.x, result.worldCoordinates.y, result.worldCoordinates.z)
                        
                        ship.position = result.worldCoordinates
                        ship.position.y += 1.5
                        return;
                    }
                }
            }
            
        }
        
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
