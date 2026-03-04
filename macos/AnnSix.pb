Structure  my_message_items
  n_max_chars.w       ; 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
  n_lines.w                ; 總行數 (決定訊息框的高度)
  message.s[8]           ; 最多放 8 行訊息
EndStructure

DataSection
  Data.s  "此為空白", "   風證   ", "  火熱證  ", "   痰證   ", "  血瘀證  ", "  氣虛證  ", "陰虛陽亢證"
  Data.i  0,  58, 56, 59, 74, 63, 52
EndDataSection

Dim group_score.i(7)    ; 六大證型目前得到幾分 (第零項不使用, 使用第 1 項至第 6 項)
Dim max_score.i(7)      ; 六大證型總分 (第零項不使用, 使用第 1 項至第 6 項)
Dim group_id.s(7)        ; 六大證型名稱 (第零項不使用, 使用第 1 項至第 6 項)
Dim cells_input.w(256)        ; 輸入層 (最多 256 個)
Dim cells_middle.w(256)     ; 中間層 (最多 256 個)
Dim cells_output.w(256)      ; 輸出層 (最多 256 個)
Dim net_upper.w(256, 256)    ; 輸入層 -> 中間層的神經網路加權值 (weights)
Dim net_lower.w(256, 256)    ; 中間層 -> 輸出層的神經網路加權值 (weights)
Dim messages.b(32, 32)       ; 最高 32 patterns, 每個 pattern 擁有獨立的 32 個訊息 (儲存指到 all_messages 陣列的索引) --> 目前只使用前 32 個 !!
Global input_count = 6       ; 輸入層有效細胞數, 上限 256
Global middle_count = 10    ; 中間層有效細胞數, 上限 256
Global output_count = 9     ; 輸出層有效細胞數, 上限 256
Global firing_level = 69     ; 大於此值, 則神經細胞活化
; --- 底下是 [訊息框] 所需要的 ---
Dim all_messages.my_message_items(32)   ; 宣告最高需要 (輸入層 16 + 輸出層16 = 32) 32 個訊息框的相關儲存空間
Global line_count_to_show, max_char_count, max_message_lines = 0, return_index = -1, string_to_show$
Global Box_Background_color, Box_Line_color, Box_Line_Width, Box_Text_color, Message_X, Message_Y

; 所有的 i, j, k.. 之類的區域變數, 只限用於局部函數內部的 For-Loop, 不可跨越到其他函數, 以免發生錯誤 !

OutPutFileName$ = "Six_Ans.txt"   ; 本程式運算後的最終建議, 將自動存檔於此
curDir$ = GetCurrentDirectory()     ; 目前本程式執行檔所在的目錄
; curDir$ = /Users/(使用者名稱)/Documents/PureBasic/AnnSix.app/Contents/
inside_app = FindString(curDir$, "Contents")
If inside_app > 0   ; 目前目錄位於 app 裡面 !!
  curDir$ = Mid(curDir$, 1, inside_app - 12)  ; 令 curDir$ 跳回 PureBasic 目錄
EndIf

err$ = ""
nParm = CountProgramParameters()  ; 取得命令行參數個數

If nParm > 0
  For i = 0 To nParm - 1
    ans$ = ProgramParameter(i)
    group_score(i+1) = Val(ans$)
  Next i
EndIf

For i = 0 To 6
  Read.s group_id(i)      ; 六大證型名稱
Next i

For i = 0  To 6
  Read.i max_score(i)    ; 六大證型總分
Next i

For i = 0 To 255          ; 清除三層神經細胞為 0
  cells_input(i) = 0
  cells_middle(i) = 0
  cells_output(i) = 0
Next i

Gosub Load_and_Run    ; 讀取檔案並執行一次運算

; 輸出結果
OutPutFileName$ = curDir$ + OutPutFileName$
If FileSize(OutPutFileName$) > 0
  Debug  "file already exists, size > 0"
