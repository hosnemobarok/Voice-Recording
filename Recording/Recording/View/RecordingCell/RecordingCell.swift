//
//  RecordCell.swift
//  Recording
//
//  Created by Md Hosne Mobarok on 11/1/22.
//

import UIKit
import AVKit
import AVFoundation

class RecordingCell: UITableViewCell {
    
    @IBOutlet weak var recordNameLabel: UITextField!
    @IBOutlet weak var recordingTimeLable: UILabel!
    @IBOutlet weak var recordingDurationLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordingPlayDurationLabel: UILabel!
    @IBOutlet weak var recordingRestTimeLabel: UILabel!
    @IBOutlet weak var trashButton: UIButton!
    
    var records: [Record] = []
    var audioPlayer = AVAudioPlayer()
    fileprivate let seekDuration: Float64 = 15.0
    var soundOnOff = false
    var timerT: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
                
        recordNameLabel.isEnabled = false
        slider.setThumbImage(#imageLiteral(resourceName: "slider"), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Private Methods.
    public func configure(name: String, time: String, duration: String){
        recordNameLabel.text = name
        recordingTimeLable.text = time
        recordingDurationLabel.text = duration
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
//        let hours = (interval / 3600)
//        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return String(format: "%02d:%02d", minutes, seconds)

    }
    
    @objc func updateTime(_ timer: Timer) {
        if Int(slider.value) == Int(audioPlayer.duration)-1 {
            timerT?.invalidate()
            timerT = nil
            
            audioPlayer.currentTime = audioPlayer.duration
            slider.maximumValue = 0.0
            
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            print(audioPlayer.currentTime)
        }
        slider.value = Float(audioPlayer.currentTime)
//        UIView.animate(withDuration: 0.1, animations: { [self] in
//            slider.layoutIfNeeded()
//        })
        
        let duration = (audioPlayer.currentTime)
        let seconds = TimeInterval(duration)
        recordingPlayDurationLabel.text = self.stringFromTimeInterval(interval: seconds)
        recordingRestTimeLabel.text = "-" + self.stringFromTimeInterval(interval: TimeInterval(audioPlayer.duration - audioPlayer.currentTime))
    }
    
    func playSlider(){
        let totalRecordDuration = Float(audioPlayer.duration)
        slider.maximumValue = Float(Int(totalRecordDuration) - 1)
        timerT = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    // MARK: - Button Action.
    @IBAction func fifteenSecondBackwardBtnAction(_ sender: UIButton) {
        print("15 second backward")
        let currentTime = audioPlayer.currentTime
        let newTime = currentTime - seekDuration

        if audioPlayer.isPlaying{
            audioPlayer.currentTime = newTime

            audioPlayer.prepareToPlay()
            audioPlayer.play()
            playSlider()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

        }else{
            audioPlayer.currentTime = newTime

            audioPlayer.prepareToPlay()
            audioPlayer.pause()
            playSlider()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func playOrPauseBtnAction(_ sender: UIButton) {
        if soundOnOff {
            timerT?.invalidate()
            timerT = nil
            audioPlayer.stop()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            soundOnOff = false

        }else {
            playSlider()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            soundOnOff = true
        }
    }
    
    @IBAction func fifteenSecondForwardBtnAction(_ sender: UIButton) {
        print("15 second forward.")
        let currentTime = audioPlayer.currentTime
        let newTime = currentTime + seekDuration

        if audioPlayer.isPlaying{
            let currentDuration = Int(audioPlayer.duration - audioPlayer.currentTime)

            if currentDuration <= Int(seekDuration){
                audioPlayer.currentTime = audioPlayer.duration - 3.0

                audioPlayer.prepareToPlay()
                audioPlayer.play()
                playSlider()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

            }else if currentDuration > Int(seekDuration){
                audioPlayer.currentTime = newTime

                audioPlayer.prepareToPlay()
                audioPlayer.play()
                playSlider()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }

        }else{
            let currentDuration = Int(audioPlayer.duration - audioPlayer.currentTime)
            
            if currentDuration <= Int(seekDuration){
                audioPlayer.currentTime = audioPlayer.duration - 3.0

                audioPlayer.prepareToPlay()
                audioPlayer.pause()
                playSlider()
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

            }else if currentDuration >= Int(seekDuration){
                audioPlayer.currentTime = newTime

                audioPlayer.prepareToPlay()
                audioPlayer.pause()
                playSlider()
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }

    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
    
        if audioPlayer.isPlaying{
            
            UIView.animate(withDuration: 0.1, animations: { [self] in
                slider.layoutIfNeeded()
                
                let currentValue = Int(sender.value)
                recordingPlayDurationLabel.text = self.stringFromTimeInterval(interval: TimeInterval(currentValue))
                audioPlayer.currentTime = TimeInterval(currentValue)

                audioPlayer.prepareToPlay()
                audioPlayer.play()
                playSlider()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            })
            
        }else{
            
            UIView.animate(withDuration: 0.1, animations: { [self] in
                slider.layoutIfNeeded()
                
                let currentValue = Int(sender.value)
                recordingPlayDurationLabel.text = self.stringFromTimeInterval(interval: TimeInterval(currentValue))
                audioPlayer.currentTime = TimeInterval(currentValue)
                audioPlayer.pause()
                playSlider()
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            })
        }
    }

}
