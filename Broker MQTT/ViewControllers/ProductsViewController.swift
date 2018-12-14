//
//  ProductsViewController.swift
//  Broker MQTT
//
//  Created by Henrique Velloso on 13/12/18.
//  Copyright © 2018 Henrique Velloso. All rights reserved.
//

import UIKit
import CocoaMQTT

class ProductsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var selectedProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

         BrokerManager.shared.mqtt?.delegate = self
        BrokerManager.shared.mqtt!.subscribe(BrokerManager.shared.settings!.topicBase + "/users/products)", qos: CocoaMQTTQOS.qos1)
        tableview.reloadData()
        
        self.navigationController!.navigationBar.topItem!.title = "Logout"
        
        // Do any additional setup after loading the view.
    }
    


    
    override func viewDidAppear(_ animated: Bool) {
                self.tableview.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        let destinationVC = segue.destination as! DetailViewController
        destinationVC.product = self.selectedProduct
        
    }
 

}



extension ProductsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BrokerManager.shared.allProductsCollection!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        let productRaw : Product? = BrokerManager.shared.allProductsCollection![indexPath.row + 1]
        let cell: ProductCell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        
        if let product = productRaw {
            cell.nameLabel.text = product.Name
            cell.valueLabel.text = ""//Z$ \(product.value!)"
            cell.betsLabel.text = ""//\(product.betCount!) Bets"
            cell.timeLabel.text = ""
            cell.userLabel.text = ""
            
//            if product.betTime != "" {
//                cell.timeLabel.text = "Last bet at " + product.betTime!
//            }
//            if product.lastBetUser != ""{
//                cell.userLabel.text = "Bet by " + product.lastBetUser!
//            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedProduct = BrokerManager.shared.allProductsCollection![indexPath.row + 1]
        performSegue(withIdentifier: "SegueToDetail", sender: self)
    }
    
}



//MARK: -
extension ProductsViewController: CocoaMQTTDelegate {
    
    
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

        
        if message.topic == "Broker/users/products" {
            if let jsonData = message.string!.data(using: .utf8)
            {
                let products = try? JSONDecoder().decode(ProductCollection.self, from: jsonData)
                BrokerManager.shared.allProductsCollection = products?.allProductsCollection
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
