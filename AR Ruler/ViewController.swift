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
    var textNode = SCNNode()
    
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
        // 配列dotNodes内に2つ以上dotNodeがある場合、全て削除する
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()  // scneViewから3D nodeを取り除く
            }
            dotNodes = []   // dotNodesを空にする
        }
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
        updateText(text:"\(abs(distance))", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode() // textNodeをsceneから削除
        let textGeometory = SCNText(string: text, extrusionDepth: 1.0)
        textGeometory.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometory)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
