//
//  MyCollectionViewCell.swift
//  tcm_ios
//
//  Created by jurng chen su on 2025/6/23.
// https://itisjoe.gitbooks.io/swiftgo/content/uikit/uicollectionview.html

import UIKit

var i: Int = 0
var w: Int = 140       // 取得螢幕寬度, 預設 375 點 -->  115=(375/3) - 10
var nowX: CGFloat = 4.0
var nowY: CGFloat = 0.0
var xpos: [Int] = [8, 48, 88, -200, -160, -120]
var ypos: [Int] = [0,  0,  0, 24, 24, 24]


class MyCollectionViewCell: UICollectionViewCell {
    // var imageView:UIImageView!
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        // NSLog("#23 MyCollectionViewCell, frame = " + frame.debugDescription)
        // frame 無法修改 ! 他是畫面的寬度除以你的項數, 所以會從零一直累加 67.5 !!
        super.init(frame: frame)
        // 建立一個 UILabel, 預設寬度是畫面的 1/3, 高度 40 點
        titleLabel = UILabel(frame:CGRect(
            x: xpos[i], y: ypos[i], width: w, height: 30))
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.red
        addSubview(titleLabel)
        // NSLog("#32 i = " + i.description + " x =" + xpos[i].description)
        i = i + 1
        if i > 5 {
            i = 0
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        // print(" -- init -- ")
        i = 0
        }
        /*required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        }*/
    func reset_index() {
        i = 0
    }
}
