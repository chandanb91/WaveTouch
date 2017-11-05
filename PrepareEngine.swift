//
//  PrepareEngine.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 12/08/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//


import AVFoundation

class PrepareEngine: NSObject {
    
   static let sharedInstance = PrepareEngine()
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioUnitTimePitch: AVAudioUnitTimePitch!
    var audioUnitVarispeed: AVAudioUnitVarispeed!
    var audioUnitDelay: AVAudioUnitDelay!
    var audioUnitDistortion: AVAudioUnitDistortion!
    var receivedAudio: RecordedAudio!
    let vcInstance = ViewController()
    var playing: Bool {
        get {
            return audioPlayerNode != nil && audioPlayerNode.playing
        }
    }
    
//    func directoryURL() -> NSURL? {
//        let fileManager = NSFileManager.defaultManager()
//        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//        let documentDirectory = urls[0] as NSURL
//        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
//        
//        return soundURL
//    }
    override init() {
        super.init()
        
        do {
            audioEngine = AVAudioEngine()
            
            // Prepare AVAudioFile
            //let url = NSURL(string: NSBundle.mainBundle().pathForResource("sample", ofType: "mp3")!)
            audioFile = try AVAudioFile(forReading: vcInstance.directoryURL()!)
//                vcInstance.audioPathURL()
                
            
            // Prepare AVAudioPlayerNode
            audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attachNode(audioPlayerNode)
            
            // Prepare AVAudioUnitTimePitch
            audioUnitTimePitch = AVAudioUnitTimePitch()
            audioEngine.attachNode(audioUnitTimePitch)
            
            // Prepare AVAudioUnitVarispeed
            audioUnitVarispeed = AVAudioUnitVarispeed()
            audioEngine.attachNode(audioUnitVarispeed)
            
            // Prepare AVAudioUnitDelay
            audioUnitDelay = AVAudioUnitDelay()
            audioEngine.attachNode(audioUnitDelay)
            audioUnitDelay.wetDryMix = 0
            
            // Prepare AVAudioUnitDistortion
            audioUnitDistortion = AVAudioUnitDistortion()
            audioEngine.attachNode(audioUnitDistortion)
            audioUnitDistortion.wetDryMix = 0
            
            // Connect Nodes
            audioEngine.connect(audioPlayerNode, to: audioUnitTimePitch, format: audioFile.processingFormat)
            audioEngine.connect(audioUnitTimePitch, to: audioUnitVarispeed, format: audioFile.processingFormat)
            audioEngine.connect(audioUnitVarispeed, to: audioUnitDelay, format: audioFile.processingFormat)
            audioEngine.connect(audioUnitDelay, to: audioUnitDistortion, format: audioFile.processingFormat)
            audioEngine.connect(audioUnitDistortion, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
            
            // Start Engine
            audioEngine.prepare()
        } catch {
            print("AudioEnginePlayer initialize error.")
        }
    }
    
    func play() {
        try! audioEngine.start()
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: {
            self.play()
        });
        audioPlayerNode.play()
    }
    
    func pause() {
        audioEngine.pause()
        audioPlayerNode.pause()
    }
    
    func stop(){
        audioEngine.stop()
        audioEngine.reset()
    }
}