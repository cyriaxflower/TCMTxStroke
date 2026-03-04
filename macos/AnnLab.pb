;!!  注意: 訓練檔的證型 TAG 務必只能擺在第一項  !!  否則無法正確處理 !!  目前不會自動比對證型  TAG !!

Structure  my_message_items
  n_max_chars.w       ; 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
  n_lines.w                ; 總行數 (決定訊息框的高度)
  message.s[8]           ; 最多放 8 行訊息
EndStructure

DataSection
  ; ---- 其他檢驗數據 ---- (每一行僅放五個項目)
  Data.s  "貧血", "血色素過高", "紅血球增生症", "白血球增多症", "白血球低下症"
  Data.s  "肝功能 GPT 過高", "肝功能 gamma-GT 過高", "腎功能肌肝酸 creatinine 過高", "鉀離子過高", "鉀離子過低"
  Data.s  "鈉離子過高", "鈉離子過低", "白血球計數 > 13,000/立方釐米", "白血球計數 13,000 ~ 10,000/立方釐米", "白血球計數 10,000 ~  7,000/立方釐米"
  Data.s  "白血球計數  7,000 ~  5,000/立方釐米", "白血球計數  < 5,000/立方釐米", "紅血球血色素 > 15 g/dl", "紅血球血色素 13 ~ 15 g/dl", "紅血球血色素 10 ~ 13 g/dl"
  Data.s  "紅血球血色素  7 ~ 10 g/dl", "紅血球血色素  < 7 g/dl", "** NIHSS 中風傷害量表 得分範圍: 0 - 42 分", "NIHSS 得 0-14 分 (輕度傷害)", "NIHSS 得 15-29 分 (中度傷害)"
  Data.s  "NIHSS 得 30-42 分 (重度傷害)", "end"
  ; ---- 其他檢驗數據的參數別名 ---- (傳給 AnnLab 的參數)
  Data.s  "anemia", "hb_h", "rbc_h", "wbc_h", "wbc_l"
  Data.s  "gpt_h", "ggt_h", "cr_h", "k_h", "k_l"
  Data.s  "na_h", "na_l", "wbc_hh", "wbc_h", "wbc_m"
  Data.s  "wbc_n", "wbc_l", "rbc_h", "rbc_n", "rbc_l"
  Data.s  "rbc_ll", "rbc_lll", "**", "nihss_l", "nihss_m"
  Data.s  "nihss_h", "end"
  ; ---- 其他檢驗數據的神經運算數據檔案檔名 ----
  Data.s "LA0001.BIN", "LA0002.BIN", "LA0003.BIN", "LA0004.BIN", "LA0005.BIN"
  Data.s "LA0006.BIN", "LA0007.BIN", "LA0008.BIN", "LA0009.BIN", "LA0010.BIN"
  Data.s "LA0011.BIN", "LA0012.BIN", "LA0013.BIN", "LA0014.BIN", "LA0015.BIN"
  Data.s "LA0016.BIN", "LA0017.BIN", "LA0018.BIN", "LA0019.BIN", "LA0020.BIN"
  Data.s "LA0021.BIN", "end"
EndDataSection

Dim lab_grp.s(100)      ; 最多可容納 100 組額外的檢驗數據
Dim lab_dat.s(100)      ; 最多可容納 100 組額外的檢驗數據參數別名
Dim lab_file.s(100)      ; 最多可容納 100 組額外的中醫證型神經運算檔名資料
Dim lab_score.i(100)    ; 最多可容納 100 組額外的檢驗數據分數
Dim lab_work.i(50)      ; 最多可容納 50 個選定的檢驗數據
Global ans_string_count = 0   ; 所有的輸出建議總行數
Global lab_count = 0              ; 檢驗數據_項目總數
Global show_window = 0       ; 1=顯示除錯訊息視窗, 0=不顯示除錯訊息視窗
Global work_ndx = 0             ; 選定的檢驗數據項目總數
; ---- 借用六大證型已經寫好的程式來稍加修改 ----
Dim cells_input.w(255)          ; 輸入層 (最多 256 個)
Dim cells_middle.w(255)       ; 中間層 (最多 256 個)
Dim cells_output.w(255)        ; 輸出層 (最多 256 個)
Dim net_upper.w(255, 255)   ; 輸入層 -> 中間層的神經網路加權值 (weights)
Dim net_lower.w(255, 255)   ; 中間層 -> 輸出層的神經網路加權值 (weights)
Dim messages.b(31, 31)        ; 最高 32 patterns, 每個 pattern 擁有獨立的 32 個訊息 (儲存指到 all_messages 陣列的索引) --> 目前只使用前 32 個 !!
Global input_count = 6        ; 輸入層有效細胞數, 上限 256
Global middle_count = 10   ; 中間層有效細胞數, 上限 256
Global output_count = 9      ; 輸出層有效細胞數, 上限 256
Global firing_level = 69      ; 大於此值, 則神經細胞活化
; --- 底下是 [訊息框] 所需要的 ---
Dim all_messages.my_message_items(32)   ; 宣告最高需要 (輸入層 16 + 輸出層16 = 32) 32 個訊息框的相關儲存空間
Global line_count_to_show, max_char_count, max_message_lines = 0, return_index = -1, string_to_show$
Global Box_Background_color, Box_Line_color, Box_Line_Width, Box_Text_color, Message_X, Message_Y
; ----------------------------------
Enumeration FormFont
  #Font_1
