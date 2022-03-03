//
//  ProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/24.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

import Firebase

struct AccountList: Codable {
    let cursor: String
    let items: [Acount]
}

struct Acount: Codable {
    let address: String
    let chainId: Int
    let createdAt: Int
    let keyId: String
    let krn: String
    let publicKey: String
    let updatedAt: Int
}

struct UserInfo {
    var uid: String
    var name: String?
    var email: String?
    var photoUrl: URL?
}

class ProfileViewController: UIViewController {
    var kasKey: KasKey?
    var data: Data?
    var userInfo: UserInfo?

    override func awakeFromNib() {
        confirmUserAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("appear")
        confirmUserAuth()
    }
    
    func confirmUserAuth() {
        guard let user = Auth.auth().currentUser else {
            goSecond()
            return
        }
        userInfo = UserInfo(
            uid: user.uid,
            name: user.displayName,
            email: user.email,
            photoUrl: user.photoURL
        )
    }
    
    func goSecond(){
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
    
    func setupProfileView() {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let name = user.displayName
            let email = user.email
            let photoURL = user.photoURL
            var multiFactorString = "MultiFactor: "
            for info in user.multiFactor.enrolledFactors {
                multiFactorString += info.displayName ?? "[DispayName]"
                multiFactorString += " "
            }
            print(uid, name, email, photoURL, multiFactorString)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    func getKeyList() {
        guard let kasKey = Bundle.main.kasApiKey else { return }
        let headers = [
            "Content-Type": "application/json",
            "x-chain-id": "8721",
            "Authorization": kasKey.authorization
        ]

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://wallet-api.klaytnapi.com/v2/account")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            self.data = data
            print(response as Any)
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
            }
        })
        dataTask.resume()
    }
}
