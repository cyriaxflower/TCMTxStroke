XIncludeFile "form1.pb"
Global  curDir$, Window_1, Window_2, item_count = 101, OutPutFileName$
Dim str_item.s(item_count)
Dim group_type.b(item_count)
Dim scores.b(item_count)
Dim group_score.i(7)    ; 六大證型目前得到幾分
Dim group_id.s(7)       ; 六大證型名稱

OpenWindow_0()
curDir$ = GetCurrentDirectory()
OutPutFileName$ = "SixGroup.BIN"
title$ = "中醫診斷缺血性中風證型分類判斷程式"
scr_width = 1680
scr_height = 776
line_height = 35
txt_bkg_color = RGB(30,  0, 0)
txt_forg_color = RGB(240, 240, 240)
img_no = 0
txt_no = 122
x = 8
y = 4

DataSection
; --------- 證狀 (0..59)
Data.s  "我選好了，請按我前方按鈕離開", "48 小時達到高峰 (風證2分)", "24小時達到高峰 (風證4分)",  "病情數變 (風證8分)"
Data.s  "發病即達高峰 (風證8分)", "兩手握固或口嘴不開 (風證3分)",  "肢體抽動 (風證5分)", "肢體拘急或頸項強急（風證7分)"
Data.s  "舌體頗抖 (風證5分)",  "舌體歪斜且頗抖 (風證7分)", "目珠遊動或目偏不瞬 (風證3分)", "脈弦 (風證3分)"
Data.s  "頭暈或頭痛如單 (風證1分)", "頭暈目眩 (風證2分)", "舌質紅 (火熱證5分)",  "舌紅絳 (火熱證6分)"
Data.s  "舌苔薄黃 (火熱證2分)", "舌苔黃厚 (火熱證3分)", "舌苔乾燥 (火熱證4分)", "舌苔灰黑乾燥 (火熱證6分)"
Data.s  "大便乾大便難 (火熱證2分)", "大便乾3日未解 (火熱證3分)", "大便乾5日以上未解 (火熱證4分)", "神情: 心煩易怒 (火熱證2分)"
Data.s  "神情: 躁擾不寧 (火熱證3分)", "神情: 神昏譫語 (火熱證4分)", "聲高氣粗或口唇乾紅 (火熱證2分)", "面紅目赤或氣促口臭 (火熱證3分)"
Data.s  "發熱 (火熱證3分)", "脈數大有力或弦數或滑數 (火熱證2分)", "口苦咽乾 (火熱證1分)", "渴喜冷飲 (火熱證2分)"
Data.s  "尿短赤 (火熱證1分)", "口多粘涎 (痰證2分)", "咯痰或嘔吐痰涎 (痰證4分)", "痰多而粘 (痰證6分)"
Data.s  "鼻鼾痰鳴 (痰證8分)", "舌苔膩或水滑 (痰證6分)", "舌苔厚膩 (痰證8分)", "舌體胖大 (痰證4分)"
Data.s  "舌體胖大多齒痕 (痰證6分)", "表情淡漠或寡言少語 (痰證2分)", "神情呆滯或反應遲鈍或嗜睡 (痰證8分)", "脈滑或濡 (痰證3分)"
Data.s  "頭昏沉 (痰證1分)", "體胖臃腫 (痰證1分)", "舌背脈絡盛張青紫 (血瘀證4分)", "舌質紫暗 (血瘀證5分)"
Data.s  "舌質有瘀點 (血瘀證6分)", "舌質有瘀斑 (血瘀證8分)", "舌質青紫 (血瘀證9分)", "頭痛而痛處不移 (血瘀證5分)"
Data.s  "頭痛如針刺或如炸裂 (血瘀證7分)", "肢痛不移 (血瘀證5分)", "爪甲青紫 (血瘀證6分)", "瞼下青黑 (血瘀證2分)"
Data.s  "口唇紫暗 (血瘀證3分)", "口唇紫暗且面色晦暗 (血瘀證5分)", "脈沉弦細 (血瘀證1分)", "脈沉弦遲 (血瘀證2分)"
; --------- 證狀 (60..63)
Data.s  "脈澀或結代 (血瘀證3分)", "高黏滯血症 (血瘀證5分)", "舌淡 (氣虛證3分)", "舌胖大 (氣虛證4分)"
Data.s  "胖大邊多齒痕或舌痿 (氣虛證5分)", "神疲乏力或少氣懶言 (氣虛證1分)", "語聲低怯或咳聲無力 (氣虛證2分)", "倦息嗜臥 (氣虛證3分)"
Data.s  "鼻鼾細微 (氣虛證4分)", "稍動則汗出 (氣虛證2分)", "安靜時汗出 (氣虛證3分)", "冷汗不止 (氣虛證4分)"
Data.s  "大便溏或初硬後溏 (氣虛證1分)", "小便自遺 (氣虛證2分)", "二便自遺 (氣虛證4分)", "手足腫脹 (氣虛證2分)"
Data.s  "肢體癱軟 (氣虛證3分)", "手撇肢冷 (氣虛證4分)", "活動較多時心悸 (氣虛證1分)", "輕微活動即心悸 (氣虛證2分)"
Data.s  "安靜時常心悸 (氣虛證3分)", "面白 (氣虛證1分)", "面白且面色虛浮 (氣虛證3分)", "脈沉細或遲緩或脈虛 (氣虛證1分)"
Data.s  "脈結代 (氣虛證2分)", "脈微 (氣虛證3分)", "舌體瘦 (陰虛陽亢證3分)", "舌瘦而紅 (陰虛陽亢證4分)"
Data.s  "舌瘦而紅乾 (陰虛陽亢證7分)", "舌瘦而紅乾多裂 (陰虛陽亢證9分)", "舌苔少或剝脫苔 (陰虛陽亢證5分)", "舌光紅無苔 (陰虛陽亢證7分)"
Data.s  "心煩易怒 (陰虛陽亢證1分)", "心煩不得眠 (陰虛陽亢證2分)", "躁擾不寧 (陰虛陽亢證3分)", "頭暈目眩 (陰虛陽亢證2分)"
Data.s  "盜汗 (陰虛陽亢證2分)", "耳鳴 (陰虛陽亢證2分)", "午後顴紅或面部烘熱或手足心熱 (陰虛陽亢證2分)", "咽乾口燥或兩目乾澀或便乾尿少 (陰虛陽亢證2分)"
Data.s  "弦細或細數 (陰虛陽亢證1分)"
; --------- 證型
Data.b  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
Data.b  4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
; --------- 得分
Data.b  0, 2, 4, 8, 8, 3, 5, 7, 5, 7, 3, 3, 1, 2, 5, 6, 2, 3, 4, 6, 2, 3, 4, 2, 3, 4, 2, 3, 3, 2, 1, 2, 1, 2, 4, 6, 8, 6, 8, 4, 6, 2, 8, 3, 1, 1, 4, 5, 6, 8, 9, 5, 7, 5, 6, 2, 3, 5, 1, 2
Data.b  3, 5, 3, 4, 5, 1, 2, 3, 4, 2, 3, 4, 1, 2, 4, 2, 3, 4, 1, 2, 3, 1, 3, 1, 2, 3, 3, 4, 7, 9, 5, 7, 1, 2, 3, 2, 2, 2, 2, 2, 1
; --------- 六大證型名稱 --> group_id()
Data.s  "此為空白", "風證", "火熱證", "痰證", "血瘀證", "氣虛證", "陰虛陽亢證"
EndDataSection

