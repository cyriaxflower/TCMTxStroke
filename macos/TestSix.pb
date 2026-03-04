XIncludeFile "Six_File.pbf"
XIncludeFile "FilePick.pbf"
XIncludeFile "FormCalc.pbf"
OpenWindow_0()
OpenWindow_1()

Structure  my_message_items
  n_max_chars.w       ; 最長的一行裡, 有幾個英文字 (決定訊息框的寬度)
  n_lines.w                ; 總行數 (決定訊息框的高度)
  message.s[8]           ; 最多放 8 行訊息
EndStructure

DataSection
  Data.s  "此為空白", "   風證   ", "  火熱證  ", "   痰證   ", "  血瘀證  ", "  氣虛證  ", "陰虛陽亢證"
  Data.i  0,  58, 56, 59, 76, 63, 52
EndDataSection

Dim group_score.i(7)     ; 六大證型目前得到幾分
Dim max_score.i(7)       ; 六大證型總分
Dim group_id.s(7)         ; 六大證型名稱
Dim cells_input.w(256)      ; 輸入層 (max 256) 
Dim cells_middle.w(256)   ; 中間層 (max 256) 
Dim cells_output.w(256)   ; 輸出層 (max 256) 
Dim targets.b(96, 16)        ; 希望輸出層的值, 集中在 1st pattern (max 96 patterns), 16 output results (只儲存 0 或 1)
Dim net_upper.w(256, 256)    ; 輸入層 -> 中間層的神經網路加權值 (weights)
Dim net_lower.w(256, 256)    ; 中間層 -> 輸出層的神經網路加權值 (weights)
Dim messages.b(32, 32)       ; 最高 32 patterns, 每個 pattern 擁有獨立的 32 個訊息 (儲存指到 all_messages 陣列的索引) --> 目前只使用前 32 個 !!
Dim six_file_names.s(128)   ; 最高 128 檔案名稱 (六大證型的神經網路訓練後的網路加權值存檔)
Dim other_names.s(128)      ; 最高 128 檔案名稱 (其他證型的神經網路訓練後的網路加權值存檔)
Dim lab_names.s(128)        ; 最高 128 檔案名稱 (檢驗資料的神經網路訓練後的網路加權值存檔)
Dim file_type.s(3)               ; 檔案選取盒的目前狀態
Global input_count = 6       ; 輸入層有效細胞數, 上限 256
Global middle_count = 10  ; 中間層有效細胞數, 上限 256
Global output_count = 9     ; 輸出層有效細胞數, 上限 256
Global firing_level = 69     ; 大於此值, 則神經細胞活化
Global pattern_count = 1    ; 總訓練組數
Global pattern = 0              ; 應該選擇的是哪一組
Global mode_select = 0      ; 0 = 六大證型檔案挑選, 1 = 其他中醫證型檔案挑選, 2 = 檢驗資料檔案挑選
; --- 底下是 [訊息框] 所需要的 ---
Dim all_messages.my_message_items(32)   ; 宣告最高需要 (輸入層 16 + 輸出層16 = ) 32 個訊息框的相關儲存空間
Global line_count_to_show, max_char_count, max_message_lines = 0, return_index = -1, string_to_show$
Global Box_Background_color, Box_Line_color, Box_Line_Width, Box_Text_color, Message_X, Message_Y
Global count_six_names, total_n_files, total_n_patterns
Global opt_checked = 0      ; PureBasic bug ! 無法點掉 option ! 必須自己來 !!
Global files_done = 0, Final_Good = 0, Final_Error = 0

