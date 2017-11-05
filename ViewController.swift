
import UIKit
import AVFoundation
import CoreAudio

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate,UIGestureRecognizerDelegate  {


    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var mixer:AVAudioMixerNode!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var fArray:[Float]!
    let bandPassfft = FFT()
    let lowPassfft = LowPassFFT()
    let highPassfft = HighPassFFT()
    var buffer:AVAudioPCMBuffer!
    var receivedAudio: RecordedAudio!
    var newAudio: AVAudioFile!
    //var url: NSURL!
    
    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
                          AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(int: 1),
                          AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
   
  
    
    @IBOutlet weak var darthvaderButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var FFTButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var pitchButton: UIButton!
    @IBOutlet weak var delayButton: UIButton!
    @IBOutlet weak var distortionButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        //self.view.backgroundColor = UIColor.cyanColor()
        
        audioEngine = AVAudioEngine()
                
    }
    
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier = timePitch {
//        let destViewController: TimePitchViewController = segue.destinationViewController as! TimePitchViewController
//        destViewController.player.audioFile = audioFile
//        }
//    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("Shaked")
                    if (!audioRecorder.recording){
                        do {
                            try audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder.url)
                            audioPlayer.play()
                                        } catch {
                        }
                    }
        }
        
    }
    
    
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        
        return soundURL
    }
    
    func audioDuration() -> (NSTimeInterval){
        do{
       //try audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl!)
        try audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl!)
                } catch{
            print(error)
        }
        
        let duration = audioPlayer.duration

        return duration
    }
    
    func audioRawDataLength() -> (Int){
        loadAudioSignal(receivedAudio.filePathUrl)
        let size = fArray.count
        return size
    }
    
    func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer {
        
        //let sampleRateHz: Float = Float(mixer.outputFormatForBus(0).sampleRate)
        let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.PCMFormatFloat32, sampleRate: 8000, channels: AVAudioChannelCount(1), interleaved: false)  // given NSData audio format
        let PCMBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: UInt32(data.length) / audioFormat.streamDescription.memory.mBytesPerFrame)
        PCMBuffer.frameLength = PCMBuffer.frameCapacity
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: Int(PCMBuffer.format.channelCount))
        data.getBytes(UnsafeMutablePointer<Void>(channels[0]) , length: data.length)
        //audioEngine.connect(playerNode, to: mixer, format: audioFormat)
        return PCMBuffer
    }
 
    
    
    func loadAudioSignal(audioURL: NSURL) -> (signal: [Float], rate: Double, frameCount: Int) {
        let file = try! AVAudioFile(forReading: audioURL)
        let format = AVAudioFormat(commonFormat: .PCMFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        let buf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: UInt32(file.length))
        try! file.readIntoBuffer(buf) // want better error handling
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData[0], count:Int(buf.frameLength)))
        fArray = floatArray
        print("floatArray \(floatArray)\n")
        return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
    }
    
    
    
    @IBAction func longPressSegue(sender: AnyObject) {
     playAudioWithVariablePitch(1000)
//            
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapped(_:)))
//        self.view.addGestureRecognizer(tapGestureRecognizer)
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        
//        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressed(_:)))
//        self.view.addGestureRecognizer(longPressRecognizer)
//        longPressRecognizer.minimumPressDuration = 1.5
//        
    }
    
