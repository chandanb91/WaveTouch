//
//  CustomSegue.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 12/08/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import UIKit
import AVFoundation

//class CustomSegue: UIStoryboardSegue {
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

class VaryspeedViewController: UIViewController {
    
    var player = PrepareEngine.sharedInstance
    
    @IBOutlet weak var PlayPauseButton : UIButton!
    
    @IBOutlet weak var audioUnitVarispeedRateLabel : UILabel!
    @IBOutlet weak var audioUnitVarispeedRateSlider : UISlider!
    
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
        //PlayPauseButton.setTitle("Play", forState: .Normal)
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
    
    @IBAction func resetDefaultValue() {
        audioUnitVarispeedRateSlider.value = 1.0
        
        changeAudioUnitVarispeedRate()
    }
    
    @IBAction func changeAudioUnitVarispeedRate() {
        player.audioUnitVarispeed.rate = audioUnitVarispeedRateSlider.value
        audioUnitVarispeedRateLabel.text = String(format: "%.1f", audioUnitVarispeedRateSlider.value)
    }
}



//class blah{
//    var playerNode: AVAudioPlayerNode!
//    var mixer:AVAudioMixerNode!
//    var engine: AVAudioEngine!
//    var EQNode:AVAudioUnitEQ!
//    func addEQ() {
//        EQNode = AVAudioUnitEQ(numberOfBands: 2)
//        engine.attachNode(EQNode)
//        
//        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
//        filterParams.filterType = .HighPass
//        filterParams.frequency = 80.0
//        
//        filterParams = EQNode.bands[1] as AVAudioUnitEQFilterParameters
//        filterParams.filterType = .Parametric
//        filterParams.frequency = 500.0
//        filterParams.bandwidth = 2.0
//        filterParams.gain = 4.0
//        
//        let format = mixer.outputFormatForBus(0)
//        engine.connect(playerNode, to: EQNode, format: format )
//        engine.connect(EQNode, to: engine.mainMixerNode, format: format)
//    }
//}