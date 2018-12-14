//
//  Extensions.swift
//  Broker MQTT
//
//  Created by Henrique Velloso on 13/12/18.
//  Copyright © 2018 Henrique Velloso. All rights reserved.
//

import Foundation

extension Date {
    
    func currentTimeHMS() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return "\(hour):\(minutes):\(seconds)"
    }
    
    func currentTimeHM() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return "\(hour):\(minutes)"
    }
    
}