//    func tapped(sender: UITapGestureRecognizer)
//    {
//        playAudioWithVariablePitch(1000)
//        print("tapped")
//    }
//    
//    func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        self.performSegueWithIdentifier("customSegue", sender: self)
//        print("longpressed")
//    }

    @IBAction func varySpeed(sender: AnyObject) {
        self.performSegueWithIdentifier("varySpeed", sender: self)
        //print("longpressed")
    
    }
    
    @IBAction func DelayPlayer(sender: AnyObject) {
        self.performSegueWithIdentifier("delaySegue", sender: self)
    }

    @IBAction func PitchPlayer(sender: AnyObject) {
        self.performSegueWithIdentifier("timePitch", sender: self)
    }
    
    @IBAction func DistortionPlayer(sender: AnyObject) {
        self.performSegueWithIdentifier("distortionSegue", sender: self)
    }
    
    @IBAction func playDarthVader(sender: AnyObject) {
        playAudioWithVariablePitch(-1000)
    }
    
    func resetAudioEngineAndPlayer() {
        //audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        resetAudioEngineAndPlayer()
        
        do{
       try audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl!)
        } catch {
            print(error)
        }
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: audioFile.processingFormat)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
                do {
            try audioEngine.start()
        } catch _ {
            print("Error")
        }
        
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            audioPlayerNode.play()
        
    }
    
    
    @IBAction func PlayHighPassAudio(sender: AnyObject) {
        loadAudioSignal(receivedAudio.filePathUrl!)
        highPassfft.calculate(fArray!)
        let length = highPassfft.calculate(fArray).count
        let data = NSData(bytes: highPassfft.calculate(fArray!), length: length)
        buffer = toPCMBuffer(data)
        print(buffer)
        resetAudioEngineAndPlayer()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        mixer = audioEngine.mainMixerNode
        
        let format = AVAudioFormat.init(commonFormat: buffer.format.commonFormat, sampleRate: buffer.format.sampleRate, channels: buffer.format.channelCount, interleaved: buffer.format.interleaved);
        
        audioEngine.connect(audioPlayerNode, to: mixer, format: format)
        audioPlayerNode.scheduleBuffer(buffer, completionHandler: nil)
        do {
            
            try audioEngine.start()
        }
        catch {
            print("error couldn't start engine")
        }
        if buffer != nil {
            print("Contains a value!")
            
        } else {
            print("Doesn’t contain a value.")
        }
        

    }
    
    
    @IBAction func PlayLowPassAudio(sender: AnyObject) {
        loadAudioSignal(receivedAudio.filePathUrl!)
        lowPassfft.calculate(fArray!)
        let length = lowPassfft.calculate(fArray).count
        let data = NSData(bytes: lowPassfft.calculate(fArray!), length: length)
        buffer = toPCMBuffer(data)
        print(buffer)
        resetAudioEngineAndPlayer()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        mixer = audioEngine.mainMixerNode
        
        let format = AVAudioFormat.init(commonFormat: buffer.format.commonFormat, sampleRate: buffer.format.sampleRate, channels: buffer.format.channelCount, interleaved: buffer.format.interleaved);
        
        audioEngine.connect(audioPlayerNode, to: mixer, format: format)
        audioPlayerNode.scheduleBuffer(buffer, completionHandler: nil)
        do {
            
            try audioEngine.start()
        }
        catch {
            print("error couldn't start engine")
        }
        if buffer != nil {
            print("Contains a value!")
            
        } else {
            print("Doesn’t contain a value.")
        }
        
        audioPlayerNode.play()

    }

    @IBAction func PlayBandPassAudio(sender: AnyObject) {
        loadAudioSignal(receivedAudio.filePathUrl!)
        bandPassfft.calculate(fArray!)
        let length = bandPassfft.calculate(fArray).count
        let data = NSData(bytes: bandPassfft.calculate(fArray!), length: length)
        buffer = toPCMBuffer(data)
        print(buffer)
        resetAudioEngineAndPlayer()
//        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        mixer = audioEngine.mainMixerNode
        
        let format = AVAudioFormat.init(commonFormat: buffer.format.commonFormat, sampleRate: buffer.format.sampleRate, channels: buffer.format.channelCount, interleaved: buffer.format.interleaved);
        
        audioEngine.connect(audioPlayerNode, to: mixer, format: format)
        audioPlayerNode.scheduleBuffer(buffer, completionHandler: nil)
        do {
            
            try audioEngine.start()
        }
        catch {
            print("error couldn't start engine")
        }
        if buffer != nil {
            print("Contains a value!")
            
        } else {
            print("Doesn’t contain a value.")
        }
        
        audioPlayerNode.play()
        
        
//        if (!audioRecorder.recording){
//            do {
//                try audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder.url)
//                audioPlayer.play()
//                            } catch {
//            }
//        }
    }
    
}