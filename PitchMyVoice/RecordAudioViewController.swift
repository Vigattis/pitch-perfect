//
//  RecordAudioViewController.swift
//  PitchMyVoice
//
//  Created by Aras Senova on 2015-05-14.
//  Copyright (c) 2015 Aras Senova. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var tapToRecord: UILabel!
    @IBOutlet weak var resumeInactive: UIButton!
    @IBOutlet weak var pauseInactive: UIButton!
    @IBOutlet weak var pauseActive: UIButton!
    @IBOutlet weak var resumeActive: UIButton!
    
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        pauseActive.hidden = true
        resumeActive.hidden = true
        pauseInactive.hidden = false
        resumeInactive.hidden = false
        stopButton.hidden = true
        microphoneButton.enabled = true
        tapToRecord.hidden = false
    }

    @IBAction func audioRecord(sender: UIButton) {
        println("Nabun")
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        pauseInactive.hidden = true
        resumeInactive.hidden = false
        resumeActive.hidden = true
        pauseActive.hidden = false
        
        microphoneButton.enabled = false
        recordingLabel.hidden = false
        tapToRecord.hidden = true
        stopButton.hidden = false
    }
    @IBAction func pauseRecording(sender: UIButton) {
        audioRecorder.pause()
        resumeActive.hidden = false
        pauseActive.hidden = true
        pauseInactive.hidden = false
    }
    @IBAction func resumeRecording(sender: UIButton) {
        audioRecorder.record()
        resumeActive.hidden = true
        resumeInactive.hidden = false
        pauseInactive.hidden = true
        pauseActive.hidden = false
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio()
            recordedAudio.filePathUrl = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else {
            println("Recording was not successful")
            stopButton.hidden = true
            microphoneButton.enabled = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playAudioVC:PlayAudioViewController = segue.destinationViewController as! PlayAudioViewController
            let data = sender as! RecordedAudio
            playAudioVC.receivedAudio = data
        }
    }
    @IBAction func stopRecord(sender: UIButton) {
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        recordingLabel.hidden = true
        stopButton.hidden = true
    }
}
