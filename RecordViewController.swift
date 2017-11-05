//
//  FirstViewController.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 05/09/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var audioFile: AVAudioFile!
    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
                      AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
                      AVNumberOfChannelsKey : NSNumber(int: 1),
                      AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]

    @IBOutlet weak var isRecordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        isRecordingLabel.hidden = true
        stopButton.hidden = true
        
    }
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        
        return soundURL
    }

    @IBAction func recordAudio(sender: AnyObject) {
    
        
//        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) [0] as String
//        let currentDateTime = NSDate()
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "ddMMyyyy-HHmmss"
//        let recordingName = formatter.stringFromDate(currentDateTime)+".m4a"
//        let pathArray = [dirPath,recordingName]
//        let filePath = NSURL.fileURLWithPathComponents(pathArray)
//        print(filePath)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            try audioRecorder = AVAudioRecorder(URL: self.directoryURL()!, settings: recordSettings)
        } catch {
            print("oops \(error)")
        }
        
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        
        if !audioRecorder.recording {
            stopButton.hidden = false
            isRecordingLabel.hidden = false
            //let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                
            } catch {
                print(error)
            }
        }
    }

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url)
            self.performSegueWithIdentifier("passAudio", sender: recordedAudio)
            
           audioFile = try? AVAudioFile(forReading: recorder.url)
            
        }
        else{
            print("Recording not Successful")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "passAudio") {
        let vc:ViewController = segue.destinationViewController as! ViewController
        let recordedData = sender as! RecordedAudio
        vc.receivedAudio = recordedData
        }
    }
    
//    func showNextController() {
//        let destination = PrepareEngine(nibName: "SecondController", bundle: NSBundle.mainBundle())
//        destination.myInformation = self.myInformation
//        self.showViewController(destination, sender: self)
//    }
    @IBAction func stopAudio(sender: AnyObject) {
        isRecordingLabel.hidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
}
