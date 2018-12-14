//
//  BrokerManager.swift
//  Broker MQTT
//
//  Created by Henrique Velloso on 13/12/18.
//  Copyright © 2018 Henrique Velloso. All rights reserved.
//

import UIKit
import CocoaMQTT


struct MQTTSettings {
    var host: String
    var port: UInt16
    var keepAlive: UInt16
    var topicBase: String
}

class BrokerManager: NSObject {
    
    //MARK: - Singleton
    private override init(){}
    static let shared = BrokerManager()

    //MARK: - Properties
    var mqtt: CocoaMQTT?
    var settings: MQTTSettings?
    var allMessageCollection: [String]?
    var allProductsCollection: [Int:Product]?
    
    //MARK: - Functions
    
    func initialSetup(username: String) -> CocoaMQTTConnState {
        
        
        if self.mqtt?.connState != CocoaMQTTConnState.connected {
            
        
        
            var nsDictionary: NSDictionary?
            if let path = Bundle.main.path(forResource: "MQTT_Config", ofType: "plist") {
                nsDictionary = NSDictionary(contentsOfFile: path)
            }
            
            settings = MQTTSettings(host: nsDictionary?["host"] as! String,
                                        port: nsDictionary?["port"] as! UInt16 ,
                                        keepAlive: ((nsDictionary?["keepAlive"]) as! UInt16),
                                        topicBase: nsDictionary?["topicBase"] as! String)
            
            if settings != nil {
                let clientID = username + "-" + String(ProcessInfo().processIdentifier)
                self.mqtt = CocoaMQTT(clientID: clientID, host: settings!.host, port: settings!.port)
                self.mqtt!.username = username
                self.mqtt!.password = ""
                self.mqtt!.willMessage = CocoaMQTTWill(topic: settings!.topicBase, message: "dieOut")
                self.mqtt!.keepAlive = settings!.keepAlive
               // self.mqtt!.delegate = self
                
                let connected = mqtt!.connect()
                NSLog("Connected \(connected)")
                
            } else {
                print("ERROR on load plist file.")
            }
            
            if allMessageCollection == nil {
                allMessageCollection = [String]()
            }
            
            
            self.initProducts()
            
                  
            
            return CocoaMQTTConnState.connecting
            
            
        } else {
            return CocoaMQTTConnState.connected
        }

    }
    
    func initProducts () {
        
        self.allProductsCollection = [Int:Product]()
        
        var product = Product()
        product.Id = 01
        product.Name = "Xbox One X"
        product.value = 100
        product.betCount = 0
        product.betTime = ""
        product.lastBetUser = ""
        self.allProductsCollection?[1] = product
        
        product = Product()
        product.Id = 02
        product.Name = "PlayStation 2"
        product.value = 50
        product.betCount = 0
        product.betTime = ""
        product.lastBetUser = ""
        self.allProductsCollection?[2] = product
        
        product = Product()
        product.Id = 03
        product.Name = "Apple iPhone XS"
        product.value = 120
        product.betCount = 0
        product.betTime = ""
        product.lastBetUser = ""
        self.allProductsCollection?[3] = product
        
        product = Product()
        product.Id = 04
        product.Name = "TV Samsung 4k 55''"
        product.value = 100
        product.betCount = 0
        product.betTime = ""
        product.lastBetUser = ""
        self.allProductsCollection?[4] = product
    }

    static func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 1 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }
        
        print("[TRACE] [\(prettyName)]: \(message)")
    }
    


}




extension BrokerManager: CocoaMQTTDelegate {
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let jsonData = message.string!.data(using: .utf8)
        {
            let product = try? JSONDecoder().decode(Product.self, from: jsonData)
            self.allProductsCollection![product!.Id!] = product!
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    

}
