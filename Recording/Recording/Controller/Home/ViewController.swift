//
//  ViewController.swift
//  Recording
//
//  Created by Md Hosne Mobarok on 11/1/22.
//

import UIKit
import AVFAudio
import AVFoundation

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var recordTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var records: [Record] = []
    var audioPlayer = AVAudioPlayer()
//    var player = AVPlayer()
    
    var selectedIndex: Int?
    var prev: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        recordTableView.estimatedRowHeight = 190
        recordTableView.rowHeight = UITableView.automaticDimension
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRecording()
    }
    
    func getRecording(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if let tempSounds = try? context.fetch(Record.fetchRequest()) as? [Record] {
            
            self.records = try! context.fetch(Record.fetchRequest())
            self.records.reverse() //Now last entry will show first
            
            records = tempSounds
            recordTableView.reloadData()
        }
    }
    
    // MARK: - Private Methods.
    private func setupTableView(){
        let nib = UINib(nibName: "RecordingCell", bundle: nil)
        recordTableView.register(nib, forCellReuseIdentifier: "cell")
        recordTableView.delegate = self
        recordTableView.dataSource = self
    }
    
    // MARK: - Button Action.
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Recording", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RecordingViewControllerID") as! RecordingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UITableView Delegate & DataSource Methods.
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == indexPath.row{
            return 180
        }else{
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recordTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordingCell
        
        let record = records[indexPath.row]
        if let sound = record.soundData{
            cell.audioPlayer = try! AVAudioPlayer(data: sound)
        }
        cell.trashButton.addTarget(self, action: #selector(removeRecord), for: .touchUpInside)
        cell.configure(name: record.name!, time: record.recordingTime ?? "", duration: record.recordingDuration ?? "")
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func removeRecord(sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? RecordingCell {
            guard let indexPath = recordTableView.indexPath(for: cell) else { return  }
            records.remove(at: indexPath.row)
            print("Remove item")
            self.recordTableView.performBatchUpdates({
                self.recordTableView.deleteRows(at:[indexPath], with: .fade)
                }, completion:nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        
        if prev == nil || prev != indexPath.row {
            recordTableView.reloadRows(at: [indexPath], with: .automatic)
            recordTableView.deselectRow(at: indexPath, animated: true)
        }
        prev = indexPath.row

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let soundToBeDeleted = records[indexPath.row]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
                context.delete(soundToBeDeleted)
                getRecording()
            //}
        }
    }
}
