//
//  MyCollectionViewCellViewController.swift
//  tcm_ios
//
//  Created by jurng chen su on 2025/6/23.
//

import UIKit

class MyCollectionViewCellViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var imageView:UIImageView!
       var titleLabel:UILabel!

       override init(frame: CGRect) {
           super.init(frame: frame)

           // 取得螢幕寬度
           let w = Double(
             UIScreen.mainScreen().bounds.size.width)

           // 建立一個 UIImageView
           imageView = UIImageView(frame: CGRect(
             x: 0, y: 0,
             width: w/3 - 10.0, height: w/3 - 10.0))
           self.addSubview(imageView)

           // 建立一個 UILabel
           titleLabel = UILabel(frame:CGRect(
             x: 0, y: 0, width: w/3 - 10.0, height: 40))
           titleLabel.textAlignment = .Center
           titleLabel.textColor = UIColor.orangeColor()
           self.addSubview(titleLabel)
       }

       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
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
