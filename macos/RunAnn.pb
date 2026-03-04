; !! 此為 Mac 用的版本 !!
; --------- 六大證型名稱 --> group_id()
DataSection
  Data.s  "此為空白", "      風證     ", "    火熱證   ", "      痰證     ", "    血瘀證    ", "    氣虛證    ", "陰虛陽亢證"
  Data.i  0,  58, 56, 59, 74, 63, 52
  ; ---- 其他中醫證型 ---- 此小區塊的資料必須與 AnnCht.pb 的內容相符 !
  Data.s  "風寒", "風熱", "風濕", "風寒濕", "陰陽兩虛證", "脾虛痰濕證", "頭部取穴", "上肢癱取穴", "下肢癱取穴"
  Data.s  "智三針", "腦三針", "顳三針", "舌三針", "小腦新區", "四神聰", "中風急性期，風痰瘀血，痹阻脈絡"
  Data.s  "中風恢復期，陰虛陽亢，脈絡瘀阻",  "真寒", "元陰匱乏", "血虛", "end"
  ; ---- 其他中醫證型的參數別名 ---- 此小區塊的資料必須與 AnnCht.pb 的內容相符 !
  Data.s "windcold", "windhot", "windwet", "windcoldwet", "yinyanglow", "splowsputwet", "headaccp", "upperaccp", "loweraccp"
  Data.s "wisdom3", "brain3", "tempor3", "tongue3", "newcerbel", "4wise", "acuteCVA"
  Data.s "recoverCVA", "realcold", "low_neg", "low_blood", "end"
  ; ---- 其他檢驗數據 ---- 此小區塊的資料必須與 AnnLab.pb 的內容相符 !
  Data.s  "貧血", "血色素過高", "紅血球增生症", "白血球增多症", "白血球低下症"
  Data.s  "肝功能 GPT 過高", "肝功能 gamma-GT 過高", "腎功能肌肝酸 creatinine 過高", "鉀離子過高", "鉀離子過低"
  Data.s  "鈉離子過高", "鈉離子過低", "白血球計數 > 13,000/立方釐米", "白血球計數 13,000 ~ 10,000/立方釐米", "白血球計數 10,000 ~  7,000/立方釐米"
  Data.s  "白血球計數  7,000 ~  5,000/立方釐米", "白血球計數  < 5,000/立方釐米", "紅血球血色素 > 15 g/dl", "紅血球血色素 13 ~ 15 g/dl", "紅血球血色素 10 ~ 13 g/dl"
  Data.s  "紅血球血色素  7 ~ 10 g/dl", "紅血球血色素  < 7 g/dl", "** NIHSS 中風傷害量表 得分範圍: 0 - 42 分", "NIHSS 得 0-14 分 (輕度傷害)", "NIHSS 得 15-29 分 (中度傷害)"
  Data.s  "NIHSS 得 30-42 分 (重度傷害)", "end"
  ; ---- 檢驗數據的運算數據檔案 ---- 此小區塊的資料必須與 AnnLab.pb 的內容相符 !
  Data.s  "anemia", "hb_h", "rbc_h", "wbc_h", "wbc_l"
  Data.s  "gpt_h", "ggt_h", "cr_h", "k_h", "k_l"
  Data.s  "na_h", "na_l", "wbc_hh", "wbc_h", "wbc_m"
  Data.s  "wbc_n", "wbc_l", "rbc_h", "rbc_n", "rbc_l"
  Data.s  "rbc_ll", "rbc_lll", "**", "nihss_l", "nihss_m"
  Data.s  "nihss_h", "end"
  ; ---- 中醫證型的 單選區間 ---- 放兩個數字為一組, 如果只有放  -1 代表此陣列範圍內的項目皆是獨立的單選, -1 是一個終止記號
  Data.i  -1
  ; ---- 檢驗數據的 單選區間 ---- 放兩個數字為一組, 例如 12, 16 代表此陣列範圍內的第 12 項至第 16 項是單選區塊, 裡面不允許多選 !
  Data.i  12, 16, 17, 21, 23, 25, -1
EndDataSection

