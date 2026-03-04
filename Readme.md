# 應用類神經網路於缺血性腦中風之中醫診療輔助應用程式開發
此為碩士研究論文之公開程式資料, 如果有發現錯誤或不當之處需修正, 請以電子郵件傳送到 :
<disokgone@gmail.com>

## 在取用各種型式的檔案前, 請先自行掃毒, 雖然上傳時都已經完成掃除病毒

## 本研究產生的程式目前適用於下列的幾個作業環境 :
- 微軟 Windows 視窗系統 (Basic 程式仰賴 PureBasic 產生可執行檔)
- 蘋果 macOS (Basic 程式仰賴 PureBasic 產生可執行檔 .app)
- 蘋果 iOS 系統 (由 XCode 編譯 swift 程式)
- Android 安卓手機或平板 (Java 與 C 程式編譯成為 .apk 程式)
- Linux 和樹莓派的愛好者可以自行修改原始程式以適用於特定環境需求


## PureBasic 可由 https://www.purebasic.com/ 下載
試用版僅允許 800 行原始程式碼, 因此本研究的程式必須拆分成幾個小程式來分段執行.

## 各目錄說明:
- /android 擺放Android 安卓手機或平板 (目前為 apk 檔案與 zip 原始程式壓縮檔), apk 檔案可以自行下載到手機安裝
- /BinData 內容是已經完成訓練的有效 AI 類神經網路訓練儲存資料, 有分成 Big5 及 UTF8 兩個目錄, Big5 目錄的檔案適用於微軟 Windows 視窗系統, UTF8 目錄的檔案適用於 macOS/Linux/Raspberry 系統, 請自行拷貝檔案到適當的位置 (微軟 Windows 視窗系統請把 Big5 目錄的檔案放在產生 TxStroke.exe 的相同目錄下; macOS 系統請把 UTF8 目錄的檔案放在產生 TxStroke.app 的相同目錄下, 勿擺進 app 的內層目錄, 會造成其他程式無法讀取其內容)
- /ios 其內容是供 XCode 開啟並編譯的 swift 程式碼, 不同版本的 XCode 能產生的 iphone/ipad 程式有很大的差異, 如需在真實手機或平板執行, 需花一百美金加入蘋果開發者網站來建立並取得權證授權.
- /macos 裡面有許多延伸檔名為 .pb 的 Basic 程式, 這些程式需要安裝 PureBasic 才可以執行或編譯產生 .app (執行時請拷貝 /BinData/UTF8 下的一群 .BIN 檔案到與 .pb 相同的目錄下, 方能運作類神經網路獲得資訊)
- /pc 裡面有許多延伸檔名為 .pb 的 Basic 程式, 這些程式需要安裝 PureBasic 才可以執行或編譯產生 .exe (執行時請拷貝 /BinData/Big5 下的一群 .BIN 檔案到與 .pb 相同的目錄下, 方能運作類神經網路獲得資訊) ** 注意: 在中國大陸或其他需要 UTF8 語系者, 請參考 /macos 的 .pb 程式, 稍作修改並拷貝 /BinData/UTF8 下的一群 .BIN 檔案到與 .pb 相同的目錄下, 謝謝 !!
- /training_text 內容是本研究提供訓練 AI 類神經網路的原始資料, 有分成 Big5 及 UTF8 兩個目錄, 訓練後儲存的檔案即是與 /BinData 內容一致