EndEnumeration

; 所有的 i, j, k.. 之類的區域變數, 只限用於局部函數內部的 For-Loop, 不可跨越到其他函數, 以免發生錯誤 !

OutPutFileName$ = "Lab_Ans.txt"   ; 本程式運算後的最終建議, 將自動存檔於此
curDir$ = GetCurrentDirectory()     ; 目前本程式執行檔所在的目錄
; /Users/(使用者名稱)/Documents/PureBasic/AnnLab.app/Contents/Lab_Ans.txt
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
  If OpenWindow(0, 210, 210, 1100, 700, "檢驗數據...",  #PB_Window_SystemMenu)  ; 除錯訊息視窗的螢幕座標為 (210, 210), 寬 1100 點, 高 700 點
    LoadFont(#Font_1,"標楷體", 16)
    Editor_1 = EditorGadget(#PB_Any, 10, 10, 1080, 680)   ; 除錯訊息文字框在除錯訊息視窗裡的座標為 (10, 10), 寬 1080 點, 高 680 點
    SetGadgetFont(Editor_1, FontID(#Font_1))
  EndIf
EndIf

toSay$ = "參數個數 = " + Str(nParm)
Gosub Say     ; 顯示到除錯訊息文字框

; 清除 100 個 [檢驗數據] 的輸入給分 (100=啟動, 0=不啟動) 若有啟動, 將會去讀取對應的神經網路加權值檔案, 然後執行一次神經網路運算, 並輸出建議
For i = 0 To 99
  lab_score(i) = 0
Next i

; -- 讀取預設 [其他檢驗數據] 資料項
For i = 0  To 99
  Read.s lab_grp(i)    ; 讀取預設 [其他檢驗數據] 資料項
  If lab_grp(i) = "end"
    lab_count = i         ; = 總項數
    Break
  EndIf
Next i
  
For i = 0  To 99
  Read.s lab_dat(i)    ; 讀取預設 [其他檢驗數據] 參數別名, 此為 RunAnn 傳遞過來的命令行參數文字
  If lab_dat(i) = "end"
    Break                   ; 1 比 1 對應 lab_grp 陣列, 不再設置總項數
  EndIf
Next i

For i = 0  To 99
  Read.s lab_file(i)    ; 讀取預設 [其他檢驗數據] 神經運算檔名資料項, 此為 RunAnn 傳遞過來的命令行參數文字 (別名), 用別名來找尋其對應的神經網路加權值檔案
  If lab_file(i) = "end"
    Break                   ; 1 比 1 對應 lab_grp 陣列, 不再設置總項數
  EndIf
Next i

; 把輸入 [參數] 查詢 [別名] 轉成內部索引編號 (0..99)
If nParm > 0
  For i = 0 To nParm - 1
    ans$ = ProgramParameter(i)
    If ans$ = "show"
      Continue            ; 忽略此內部隱藏命令, 在本程式的第 74 行已經處裡過 "show" 的命令功能.
    EndIf
    ndx = 9999    ; 100 以內才有效 !
    For j = 0 To lab_count - 1
      If lab_dat(j) = ans$      ; 如果 [別名] 與 [參數] 相同, 則記下此索引數值
        ndx = j
        Break
      EndIf
    Next j
    If ndx < 100    ; 100 以內才有效 !
      lab_work(work_ndx)  = ndx
      lab_score(ndx) = 100              ; 此值目前暫不使用, 固定把第一個輸入神經值填 100 (100=啟動, 0=不啟動)
      work_ndx = work_ndx + 1
      toSay$ = "查詢別名有效 ! " + ans$ + " 此為 [" + lab_grp(ndx) + "], 其神經網路加權值檔案為 " + lab_file(ndx)
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
  toSay$ = "在其他檢驗數據, 您選擇: "
  Gosub Say     ; 顯示到除錯訊息文字框
  WriteStringN(Fid, "在其他檢驗數據, 您選擇: ", #PB_UTF8)
  For i_ndx = 0 To work_ndx - 1
    WriteStringN(Fid, "  " + lab_grp(lab_work(i_ndx)) + " --> ", #PB_UTF8)     ;  + lab_file(cht_work(i_ndx))
    toSay$ = "  " + lab_grp(lab_work(i_ndx)) + " --> "    ; + lab_file(cht_work(i_ndx))
    Gosub Say     ; 顯示到除錯訊息文字框
    ; 呼叫執行所想要的其他檢驗數據程式
    InPutNetName$ = curDir$ + lab_file(lab_work(i_ndx))
    Fianl_ans$ = ""
    Gosub Load_and_Run
    If Len(Fianl_ans$) > 1
      toSay$ = Fianl_ans$ + Chr(13) + Chr(10)
      Gosub Say     ; 顯示到除錯訊息文字框
      WriteStringN(Fid, Fianl_ans$ + Chr(13) + Chr(10), #PB_UTF8)
      ans_string_count = ans_string_count + 1
    EndIf
  Next i_ndx  
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
    *ptr = *ptr + 8              ; 此時跳到 檔案位置 48 (0x30)
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
      ; Debug Tmp$
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
; CursorPosition = 335
; FirstLine = 318
; EnableXP
; DPIAware
; Executable = AnnLab.app