;!!  注意: 訓練檔的證型 TAG 務必只能擺在第一項  !!  否則無法正確處理 !!  目前不會自動比對證型  TAG !!

Structure  my_message_items
  n_max_chars.w       ; 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
  n_lines.w                ; 總行數 (決定訊息框的高度)
  message.s[8]           ; 最多放 8 行訊息
EndStructure

DataSection
  ; ---- 其他中醫證型 ----
  Data.s  "風寒", "風熱", "風濕", "風寒濕", "陰陽兩虛證", "脾虛痰濕證", "頭部取穴", "上肢癱取穴", "下肢癱取穴"
  Data.s  "智三針", "腦三針", "顳三針", "舌三針", "小腦新區", "四神聰", "中風急性期，風痰瘀血，痹阻脈絡"
  Data.s  "中風恢復期，陰虛陽亢，脈絡瘀阻",  "真寒", "元陰匱乏", "血虛", "end"
  ; ---- 其他中醫證型的參數別名 ----
  Data.s "windcold", "windhot", "windwet", "windcoldwet", "yinyanglow", "splowsputwet", "headaccp", "upperaccp", "loweraccp"
  Data.s "wisdom3", "brain3", "tempor3", "tongue3", "newcerbel", "4wise", "acuteCVA"
  Data.s "recoverCVA", "realcold", "low_neg", "low_blood", "end"
  ; ---- 其他中醫證型的神經運算數據檔案檔名 ----
  Data.s "CH0001.BIN", "CH0002.BIN", "CH0003.BIN", "CH0004.BIN", "CH0005.BIN", "CH0006.BIN", "CH0007.BIN", "CH0008.BIN", "CH0009.BIN"
  Data.s "CH0010.BIN", "CH0011.BIN", "CH0012.BIN", "CH0013.BIN", "CH0014.BIN", "CH0015.BIN", "CH0016.BIN"       
  Data.s "CH0017.BIN", "CH0018.BIN", "CH0019.BIN", "CH0020.BIN", "end"
EndDataSection

Dim chdxgrp.s(100)      ; 最多可容納 100 組額外的中醫證型
Dim chdxdat.s(100)      ; 最多可容納 100 組額外的中醫證型參數別名
Dim chdxfile.s(100)     ; 最多可容納 100 組額外的中醫證型神經運算檔名資料
Dim cht_score.i(100)    ; 最多可容納 100 組額外的中醫證型分數
Dim cht_work.i(50)      ; 最多可容納 50 個選定的中醫證型
Global ans_string_count = 0   ; 所有的輸出建議總行數
Global chdx_count = 0           ; 中醫證型_項目總數
Global show_window = 0       ; 1=顯示除錯訊息視窗, 0=不顯示除錯訊息視窗
Global work_ndx = 0             ; 選定的中醫證型項目總數
; ---- 借用六大證型已經寫好的程式來稍加修改 ----
Dim cells_input.w(255)        ; 輸入層 (最多 256 個)
Dim cells_middle.w(255)     ; 中間層 (最多 256 個)
Dim cells_output.w(255)      ; 輸出層 (最多 256 個)
Dim net_upper.w(255, 255)  ; 輸入層 -> 中間層的神經網路加權值 (weights)
Dim net_lower.w(255, 255)  ; 中間層 -> 輸出層的神經網路加權值 (weights)
Dim messages.b(31, 31)       ; 最高 32 patterns, 每個 pattern 擁有獨立的 32 個訊息 (儲存指到 all_messages 陣列的索引) --> 目前只使用前 32 個 !!
Global input_count = 6       ; 輸入層有效細胞數, 上限 256
Global middle_count = 10  ; 中間層有效細胞數, 上限 256
Global output_count = 9     ; 輸出層有效細胞數, 上限 256
Global firing_level = 69     ; 大於此值, 則神經細胞活化
; --- 底下是 [訊息框] 所需要的 ---
Dim all_messages.my_message_items(32)   ; 宣告最高需要 (輸入層 16 + 輸出層16 = 32) 32 個訊息框的相關儲存空間
Global line_count_to_show, max_char_count, max_message_lines = 0, return_index = -1, string_to_show$
Global Box_Background_color, Box_Line_color, Box_Line_Width, Box_Text_color, Message_X, Message_Y
; ----------------------------------

