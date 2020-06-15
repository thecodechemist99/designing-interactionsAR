//
//  ViewController.swift
//  Designing Interactions
//
//  Created by Florian Beck on 09.06.20.
//  Copyright © 2020 Florian Beck. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ARKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var viewFinder: UIImageView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var pauseIcon: UIImageView!
    @IBOutlet weak var videoProgressBar: UIProgressView!
    @IBOutlet var sceneView: ARSCNView!
    
    let marker = [
        "00_crampton_smith",
        "01_1_engelbart",
        "01_2_card",
        "01_3_mott",
        "01_4_tesler",
        "02_1_atkinson",
        "02_2_bradley",
        "02_3_verplank",
        "02_4_ratzlaff",
        "03_1_ellenby",
        "03_2_hawkins",
        "03_3_keely",
        "03_4_haitani",
        "03_5_boyle",
        "04_1_liddle",
        "04_2_hunter",
        "04_3_sakai",
        "04_4_kelley",
        "04_5_mercer",
        "05_1_gordon",
        "05_2_boyle",
        "05_3_laurel",
        "05_4_wright",
        "06_1_natsuno",
        "06_2_downs_reason_lovlie",
        "06_3_samalionis",
        "07_1_winograd",
        "07_2_page_brin",
        "07_3_rogers",
        "07_4_podlaseck",
        "08_1_ishii",
        "08_2_bishop",
        "08_3_mountford",
        "08_4_gaver",
        "09_1_raby_dunne",
        "09_2_maeda",
        "09_3_rekimoto"
    ]
    
    var avPlayers = [String: AVPlayer]()
    var imageNodes : [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        for name in marker {
            avPlayers[name] = AVPlayer()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.avPlayers.forEach { key, value in
                if notification.description.contains(key) {
                    value.seek(to: CMTime.zero)
                }
            }
        }
        
        runARSession()
        
    }
    
    func runARSession() {
        let config = ARImageTrackingConfiguration()
        
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "marker", bundle: nil) else {
            return
        }
        
        config.trackingImages = refImages
        config.maximumNumberOfTrackedImages = 1
        
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLoc = touch?.location(in: self.view)
        
        let hits = sceneView.hitTest(touchLoc!, options: nil)
        
        if hits.count > 0 {
            let nodeName = hits[0].node.name
            for name in marker {
                if (nodeName?.contains(name))! {
                    if avPlayers[name]!.timeControlStatus == .playing {
                        avPlayers[name]!.pause()
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                            self.pauseIcon.alpha = 1.0
                        }, completion: nil)
                        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                            self.pauseIcon.alpha = 0.0
                        }, completion: nil)
                    } else {
                        for n in marker {
                            avPlayers[n]!.pause()
                        }
                        avPlayers[name]!.play()
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                            self.playIcon.alpha = 1.0
                        }, completion: nil)
                        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                            self.playIcon.alpha = 0.0
                        }, completion: nil)
                    }
                }
            }
        }
    }
}

extension ViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let _ = anchor as? ARImageAnchor {
                if renderer.isNode(node, insideFrustumOf: self.sceneView.pointOfView!) {
//                    if self.viewFinder.alpha == 1.0 {
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                            self.viewFinder.alpha = 0.0
                        }, completion: nil)
//                    }
                    if self.videoProgressBar.alpha == 0.0 {
                        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                            self.videoProgressBar.alpha = 1.0
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.imageNodes.forEach { node in
                if !renderer.isNode(node, insideFrustumOf: self.sceneView.pointOfView!) {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                            self.viewFinder.alpha = 1.0
                    }, completion: nil)
                    UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
                            self.videoProgressBar.alpha = 0.0;
                    }, completion: nil)
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imgAnchor = anchor as? ARImageAnchor {
            let imgName = imgAnchor.referenceImage.name
            
            for name in self.marker {
                if let fileName = imgName, fileName.contains(name) {
                    DispatchQueue.main.async {
                        guard let videoURL = URL(string: "https://designinginteractions.florian-beck.de/\(name).mp4") else {
                            return
                        }
//                          guard let path = Bundle.main.path(forResource: name, ofType: "mp4") else {
//                            return
//                        }
                        
//                        let videoURL = URL(fileURLWithPath: path)
                        let avPlayerItem = AVPlayerItem(url: videoURL)
                        self.avPlayers[name] = AVPlayer(playerItem: avPlayerItem)
                        for n in self.marker {
                            self.avPlayers[n]!.pause()
                        }
                        self.avPlayers[name]!.play()
                        self.avPlayers[name]!.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 50), queue: nil) { _ in
                            self.videoProgressBar.progress = (Float) (CMTimeGetSeconds(self.avPlayers[name]!.currentTime()) / avPlayerItem.duration.seconds)
                        }
                        
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                            self.viewFinder.alpha = 0.0
                            self.videoProgressBar.alpha = 1.0
                        }, completion: nil)
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                            self.playIcon.alpha = 1.0
                        }, completion: nil)
                        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                            self.playIcon.alpha = 0.0
                        }, completion: nil)
                        
                        let avMaterial = SCNMaterial()
                        avMaterial.diffuse.contents = self.avPlayers[name]!
                        
                        let videoPlane = SCNPlane(
                            width: imgAnchor.referenceImage.physicalSize.width,
                            height: imgAnchor.referenceImage.physicalSize.height)
                        videoPlane.materials = [avMaterial]
                        
                        let videoNode = SCNNode(geometry: videoPlane)
                        videoNode.name = name
                        videoNode.eulerAngles.x = -.pi / 2
                        node.addChildNode(videoNode)
                        
                        self.imageNodes.append(node)
                    }
                }
            }
        }
    }
}
