﻿#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%

global g_UserFunctionsAutoFileName := A_ScriptDir "\..\Conf\UserFunctionsAuto.txt"
global g_FileContent

if (!FileExist(g_UserFunctionsAutoFileName))
{
    FileCopy, %g_UserFunctionsAutoFileName%.template, %g_UserFunctionsAutoFileName%
}

FileRead, g_FileContent, %g_UserFunctionsAutoFileName%

allLabels := Object()
index := 1

Loop, %0%
{
    SplitPath, %A_Index%, fileName, fileDir, fileExt, fileNameNoExt

    if (fileNameNoExt == "")
    {
        continue
    }

    labelName := fileNameNoExt

    ; 如果和已有标签重名，添加时间
    if (IsLabel(labelName) || allLabels.HasKey(labelName))
    {
        labelName .= "_" A_Now "_" index
        index++
    }

    AddFile(labelName, fileNameNoExt, fileDir "\" fileName, fileDir)
    allLabels[labelName] := true
}

FileMove, %g_UserFunctionsAutoFileName%, %g_UserFunctionsAutoFileName%.bak, 1
FileAppend, %g_FileContent%, %g_UserFunctionsAutoFileName%, utf-8

; 打开文件来编辑
Run, %g_UserFunctionsAutoFileName%

return

; 添加一个需要运行的文件
AddFile(name, comment, path, dir)
{
    addFunctionsText = @("%name%", "%comment%")
    addLabelsText = %name%:`r`n    `; 用法：  Run, "文件名" "参数..", 工作目录, Max|Min|Hide`r`n
    addLabelsText = %addLabelsText%    Run, "%path%", "%dir%"`r`nreturn`r`n

    g_FileContent := StrReplace(g_FileContent
        , "    `; -*-*-*-*-*-", "    `; -*-*-*-*-*-`r`n    " addFunctionsText)
    g_FileContent := StrReplace(g_FileContent
        , "`r`n`; -*-*-*-*-*-", "`r`n`; -*-*-*-*-*-`r`n" addLabelsText)
}