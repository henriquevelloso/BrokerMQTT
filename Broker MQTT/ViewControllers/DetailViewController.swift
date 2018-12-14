//
//  DetailViewController.swift
//  Broker MQTT
//
//  Created by Henrique Velloso on 13/12/18.
//  Copyright © 2018 Henrique Velloso. All rights reserved.
//

import UIKit
import CocoaMQTT

class DetailViewController: UIViewController {

    //MARK: - Properties
        var product: Product?
    
    
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var betsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    //MARK: - Actions
    
    @IBAction func addNewBet(_ sender: Any) {
        
        product!.betCount = product!.betCount! + 1
        product!.betTime = Date().currentTimeHMS()
        product!.lastBetUser = BrokerManager.shared.mqtt?.username
        product!.value = product!.value! + 1.5
        updateProduct()
        
        BrokerManager.shared.mqtt!.subscribe(BrokerManager.shared.settings!.topicBase + "/users/\(product!.Id!)", qos: CocoaMQTTQOS.qos1)
        
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(product!)
        let json = String(data: jsonData!, encoding: String.Encoding.utf8)
        
        
        BrokerManager.shared.mqtt!.publish(BrokerManager.shared.settings!.topicBase + "/users/\(product!.Id!)", withString: json!, qos: CocoaMQTTQOS.qos1)
        self.button.isEnabled = false
        self.button.setTitle("LOADING", for: .normal)
        
        //-- update products
        BrokerManager.shared.allProductsCollection![product!.Id!] = product!
        let productCollection: ProductCollection = ProductCollection()
        productCollection.allProductsCollection = BrokerManager.shared.allProductsCollection!
        
        let jsonEncoder2 = JSONEncoder()
        let jsonData2 = try? jsonEncoder2.encode(productCollection)
        let json2 = String(data: jsonData2!, encoding: String.Encoding.utf8)
        
        BrokerManager.shared.mqtt!.publish(BrokerManager.shared.settings!.topicBase + "/users/products", withString: json2!, qos: CocoaMQTTQOS.qos1)
    }
    
    //MARK: - Functions
    
    func updateProduct() {
    
        self.nameLabel.text = product!.Name
        self.valueLabel.text = "Z$ \(product!.value!)"
        self.betsLabel.text = "\(product!.betCount!) Bets"
        self.timeLabel.text = ""
        self.userLabel.text = ""
        
        if product!.betTime != "" {
            self.timeLabel.text = "Last bet at " + product!.betTime!
        }
        if product!.lastBetUser != ""{
            self.userLabel.text = "Bet by " + product!.lastBetUser!
        }
        
        
      

    
    }
    
    //MARK: - Delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        BrokerManager.shared.mqtt!.subscribe(BrokerManager.shared.settings!.topicBase + "/users/products)", qos: CocoaMQTTQOS.qos1)
       BrokerManager.shared.mqtt?.delegate = self
        
        self.product = BrokerManager.shared.allProductsCollection![self.product!.Id!]
        updateProduct()

        
        
    }
    

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
extension DetailViewController: CocoaMQTTDelegate {
    
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        BrokerManager.TRACE("trust: \(trust)")
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        BrokerManager.TRACE("ack: \(ack)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        BrokerManager.TRACE("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        BrokerManager.TRACE("message: \(message.string!), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        BrokerManager.TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        BrokerManager.TRACE("message: \(message.string!), id: \(id)")
        
        if message.topic == "Broker/users/\(self.product!.Id!)" {
        
            if let jsonData = message.string!.data(using: .utf8)
            {
                self.product = try? JSONDecoder().decode(Product.self, from: jsonData)
                updateProduct()
                self.button.isEnabled = true
                self.button.setTitle("BET in Z$ 1.50", for: .normal)
            }
        }
        
        if message.topic == "Broker/users/products" {
            if let jsonData2 = message.string!.data(using: .utf8)
            {
                var products:ProductCollection = try! JSONDecoder().decode(ProductCollection.self, from: jsonData2)
                BrokerManager.shared.allProductsCollection = products.allProductsCollection
            }
        }
        
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
