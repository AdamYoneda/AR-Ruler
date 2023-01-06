//
//  ViewController.swift
//  AR Ruler
//
//  Created by Adam Yoneda on 2023/01/03.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチされた位置を取得する
        if let touchLocation = touches.first?.location(in: sceneView) {
            // タッチされた位置を、SceneKit view上の3D空間の位置を取得
            let results = sceneView.hitTest(touchLocation, options: nil)
            guard let result = results.first else { return }
            addDot(at: result)
        }
    }
    
    func addDot(at hitTestResult: SCNHitTestResult) {
        let dotGeometory = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometory.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometory)
        dotNode.position = hitTestResult.worldCoordinates
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(pow(end.position.x - start.position.x, 2) +
                            pow(end.position.y - start.position.y, 2) +
                            pow(end.position.z - start.position.z, 2)
        )
        print(abs(distance))
    }
    
}



//
//    guard let query = sceneView.raycastQuery(
//        from: touchLocation,
//        allowing: .existingPlaneInfinite,
//        alignment: .any
//    ) else { return }
//    let results = sceneView.session.raycast(query)
//    guard let hitTestResult = results.first else {
//        print("No surface found")
//        return
//    }
//    let anchor = ARAnchor(transform: hitTestResult.worldTransform)
//    sceneView.session.add(anchor: anchor)
