
; 切换视图为单个窗口
F1::
Postmessage, 1075, 910, 0,, ahk_class TTOTAL_CMD
Return

; 切换视图为两个窗口
F2::
Postmessage, 1075, 909, 0,, ahk_class TTOTAL_CMD
Return


;;;


;切换chrome
F12::
hyf_onekeyWindow("C:\Program Files (x86)\Google\Chrome\Application", "Chrome_WidgetWin_1", "\S") ;注意修改Chrome路径
 
hyf_onekeyWindow(exePath, titleClass := "", titleReg := "")
{ ;有些窗口用Ahk_exe exeName判断不准确，所以自定义个titleClass
    SplitPath, exePath, exeName, , , noExt
    If !hyf_processExist(exeName)
    {
        ;hyf_tooltip("启动中，请稍等...")
        Run,% exePath
        ;打开后自动运行 TODO
        funcName := noExt . "_runDo"
        If IsFunc(funcName)
        {
            ;hyf_tooltip("已自动执行函数：" . funcName)
            Func(funcName).Call()
        }
        Else If titleClass
        {
            WinWait, Ahk_class %titleClass%, , 1
            WinActivate Ahk_class %titleClass%
        }
    }
    Else If WinActive("Ahk_exe " . exeName)
    {
        funcName := noExt . "_hideDo"
        If IsFunc(funcName)
            Func(funcName).Call()
        WinHide
        ;激活鼠标所在窗口 TODO
        MouseGetPos, , , idMouse
        WinActivate Ahk_id %idMouse%
    }
    Else
    {
        If titleReg
            titleClass := "Ahk_id " . hyf_getMainIDOfProcess(exeName, titleClass, titleReg)
        Else If titleClass
            titleClass := "Ahk_class " . titleClass
        Else
            titleClass := "Ahk_exe " . exeName
        WinShow %titleClass%
        WinActivate %titleClass%
        funcName := noExt . "_activeDo"
        If IsFunc(funcName)
        {
            ;hyf_tooltip("已自动执行函数：" . funcName)
            Func(funcName).Call()
        }
    }
}
 
hyf_processExist(n) ;判断进程是否存在（返回PID）
{ ;n为进程名
    Process, Exist, %n% ;比IfWinExist可靠
    Return ErrorLevel
}
 
hyf_tooltip(str, t := 1, ExitScript := 0, x := "", y := "")  ;提示t秒并自动消失
{
    t *= 1000
    ToolTip, %str%, %x%, %y%
    SetTimer, hyf_removeToolTip, -%t%
    If ExitScript
    {
        Gui, Destroy
        Exit
    }
}
 
hyf_getMainIDOfProcess(exeName, cls, titleReg := "") ;获取类似chrome等多进程的主程序ID
{
    DetectHiddenWindows, On
    WinGet, arr, List, Ahk_exe %exeName%
    Loop,% arr
    {
        n := arr%A_Index%
        WinGetClass, classLoop, Ahk_id %n%
        ;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . cls
        If (classLoop = cls)
        {
            If !StrLen(titleReg) ;不需要判断标题
                Return n
            WinGetTitle, titleLoop, Ahk_id %n%
            ;MsgBox,% A_Index . "/" . arr . "`n" . classLoop . "`n" . titleLoop
            If (titleLoop ~= titleReg)
                Return n
        }
        Continue
    }
    Return False
}
 
hyf_removeToolTip() ;清除ToolTip
{
    ToolTip
}