HideWindow(Window_1, #True)
OpenWindow_2()
SetGadgetText(Editor_0_Copy1, "期望_輸出活化")
SetGadgetText(Editor_0_Copy2, "期望_輸出不活化")
SetGadgetText(Editor_0_Copy3, "實際_輸出活化")
SetGadgetText(Editor_0_Copy6, "實際_輸出不活化")
HideWindow(Window_2, #True)
curDir$ = GetCurrentDirectory()
Total_Error_Count = 0
count_six_names = 0       ; 搜尋到的六大證型的神經網路訓練後的網路加權值存檔  檔案數量
count_lab_names = 0       ; 搜尋到的其他證型的神經網路訓練後的網路加權值存檔  檔案數量
count_other_names = 0    ; 搜尋到的檢驗資料的神經網路訓練後的網路加權值存檔  檔案數量
six_file_names(127) = "." ; 此為代表尾端的記號
other_names(127) = "."    ; 此為代表尾端的記號
lab_names(127) = "."      ; 此為代表尾端的記號
file_type(0) = "六大證型"
file_type(1) = "其他中醫證型"
file_type(2) = "檢驗資料"
For i = 0 To 6
  Read.s group_id(i)      ; 六大證型名稱
Next i
For i = 0  To 6
  Read.i max_score(i)    ; 六大證型總分
Next i
; 混淆矩陣計算用途: TT=True/True, TF=True/False, FT=False/True, FF=False/False (前:實際輸出, 後: 期望輸出)
all_TT = 0
all_TF = 0
all_FT = 0
all_FF = 0
; 預備輸出結果檔案
OutPutFileName$ = "TestSix.txt"         ; 輸出測試結果
OutPutFileName$ = curDir$ + OutPutFileName$   ; 輸出檔案 
If FileSize(OutPutFileName$) > 0
  Debug  "!! 輸出結果檔案已經存在, file size > 0, 檔案內容將被清除 !!"
EndIf
Fid = CreateFile(#PB_Any, OutPutFileName$, #PB_File_SharedWrite)
;!! bug !! 反覆寫入會遇到檔案大小上限 4096 bytes, 超過此值就不再印出文字 !!
CloseFile(Fid)  ; 只能每次要寫出資料時, 再臨時開啟檔案, 寫完資料後就立即關閉檔案 

Repeat
  Event = WaitWindowEvent()
  Select Event
    Case #PB_Event_Gadget
      gadget_no = EventGadget()
      ; Debug Str(gadget_no) + "  " + Str(0)
      Select gadget_no
        Case Option_0
          opt_checked = 1 - opt_checked
          SetGadgetState(Option_0, opt_checked)  ; Toggle checked
        Case Button_0
          file$ = OpenFileRequester("Select a file to dump..","","類神經網路訓練後儲存檔 (.BIN)|*.bin|All files (*.*)|*.*",0)
          If file$
            If ReadFile(0, file$)   ; 測試檔案是否存在 ?
              file_len = Lof(0)
              CloseFile(0)
              curDir$ = GetPathPart(file$)
              name$ = GetFilePart(file$, #PB_FileSystem_NoExtension)  ; "AN100100"    ; 此為單一類神經網路訓練後儲存檔的中間數字部分 !
              file_ext$ = GetExtensionPart(file$)
              toSay$ = "您所點選的檔案是 " + name$ + "." + file_ext$
              Gosub Say
              If GetGadgetState(Option_0) = #PB_Checkbox_Checked    ; ? 是否要大量驗證檔案 ?
                Gosub Get_Dir
                Gosub Prepare_Files_Dialog  ; 準備檔案挑選對話盒
              EndIf
;              Gosub Go_Run     ; Run !
;              toSay$ = Final_ans$
;              Gosub Say
            EndIf
          EndIf
        Case Button_1   ; Exit
          Break
          ;Event = #PB_Event_CloseWindow
        Case Button_2   ; 開始驗證
          Gosub Do_Verify
        Case Button_21 ; Exit
          Break
        Case Button_4   ; 移動向右→
          i = GetGadgetState(ListView_0)
          If i >= 0
            AddGadgetItem(ListView_1, 0, GetGadgetItemText(ListView_0, i))
            RemoveGadgetItem(ListView_0, i)
          EndIf
        Case Button_5   ; ←移動向左
          i = GetGadgetState(ListView_1)
          If i >= 0
            AddGadgetItem(ListView_0, 0, GetGadgetItemText(ListView_1, i))
            RemoveGadgetItem(ListView_1, i)
          EndIf
        Case Button_6   ; 全部移動到右邊
          For i = CountGadgetItems(ListView_0) -1 To 0 Step -1
            AddGadgetItem(ListView_1, 0, GetGadgetItemText(ListView_0, i))
            RemoveGadgetItem(ListView_0, i)
          Next i
        Case Button_7   ; 全部移動到左邊
          For i = CountGadgetItems(ListView_1) -1 To 0 Step -1
            AddGadgetItem(ListView_0, 0, GetGadgetItemText(ListView_1, i))
            RemoveGadgetItem(ListView_1, i)
          Next i
        Case Button_8   ; 完  成
          Gosub Collect_current_files   ; 收集現有已經被選擇好的檔案, 儲存起來
          Gosub Do_Verify
        Case Button_9   ; 放  棄
          HideWindow(Window_1, #True)
        Case Button_10    ; 切換檔案列示盒 [0=六大證型 / 1=其他中醫證型 / 2=檢驗資料]
          Gosub Collect_current_files   ; 收集現有已經被選擇好的檔案, 儲存起來
          mode_select = mode_select + 1
          If mode_select > 2
            mode_select = 0
          EndIf
          SetGadgetText(Text_7, "目前為" + file_type(mode_select))
          Gosub Prepare_Files_Dialog  ; 顯示即將被選擇的檔案
      EndSelect    
  EndSelect    
Until Event = #PB_Event_CloseWindow

Final_ans$ = EndMsg$
Gosub Write_Final_ans

End

; ------ 收集現有已經被選擇好的檔案, 儲存起來 ------
Collect_current_files:
tmp_Count = CountGadgetItems(ListView_0)  ; 先儲存 (左側檔案挑選盒)
Select mode_select
  Case 0  ; 六大證型 神經網路加權值存檔檔案挑選
    For i = 0 To tmp_Count - 1
      six_file_names(i) = GetGadgetItemText(ListView_0, i)    ; 儲存左側檔案挑選盒的檔名內容
    Next i
    count_six_names = tmp_Count
    tmp_Count = CountGadgetItems(ListView_1)  ; 準備儲存 (右側檔案挑選盒)
    If tmp_Count < 1
      six_file_names(127) = "."   ; (右側檔案挑選盒) 是空的 !
    Else
      j = 127
      For i = tmp_Count - 1 To 0 Step -1
        six_file_names(j) = GetGadgetItemText(ListView_1, i)    ; 倒反 (從底部開始) 儲存右側檔案挑選盒的檔名內容
        j = j - 1
      Next i
      six_file_names(j) = "."     ; 擺上代表 (右側檔案挑選盒) 尾端的記號
    EndIf

  Case 1  ; 其他中醫證型 神經網路加權值存檔檔案挑選
    For i = 0 To tmp_Count - 1
      other_names(i) = GetGadgetItemText(ListView_0, i)    ; 儲存左側檔案挑選盒的檔名內容
    Next i
    count_other_names = tmp_Count
    tmp_Count = CountGadgetItems(ListView_1)  ; 準備儲存 (右側檔案挑選盒)
    If tmp_Count < 1
      other_names(127) = "."   ; (右側檔案挑選盒) 是空的 !
    Else
      j = 127
      For i = tmp_Count - 1 To 0 Step -1
        other_names(j) = GetGadgetItemText(ListView_1, i)    ; 倒反 (從底部開始) 儲存右側檔案挑選盒的檔名內容
        j = j - 1
      Next i
      other_names(j) = "."     ; 擺上代表 (右側檔案挑選盒) 尾端的記號
    EndIf

  Case 2  ; 檢驗資料 神經網路加權值存檔檔案挑選
    For i = 0 To tmp_Count - 1
      lab_names(i) = GetGadgetItemText(ListView_0, i)    ; 儲存左側檔案挑選盒的檔名內容
    Next i
    count_lab_names = tmp_Count
    tmp_Count = CountGadgetItems(ListView_1)  ; 準備儲存 (右側檔案挑選盒)
    If tmp_Count < 1
      lab_names(127) = "."   ; (右側檔案挑選盒) 是空的 !
    Else
      j = 127
      For i = tmp_Count - 1 To 0 Step -1
        lab_names(j) = GetGadgetItemText(ListView_1, i)    ; 倒反 (從底部開始) 儲存右側檔案挑選盒的檔名內容
        j = j - 1
      Next i
      lab_names(j) = "."     ; 擺上代表 (右側檔案挑選盒) 尾端的記號
    EndIf
EndSelect
Return

;-------------------------
Do_Verify:
HideWindow(Window_1, #True)
HideWindow(Window_2, #False)
work_done = 0
total_n_files = 0       ; 實際成功驗證的檔案數量
total_n_patterns = 0  ; 實際成功驗證的訓練樣式數量
If GetGadgetState(CheckBox_0) = 1
  If GetGadgetState(Option_0) = 1   ; 1=要大量驗證檔案
    If GetWindowState(Window_1) = #PB_Window_Minimize
      HideWindow(Window_1, #False)
    EndIf
    For ndx_ver = 0 To count_six_names  - 1
      name$ = six_file_names(ndx_ver)
      Gosub Go_Run_Once    ; [六大證型] 驗證 Run !
      ;Debug Str(ndx_ver) + " === " + name$
    Next ndx_ver
  Else    ; Option_0 is 0 = 只要驗證一個檔案 (檔名在 name$)
    name$ = name$ + "." + file_ext$
    Gosub Go_Run_Once    ; [六大證型] 執行驗證單一檔案 !
  EndIf
  work_done = 1
EndIf

If GetGadgetState(CheckBox_1) = 1
  If GetGadgetState(Option_0) = 1   ; 1=要大量驗證檔案
    If GetWindowState(Window_1) = #PB_Window_Minimize
      HideWindow(Window_1, #False)
    EndIf
    For ndx_ver = 0 To count_other_names  - 1
      name$ = other_names(ndx_ver)
      Gosub Go_Run_Once    ; [其他中醫證型] 驗證 Run !
      ;Debug Str(ndx_ver) + " === " + name$
    Next ndx_ver
  Else    ; Option_0 is 0 = 只要驗證一個檔案 (檔名在 name$)
    name$ = name$ + "." + file_ext$
    Gosub Go_Run_Once    ; [其他中醫證型] 執行驗證單一檔案 !
  EndIf
  work_done = 2
EndIf

If GetGadgetState(CheckBox_2) = 1
  If GetGadgetState(Option_0) = 1   ; 1=要大量驗證檔案
    If GetWindowState(Window_1) = #PB_Window_Minimize
      HideWindow(Window_1, #False)
    EndIf
    For ndx_ver = 0 To count_lab_names  - 1
      name$ = lab_names(ndx_ver)
      Gosub Go_Run_Once    ; [檢驗資料] 驗證 Run !
      ;Debug Str(ndx_ver) + " === " + name$
    Next ndx_ver
  Else    ; Option_0 is 0 = 只要驗證一個檔案 (檔名在 name$)
    name$ = name$ + "." + file_ext$
    Gosub Go_Run_Once    ; [檢驗資料] 執行驗證單一檔案 !
  EndIf
  work_done = 3
EndIf

If work_done = 0
  toSay$ = "請先挑選已儲存的神經訓練後儲存檔, 並勾選其類別, 再按下 [開始驗證按鈕] !"
  Gosub Say
EndIf
toSay$ = "---- 驗證完成 ----"
Gosub Say
EndMsg$ = "總共驗證了 " + Str(files_done)+ " 個檔案, 總錯誤次數: " + Str(Final_Error) + ", 總正確次數: " + Str(Final_Good)
toSay$ = EndMsg$
Gosub Say
Return
;-------------------------
Get_Dir:
; Lists all files and folder in the home directory
  If ExamineDirectory(0, curDir$, "*.*")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        Type$ = "[File] "
        Size$ = " (Size: " + DirectoryEntrySize(0) + ")"
        name$ = DirectoryEntryName(0)
        If GetExtensionPart(name$) = "BIN"
          name$ = GetFilePart(name$, #PB_FileSystem_NoExtension)
          first_2char$ = Mid(name$, 1, 2)
          If (first_2char$ = "AN") And (GetGadgetState(CheckBox_0) = 1)
            oncCharVal = Asc(Mid(name$, 3, 1))
            If (47 < oncCharVal) And (oncCharVal < 58)      ; 允許範圍: AN0xxxxx.BIN ~ AN9xxxxx.BIN 
              Debug DirectoryEntryName(0)
              six_file_names(count_six_names) = DirectoryEntryName(0)
              count_six_names = count_six_names + 1
              ; AddGadgetItem(ListView_0, 0, DirectoryEntryName(0))
            EndIf
          EndIf
          If (first_2char$ = "CH") And (GetGadgetState(CheckBox_1) = 1)
            oncCharVal = Asc(Mid(name$, 3, 1))
            If (47 < oncCharVal) And (oncCharVal < 58)      ; 允許範圍: CH0xxxxx.BIN ~ CH9xxxxx.BIN 
              Debug DirectoryEntryName(0)
              other_names(count_other_names) = DirectoryEntryName(0)
              count_other_names = count_other_names + 1
              ; AddGadgetItem(ListView_0, 0, DirectoryEntryName(0))
            EndIf
          EndIf
          If (first_2char$ = "LA") And (GetGadgetState(CheckBox_2) = 1)
            oncCharVal = Asc(Mid(name$, 3, 1))
            If (47 < oncCharVal) And (oncCharVal < 58)      ; 允許範圍: CH0xxxxx.BIN ~ CH9xxxxx.BIN 
              Debug DirectoryEntryName(0)
              lab_names(count_lab_names) = DirectoryEntryName(0)
              count_lab_names = count_lab_names + 1
              ; AddGadgetItem(ListView_0, 0, DirectoryEntryName(0))
            EndIf
          EndIf
        EndIf
;      Else
;        Type$ = "[Directory] "
;        Size$ = "" ; A directory doesn't have a size
      EndIf
;      Debug Type$ + DirectoryEntryName(0) + Size$
    Wend
    FinishDirectory(0)
  EndIf
  HideWindow(Window_1, #False)
Return
;-------------------------
Go_Run_Once:
;If GetGadgetState(Option_0) = #PB_Checkbox_Checked  ; 是否需要自動搜尋 AN**.BIN  
;EndIf
; InPutNetName$ = "ANNnets.BIN"      ; 神經鍵值檔案
; nParm = CountProgramParameters()
toSay$ = "--------- 即將驗證檔案: " + name$ + "---------"
Gosub Say
err$ = ""
Good_Count = 0
mode_select = 0     ; 0 = 六大證型
; Debug "輸入參數個數: " + nParm
;If nParm > 0
;  For i = 0 To nParm - 1
;    ans$ = ProgramParameter(i)
;    group_score(i+1) = Val(ans$)
;    Debug ans$
;  Next i
;EndIf

;For i = 0  To 6
;  If group_score(i) > 30    ; 按照規定, 單一證型積分超過 30 時, 視為該證型 "成立"
;    group_score(i) = 100    ; 證型 "成立" --> 填入 100 分
;  Else
;    group_score(i) = 0        ; 證型 "不成立" --> 填入 0 分
;  EndIf 
;Next i

;For iNum = 0 To 63      ; 2^6 = 64 (把六大證型的所有變化, 全部測試一次)
; -- 測試用, 直接指定分數 --
;  j = iNum
;  For i = 6 To 1 Step -1
;    If j & 1 = 1
;      group_score(i) = 100
;    Else
;      group_score(i) = 0
;    EndIf
;    j = j >> 1 
;  Next i
;Next iNum
Debug "讀取訓練儲存檔名: " + name$
Gosub Load_Net_Data    ; 讀取檔案
If err$ <> ""
  Final_ans$ = "無法開啟檔案: " + name$
  Gosub Print_Text
  Gosub Write_Final_ans
  Return
EndIf
For iNum = 0 To pattern_count-1       ; (把所有訓練資料組, 全部測試一次)
  For i = 0 To 255       ; 執行運算前, 清除三層神經細胞為 0
    cells_input(i) = 0
    cells_middle(i) = 0
    cells_output(i) = 0
  Next i
  pattern_str$ = ""
  val = iNum  ; 把 iNum 轉成二進位表示法 (代表單一訓練儲存檔裡面的所有證型變化, 例如 64 種: 000000 至 111111)
; 混淆矩陣計算用途: TT=True/True, TF=True/False, FT=False/True, FF=False/False (前:實際輸出, 後: 期望輸出)
  For i = input_count To 1 Step -1    ; => (N..1) 從輸入層神經細胞尾端開始填入數值
    If val & 1    ; 從最低位元開始檢測
      group_score(i) = 100    ; 遇到 1, 代表神經細胞活化, 填入最大值 100
      pattern_str$ =  "1" + pattern_str$
    Else
      group_score(i) = 0        ; 遇到 0, 代表神經細胞不活化, 填入最小值 0
      pattern_str$ =  "0" + pattern_str$
    EndIf
    cells_input(i-1) = group_score(i)
    val = val >> 1    ; 右旋一個位元
  Next i
;  For i = 1 To input_count      ; => (1..6) 從輸入層神經細胞開始填入數值
;    score = group_score(i)        ; 前面已指定, 不再乘除 ... * 100 / max_score(i)
;    Debug Str(i) + " = " + Str(score)
;    If score > 100
;      score = 100
;    EndIf
;  If score > 30     ; 如果證型分數超過 30% 即當成該證型成立 !!
;    name$ = name$ + "1"     ; 1 = 證型成立
;    pattern = pattern + pattern + 1
;  Else
;    name$ = name$ + "0"     ; 0 = 證型不成立
;    pattern = pattern + pattern
;  EndIf
;    cells_input(i-1) = score
;  Next i
;-------------------------
  Gosub Run_Once    ; 執行一次運算
Next iNum
files_done = files_done + 1
Final_Good = Final_Good + Good_Count
Final_Error = Final_Error + Total_Error_Count
toSay$ = "完成驗證檔案: " + name$ + " , 有 "  + Str(pattern_count) + " 個訓練組數, 正確次數 = " + Str(Good_Count)  + ", 總錯誤次數 = " + Str(Total_Error_Count)
Gosub Say

; 輸出到評估結果視窗
total_n_files = total_n_files + 1             ; 實際成功驗證的檔案數量
total_n_patterns = total_n_patterns + pattern_count  ; 實際成功驗證的訓練樣式數量
SetGadgetText(Editor_1, "")               ; 清除主要訊息輸出框
SetGadgetText(Editor_0_Copy0, "")         ; 清除左上方格
If total_n_files = 1
  AddGadgetItem(Editor_0_Copy0, 0 , "有 "  + Str(pattern_count) + " 個訓練組數")     ; 左上方格填入 [內含的訓練組數]
  AddGadgetItem(Editor_0_Copy0, 0 , name$)   ; 左上方格填入 [短的類神經網路檔案名稱]
Else
  SetGadgetFont(Editor_0_Copy0, FontID(#Font_Window_2_2))     ; 使用較小字體
  AddGadgetItem(Editor_0_Copy0, 0 , "驗證了 "  + Str(total_n_patterns) + " 個訓練組數")     ; 左上方格填入 [驗證了多少個訓練組數]
  AddGadgetItem(Editor_0_Copy0, 0 , "共驗證了 " + Str(total_n_files) + "個檔案")                ; 左上方格填入 [驗證了多少個類神經網路檔案]
EndIf
SetGadgetText(Editor_0_Copy4, Str(all_TT))  ; 中間列中間格填入 [全部實際_活化 and 全部期望_活化 的訓練組數]
SetGadgetText(Editor_0_Copy5, Str(all_TF))  ; 中間列右邊格填入 [全部實際_活化 and 全部期望_不活化 的訓練組數]
SetGadgetText(Editor_0_Copy7, Str(all_FT))  ; 下方列中間格填入 [全部實際_不活化 and 全部期望_活化 的訓練組數]
SetGadgetText(Editor_0_Copy8, Str(all_FF))  ; 下方列右邊格填入 [全部實際_不活化 and 全部期望_不活化 的訓練組數]

; 輸出到儲存結果檔案
; Final_ans$ = "最終統計: True/True = " + Str(all_TT) + ", True/False = " + Str(all_TF) + ", False/True = " + Str(all_FT) + ", False/False = " + Str(all_FF) 
; Gosub Print_Text
; Gosub Write_Final_ans
Final_ans$ = "準確率 Accuracy rate = " + Str((all_TT + all_FF) / (all_TT + all_TF + all_FT + all_FF))
Gosub Print_Text
Gosub Write_Final_ans
If (all_TT + all_FN) = 0  ; 會發生除到零的錯誤, (無窮大,  直接返回上限最大值 = 1)
  TPR = 1
Else
  TPR = all_TT / (all_TT + all_FN)
EndIf
Final_ans$ = "召回率 (Recall)，真陽性率 True Positive Rate (TPR) = " + Str(TPR)
Gosub Print_Text                                                                   
Gosub Write_Final_ans
If (all_FT + all_TF) = 0  ; 會發生除到零的錯誤, (無窮大,  直接返回上限最大值 = 1)
  TNR = 1
Else
  TNR = all_FF / (all_FT + all_TF)
EndIf
Final_ans$ = "真陰性率 True Negative Rate (TNR) = " + Str(TNR)
If (all_TT + all_TF) = 0  ; 會發生除到零的錯誤, (無窮大,  直接返回上限最大值 = 1)
  PPV = 1
Else
  PPV = all_TT / (all_TT + all_TF)
EndIf
Final_ans$ = "精確率 (Precision)，陽性預測值 Positive Predictive Value (PPV) = " + Str(PPV)
Gosub Print_Text
Gosub Write_Final_ans
Final_ans$ = "陰性預測值 Negative Predictive Value (NPV) = " + Str(all_FF / (all_FF + all_FT))
Gosub Print_Text
Gosub Write_Final_ans
Final_ans$ = "F1 score = " + Str(2 * TPR * PPV / (TPR + PPV))
Gosub Print_Text
Gosub Write_Final_ans
Final_ans$ = "特異度 (Specificity) = " + Str(all_FF / (all_FT + all_FF))
Gosub Print_Text
Gosub Write_Final_ans
Final_ans$ = "幾何平均評估指標 Geometric Mean (GM) = " + Str(Sqr(TPR * TNR))
Gosub Print_Text
Gosub Write_Final_ans
; 約登J統計 (Youden's J statistic)，也稱約登指數 = TPR + TNR–1 = (TP / (TP+FN)) + (TN / (FP+TN)) - 1
J_stat = TPR + TNR - 1
Final_ans$ = "約登 J 統計 (Youden's J statistic)，也稱約登指數 = " + Str(J_stat)
Gosub Print_Text
Gosub Write_Final_ans                                                              
Final_ans$ = ""
Gosub Write_Final_ans
Return

;-------------------------
Load_Net_Data:
; ---- 把六大證型值放到 cells_input() ----
For i = 0 To 255          ; 清除三層神經細胞為 0
  cells_input(i) = 0
  cells_middle(i) = 0
  cells_output(i) = 0
Next i
; ---- load net data ----
; If Mid(name$, 1, 1) = "A"
;  InPutNetName$ = curDir$ +name$      ; 使用完整神經鍵值檔案檔名
;Else
  InPutNetName$ = curDir$ + name$   ; ext = ".BIN"   ; 使用證型分類挑選神經鍵值檔案  
;EndIf
file_id = OpenFile(#PB_Any, InPutNetName$, #PB_File_SharedRead)    ; return none-zero = OK
If file_id    ; 0=Err, Not Zero=OK
  file_len = Lof(file_id)   ; 1024 = 2 x 16 x 32 = 2 x 512 bytes
  If file_len < 1
    err$ = "錯誤: 無法讀取神經鍵值檔案 " + InPutNetName$
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
    *ptr = *ptr + 2
    target_offset = PeekW(*ptr)     ; = targets[] 擺放起點位置
    *ptr = *ptr + 2
    pattern_count = PeekW(*ptr)    ; = 總訓練組數
    *ptr = *ptr + 4              ; 跳到 檔案位置 48 (0x30)
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
    *ptr = *DATABUF + 42           ; offset 0x2A = start offset of targets[]
    If PeekW(*ptr) = 0
      toSay$ = "錯誤: 此檔案 " + InPutNetName$ + " 是舊型格式 ! offset 0x2A = start offset of targets[] 是零 !!"
      Gosub Say
    EndIf
    *ptr = *DATABUF + PeekW(*ptr)   ; 移動讀取位置到 targets[]
    For i = 0 To pattern_count - 1  ; 目前最高 96 patterns (目前六大證型用 2^6 = 64 patterns)
      For j = 0 To output_count - 1 ; 目前六大證型最高 16 output cells
        targets(i, j) = PeekB(*ptr)     ; 讀回希望輸出層的值 (0 or 1)
        *ptr = *ptr + 1
      Next j
    Next i
  EndIf
  CloseFile(file_id) 
  ; 執行大量測試, 免讀取訊息 !
  Debug "實讀檔案長度: 0x" + Hex(*ptr - *DATABUF, #PB_Word) + " (" + Str(*ptr - *DATABUF) + " bytes)"
EndIf
Return

; ---- 執行一次運算 ----
Run_Once:
err$ = ""
pattern = iNum
Error_Count = 0
; 混淆矩陣計算用途: TT=True/True, TF=True/False, FT=False/True, FF=False/False (前:實際輸出, 後: 期望輸出)
TT = 0
TF = 0
FT = 0
FF = 0
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
Select mode_select
  Case 0
    group_name$ = "六大證型檔案: " + name$ + " , 樣式編號: "
  Case 1
    group_name$ = "其他中醫證型: "
  Case 2
    group_name$ = "檢驗資料: "
EndSelect
Final_ans$ =  group_name$ + Str(iNum)
ansA$ = "  輸出值: "
ansB$ = ", 期望結果: "
For i = 0 To output_count - 1
  Debug "樣式: " + pattern_str$ + ", 輸出細胞編號: " + Str(i) + ", 輸出值: " + Str(cells_output(i)) + ", 期望結果: " + Str(targets(pattern, i))
  ansB$ = ansB$ + Str(targets(pattern, i))
  If cells_output(i) > firing_level
    ansA$ = ansA$ + "1"
    If targets(pattern, i) = 0     ; 應是 1 才對
      TF = TF + 1   ; 實際輸出=1  期望輸出=0 (錯誤結果 !)
      Error_Count = Error_Count + 1
      Break
    Else
      TT = TT + 1   ; 實際輸出=1  期望輸出=1  (正確結果)
    EndIf
  Else
    ansA$ = ansA$ + "0"
    If targets(pattern, i) = 1     ; 應是 0 才對
      FT = FT + 1   ; 實際輸出=0  期望輸出=1 (錯誤結果 !)
      Error_Count = Error_Count + 1
      Break
    Else
      FF = FF + 1   ; 實際輸出=0  期望輸出=0 (正確結果 !)
    EndIf
  EndIf
Next i

If Error_Count > 0
  ans$ = " .. 有錯誤 "    ; ", 單訓練項次錯誤次數 = " + Str(Error_Count)
Else
  ans$ = " .. No Error "
  Good_Count = Good_Count + 1
EndIf
Final_ans$ = Final_ans$ + ansA$ + ansB$ + ans$ + ", 正確次數 = " + Str(Good_Count)  + ", 總錯誤次數 = " + Str(Total_Error_Count) + " TT="+ Str(TT)+ ", TF="+ Str(TF) + ", FT="+ Str(FT)+ ", FF="+ Str(FF)
Total_Error_Count = Total_Error_Count + Error_Count
Gosub Write_Final_ans     ; 寫出剛才的驗證結果
all_TT = all_TT + TT
all_TF = all_TF + TF
all_FT = all_FT + FT
all_FF = all_FF + FF
Return

Prepare_Files_Dialog:     ; 準備檔案挑選對話盒
ClearGadgetItems(ListView_0)
ClearGadgetItems(ListView_1)    
Select mode_select
  Case 0  ; 六大證型 神經網路加權值存檔檔案挑選
    If six_file_names(127) = "."  ; 右側檔案挑選盒內無資料, six_file_names 陣列全部顯示到左側檔案挑選盒內無資料
      For i = count_six_names - 1 To 0 Step -1        
        AddGadgetItem(ListView_0, 0, six_file_names(i)) ; 左側檔案挑選盒
      Next i
    Else
      For i = count_six_names - 1 To 0 Step -1        
        AddGadgetItem(ListView_0, 0, six_file_names(i)) ; 左側檔案挑選盒
      Next i
      For i = 127 To 0 Step -1
        If six_file_names(i) = "."    ; 遇到代表尾端的記號
          Break
        EndIf
        AddGadgetItem(ListView_1, 0, six_file_names(i)) ; 右側檔案挑選盒
      Next i
    EndIf
  Case 1  ; 其他中醫證型 神經網路加權值存檔檔案挑選
    If other_names(127) = "."  ; 右側檔案挑選盒內無資料, other_names 陣列全部顯示到左側檔案挑選盒內無資料
      For i = count_other_names - 1 To 0 Step -1        
        AddGadgetItem(ListView_0, 0, other_names(i)) ; 左側檔案挑選盒
      Next i
    Else
      For i = count_other_names - 1 To 0 Step -1        
        AddGadgetItem(ListView_0, 0, other_names(i)) ; 左側檔案挑選盒
      Next i
      For i = 127 To 0 Step -1
        If other_names(i) = "."    ; 遇到代表尾端的記號
          Break
        EndIf
        AddGadgetItem(ListView_1, 0, other_names(i)) ; 右側檔案挑選盒
      Next i
    EndIf
  Case 2  ; 檢驗資料 神經網路加權值存檔檔案挑選
    If lab_names(127) = "."  ; 右側檔案挑選盒內無資料, lab_names 陣列全部顯示到左側檔案挑選盒內無資料
      For i = count_lab_names - 1 To 0 Step -1        
        AddGadgetItem(ListView_0, 0, lab_names(i)) ; 左側檔案挑選盒
      Next i
    Else
      For i = count_lab_names - 1 To 0 Step -1        
        AddGadgetItem(ListView_0, 0, lab_names(i)) ; 左側檔案挑選盒
      Next i
      For i = 127 To 0 Step -1
        If lab_names(i) = "."    ; 遇到代表尾端的記號
          Break
        EndIf
        AddGadgetItem(ListView_1, 0, lab_names(i)) ; 右側檔案挑選盒
      Next i
    EndIf
EndSelect
Return

Print_Text:
AddGadgetItem(Editor_0, CountGadgetItems(Editor_0), Final_ans$)
AddGadgetItem(Editor_1, CountGadgetItems(Editor_1), Final_ans$)
Return

Say:
AddGadgetItem(Editor_0, CountGadgetItems(Editor_0), toSay$)
Return

Write_Final_ans:
Fid = OpenFile(#PB_Any, OutPutFileName$, #PB_File_Append | #PB_File_NoBuffering)
WriteStringN(Fid, Final_ans$, #PB_Ascii)    ; 寫出剛才的驗證結果
CloseFile(Fid)
Return
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 451
; FirstLine = 441
; EnableXP
; DPIAware
; Executable = TestSix.exe