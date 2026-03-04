Structure  my_message_items
  n_max_chars.w       ; 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
  n_lines.w                ; 總行數 (決定訊息框的高度)
  message.s[8]           ; 最多放 8 行訊息
EndStructure

main:

Global DataLoaded = 0, annView = 1, item_count = 0, middle_count = 0, pattern_count = 0, result_count = 0
Global pattern_to_run = 0, pattern_to_set = 0, radius = 20, line_height = 16, v_distance = 120
Global firing_level = 69, feed_back = 4, color_firing, color_not_firing, net_limit =  90, DebugShow = 1
Global char_width = 8, half_char_width, entropy, entropy_Y, show_entropy = 1, max_run_count = 100
; char_width 是中文標籤寬度，目前實測放 8 剛好 (Kai TC 中文字寬度為 15.587 點)
; .b 的數值範圍是   -128 至   +127
; .w 的數值範圍是 -32768 至 +32767
Dim cells.w(96, 32)         ; 輸入層 (前 max 16) 期望輸出層 (後 max 16) 神經細胞, 最多 96 patterns, 每個 pattern 最多 16+16 items
Dim cells_out.w(16)         ; 運算中的輸出層 (max 16) 神經細胞
Dim targets.b(96, 16)       ; 希望輸出層的值, 集中在 1st pattern, 16 output results (只儲存 0 或 1)
Dim middle_layer.w(32)     ; 運算中的中間層神經細胞, 集中在 1st pattern, 32 middle layer cells
Dim net_top.b(1024)           ; 輸入層往中間層的神經鍵結強度 (net strength), 集中在 1st pattern. 索引= (輸入層 max * 32) +  中間層 max 32
Dim net_down.b(1024)       ; 中間層往輸出層的神經鍵結強度 (net strength),  集中在 1st pattern. 索引= (輸出層 max * 32) +  中間層 max 32
Dim training_done.b(96)     ; 1 = 訓練已完成, 0 = 仍在訓練中
Dim messages.b(96, 32)      ; 最高 96 patterns, 每個 pattern 擁有獨立的 32 個訊息 (儲存指到 all_messages 陣列的索引)
Dim max_entropy(96)         ; max 96 patterns, 其最高的熵值
Dim entropies.w(96, 1024)   ; max 96 patterns, 每個 pattern 擁有獨立的 1024 個熵值紀錄
Dim ErrorCount(96)
Dim name(16)
; --- 底下是 [訊息框] 所需要的 ---
Dim all_messages.my_message_items(32)   ; 宣告最高需要 (輸入層 16 + 輸出層16 = ) 32 個訊息框的相關儲存空間
Global line_count_to_show, max_char_count, max_message_lines = 0, return_index = -1, string_to_show$
Global Box_Background_color, Box_Line_color, Box_Line_Width, Box_Text_color, Message_X, Message_Y

half_char_width = char_width / 2
Box_Background_color = RGB(0, 64, 0)
Box_Line_color = RGB(200, 128, 64)
Box_Line_Width = 3
Box_Text_color = RGB(128, 255, 240)
;--- 以上是 [訊息框] 所需要的 ---

bool_show_tags = 1
entropy_Y = 100         ; 預留給畫出熵值的總高度 = 熵值外框 + 30
; FrontColor = RGB(90, 0, 0)
white_color = RGB(255, 255, 255)
color_firing = RGB(0, 0, 0) ; RGB(255, 0, 0)
color_not_firing = RGB(0, 0, 255)
color_yellow = RGB(128, 128, 0)
two_radius = radius + radius
three_radius = two_radius + radius
four_radius = two_radius + two_radius
BackGroundColor =  RGB(250, 250, 250) ; RGB(16, 16, 16)
Text_color_A = RGB(16, 16, 0) ;  RGB(255, 255, 0) ; 
Text_color_B = RGB(16, 0, 16) ;  RGB(255, 0, 255)
Line_color_A = RGB(0, 0, 0)    ; white_color
Target_color = RGB(10, 10, 10)   ; white_color

If LoadFont(9, "Kaiti TC", 13)         ; 11 for office, 13 for home. ("細明體" for PC)
  can_use_Font_1 = 9
EndIf
; 在 macOS 查詢 "Kaiti TC" 得到 Optional("楷體-繁 標準體")  size=13, rect = Optional((-1.105, -2.963958740234375, 14.482, 15.040969848632812))

curDir$ = GetCurrentDirectory()   ; 執行檔會變成 ~/PureBasic/AppB.app/Contents/
loc = FindString(curDir$, "AnnB")
If loc > 0
  curDir$ = Mid(curDir$, 1, loc - 1)  ; !! 修正路徑 !!
