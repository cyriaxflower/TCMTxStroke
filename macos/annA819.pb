; 轉換 iconv -f BIG-5 -t UTF-8 100100.txt > Data02.txt

Structure  my_message_items
  n_max_chars.w       ; 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
  n_lines.w                ; 總行數 (決定訊息框的高度)
  message.s[8]           ; 最多放 8 行訊息
EndStructure

Global  bDone = 0, item_count = 0, middle_count = 0, pattern_count = 0, result_count = 0
Global  pattern_to_set = 0
; .b 的數值範圍是   -128 至   +127
; .w 的數值範圍是 -32768 至 +32767
Dim cells.w(96, 31)         ; 輸入層 (前 max 16) 期望輸出層 (後 max 16) 神經細胞, 最多 96 patterns, 每個 pattern 最多 16+16 items
;Dim cells_out.w(15)         ; 運算中的輸出層 (max 16) 神經細胞 max 32 patterns, 16 input items, 16 output results
;Dim targets.b(31, 15)       ; 希望輸出層的值, 集中在 1st pattern, 16 output results (只儲存 0 或 1)
;Dim middle_layer.w(31)      ; 運算中的中間層神經細胞, 集中在 1st pattern, 32 middle layer cells
;Dim net_top.b(511)             ; 輸入層往中間層的神經鍵結強度 (net strength), 集中在 1st pattern. 索引= (輸入層 max * 32) +  中間層 max 32
;Dim net_down.b(511)         ; 中間層往輸出層的神經鍵結強度 (net strength),  集中在 1st pattern. 索引= (輸出層 max * 32) +  中間層 max 32
Dim messages.b(96, 31)      ; 最高 32 patterns, 每個 pattern 擁有獨立的 32 個訊息 (儲存指到 all_messages 陣列的索引)

; --- 底下是 [訊息框] 所需要的 ---
Dim all_messages.my_message_items(31)   ; 宣告最高需要 (輸入層 16 + 輸出層16 = ) 32 個訊息框的相關儲存空間
Global line_count_to_show, max_char_count, max_message_lines = 0, return_index = -1, string_to_show$
;Global Box_Background_color, Box_Line_color, Box_Line_Width, Box_Text_color, Message_X, Message_Y

; 載入學習資料檔
curDir$ = GetCurrentDirectory()
; 執行檔會變成 ~/PureBasic/AnnA.app/Contents/
loc = FindString(curDir$, "AnnA")
If loc > 0
  curDir$ = Mid(curDir$, 1, loc - 1)  ; !! 修正路徑 !!
