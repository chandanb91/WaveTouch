//
//  Distortion.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 15/08/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import Foundation
import UIKit

class AudioUnitDistortionViewController: UIViewController {
    
    var player = PrepareEngine.sharedInstance
    
    @IBOutlet weak var PlayPauseButton : UIButton!
    
    @IBOutlet weak var audioUnitDistortionPreGainLabel : UILabel!
    @IBOutlet weak var audioUnitDistortionPreGainSlider : UISlider!
    @IBOutlet weak var audioUnitDistortionWetDryMixLabel : UILabel!
    @IBOutlet weak var audioUnitDistortionWetDryMixSlider : UISlider!
    
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
        audioUnitDistortionPreGainSlider.value = -6
        audioUnitDistortionWetDryMixSlider.value = 0
        
        changeAudioUnitDistortionPreGain()
        changeAudioUnitDistortionWetDryMix()
    }
    
    @IBAction func changeAudioUnitDistortionPreGain() {
        player.audioUnitDistortion.preGain = audioUnitDistortionPreGainSlider.value
        audioUnitDistortionPreGainLabel.text = String(format: "%.1f", audioUnitDistortionPreGainSlider.value)
    }
    
    @IBAction func changeAudioUnitDistortionWetDryMix() {
        player.audioUnitDistortion.wetDryMix = audioUnitDistortionWetDryMixSlider.value
        audioUnitDistortionWetDryMixLabel.text = String(format: "%.1f", audioUnitDistortionWetDryMixSlider.value)
    }
}


