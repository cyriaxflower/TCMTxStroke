//
//  ViewController.swift
//  tcm_ios
//
//  Created by jurng chen su on 2025/6/23.
// https://itisjoe.gitbooks.io/swiftgo/content/uikit/uicollectionview.html

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    var ann_file: String = ""
    var filename: String = ""
    var six_sym: String = ""
    var myCollectionView: UICollectionView? = nil
    var myTextView: UITextView? = nil
    var choosen: Bool = false
    var table1_simple: Bool = false
    var table2_added: Bool = false
    var table2_type: Int = 0
    var label_str: String = ""
    var last_segue: UIStoryboardSegue!
    var fullScreenSize :CGRect!
    var symptomType: [String] = ["風證", "火熱證", "痰證", "血瘀證", "氣虛證", "陰虛陽亢證"]
    var symptomList: [String] = ["48 小時達到高峰 (風證2分)", "24小時達到高峰 (風證4分)",  "病情數變 (風證8分)",
                                 "發病即達高峰 (風證8分)", "兩手握固或口嘴不開 (風證3分)",  "肢體抽動 (風證5分)", "肢體拘急或頸項強急（風證7分)",
                                 "舌體頗抖 (風證5分)",  "舌體歪斜且頗抖 (風證7分)", "目珠遊動或目偏不瞬 (風證3分)", "脈弦 (風證3分)",
                                 "頭暈或頭痛如顛 (風證1分)", "頭暈目眩 (風證2分)", "舌質紅 (火熱證5分)",  "舌紅絳 (火熱證6分)",
                                 "舌苔薄黃 (火熱證2分)", "舌苔黃厚 (火熱證3分)", "舌苔乾燥 (火熱證4分)", "舌苔灰黑乾燥 (火熱證6分)",
                                 "大便乾大便難 (火熱證2分)", "大便乾3日未解 (火熱證3分)", "大便乾5日以上未解 (火熱證4分)", "神情: 心煩易怒 (火熱證2分)",
                                 "神情: 躁擾不寧 (火熱證3分)", "神情: 神昏譫語 (火熱證4分)", "聲高氣粗或口唇乾紅 (火熱證2分)", "面紅目赤或氣促口臭 (火熱證3分)",
                                 "發熱 (火熱證3分)", "脈數大有力或弦數或滑數 (火熱證2分)", "口苦咽乾 (火熱證1分)", "渴喜冷飲 (火熱證2分)",
                                 "尿短赤 (火熱證1分)", "口多粘涎 (痰證2分)", "咯痰或嘔吐痰涎 (痰證4分)", "痰多而粘 (痰證6分)",
                                 "鼻鼾痰鳴 (痰證8分)", "舌苔膩或水滑 (痰證6分)", "舌苔厚膩 (痰證8分)", "舌體胖大 (痰證4分)",
                                 "舌體胖大多齒痕 (痰證6分)", "表情淡漠或寡言少語 (痰證2分)", "神情呆滯或反應遲鈍或嗜睡 (痰證8分)", "脈滑或濡 (痰證3分)",
                                 "頭昏沉 (痰證1分)", "體胖臃腫 (痰證1分)", "舌背脈絡盛張青紫 (血瘀證4分)", "舌質紫暗 (血瘀證5分)",
                                 "舌質有瘀點 (血瘀證6分)", "舌質有瘀斑 (血瘀證8分)", "舌質青紫 (血瘀證9分)", "頭痛而痛處不移 (血瘀證5分)",
                                 "頭痛如針刺或如炸裂 (血瘀證7分)", "肢痛不移 (血瘀證5分)", "爪甲青紫 (血瘀證6分)", "瞼下青黑 (血瘀證2分)",
                                 "口唇紫暗 (血瘀證3分)", "口唇紫暗且面色晦暗 (血瘀證5分)", "脈沉弦細 (血瘀證1分)", "脈沉弦遲 (血瘀證2分)",
                                 "脈澀或結代 (血瘀證3分)", "高黏滯血症 (血瘀證5分)", "舌淡 (氣虛證3分)", "舌胖大 (氣虛證4分)",
                                 "胖大邊多齒痕或舌痿 (氣虛證5分)", "神疲乏力或少氣懶言 (氣虛證1分)", "語聲低怯或咳聲無力 (氣虛證2分)", "倦息嗜臥 (氣虛證3分)",
                                 "鼻鼾細微 (氣虛證4分)", "稍動則汗出 (氣虛證2分)", "安靜時汗出 (氣虛證3分)", "冷汗不止 (氣虛證4分)",
                                 "大便溏或初硬後溏 (氣虛證1分)", "小便自遺 (氣虛證2分)", "二便自遺 (氣虛證4分)", "手足腫脹 (氣虛證2分)",
                                 "肢體癱軟 (氣虛證3分)", "手撇肢冷 (氣虛證4分)", "活動較多時心悸 (氣虛證1分)", "輕微活動即心悸 (氣虛證2分)",
                                 "安靜時常心悸 (氣虛證3分)", "面白 (氣虛證1分)", "面白且面色虛浮 (氣虛證3分)", "脈沉細或遲緩或脈虛 (氣虛證1分)",
                                 "脈結代 (氣虛證2分)", "脈微 (氣虛證3分)", "舌體瘦 (陰虛陽亢證3分)", "舌瘦而紅 (陰虛陽亢證4分)",
                                 "舌瘦而紅乾 (陰虛陽亢證7分)", "舌瘦而紅乾多裂 (陰虛陽亢證9分)", "舌苔少或剝脫苔 (陰虛陽亢證5分)", "舌光紅無苔 (陰虛陽亢證7分)",
                                 "心煩易怒 (陰虛陽亢證1分)", "心煩不得眠 (陰虛陽亢證2分)", "躁擾不寧 (陰虛陽亢證3分)", "頭暈目眩 (陰虛陽亢證2分)",
                                 "盜汗 (陰虛陽亢證2分)", "耳鳴 (陰虛陽亢證2分)", "午後顴紅或面部烘熱或手足心熱 (陰虛陽亢證2分)",
                                 "咽乾口燥或兩目乾澀或便乾尿少(陰虛陽亢證2分)", "弦細或細數 (陰虛陽亢證1分)"]
    var six_pat_types:[Int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
                            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5,
                            5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]
    var six_pat_scores:[Int] = [2, 4, 8, 8, 3, 5, 7, 5, 7, 3, 3, 1, 2, 5, 6, 2, 3, 4, 6, 2, 3, 4, 2, 3, 4, 2, 3, 3, 2, 1, 2, 1, 2, 4,
                             6, 8, 6, 8, 4, 6, 2, 8, 3, 1, 1, 4, 5, 6, 8, 9, 5, 7, 5, 6, 2, 3, 5, 1, 2, 3, 5, 3, 4, 5, 1, 2, 3, 4, 2,
                             3, 4, 1, 2, 4, 2, 3, 4, 1, 2, 3, 1, 3, 1, 2, 3, 3, 4, 7, 9, 5, 7, 1, 2, 3, 2, 2, 2, 2, 2, 1]
    var lab_group: [Bool] = []      // 醫學檢驗數據範圍的按鈕狀態
    var six_group: [Bool] = []      // 六大證型的按鈕狀態複雜版
    var six_group2: [Bool] = []     // 六大證型的按鈕狀態縮減版
    var six_group_score: [Int] = []    // 六大證型複雜版的總得分狀態
    var six_scores: [Int8] = [0, 0, 0, 0, 0, 0]     // 六大證型總得分狀態, 準備轉為 8 bytes (unsigned char)
    var tcm_group: [Bool] = []      // 其他中醫證型的按鈕狀態
    var pat_extra: [String] = ["風寒", "風熱", "風濕", "風寒濕", "陰陽兩虛證", "脾虛痰濕證", "頭部取穴", "上肢癱取穴", "下肢癱取穴",
                               "智三針", "腦三針", "顳三針", "舌三針", "小腦新區", "四神聰", "中風急性期，風痰瘀血，痹阻脈絡",
                               "中風恢復期，陰虛陽亢，脈絡瘀阻",  "真寒", "元陰匱乏", "血虛"]         // 其他中醫證型 -> CH0001 ~ CH00xx
    var pat_labs: [String] = ["貧血", "血色素過高", "紅血球增生症", "白血球增多症", "白血球低下症",
                              "肝功能 GPT 過高", "肝功能 gamma-GT 過高", "腎功能肌肝酸 creatinine 過高", "鉀離子過高", "鉀離子過低",
                              "鈉離子過高", "鈉離子過低", "白血球計數 > 13,000/立方釐米", "白血球計數 13,000 ~ 10,000/立方釐米", "白血球計數 10,000 ~  7,000/立方釐米",
                              "白血球計數  7,000 ~  5,000/立方釐米", "白血球計數  < 5,000/立方釐米", "紅血球血色素 > 15 g/dl", "紅血球血色素 13 ~ 15 g/dl", "紅血球血色素 10 ~ 13 g/dl",
                              "紅血球血色素  7 ~ 10 g/dl", "紅血球血色素  < 7 g/dl", "** NIHSS 中風傷害量表 得分範圍: 0 - 42 分", "NIHSS 得 0-14 分 (輕度傷害)", "NIHSS 得 15-29 分 (中度傷害)",
                              "NIHSS 得 30-42 分 (重度傷害)"]      // 實驗室類型 -> LA0001 ~ LA00xx
    // 六大證型 --> 項數 = 6
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symptomType.count
    }
    // 六大證型 --> 逐一填入資料 (六大證型目前總得分)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 依據前面註冊設置的識別名稱 "collectCell" 取得目前使用的 cell
        var str: String
        
        let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "collectCell", for: indexPath)
                as! MyCollectionViewCell
        
        // 設置 cell 內容 (自定義元件增加文字元件) -- 顯示六大證型目前總得分
        str = self.symptomType[indexPath.row]
        if table2_type == 0 {
            str.append(" " + six_group_score[indexPath.row].description)
        } else {
            if six_group2[indexPath.row] {
                str.append(" 100")  // 縮減版, 有點選就給 100 分
            } else {
                str.append(" 0")    // 縮減版, 沒點選, 給 0 分
            }
        }
        str.append(" 分")
        if indexPath.row == 0 {
           
            // cell.reset_index()  // !! 失敗
            // doSaveToPublicDir(ToShare: "This is 測試 ！")

            }
        cell.titleLabel?.text = str
        NSLog("#84 " + indexPath.row.description + cell.titleLabel.frame.debugDescription)
        return cell
    }
    
    @IBAction func btnLabDataTapped(_Sender: Any) {
        // 選擇醫學檢驗數據範圍
        NSLog("選擇醫學檢驗數據範圍 !");
        if table2_type != 3 {
            table2_added = false    // 資料類型不同, 必須重新設定
        }
        table2_type = 3
        switchScreen(screen_id: 3)
        // performSegue(withIdentifier: "ToScene3", sender: self) 因為 Scene3 不在 scope 內
    }
    
    @IBAction func btnNextTapped(_Sender: Any) {
        // 切換至第二畫面
        NSLog("切換至第二畫面 !");
        switchScreen(screen_id: 2)
        // performSegue(withIdentifier: "ToScene2", sender: self)
    }
    
    @IBAction func btnOtherTCMTapped(_Sender: Any) {
        // 選擇其他中醫證型
        NSLog("選擇其他中醫證型 !");
        if table2_type != 2 {
            table2_added = false    // 資料類型不同, 必須重新設定
        }
        table2_type = 2
        switchScreen(screen_id: 3)
    }
    
    @IBAction func btnSwitchModeTapped(_Sender: Any) {
        // 切換簡易/複雜證型
        NSLog("切換簡易/複雜證型 !");
        if table1_simple {
            table2_type = 0     // 切入使用複雜證型, 必須重新設定
            table1_simple = false
        } else {
            table2_type = 1     // 切入使用簡易證型, 必須重新設定
            table1_simple = true
        }
        switchScreen(screen_id: 1)  // 更新畫面
    }
    
    @IBAction func unwindToView1(segue: UIStoryboardSegue) {
        // let sourceVC = segue.source as? ViewController
        // if let data = sourceVC?.last_segue {
        NSLog("SRC = " + (segue.identifier ?? ""));
        // last_segue.perform()
        // }
    }
    
    @IBAction func doneSelect(_Sender: Any) {
        NSLog("#151 done selection ! 請給我答案 ！");
        doRunOnce()     // 取得關於六大證型的建議
        doGetOthers()   // 取得其他中醫證型的建議
        doGetLabs()     // 取得其他檢驗數據的建議
    }
    
    @IBAction func doUnwindSegue(_Sender: Any) {
        NSLog("#156 do unwind segue !");
        exit(0)
    }
    
    func big5ToUTF8(input: String) -> String {
        let cfEncoding = CFStringEncoding(CFStringEncodings.big5.rawValue)
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cfEncoding))
        if let data = input.data(using: encoding) {
                return String(data: data, encoding: .utf8) ?? input
            }
        return input    // 無法解碼，則傳回原本輸入的字串
    }
    
    // 取得檢驗數據的建議
    func doGetLabs() {
        for i in 1...pat_labs.count {
            if lab_group[i-1] { // 某個檢驗數據有被選擇！ 檔案編號從 1 開始
                filename = "LA"
                let num_str = i.description
                switch num_str.count { // 前面補零
                    case 1: filename = filename + "000" + num_str
                    case 2: filename = filename + "00" + num_str
                    case 3: filename = filename + "0" + num_str
                default:
                    filename = filename + num_str
                }
                
                if let fileURL = Bundle.main.url(forResource: filename, withExtension: "BIN") {
                    print("Good! File contents: \(fileURL)")
                    ann_file = fileURL.absoluteString
                    // 得到： file:///Users/happysu/Library/Developer/CoreSimulator/Devices/8D9BC302-0DE1-4F79-B14E-76911B8F31CF/data/Containers/Bundle/Application/C70AA070-8DD7-482E-8145-A4811CAE91C6/tcm_ios.app/LA00xx.BIN
                    ann_file.removeFirst(7)
                    // !! 在 offset 256 處, 需貼上6 bytes !
                } else {
                    print("File not found in main bundle.")
                }
                // Bundle.main.unload()
                for j in 0...5 {
                    six_scores[j] = 0
                }
                six_scores[0] = 100     // !! 永遠只填第一項為 100 !!
                ann_file.withCString { cStrPtr3 in
                    if six_main(cStrPtr3, six_scores) == 0 {
                        print("傳回 0 代表成功")
                        let cStrPtr3 = ret_six_answer()!
                        NSLog(String(cString: cStrPtr3))
                        let ans_Str3 = pat_labs[i-1] + " 建議：" + big5ToUTF8(input: String(cString: cStrPtr3)) + "\n"
                        if myTextView!.text.isEmpty {
                            myTextView!.text = ans_Str3
                        }
                        else {
                            myTextView!.text.append(ans_Str3)
                        }
                    }
                }
            }
        }
    }
    
    // 取得其他中醫證型的建議
    func doGetOthers() {
        for i in 1...pat_extra.count {
            if tcm_group[i-1] { // 某個中醫證型有被選擇！ 檔案編號從 1 開始
                filename = "CH"
                let num_str = i.description
                switch num_str.count { // 前面補零
                    case 1: filename = filename + "000" + num_str
                    case 2: filename = filename + "00" + num_str
                    case 3: filename = filename + "0" + num_str
                default:
                    filename = filename + num_str
                }
                
                if let fileURL = Bundle.main.url(forResource: filename, withExtension: "BIN") {
                    print("Good! File contents: \(fileURL)")
                    ann_file = fileURL.absoluteString
                    // 得到： file:///Users/happysu/Library/Developer/CoreSimulator/Devices/8D9BC302-0DE1-4F79-B14E-76911B8F31CF/data/Containers/Bundle/Application/C70AA070-8DD7-482E-8145-A4811CAE91C6/tcm_ios.app/CH00xx.BIN
                    ann_file.removeFirst(7)
                    // !! 在 offset 256 處, 需貼上6 bytes !
                } else {
                    print("File not found in main bundle.")
                }
                // Bundle.main.unload()
                for j in 0...5 {
                    six_scores[j] = 0
                }
                six_scores[0] = 100     // !! 永遠只填第一項為 100 !!
                ann_file.withCString { cStrPtr2 in
                    if six_main(cStrPtr2, six_scores) == 0 {
                        print("傳回 0 代表成功")
                        let cStrPtr2 = ret_six_answer()!
                        NSLog(String(cString: cStrPtr2))
                        let ans_Str2 = pat_extra[i-1] + " 建議：" + big5ToUTF8(input: String(cString: cStrPtr2)) + "\n"
                        if myTextView!.text.isEmpty {
                            myTextView!.text = ans_Str2
                        }
                        else {
                            myTextView!.text.append(ans_Str2)
                        }
                    }
                }
            }
        }
    }
    
    // 取得關於六大證型的建議
    func doRunOnce() {
        // let ann_file = "/AN100100.BIN"
        six_sym = ""    // 你所選的六大證型
        filename = "AN"
        if table1_simple {  // 簡易證型
            for i in 0...5 {
                if six_group2[i] {
                    six_scores[i] = 100
                    filename = filename + "1"
                    six_sym = six_sym + " " + symptomType[i]
                }
                else {
                    six_scores[i] = 0
                    filename = filename + "0"
                }
            }
        }
        else {  // 複雜證型 (101 項)
            for i in 0...5 {
                six_scores[i] = Int8(six_group_score[i])
                if six_scores[i] > 69 {
                    filename = filename + "1"
                    six_sym = six_sym + " " + symptomType[i]
                }
                else {
                    filename = filename + "0"
                }
            }
        }
        // six_scores[0] = 90
        // six_scores[3] = 90

        if let fileURL = Bundle.main.url(forResource: filename, withExtension: "BIN") {
            // let fileContents = try String(contentsOf: fileURL, encoding: .ascii)
            print("Good! File contents: \(fileURL)")
            ann_file = fileURL.absoluteString
            // 得到： file:///Users/happysu/Library/Developer/CoreSimulator/Devices/8D9BC302-0DE1-4F79-B14E-76911B8F31CF/data/Containers/Bundle/Application/C70AA070-8DD7-482E-8145-A4811CAE91C6/tcm_ios.app/AN100100.BIN
            ann_file.removeFirst(7)
            // !! 在 offset 256 處, 需貼上6 bytes !
        } else {
            print("File not found in main bundle.")
        }
        // Bundle.main.unload()
        
        let home_path = NSHomeDirectory()
        
        home_path.withCString { cStringPointer in
            set_HOME_path(cStringPointer)
        }
        // let cStrPtr = ret_answer()!
        // print(String(cString: cStrPtr))  // as Any 會印出 Optional(0x000...) --> 記憶體位址
        // cell.titleLabel?.frame.origin.x
        
        ann_file.withCString { cStrPtr1 in
            if six_main(cStrPtr1, six_scores) == 0 {
                print("傳回 0 代表成功")
                let cStrPtr1 = ret_six_answer()!
                // let str = string.withCString(cStrPtr3)
                // let str = String(data: cStrPtr3, encoding: .big5)
                NSLog(String(cString: cStrPtr1))
                // NSLog(str ?? "null str")
                myTextView!.text = "[" + six_sym + "] 建議：" + big5ToUTF8(input: String(cString: cStrPtr1)) + "\n"
                // "[風證 --> 黃耆桂枝五物湯]"
                // myTextView.text = big5ToUTF8(input: String(cString: cStrPtr3))
                // big5ToUTF8(input: String(cString: cStrPtr3))
            }
        }
    }
    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//    }
    
    func doSaveToPublicDir(ToShare: Any) {
        // 跳出迸現視窗來儲存物件到公共目錄 text to share (Good 可以儲存到公共目錄裡)
        // 例子：let text = "This is some text that I want to share.
        //      let objToShare = [ text ]
        // 例子：let image = UIImage(named: "Image")
        //      let objToShare = [ image! ]
        
        // set up activity view controller
        let objToShare = [ ToShare ]
        let activityViewController = UIActivityViewController(activityItems: objToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter ]
        // not post to FB --> UIActivity.ActivityType.postToFacebook
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func unwindToPrevScene(_ unwindSegue: UIStoryboardSegue) {
        last_segue = unwindSegue
        NSLog("切換至第ㄧ畫面 !")  // 把第二畫面的 [Exit] 指定到本函數 !
        table2_type = 0
        // unwindToView1(segue: last_segue)
    }
    
    func switchScreen(screen_id: Int) { // 切換至第三畫面
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // unwindToPrevScene( UIStoryboardSegue(identifier: "unwindTo1", source: self, destination: self))
        // unwindToPrevScene( UIStoryboardSegue(identifier: "unwindTo1", source: self, destination: self))
        // performSegue(withIdentifier: "unwindTo1", sender: 0)
        if screen_id == 1 {
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Scene1") as? UIViewController {
                if self.table2_type > 1 {
                    self.dismiss(animated: true) {
                    // Now present the new view controller
                    self.present(viewController, animated: true, completion: nil)
                    }
                }
                add_1st_TableView(vc: viewController)
                myCollectionView?.reloadData()
            }
        }
        if screen_id == 2 {
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Scene2") as? UIViewController {
                // _ = viewController.view.viewWithTag(3)
                myTextView = UITextView(frame: CGRect(
                    x: 0, y: 300,
                    width: fullScreenSize.width,
                    height: fullScreenSize.height - 400))
                myTextView?.text = "最終建議：\n"
                myTextView?.backgroundColor = UIColor.white
                myTextView?.textColor = UIColor.black
                myTextView?.font = UIFont.systemFont(ofSize: 20.0)
                viewController.view.addSubview(myTextView!)
                self.dismiss(animated: true) {
                    // Now present the new view controller
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
        if screen_id == 3 {
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Scene3") as? UIViewController {
                self.dismiss(animated: true) {
                    // Now present the new view controller
                    self.present(viewController, animated: true, completion: nil)
                }
                // 在切換畫面時，檢查並臨時添加此 第二個 TableView
                if table2_added == false {
                    table2_added = true
                    add_2nd_TableView(vc: viewController)
                }
                // self.present(viewController, animated: false, completion: nil)
                // performSegue(withIdentifier: "ToScene3", sender: 0)
            }
        }
    }
    
    func add_1st_TableView(vc: UIViewController) {
        // ----------- 第ㄧ個 Table View -----------
        // 建立 UITableView 並設置原點及尺寸
        // --- Exit button 的底部位置 = 131 + 38 = 169 ---
        let myTableView = UITableView(frame: CGRect(
            x: 0, y: 210,
            width: fullScreenSize.width,
            height: fullScreenSize.height - 230),
                                      style: .grouped)
        
        // 註冊 table view cell
        myTableView.register(
            UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        
        // 設置委任對象
        myTableView.delegate = self
        myTableView.dataSource = self
        
        // 分隔線的樣式
        myTableView.separatorStyle = .singleLine
        
        // 分隔線的間距 四個數值分別代表 上、左、下、右 的間距
        myTableView.separatorInset =
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // 是否可以點選 cell
        myTableView.allowsSelection = true
        
        // 是否可以多選 cell
        myTableView.allowsMultipleSelection = false
        
        // 加入到畫面中
        self.view.addSubview(myTableView)
    }
    
    func add_2nd_TableView(vc: UIViewController) {
        // ----------- 第二個 Table View -----------
        // switchScreen(screen_id: 3) 在切換畫面時，檢查並臨時添加此 TableView
        let myTableView2 = UITableView(frame: CGRect(
            x: 0, y: 60,
            width: fullScreenSize.width - 1,
            height: fullScreenSize.height - 120),
                                       style: .grouped)
        
        // 註冊 table view cell 2
        myTableView2.register(
            UITableViewCell.self, forCellReuseIdentifier: "tableCell2")
        
        // 設置委任對象 (self = 目前主要的 ViewController)
        myTableView2.delegate = self
        myTableView2.dataSource = self
        
        // 分隔線的樣式
        myTableView2.separatorStyle = .singleLine
        
        // 分隔線的間距 四個數值分別代表 上、左、下、右 的間距
        myTableView2.separatorInset =
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // 是否可以點選 cell
        myTableView2.allowsSelection = true
        
        // 是否可以多選 cell
        myTableView2.allowsMultipleSelection = false
        
        // 加入到畫面中
        vc.view.addSubview(myTableView2)
        // switchScreen(screen_id: 1)
    }
    
    // 需傳回 TableView 的項數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if table2_type == 0 {   // 是六大證型複雜版
            NSLog("#253  六大證型複雜版, 一百多個證狀, 項數 = " + symptomList.count.description);
            return symptomList.count
        }
        if table2_type == 1 {   // 是六大證型縮減版
            return symptomType.count   // = 6
        }
        if table2_type == 2 {   // 是中醫其他證型
            NSLog("#260 中醫其他證狀, 項數 = " + pat_extra.count.description);
            return pat_extra.count
        }
        if table2_type == 3 {   // 醫學檢驗數據範圍
            NSLog("#264 醫學檢驗數據範圍, 項數 = " + pat_labs.count.description);
            return pat_labs.count
        }
        return 0
    }
    
    @objc func switchChanged(_ sender : UISwitch!) {
        var score: Int = 0
        var six_type: Int = 0
        
        print("table row switch Changed \(sender.tag)")
        if table2_type == 0 {   // 是六大證型複雜版
            six_group[sender.tag]    = sender.isOn      // 更正按鈕陣列內值
            six_type = six_pat_types[sender.tag] - 1    // 得知是修改哪個證型的類別
            score = six_group_score[six_type]
            if sender.isOn { // 從 off 變成 on --> 增加該項目的分數
                score = score + six_pat_scores[sender.tag]
            } else {    // 從 on 變成 off --> 扣除該項目的分數
                score = score - six_pat_scores[sender.tag]
            }
            six_group_score[six_type] = score
            myCollectionView?.reloadData()
        }
        if table2_type == 1 {   // 是六大證型縮減版
            six_group2[sender.tag]   = sender.isOn     // 更正按鈕陣列內值
            myCollectionView?.reloadData()
        }
        if table2_type == 2 {   // 是中醫其他證型
            tcm_group[sender.tag]    = sender.isOn      // 更正按鈕陣列內值
        }
        if table2_type == 3 {   // 是醫學檢驗數據範圍
            // !!@@ 需添加按鈕項目互斥檢查功能 及 ** 開頭項目 不可按選的功能
            lab_group[sender.tag]    = sender.isOn      // 更正按鈕陣列內值
        }
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        // tableView.reloadData() // 更新tableView
    }
    
    // 一百多個證狀 --> 逐一填入資料
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 依據前面註冊設置的識別名稱 "tableCell" 取得目前使用的 cell
        NSLog("#396 table2_type = " + table2_type.description)
        if table2_type < 2 { // 是六大證型
            NSLog("#398 一百多個證狀 --> 逐一填入資料, index = " + indexPath.row.description);
            let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "tableCell", for: indexPath) as
                UITableViewCell
            if table2_type == 0 {
                cell.textLabel?.text = self.symptomList[indexPath.row]
                choosen = six_group[indexPath.row]     // 取得按鈕陣列內值
            }
            if table2_type == 1 {
                cell.textLabel?.text = self.symptomType[indexPath.row]
                choosen = six_group2[indexPath.row]     // 取得按鈕陣列內值
            }
            let switchView = UISwitch(frame: .zero)
                switchView.setOn(choosen, animated: true)
                switchView.tag = indexPath.row  // for detect which row switch Changed
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        }
        NSLog("#418 其他證狀 --> 逐一填入資料, index = " + indexPath.row.description + ", type = " + table2_type.description);
        if table2_type == 2 {
                label_str = pat_extra[indexPath.row]
                choosen = tcm_group[indexPath.row]      // 取得其他中醫證型按鈕陣列內值
                NSLog("#422 ndx = " + indexPath.row.description + " , chosen = " + choosen.description)
        }
        if table2_type == 3 {
            label_str = pat_labs[indexPath.row]
            choosen = lab_group[indexPath.row]      // 取得醫學檢驗數據範圍按鈕陣列內值
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "tableCell2", for: indexPath) as
            UITableViewCell
        cell.textLabel?.text = label_str
        let switchView = UISwitch(frame: .zero)
            switchView.tag = indexPath.row  // for detect which row switch Changed
            switchView.setOn(choosen, animated: true)
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender);
        NSLog("----- #442 prepare 每按下「我選好了，請進行下一步」按鈕，便執行一次 ----- " + segue.identifier!)
        if case segue.identifier = "ToScene2" {
            last_segue = segue;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 取得螢幕的尺寸
        NSLog("----- #452 viewDidLoad 只執行一次 ----- ")
        six_group = Array(repeating: false, count: symptomList.count)   // 起始 六大證型複雜版 的按鈕陣列 （all zero)
        six_group2 = Array(repeating: false, count: symptomType.count)  // 起始 六大證型縮減版 的按鈕陣列 （all zero)
        six_group_score = Array(repeating: 0, count: symptomType.count) // 起始 六大證型複雜版 的總得分陣列 （all zero)
        lab_group = Array(repeating: false, count: pat_labs.count)      // 起始 醫學檢驗數據範圍 的按鈕陣列 （all zero)
        tcm_group = Array(repeating: false, count: pat_extra.count)     // 起始 其他中醫證型 的按鈕陣列 （all zero)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            print("螢幕的尺寸", windowScene.screen.bounds)
            fullScreenSize = windowScene.screen.bounds
        }
        // get UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        // myTextView.text = "123"
        // fullScreenSize.height - 20
        myCollectionView = UICollectionView(frame: CGRect(
              x: 0, y: 160,
              width: fullScreenSize.width,
              height: 100),
            collectionViewLayout: layout)
        
        // 註冊 my collection view cell 以供後續重複使用
        myCollectionView?.register(
          MyCollectionViewCell.self,
          forCellWithReuseIdentifier: "collectCell")
        
        // 設置委任對象
        myCollectionView?.delegate = self
        myCollectionView?.dataSource = self

        // 加入畫面中
        self.view.addSubview(myCollectionView!)
        switchScreen(screen_id: 1)
    }


    

    // 實作TableView方法，自動出現左滑功能
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath)
    {
        let select:Int = indexPath.row  // 按下紅色區域, 此處會傳回 2
        NSLog("----- #497 " + select.description)
        //=========
        // 操作
        //=========
        tableView.reloadData() // 更新tableView
    }
    
     // 自訂delete的文字為刪除
    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath)
                    -> String?
    {
        return "切換選擇"
    }

}

