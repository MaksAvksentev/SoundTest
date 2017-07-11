 //
 //  PlayerViewController.swift
 //  SoundTest
 //
 //  Created by Maksim Avksentev on 05.07.17.
 //  Copyright © 2017 Avksentev. All rights reserved.
 //

import Foundation
import UIKit
import MediaPlayer
import Jukebox
import CountdownLabel
 
let playNotificationIdentifier = "PlayMusicAtIndexPath"
let playNextNotificationIdentifier = "PlayNextNotificationIdentifier"
let timerNotificationIdentifier = "TimerNotificationIdentifier"
 
class PlayerViewController: BaseViewController, JukeboxDelegate, TimerDelegate {
    
    @IBOutlet weak var soundImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var centerContainer: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var prevButton:UIButton!
    
    private var jukebox : Jukebox!
    
    private var SoundArray: [Sound] = [Sound]()
    
    var timer: Timer? {
        willSet {
            self.timer?.invalidate()
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureUI()

        self.jukebox = Jukebox(delegate: self, items: [])!
       
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.configureNotifications()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.configureButtons()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == .remoteControl {
            
            switch event!.subtype {
            case .remoteControlPlay :
                self.jukebox.play()
            case .remoteControlPause :
                self.jukebox.pause()
            case .remoteControlNextTrack :
                self.configurePlayer(next: true)
                if self.jukebox.playIndex == self.SoundArray.count - 1 {
                    self.jukebox.play(atIndex: 0)
                } else {
                    self.jukebox.playNext()
                }
            case .remoteControlPreviousTrack:
                self.configurePlayer(next: false)
                if self.jukebox.playIndex == 0 {
                    self.jukebox.play(atIndex: self.SoundArray.count - 1)
                } else {
                    self.jukebox.playPrevious()
                }
            case .remoteControlTogglePlayPause:
                if self.jukebox.state == .playing {
                    self.jukebox.pause()
                } else {
                    self.jukebox.play()
                }
            default:
                break
            }
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: playNotificationIdentifier), object: nil);
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: playNextNotificationIdentifier), object: nil);
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: timerNotificationIdentifier), object: nil)
    }
    
    //MARK: - Private
    private func configureNotifications() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(playSound), name: NSNotification.Name(rawValue: playNotificationIdentifier), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configurePlayNext), name: NSNotification.Name(rawValue: playNextNotificationIdentifier), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerConfigure), name: NSNotification.Name(rawValue: timerNotificationIdentifier), object: nil)
    }
    
    private func configureButtons() {
    
        switch self.jukebox.queuedItems.isEmpty {
        case true:
            self.playPauseButton.isEnabled = false
            self.stopButton.isEnabled = false
            self.replayButton.isEnabled = false
            self.prevButton.isEnabled = false
            self.nextButton.isEnabled = false
        case false:
            self.playPauseButton.isEnabled = true
            self.stopButton.isEnabled = true
            self.replayButton.isEnabled = true
            self.prevButton.isEnabled = true
            self.nextButton.isEnabled = true
        }
    }
    
    private func configurePlayer(next: Bool = true) {
    
        var index = next ? 1 : -1
        
        if jukebox.playIndex + index >= self.SoundArray.count {
        
            index = 0
        } else if jukebox.playIndex + index < 0 {
            
            index = self.SoundArray.count - 1
        } else {
        
            index = jukebox.playIndex + index
        }
        
        let sound = self.SoundArray[index]
        self.configurePlayer(withSound: sound)
    }
    
    private func configurePlayer(withSound sound: Sound) {
    
        if let image = sound.image as? Data {
        
           self.soundImageView.image = UIImage(data: image)
        } else {
        
            self.soundImageView.image = UIImage(named: "logo")
        }
        
        self.titleLabel.text = sound.title
    }
    
    private func initializeArray(withState state: ControllerState) {
        
        switch state {
        case .all:
            self.SoundArray = Sound.findAll(inContext: CoreDataManager.shared.viewContext)
        case .favorites:
            self.SoundArray = Sound.findFavorites(inContext: CoreDataManager.shared.viewContext)
        case .none:
            break
        }
    }
    
    private func configureUI() {
        
        self.resetUI()
        
        let color = UIColor(red:0.84, green:0.09, blue:0.1, alpha:1)
        
        indicator.color = color
        slider.setThumbImage(UIImage(named: "slider"), for: UIControlState())
        slider.minimumTrackTintColor = color
        slider.maximumTrackTintColor = UIColor.black
        
        volumeSlider.minimumTrackTintColor = color
        volumeSlider.maximumTrackTintColor = UIColor.black
        volumeSlider.thumbTintColor = color
        
        titleLabel.textColor =  color
        
        centerContainer.layer.cornerRadius = 12
        view.backgroundColor = UIColor.black
    }
    
    //MARK: - NotificationAction
    func playSound(_ notification: NSNotification) {
        
        if let sound = notification.userInfo?["sound"] as? Sound, let state = notification.userInfo?["state"] as? ControllerState {
            
            self.initializeArray(withState: state)
            
            jukebox.stop()
            jukebox = Jukebox(delegate: self, items: [])!
            
            var index = 0
            for track in self.SoundArray {
                let item = JukeboxItem (URL: URL(string: track.stream_url!)!, localTitle: track.title)
                item.setImage(UIImage(data: track.image! as Data)!)
                self.jukebox.append(item: item, loadingAssets: true)
                if track == sound {
                    index = self.SoundArray.index(of: track)!
                }
            }
            
            OperationQueueManager.shared.addToQueue{

                self.jukebox.play(atIndex: index)
            }
            
            self.configurePlayer(withSound: sound)
        }
        
        UIView.animate(withDuration: 1.5) {
        
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    func configurePlayNext(_ notification: NSNotification) {
    
        guard let url = notification.userInfo?["url"] as? URL, let sound = Sound.find(inContext: CoreDataManager.shared.viewContext, withStream: String(describing: url)) else {
        
            self.resetUI()
            return
        }
        
        self.configurePlayer(withSound: sound)
    }
    
    func timerConfigure(_ notification: NSNotification) {
        
        guard let timer = notification.userInfo?["timer"] as? TimeInterval else {
        
            self.timer = nil
            return
        }
        
        if let state = notification.userInfo?["state"] as? String {
        
            switch state {
            case "Start":
                self.timer = Timer.scheduledTimer(withTimeInterval: timer, repeats: false, block: { (time) in
                    self.timer = nil
                    self.jukebox.pause()
                })
            case "Stop":
                self.timer = nil
            default:
                break
            }
        }
    }
    
    //MARK: - Timer 
    func timerChange() {
        
        self.timer = nil
        self.jukebox.pause()
    }
    
    //MARK: - JukeboxDelegate
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        
        log.info("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            slider.value = value
            populateLabelWithTime(currentTimeLabel, time: currentTime)
            populateLabelWithTime(durationLabel, time: duration)
        } else {
            resetUI()
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.indicator.alpha = jukebox.state == .loading ? 1 : 0
            self.playPauseButton.alpha = jukebox.state == .loading ? 0 : 1
            self.playPauseButton.isEnabled = jukebox.state == .loading ? false : true
        })
        
        if jukebox.state == .ready {
            playPauseButton.setImage(UIImage(named: "play"), for: UIControlState())
        } else if jukebox.state == .loading  {
            playPauseButton.setImage(UIImage(named: "pause"), for: UIControlState())
        } else {
            volumeSlider.value = jukebox.volume
            let imageName: String
            switch jukebox.state {
            case .playing, .loading:
                imageName = "pause"
            case .paused, .failed, .ready:
                imageName = "play"
            }
            playPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
        }
        
        log.info("Jukebox state changed to \(jukebox.state)")
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        
        log.info("Item updated:\n\(forItem)")
    }
    
    //MARK: - Callbacks
    @IBAction func volumeSliderValueChanged() {
        
        if let jk = jukebox {
            jk.volume = volumeSlider.value
        }
    }
    
    @IBAction func progressSliderValueChanged() {
        
        if let duration = jukebox.currentItem?.meta.duration {
            jukebox.seek(toSecond: Int(Double(slider.value) * duration))
        }
    }
    
    @IBAction func prevAction() {
        
        configurePlayer(next: false)
        
        if jukebox.playIndex == 0 {
            jukebox.play(atIndex: self.SoundArray.count - 1)
        } else {
            jukebox.playPrevious()
        }
    }
    
    @IBAction func nextAction() {
        
        configurePlayer(next: true)
        
        if jukebox.playIndex == self.SoundArray.count - 1 {
            jukebox.play(atIndex: 0)
        } else {
            jukebox.playNext()
        }
    }
    
    @IBAction func playPauseAction() {
        
        switch jukebox.state {
            case .ready :
                self.jukebox.play(atIndex: 0)
            case .playing :
                self.jukebox.pause()
            case .paused :
                self.jukebox.play()
            default:
                self.jukebox.stop()
        }
    }
    
    @IBAction func replayAction() {
        
        self.jukebox.replayCurrentItem()
    }
    
    @IBAction func stopAction() {
        
        self.resetUI()
        self.jukebox.pause()
        self.jukebox = Jukebox(delegate: self, items: [])
        self.configureButtons()
        self.jukebox.stop()
    }
  
    @IBAction func timerAction() {
        
        let viewController = UIStoryboard.loadTimerFromMain(TimerViewController.className)
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - TimerDelegate
    func timerDidStop() {
        
        guard let _ = self.timer else {
            
            return
        }
        
        self.jukebox.pause()
    }
    
    //MARK: - Helpers
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    func resetUI() {
        
        durationLabel.text = "00:00"
        currentTimeLabel.text = "00:00"
        slider.value = 0
        titleLabel.text = "JukeBox"
        soundImageView.image = UIImage(named: "logo")
    }
}
