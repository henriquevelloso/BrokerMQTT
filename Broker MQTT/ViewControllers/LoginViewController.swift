//
//  LoginViewController.swift
//  Broker MQTT
//
//  Created by Henrique Velloso on 13/12/18.
//  Copyright © 2018 Henrique Velloso. All rights reserved.
//

import UIKit
import CocoaMQTT

class LoginViewController: UIViewController {
    
    
    //MARK: - Outlets

    @IBOutlet weak var usernameTextbox: UITextField!
    
    //MARK: - Actions
    
    
    @IBAction func signInAndGo(_ sender: Any) {
        
        if self.usernameTextbox.text != "" {
            var state: CocoaMQTTConnState =  BrokerManager.shared.initialSetup(username: self.usernameTextbox.text!)
            BrokerManager.shared.mqtt?.delegate = self
           
            if state == CocoaMQTTConnState.connected {

                performSegue(withIdentifier: "SegueToProducts", sender: self)
            }
        }
    }
    
    
//MARK: - Delegates
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let mqtt = BrokerManager.shared.mqtt {
            if mqtt.connState == .connected {
                mqtt.disconnect()
            }
        }
    }
    
    //MARK: - Functions

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: -
extension LoginViewController: CocoaMQTTDelegate {
    

    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
       BrokerManager.TRACE("trust: \(trust)")
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        BrokerManager.TRACE("ack: \(ack)")
        
        if ack == .accept {
            mqtt.subscribe(BrokerManager.shared.settings!.topicBase + "/users/products)", qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe(BrokerManager.shared.settings!.topicBase + "/users/+", qos: CocoaMQTTQOS.qos1)
            BrokerManager.shared.allMessageCollection?.append(Date().currentTimeHM() + " - " + mqtt.username! + " connected")
            performSegue(withIdentifier: "SegueToProducts", sender: self)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        BrokerManager.TRACE("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        BrokerManager.TRACE("message: \(message.string!), id: \(id)")
        
        if message.topic == "Broker/users/products" {
            
            if let jsonData = message.string!.data(using: .utf8)
            {
                let products = try? JSONDecoder().decode(ProductCollection.self, from: jsonData)
               BrokerManager.shared.allProductsCollection = products?.allProductsCollection
            }
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        BrokerManager.TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        BrokerManager.TRACE("message: \(message.string!), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        BrokerManager.TRACE("topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        BrokerManager.TRACE("topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        BrokerManager.TRACE()
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        BrokerManager.TRACE()
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError error: Error?) {
        
        if let err = error {
            BrokerManager.TRACE("\(err.localizedDescription)")
        }
    }
    
}
