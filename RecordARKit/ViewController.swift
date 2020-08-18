//
//  ViewController.swift
//  RecordARKit
//
//  Created by zeynep tokcan on 18.08.2020.
//  Copyright © 2020 zeynep tokcan. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import ARVideoKit

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    var recorder:RecordAR?
    
    var recorderButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Record", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 110, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*0.90)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.tag = 0
        return btn
    }()
    
    // Pause UIButton. This button will pause a video recording.
    var pauseButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Pause", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width*0.15, y: UIScreen.main.bounds.height*0.90)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.alpha = 0.3
        btn.isEnabled = false
        return btn
    }()
    
    var gifButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width*0.85, y: UIScreen.main.bounds.height*0.90)
        btn.layer.cornerRadius = btn.bounds.height/2
        return btn
    }()
    var randoMoji: String {
        let emojis = ["👾", "🤓", "🔥", "😜", "😇", "🤣", "🤗", "🧐", "🛰", "🚀"]
        return emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(recorderButton)
        self.view.addSubview(pauseButton)
        self.view.addSubview(gifButton)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
            recorder = RecordAR(ARSpriteKit: sceneView)
            recorder?.inputViewOrientations = [.portrait, .landscapeLeft, .landscapeRight]
        }
        
        recorderButton.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseAction(sender:)), for: .touchUpInside)
        gifButton.addTarget(self, action: #selector(gifAction(sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
        recorder?.prepare(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        recorder?.rest()
    }
    
    @objc func recorderAction(sender:UIButton) {
        
        if recorder?.status == .readyToRecord {
            // Start recording
            recorder?.record()
            
            // Change button title
            sender.setTitle("Stop", for: .normal)
            sender.setTitleColor(.red, for: .normal)
            
            // Enable Pause button
            pauseButton.alpha = 1
            pauseButton.isEnabled = true
            
            // Disable GIF button
            gifButton.alpha = 0.3
            gifButton.isEnabled = false
        }else if recorder?.status == .recording || recorder?.status == .paused {
            // Stop recording and export video to camera roll
            recorder?.stopAndExport()
            
            // Change button title
            sender.setTitle("Record", for: .normal)
            sender.setTitleColor(.black, for: .normal)
            
            // Enable GIF button
            gifButton.alpha = 1
            gifButton.isEnabled = true
            
            // Disable Pause button
            pauseButton.alpha = 0.3
            pauseButton.isEnabled = false
        }
        
    }
    // Pause and resume method
    @objc func pauseAction(sender:UIButton) {
        if recorder?.status == .recording {
            // Pause recording
            recorder?.pause()
            
            // Change button title
            sender.setTitle("Resume", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else if recorder?.status == .paused {
            // Resume recording
            recorder?.record()
            
            // Change button title
            sender.setTitle("Pause", for: .normal)
            sender.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc func gifAction(sender:UIButton) {
        self.gifButton.isEnabled = false
        self.gifButton.alpha = 0.3
        self.recorderButton.isEnabled = false
        self.recorderButton.alpha = 0.3
        
        recorder?.gif(forDuration: 1.5, export: true) { _, _, _ , exported in
            if exported {
                DispatchQueue.main.sync {
                    self.gifButton.isEnabled = true
                    self.gifButton.alpha = 1.0
                    self.recorderButton.isEnabled = true
                    self.recorderButton.alpha = 1.0
                }
            }
        }
    }
    
    // MARK: - ARSKViewDelegate
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: randoMoji)
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        
        return labelNode;
    
        
    }
    
}