EndIf

; nParm = CountProgramParameters()
For i = 0 To 15
  name(i) = 0   ; 預置檔名為 "00000..."
Next i
;XIncludeFile "FormBB.pbf"
;OpenWindow_1()
nParm = 0
leng$ = "0"
;!! bug !! 參數無法使用, 必須從檔案 "temp_arg.txt" 讀取參數
Fid = OpenFile(#PB_Any, curDir$ + "temp_arg.txt", #PB_File_SharedRead)
If Fid <> 0
  nParm = 1
  arg$ = ReadString(Fid, #PB_UTF8 + #PB_File_IgnoreEOL)
  ;SetGadgetText(Editor_0, curDir$ + "temp_arg.txt")
  loc = FindString(arg$, Chr(13))
  If loc > 0
    leng$ = Mid(arg$, loc + 1)
    arg$ = Mid(arg$, 1, loc - 1)
  EndIf
  CloseFile(Fid)
EndIf

If nParm > 0
  For i = 0 To nParm - 1
    ; arg$ =  ProgramParameter(i)
    If i = 0
      For j = 1 To 16
        k = Asc(Mid(arg$, j, 1))
        name(j - 1) = k
      Next j
    EndIf
  Next i
EndIf

For pattern = 0 To 95
  training_done(pattern) = 0             ; 0 = 仍在訓練中
  max_entropy(pattern) = 0               ; 0 = 仍在訓練中
Next pattern

; 清除所有輸入層及期望輸出層神經細胞為 0
For pattern = 0 To 95
  For both_item = 0 To 31
    cells(pattern, both_item) = 0
  Next both_item
Next pattern

; 每次 Run_Once 會清除所有中間層與輸出層神經細胞為 0

; 清除所有神經鍵結強度為 0.5
For net_count = 0 To 1023
  net_top(net_count) = 0      ; 輸入層往中間層的神經鍵結強度
  net_down(net_count) = 0   ; 中間層往輸出層的神經鍵結強度
Next net_count

; 載入學習資料檔
Gosub LoadDataFile

If DataLoaded = 1
  
  ; Debug FormatDate("Start ! UTC time: %hh:%ii:%ss", DateUTC())
  ; 儲存希望輸出層神經細胞 (拷貝檔案指定的輸出層陣列到 targer 陣列)
  For pattern = 0 To 95
    For i = 0 To 15
      If cells(pattern, 16 + i) > firing_level
        targets(pattern, i) = 1   ; (只儲存 0 或 1)
      Else
        targets(pattern, i) = 0   ; (只儲存 0 或 1)
      EndIf
    Next i
  Next pattern

  ; Gosub Clear_Result_cells
  total_run_count = 0
  For run_count = 1 To max_run_count
    err_count = 0
    For pattern = 0 To pattern_count - 1
      ; If training_done(pattern) = 1    ; 訓練已完成 --> 此資料群免再訓練
      ;  Gosub Draw_Graphs
      ;  Continue
      ; EndIf
      ;If training_done(pattern) = 0
        pattern_to_run = pattern
        Gosub Run_Once
        total_run_count = total_run_count + 1
        ; Gosub Draw_Graphs
        entropy = 0   ; 清除此回合熵值為 0
        Gosub FeedBack_Once
        entropies(pattern, run_count) = entropy
        If training_done(pattern_to_run) = 0    ; 1= 成功, 0 = 此回合失敗
          ErrorCount(pattern_to_run) = ErrorCount(pattern_to_run) + 1
        EndIf
        
        ; Debug "#159: 單回合至今 ErrCnt=" + Str(err_count) + " , 第 " + Str(pattern_to_run) +  " 組, 本次樣式 Err count = " + Str(ErrorCount(pattern_to_run)) + " , 本次樣式成功: " + Str(training_done(pattern_to_run)) + " , 熵值: " + Str(entropy) + " , 總執行回合數 = " + Str(run_count)
        ; Gosub Draw_Graphs
      ;EndIf
    Next pattern
    If err_count = 0
      Debug "恭喜 ! 訓練已完成 !" + Str(ErrorCount(0)) + "_" + Str(ErrorCount(1)) + "_" + Str(ErrorCount(2))
      ; End
      Break   ; 全部訓練已完成 !
    EndIf
  Next run_count
Else
    MessageRequester("錯誤", "無法開啟資料檔案 !", #PB_MessageRequester_Error)
	;End
EndIf

Gosub Draw_Graphs
; Debug FormatDate("Done ! UTC time: %hh:%ii:%ss", DateUTC())
dump_which = 0    ; 0 = dump top net, 1 = dump down net
Gosub Dump_net
dump_which = 1    ; 0 = dump top net, 1 = dump down net
Gosub Dump_net
pattern_to_run = 0
Gosub Run_Once
Gosub Draw_Graphs
OutPutNetName$ = "AnnNets.BIN"
Gosub Save_nets     ; 保存神經鍵值
Debug "Bye: " + Str(ErrorCount(0)) + "_" + Str(ErrorCount(1)) + "_" + Str(ErrorCount(2))
ButtonGadget(15, 10, 32, 160, 32, "請按我來結束程式 !")    ; 無效
i = 0
Repeat
  Event = WaitWindowEvent()
  ; Debug EventGadget()
  If EventGadget() = 15
    ;D ebug Event
    i = i + 1
    If i > 1
      Break   ; exit program !
    EndIf
  EndIf
Until Event = #PB_Event_CloseWindow
End

LoadDataFile:
  Fid = OpenFile(#PB_Any, curDir$ + "ANNData.BIN")    ; return none-zero = O. , #PB_File_SharedRead
  If Fid <> 0
    len = 71968 ; Val(leng$)
    If len < 1
      MessageRequester("錯誤", "無法開啟 ANNData.BIN ! 檔案長度為零 !", #PB_MessageRequester_Error)
      End
    EndIf
    *DATABUF = AllocateMemory(len)
    If ReadData(Fid, *DATABUF, len) = 0              ; Failed !
      MessageRequester("錯誤 #211", Str(Fid) + " read 0 byte !", #PB_MessageRequester_Error)
      Return
    EndIf
    CloseFile(Fid)
    *ReadPos = *DATABUF + 128                           ;
    ; 4 x 32-bit Long --> item_count = 0, middle_count = 0, pattern_count = 0, result_count = 0
    item_count = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    middle_count = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    pattern_count = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    result_count = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    ; 4 x 32-bit Long --> max_message_lines, dummy_, dummy_, dummy_
    max_message_lines = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    dummy_not_use = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    dummy_not_use = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    dummy_not_use = PeekL(*ReadPos)
    *ReadPos = *ReadPos + 4
    ; read 32*32 = 1024 x 16-bit Word, ptr = [160, 2208)
    ; Debug "pos1 = " + Str(*ReadPos - *DATABUF)
    For i = 0 To 95
      For j = 0 To 31
        cells(i, j) = PeekW(*ReadPos)
        *ReadPos = *ReadPos + 2
      Next j
    Next i
    ; Debug "pos2 = " + Str(*ReadPos - *DATABUF)
    ; read 32* all_messages.my_message_items() --> [2208, ..
    For i = 0 To 31
      all_messages.my_message_items(i)\n_lines = PeekW(*ReadPos)
      *ReadPos = *ReadPos + 2
      all_messages.my_message_items(i)\n_max_chars = PeekW(*ReadPos)   ; !! 中文字需加寬
      *ReadPos = *ReadPos + 2
      For j = 0 To 7
        all_messages.my_message_items(i)\message[j] = PeekS(*ReadPos, 256, #PB_UTF8)    ; !! only ASCII is used now -- 會自動轉成 UTF-8 !!
        ss$ = Trim(all_messages.my_message_items(i)\message[j])
        If Len(ss$)  > 0
          Debug "字數: " + Str(all_messages.my_message_items(i)\n_max_chars) + " -> [" + ss$ + "] 字串長度 ＝ " + Len(ss$) 
        EndIf
        *ReadPos = *ReadPos + 256
      Next j
      For j = 0 To 15
        messages(i, j) = j;   ; 輸入層的標籤
        messages(i, 16 + j) = item_count + j    ; 輸出層的標籤
      Next j
    Next i
    DataLoaded = 1
  EndIf
Return

; 清除所有輸出層神經細胞為 0
Clear_Result_cells:
  For pattern_i = 0 To pattern_count - 1
    For result_item = 0 To result_count - 1
      cells(pattern_i, 16 + result_item) = 0
    Next result_item
  Next pattern_i
Return

Dump_net:
  k = 0
  If dump_which = 0
    For i = 0 To item_count - 1
      answer$ = ""
      For j = 0 To middle_count - 1
        answer$ = answer$ + Str(net_top(k + j)) + ", "
      Next j  
      Debug answer$
      k = k + 32
    Next i  
  Else
    For i = 0 To middle_count - 1
      answer$ = ""
      For j = 0 To result_count - 1
        answer$ = answer$ + Str(net_down(k + j)) + ", "
      Next j  
      Debug answer$
      k = k + 32
    Next i
  EndIf
Return

Draw_Graphs:
  title$ = "神經網路編號 #" + Str(pattern_to_run)
  max_x_cnt = item_count    ; 找出三者的最大值
  If result_count > max_x_cnt
    max_x_cnt = result_count
  EndIf
  If middle_count > max_x_cnt
    max_x_cnt = middle_count
  EndIf
  
  width_no = (max_x_cnt + max_x_cnt + 1) * two_radius   ; 準備計算畫面寬度
  If width_no < 640
    width_no = 640
  EndIf
  v_height = v_distance >> 1
  all_msg_max_height = (max_message_lines * line_height) + 10
  entropy_max_Y = 0
  If show_entropy > 0          ; 增加畫出熵值空間
    entropy_max_Y = entropy_Y
    entropy_box_Height = entropy_Y - (line_height * 2)  ; 熵值外框上下都保留一行 (16 dot)
  EndIf

  If mainViewOK = 0
    If OpenWindow(annView, 0, 0, width_no, v_height * 6, title$, #PB_Window_ScreenCentered)
      real_width = width_no ; - 90
      real_height = (v_height * 6) + all_msg_max_height + line_height + line_height + line_height + entropy_max_Y ; - 11
      ResizeWindow(annView, 500, 0, real_width, real_height)
      mainViewOK = 1
    EndIf
  EndIf

  If mainViewOK = 1
    ; 畫面必須已經設定好, 才可以繪圖
    If CreateImage(annView, real_width, real_height) And StartDrawing(ImageOutput(annView))
      DrawingMode(#PB_2DDrawing_Default)    ; 不透明, 直接覆蓋 !
      If can_use_Font_1 = 1
        DrawingFont(FontID(1))
      EndIf
      Box(0, 0, real_width, real_height, BackGroundColor)   ; 清除整個畫面
      ; 先畫出輸入端的神經細胞 (item_count)
      xc = radius + ((width_no - (item_count + item_count) * two_radius) >> 1)
      now_y = v_height + all_msg_max_height
    For x = 0 To item_count - 1
      cell_value = cells(pattern_to_run, x)
      Gosub Draw_Cell_Body ; 如果神經細胞強度足, 則顯示實心數字, 如果強度不足 --> 產生外框字
      If bool_show_tags = 1
        Message_X = xc - (all_messages.my_message_items(messages(pattern_to_set, x))\n_max_chars * half_char_width)
        Message_Y = line_height + 8 + ((max_message_lines - all_messages.my_message_items(messages(pattern_to_set, x))\n_lines) * (line_height >> 1))
        Message_Num_To_Show = messages(pattern_to_set, x)
        Gosub Show_Message
      EndIf
      xc = xc + four_radius
    Next x
    
    ; 然後畫出中間層的神經細胞 (middle_count)
    xc = two_radius + ((width_no - (middle_count + middle_count) * two_radius) >> 1)
    now_y = now_y + v_distance
    For x = 0 To middle_count - 1
      cell_value = middle_layer(x)
      Gosub Draw_Cell_Body ; 如果神經細胞強度足, 則顯示實心數字, 如果強度不足 --> 產生外框字
      xc = xc + four_radius
    Next x

    ; 然後畫出輸出層的神經細胞 (result_count)
    xc = radius + ((width_no - (result_count + result_count) * two_radius) >> 1)
    now_y = now_y + v_distance
    For x = 0 To result_count - 1
      cell_value = cells_out(x)    ; cells(pattern_to_run, 16 + x)
      Gosub Draw_Cell_Body ; 如果神經細胞強度足, 則顯示實心數字, 如果強度不足 --> 產生外框字
      ; 印出期望目標
      DrawText(xc - 28, now_y + radius + 4, "目標=" + Str(targets(pattern_to_run, x)), Target_color, BackGroundColor)
      If bool_show_tags = 1
        Message_X = xc - (all_messages.my_message_items(messages(pattern_to_set, 16 + x))\n_max_chars * half_char_width)
        Message_Y = now_y + radius + line_height + 8 + ((max_message_lines - all_messages.my_message_items(messages(pattern_to_set, 16 + x))\n_lines) * (line_height >> 1))
        Message_Num_To_Show = messages(pattern_to_set, 16 + x)
        Gosub Show_Message
      EndIf
      xc = xc + four_radius
    Next x
    
    ; 畫出輸入層往中間層的神經鍵結強度
    xc = radius + ((width_no - (item_count + item_count) * two_radius) >> 1)
    x_origin = radius + ((width_no - (middle_count + middle_count) * two_radius) >> 1)
    now_y = v_height + radius + all_msg_max_height + 2
    For x = 0 To item_count - 1
      loc_x =  x * 32         ; 中間層固定保留 32 個位置
      For to_x = 0 To middle_count - 1
        strength = net_top(loc_x)
        strength_c = (strength * 2) + 31
        If strength_c > 240 
          strength_c = 240
        EndIf
        color_no = RGB(strength_c, strength_c, strength_c)
        LineXY(xc, now_y, x_origin + four_radius * to_x + radius, now_y + v_distance - two_radius - 4, color_no)
        loc_x = loc_x + 1
      Next to_x
      xc = xc + four_radius
    Next x  
    
    ; 畫出中間層往輸出層的神經鍵結強度
    xc = radius + ((width_no - (result_count + result_count) * two_radius) >> 1)
    ; x_origin = radius + ((width_no - (middle_count + middle_count) * two_radius) >> 1)
    now_y = v_height + v_distance - radius + all_msg_max_height + 6
    For x = 0 To result_count - 1
      loc_x =  x * 32         ; 中間層固定保留 32 個位置
      For to_x = 0 To middle_count - 1
        strength = net_down(loc_x)
        strength_c = (strength * 2) + 31
        If strength_c > 240 
          strength_c = 240
        EndIf
        color_no = RGB(strength_c, strength_c, strength_c)
        LineXY(xc, now_y + v_distance - 8, x_origin + four_radius * to_x + radius, now_y + two_radius - 4, color_no)
        loc_x = loc_x + 1
      Next to_x
      xc = xc + four_radius
    Next x
    
    number$ = "第 " + Str(pattern_to_run) + " 組" + "回授值 = " + Str(feed_back) + ", 執行第 " + Str(run_count) + " 回合"
    If BackGroundColor < RGB(32, 32, 32)
      ; 黑底黃字 (適用於電腦顯示)
      DrawText(4,   4, number$, Text_color_A, BackGroundColor)
    Else
      ; 白底黑字 (適用於紙張輸出)
      DrawText(4,   4, number$, RGB(16, 16, 16), BackGroundColor)
    EndIf
    
    ; 畫出熵值的座標軸
    xc = 20
    now_y = (v_height * 3) + (all_msg_max_height * 2) + (v_distance * 2) + (line_height * 2)
    LineXY(xc, now_y - entropy_box_Height, xc, now_y, Line_color_A)  ; 畫 Y 軸
    LineXY(xc, now_y, width_no - 20, now_y, Line_color_A)            ; 畫 X 軸
    DrawText(4,  now_y - entropy_box_Height - line_height, "熵值", Text_color_A, BackGroundColor)
    If run_count > 0
      x_gap = (width_no - 40 - 30) / run_count  ; 相鄰每個熵值的間距 (dots)
      xc = 35                                   ; 20 (Y 軸與左邊的間距) + 15 (Y 軸與右邊第一項熵值的間距)
      If max_entropy(pattern_to_run) < 1
        unit_height = (entropy_box_Height / 3)
      Else
        unit_height = (entropy_box_Height / max_entropy(pattern_to_run))
      EndIf
      For to_x = 1 To run_count
        this_y = now_y - (unit_height * entropies(pattern_to_run, to_x))
        Circle(xc, this_y, 4, Line_color_A)
        number$ = Str(entropies(pattern_to_run, to_x))
        If to_x & 1 = 0
          DrawText(xc - 8,  this_y - line_height - 6,  number$, Text_color_B, BackGroundColor)
        Else
          DrawText(xc - 8,  this_y + line_height - 8,  number$, Text_color_B, BackGroundColor)          
        EndIf
        If to_x > 1
          LineXY(xc, this_y, xc - x_gap, last_y, Line_color_A)
        EndIf
        last_y = this_y
        xc = xc + x_gap
      Next to_x
    EndIf
    StopDrawing()
    ImageGadget(annView, 0, 0, real_width, real_height, ImageID(annView))
    EndIf
  EndIf
Return

Draw_Cell_Body:
  color_no = RGB(cell_value << 1, cell_value << 1, cell_value << 1)
  Circle(xc, now_y, radius + 2, color_yellow)
  Circle(xc, now_y, radius, color_no)
  number$ = Str(cell_value)
  If cell_value > firing_level
    number_color = color_firing
  Else
    number_color = color_not_firing
  EndIf
  x_to_sub = 8
  If cell_value = 100
    x_to_sub = 13
  EndIf
  If cell_value = 0
    x_to_sub = 2
  EndIf
  DrawingMode(#PB_2DDrawing_Transparent)
  If cell_value < firing_level
    DrawText(xc - x_to_sub - 1, now_y -  8, number$, white_color)
    DrawText(xc - x_to_sub - 1, now_y - 10, number$, white_color)
    DrawText(xc - x_to_sub + 1, now_y -  8, number$, white_color)
    DrawText(xc - x_to_sub + 1, now_y - 10, number$, white_color)
  EndIf
  DrawText(xc - x_to_sub, now_y - 9, number$, number_color)
  DrawingMode(#PB_2DDrawing_Default)
Return
      
; 直接對 net_top 或 net_down 鍵結值強度做 [增加 feed_back 值] 的動作
Add_Net_Down_Power:
  
  ; Debug "#439 index_result= " + Str(index_result) + "  將增 net_down: "
  For mid_n = 0 To middle_count - 1
    ; 檢查中間層, 如果未激活, 則須加強全部 net_top; 如果有激活, 則加強 net_down (bug: 若未激活, 仍需加強 net_down !)
    ; If middle_layer(mid_n) > firing_level
      ; 中間層激活, 須加強 net_down !
      ; Debug "#418  中間層= " + Str(middle_layer(mid_n)) + " , 加強下鍵結=" + Str(net_down(j + mid_n))
      j = mid_n * 32
      net_down(j +  index_result) = net_down(j +  index_result) + feed_back
      If net_down(j +  index_result) > net_limit
        net_down(j +  index_result) = net_limit
      EndIf    
    ; EndIf   ; 檢查中間層 OK

    ; 需加強 net_top !
    k = 0
    For i = 0 To item_count  - 1
      If cells(pattern_to_run, i) > firing_level
        net_top(k + mid_n) = net_top(k + mid_n) + feed_back
        If net_top(k + mid_n) > net_limit
          net_top(k+ mid_n) = net_limit
        EndIf
      EndIf
      k = k + 32
    Next i

    If show_entropy <> 0      ; 如果需要顯示熵值
      entropy = entropy + 1
      If max_entropy(pattern_to_run) < entropy
        max_entropy(pattern_to_run) = entropy
      EndIf
    EndIf
  Next mid_n
Return

; 直接對 net_down 鍵結值強度做 [減少 feed_back 值] 的動作
Sub_Net_Down_Power:
  ; j = index_result * 32
  ; Debug  "#444 index_result= " + Str(index_result) + "  將減 net_down: "
  For mid_n = 0 To middle_count - 1
    ; 檢查中間層, 如果未激活, 則免減少; 如果有激活, 則須減少
    ; If middle_layer(mid_n) > firing_level
      ; 中間層有激活, 須減少 net_down !
      ; Debug "#449  中間層(有激活)= " + Str(middle_layer(mid_n)) + " , 須減少下鍵結=" + Str(net_down(j + mid_n))
      j = mid_n * 32
      net_down(j + index_result) = net_down(j + index_result) - feed_back
      If net_down(j + index_result) < -70
        net_down(j + index_result) = -70
      EndIf
    ; EndIf   ; 檢查中間層 OK
    
    ; 減少 net_top !
    k = 0
    For i = 0 To item_count  - 1
      If cells(pattern_to_run, i) > firing_level
        net_top(k + mid_n) = net_top(k + mid_n) - feed_back
        If net_top(k + mid_n) < -70
          net_top(k+ mid_n) = -70
        EndIf
      EndIf
      k = k + 32
    Next i

    If show_entropy <> 0      ; 如果需要顯示熵值
      entropy = entropy + 1
      If max_entropy(pattern_to_run) < entropy
        max_entropy(pattern_to_run) = entropy
      EndIf
    EndIf
  Next mid_n
Return

FeedBack_Once:
  ; 從輸出層開始, 如果與預期結果不合, 則回溯修正上層的 net 鍵結強度
  last_error_count = err_count
  For index_fb = 0 To result_count - 1
    ; this_cell = cells(pattern_to_run, 16 + index_fb)
    index_result = index_fb
    this_cell = cells_out(index_fb)
    ; 把輸出層的神經細胞值 轉成 0 或 1 來進行比較
    If this_cell > firing_level
      this_cell = 1
    Else
      this_cell = 0
    EndIf
    ; Debug "491 FB: " + Str(pattern_to_run) + "組. " +  Str(index_fb) + ". 出" +  Str(cells_out(index_fb)) + ". 目標" + Str(targets(pattern_to_run, index_fb))
    ; 如果與預期結果不合
    If this_cell <> targets(pattern_to_run, index_fb)   ; (targets 只儲存 0 或 1)
      err_count = err_count + 1
      If this_cell = 0
        ; Debug "第 " + Str(pattern_to_run) + " 組: 現值太低 = 0, 目標值是 1 --> add"
        Gosub Add_Net_Down_Power    ; #408 現值太低 = 0, 目標值是 1
      Else
        ; Debug "第 " + Str(pattern_to_run) + " 組: 現值太高 = 1, 目標值是 0 --> sub"
        Gosub Sub_Net_Down_Power    ; #442 現值太高 = 1, 目標值是 0 
      EndIf
    EndIf
  Next index_fb 
  If last_error_count = err_count
    training_done(pattern_to_run) = 1    ; 標記訓練已完成
  EndIf
Return

Run_Once:
  ; 清除中間層神經細胞為 0
  For i = 0 To middle_count - 1
    middle_layer(i) = 0
  Next i
  ; 清除輸出層神經細胞為 0
  For i = 0 To result_count - 1
    cells_out(i) = 0
  Next i
  ; Debug "Run_Once  #548  Patn = " + Str(pattern_to_run)
  For i = 0 To item_count - 1
    If cells(pattern_to_run, i) > firing_level
      ; 執行至此處為激發狀態, 將透過 net_top 裡的數值往下傳遞到下一層神經細胞
      index_base = i * 32
      For j = 0 To middle_count - 1
        ; Debug "#532  輸入層 " + Str(i) + " 值= " + Str(cells(pattern_to_run, i)) + " 激發!!  mid[" + Str(j) + "]=" + Str(middle_layer(j)) + " + " + Str(net_top(index_base + j))
        middle_layer(j) = middle_layer(j) + net_top(index_base + j)
        If middle_layer(j) > 100
          middle_layer(j) = 100
        EndIf
      Next j
    Else 
      ; Debug "#561 輸入層 " + Str(i) + " 值= " + Str(cells(pattern_to_run, i)) + " --> 沒激發"
    EndIf
  Next i

  For i = 0 To middle_count - 1
    If middle_layer(i) > firing_level
      ; 執行至此處為激發狀態, 將透過 net_down 裡的數值往下傳遞到下一層神經細胞
      For j = 0 To result_count - 1
        index_base = i * 32
        ; Debug "#570 中間層 " + Str(i) + " 值= " + Str(middle_layer(i)) + " 激發!!  out[" + Str(j) + "]=" + Str(cells_out(j)) + " + " + Str(net_down(index_base + i))
        cells_out(j) = cells_out(j) + net_down(index_base + j)
        If cells_out(j) > 100
          cells_out(j) = 100
        EndIf
      Next j
    Else 
      ; Debug "#555 中間層 " + Str(i) + " 值= " + Str(middle_layer(i)) + " --> 沒激發"
    EndIf
    index_base = index_base + 32
  Next i
Return

Save_nets:
; 保存神經鍵值  net_top.b(512) + net_down.b(512) = 1024 bytes
;DeleteFile(curDir$ + OutPutNetName$)  ; 先刪除舊資料 !
*DATABUF = AllocateMemory(8192)     ; 夠放很多資料了 !!
If *DATABUF
  FillMemory(*DATABUF, 8192)        ; 全部清成 0
  *ptr = *DATABUF     ; 頭 32 bytes 為 六大證型結果 (以 0、1 格式代表)
  ans$ = ""
  For i = 0 To item_count - 1
    If name(i) > 0
      PokeB(*ptr,  name(i))   ; 英文字 or 49 = ASCII 的文字 "1"  (此為檔名後六碼)
      ans$ = ans$ + Chr(name(i))
    Else
      PokeB(*ptr,  48)          ; 48 = ASCII 的文字 "0"  (此為檔名後六碼)
      ans$ = ans$ + "0"
    EndIf
    *ptr = *ptr + 1
  Next i
  PokeB(*ptr, 26)            ; 寫出 0x1A (End of File) --> type 此檔案時, 只會秀出六大證型結果
  
  If ans$ <> "000000"
    OutPutNetName$ = "AN" + ans$ + ".BIN"
  EndIf
;  OutPutNetName$ = "AN100100.BIN"
  file_id = OpenFile(#PB_Any, curDir$ + OutPutNetName$, #PB_File_SharedWrite)
  *ptr = *DATABUF + 32    ; 移位到 32 的位置
  ; 寫出 (皆為 16-bits) 輸入層的細胞數、中間層的細胞數、輸出層的細胞數、firing_level、訊息字串數
  PokeW(*ptr, item_count)
  *ptr = *ptr + 2
  PokeW(*ptr, middle_count)
  *ptr = *ptr + 2
  PokeW(*ptr, result_count)
  *ptr = *ptr + 2
  PokeW(*ptr, firing_level)
  *ptr = *ptr + 2
  PokeW(*ptr, 32)        ; 目前訊息數, 最大值 = 32
  *ptr = *ptr + 8     ; 移位到 32 的位置
  ; 輸出 net_upper(item_count, middle_count) 以 8-bit 無號數儲存 (0 .. 255)
  k = 0     ; 對應輸入層 16 cells, 中間層  32 cells, 輸出層 16 cells
  For i = 0 To item_count - 1
    For j = 0 To middle_count - 1
      PokeB(*ptr, net_top(k + j))
      *ptr = *ptr + 1
    Next j
    k = k + 32    ; 中間層  32 cells
  Next i
  ; 輸出 net_lower(middle_count, result_count) 以 8-bit 無號數儲存 (0 .. 255)
  k = 0
  For i = 0 To middle_count - 1
    For j = 0 To result_count - 1
      PokeB(*ptr, net_down(k + j))
      *ptr = *ptr + 1
    Next j
    k = k + 32    ; 中間層  32 cells
  Next i
  ; 輸出 all_messages.my_message_items(32) 簡化版訊息字串表
  For i = 0 To 31     ; ==> my_message_items(32)
    ans$ = ""               ; 把所有八行的訊息字串收集到 ans$
    For j = 0 To 7
      Tmp$ = all_messages.my_message_items(i)\message[j]
      slen = Len(Tmp$)
      If slen > 0
        ans$ = ans$ + Tmp$ + Chr(13)    ; 以 #13 (CR) 作為每一行之分界
      EndIf
    Next j
    slen = Len(ans$) * 2 ; !! 中文字僅被當成一字, 最後的 ASCIZ  也算一字 ("風證" --> 3 字 !)
    PokeW(*ptr, slen)     ; 寫出字串長度
    *ptr = *ptr + 2
    If slen > 0
      PokeS(*ptr, ans$, slen, #PB_UTF8)
      *ptr = *ptr + slen
    EndIf
  Next i
  ; -- 寫出 期望輸出表 target table --> targets.b(96, 16)   
  i = *ptr - *DATABUF     ; 現在位置 =  offset of target table
  *saveptr = *ptr
  *ptr = 42 + *DATABUF ; 移至 file offset 42 (0x2A) 
  PokeW(*ptr, i)                ; 填入期望輸出表 offset of target table
  *ptr = *ptr + 2
  PokeW(*ptr, pattern_count)                ; 填入總訓練組數
  *ptr = *saveptr
  For pattern = 0 To pattern_count - 1  ; 輸出所有的訓練組資料 
    For i = 0 To result_count - 1           ; 按照輸出層細胞數量
      PokeB(*ptr, targets(pattern, i))       ; 填入 "期望輸出" (0 or 1)
      *ptr = *ptr + 1
    Next i
  Next pattern
  ; --- done ! (406 -->  982)
  file_len = *ptr - *DATABUF
  WriteData(file_id, *DATABUF, file_len)
  CloseFile(file_id)
  ; SetGadgetText(Text_7, info$ + "已成功儲存 " + Str(file_len) + " bytes 到 " + curDir$ + OutPutNetName$)
EndIf
Return

Show_Message:
  index = Message_Num_To_Show
  ; bug: 中文字的長度必須加倍 ! (中文字 * 20) (英文字 * 10)
  msg_max_width = (all_messages.my_message_items(index)\n_max_chars * char_width)    ; !! 長度無法精確計算 !! (需保證夠寬)
  Debug "msg_max dots = " + Str(msg_max_width) + ", nMaxC = " + Str(all_messages.my_message_items(index)\n_max_chars) + ", chW = " + Str(char_width)
  num_lines = all_messages.my_message_items(index)\n_lines
  this_msg_max_height = (num_lines * line_height) + 10
  Box(Message_X, Message_Y, msg_max_width, this_msg_max_height, Box_Line_color)
  two_line_width = Box_Line_Width + Box_Line_Width
  x_pos = Message_X + Box_Line_Width
  y_pos = Message_Y + Box_Line_Width
  Box(x_pos, y_pos, msg_max_width - two_line_width, this_msg_max_height - two_line_width, Box_Background_color)
  ; Debug "572 " + Str(index)
  For i = 1 To num_lines
    DrawText(x_pos + 2, y_pos + 2, all_messages.my_message_items(index)\message[i - 1], Box_Text_color, Box_Background_color)
    y_pos = y_pos + line_height
  Next i
Return
; IDE Options = PureBasic 6.21 - C Backend (MacOS X - x64)
; CursorPosition = 258
; FirstLine = 232
; EnableXP
; DPIAware
; Executable = AnnB.app