//
//  RecordedAudio.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 13/08/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
   
    // Constructor with initializers
    init(filePathUrl: NSURL) {
        self.filePathUrl = filePathUrl
            }
    
    func getFilePath() -> NSURL {
        return self.filePathUrl
    }
    
}