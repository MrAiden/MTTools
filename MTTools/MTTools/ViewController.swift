//
//  ViewController.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        MTDebug("弹窗")
        let alert = MTAlertController(title: "标题", message: "消息")
        present(alert, animated: true)
    }
}

struct CRToken: Decodable {
    
    var token: String
    
    var access_token: String
}
