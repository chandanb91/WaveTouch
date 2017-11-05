//
//  TimePitch.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 15/08/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import UIKit

//class CustomSeguePitch: UIStoryboardSegue {
//    
//    override func perform()
//    {
//        let sourceVC = self.sourceViewController
//        let destinationVC = self.destinationViewController
//        
//        sourceVC.view.addSubview(destinationVC.view)
//        
//        destinationVC.view.transform = CGAffineTransformMakeScale(0.05, 0.05)
//        
//        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
//            
//            destinationVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
//            
//        }) { (finished) -> Void in
//            
//            destinationVC.view.removeFromSuperview()
//            
//            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.001 * Double(NSEC_PER_SEC)))
//            
//            dispatch_after(time, dispatch_get_main_queue()) {
//                
//                sourceVC.presentViewController(destinationVC, animated: false, completion: nil)
//                
//            }
//        }
//    }
//}


class TimePitchViewController: UIViewController {
    
    var player = PrepareEngine.sharedInstance
    
    @IBOutlet weak var PlayPauseButton : UIButton!
    
    @IBOutlet weak var audioUnitTimePitchOverlapLabel : UILabel!
    @IBOutlet weak var audioUnitTimePitchOverlapSlider : UISlider!
    @IBOutlet weak var audioUnitTimePitchPitchLabel : UILabel!
    @IBOutlet weak var audioUnitTimePitchPitchSlider : UISlider!
    @IBOutlet weak var audioUnitTimePitchRateLabel : UILabel!
    @IBOutlet weak var audioUnitTimePitchRateSlider : UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetDefaultValue()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if player.playing{
            player.stop()
            //updateView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateView() {
        if player.playing {
            PlayPauseButton.setTitle("Pause", forState: .Normal)
        } else {
            PlayPauseButton.setTitle("Play", forState: .Normal)
        }
    }
    
    @IBAction func playPauseAction() {
        if player.playing {
            player.pause()
        } else {
            player.play()
        }
        updateView()
    }
    
//    @IBAction func unwindToMain(sender: AnyObject) {
//        if player.playing{
//            player.stop()
//        }
//        dismissViewControllerAnimated(true, completion: nil)
//        
//
//    }
    
    @IBAction func resetDefaultValue() {
        audioUnitTimePitchOverlapSlider.value = 8.0
        audioUnitTimePitchPitchSlider.value = 1.0
        audioUnitTimePitchRateSlider.value = 1.0
        
        changeAudioUnitTimePitchOverlap()
        changeAudioUnitTimePitchPitch()
        changeAudioUnitTimePitchRate()
    }
    
    @IBAction func changeAudioUnitTimePitchOverlap() {
        player.audioUnitTimePitch.overlap = audioUnitTimePitchOverlapSlider.value
        audioUnitTimePitchOverlapLabel.text = String(format: "%.1f", audioUnitTimePitchOverlapSlider.value)
    }
    
    @IBAction func changeAudioUnitTimePitchPitch() {
        player.audioUnitTimePitch.pitch = audioUnitTimePitchPitchSlider.value
        audioUnitTimePitchPitchLabel.text = String(format: "%.1f", audioUnitTimePitchPitchSlider.value)
    }
    
    @IBAction func changeAudioUnitTimePitchRate() {
        player.audioUnitTimePitch.rate = audioUnitTimePitchRateSlider.value
        audioUnitTimePitchRateLabel.text = String(format: "%.1f", audioUnitTimePitchRateSlider.value)
    }
}