EndIf
Debug curDir$
If OpenFile(0, curDir$ + "Data02.txt")
  If ReadFile(0, curDir$ + "Data02.txt")
    Debug FormatDate("Start ! UTC time: %hh:%ii:%ss", DateUTC())
    Format = ReadStringFormat(0)
    Debug Format    ; 24 = Big-5
    If Lof(0) > 0
      While Eof(0) = 0
        StrForParse$ = ReadString(0, #PB_UTF8)
        Gosub Parse_One_String       
      Wend
    EndIf
    CloseFile(0)
    OutPutFileName$ = "ANNData.BIN"
    Gosub WriteDataFile
  EndIf     ; -- ReadFile OK
  Else
    MessageRequester("錯誤", "無法開啟資料檔案 Data02.txt !", #PB_MessageRequester_Error)
  EndIf
Debug FormatDate("Done ! UTC time: %hh:%ii:%ss", DateUTC())

XIncludeFile "FormBB.pbf"
OpenWindow_1()

Repeat
  Event = WaitWindowEvent()
  Window_1_Events(Event)
  If bDone > 0
    Break
  EndIf
Until Event = #PB_Event_CloseWindow
Debug GetGadgetText(Editor_0)
Debug curDir$ + "AnnB.app"
; !! bug !! 參數無法使用 + " --args " + GetGadgetText(Editor_0) 
; 改成把參數存到檔案
Fid = CreateFile(#PB_Any, curDir$ + "temp_arg.txt", #PB_File_SharedWrite)
If Fid <> 0
  WriteString(Fid, Trim(GetGadgetText(Editor_0)) + Chr(13) + Str(file_len), #PB_UTF8)
  CloseFile(Fid)
EndIf
RunProgram("open" , " -n " + curDir$ + "AnnB.app", curDir$)  ; 等待運算結束
; RunProgram(curDir$ + "AnnB.app", GetGadgetText(Editor_0), curDir$, #PB_Program_Wait)    ; 等待運算結束
; + "  " + GetGadgetText(Editor_0)
End




Parse_One_String:
  ; Debug StrForParse$
  a$ = LTrim(StrForParse$)
  a_len = Len(a$)
  ; Debug a_len
  While a$ <> ""
    b$ = LCase(Left(a$, 1))   ; 第一個字 轉成小寫
    ;If (Asc(b$) > $40) And (Asc(b$) < $5B)
    ;  b$ = Chr(Asc(b$) | $20)   
    ;EndIf
    Select b$
      Case "d"
        b$ =  Trim(Mid(a$, 6, a_len - 5))
        For i = 1 To item_count
          cells(pattern_to_set, i - 1) = Val(StringField(b$, i, ","))
        Next
        i = 16
        For j = 1 To result_count
          cells(pattern_to_set, i) = Val(StringField(b$, item_count + j, ","))
          ; Debug cells(pattern_to_set, i)
          i = i + 1
        Next        
        pattern_to_set = pattern_to_set + 1
        ; Debug "is data"

      Case "e"
        If StringField(a$, 1, " ") = "end"
          Debug "資料檔讀取完畢 !"
          a$ = ""   ; => Return
      EndIf

      Case "i"
        If StringField(a$, 1, " ") = "item_count"
          b$ =  Trim(Mid(a$, 12, a_len - 11))
          item_count = Val(StringField(b$, 1, " ")) 
          ; Debug item_count
        EndIf      

      Case "m"
        If StringField(a$, 1, " ") = "middle_count"
          b$ =  Trim(Mid(a$, 14, a_len - 13))
          middle_count = Val(StringField(b$, 1, " ")) 
          ; Debug middle_count
        EndIf

      Case "p"
        If StringField(a$, 1, " ") = "pattern_count"
          b$ =  Trim(Mid(a$, 15, a_len - 14))
          pattern_count = Val(StringField(b$, 1, " ")) 
          ; Debug pattern_count
        EndIf

      Case "r"
        If StringField(a$, 1, " ") = "result_count"
          b$ =  Trim(Mid(a$, 14, a_len - 13))
          result_count = Val(StringField(b$, 1, " ")) 
          ; Debug result_count
        EndIf

      Case "t"
        If StringField(a$, 1, " ") = "tags"
          str_to_read$ = a$
          begin_from = 5    ; 跳過 n 字元, 讀取雙引號包括的字串
          For mm = 1 To item_count
            Gosub Read_One_String
            ; Debug "#340 " + read_result$
            string_to_show$ = read_result$ ; read_result$ 是你已打包的文字, string_to_show$ 是 Prepare_To_Show 需要的參數
            Gosub Prepare_To_Show       ; 預處理文字, 呼叫完會得到 all_messages.my_message_items() 的索引值 return_index
            messages(pattern_to_set, mm - 1) = return_index
          Next mm

          For nn = 1 To result_count
            Gosub Read_One_String
            ; Debug "#349 " + read_result$
            string_to_show$ = read_result$ ; read_result$ 是你已打包的文字, string_to_show$ 是 Prepare_To_Show 需要的參數
            Gosub Prepare_To_Show       ; 預處理文字, 呼叫完會得到 all_messages.my_message_items() 的索引值 return_index
            messages(pattern_to_set, 16 + nn - 1) = return_index
          Next nn
        EndIf

      Default    
        Debug a$
    EndSelect
    a$ = ""
  Wend
Return

; 請把想分析處理的字串放到 string_to_show$ 然後呼叫此子程式
Prepare_To_Show:
  Dim answer$(8)   ; 預處理字串的輸出結果 max 8 lines in a message box 每個訊息框最多放 8 行
  ;local    begin_pos, found_pos, now_line, str_len, target_pos, last_pos
  line_count_to_show = 0
  max_char_count = 0
  string_length = Len(string_to_show$)
  now_line = 0     ; 每個訊息框最多放 8 行
  begin_pos = 1    ; 需要拷貝的開始位置 = 想開始尋找雙底線的位置 (雙底線代表下一行)
  Repeat
    answer$(now_line) = ""      ; 有可能想顯示的都是空白行, 因此先清除內容
    found_pos = FindString(string_to_show$, "__", begin_pos)   ; 若傳回 0 代表沒找到
    If found_pos > 0    ; 非零值代表有找到雙底線 "__"
      last_pos = found_pos
      found_pos = FindString(string_to_show$, "__", begin_pos + 1)   ; 續找下一個雙底線, 若傳回 0 代表沒找到
      answer$(now_line) = Mid(string_to_show$, begin_pos, last_pos - begin_pos)
      now_line = now_line + 1
      begin_pos = last_pos + 2    ; 修正下次拷貝的起點
    Else      ; 底下是沒找到雙底線 "__", 已經到全字串末端了
      answer$(now_line) = Mid(string_to_show$, begin_pos, string_length + 1 - begin_pos)
      now_line = now_line + 1
      begin_pos = string_length + 1
    EndIf
    ; 計算最長的字串長度 (bug: BIG-5 中文字是英文字的兩倍寬, 但此軟體僅把中文字看成英文字一樣, 導致字寬計算被減半
    If Len(answer$(now_line - 1)) > max_char_count
      max_char_count = Len(answer$(now_line - 1))
    EndIf
    line_count_to_show = line_count_to_show + 1
    Debug answer$(now_line - 1)
  Until begin_pos > string_length
  return_index = return_index + 1
  Debug "ret ndx = " + Str(return_index) + " , " + Str(line_count_to_show) + " lines, 最長字串是 " + Str(max_char_count) + " 個字"
  ; 記住訊息最多的行數
  If max_message_lines < line_count_to_show
    max_message_lines = line_count_to_show
  EndIf
  ; 儲存分析結果
  all_messages.my_message_items(return_index)\n_lines = line_count_to_show
  all_messages.my_message_items(return_index)\n_max_chars = max_char_count * 2 ; !!@@ UTF-8 中文字 = 2 英文字寬 @@!!
  For i = 0 To 7
    all_messages.my_message_items(return_index)\message[i] = answer$(i)
  Next i
Return

;tags "中大腦動脈梗塞", "上肢痙攣", "下肢痙攣", "針刺", "埋線"
Read_One_String:
  read_result$ = ""
  ; Debug "#405  bgn = " + Str(begin_from)
  this_str_len = Len(str_to_read$)
  bool_in_str = 0     ; 1=已經遇過第一個雙引號了,  0= 尚未遇到雙引號
  now_pos = begin_from
  Repeat
    ch$ = Mid(str_to_read$, now_pos, 1)
    Select ch$
      Case " "    ; 遇到空白
        If bool_in_str = 0    ; 0 = 尚未遇到雙引號, 直接忽略此空格
          now_pos = now_pos + 1   ; 準備看下一個字
        Else
          read_result$ = read_result$ + ch$   ; 加入此空格
          now_pos = now_pos + 1               ; 準備看下一個字
        EndIf

      Case Chr(34)   ; 遇到雙引號 ( \" =  double quote)
        now_pos = now_pos + 1  ; 準備看下一個字
        If bool_in_str = 0    ; 0 = 尚未遇到雙引號, 直接忽略此空格
          bool_in_str = 1
        Else    ; 1 = 現在遇到第二個雙引號, 結束讀取字串
          bool_in_str = 0
          begin_from = now_pos
          Break   ;  結束讀取字串
        EndIf
        
      Default
        now_pos = now_pos + 1               ; 準備看下一個字
        If ch$ = ","      ; 遇到逗號
          If bool_in_str = 0    ; 0 = 尚未遇到雙引號, 直接忽略此逗號
            Continue
          EndIf
        EndIf
        read_result$ = read_result$ + ch$   ; 加入此字元
          
    EndSelect
  Until now_pos >= this_str_len
Return

WriteDataFile:
  DeleteFile(curDir$ + OutPutFileName$)     ; 先刪除舊資料 !
  Fid = OpenFile(#PB_Any, curDir$ + OutPutFileName$, #PB_File_NoBuffering + #PB_File_SharedWrite) ; , #PB_File_SharedRead + #PB_File_SharedWrite
  *DATABUF = AllocateMemory(131072)   ; 夠放很多資料了 !!
  If *DATABUF
    FillMemory(*DATABUF, 131072)          ; 全部清成 0 
    *ptr = *DATABUF
    info$ = "This is an important neural network data file !" + Chr(13) + Chr(10) + "Please DO Not edit or change this file, thank you !" + Chr(26) + "Data begin from offset 128."
    PokeS(*ptr, info$, 128, #PB_UTF8)           ; 警告訊息最多放 128 字元
    *ptr = *DATABUF + 128                       ; 從 128 字元後開始放數位資料
    ; 4 個 32-bit Long --> item_count = 0, middle_count = 0, pattern_count = 0, result_count = 0
    PokeL(*ptr, item_count)
    *ptr = *ptr + 4
    PokeL(*ptr, middle_count)
    *ptr = *ptr + 4
    PokeL(*ptr, pattern_count)
    *ptr = *ptr + 4
    PokeL(*ptr, result_count)
    *ptr = *ptr + 4
    ; 4 個 32-bit Long --> max_message_lines, dummy_未使用, dummy_未使用, dummy_未使用
    PokeL(*ptr, max_message_lines)
    *ptr = *ptr + 4
    PokeL(*ptr, 0)    ; dummy_未使用
    *ptr = *ptr + 4
    PokeL(*ptr, 0)    ; dummy_未使用
    *ptr = *ptr + 4
    PokeL(*ptr, 0)    ; dummy_未使用
    *ptr = *ptr + 4
    ; 寫出 96*32 = 3072 個 16-bit Word, ptr = [160, 6304]
    For i = 0 To 95
      For j = 0 To 31
        PokeW(*ptr, cells(i, j))
        *ptr = *ptr + 2
      Next j
    Next i
    ; 寫出 32* all_messages.my_message_items()
    For i = 0 To 31
      PokeW(*ptr, all_messages.my_message_items(i)\n_lines)
      *ptr = *ptr + 2
      PokeW(*ptr, all_messages.my_message_items(i)\n_max_chars)
      *ptr = *ptr + 2
      For j = 0 To 7
        PokeS(*ptr, all_messages.my_message_items(i)\message[j], 256, #PB_UTF8)
        *ptr = *ptr + 256
      Next j
    Next i
  EndIf
  file_len = *ptr - *DATABUF
  Debug "Final data length = " + Str(file_len) + " bytes."
  WriteData(Fid, *DATABUF, file_len)
  CloseFile(Fid)
  Debug "分析好的資料已經寫出到特殊資料檔案: " + OutPutFileName$
Return
; IDE Options = PureBasic 6.21 - C Backend (MacOS X - x64)
; CursorPosition = 201
; FirstLine = 182
; EnableXP
; DPIAware
; Executable = AnnA.app