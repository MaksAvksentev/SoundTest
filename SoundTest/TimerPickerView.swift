//
//  TimerPickerView.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 10.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import UIKit

class TimerPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var minute: Int = 0
    private var seconds: Int = 0
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.setup()
    }
    
    func setup(){
        
        self.delegate = self
        self.dataSource = self
    }
    
    func getDate() -> NSDate {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        let date = dateFormatter.date(from: String(format: "%02d", self.minute) + ":" + String(format: "%02d", self.seconds))
        return date! as NSDate
    }
    
    func getMinutes() -> Double {
    
        return Double(self.minute * 60) + Double(self.seconds)
    }
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return 60
        }
        
        return 60
    }
    
    //MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            self.minute = row
        case 1:
            self.seconds = row
        default:
            print("No component with number \(component)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        switch component {
        case 0:
            return "m"
        case 1:
            return "s"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if (view != nil) {
            (view as! UILabel).text = String(format:"%02lu", row)
            return view!
        }
        let columnView = UILabel(frame: CGRect(x: 35, y: 0, width: self.frame.size.width/3 - 35, height: 30))
        columnView.text = String(format:"%02lu", row)
        columnView.textAlignment = NSTextAlignment.center
        columnView.textColor = UIColor.red
        
        return columnView
    }
    
}
