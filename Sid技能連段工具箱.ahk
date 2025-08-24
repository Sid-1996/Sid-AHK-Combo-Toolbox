#SingleInstance Force

; 全域變數
遊戲視窗 := ""
連招組 := []
連招GUI := ""
當前熱鍵 := Map()

; 初始化5組連招
Loop 5 {
    連招組.Push({
        觸發按鍵: "",
        技能: ["", "", "", ""],
        延遲: [100, 100, 100, 100]
    })
}

; 初始化
讀取設定()
; 啟動時自動開啟設定GUI
顯示設定GUI()

F11::Reload
F12::{
    ToolTip("👋 工具即將結束...")
    SetTimer(() => ToolTip(), -1000)
    Sleep(1000)
    ExitApp
}
F1::切換設定GUI()
F2::顯示連招狀態()

; 切換設定GUI
切換設定GUI() {
    global 連招GUI
    if IsObject(連招GUI) {
        try {
            連招GUI.Destroy()
            連招GUI := ""
        }
    } else {
        顯示設定GUI()
    }
}

; 設定GUI
顯示設定GUI() {
    global 連招GUI, 遊戲視窗, 連招組
    if IsObject(連招GUI)
        連招GUI.Destroy()
    
    連招GUI := Gui("+Resize", "Sid 連技工具箱 v2 - 多組連招設定")
    連招GUI.BackColor := "White"
    
    ; 分頁控制
    tab := 連招GUI.AddTab3("x10 y10 w700 h570", ["連招設定", "連招預覽", "熱鍵列表"])
    
    ; === 第1個分頁：連招設定 ===
    tab.UseTab(1)
    
    ; 視窗設定
    連招GUI.SetFont("s11 Bold c0x0000FF")
    連招GUI.AddText("x20 y45", "遊戲視窗名稱:")
    連招GUI.SetFont("s10 c0x000000")
    連招GUI.AddEdit("x20 y70 w400 v遊戲視窗", 遊戲視窗)
    
    ; 按鍵選項
    按鍵選項 := ["","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","Space","Tab","LShift","LCtrl","LAlt","RButton","MButton"]
    
    ; 表頭
    連招GUI.SetFont("s10 Bold c0x0000FF")
    連招GUI.AddText("x20 y110 w50 Center", "組別")
    連招GUI.AddText("x80 y110 w80 Center", "觸發按鍵")
    連招GUI.AddText("x170 y110 w60 Center", "連招1")
    連招GUI.AddText("x240 y110 w50 Center", "延遲ms")
    連招GUI.AddText("x300 y110 w60 Center", "連招2")
    連招GUI.AddText("x370 y110 w50 Center", "延遲ms")
    連招GUI.AddText("x430 y110 w60 Center", "連招3")
    連招GUI.AddText("x500 y110 w50 Center", "延遲ms")
    連招GUI.AddText("x560 y110 w60 Center", "連招4")
    連招GUI.AddText("x630 y110 w50 Center", "延遲ms")
    
    連招GUI.SetFont("s10 c0x000000")
    
    ; 5組連招設定
    Loop 5 {
        i := A_Index
        y_pos := 135 + (i-1)*35
        
        ; 組別標籤
        連招GUI.SetFont("s10 Bold c0xFF0000")
        連招GUI.AddText("x25 y" (y_pos+5) " w40 Center", "第" i "組")
        連招GUI.SetFont("s10 c0x000000")
        
        ; 觸發按鍵
        連招GUI.AddComboBox("x80 y" y_pos " w80 v觸發" i, 按鍵選項).Text := 連招組[i].觸發按鍵
        
        ; 4個連招技能和延遲
        Loop 4 {
            j := A_Index
            x_skill := 170 + (j-1)*130
            x_delay := x_skill + 70
            
            連招GUI.AddComboBox("x" x_skill " y" y_pos " w60 v技能" i "_" j, 按鍵選項).Text := 連招組[i].技能[j]
            連招GUI.AddEdit("x" x_delay " y" y_pos " w50 Number v延遲" i "_" j, 連招組[i].延遲[j])
        }
    }
    
    ; 控制按鈕
    y_btn := 135 + 5*35 + 20
    連招GUI.SetFont("s10 Bold")
    連招GUI.AddButton("x80 y" y_btn " w80 h30", "保存設定").OnEvent("Click", 保存設定)
    連招GUI.AddButton("x170 y" y_btn " w80 h30", "測試連招").OnEvent("Click", 測試所有連招)
    連招GUI.AddButton("x260 y" y_btn " w80 h30", "重置設定").OnEvent("Click", 重置設定)
    連招GUI.AddButton("x350 y" y_btn " w80 h30", "匯出設定").OnEvent("Click", 匯出設定)
    連招GUI.AddButton("x440 y" y_btn " w80 h30", "匯入設定").OnEvent("Click", 匯入設定)
    
    ; 說明區域
    y_info := y_btn + 50
    連招GUI.SetFont("s9 c0x666666")
    連招GUI.AddText("x20 y" y_info " w660", "使用說明:")
    連招GUI.AddText("x20 y" (y_info+15) " w660", "• 每組可設定1個觸發按鍵 + 最多4個連招動作")
    連招GUI.AddText("x20 y" (y_info+30) " w660", "• 延遲時間單位為毫秒(1000ms = 1秒)，建議設定100-500ms")
    連招GUI.AddText("x20 y" (y_info+45) " w660", "• 連招只在指定的遊戲視窗中生效，避免誤觸")
    連招GUI.AddText("x20 y" (y_info+60) " w660", "• 可同時啟用多組不同按鍵的連招配置")
    
    ; === 第2個分頁：連招預覽 ===
    tab.UseTab(2)
    連招GUI.SetFont("s11 Bold c0x0000FF")
    連招GUI.AddText("x20 y45", "🎮 連招執行預覽")
    連招GUI.SetFont("s10 c0x000000")
    
    ; 預覽文字內容
    預覽文字 := 建立連招預覽文字()
    連招GUI.AddEdit("x20 y70 w660 h470 ReadOnly VScroll", 預覽文字)
    
    ; 重新整理按鈕
    連招GUI.SetFont("s10 Bold")
    連招GUI.AddButton("x300 y550 w100 h25", "重新整理預覽").OnEvent("Click", 更新連招預覽)
    
    ; === 第3個分頁：熱鍵列表 ===
    tab.UseTab(3)
    連招GUI.SetFont("s13 Bold c0x0000FF")
    連招GUI.AddText("x20 y45 w660 Center", "🎮 Sid 連技工具箱 - 熱鍵列表")
    
    連招GUI.SetFont("s11 c0x000000")
    y_start := 80
    
    連招GUI.AddText("x50 y" y_start " w600", "═══════════════════════════════════════════════════")
    連招GUI.AddText("x50 y" (y_start+25) " w600", "📋 程式控制熱鍵:")
    連招GUI.SetFont("s10 Bold c0x0000FF")
    連招GUI.AddText("x70 y" (y_start+50) " w100", "[F1]")
    連招GUI.SetFont("s10 c0x000000")
    連招GUI.AddText("x170 y" (y_start+50) " w400", "開啟/關閉設定介面")
    
    連招GUI.SetFont("s10 Bold c0x0000FF")
    連招GUI.AddText("x70 y" (y_start+75) " w100", "[F2]")
    連招GUI.SetFont("s10 c0x000000")
    連招GUI.AddText("x170 y" (y_start+75) " w400", "查看連招狀態總覽")
    
    連招GUI.SetFont("s10 Bold c0x0000FF")
    連招GUI.AddText("x70 y" (y_start+100) " w100", "[F11]")
    連招GUI.SetFont("s10 c0x000000")
    連招GUI.AddText("x170 y" (y_start+100) " w400", "重新載入程式")
    
    連招GUI.SetFont("s10 Bold c0x0000FF")
    連招GUI.AddText("x70 y" (y_start+125) " w100", "[F12]")
    連招GUI.SetFont("s10 c0x000000")
    連招GUI.AddText("x170 y" (y_start+125) " w400", "結束程式")
    
    連招GUI.SetFont("s11 c0x000000")
    連招GUI.AddText("x50 y" (y_start+170) " w600", "═══════════════════════════════════════════════════")
    連招GUI.AddText("x50 y" (y_start+195) " w600", "🎯 連招觸發熱鍵:")
    
    ; 顯示當前啟用的連招熱鍵
    y_combo := y_start + 220
    啟用數量 := 0
    Loop 5 {
        i := A_Index
        if 連招組[i].觸發按鍵 != "" {
            啟用數量++
            連招GUI.SetFont("s9 Bold c0xFF0000")
            連招GUI.AddText("x70 y" y_combo " w100", "[" 連招組[i].觸發按鍵 "]")
            連招GUI.SetFont("s9 c0x000000")
            
            描述文字 := "第" i "組連招 ("
            技能數 := 0
            Loop 4 {
                j := A_Index
                if 連招組[i].技能[j] != "" {
                    技能數++
                    if j = 1
                        描述文字 .= 連招組[i].技能[j]
                    else
                        描述文字 .= "→" 連招組[i].技能[j]
                }
            }
            描述文字 .= ")"
            
            連招GUI.AddText("x170 y" y_combo " w400", 描述文字)
            y_combo += 25
        }
    }
    
    if 啟用數量 = 0 {
        連招GUI.SetFont("s9 c0x666666")
        連招GUI.AddText("x70 y" y_combo " w500", "❌ 目前沒有設定任何連招熱鍵")
        連招GUI.AddText("x70 y" (y_combo+20) " w500", "💡 請到「連招設定」分頁進行配置")
    } else {
        連招GUI.SetFont("s9 Bold c0x008000")
        連招GUI.AddText("x50 y" (y_combo+20) " w600", "✅ 總共啟用了 " 啟用數量 " 組連招熱鍵")
    }
    
    連招GUI.SetFont("s10 c0x000000")
    連招GUI.AddText("x50 y" (y_combo+60) " w600", "═══════════════════════════════════════════════════")
    連招GUI.SetFont("s8 c0x666666")
    連招GUI.AddText("x50 y" (y_combo+85) " w600", "⚠️ 注意：連招熱鍵僅在指定的遊戲視窗啟用時才會觸發")
    連招GUI.AddText("x50 y" (y_combo+105) " w600", "📌 請確保在正確的遊戲視窗中使用連招功能")
    
    ; 回到預設分頁，確保分頁可見
    tab.UseTab(1)
    
    連招GUI.Show("w720 h600")
    連招GUI.OnEvent("Close", (*) => (連招GUI.Destroy(), 連招GUI := ""))
}

