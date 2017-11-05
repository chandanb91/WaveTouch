//
//  Delay.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 15/08/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import Foundation
import UIKit


class AudioUnitDelayViewController: UIViewController {
    
    var player = PrepareEngine.sharedInstance
    
    @IBOutlet weak var PlayPauseButton : UIButton!
    
    @IBOutlet weak var audioUnitDelayDelayTimeLabel : UILabel!
    @IBOutlet weak var audioUnitDelayDelayTimeSlider : UISlider!
    @IBOutlet weak var audioUnitDelayFeedbackLabel : UILabel!
    @IBOutlet weak var audioUnitDelayFeedbackSlider : UISlider!
    @IBOutlet weak var audioUnitDelayLowPassCutoffLabel : UILabel!
    @IBOutlet weak var audioUnitDelayLowPassCutoffSlider : UISlider!
    @IBOutlet weak var audioUnitDelayWetDryMixLabel : UILabel!
    @IBOutlet weak var audioUnitDelayWetDryMixSlider : UISlider!
    
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
    
    @IBAction func resetDefaultValue() {
        audioUnitDelayDelayTimeSlider.value = 1.0
        audioUnitDelayFeedbackSlider.value = 50
        audioUnitDelayLowPassCutoffSlider.value = 15000
        audioUnitDelayWetDryMixSlider.value = 0
        
        changeAudioUnitDelayDelayTime()
        changeAudioUnitDelayFeedback()
        changeAudioUnitDelayLowPassCutoff()
        changeAudioUnitDelayWetDryMix()
    }
    
    
    
    @IBAction func changeAudioUnitDelayDelayTime() {
        player.audioUnitDelay.delayTime = Double(audioUnitDelayDelayTimeSlider.value)
        audioUnitDelayDelayTimeLabel.text = String(format: "%.1f", audioUnitDelayDelayTimeSlider.value)
    }
    
    @IBAction func changeAudioUnitDelayFeedback() {
        player.audioUnitDelay.feedback = audioUnitDelayFeedbackSlider.value
        audioUnitDelayFeedbackLabel.text = String(format: "%.1f", audioUnitDelayFeedbackSlider.value)
    }
    
    @IBAction func changeAudioUnitDelayLowPassCutoff() {
        player.audioUnitDelay.lowPassCutoff = audioUnitDelayLowPassCutoffSlider.value
        audioUnitDelayLowPassCutoffLabel.text = String(format: "%.1f", audioUnitDelayLowPassCutoffSlider.value)
    }
    
    @IBAction func changeAudioUnitDelayWetDryMix() {
        player.audioUnitDelay.wetDryMix = audioUnitDelayWetDryMixSlider.value
        audioUnitDelayWetDryMixLabel.text = String(format: "%.1f", audioUnitDelayWetDryMixSlider.value)
    }
}