; use 6 character (0 or 1) in file name for -- "風證 58 分", "火熱證 56 分", "痰證 59 分", "血瘀證 74 分", "氣虛證 63 分", "陰虛陽亢證 52 分"
; ANN0xx.BIN (位元組合 hex xx = 0x00 - 0x3F for 風證=0x20, 火熱證=0x10, 痰證=8, 血瘀證=4, 氣虛證=2, 陰虛陽亢證=1)
; 如果該對應檔案不存在, 則顯示尚未建立該證型資料
Dim group_score.i(7)    ; 六大證型目前得到幾分
Dim max_score.i(7)      ; 六大證型總分
Dim group_id.s(7)        ; 六大證型名稱
Dim chdxgrp.s(100)     ; 最多可容納 100 組額外的中醫證型
Dim chdxdat.s(100)      ; 最多可容納 100 組額外的中醫證型神經運算檔名資料
Dim chdxPairA.i(20)    ; 最多可容納  20 組中醫證型單選範圍 A: 開頭
Dim chdxPairB.i(20)    ; 最多可容納  20 組中醫證型單選範圍 B: 結尾
Dim chdxPairN.i(20)    ; 最多可容納  20 組檢驗數據單選範圍 N: 目前點選哪項 (< 0 代表完全沒點選)
Dim lab_grp.s(100)      ; 最多可容納 100 組額外的檢驗數據
Dim lab_dat.s(100)      ; 最多可容納 100 組額外的檢驗數據神經運算檔名
Dim lab_last_click.b(100)   ; 保存前次有點選的檢驗數據項目 (1= 有點選, 0= 未點選)
Dim labPairA.i(20)      ; 最多可容納  20 組檢驗數據單選範圍 A: 開頭
Dim labPairB.i(20)      ; 最多可容納  20 組檢驗數據單選範圍 B: 結尾
Dim labPairN.i(20)      ; 最多可容納  20 組檢驗數據單選範圍 N: 目前點選哪項 (< 0 代表完全沒點選)

Global chdx_count = 0, lab_grp_count = 0    ; 中醫證型_項目總數,                檢驗數據_項目總數
Global chdx_sel = 0, lab_grp_sel = 0            ; 中醫證型_選定項目總數,         檢驗數據_選定項目總數
Global chdx_intv_cnt = 0, lab_intv_cnt = 0   ; 中醫證型_單選區間的成對數, 檢驗數據_單選區間的成對數
Global iCnt = 0, item_ndx, b_List_0_done = 0, b_List_1_done = 0, debug_on = 0
Global lab_last_new_click = -1       ; 0~99 為新 "點選" 的檢驗數據項目編號 (-1 = 無動作)

; 所有的 i, j, k.. 之類的區域變數, 只限用於局部函數內部的 For-Loop, 不可跨越到其他函數, 以免發生錯誤 !