; 保存設定
保存設定(*) {
    global 遊戲視窗, 連招組
    設定值 := 連招GUI.Submit()
    
    if 設定值.遊戲視窗 = "" {
        ToolTip("❌ 請輸入遊戲視窗名稱!")
        SetTimer(() => ToolTip(), -2000)
        顯示設定GUI()
        return
    }
    
    遊戲視窗 := 設定值.遊戲視窗
    
    ; 保存5組連招設定
    Loop 5 {
        i := A_Index
        連招組[i].觸發按鍵 := 設定值.HasProp("觸發" i) ? 設定值.%"觸發" i% : ""
        Loop 4 {
            j := A_Index
            連招組[i].技能[j] := 設定值.HasProp("技能" i "_" j) ? 設定值.%"技能" i "_" j% : ""
            延遲值 := 設定值.HasProp("延遲" i "_" j) ? 設定值.%"延遲" i "_" j% : "100"
            連招組[i].延遲[j] := IsNumber(延遲值) ? Integer(延遲值) : 100
        }
    }
    
    寫入設定()
    設置所有熱鍵()
    ToolTip("✅ 設定已保存成功!")
    SetTimer(() => ToolTip(), -2000)
}

; 建立連招預覽文字
建立連招預覽文字() {
    global 連招組, 遊戲視窗
    
    預覽文字 := "=== 🎮 Sid 連招預覽總覽 ===" "`r`n`r`n"
    預覽文字 .= "🎯 目標視窗: " (遊戲視窗 != "" ? 遊戲視窗 : "❌ 未設定") "`r`n"
    預覽文字 .= "📌 連招僅在目標視窗啟用時才會觸發" "`r`n`r`n"
    預覽文字 .= "═══════════════════════════════════" "`r`n`r`n"
    
    啟用數量 := 0
    Loop 5 {
        i := A_Index
        if 連招組[i].觸發按鍵 != "" {
            啟用數量++
            預覽文字 .= "🔥 【第" i "組連招】`r`n"
            預覽文字 .= "👆 按下 [" 連招組[i].觸發按鍵 "] 時的執行流程:`r`n"
            
            有效技能數 := 0
            Loop 4 {
                j := A_Index
                if 連招組[i].技能[j] != "" {
                    有效技能數++
                    if j = 1
                        預覽文字 .= "   ⏱️  等待 " 連招組[i].延遲[j] "ms → 🎯 按下 [" 連招組[i].技能[j] "]`r`n"
                    else
                        預覽文字 .= "   ⏱️  再等 " 連招組[i].延遲[j] "ms → 🎯 按下 [" 連招組[i].技能[j] "]`r`n"
                }
            }
            
            總時間 := 0
            Loop 4 {
                j := A_Index
                if 連招組[i].技能[j] != ""
                    總時間 += 連招組[i].延遲[j]
            }
            
            預覽文字 .= "   ✨ 整套連招共 " 有效技能數 " 個動作，總耗時約 " 總時間 "ms`r`n"
            預覽文字 .= "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "`r`n`r`n"
        }
    }
    
    if 啟用數量 = 0 {
        預覽文字 .= "❌ 目前沒有設定任何連招" "`r`n`r`n"
        預覽文字 .= "💡 請先在設定介面中配置連招後再查看預覽"
    } else {
        預覽文字 .= "✅ 總共啟用了 " 啟用數量 " 組連招配置" "`r`n`r`n"
        預覽文字 .= "💡 提醒: 確保在正確的遊戲視窗中測試連招效果"
    }
    
    return 預覽文字
}

