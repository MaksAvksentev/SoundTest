//
//  TimerViewController.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 10.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import CountdownLabel

protocol TimerDelegate: class {
    func timerDidStop()
}

class TimerViewController: UIViewController, CountdownLabelDelegate {

    @IBOutlet weak var timerLabel: CountdownLabel!
    @IBOutlet weak var datePicker: TimerPickerView!
    @IBOutlet weak var controlButton: UIButton!
    
    weak var delegate: TimerDelegate?
    
    class var className: String {
    
        return "TimerViewController"
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureButton()
        self.configureTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.initialize()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.save()
    }
    
    //MARK: - Private
    private func configureTimer() {
        
        self.timerLabel.countdownDelegate = self
        self.timerLabel.animationType = CountdownEffect.Burn
    }
    
    private func configureButton() {
    
        if timerLabel.isCounting {
            self.controlButton.setTitle("Stop", for: .normal)
        } else {
            self.controlButton.setTitle("Start", for: .normal)
        }
    }
    
    private func configureView(withState state: String) {
        
        switch state {
        case "Start":
            let minutes = datePicker.getMinutes()
            self.timerLabel.setCountDownTime(minutes: minutes)
            NotificationCenter.default.post(name: Notification.Name(rawValue: timerNotificationIdentifier), object: nil, userInfo: ["timer" : minutes, "state" : "Start"])
            self.timerLabel.start()
            self.configureButton()
            self.datePicker.isHidden = true
            self.timerLabel.isHidden = false
        case "Stop":
            self.timerLabel.cancel()
            NotificationCenter.default.post(name: Notification.Name(rawValue: timerNotificationIdentifier), object: nil, userInfo: ["state" : "Stop"])
            self.datePicker.isHidden = false
            self.timerLabel.isHidden = true
            self.configureButton()
            break
        default:
            break
        }
    }
    
    //MARK: - Actions
    @IBAction func controlAction(_ sender: UIButton) {
    
        guard let text = controlButton.titleLabel?.text else {
            
            return
        }
        
        self.configureView(withState: text)
    }
    
    //MARK: - CountdownLabelDelegate
    func countdownFinished() {
        
        self.delegate?.timerDidStop()
        self.datePicker.isHidden = false
        self.timerLabel.isHidden = true
        self.configureView(withState: "Stop")
    }
    
    //MARK: - Storing
    private func initialize() {
        
        let state = UserDefaults.standard.data(forKey: "State")
        let timerTime = UserDefaults.standard.data(forKey: "Timer")
        
        if let data = state, let type = NSKeyedUnarchiver.unarchiveObject(with: data) as? String, type == "Stop", let timerData = timerTime, let timer = NSKeyedUnarchiver.unarchiveObject(with: timerData) as? TimeInterval {
            
            if timer - Date.getCurrentDate() < Date.getCurrentDate(){
                self.configureButton()
                self.datePicker.isHidden = true
                self.timerLabel.isHidden = false
                
                self.timerLabel.setCountDownTime(minutes: timer - Date.getCurrentDate())
                self.timerLabel.start()
            }
        }
    }
    
    func save() {

        let timer = NSKeyedArchiver.archivedData(withRootObject: self.timerLabel.currentTime + Date.getCurrentDate())
        let state = NSKeyedArchiver.archivedData(withRootObject: self.controlButton.titleLabel?.text ?? "Start")
        
        UserDefaults.standard.set(state, forKey: "State")
        UserDefaults.standard.set(timer, forKey: "Timer")

        UserDefaults.standard.synchronize()
    }
}

extension Date {

    static func getCurrentDate() -> Double {
    
        let date = Date()
        return date.timeIntervalSince1970
    }
}