XIncludeFile "Form2.pbf"          ; 視窗標題: 類神經網路輔助中醫治療缺血性中風
XIncludeFile "FormCD.pbf"       ; 視窗標題: 其他中醫證型勾選選單
XIncludeFile "FormLab.pbf"      ; 視窗標題: 其他檢驗數據勾選選單
XIncludeFile "Answer.pbf"        ; 視窗標題: 綜合建議
OpenWindow_0()                   ; 開啟 主要視窗, 標題: 類神經網路輔助中醫治療缺血性中風
; 下面三個視窗, 開啟後先暫時隱藏
OpenWindow_1()
HideWindow(Window_1, #True)    ; hide "我要勾選其他中醫證型"
OpenWindow_2()
HideWindow(Window_2, #True)    ; hide "我要勾選其他檢驗數據"
OpenWindow_3()
HideWindow(Window_3, #True)    ; hide "綜合建議"

curDir2$ = GetCurrentDirectory()     ; 目前本程式執行檔所在的目錄
; curDir2$ = /Users/(使用者名稱)/Documents/PureBasic/RunAnn.app/Contents/
inside_app = FindString(curDir2$, "Contents")
If inside_app > 0   ; 目前位於 app 裡面 !!
  curDir2$ = Mid(curDir2$, 1, inside_app - 12)  ; 目錄倒退, 跳回 PureBasic 目錄
EndIf

If OpenFile(19, curDir2$ + "EnableDebug", #PB_File_SharedRead)  ; 此檔案的確存在！ --> 允許顯示除錯視窗 !
  debug_on = 1
  CloseFile(19)
EndIf

InPutFileName$ = "SixGroup.BIN"     ; 此檔案儲存了從 TxStroke.exe 保存的使用者所選的六大證型各項的細項與總分
six_score$ = "中醫六大證型得分 :" + Chr(13) + Chr(10)
six_ans$ = ""

file_id = OpenFile(#PB_Any, curDir2$ + InPutFileName$, #PB_File_SharedRead)
If file_id
  file_len = Lof(file_id)
  *DATABUF = AllocateMemory(128)    ; item_count = 101 --> 其實只需 10 + 101 = 111 bytes (準備 128 bytes 已足夠)
  ;  先全部清除
  FillMemory(*DATABUF, 128, 0)
  ReadData(file_id, *DATABUF, file_len)
  ; 在檔案位置 0 的地方開始, 依序取得六大證型得分, 每個證型得分占用 1 byte
  *BytePtr = *DATABUF
  For i = 1 To 6
    group_score(i) = PeekB(*BytePtr)  ; 六大證型得分
    *BytePtr = *BytePtr + 1
  Next i
  
  For i = 0  To 6
    Read.s group_id(i)    ; 六大證型名稱
  Next i
  For i = 0  To 6
    Read.i max_score(i)   ; 六大證型總分
    If i > 0
      score$ = group_id(i) + " 得分 " + Str(group_score(i)) + " 分,"
      six_score$ = six_score$ + Chr(9) + Chr(9) + "[ " + score$ + Chr(9) + Chr(9) + "總分 " + Str(max_score(i)) + " 分 ]" + Chr(13) + Chr(10)
      six_ans$ = six_ans$ + Str(group_score(i)) + "  "  
    EndIf
  Next i
  ; -- 讀取預設 [其他中醫證型] 資料項
  For i = 0  To 99
    Read.s chdxgrp(i)     ; 讀取預設 [其他中醫證型] 資料項
    If chdxgrp(i) = "end"
      chdx_count = i      ; = 總項數 (其他中醫證型)
      Break
    EndIf
    AddGadgetItem(ListView_0, -1, chdxgrp(i))
  Next i
  ; -- 讀取預設 [其他中醫證型] 神經運算檔名資料項
  For i = 0  To 99
    Read.s chdxdat(i)     ; 讀取預設 [其他中醫證型] 神經運算檔名資料項
    If chdxdat(i) = "end"
      Break
    EndIf
  Next i
  ; -- 讀取預設 [其他檢驗數據] 資料項
  For i = 0  To 99
    lab_last_click(i) = 0   ; 清除此資料項為未點選 (1= 有點選, 0= 未點選)
    Read.s lab_grp(i)     ; 讀取預設 [其他檢驗數據] 資料項
    If lab_grp(i) = "end"
      lab_grp_count = i      ; = 總項數 (其他檢驗數據)
      Break
    EndIf
    AddGadgetItem(ListView_1, -1, lab_grp(i))
  Next i
  ; -- 讀取預設 [其他檢驗數據] 神經運算檔名資料項
  For i = 0  To 99
    Read.s lab_dat(i)     ; 讀取預設 [其他檢驗數據] 神經運算檔名資料項
    If lab_dat(i) = "end"
      Break
    EndIf
  Next i
EndIf
  
; ---- 讀取 "成對" 數範圍資料 ---- "成對" 是指用來指定範圍的數字是 [開始位置] 與 [終止位置] 兩個數字是成對出現的, 若遇到  -1 代表範圍的宣告結束
For i = 0 To 19   ; 目前最多只可容納  20 組單選範圍
  chdxPairA(i) = -1   ; -1 代表範圍的宣告結束 (以下類推)
  chdxPairB(i) = -1
  chdxPairN(i) = -1
  labPairA(i) = -1
  labPairB(i) = -1
  labPairN(i) = -1
Next i
; ---- 讀取 中醫證型 "成對" 數範圍資料 ----
For i = 0 To 19
  Read.i temp_i
  If temp_i < 0   ; 遇到負值 (-1) 便結束
    Break
  EndIf
  chdxPairA(i) = temp_i
  Read.i chdxPairB(i)
  chdx_intv_cnt = chdx_intv_cnt + 1   ; "成對" 數範圍的有效組數加 1
Next i
; ---- 讀取 檢驗數據 "成對" 數範圍資料 ----
For i = 0 To 19
  Read.i temp_i
  If temp_i < 0   ; 遇到負值 (-1) 便結束
    Break
  EndIf
  labPairA(i) = temp_i
  Read.i labPairB(i)
  lab_intv_cnt = lab_intv_cnt + 1   ; "成對" 數範圍的有效組數加 1
Next i

SetGadgetText(Editor_0, six_score$)   ; 六大證型總分 & 得分
your_sel$ = " (您尚未選其他中醫證型)"
If chdx_sel > 0
  your_sel$ = " (您選定了" + Str(chdx_sel) + "項其他中醫證型) :"
EndIf
SetGadgetText(Text_2, "其他中醫證型: 共有 " + Str(chdx_count) + " 項" + your_sel$)

your_sel$ = " (您尚未選其他檢驗數據)"
If lab_grp_sel > 0
  your_sel$ = " (您選定了" + Str(lab_grp_sel) + "項其他檢驗數據) :"
EndIf
SetGadgetText(Text_3, "其他檢驗數據: 共有 " + Str(lab_grp_count) + " 項" + your_sel$)

Repeat
  Event = WaitWindowEvent()

  If Event = 3    ; 此為滑鼠有按鍵被按下時, 會先產生的特殊事件 !
    gadget_no = EventGadget()
    Select gadget_no
      Case ListView_0   ; 是其他中醫證型的 listview 被點選了
        item_ndx = GetGadgetState(ListView_0)
        If (DateUTC() - last_click_time) > 0
          the_item$ = GetGadgetItemText(ListView_0, item_ndx)
          If Mid(the_item$, 1, 2) <> "**"   ; 如果開頭是 ** 則不需處理（開頭 ** 是說明訊息）
            If Mid(the_item$, 1, 2) = "V "
              the_item$ = Mid(the_item$, 3)
              SetGadgetItemText(ListView_0, item_ndx, the_item$)
            Else
              the_item$ = "V " + the_item$
              Gosub Do_Unset_0  ; 某些項目是單選 !
              SetGadgetItemText(ListView_0, item_ndx, the_item$)
            EndIf
          EndIf
        EndIf
        Gosub Update_0    ; 重整顯示您所選擇的 [其他中醫證型] 項目
        last_click_time = DateUTC()

      Case ListView_1   ; 是其他檢驗數據的 listview 被點選了
        item_ndx = GetGadgetState(ListView_1)
        If (DateUTC() - last_click_time) > 0
          the_item$ = GetGadgetItemText(ListView_1, item_ndx)
          If Mid(the_item$, 1, 2) <> "**"   ; 如果開頭是 ** 則不需處理（開頭 ** 是說明訊息）
            If Mid(the_item$, 1, 2) = "V "
              the_item$ = Mid(the_item$, 3)
              SetGadgetItemText(ListView_1, item_ndx, the_item$)
            Else
              the_item$ = "V " + the_item$
              Gosub Do_Unset_1  ; 某些項目是單選 !
              SetGadgetItemText(ListView_1, item_ndx, the_item$)
            EndIf
          EndIf
        EndIf
        Gosub Update_1  ; 重整顯示您所選擇的 [其他檢驗數據] 項目
        last_click_time = DateUTC()
    EndSelect    
  EndIf
  
  Select Event
    Case #PB_Event_Gadget
      gadget_no = EventGadget()
      Select gadget_no
        Case Button_0   ; "Exit" 程式直接結束, 不存檔 !
          End 0
        Case Button_1   ;我要勾選其他中醫證型
          HideWindow(Window_1, #False)    ; 顯現 [其他中醫證型]
        Case Button_2   ;我要勾選其他檢驗數據
          HideWindow(Window_2, #False)    ; 顯現 [其他檢驗數據]
        Case Button_3   ;全都選好了請給我建議
          HideWindow(Window_3, #False)    ; 顯現 [綜合建議]
          Gosub Run_All_Jobs      ; 執行所有的類神經網路程式
        Case Button_8   ;將建議存檔後結束本程式
          file$ = OpenFileRequester("Select an empty file to save..","","Text (.txt)|*.txt|All files (*.*)|*.*",0)
          If file$    ; 確定使用者有點選某個檔案來存檔
            If ReadFile(0, file$)
              ; 此檔案的確存在！
              file_len = Lof(0)
              CloseFile(0)
              DeleteFile(file$)   ; 刪除舊檔案
              Fid = CreateFile(#PB_Any, file$, #PB_File_SharedWrite)  ; 新建檔案
              If Fid > 0    ; 建立檔案成功
                ans$ = GetGadgetText(Editor_7)
                WriteStringN(Fid, ans$, #PB_UTF8)   ; 寫出 [六大證型] 建議
                ans$ = GetGadgetText(Editor_8)
                WriteStringN(Fid, ans$, #PB_UTF8)   ; 寫出 [其他中醫證型] 建議
                ans$ = GetGadgetText(Editor_9)
                WriteStringN(Fid, ans$, #PB_UTF8)   ; 寫出 [其他檢驗數據] 建議
              EndIf
              CloseFile(Fid)
              YourSelect = MessageRequester("已經存檔成功！確定要結束本程式 ?" , "現在按下 Yes 將會直接結束本程式 !", #PB_MessageRequester_YesNo)
              If YourSelect = #PB_MessageRequester_Yes
                End 0   ; 按下 Yes ==> 直接結束本程式 !
              EndIf         
            EndIf
          EndIf
        Case Button_9   ;不存檔, 直接結束本程式
          YourSelect = MessageRequester("確定要結束本程式 ?" , "現在按下 Yes 將會直接結束本程式 !", #PB_MessageRequester_YesNo)
          If YourSelect = #PB_MessageRequester_Yes
            End 0   ; 按下 Yes ==> 直接結束本程式 !
          EndIf         
      EndSelect
    Case #PB_Event_CloseWindow
      gadget_no = EventGadget()
      Select gadget_no
        Case Window_1
          HideWindow(Window_1, #True)    ; 隱藏 [其他中醫證型]
          Event = 0         ; 防止程式不慎自我關閉 !
        Case Window_2
          HideWindow(Window_2, #True)    ; 隱藏 [其他檢驗數據]
          Event = 0         ; 防止程式不慎自我關閉 !
        Case Window_3
          HideWindow(Window_3, #True)    ; 隱藏 [綜合建議]
          Event = 0         ; 防止程式不慎自我關閉 !
        EndSelect
  EndSelect
Until Event = #PB_Event_CloseWindow
End 0

Do_Unset_0:
; 某些 中醫證型 項目是單選 !
If chdx_intv_cnt > 0
  For i = 0 To chdx_intv_cnt -1
    If item_ndx >= chdxPairA(i)
      If item_ndx <= chdxPairB(i)
        ; 符合單選區間 ==> 把這區間裡的所有項目開頭的打勾通通去除 !
        For j = chdxPairA(i) To chdxPairB(i)
          itemStr$ = GetGadgetItemText(ListView_0, j)
          If Mid(itemStr$, 1, 2) = "V "
            itemStr$ = Mid(itemStr$, 3)   ; 去除打勾 !
            SetGadgetItemText(ListView_0, j, itemStr$)
          EndIf
        Next j
        Return    ; 某個單選區間已經清理完畢, 可以提前離開
      EndIf
    EndIf
  Next i
EndIf
Return

Do_Unset_1:
; 某些 檢驗數據 項目是單選 !
If lab_intv_cnt > 0
  For i = 0 To lab_intv_cnt -1
    If item_ndx >= labPairA(i)
      If item_ndx <= labPairB(i)
        ; 符合單選區間 ==> 把這區間裡的所有項目開頭的打勾通通去除 !
        For j = labPairA(i) To labPairB(i)
          itemStr$ = GetGadgetItemText(ListView_1, j)
          If Mid(itemStr$, 1, 2) = "V "
            itemStr$ = Mid(itemStr$, 3)   ; 去除打勾 !
            SetGadgetItemText(ListView_1, j, itemStr$)
          EndIf
        Next j
        Return    ; 某個單選區間已經清理完畢, 可以提前離開
      EndIf
    EndIf
  Next i
EndIf
Return

Read_Whole_File:        ; 把 to_open$ 所指定的檔案內容, 統統讀出來, 保存到 ans$ 裡面傳回 !
ans$ = ""
ret = OpenFile(0, curDir2$ + to_open$)  ; to_open$ 是想讀取整個檔案的檔案名稱
If ret > 0
  If ReadFile(0, curDir2$ + to_open$, #PB_File_SharedRead)
    ; Format = ReadStringFormat(0)    ; auto detect UTF/Unicode/ASCII format --> all OK !
    While Eof(0) = 0
      ans$ = ans$ + ReadString(0, #PB_UTF8 + #PB_File_IgnoreEOL)     ; 不要傳回太多東西 !! + ", "  @@ 保留 CR/LF !! @@
    Wend
  EndIf
  CloseFile(0)  
EndIf
Return

Run_All_Jobs:
Debug "Run all ANN works and show reports !"
parameters$ = ""
For i = 1 To 6
  parameters$ = parameters$ + " " + Str(group_score(i))
Next i
DeleteFile(curDir2$ + "Six_Ans.txt")
RunProgram("open" , " -n " + curDir2$ + "AnnSix.app --args " + parameters$, curDir2$, #PB_Program_Wait)   ; 等待運算結束
Delay(250)
to_open$ = "Six_Ans.txt"    ; AnnSix.exe 執行完後會把 [中風六大證型] 的最終建議寫到 Six_Ans.txt , 故開啟此檔案並讀取建議
Gosub Read_Whole_File
SetGadgetText(Editor_7, "六大證型建議 --> " + ans$)   ; 顯示最終建議
; -------------  其他中醫證型  ---------------   
DeleteFile(curDir$ + "Cht_Ans.txt")
ans$ = "cht 證型 --> "
parameters$ = ""
For i = 0 To chdx_count - 1    ; 收集使用者點選的項目, 轉化成別名, 然後當成命令行參數, 傳給 AnnCht.app !
  item$ = GetGadgetItemText(ListView_0, i)
  If Mid(item$, 1, 2) = "V "    ; 檢查該項目是否有被點選
    parameters$ = parameters$ + " " + chdxdat(i)
  EndIf  
Next i
If debug_on = 1
  parameters$ = " show " + parameters$    ; 允許顯示除錯視窗
EndIf
SetGadgetText(Text_2, parameters$)    ; 顯示有被點選的項目
RunProgram("open" , " -n " + curDir2$ + "AnnCht.app --args " + parameters$, curDir2$, #PB_Program_Wait)   ; 等待運算結束
Delay(250)
to_open$ = "Cht_Ans.txt"
Gosub Read_Whole_File
SetGadgetText(Editor_8, ans$)   ; 顯示最終建議
; -------------  其他檢驗數據  ---------------   
ans$ = "lab --> "
parameters$ = ""
For i = 0 To lab_grp_count - 1    ; 收集使用者點選的項目, 轉化成別名, 然後當成命令行參數, 傳給 AnnLab.app !
  item$ = GetGadgetItemText(ListView_1, i)
  If Mid(item$, 1, 2) = "V "    ; 檢查該項目是否有被點選
    parameters$ = parameters$ + " " + lab_dat(i)
  EndIf  
Next i
If debug_on = 1
  parameters$ = " show " + parameters$    ; 允許顯示除錯視窗
EndIf
SetGadgetText(Text_3, parameters$)    ; 顯示有被點選的項目
RunProgram("open" , " -n " + curDir2$ + "AnnLab.app --args " + parameters$, curDir2$, #PB_Program_Wait)   ; 等待運算結束
Delay(250)
to_open$ = "Lab_Ans.txt"
Gosub Read_Whole_File
SetGadgetText(Editor_9, ans$)   ; 顯示最終建議
Return

Update_0:
; 重整顯示您所選擇的 [其他中醫證型] 項目
ans$ = ""
For i = 0 To chdx_count
  itemStr$ = GetGadgetItemText(ListView_0, i)
  If Mid(itemStr$, 1, 2) = "V "     ; 檢查開頭有選中的打勾記號
    ans$ = ans$ + Mid(itemStr$, 3) + ", "   ; 收集開頭有打勾的項目
  EndIf
Next i
SetGadgetText(Text_2, "其他中醫證型: 全部共有 " + Str(chdx_count) + " 項, 您選擇了: " + ans$)
Return

Update_1:
; 重整顯示您所選擇的 [其他檢驗數據] 項目
ans$ = ""
For i = 0 To lab_grp_count
  itemStr$ = GetGadgetItemText(ListView_1, i)
  If Mid(itemStr$, 1, 2) = "V "     ; 檢查開頭有選中的打勾記號
    ans$ = ans$ + Mid(itemStr$, 3) + ", "   ; 收集開頭有打勾的項目
  EndIf
Next i
SetGadgetText(Text_3, "其他檢驗數據: 全部共有 " + Str(chdx_count) + " 項, 您選擇了: " + ans$)
Return
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 419
; FirstLine = 399
; EnableXP
; DPIAware
; Executable = RunAnn.app
; Compiler = PureBasic 6.21 - C Backend (MacOS X - x64)