EndIf
Fid = CreateFile(#PB_Any, OutPutFileName$, #PB_File_SharedWrite)    ; 建立輸出檔案
If Fid > 0
  For i = 1 To 6    ; 寫出六大證型的   目前證型得分  /  證型分數上限
    WriteStringN(Fid, Trim(group_id(i)) + ": " + Str(group_score(i)) + "/" + Str(max_score(i)) + " ", #PB_UTF8)
  Next i 
  WriteStringN(Fid, Fianl_ans$, #PB_UTF8)    ; 寫出最終建議
EndIf
If Len(Fianl_ans$) < 4    ; 最終建議的內容太短, 可能是空白, 沒有建議
  WriteStringN(Fid, "抱歉 ! 各證型分數不足, 尚無可建議之方劑", #PB_UTF8)
EndIf
CloseFile(Fid)
End

Load_and_Run:
; ---- 把六大證型值放到 cells_input() ----
name$ = ""
; group_score(1) = 90
; group_score(4) = 90
For i = 1 To input_count      ; 從輸入層神經細胞開始填入數值
  ; 某個證候超過六分，則該證候成立，(7 分 - 14 分為輕度，15 分 - 22 分為中度，大於 22 分為重度，最高只計 30 分)
  If group_score(i) > 6
    name$ = name$ + "1"     ; 1 = 證型成立
    score = 100
  Else
    name$ = name$ + "0"     ; 0 = 證型不成立
    score = 0
  EndIf
  cells_input(i-1) = score
Next i

Debug "證型編號 載入神經鍵值檔案: " + name$
; ---- load net data ----
InPutNetName$ = curDir$ + "AN" + name$ + ".BIN"     ; 使用證型分類挑選神經鍵值檔案
file_id = OpenFile(#PB_Any, InPutNetName$, #PB_File_SharedRead)    ; return file_id: none-zero = OK
If file_id    ; 0=Err, Not Zero=OK
  file_len = Lof(file_id)   ; 1024 = 2 x 16 x 32 = 2 x 512 bytes, 神經鍵值檔案的大小通常比 1 k bytes 多一點
  If file_len < 1
    err$ = "無法讀取神經鍵值檔案 " + InPutNetName$
    Debug err$
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
      *ptr = *ptr + slen  ; !! bug !! 可能無法取得正確長度 ！！
      Debug Tmp$
      For j = 0 To 7
        crloc = FindString(Tmp$, cr$, last_cr + 1)
        If crloc > 0    ; 有找到 chr(13) = CR 換行分割標記
          all_messages.my_message_items(i)\message[j] = Mid(Tmp$, last_cr + 1, crloc - last_cr)
          If max_char_num < (crloc - last_cr)
            max_char_num = crloc - last_cr
          EndIf
          last_cr = crloc
        Else
          If max_char_num = 0   ; 僅有單行訊息
            max_char_num = slen
          EndIf
          all_messages.my_message_items(i)\message[j] = Tmp$
          ; Debug all_messages.my_message_items(i)\message[j]
          all_messages.my_message_items(i)\n_lines = j + 1
          all_messages.my_message_items(i)\n_max_chars = max_char_num
          Break       ;沒有找到 CR 換行分割標記, 提前結束
        EndIf        
      Next j
    EndIf
  Next i
  CloseFile(file_id) 
  Debug   "已成功從 " + InPutNetName$ + " 載入 " + Str(file_len) + " bytes."
EndIf

; ---- 執行一次運算 ----
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
      cells_output(j) = cells_output(j) + net_lower(i, j)   ; 輸入層神經細胞有活化, 此時中間層神經細胞可以得到相對應的神經網路加權值 (weight)
      If cells_output(j) > 100
        cells_output(j) = 100     ; 防止超過 100 (上限)
      EndIf
    Next j
  EndIf
Next i
; ---- 收集最終結果 ----
ans$ = err$
For i = 0 To output_count - 1
  If cells_output(i) > firing_level
    Tmp$ = ""
    For j = 0 To 7    ; 一個訊息最多放 8 行文字
      If Len(all_messages.my_message_items(input_count + i)\message[j]) > 0     ; 前面 input_count 項訊息是輸入層的標籤, 後面是輸出層的標籤
        Tmp$ = Tmp$ + all_messages.my_message_items(input_count + i)\message[j]
      EndIf
    Next j 
    Tmp$ = Trim(Tmp$)   ; 移除兩端多餘的空白
    ans$ = ans$ + Mid(Tmp$, 1, FindString(Tmp$, Chr(13)) - 1) + ", "     ; 移除尾端多餘的 CR (#13), 後面補上逗號 (可能有多項建議, 需用逗號分隔)
  EndIf
Next i
Fianl_ans$ = "建議: " + ans$
Debug Fianl_ans$
Return

;中醫六大證型得分 :
;[    風證    得分 15 分,  總分 58 分 ]
;[   火熱證   得分 11 分,  總分 56 分 ]
;[    痰證    得分 2 分,  總分 59 分 ]
;[   血瘀證   得分 14 分,  總分 74 分 ]
;[   氣虛證   得分 6 分,  總分 63 分 ]
;[ 陰虛陽亢證 得分 5 分,  總分 52 分 ]
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 35
; FirstLine = 21
; EnableXP
; DPIAware
; Executable = AnnSix.app