SetGadgetFont(#PB_Default, #PB_Default)  ; Set the font settings back to original standard font
If LoadFont(0, "標楷體", 24)
  SetGadgetFont(#PB_Default, FontID(0))   ; Set the loaded 標楷體 28 font as new standard
EndIf

For i = 0  To item_count - 1
  Read.s  str_item(i)
Next i

For i = 0  To item_count - 1
  Read.b group_type(i)
Next i

For i = 0  To item_count - 1
  Read.b scores(i)
Next i

For i = 0  To 6
  Read.s group_id(i)    ; 六大證型名稱
Next i

Window_1 = OpenWindow(#PB_Any, 0, 0, scr_width, scr_height, title$ + " 第一頁", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
If Window_1 <> 0
  If CreateImage(10, scr_width, scr_height) And StartDrawing(ImageOutput(10))
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, scr_width, scr_height, RGB(0, 20, 30));
    StopDrawing()
    ;ImageGadget(90, 0, 0, scr_width, scr_height, ImageID(10))
  EndIf
  ; ResizeWindow(1, 600, 300, scr_width, scr_height)
EndIf

Debug curDir$
abs_path$ = "/Users/happysu/Documents/PureBasic/"
If curDir$ <> abs_path$
  curDir$ = abs_path$
EndIf

notchk = LoadImage(0,  curDir$ + "NotChecked.bmp")    ; #PB_Compiler_Home. K:/PureBasic/Examples/
chk = LoadImage(1,  curDir$ + "Checked.bmp")   ; #PB_Compiler_Home + "examples/
If notchk And chk
ContainerGadget(120, 10, 8, scr_width - 20, scr_height - 20, #PB_Container_Double)
  ; CheckBoxGadget(3, 10,  250, 630, 50, "CheckBox standard")
  ; ImageGadget(90, 0, 0, scr_width, scr_height, ImageID(10))
  For i = 0 To 59
    ButtonImageGadget(img_no, x, y, 40, 40,  ImageID(0), #PB_Button_Toggle)
    TextGadget(txt_no, x + 40, y + 1, 500, line_height, str_item(i), #PB_Text_Center)
    SetGadgetColor(txt_no,  #PB_Gadget_FrontColor, txt_forg_color)
    SetGadgetColor(txt_no,  #PB_Gadget_BackColor, txt_bkg_color)
    y = y + line_height + 2
    img_no = img_no + 1
    txt_no = txt_no + 1
    If y > 740
      y = 4
      x = x + 550
    EndIf
  Next i
CloseGadgetList()
EndIf

Window_2 = OpenWindow(#PB_Any, 4, 4, scr_width, scr_height, title$ + " 第二頁", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
If Window_2 <> 0
  If CreateImage(20, scr_width, scr_height) And StartDrawing(ImageOutput(20))
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, scr_width, scr_height, RGB(0, 20, 30));
    StopDrawing()
    ;ImageGadget(90, 0, 0, scr_width, scr_height, ImageID(10))
  EndIf
  ; ResizeWindow(1, 600, 300, scr_width, scr_height)
EndIf
If notchk And chk
ContainerGadget(121, 10, 8, scr_width - 20, scr_height - 20, #PB_Container_Double)
  ; CheckBoxGadget(3, 10,  250, 630, 50, "CheckBox standard")
  ; ImageGadget(90, 0, 0, scr_width, scr_height, ImageID(10))
  x = 8
  y = 4
  For i = 60 To item_count - 1
      ButtonImageGadget(img_no, x, y, 40, 40,  ImageID(0), #PB_Button_Toggle)
    If i = 98 Or i = 99
      TextGadget(txt_no, x + 40, y + 1, 780, line_height, str_item(i), #PB_Text_Center)
    Else
      TextGadget(txt_no, x + 40, y + 1, 500, line_height, str_item(i), #PB_Text_Center)
    EndIf
    SetGadgetColor(txt_no,  #PB_Gadget_FrontColor, txt_forg_color)
    SetGadgetColor(txt_no,  #PB_Gadget_BackColor, txt_bkg_color)
    y = y + line_height + 2
    img_no = img_no + 1
    txt_no = txt_no + 1
    If y > 740
      y = 4
      x = x + 550
    EndIf
  Next i
CloseGadgetList()
EndIf

Repeat
  Event = WaitWindowEvent()


  Select Event
;    Case #PB_Event_CloseWindow
;     ProcedureReturn #False

;    Case #PB_Event_Menu
 ;     Select EventMenu()
 ;     EndSelect

       

    Case #PB_Event_Gadget
      gadget_no = EventGadget()
      State = GetGadgetState(gadget_no)
      If State = 1
        SetGadgetAttribute(gadget_no, #PB_Button_PressedImage, chk)
      Else
        SetGadgetAttribute(gadget_no, #PB_Button_PressedImage, notchk)
      EndIf
      Gosub Count_scores      ; 統計所有六大證型目前得到幾分 ?
      
      Select gadget_no
        Case Button_0
          Show_First_Page(EventType())
        Case Button_1
          Show_Second_Page(EventType())
        Case Button_2
          Gosub Save_scores
          ; RunProgram()
          OK_Goto_Next(EventType())
        Case Button_3
          Maybe_Exit(EventType())
      EndSelect
    EndSelect
Until Event = #PB_Event_CloseWindow
End

; 統計六大證型目前得到幾分
Count_scores:
For i = 0 To 6
  group_score(i) = 0
Next i

For i = 1 To item_count - 1
  If  GetGadgetState(i) = 1
    group_num = group_type(i)
    group_score(group_num) = group_score(group_num) + scores(i)
  EndIf
Next i
; 把結果更新到畫面上
ans$ = ""
For i = 1 To 6
  If group_score(i) > 0
    ans$ = ans$ + group_id(i) + " " + Str(group_score(i)) + " 分, "
  EndIf
  Next i
  form_title$ = "六大證型得分: " + ans$
  SetWindowTitle(Window_0, form_title$)
Return

Save_scores:
*DATABUF = AllocateMemory(128)    ; item_count = 101 --> 其實只需 10 + 101 = 111 bytes (準備 128 bytes 已足夠)
;  先全部清除
FillMemory(*DATABUF, 128, 0)
; 在位置 0 的地方開始, 依序填入六大證型得分
*BytePtr = *DATABUF
For i = 1 To 6
  PokeB(*BytePtr, group_score(i))
  *BytePtr = *BytePtr + 1
Next i
; 在位置 10 的地方開始, 依序填入 [對應的選項得分]
*BytePtr = *DATABUF + 10
For i = 1 To item_count - 1
  If GetGadgetState(i) = 1      ; 有被選到才會填入非零值的分數
    group_num = group_type(i)
    PokeB(*BytePtr, scores(i))
  EndIf
  *BytePtr = *BytePtr + 1
Next i

DeleteFile(OutPutFileName$)     ; 先刪除舊資料 !
OpenFile(1, OutPutFileName$, #PB_File_SharedWrite)
WriteData(1, *DATABUF, 128)   ; 寫出全部 128 bytes
CloseFile(1)
Return

Procedure Show_First_Page(EventType)
  Debug "Show_First_Page event"
  SetActiveWindow(Window_1)       ; show first window
EndProcedure

Procedure Show_Second_Page(EventType)
  Debug "Show_Second_Page event"
  SetActiveWindow(Window_2)       ; show second window
EndProcedure

Procedure OK_Goto_Next(EventType)
  Debug "OK_Goto_Next event"
  ; run_id = RunProgram(curDir$ + "RunAnn")  ;, OutPutFileName$, curDir$
  RunProgram("open" , " -n " + curDir$ + "RunAnn.app", curDir$) ; ,  #PB_Program_Wait
  End 0
EndProcedure

Procedure Maybe_Exit(EventType)
  Debug "Maybe_Exit event"
  End 0
EndProcedure
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 259
; FirstLine = 233
; Folding = -
; EnableXP
; DPIAware
; Executable = TxStroke.app.exe