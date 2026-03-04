
curDir$ = GetCurrentDirectory()
DeleteFile(curDir$ + "Lab_Ans.txt")

RunProgram("open" , " -n " + curDir$ + "AnnLab.app --args show anemia na_l", curDir$)
Delay(500)
to_open$ = "Lab_Ans.txt"
ans$ = ""
ret = OpenFile(0, curDir$ + to_open$)
If ret > 0
  If ReadFile(0, curDir$ + to_open$, #PB_File_SharedRead)
    While Eof(0) = 0
      ans$ = ans$ + ReadString(0, #PB_UTF8) + ", "    ; 不要傳回太多東西 !!
    Wend
  EndIf
  CloseFile(0)  
EndIf
Debug ans$


; IDE Options = PureBasic 6.21 - C Backend (MacOS X - x64)
; CursorPosition = 6
; EnableXP
; DPIAware
; Executable = test_run.app
; Compiler = PureBasic 6.21 - C Backend (MacOS X - x64)