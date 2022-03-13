//
//  RecordingViewController.swift
//  Recording
//
//  Created by Md Hosne Mobarok on 11/1/22.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioPlayerDelegate {
    
    static let shared = RecordingViewController()
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    
    fileprivate var timer: Timer!
    var isRecording : Bool = false
    var isPlaying : Bool = false
    var duration = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        playButton.isEnabled = false
        saveButton.isEnabled = false
        
        setupUI()
        micSetup()
    }
    
    @objc func updateAudioMeter(_ timer: Timer) {
        if let recorder = self.audioRecorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                statusLabel.text = s
                recorder.updateMeters()
            }
        }
    }
    
    //MARK:- Track time
    @objc func updateDuration() {
        if isRecording && !isPlaying{
            duration += 1
        }else{
            timer.invalidate()
        }
    }
    
    func getCurrentTime() -> Double {
        return audioPlayer!.currentTime
    }
    
    // MARK: - Private Methods.
    func setupUI(){
        recordButton.layer.cornerRadius = 8
        playButton.layer.cornerRadius = 8
        saveButton.layer.cornerRadius = 8
    }
    
    func getCurrentTime() -> String? {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let dateTimeString = formatter.string(from: currentDateTime)
        return dateTimeString
    }
    
    func micSetup() {
        /// Session
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        /// URL for saving
        if let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let filepatharray = [basePath, "dasound.m4a"]
            if let audioURL = NSURL.fileURL(withPathComponents: filepatharray) {
                var settings : [String:Any] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
                settings[AVSampleRateKey] = 44_100.0
                settings[AVNumberOfChannelsKey] = 2
                
                audioRecorder = try? AVAudioRecorder(url: audioURL, settings: settings)
                audioRecorder?.prepareToRecord()
            }
        }
    }
    
    func startPlaying() {
        if let audioURL = audioRecorder?.url {
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            playButton.setTitle("Stop", for: .normal)
            recordButton.isEnabled = false
            saveButton.isEnabled = false
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        playButton.setTitle("Play", for: .normal)
        recordButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play", for: .normal)
        recordButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    // MARK: - Button Action.
    @IBAction func recordButtonAction(_ sender: UIButton) {
        if let recorder = audioRecorder {
            if recorder.isRecording{
                /// Stop Recording
                recorder.stop()
                recordButton.setTitle("Record", for: .normal)
                playButton.isEnabled = true
                saveButton.isEnabled = true
            } else {
                /// Start recording
                self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                                       target: self,
                                                       selector: #selector(self.updateAudioMeter(_:)),
                                                       userInfo: nil,
                                                       repeats: true)
                duration = 0
                isRecording = true
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateDuration), userInfo: nil, repeats: true) /// start  timer
            
                recorder.record()
                recordButton.setTitle("Stop", for: .normal)
                playButton.isEnabled = false
                saveButton.isEnabled = false
            }
        }
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        if let player = audioPlayer {
            if player.isPlaying {
                stopPlaying()
            } else {
                startPlaying()
            }
        } else {
            startPlaying()
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let data = Record(context: context)
            
            data.name = nameTextfield.text
            data.recordingTime = getCurrentTime()
            data.recordingDuration = statusLabel.text
            if let audioUrl = audioRecorder?.url{
                data.soundData = try? Data(contentsOf: audioUrl)
                try? context.save()
                navigationController?.popViewController(animated: true)
            }
        }
    }
}
