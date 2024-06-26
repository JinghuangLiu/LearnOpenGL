/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
  
  // MARK: - Properties
  var trackingStatus: String = ""
  var diceNodes: [SCNNode] = []
  var diceCount: Int = 5
  var diceStyle: Int = 0
  var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                  SCNVector3(-0.15, 0.00, 0.0),
                                  SCNVector3(0.15, 0.00, 0.0),
                                  SCNVector3(-0.15, 0.15, 0.12),
                                  SCNVector3(0.15, 0.15, 0.12)]
  
  // MARK: - Outlets
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction func styleButtonPressed(_ sender: Any) {
    diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  @IBAction func swipeUpGestureHandler(_ sender: Any) {
    // 1
    guard let frame = self.sceneView.session.currentFrame else { return }
    // 2
    for count in 0..<diceCount {
      throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                    offset: diceOffset[count])
    }
  }
  
  // MARK: - View Management
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initSceneView()
    self.initScene()
    self.initARSession()
    self.loadModels()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  // MARK: - Initialization
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    sceneView.debugOptions = [
      //ARSCNDebugOptions.showFeaturePoints,
      //ARSCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showBoundingBoxes,
      //SCNDebugOptions.showWireframe
    ]
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    sceneView.scene = scene
    //scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
    //scene.lightingEnvironment.intensity = 2
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.environmentTexturing = .automatic
    sceneView.session.run(config)
  }
  
  // MARK: - Load Models
  
  func loadModels() {
    // 1
    let diceScene = SCNScene(
      named: "PokerDice.scnassets/Models/DiceScene.scn")!
    // 2
    for count in 0..<5 {
      // 3
      diceNodes.append(diceScene.rootNode.childNode(
        withName: "dice\(count)",
        recursively: false)!)
    }
  }
  
  // MARK: - Helper Functions
  
  func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
    // 1
    let position = SCNVector3(transform.m41 + offset.x,
                              transform.m42 + offset.y,
                              transform.m43 + offset.z)
    // 2
    let diceNode = diceNodes[diceStyle].clone()
    diceNode.name = "dice"
    diceNode.position = position
    //3
    sceneView.scene.rootNode.addChildNode(diceNode)
    //diceCount -= 1
  }
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.statusLabel.text = self.trackingStatus
    }
  }
  
  
  // MARK: - Session State Management
  
  func session(_ session: ARSession,
               cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    // 1
    case .notAvailable:
      self.trackingStatus = "Tacking:  Not available!"
      break
    // 2
    case .normal:
      self.trackingStatus = ""
      break
    // 3
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
        break
      // 3.1
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features!"
        break
      // 3.2
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
        break
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizing..."
      @unknown default:
        self.trackingStatus = "Tracking: Unknown..."
      }
    }
  }
  
  // MARK: - Session Error Managent
  
  func session(_ session: ARSession,
               didFailWithError error: Error) {
    self.trackingStatus = "AR Session Failure: \(error)"
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session Was Interrupted!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session Interruption Ended"
  }
  
  // MARK: - Plane Management
  
}