; 所有的 i, j, k.. 之類的區域變數, 只限用於局部函數內部的 For-Loop, 不可跨越到其他函數, 以免發生錯誤 !

Enumeration FormFont
  #Font_1
EndEnumeration

OutPutFileName$ = "Cht_Ans.txt"   ; 本程式運算後的最終建議, 將自動存檔於此
curDir$ = GetCurrentDirectory()     ; 目前本程式執行檔所在的目錄
; /Users/(使用者名稱)/Documents/PureBasic/AnnCht.app/Contents/Cht_Ans.txt
inside_app = FindString(curDir$, "Contents")
If inside_app > 0   ; 目前目錄位於 app 裡面 !!
  curDir$ = Mid(curDir$, 1, inside_app - 12)  ; 跳回 PureBasic 目錄
EndIf

nParm = CountProgramParameters()

If nParm > 0
  For i = 0 To nParm - 1
    If ProgramParameter(i) = "show"
      show_window = 1       ; 允許顯示除錯訊息視窗
      Break
    EndIf
  Next i
EndIf
  
If show_window > 0
  If OpenWindow(0, 200, 200, 1000, 700, "中醫證型...",  #PB_Window_SystemMenu)  ; 除錯訊息視窗的螢幕座標為 (200, 200), 寬 1000 點, 高 700 點
    LoadFont(#Font_1,"標楷體", 16)
    Editor_1 = EditorGadget(#PB_Any, 10, 10, 980, 680)   ; 除錯訊息文字框在除錯訊息視窗裡的座標為 (10, 10), 寬 980 點, 高 680 點
    SetGadgetFont(Editor_1, FontID(#Font_1))
  EndIf
EndIf

Debug nParm
toSay$ = "參數個數 = " + Str(nParm)
Gosub Say     ; 顯示到除錯訊息文字框

; 清除 100 個 [其他中醫證型] 的輸入給分 (100=啟動, 0=不啟動) 若有啟動, 將會去讀取對應的神經網路加權值檔案, 然後執行一次神經網路運算, 並輸出建議
For i = 0 To 99
  cht_score(i) = 0
Next i

; -- 讀取預設 [其他中醫證型] 神經運算檔名資料項
For i = 0  To 99
  Read.s chdxgrp(i)    ; 讀取預設 [其他中醫證型] 資料項
  If chdxgrp(i) = "end"
    chdx_count = i         ; 記下所讀取的 預設 [其他中醫證型] 總數
    Break
  EndIf
Next i

For i = 0  To 99
  Read.s chdxdat(i)    ; 讀取預設 [其他中醫證型] 參數別名資料項, 此為 RunAnn 傳遞過來的命令行參數文字
  If chdxdat(i) = "end"
    Break                   ; 1 比 1 對應 chdxgrp 陣列, 不再設置總項數
  EndIf
Next i

For i = 0  To 99
  Read.s chdxfile(i)    ; 讀取預設 [其他中醫證型] 神經運算檔名資料項, 此為 RunAnn 傳遞過來的命令行參數文字 (別名), 用別名來找尋其對應的神經網路加權值檔案
  If chdxfile(i) = "end"
    Break                   ; 1 比 1 對應 chdxgrp 陣列, 不再設置總項數
  EndIf
Next i

; 把輸入 [參數] 查詢 [別名] 轉成內部索引編號 (0..99)
If nParm > 0
  For i = 0 To nParm - 1
    ans$ = ProgramParameter(i)
    If ans$ = "show"
      Continue            ; 忽略此內部隱藏命令, 在本程式的第 71 行已經處裡過 "show" 的命令功能.
    EndIf
    ndx = 9999    ; 100 以內才有效 !
    For j = 0 To chdx_count - 1
      If chdxdat(j) = ans$      ; 如果 [別名] 與 [參數] 相同, 則記下此索引數值
        ndx = j
        Break
      EndIf
    Next j

    If ndx < 100    ; 100 以內才有效 !
      cht_work(work_ndx)  = ndx
      cht_score(ndx) = 100              ; 此 cht_score 陣列目前暫不使用, 固定把第一個輸入神經值填 100 (100=啟動, 0=不啟動)
      work_ndx = work_ndx + 1
      toSay$ = "查詢別名有效 ! " + ans$ + " 此為 [" + chdxgrp(ndx) + "], 其神經網路加權值檔案為 " + chdxfile(ndx)
      Gosub Say     ; 顯示到除錯訊息文字框
    Else
      toSay$ = "此查詢別名無效 ! ( " + ans$ + " )"
      Gosub Say     ; 顯示到除錯訊息文字框
    EndIf
  Next i
EndIf

OutPutFileName$ = curDir$ + OutPutFileName$
If FileSize(OutPutFileName$) > 0
  Debug  "file already exists, size > 0"
  toSay$ = "已經有輸出檔案: " + Chr(13) + Chr(9) + OutPutFileName$
  Gosub Say     ; 顯示到除錯訊息文字框
EndIf

Fid = CreateFile(#PB_Any, OutPutFileName$, #PB_File_SharedWrite)
If Fid > 0
  toSay$ = "在其他中醫證型, 您選擇: "
  Gosub Say     ; 顯示到除錯訊息文字框
  WriteStringN(Fid, "在其他中醫證型, 您選擇: ", #PB_UTF8)
  For Lv1 = 0 To work_ndx - 1
    WriteStringN(Fid, "  " + chdxgrp(cht_work(Lv1)) + " --> ", #PB_UTF8)     ;  + chdxfile(cht_work(i))
    toSay$ = "  " + chdxgrp(cht_work(Lv1)) + " --> "    ; + chdxfile(cht_work(Lv1))
    Gosub Say     ; 顯示到除錯訊息文字框
    ; 呼叫執行所想要的其他中醫證型程式
    InPutNetName$ = curDir$ + chdxfile(cht_work(Lv1))
    Fianl_ans$ = ""
    Gosub Load_and_Run
    If Len(Fianl_ans$) > 1
      toSay$ = Fianl_ans$ + Chr(13) + Chr(10)
      Gosub Say     ; 顯示到除錯訊息文字框
      WriteStringN(Fid, Fianl_ans$ + Chr(13) + Chr(10), #PB_UTF8)
      ans_string_count = ans_string_count + 1
    EndIf
  Next Lv1  
EndIf

If ans_string_count < 1
  WriteStringN(Fid, "抱歉 ! 各證型分數不足, 尚無可建議之方劑", #PB_UTF8)
  toSay$ = "抱歉 ! 各證型分數不足, 尚無可建議之方劑"
  Gosub Say     ; 顯示到除錯訊息文字框
EndIf

CloseFile(Fid)

If show_window > 0
  Repeat
    Event = WaitWindowEvent()
  Until Event = #PB_Event_CloseWindow
EndIf 

End

Load_and_Run:
; ---- 把輸入值放到 cells_input() ----
For i = 0 To input_count - 1      ; 從輸入層神經細胞開始填入數值
  cells_input(i) = 0
Next i

;!! [輸入證型] 務必 擺在第一項  !!  否則無法正確處理 !!  目前不會自動比對證型  TAG !!
cells_input(0) = 100    ; 固定把第一個輸入神經值填 100

; ---- load net data ----
Debug InPutNetName$
file_id = OpenFile(#PB_Any, InPutNetName$, #PB_File_SharedRead)    ; return file_id: none-zero = OK
If file_id    ; 0=Err, Not Zero=OK
  file_len = Lof(file_id)   ; 1024 = 2 x 16 x 32 = 2 x 512 bytes, 神經鍵值檔案的大小通常比 1 k bytes 多一點
  If file_len < 1
    err$ = "無法讀取神經鍵值檔案 " + InPutNetName$
    toSay$ = err$
    Gosub Say     ; 顯示到除錯訊息文字框
    Return
  EndIf
  *DATABUF = AllocateMemory(file_len)
  ReadData(file_id, *DATABUF, file_len)
  If *DATABUF
    *ptr = *DATABUF + 32    ; 頭 32 bytes 是輸入層的 01 簡易文字表示法, 可略過
    ; 讀取 (皆為 16-bits) 輸入層的細胞數、中間層的細胞數、輸出層的細胞數、firing_level、訊息字串數 (目前固定為 32)
    input_count = PeekW(*ptr)       ; = 輸入層的細胞
    *ptr = *ptr + 2
    middle_count = PeekW(*ptr)    ; = 中間層的細胞數
    *ptr = *ptr + 2
    output_count = PeekW(*ptr)    ; = 輸出層的細胞數
    *ptr = *ptr + 2
    firing_level = PeekW(*ptr)      ; = firing_level
    *ptr = *ptr + 2
    message_count = PeekW(*ptr)  ; = 訊息字串數 (目前固定為 32)
    *ptr = *ptr + 8              ; 此時應該跳到 檔案位置 48 (0x30)
    ; 讀取 輸入層 -> 中間層的神經網路加權值 (weights) = (input_count * middle_count) bytes
    For i = 0 To input_count - 1
      For j = 0 To middle_count - 1
        net_upper(i, j) = PeekB(*ptr)
        *ptr = *ptr + 1
      Next j
    Next i
    ; 讀取 中間層 -> 輸出層的神經網路加權值 (weights) = (middle_count * output_count) bytes
    For i = 0 To middle_count - 1
      For j = 0 To output_count - 1
        net_lower(i, j) = PeekB(*ptr)
        *ptr = *ptr + 1
      Next j
    Next i
  EndIf
  ; 讀取訊息字串
  For i = 0 To 31    ; 每個神經鍵值檔案擁有 32 個訊息結構, 神經鍵值檔案裡面的所有 patterns 皆共用此 32 個訊息結構
    all_messages.my_message_items(i)\n_max_chars = 0   ; 此單一訊息結構最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
    all_messages.my_message_items(i)\n_lines = 0            ; 此單一訊息結構實際訊息含有幾行 (每則訊息上限 8 行)
    For j = 0 To 7    ; 每個訊息結構最多放 8 行訊息
      all_messages.my_message_items(i)\message[j] = ""    ; 預先清除此單一訊息結構所有訊息的字串
    Next j
    ; 上面把單一訊息結構的內容清除乾淨, 接著開始讀取檔案來填註每一個單一訊息結構
    cr$ = Chr(13)
    last_cr = 0
    max_char_num = 0    ; 紀錄此單一訊息結構最長的一行裡, 有幾個英文字, 一開始清成 0
    slen = PeekW(*ptr)    ; 取得訊息字串占用檔案空間長度
    *ptr = *ptr + 2
    If slen > 0     ; 有訊息內容
      Tmp$ = PeekS(*ptr, slen, #PB_UTF8)  ; 一般視窗電腦 PC 請用 #PB_Ascii    或    蘋果電腦 macOS 請用 #PB_UTF8
      *ptr = *ptr + slen
      For j = 0 To 7
        crloc = FindString(Tmp$, cr$, last_cr + 1)  ; 如果發現 CR 換行分割標記, 表示此訊息字串是多行字串 !
        If crloc > 0    ; 有找到 chr(13) = CR 換行分割標記
          all_messages.my_message_items(i)\message[j] = Mid(Tmp$, last_cr + 1, crloc - last_cr)
          If max_char_num < (crloc - last_cr)
            max_char_num = crloc - last_cr  ; 修正此單一訊息結構最長的一行裡, 有幾個英文字
          EndIf
          last_cr = crloc
        Else            ; 沒有找到 chr(13) = CR 換行分割標記, 此為單行訊息 !
          If max_char_num = 0   ; 僅有單行訊息
            max_char_num = slen                ; 修正此單一訊息結構最長的一行裡, 有幾個英文字
          EndIf
          all_messages.my_message_items(i)\n_lines = j + 1    ; 記住目前此單一訊息結構已有行數
          all_messages.my_message_items(i)\n_max_chars = max_char_num   ; 記住此單一訊息結構最長的一行裡, 有幾個英文字
          Break       ; 沒有找到 CR 換行分割標記, 提前結束 For-j-Loop, 程式將會跳到下面 Next j 的下一行
        EndIf
        all_messages.my_message_items(i)\n_lines = j + 1      ; 記住目前此單一訊息結構已有行數
        all_messages.my_message_items(i)\n_max_chars = max_char_num     ; 記住此單一訊息結構最長的一行裡, 有幾個英文字
      Next j
    EndIf
  Next i
  CloseFile(file_id) 
  toSay$ = "已成功從 " + InPutNetName$ + " 載入 " + Str(file_len) + " bytes."
  Gosub Say     ; 顯示到除錯訊息文字框
  Debug  toSay$
EndIf

; ---- 執行一次運算 ----
For i = 0 To middle_count - 1   ; 清除中間層神經細胞
  cells_middle(i) = 0
Next i

For i = 0 To output_count - 1   ; 清除輸出層神經細胞
  cells_output(i) = 0
Next i

For i = 0 To input_count - 1    ; 從輸入層神經細胞開始檢查
  If cells_input(i) > firing_level  ; 大於此閥值, 代表輸入層神經細胞活化 !
    For j = 0 To middle_count - 1
      cells_middle(j) = cells_middle(j) + net_upper(i, j)   ; 輸入層神經細胞有活化, 此時中間層神經細胞可以得到相對應的神經網路加權值 (weight)
      If cells_middle(j) > 100
        cells_middle(j) = 100     ; 防止超過 100 (上限)
      EndIf
    Next j
  EndIf
Next i

For i = 0 To middle_count - 1    ; 從中間層神經細胞開始檢查
  If cells_middle(i) > firing_level  ; 大於此閥值, 代表中間層神經細胞活化 !
    For j = 0 To output_count - 1
      cells_output(j) = cells_output(j) + net_lower(i, j)   ; 中間層神經細胞有活化, 此時輸出層神經細胞可以得到相對應的神經網路加權值 (weight)
      If cells_output(j) > 100
        cells_output(j) = 100     ; 防止超過 100 (上限)
      EndIf
    Next j
  EndIf
Next i
; ---- 收集最終結果 ----
ans$ = err$
Fianl_ans$ = "建議: "
For i = 0 To output_count - 1
  toSay$ = "output " + Str(cells_output(i))
  Gosub Say     ; 顯示到除錯訊息文字框
  If cells_output(i) > firing_level
    Tmp$ = ""
    For j = 0 To 7    ; 一個訊息最多放 8 行文字
      If Len(all_messages.my_message_items(input_count + i)\message[j]) > 0     ; 前面 input_count 項訊息是輸入層的標籤, 後面是輸出層的標籤
        Tmp$ = Tmp$ + all_messages.my_message_items(input_count + i)\message[j]   ; 如果有超過一行的訊息, 在此會被串接在一起
      EndIf
    Next j 
    Tmp$ = Trim(Tmp$)   ; 移除兩端多餘的空白
    slen = Len(Tmp$)
    If slen > 1
      ans$ = ans$ + Mid(Tmp$, 1, slen - 1) + ", "     ; 移除尾端多餘的 CR (#13), 後面補上逗號 (可能有多項建議, 需用逗號分隔)
    EndIf
  EndIf
Next i
Fianl_ans$ = Fianl_ans$ + ans$  ; 傳回最終建議
Debug Fianl_ans$
Return

Say:
If show_window > 0
  AddGadgetItem(Editor_1, -1, toSay$)   ; 顯示到除錯訊息文字框
EndIf
Return
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 303
; FirstLine = 286
; EnableXP
; DPIAware
; Executable = AnnCht.app