; 更新連招預覽
更新連招預覽(*) {
    ToolTip("🔄 預覽已更新!")
    SetTimer(() => ToolTip(), -1500)
    ; 重新打開GUI來更新預覽內容
    顯示設定GUI()
}

; 顯示連招預覽
顯示連招預覽(*) {
    ToolTip("📋 連招預覽請查看第2個分頁")
    SetTimer(() => ToolTip(), -2000)
}

; 測試所有連招
測試所有連招(*) {
    啟用數量 := 0
    Loop 5 {
        if 連招組[A_Index].觸發按鍵 != ""
            啟用數量++
    }
    
    if 啟用數量 = 0 {
        ToolTip("❌ 沒有設定任何連招!")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    
    ToolTip("🔄 將在3秒後測試所有連招 (共" 啟用數量 "組)")
    SetTimer(() => ToolTip(), -3000)
    Sleep(3000)
    
    Loop 5 {
        i := A_Index
        if 連招組[i].觸發按鍵 != "" {
            ToolTip("🎯 測試第" i "組連招: " 連招組[i].觸發按鍵)
            SetTimer(() => ToolTip(), -1000)
            執行連招(i)
            Sleep(1000)
        }
    }
    
    ToolTip("✅ 所有連招測試完成!")
    SetTimer(() => ToolTip(), -2000)
}

; 重置設定
重置設定(*) {
    ToolTip("⚠️ 按下 Ctrl+Y 確認重置，或等待3秒取消")
    SetTimer(() => ToolTip(), -3000)
    
    ; 等待確認
    startTime := A_TickCount
    while (A_TickCount - startTime < 3000) {
        if GetKeyState("Ctrl", "P") && GetKeyState("Y", "P") {
            global 連招組, 遊戲視窗
            遊戲視窗 := ""
            Loop 5 {
                i := A_Index
                連招組[i].觸發按鍵 := ""
                連招組[i].技能 := ["", "", "", ""]
                連招組[i].延遲 := [100, 100, 100, 100]
            }
            寫入設定()
            清除所有熱鍵()
            ToolTip("✅ 已重置所有設定!")
            SetTimer(() => ToolTip(), -2000)
            顯示設定GUI()
            return
        }
        Sleep(50)
    }
    ToolTip("❌ 重置操作已取消")
    SetTimer(() => ToolTip(), -1500)
}

; 匯出設定
匯出設定(*) {
    檔名 := FileSelect("S", "連招設定備份.ini", "匯出設定檔", "INI檔案 (*.ini)")
    if 檔名 != "" {
        try {
            FileCopy("連技設定.ini", 檔名, true)
            ToolTip("✅ 設定已匯出至: " 檔名)
            SetTimer(() => ToolTip(), -3000)
        } catch {
            ToolTip("❌ 匯出失敗，請檢查檔案路徑!")
            SetTimer(() => ToolTip(), -2000)
        }
    }
}

; 匯入設定
匯入設定(*) {
    檔名 := FileSelect(1, , "選擇設定檔", "INI檔案 (*.ini)")
    if 檔名 != "" {
        try {
            FileCopy(檔名, "連技設定.ini", true)
            讀取設定()
            ToolTip("✅ 設定已匯入並載入!")
            SetTimer(() => ToolTip(), -2000)
            顯示設定GUI()
        } catch {
            ToolTip("❌ 匯入失敗，請檢查檔案格式!")
            SetTimer(() => ToolTip(), -2000)
        }
    }
}

; 顯示連招狀態
顯示連招狀態() {
    global 遊戲視窗, 連招組
    狀態文字 := "=== Sid 連技工具箱狀態 ===" "`n`n"
    狀態文字 .= "鎖定視窗: " (遊戲視窗 != "" ? 遊戲視窗 : "❌ 未設定") "`n`n"
    
    啟用數量 := 0
    Loop 5 {
        i := A_Index
        if 連招組[i].觸發按鍵 != "" {
            啟用數量++
            狀態文字 .= "📋 第" i "組連招:`n"
            狀態文字 .= "   觸發: " 連招組[i].觸發按鍵
            
            Loop 4 {
                j := A_Index
                if 連招組[i].技能[j] != ""
                    狀態文字 .= " → " 連招組[i].延遲[j] "ms → " 連招組[i].技能[j]
            }
            狀態文字 .= "`n`n"
        }
    }
    
    if 啟用數量 = 0
        狀態文字 .= "❌ 尚未設定任何連招"
    else
        狀態文字 .= "✅ 共啟用 " 啟用數量 " 組連招"
    
    MsgBox(狀態文字, "連招狀態總覽")
}

; 設置所有熱鍵
設置所有熱鍵() {
    清除所有熱鍵()
    
    global 當前熱鍵, 連招組
    Loop 5 {
        i := A_Index
        if 連招組[i].觸發按鍵 != "" {
            熱鍵名 := 轉換熱鍵名(連招組[i].觸發按鍵)
            if 熱鍵名 != "" {
                try {
                    Hotkey(熱鍵名, (*) => 觸發連招(i))
                    當前熱鍵[熱鍵名] := i
                } catch Error as e {
                    ; 忽略熱鍵設定錯誤
                }
            }
        }
    }
}

; 清除所有熱鍵
清除所有熱鍵() {
    global 當前熱鍵
    for 熱鍵名 in 當前熱鍵 {
        try {
            Hotkey(熱鍵名, "Off")
        } catch {
            ; 忽略清除錯誤
        }
    }
    當前熱鍵.Clear()
}

; 轉換熱鍵名
轉換熱鍵名(按鍵) {
    switch 按鍵 {
        case "Space": return "~*Space"
        case "Tab": return "~*Tab"
        case "LShift": return "~*LShift"
        case "LCtrl": return "~*LCtrl"
        case "LAlt": return "~*LAlt"
        case "RButton": return "~*RButton"
        case "MButton": return "~*MButton"
        default: return (按鍵 != "") ? "~*" 按鍵 : ""
    }
}

; 觸發連招
觸發連招(組號) {
    global 遊戲視窗
    if WinActive(遊戲視窗) {
        執行連招(組號)
    }
}

; 執行連招
執行連招(組號) {
    global 連招組
    
    Loop 4 {
        j := A_Index
        if 連招組[組號].技能[j] = ""
            break
        
        Sleep(連招組[組號].延遲[j])
        發送按鍵(連招組[組號].技能[j])
    }
}

; 發送按鍵
發送按鍵(按鍵) {
    switch 按鍵 {
        case "Space": Send("{Space}")
        case "Tab": Send("{Tab}")
        case "LShift": Send("{LShift}")
        case "LCtrl": Send("{LCtrl}")
        case "LAlt": Send("{LAlt}")
        case "RButton": Click("Right")
        case "MButton": Click("Middle")
        default: Send("{" 按鍵 "}")
    }
}

; 設定檔操作
寫入設定() {
    global 遊戲視窗, 連招組
    
    try {
        IniWrite(遊戲視窗, "連技設定.ini", "基本", "視窗")
        
        Loop 5 {
            i := A_Index
            section := "連招組" i
            IniWrite(連招組[i].觸發按鍵, "連技設定.ini", section, "觸發按鍵")
            Loop 4 {
                j := A_Index
                IniWrite(連招組[i].技能[j], "連技設定.ini", section, "技能" j)
                IniWrite(連招組[i].延遲[j], "連技設定.ini", section, "延遲" j)
            }
        }
    } catch {
        ToolTip("❌ 設定檔寫入失敗!")
        SetTimer(() => ToolTip(), -2000)
    }
}

讀取設定() {
    global 遊戲視窗, 連招組
    
    try {
        遊戲視窗 := IniRead("連技設定.ini", "基本", "視窗", "")
        
        Loop 5 {
            i := A_Index
            section := "連招組" i
            連招組[i].觸發按鍵 := IniRead("連技設定.ini", section, "觸發按鍵", "")
            Loop 4 {
                j := A_Index
                連招組[i].技能[j] := IniRead("連技設定.ini", section, "技能" j, "")
                延遲值 := IniRead("連技設定.ini", section, "延遲" j, "100")
                連招組[i].延遲[j] := IsNumber(延遲值) ? Integer(延遲值) : 100
            }
        }
        
        設置所有熱鍵()
    } catch {
        ; 設定檔不存在或讀取失敗，使用預設值
    }
}