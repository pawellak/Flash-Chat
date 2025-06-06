//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages  : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        title = "Chat"
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
       if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email
        {
           
           let db = Firestore.firestore()
           
          
           
           db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender,K.FStore.bodyField: messageBody,K.FStore.dateField: Date().timeIntervalSince1970])
           }
           
        }
         
    func loadMessages()
    {
        
        
        let db = Firestore.firestore()
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener() { (querySnapshot, error) in
             
            self.messages = []
            
            if let error = error
            {
                print("Error getting documents: \(error)")
            }
            else
            {
                if let snapshotDocument = querySnapshot?.documents
                {
                    for document in snapshotDocument
                    {
                        let data = document.data()
                        
                        if let sender = data[K.FStore.senderField]  as? String, let messageBody = data[K.FStore.bodyField]  as? String
                        {
                            
                            let newMessage = Message(sender: sender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
               
            }
        }
        
        
    }
         
    
    
    @IBAction func onLogoutButtonPressed(_ sender: UIBarButtonItem) {
        
       do {
            
            try Auth.auth().signOut()
           navigationController?.popToRootViewController(animated: false)
           
            
        } catch let signOutError as NSError
        {
            print("Error signing out: \(signOutError)")
        }
        
        
        
    }
    
    
}

extension ChatViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
       
        cell.label?.text = self.messages[indexPath.row].body
        
        return cell;
    }
}
