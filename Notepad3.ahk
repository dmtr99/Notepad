#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1

; This also adds the notepad icon, but I will comment it out to keep the testing simple
; #Include "C:\Users\Dimitri\Documents\Autohotkey v2\lib\ImagePut.ahk"
; base64 := "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAKNSURBVDhPjZHLTxNRFMbZm7j2/zG6cEPUxK1xZ9wZEk0kBBIKWpB3CuENlldQaSihgGKhtKXTx/QxnVfn3VL6gLbauJbPO4NSG1lwkpNzM5P7/b7v3JbrqnNsCjeZ/9VkSmXvP3oC6rSCe62P4TXK1tyUT625xGWt+Z7iMBBIwmlv7fpztaXFI0m3B6KZolL7CaFSR7L8HeFCFb6Tc+zqJbiIyDKfxSyjweaLo9+fwIjtWcOJkzPuOhKyKFXr4M7qiBdrOM5X4M2Wsa0W8Fk6gZM3MJVU0fUtitmY0CzgSEg9y6xxRGkn8Ks5eCUDHl6DKy1jNSFinuYxTqUt8suNr1ijuWaBwVhmf1PKu5izH6BLNYSI/cNcGTt6kdjPY0Ug9tM6RmgZbVtHSJaqzQL2MK/vaaU5n5LDfuaSvkHoa4kMFmiB0FkMBRl0H9J4vrINvVxpCPTvJW/1RcSsWz6djxSrCObPrewejdClS/pcWoMjoaI3xOK1J4BfFxcNAXuIezAWl+PrYm5hT9Th5lR8YiSskOxzMTM7oQdS6DmK440niHb3AWr1ekOgLyz2zaTUHSerL/ryZ/hilLClFPCRbH6JbH6G0UEAsEdFdHppOEJpmHUl0Evx/kVyeTqlfnCxCtZTEpxxAdMxDg6y+QGTTt6+fT+GNpcXi1Sq2YHtmNdnGG3cEVeWPFoBGyT3qpDDPGtgIqlgiJbwNiyiI2DmDyJKXF456Dxg77wLC9JsSpuYSirLf7Obm5+McBg9ZtBPHPQSBx3eKF6sepAplBsOOvzMQxvFwx4RLdIIyTpM3nqYnAfNjmUwSr6ZPRjN4NVuyKKbdRXh35I1w1K/SV8rMNz91G3+uEk77a1dvwG4Tq7njMk9LQAAAABJRU5ErkJggg=="
; newIcon := ImagePutHIcon(base64)
; TraySetIcon("HICON:" . newIcon)

global oSettings := Object()
TraySetIcon("Notepad.exe")


oSettings.File := A_ScriptDir "\" RegExReplace(A_ScriptName, "(.*\.)(.*)", "$1ini")
; ; Settings to set ini file hidden in AppData
; Folder := A_AppData "\" RegExReplace(A_ScriptName, "(.*)\.(.*)", "$1")
; DirCreate(Folder)
; oSettings.File := Folder "\" RegExReplace(A_ScriptName, "(.*\.)(.*)", "$1ini")

oSettings.Darkmode := IniRead(oSettings.File, "Settings", "Darkmode",false)

if (oSettings.Darkmode){
	DllCall("dwmapi\DwmSetWindowAttribute", "ptr", A_ScriptHwnd, "int", 20, "int*", true, "int", 4)
}
FilePath := ""
if (A_Args.Length < 0){
	FilePath := A_Args[1]
}
; class Ini {
; 	__New(FileName){
; 		this.FileName := FileName
; 	}
;     __Item[Section, Key, Default:=""] {
;         get {
; 			return IniRead(this.Filename, Section, Key, Default)
; 		}
;         set {
; 			return IniWrite(Value, this.Filename, Section, Key)
; 		}
;     }
; }

; Ini1 := Ini(RegExReplace(A_ScriptName, "(.*)\.(.*)", "$11.ini"))
; Ini1.GetOwnPropDesc(Name)
; ini1["pos","W"] := "100"


AHKPad(FilePath)

AHKPad(FilePath := ""){

	; Create the MyGui window:
	; SkinForm("Apply", A_ScriptDir . "\USkin.dll", A_ScriptDir . "\concaved.msstyles")
	MyGui := Gui("+Resize")	; Make the window resizable.
	if (oSettings.Darkmode){
		DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MyGui.hwnd, "int", 20, "int*", true, "int", 4)
	}
	MyGui.Title := "Untitled - Notepad"
	MyGui.MarginX := 0
	MyGui.MarginY := 0

	MyGui.StatusBar := IniRead(oSettings.File, "Settings", "StatusBar", false)
	MyGui.FontSize := IniRead(oSettings.File, "Settings", "FontSize", 11)
	MyGui.FontStyle := IniRead(oSettings.File, "Settings", "FontStyle", "Norm")
	MyGui.FontName := IniRead(oSettings.File, "Settings", "FontName", "Consolas")
	MyGui.FontStyleAlternative := IniRead(oSettings.File, "Settings", "FontStyleAlternative", "Regular")

	MyGui.Zoom := 100
	MyGui.FilePath := FilePath
	MyGui.X := IniRead(oSettings.File, "Pos", "X","")
	MyGui.Y := IniRead(oSettings.File, "Pos", "Y","")
	MyGui.W := IniRead(oSettings.File, "Pos", "W",500)
	MyGui.H := IniRead(oSettings.File, "Pos", "H",300)

	; Create the main Edit control:

	MainEdit := MyGui.AddEdit("+Wrap +Multi -HScroll +VScroll -0x40 +0x100 +0x10000000 WantTab -E0x200 W600 R20 -border" , "")
	MainEdit.OnEvent("Change", MainEdit_Change)
	MainEdit.OnEvent("Focus", MainEdit_Focus)
	MainEdit.OnEvent("LoseFocus", MainEdit_Focus)
	UpdateFont()

	if (oSettings.Darkmode){
		MainEdit.Opt("Background0x383838 cWhite")
		DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MainEdit.hwnd, "int", 20, "int*", true, "int", 4)
	}
	MyGui.MainEdit := MainEdit

	MyGui.SB := MyGui.AddStatusBar("" , "")
	MyGui.SB.SetParts(600 - 430, 140, 50, 120, 120)
	MyGui.SB.SetText(" Ln 1, Col 1", 2)
	MyGui.SB.SetText(" 100%", 3)
	MyGui.SB.SetText(" Windows (CRLF)", 4)
	MyGui.SB.SetText(" UTF-8", 5)
	WinSetAlwaysOnTop(1,"ahk_id " MyGui.SB.hwnd)
	if (!MyGui.Statusbar){
		DllCall("ShowWindow", "UInt", MyGui.SB.hwnd, "Int", "0")
	}

	FileMenu := Menu()

	FileMenu.Add("&New`tCtrl+N", MenuFileNew)
	FileMenu.SetIcon("&New`tCtrl+N","shell32.dll", 1)
	FileMenu.Add("New &Window`tCtrl+Shift+N", MenuFileNewWindow)
	FileMenu.SetIcon("New &Window`tCtrl+Shift+N","shell32.dll", 3)
	FileMenu.Add("&Open`tCtrl+O", MenuFileOpen)
	FileMenu.SetIcon("&Open`tCtrl+O","shell32.dll", 4)
	FileMenu.Add("&Save`tCtrl+S", MenuFileSave)
	FileMenu.SetIcon("&Save`tCtrl+S","shell32.dll", 259)
	FileMenu.Add("Save &As...`t Ctrl+Shift+S", MenuFileSaveAs)
	FileMenu.SetIcon("Save &As...`t Ctrl+Shift+S","shell32.dll", 259)
	FileMenu.Add()	; Separator line.
	FileMenu.Add("Page Setup...", MenuFilePageSetup)
	FileMenu.Add("Print...`t Ctrl+P", MenuFilePrint)
	FileMenu.SetIcon("Print...`t Ctrl+P","shell32.dll", 17)
	FileMenu.Add()	; Separator line.
	FileMenu.Add("E&xit", MenuFileExit)
	EditMenu := Menu()
	EditMenu.Add("&Undo`tCtrl+Z", MenuEditUndo)
	EditMenu.Disable("&Undo`tCtrl+Z")
	EditMenu.Add()
	EditMenu.Add("Cu&t`tCtrl+X", MenuEditCut)
	EditMenu.SetIcon("Cu&t`tCtrl+X","shell32.dll", 260)
	EditMenu.Add("&Copy`tCtrl+C", MenuEditCopy)
	EditMenu.SetIcon("&Copy`tCtrl+C","shell32.dll", 135)
	EditMenu.Add("&Paste`tCtrl+P", MenuEditPaste)
	EditMenu.SetIcon("&Paste`tCtrl+P","shell32.dll", 261)
	EditMenu.Add("De&lete`tDel", MenuEditDelete)
	EditMenu.SetIcon("De&lete`tDel","shell32.dll", 132)
	EditMenu.Add()
	EditMenu.Add("&Find`tCtrl+F", MenuEditFind)
	EditMenu.Add("&Find Next`tF3", MenuEditFind)
	EditMenu.Add("Find Pre&vious`tShift+F3", MenuEditFind)
	EditMenu.Add("&Replace`tCtrl+H", MenuEditReplace)
	EditMenu.SetIcon("&Replace`tCtrl+H","shell32.dll", 239)
	EditMenu.Add("&Go To`tCtrl+G", MenuEditGoTo)
	EditMenu.Add()
	EditMenu.Add("Select &All	Ctrl+A", MenuEditSelectAll)
	EditMenu.Add("&Time/Date	F5", MenuEditTimeDate)
	MyGui.EditMenu := EditMenu
	ZoomMenu := Menu()
	ZoomMenu.Add("Zoom In`tCtrl+Plus", MenuViewZoomIn)
	ZoomMenu.Add("Zoom Out`tCtrl+Min", MenuViewZoomOut)
	ZoomMenu.Add("Restore Default Zoom`tCtrl+0", MenuViewRestoreDefaultZoom)
	FormatMenu := Menu()
	FormatMenu.Add("Word Wrap", MenuFormatWordWrap)

	MyGui.Wrap := IniRead(oSettings.File, "Settings", "Wrap", false)
	if (MyGui.Wrap){
		FormatMenu.Check("Word Wrap")
	}

	FormatMenu.Add("Font...", MenuFormatFont)
	ViewMenu := Menu()
	ViewMenu.Add("&Zoom", ZoomMenu)
	ViewMenu.Add("&Statusbar", MenuViewStatusbar)

	if (MyGui.Statusbar){
		ViewMenu.Check("&Statusbar")
	}

	HelpMenu := Menu()
	HelpMenu.Add("&View Help", (*)=>(Run("https://www.bing.com/search?q=get+help+for+notepad+in+windows")))
	HelpMenu.SetIcon("&View Help","shell32.dll", 24)
	HelpMenu.Add("&Send Feedback", (*)=>(SendInput("#f")))
	HelpMenu.Add()
	HelpMenu.Add("&About Notepad", MenuHelpAbout)
	HelpMenu.SetIcon("&About Notepad","shell32.dll", 278)

	; Create the menu bar by attaching the submenus to it:
	MyMenuBar := MenuBar()
	MyMenuBar.Add("&File", FileMenu)
	MyMenuBar.Add("&Edit", EditMenu)
	MyMenuBar.Add("F&ormat", FormatMenu)
	MyMenuBar.Add("&View", ViewMenu)
	MyMenuBar.Add("&Help", HelpMenu)

	if (oSettings.Darkmode){
		uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
		SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
		FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
		DllCall(SetPreferredAppMode, "int", 1)	; Dark
		DllCall(FlushMenuThemes)
		DllCall("uxtheme\SetWindowTheme", "ptr", MainEdit.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
	}

	; Attach the menu bar to the window:
	MyGui.MenuBar := MyMenuBar

	; Apply events:
	MyGui.OnEvent("Close", MenuFileExit)
	MyGui.OnEvent("DropFiles", Gui_DropFiles)
	MyGui.OnEvent("Size", Gui_Size)

	MyGui.Show((MyGui.X="" ? "" : " x" MyGui.X ) (MyGui.Y="" ? "" : " y" MyGui.Y ) "w" MyGui.W " h" MyGui.H)	; Display the window.

	HotIfWinActive("ahk_id " myGui.hwnd)
	Hotkey "^WheelDown", (*) => ZoomOut()
	Hotkey "^NumpadSub", (*) => ZoomOut()
	Hotkey "^WheelUp", (*) => ZoomIn()
	Hotkey "^NumpadAdd", (*) => ZoomIn()

	OnMessage(0x0100, WM_UpdateGui) ; Calling the same function(WM_KEYDOWN :=0x0100)
	OnMessage(0x0101, WM_UpdateGui) ; Calling the same function(WM_KEYUP :=0x0101)
	OnMessage(0x0201, WM_UpdateGui) ; Calling the same function(WM_LBUTTONDOWN :=0x0201)
	OnMessage(0x0202, WM_UpdateGui) ; Calling the same function(WM_LBUTTONUP :=0x0202)
	OnMessage(0x0008, WM_UpdateGui) ; Calling the same function(WM_KILLFOCUS :=0x0008)
	Hook_ES_MENUSTART := DllCall("SetWinEventHook", "UInt", 0x4, "UInt", 0x4, "UInt", 0, "UInt", CallbackCreate(CallBack_ES_MENUSTART), "UInt", 0, "UInt", 0, "UInt", 0)

	if (FilePath!=""){
		readContent(FilePath)
	}
	return

	ZoomOut(){
		MyGui.Zoom := Max(MyGui.Zoom -10,10)
		UpdateFont()
		sleep(20)
		MyGui.SB.SetText(" " MyGui.Zoom "%", 3)
	}

	ZoomIn() {
		MyGui.Zoom := Min(MyGui.Zoom +10,500)
		UpdateFont()
		sleep(20)
		MyGui.SB.SetText(" " MyGui.Zoom "%", 3)
	}

	UpdateFont(){
		FontSize := Round(MyGui.FontSize*MyGui.Zoom/100)
		FontSize := Max(Min(FontSize,71), 2)
		MainEdit.SetFont(MyGui.FontStyle " s" FontSize, MyGui.FontName)
	}

	MenuFileNew(*) {
		if GuiCheckChanges(){
			MainEdit.Value := ""	; Clear the Edit control.
			FileMenu.Disable("4&")	; Gray out &Save.
			MyGui.Title := "Untitled - NotePad"
		}
	}

	MenuFileNewWindow(*) {
		global
		AHKpad()
	}

	MenuFileOpen(*) {
		if GuiCheckChanges(){
			MyGui.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
			SelectedFileName := FileSelect(3, , "Open", "Text Documents (*.txt)")
			if SelectedFileName = ""	; No file selected.
				return
			readContent(SelectedFileName)
		}
	}

	GuiFileOpen(*) {
		MyGui.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
		SelectedFileName := FileSelect(3, , "Open", "Text Documents (*.txt)")
		if SelectedFileName = ""	; No file selected.
			return
		readContent(SelectedFileName)
	}

	MenuFileSave(*) {

		if (FilePath!="") {
			saveContent(FilePath)
		} else {
			MyGui.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
			SelectedFileName := FileSelect("S16", "*.txt", "Save As", "Text Documents (*.txt)")
			if SelectedFileName = ""	; No file selected.
				return
			saveContent(SelectedFileName)
		}
		return true
	}

	MenuFileSaveAs(*) {
		MyGui.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
		SelectedFileName := FileSelect("S16", , "Save As", "Text Documents (*.txt)")
		if SelectedFileName = ""	; No file selected.
			return false
		saveContent(SelectedFileName)
	}

	MenuFilePageSetup(*) {
		gPageSetup := Gui("+owner" MyGui.Hwnd, "Page Setup")

		gPageSetup.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
		gPageSetup.Opt("+0x94C80000")
		gPageSetup.Opt("-Toolwindow")
		mSizes := Map()

		{
			mSizes["10x11"] := {w:210, h:279.4}
			mSizes["10x14"] := {w:254, h:335.6}
			mSizes["11x17"] := {w:279.4, h:431.8}
			mSizes["12x11"] := {w:210, h:279.4}
			mSizes["15x11"] := {w:210, h:279.4}
			mSizes["6 3/4 Envelope"] := {w:210, h:297}
			mSizes["9x11"] := {w:210, h:297}
			mSizes["A2"] := {w:420, h:594}
			mSizes["A3"] := {w:297, h:420}
			mSizes["A3 Extra"] := {w:297, h:420}
			mSizes["A3 Extra Transverse"] := {w:297, h:420}
			mSizes["A3 Rotated"] := {w:420, h:297}
			mSizes["A3 Transverse"] := {w:297, h:420}
			mSizes["A4"] := {w:210, h:297}
			mSizes["A4 Extra"] := {w:210, h:297}
			mSizes["A4 Plus"] := {w:210, h:297}
			mSizes["A4 Rotated"] := {w:297, h:210}
			mSizes["A4 Small"] := {w:210, h:297}
			mSizes["A4 Transverse"] := {w:210, h:297}
			mSizes["A5"] := {w:148, h:210}
			mSizes["A5 Extra"] := {w:148, h:210}
			mSizes["A5 Rotated"] := {w:210, h:297}
			mSizes["A5 Transverse"] := {w:210, h:297}
			mSizes["A6"] := {w:210, h:297}
			mSizes["A6 Rotated"] := {w:210, h:297}
			mSizes["B4 (ISO)"] := {w:210, h:297}
			mSizes["B4 (JIS)"] := {w:210, h:297}
			mSizes["B4 (JIS) Rotated"] := {w:210, h:297}
			mSizes["B5 (ISO) Extra"] := {w:210, h:297}
			mSizes["B5 (JIS)"] := {w:210, h:297}
			mSizes["B5 (JIS) Rotated"] := {w:210, h:297}
			mSizes["B5 (JIS) Transverse"] := {w:210, h:297}
			mSizes["B6 (JIS)"] := {w:210, h:297}
			mSizes["B6 (JIS) Rotated"] := {w:210, h:297}
			mSizes["C size sheet"] := {w:210, h:297}
			mSizes["D size sheet"] := {w:210, h:297}
			mSizes["Double Japan Postcard Rotated"] := {w:210, h:297}
			mSizes["E size sheet"] := {w:210, h:297}
			mSizes["Envelope"] := {w:210, h:297}
			mSizes["Envelope #10"] := {w:210, h:297}
			mSizes["Envelope #11"] := {w:210, h:297}
			mSizes["Envelope #12"] := {w:210, h:297}
			mSizes["Envelope #14"] := {w:210, h:297}
			mSizes["Envelope #9"] := {w:210, h:297}
			mSizes["Envelope B4"] := {w:210, h:297}
			mSizes["Envelope B5"] := {w:210, h:297}
			mSizes["Envelope B6"] := {w:210, h:297}
			mSizes["Envelope C3"] := {w:210, h:297}
			mSizes["Envelope C4"] := {w:210, h:297}
			mSizes["Envelope C5"] := {w:210, h:297}
			mSizes["Envelope C6"] := {w:210, h:297}
			mSizes["Envelope C65"] := {w:210, h:297}
			mSizes["Envelope DL"] := {w:210, h:297}
			mSizes["Envelope Invitation"] := {w:210, h:297}
			mSizes["Envelope Monarch"] := {w:210, h:297}
			mSizes["Executive"] := {w:210, h:297}
			mSizes["Folio"] := {w:210, h:297}
			mSizes["German Legal Fanfold"] := {w:210, h:297}
			mSizes["German Std Fanfold"] := {w:210, h:297}
			mSizes["Japan Envelope Chou #3 Rotated"] := {w:210, h:297}
			mSizes["Japan Envelope Chou #4 Rotated"] := {w:210, h:297}
			mSizes["Japan Envelope Kaku #2 Rotated"] := {w:210, h:297}
			mSizes["Japan Envelope Kaku #3 Rotated"] := {w:210, h:297}
			mSizes["Japan Envelope You #4"] := {w:210, h:297}
			mSizes["Japan Envelope You #4 Rotated"] := {w:210, h:297}
			mSizes["Japanese Double Postcard"] := {w:210, h:297}
			mSizes["Japanese Envelope Chou #3"] := {w:210, h:297}
			mSizes["Japanese Envelope Chou #4"] := {w:210, h:297}
			mSizes["Japanese Envelope Kaku #2"] := {w:210, h:297}
			mSizes["Japanese Envelope Kaku #3"] := {w:210, h:297}
			mSizes["Japanese Postcard"] := {w:210, h:297}
			mSizes["Japanese Postcard Rotated"] := {w:210, h:297}
			mSizes["Ledger"] := {w:210, h:297}
			mSizes["Legal"] := {w:210, h:297}
			mSizes["Legal Extra"] := {w:210, h:297}
			mSizes["Letter"] := {w:210, h:297}
			mSizes["Letter Extra"] := {w:210, h:297}
			mSizes["Letter Extra Transverse"] := {w:210, h:297}
			mSizes["Letter Plus"] := {w:210, h:297}
			mSizes["Letter Rotated"] := {w:210, h:297}
			mSizes["Letter Small"] := {w:210, h:297}
			mSizes["Letter Transverse"] := {w:210, h:297}
			mSizes["Note"] := {w:210, h:297}
			mSizes["PRC 16K"] := {w:210, h:297}
			mSizes["PRC 16K Rotated"] := {w:210, h:297}
			mSizes["PRC 32K"] := {w:210, h:297}
			mSizes["PRC 32K Rotated"] := {w:210, h:297}
			mSizes["PRC 32K(Big)"] := {w:210, h:297}
			mSizes["PRC 32K(Big) Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #1"] := {w:210, h:297}
			mSizes["PRC Envelope #1 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #10"] := {w:210, h:297}
			mSizes["PRC Envelope #10 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #2"] := {w:210, h:297}
			mSizes["PRC Envelope #2 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #3"] := {w:210, h:297}
			mSizes["PRC Envelope #3 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #4"] := {w:210, h:297}
			mSizes["PRC Envelope #4 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #5"] := {w:210, h:297}
			mSizes["PRC Envelope #5 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #6"] := {w:210, h:297}
			mSizes["PRC Envelope #6 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #7"] := {w:210, h:297}
			mSizes["PRC Envelope #7 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #8"] := {w:210, h:297}
			mSizes["PRC Envelope #8 Rotated"] := {w:210, h:297}
			mSizes["PRC Envelope #9"] := {w:210, h:297}
			mSizes["PRC Envelope #9 Rotated"] := {w:210, h:297}
			mSizes["Quarto"] := {w:210, h:297}
			mSizes["Reserved48"] := {w:210, h:297}
			mSizes["Reserved49"] := {w:210, h:297}
			mSizes["Statement"] := {w:210, h:297}
			mSizes["Super A"] := {w:210, h:297}
			mSizes["Super B"] := {w:210, h:297}
			mSizes["Tabloid"] := {w:210, h:297}
			mSizes["Tabloid Extra"] := {w:210, h:297}
			mSizes["US Std Fanfold"] := {w:210, h:297}
		}

		gPageSetup.Opt("-MaximizeBox -MinimizeBox")
		Button1 := gPageSetup.AddGroupBox("x12 y13 w336 h91 +Group +E0x4", "Paper")
		Static1 := gPageSetup.AddText("x24 y39 w54 h13 +Group +E0x4", "Si&ze:")
		cbSize := gPageSetup.Add("DropDownList", "x96 y37 w240 +Group +Sort +E0x4", ["10x11","10x14","11x17","12x11","15x11","6 3/4 Envelope","9x11","A2","A3","A3 Extra","A3 Extra Transverse","A3 Rotated","A3 Transverse","A4","A4 Extra","A4 Plus","A4 Rotated","A4 Small","A4 Transverse","A5","A5 Extra","A5 Rotated","A5 Transverse","A6","A6 Rotated","B4 (ISO)","B4 (JIS)","B4 (JIS) Rotated","B5 (ISO) Extra","B5 (JIS)","B5 (JIS) Rotated","B5 (JIS) Transverse","B6 (JIS)","B6 (JIS) Rotated","C size sheet","D size sheet","Double Japan Postcard Rotated","E size sheet","Envelope","Envelope #10","Envelope #11","Envelope #12","Envelope #14","Envelope #9","Envelope B4","Envelope B5","Envelope B6","Envelope C3","Envelope C4","Envelope C5","Envelope C6","Envelope C65","Envelope DL","Envelope Invitation","Envelope Monarch","Executive","Folio","German Legal Fanfold","German Std Fanfold","Japan Envelope Chou #3 Rotated","Japan Envelope Chou #4 Rotated","Japan Envelope Kaku #2 Rotated","Japan Envelope Kaku #3 Rotated","Japan Envelope You #4","Japan Envelope You #4 Rotated","Japanese Double Postcard","Japanese Envelope Chou #3","Japanese Envelope Chou #4","Japanese Envelope Kaku #2","Japanese Envelope Kaku #3","Japanese Postcard","Japanese Postcard Rotated","Ledger","Legal","Legal Extra","Letter","Letter Extra","Letter Extra Transverse","Letter Plus","Letter Rotated","Letter Small","Letter Transverse","Note","PRC 16K","PRC 16K Rotated","PRC 32K","PRC 32K Rotated","PRC 32K(Big)","PRC 32K(Big) Rotated","PRC Envelope #1","PRC Envelope #1 Rotated","PRC Envelope #10","PRC Envelope #10 Rotated","PRC Envelope #2","PRC Envelope #2 Rotated","PRC Envelope #3","PRC Envelope #3 Rotated","PRC Envelope #4","PRC Envelope #4 Rotated","PRC Envelope #5","PRC Envelope #5 Rotated","PRC Envelope #6","PRC Envelope #6 Rotated","PRC Envelope #7","PRC Envelope #7 Rotated","PRC Envelope #8","PRC Envelope #8 Rotated","PRC Envelope #9","PRC Envelope #9 Rotated","Quarto","Reserved48","Reserved49","Statement","Super A","Super B","Tabloid","Tabloid Extra","US Std Fanfold"])
		cbSize.text := "A4"
		cbSize.OnEvent("Change", UpdatePreview)
		Static2 := gPageSetup.AddText("x24 y73 w54 h13 +Group +E0x4", "&Source:")
		ComboBox2 := gPageSetup.Add("DropDownList", "x96 y68 w240 +Group +Sort +E0x4", ["Default"])
		ComboBox2.text := "Default"
		gPageSetup.AddGroupBox("x12 y112 w96 h91 +Group +E0x4", "Orientation")
		ogRBOrientation := gPageSetup.AddRadio("x24 y133 w78 h20 +E0x4 checked", "P&ortrait")
		ogRBOrientation.OnEvent("Click", UpdatePreview)
		OgRBLandscape := gPageSetup.AddRadio("x24 y167 w78 h20 -Tabstop -Group +E0x4", "L&andscape")
		OgRBLandscape.OnEvent("Click", UpdatePreview)
		gPageSetup.AddGroupBox("x120 y112 w228 h91 +Group +E0x4", "Margins (millimetres)")
		Static3 := gPageSetup.AddText("x132 y138 w48 h13 +Group +E0x4", "&Left:")
		ogEditLeft := gPageSetup.AddEdit("x180 y133 w42 h20 +Group -Limit +E0x4 +Number", "20")
		ogEditLeft.OnEvent("Change", UpdatePreview)
		Static4 := gPageSetup.AddText("x246 y138 w48 h13 +Group +E0x4", "&Right:")
		ogEditRight := gPageSetup.AddEdit("x294 y133 w42 h20 +Group -Limit +E0x4 +Number", "20")
		ogEditRight.OnEvent("Change", UpdatePreview)
		Static5 := gPageSetup.AddText("x132 y169 w48 h13 +Group +E0x4", "&Top:")
		ogEditTop := gPageSetup.AddEdit("x180 y167 w42 h20 +Group -Limit +E0x4 +Number", "25")
		ogEditTop.OnEvent("Change", UpdatePreview)
		Static6 := gPageSetup.AddText("x246 y169 w48 h13 +Group +E0x4", "&Bottom:")
		ogEditBottom := gPageSetup.AddEdit("x294 y167 w42 h20 +Group -Limit +E0x4 +Number", "25")
		ogEditBottom.OnEvent("Change", UpdatePreview)
		Static7 := gPageSetup.AddText("x12 y219 w44 h13 +Group +E0x4", "&Header:")
		Edit5 := gPageSetup.AddEdit("x84 y218 w261 h20 +E0x4", "")
		Static8 := gPageSetup.AddText("x12 y250 w44 h13 +Group +E0x4", "&Footer:")
		Edit6 := gPageSetup.AddEdit("x84 y249 w261 h20 +E0x4", "")
		SysLink1 := gPageSetup.AddLink("x84 y276 w182 h13 +E0x4", '<A href="http://go.microsoft.com/fwlink/p?linkid=838060">Input Values</A>')
		ButtonOK := gPageSetup.AddButton("x366 y283 w75 +Group +0x3 +0x9 +Default +0x7 +E0x4", "OK")
		ButtonCancel := gPageSetup.AddButton("x447 y283 w75 +E0x4", "Cancel")
		Button8 := gPageSetup.AddButton("x447 y283 w75 +Hidden +E0x4", "&Printer...")
		Button9 := gPageSetup.AddGroupBox("x360 y13 w162 h257 +E0x4", "Preview")
		Static9 := gPageSetup.AddText("x395 y75 w91 h130 +0x7 +0x4 +0x12 +0x5 +Wrap +Right +0x6 +E0x4", "")
		Static10 := gPageSetup.AddText("x486 y83 w8 h130 +0x7 +0x4 +Center +0x11 +0x5 +Wrap +0x9 +0x6 +E0x4", "")
		Static11 := gPageSetup.AddText("x403 y205 w91 h8 +0x7 +0x4 +Center +0x11 +0x5 +Wrap +0x9 +0x6 +E0x4", "")

		xCenter := 445
		yCenter := 144
		W := 100
		H := 130
		Shadow := 8

		ogShadow := gPageSetup.AddText("x" xCenter-W/2+Shadow/2 " y" yCenter-H/2+Shadow/2 " w" W " h" H " BackGroundA0A0A0")
		ogPage := gPageSetup.AddText("x" xCenter-W/2-Shadow/2 " y" yCenter-H/2-Shadow/2 " w" W " h" H " BackGroundWhite +Border")
		gPageSetup.SetFont("s3","Calibri")
		ogText := gPageSetup.AddText("x" xCenter-W/2+Shadow/2 +10 " y" yCenter-H/2+Shadow/2+10 " w" W-20 " h" H-20 " BackGroundWhite +Wrap","abcdefgh ijklmnopqr stuvwxyzabcdefgh ijklmnopq rstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`n`nabcdefghi jklmnopqrst uvwxyzabcd efghijklmno pqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`n`nabcdefghi jklmnopqrs tuvwxyzabcdef ghijklmnopqrstu vwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`nabcdefghijklmnopqrstuvwxyz`n")
		gPageSetup.SetFont()

		ButtonOK.OnEvent("Click",(*)=>(gPageSetup.Destroy()))
		ButtonCancel.OnEvent("Click",(*)=>(gPageSetup.Destroy()))
		gPageSetup.Show("w534 h319")
		Return

		UpdatePreview(*){
			oSize := mSizes[cbSize.text]
			Ratio := oSize.w/oSize.H
			if(!ogRBOrientation.value){
				Ratio := 1/Ratio
			}
			if (Ratio>1.2){
				W := 130
			} else if (Ratio>0.8){
				W := 100
			} else{
				W := 115
			}
			Scale := W/oSize.w
			xCenter := 445
			yCenter := 144
			H := W/ratio
			Shadow := 8
			Left := ogEditLeft.value*Scale+1
			Right := ogEditRight.value*Scale+1
			Top := ogEditTop.value*Scale+1
			Bottom := ogEditBottom.value*Scale+1

			ControlMove(xCenter-W/2+Shadow/2, yCenter-H/2+Shadow/2, W, H, ogShadow)
			ControlMove(xCenter-W/2-Shadow/2, yCenter-H/2-Shadow/2, W, H, ogPage)
			ControlMove(xCenter-W/2-Shadow/2+Left, yCenter-H/2-Shadow/2+Top, W-(Left+Right), H-(Top+Bottom), ogText)
			WinRedraw gPageSetup
		}
	}

	MenuFilePrint(*) {
		gFilePrint := Gui("+owner" MyGui.Hwnd, "Print")

		gFilePrint.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
		gFilePrint.Opt("+0x94C80000")
		gFilePrint.Opt("-Toolwindow")
		gFilePrint.Opt("-MaximizeBox -MinimizeBox")

		hIcon := LoadPicture("Shell32.dll", "Icon17 w" 32 " h" 32, &imgtype) ; not the exact icon, but a start
		SendMessage(0x0080, 0, hIcon, gFilePrint)  ; 0x0080 is WM_SETICON; and 1 means ICON_BIG (vs. 0 for ICON_SMALL).

		Static1 := gFilePrint.AddText("x42 y163 w53 h13 +Hidden +Group +0x80 +E0x4", "Select Printer")
		SysTabControl321 := gFilePrint.Add("Tab3", "x6 y7 w446 h348 +Group +E0x4", ["General"])
		SysTabControl321.UseTab("General")

		ListViewPrinters := gFilePrint.AddListView("x31 y57 w396 h86 -List", ["Name"])
		ImageListID := IL_Create(1)
		ListViewPrinters.SetImageList(ImageListID)
		IL_Add(ImageListID, "shell32.dll", 17)

		defaultPrinter := RegRead("HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows", "device")
		defaultName := StrSplit(defaultPrinter,",")
		defaultName := defaultName[1]

		printerlist := ""

		Loop Reg "HKCU\Software\Microsoft\Windows NT\CurrentVersion\devices"
		{
			printerlist .= (printerlist="" ? "": "`n") A_LoopRegName
		}

		printerlist := Sort(printerlist)
		Loop parse, printerlist, "`n"
		{
			ListViewPrinters.Add("Icon1",A_LoopField)
		}

		Button1 := gFilePrint.AddGroupBox("x21 y40 w417 h169 +E0x4", "Select Printer")
		Button2 := gFilePrint.AddGroupBox("x21 y221 w417 h119 +Hidden +E0x4", "")
		ListBox1 := gFilePrint.Add("ListBox", "x31 y57 w396 h86 +Hidden -Tabstop +0x100 +Sort -0x80 +E0x4", [])
		Static2 := gFilePrint.AddText("x31 y153 w75 h13 +Group +0x80 +E0x4", "Status:")
		Edit1 := gFilePrint.AddEdit("x108 y153 w149 h13 -Tabstop +ReadOnly -E0x200 +E0x4", "Ready")
		Static3 := gFilePrint.AddText("x31 y170 w75 h13 +Group +0x80 +E0x4", "Location:")
		Edit2 := gFilePrint.AddEdit("x108 y170 w224 h13 -Tabstop +ReadOnly -E0x200 +E0x4", "")
		Static4 := gFilePrint.AddText("x31 y188 w75 h13 +Group +0x80 +E0x4", "Comment:")
		Edit3 := gFilePrint.AddEdit("x108 y188 w224 h13 -Tabstop +ReadOnly -E0x200 +E0x4", "")
		Button3 := gFilePrint.AddCheckBox("x276 y154 w71 h13 +Group +E0x4", "Print to &file")
		Button4 := gFilePrint.AddButton("x352 y149 w75 +Group +E0x4", "P&references")
		Button5 := gFilePrint.AddButton("x352 y179 w75 +Group +E0x4", "Fin&d Printer...")
		Button6 := gFilePrint.AddGroupBox("x21 y221 w224 h119 +Group +E0x4", "Page Range")
		Button7 := gFilePrint.AddRadio("x32 y239 w87 h16 +0x6 -0x3 -0x9 +E0x4 Checked", "A&ll")
		Button8 := gFilePrint.AddRadio("x32 y260 w87 h16 +Disabled -Tabstop -Group +0x6 -0x3 -0x9 +E0x4", "Selec&tion")
		Button9 := gFilePrint.AddRadio("x137 y260 w87 h16 +Disabled -Tabstop -Group +0x6 -0x3 -0x9 +E0x4", "C&urrent Page")
		Button10 := gFilePrint.Add("Radio", "x32 y283 w87 h16 +Disabled -Tabstop -Group +0x6 -0x3 -0x9 +E0x4", "Pa&ges:")
		Static5 := gFilePrint.AddText("x32 y232 w2 h2 +Hidden +Disabled +E0x4", "Page range")
		Edit4 := gFilePrint.AddEdit("x138 y281 w87 h20 +Disabled +Group +E0x4", "")
		Static6 := gFilePrint.AddText("x30 y306 w209 h29 +Hidden +Disabled +Group +E0x4", "Enter page numbers and/or page ranges separated by commas.  For example, 1,5-12")
		Static7 := gFilePrint.AddText("x30 y306 w209 h29 +Hidden +Disabled +Group +E0x4", "Enter either a single page number or a single page range.  For example, 5-12")
		Button11 := gFilePrint.AddGroupBox("x260 y221 w177 h119 +Group +E0x4", "")
		Static8 := gFilePrint.AddText("x267 y242 w92 h16 +Group +E0x4", "Number of &copies:")
		Edit5 := gFilePrint.AddEdit("x359 y239 w50 +Group -Limit +Number +E0x4", 1)
		msctls_updown321 := gFilePrint.AddUpDown("x389 y239", 1)
		Button12 := gFilePrint.AddCheckBox("x270 y283 w53 +Disabled +Group +E0x4", "C&ollate")

		; Static9 := gFilePrint.AddPicture("x330 y275 w101 h59 +Group +0x200 +E0x4", "mspaint.exe")

		gFilePrint.AddPicture("x331 y289 w31 h30 +Group +0x200 +E0x4 Icon1", "Papers.png")
		gFilePrint.AddPicture("x+2 yp w31 h30 +Group +0x200 +E0x4 Icon1", "Papers.png")
		gFilePrint.AddPicture("x+2 yp w31 h30 +Group +0x200 +E0x4 Icon1", "Papers.png")
		gFilePrint.SetFont("s12","Calibri")
		gFilePrint.AddText("x338 y300 +0x80 +E0x4", "1").Opt("+BackgroundTrans")
		gFilePrint.AddText("xp+12 yp-6 +0x80 +E0x4", "1").Opt("+BackgroundTrans")
		gFilePrint.AddText("x" 338+33 " y300 +0x80 +E0x4", "2").Opt("+BackgroundTrans")
		gFilePrint.AddText("xp+12 yp-6 +0x80 +E0x4", "2").Opt("+BackgroundTrans")
		gFilePrint.AddText("x" 338+66 " y300 +0x80 +E0x4", "3").Opt("+BackgroundTrans")
		gFilePrint.AddText("xp+12 yp-6 +0x80 +E0x4", "3").Opt("+BackgroundTrans")
		gFilePrint.SetFont()

		SysTabControl321.UseTab()
		ButtonPrint := gFilePrint.AddButton("x215 y361 w75 +Group +0x3 +0x9 +Default +0x7 +E0x4", "&Print")
		ButtonCancel := gFilePrint.AddButton("x296 y361 w75 +E0x4", "Cancel")
		ButtonCancel.OnEvent("Click",(*)=>(gFilePrint.Destroy()))
		ButtonApply := gFilePrint.AddButton("x377 y361 w75 +Disabled +E0x4", "&Apply")
		ButtonHelp := gFilePrint.AddButton("x458 y361 w75 +Hidden +Group +E0x4", "Help")
		gFilePrint.Show("w458 h391")
		Return
	}

	MenuFileExit(*) {	; User chose "Exit" from the File menu.
		if (SubStr(MyGui.Title, 1, 1) = "*") {
			result := GuiCheckChanges()
			if !result {
				return true ; This cancels the closing of the gui for the close event.
			}
		}
		WinGetPos(&X, &Y, &W, &H, MyGui)
		IniWrite(X, oSettings.File, "Pos", "X")
		IniWrite(Y, oSettings.File, "Pos", "Y")
		IniWrite(W, oSettings.File, "Pos", "W")
		IniWrite(H, oSettings.File, "Pos", "H")

		IniWrite(MyGui.StatusBar, oSettings.File, "Settings", "StatusBar")
		IniWrite(MyGui.Wrap, oSettings.File, "Settings", "Wrap")
		IniWrite(MyGui.FontSize, oSettings.File, "Settings", "FontSize")
		IniWrite(MyGui.FontStyle, oSettings.File, "Settings", "FontStyle")
		IniWrite(MyGui.FontName, oSettings.File, "Settings", "FontName")
		IniWrite(MyGui.FontStyleAlternative, oSettings.File, "Settings", "FontStyleAlternative")

		WinClose(MyGui)
	}

	MenuEditUndo(*) {
		SendMessage(0x0304, , , MainEdit)
	}
	MenuEditCut(*) {
		SendMessage(0x0300, , , MainEdit)
	}
	MenuEditCopy(*) {
		SendMessage(0x0301, , , MainEdit)
	}
	MenuEditPaste(*) {
		SendMessage(0x0302, , , MainEdit)
	}
	MenuEditDelete(*) {
		SendMessage(0x0303, , , MainEdit)
	}
	MenuEditSelectAll(*) {
		SendMessage(0xB1, 0, StrLen(MainEdit.Text), , MainEdit)	;EM_SETSEL := 0xB1 ;select text
	}

	MenuEditReplace(*) {
		gReplace := Gui("+owner" MyGui.Hwnd)

		gReplace.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
		gReplace.Opt("+0x94C80000")
		gReplace.Opt("-Toolwindow")

		gReplace.AddText("x6 y15 w72 h13", "Fi&nd what:")

		ogcEditFindWhat := gReplace.AddEdit("x81 y11 w171 h20", "")
		ogcEditFindWhat.OnEvent("Change", gReplace_ReDraw)
		gReplace.AddText("x6 y42 w72 h13", "Re&place with:")
		ogcEditReplaceWith := gReplace.AddEdit("x81 y39 w171 h20", "")
		ogcCheckBoxMatchCase := gReplace.AddCheckBox("x6 y101 w89 h20", "Match &case")
		ogcCheckBoxWrapAround := gReplace.AddCheckBox("x6 y127 w96 h20 Checked", "Wrap ar&ound")
		ogcButtonFindNext := gReplace.AddButton("x261 y7 w75 h23 Default", "&Find Next")
		ogcButtonFindNext.OnEvent("Click", gReplace_FindNext)
		ogcButtonReplace := gReplace.AddButton("x261 y34 w75 h23", "&Replace")
		ogcButtonReplace.OnEvent("Click", gReplace_Replace)
		ogcButtonReplaceAll := gReplace.AddButton("x261 y62 w75 h23", "Replace &All")
		ogcButtonReplaceAll.OnEvent("Click", gReplace_ReplaceAll)
		ogcButtonCancel := gReplace.AddButton("x261 y89 w75 h23", "Cancel")
		ogcButtonCancel.OnEvent("Click", gReplace_Close)

		if (oSettings.Darkmode) {
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", gReplace.hwnd, "int", 20, "int*", true, "int", 4)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonFindNext.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonReplace.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonReplaceAll.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonCancel.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
		}
		gReplace.Title := "Replace"
		gReplace.OnEvent("Close", gReplace_Close)
		gReplace.OnEvent("Escape", gReplace_Close)
		gReplace_ReDraw(gReplace)

		gReplace.Show("h153 w344")
		Return

		gReplace_ReDraw(*) {
			if (ogcEditFindWhat.Value = "") {
				ogcButtonFindNext.Opt("+Disabled")
				ogcButtonReplace.Opt("+Disabled")
				ogcButtonReplaceAll.Opt("+Disabled")
			} else {
				ogcButtonFindNext.Opt("-Disabled")
				ogcButtonReplace.Opt("-Disabled")
				ogcButtonReplaceAll.Opt("-Disabled")
			}
		}

		gReplace_Find(*) {
			CaseSense := ogcCheckBoxMatchCase.value = 0 ? false : true
			StartPos := EndPos := 0
			DllCall("User32.dll\SendMessage", "Ptr", MainEdit.Hwnd, "UInt", 0x00B0, "UIntP", &StartPos, "UIntP", &EndPos, "Ptr")

			FoundPos := ""
			SearchText := MainEdit.Text
			FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, EndPos + 1)
			if (FoundPos = 0 and ogcCheckBoxWrapAround.Value) {
				FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense)
			}

			if (FoundPos != "" and FoundPos != 0) {
				SendMessage(0xB1, FoundPos - 1, FoundPos + StrLen(ogcEditFindWhat.Value) - 1, , MainEdit)	;EM_SETSEL := 0xB1 ;deselect text
			} else {
				Return 0
			}
			return 1
		}
		gReplace_FindNext(*) {
			if !gReplace_Find(gReplace) {
				msgResult := MsgBox("Cannot find `"" ogcEditFindWhat.Value "`"", , 4160)
			}
		}

		gReplace_Replace(*) {
			SelectedText := EditGetSelectedText(MainEdit)
			ReplacedNumber := 0
			if (ogcEditFindWhat.Value = SelectedText) {
				vText := ogcEditReplaceWith.Value
				DllCall("SendMessage", "UInt", MainEdit.Hwnd, "UInt", 0xC2, "UInt", 0, "Str", &vText)
				ReplacedNumber++
			}

			if (!gReplace_Find(gReplace) and !ReplacedNumber) {
				msgResult := MsgBox("Cannot find `"" ogcEditFindWhat.Value "`"", , 4160)
			}
		}

		gReplace_ReplaceAll(*) {
			if InStr(MainEdit.Text, ogcEditFindWhat.Value) {
				MainEdit.Text := StrReplace(MainEdit.Text, ogcEditFindWhat.Value, ogcEditReplaceWith.Value)
			}
		}

		gReplace_Close(*) {
			gReplace.Destroy()
		}
	}

	MenuEditTimeDate(*) {
		EditPaste(A_Hour ":" A_Min " " A_DD "/" A_MM "/" A_YYYY, MainEdit)
	}

	MenuEditFind(*) {
		gFind := Gui("+owner" MyGui.Hwnd)

		gFind.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
		gFind.Opt("+0x94C80000")
		gFind.Opt("-Toolwindow")
		gFind.AddText("x6 y13 w63 h13", "Fi&nd what:")
		ogcEditFindWhat := gFind.AddEdit("x71 y11 w192 h20", "")
		ogcEditFindWhat.OnEvent("Change", gFind_FindWhat)
		ogcCheckBoxMatchCase := gFind.AddCheckBox("x6 y68 w96 h20", "Match &case")
		ogcCheckBoxWrapAround := gFind.AddCheckBox("x6 y94 w96 h20 Checked", "W&rap around")
		gFind.AddGroupBox("x161 y42 w102 h46", "Direction")
		ogcRadioDirection := gFind.Add("Radio", "x167 y62 w38 h20", "&Up")
		gFind.Add("Radio", "x207 y62 w53 h20 checked", "&Down")
		ogcButtonFindNext := gFind.AddButton("x273 y8 w75 h23 Default", "&Find Next")
		ogcButtonFindNext.OnEvent("Click", gFind_ButtonFindNext)
		ogcButtonCancel := gFind.AddButton("x273 y37 w75 h23", "Cancel")
		ogcButtonCancel.OnEvent("Click", gFind_Close)
		gFind.Title := "Find"
		gFind.OnEvent("Close", gFind_Close)
		gFind.OnEvent("Escape", gFind_Close)
		if (ogcEditFindWhat.Value = "") {
			ogcButtonFindNext.Opt("+Disabled")
		} else {
			ogcButtonFindNext.Opt("-Disabled")
		}

		if (oSettings.Darkmode) {
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", gFind.hwnd, "int", 20, "int*", true, "int", 4)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonFindNext.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonCancel.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
		}

		gFind.Show("h120 w354")
		Return

		gFind_Close(*) {
			gFind.Destroy()
		}
		gFind_ButtonFindNext(*) {

			CaseSense := ogcCheckBoxMatchCase.value = 0 ? false : true
			StartPos := EndPos := 0
			DllCall("User32.dll\SendMessage", "Ptr", MainEdit.HWND, "UInt", 0x00B0, "UIntP", &StartPos, "UIntP", &EndPos, "Ptr")
			if (ogcRadioDirection.Value) {
				Occurence := -1
			} else {
				Occurence := +1
			}

			FoundPos := ""
			SearchText := MainEdit.Text
			if (!ogcRadioDirection.Value) {
				FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, EndPos + 1)
				if (FoundPos = 0 and ogcCheckBoxWrapAround.Value) {
					FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense)
				}
			} else {
				if (StartPos = 0 and ogcCheckBoxWrapAround.Value) {
					FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, -1, -1)
				} else {
					FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, StartPos, -1)
				}
			}

			if (FoundPos != "" and FoundPos != 0) {
				SendMessage(0xB1, FoundPos - 1, FoundPos + StrLen(ogcEditFindWhat.Value) - 1, , MainEdit)	;EM_SETSEL := 0xB1 ;select text
			} else {
				msgResult := MsgBox("Cannot find `"" ogcEditFindWhat.Value "`"", , 4160)
			}

		}
		gFind_FindWhat(*) {
			if (ogcEditFindWhat.Value = "") {
				ogcButtonFindNext.Opt("+Disabled")
			} else {
				ogcButtonFindNext.Opt("-Disabled")
			}
		}
	}

	MenuEditGoTo(*) {
		gGoTo := Gui("+owner" MyGui.Hwnd)
		gGoTo.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
		gGoTo.Opt("+0x94C80000")
		gGoTo.Opt("-Toolwindow")
		gGoTo.AddText("x11 y11 w173 h13", "&Line number:")
		ogcEditLineNumber := gGoTo.AddEdit("x11 y29 w227 h23 +Number", )
		ogcButtonGoTO := gGoTo.AddButton("x83 y63 w75 h23 Default", "Go To")
		ogcButtonGoTO.OnEvent("Click", gFind_ButtonGoTo)
		ogcButtonCancel := gGoTo.AddButton("x164 y63 w75 h23", "Cancel")
		ogcButtonCancel.OnEvent("Click", gGoTo_Close)

		gGoTo.Title := "Go To Line"

		if (oSettings.Darkmode) {
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", gGoTo.hwnd, "int", 20, "int*", true, "int", 4)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonGoTO.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonCancel.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
		}

		gGoTo.Show("h98 w249")
		Return

		gGoTo_Close(*) {
			gGoTo.Destroy()
		}
		gFind_ButtonGoTo(*) {
			LineCount := EditGetLineCount(MainEdit)
			if (ogcEditLineNumber.value > LineCount) {
				MsgBox("The line number is beyond the total number of lines", , 4096)
			} else {
				if (ogcEditLineNumber.value = 1) {
					FoundPos := 0
				} else {
					FoundPos := InStr(MainEdit.Text, "`n", , , ogcEditLineNumber.value - 1)
				}
				SendMessage(0xB1, FoundPos, FoundPos, , MainEdit)

				gGoTo.Destroy()
			}
		}
	}

	MenuFormatFont(*) {
		gFont := Gui("+owner" MyGui.Hwnd)
		MyGui.Opt("+Disabled")	; Disable main window.
		gFont.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
		gFont.Opt("+0x94C80000")
		gFont.Opt("-Toolwindow")
		gFont.AddText("x12 y13 w172", "&Font:")
		ComboBoxText := gFont.AddComboBox("x12 y30 w172 h140 Simple +HScroll", ["Arial", "Arial Black", "Arial Nova", "Bahnschrift", "Calibri", "Calibri Light", "Cambria", "Cambria Math", "Candara", "Comic Sans MS", "Comic Sans MS", "Consolas", "Constantia", "Corbel", "Courier", "Courier New", "Webdings", "Wingdings", "Yu Gothic", "Yu Gothic Ui"])
		ComboBoxText.Choose(MyGui.FontName)
		ComboBoxText.OnEvent("Change", Example_Change)

		gFont.AddText("x200 y13 w130", "Font st&yle:")
		ComboBoxStyle := gFont.AddComboBox("x200 y30 w130 h143 Simple +HScroll", ["Regular", "Italic", "Bold", "Bold italic"])
		ComboBoxStyle.Choose(MyGui.FontStyleAlternative)
		ComboBoxStyle.OnEvent("Change", Example_Change)
		gFont.AddText("x347 y13 w63", "&Size:")
		ComboBoxSize := gFont.AddComboBox("x347 y30 w63 h131 Simple +HScroll", ["8", "9", "10", "11", "12", "14", "16", "18", "20", "22", "24", "26", "28", "36", "48", "72"])

		try{
			FontSizeMap := Map(8, 1, 9, 2, 10, 3, 11, 4, 12, 5, 14, 6, 16, 7, 18, 8, 20, 9, 22, 10, 24, 11, 26, 12, 28, 13, 36, 14, 48, 15, 72, 16)
			ComboBoxSize.Choose(FontSizeMap[MyGui.FontSize])
		}
		Catch{
			ComboBoxSize.text := MyGui.FontSize
		}

		ComboBoxSize.OnEvent("Change", Example_Change)
		gFont.AddGroupBox("x200 y182 w210 h81", "Sample")
		gocTextExample := gFont.AddText("x210 y202 w190 h50 +Center 0x200", "AaBbYyZz")
		gocTextExample.SetFont(MyGui.FontStyle " s" MyGui.FontSize, MyGui.FontName)


		gFont.AddLink("x12 y334 w397 h38", '<a href="ms-settings:fonts">Show more fonts</a>')
		gFont.AddText("x200 y272 w207 h17", "Sc&ript:")
		DropDownListScript := gFont.AddComboBox("x200 y291 w210", ["Western", "Greek", "Turkish", "Baltic", "Central European", "Cyrillic", "Vietnamese"])

		DropDownListScript.Choose("Western")
		ogcMyButtonOK := gFont.AddButton("x247 y403 w79 h26", "OK")
		ogcMyButtonOK.OnEvent("Click", gFont_OK)
		ogcMyButtonCancel := gFont.AddButton("x333 y403 w79 h26", "Cancel")
		ogcMyButtonCancel.OnEvent("Click", gFont_Cancel)
		gFont.OnEvent("Close", gFont_Cancel)
		gFont.Title := "Font"

		if (oSettings.Darkmode) {
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", gFont.hwnd, "int", 20, "int*", true, "int", 4)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcMyButtonOK.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcMyButtonCancel.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
		}

		gFont.Show("h443 w429")
		Return
		Example_Change(*) {
			Style := ComboBoxStyle.Text = "Regular" ? "Norm" : ComboBoxStyle.Text = "Bold" ? "norm Bold" : ComboBoxStyle.Text = "Italic" ? "norm Italic" : ComboBoxStyle.Text = "Bold italic" ? "Bold italic" : ""
			gocTextExample.SetFont(Style " s" ComboBoxSize.Text, ComboBoxText.Text)
		}
		gFont_OK(*) {
			MyGui.FontStyle := ComboBoxStyle.Text = "Regular" ? "Norm" : ComboBoxStyle.Text = "Bold" ? "norm Bold" : ComboBoxStyle.Text = "Italic" ? "norm Italic" : ComboBoxStyle.Text = "Bold italic" ? "Bold italic" : ""
			MyGui.FontStyleAlternative := ComboBoxStyle.Text
			MyGui.FontName := ComboBoxText.Text
			MyGui.FontSize := ComboBoxSize.Text
			UpdateFont()
			MyGui.Opt("-Disabled")
			gFont.Destroy()
		}
		gFont_Cancel(*) {
			MyGui.Opt("-Disabled")
			gFont.Destroy()
		}
	}

	MenuFormatWordWrap(*) {
		TextMainEdit := MainEdit.Text
		MainEdit.GetPos(,,&wControl,&hControl)
		FormatMenu.ToggleCheck("Word Wrap")
		MyGui.Wrap := !MyGui.Wrap
		SendMessage(0xB, 0, 0, , MyGui.hwnd) ; Turn OFF redrawing
		DllCall("DestroyWindow", "UInt", MainEdit.Hwnd)
		Sleep(30)
		if (MyGui.Wrap=true){
			MainEdit := MyGui.AddEdit("x0 y0 +Wrap +Multi -HScroll +VScroll +0x100 +0x10000000 WantTab -E0x200 -border W" wControl " H" hControl, TextMainEdit)
		}else{
			MainEdit := MyGui.AddEdit("x0 y0 -Wrap +Multi +HScroll +VScroll +0x100 +0x10000000 WantTab -E0x200 -border W" wControl " H" hControl, TextMainEdit)
		}
		if (oSettings.Darkmode) {
			MainEdit.Opt("Background0x383838 cWhite")
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MainEdit.hwnd, "int", 20, "int*", true, "int", 4)
		}
		SendMessage(0xB, 1, 0, , MyGui.hwnd) ; Turn ON redrawing

		MainEdit.OnEvent("Change", MainEdit_Change)
		MainEdit.OnEvent("Focus", MainEdit_Focus)
		MainEdit.OnEvent("LoseFocus", MainEdit_Focus)
		UpdateFont()

		MyGui.MainEdit := MainEdit
	}

	MenuViewZoomIn(*) {
		MyGui.FontSize := MyGui.FontSize + 1
		if (MyGui.FontSize > 71) {
			MyGui.FontSize := 71
		}
		MainEdit.SetFont("s" MyGui.FontSize)
		MyGui.SB.SetText(" " (MyGui.FontSize - 1) * 10 "%", 3)
		sleep(20)
	}

	MenuViewZoomOut(*) {
		MyGui.FontSize := MyGui.FontSize - 1
		if (MyGui.FontSize = 1) {
			MyGui.FontSize := 2
		}
		MainEdit.SetFont("s" MyGui.FontSize)
		MyGui.SB.SetText(" " (MyGui.FontSize - 1) * 10 "%", 3)
		sleep(20)
	}

	MenuViewRestoreDefaultZoom(*) {
		MyGui.FontSize := 11
		MainEdit.SetFont("s" MyGui.FontSize)
		if (MyGui.Statusbar){
			MyGui.SB.SetText(" " (MyGui.FontSize - 1) * 10 "%", 3)
		}
	}

	MenuViewStatusbar(*) {
		MyGui.Statusbar := !MyGui.Statusbar
		MyGui.GetClientPos(, , &Width, &Height)
		if (!MyGui.Statusbar){
			DllCall("ShowWindow", "UInt", MyGui.SB.hwnd, "Int", "0")
		} else {
			DllCall("ShowWindow", "UInt", MyGui.SB.hwnd, "Int", "1")
		}

		MainEdit.Move(, , , Height - MyGui.Statusbar * 23)
		ViewMenu.ToggleCheck("&Statusbar")
	}

	MenuHelpAbout(*) {
		gAbout := Gui("+owner" MyGui.Hwnd)	; Make the main window the owner of the "about box".
		MyGui.Opt("+Disabled")	; Disable main window.
		gAbout.AddText(, "Exercise to simulate working of AHKpad.")
		ogcMyButtonOK := gAbout.AddButton("Default x375 y358 w75 h23", "OK")
		ogcMyButtonOK.OnEvent("Click", About_Close)
		gAbout.OnEvent("Close", About_Close)
		gAbout.OnEvent("Escape", About_Close)
		gAbout.title := "About AHKpad"
		if (oSettings.Darkmode) {
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", gAbout.hwnd, "int", 20, "int*", true, "int", 4)
			DllCall("uxtheme\SetWindowTheme", "ptr", ogcMyButtonOK.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
		}
		gAbout.Show("h395 w462")

		About_Close(*) {
			MyGui.Opt("-Disabled")	; Re-enable the main window (must be done prior to the next step).
			gAbout.Destroy()	; Destroy the about box.
		}
	}

	MainEdit_Change(*) {
		if !(MyGui.Title ~= "^\*") {
			MyGui.Title := "*" MyGui.Title
			FileMenu.Enable("4&")	; Gray out &Save.
			EditMenu.Enable("&Undo`tCtrl+Z")
		} else if (MyGui.FilePath = "" and MainEdit.text = ""){
			MyGui.Title := StrReplace(MyGui.Title, "*")
		}
		try{
			CurrentCol := EditGetCurrentCol(MainEdit)
			CurrentLine := EditGetCurrentLine(MainEdit)
			if (MyGui.Statusbar){
				MyGui.SB.SetText(" Ln " CurrentLine ",  Col " CurrentCol, 2)
				MyGui.SB.Redraw()
			}
		}

	}

	MainEdit_Focus(*) {
		try{
			CurrentCol := EditGetCurrentCol(MainEdit)
			CurrentLine := EditGetCurrentLine(MainEdit)
			if (MyGui.Statusbar){
				MyGui.SB.SetText(" Ln " CurrentLine ",  Col " CurrentCol, 2)
				MyGui.SB.Redraw()
			}
		}

	}

	GuiCheckChanges() {
		Result := true
		if InStr(MyGui.Title,"*"){
			Result := false
			gSC := Gui("+owner" MyGui.Hwnd)
			gSC.OnEvent("Close", gSC_Close)
			gSC.OnEvent("Escape", gSC_Close)
			gSC.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
			gSC.Opt("+0x94C80000")
			gSC.Opt("-Toolwindow")
			SaveDescrip := IsSet(CurrentFileName) ? " " CurrentFileName "?`n" : "Untitled?`n"
			gSC.SetFont("s12 cPurple W200")
			gSC.AddText("x0 y0 w354 BackgroundWhite Wrap ", "`n  Do you want to save changes to " SaveDescrip "")
			gSC.SetFont("s10 cBlack W400")
			ogcButtonSave := gSC.AddButton("Default x92 y+10 w72 h23", "&Save")
			ogcButtonSave.OnEvent("Click", gSC_Save)

			ogcButtonDontSave := gSC.AddButton("x+6 yp w92 h23", "&Don't Save")
			ogcButtonDontSave.OnEvent("Click", gSC_DontSave)
			ogcButtonCancel := gSC.AddButton("x+6 yp w72 h23", "&Cancel")
			ogcButtonCancel.OnEvent("Click", gSC_Cancel)

			gSC.Title := "Notepad"
			if (oSettings.Darkmode) {
				DllCall("dwmapi\DwmSetWindowAttribute", "ptr", gSC.hwnd, "int", 20, "int*", true, "int", 4)
				DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonSave.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
				DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonDontSave.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
				DllCall("uxtheme\SetWindowTheme", "ptr", ogcButtonCancel.hwnd, "str", "DarkMode_Explorer", "ptr", 0)
			}

			gSC.Show(" w350")
			WinWaitClose(gSC)
		}
		Return result

		gSC_Cancel(*){
			gSC.Destroy()
			Result := false
			Return
		}
		gSC_Save(*){
			if MenuFileSave() {
				Result := true
			}
			gSC.Destroy()
			Return
		}

		gSC_DontSave(*) {
			Result := true
			gSC.Destroy()
			Return
		}

		gSC_Close(*){
			MyGui.Opt("-Disabled")	; Re-enable the main window (must be done prior to the next step).
			Result := false
			gSC.Destroy()	; Destroy the about box.
		}
	}

	saveContent(FileName) {
		if !InStr(FileName, ".") {
			FileName := FileName ".txt"
		}
		try{
			if FileExist(FileName)
				FileDelete(FileName)
			FileAppend(MainEdit.Value, FileName)	; Save the contents to the file.
			MyGui.FileName := FileName
		} catch {
			MsgBox("The attempt to overwrite '" FileName "' failed.")
			return
		}
		; Upon success, Show file name in title bar (in case we were called by MenuFileSaveAs):
		FilePath := FileName
		MyGui.Title := StrReplace(MyGui.Title,"*")
		FileMenu.Disable("4&")	; Disable &Save.
		SplitPath(FileName, &OutFileName)
		MyGui.Title := OutFileName " - AHKpad"	; Show file name in title bar.
		return FileName
	}

	readContent(FileName) {
		try
			FileContent := FileRead(FileName)	; Read the file's contents into the variable.
		catch{
			MsgBox("Could not open '" FileName "'.")
			return
		}
		MainEdit.Value := FileContent	; Put the text into the control.
		FilePath := FileName
		FileMenu.Disable("4&")	; Disable &Save.
		SplitPath(FileName, &OutFileName)
		MyGui.Title := OutFileName " - AHKpad"	; Show file name in title bar.
		return FileName
	}

	Gui_DropFiles(thisGui, Ctrl, FileArray, * ) {	; Support drag & drop.
		CurrentFileName := readContent(FileArray[1])	; Read the first file only (in case there's more than one).
	}

	Gui_Size(thisGui, MinMax, Width, Height) {
		if MinMax = -1	; The window has been minimized. No action needed.
			return
		; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
		if (MyGui.Statusbar){
			MyGui.SB.SetParts(Max(Width - 430,0), Max(Min(140,Width-430+140),0), Max(Min(50,Width-430+140+50),0), Max(Min(120,Width-430+140+50+120),0), 120)
		}

		MainEdit.Move(, , Width, Height - MyGui.Statusbar * 23)
	}

	WM_UpdateGui(wParam, lParam, Msg, Hwnd) {
		Global
		currControl := GuiCtrlFromHwnd(Hwnd)

		thisGui := ""
		if (currControl != "") {
			thisGui := currControl.Gui
		} else {
			thisGui := GuiFromHwnd(Hwnd)
		}
		if (thisGui != "") {
			try {
				CurrentCol := EditGetCurrentCol(thisGui.MainEdit)
				CurrentLine := EditGetCurrentLine(thisGui.MainEdit)
				if (thisGui.Has("Statusbar") and thisGui.StatusBar){
					thisGui.SB.SetText(" Ln " CurrentLine ",  Col " CurrentCol, 2)
					thisGui.SB.Redraw()
				}
			}
		}
	}

	WM_MenuStart(hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime) {
		Global
		currControl := GuiCtrlFromHwnd(Hwnd)

		thisGui := ""
		if (currControl != "") {
			thisGui := currControl.Gui
		} else {
			thisGui := GuiFromHwnd(Hwnd)
		}
		if (thisGui != "") {
			try {
				CurrentCol := EditGetCurrentCol(thisGui.MainEdit)
				CurrentLine := EditGetCurrentLine(thisGui.MainEdit)
				Selected := EditGetSelectedText(thisGui.MainEdit)
				; thisGui.EditMenu.Disable("&Undo`tCtrl+Z")
				if (Selected = ""){
					thisGui.EditMenu.Disable("Cu&t`tCtrl+X")
					thisGui.EditMenu.Disable("&Copy`tCtrl+C")
					thisGui.EditMenu.Disable("De&lete`tDel")
				}
				else {
					thisGui.EditMenu.Enable("Cu&t`tCtrl+X")
					thisGui.EditMenu.Enable("&Copy`tCtrl+C")
					thisGui.EditMenu.Enable("De&lete`tDel")
				}
				if (A_Clipboard=""){
					thisGui.EditMenu.Disable("&Paste`tCtrl+P")
				} else {
					thisGui.EditMenu.Enable("&Paste`tCtrl+P")
				}
				if (thisGui.MainEdit.text=""){
					thisGui.EditMenu.Disable("&Find`tCtrl+F")
					thisGui.EditMenu.Disable("&Find Next`tF3")
					thisGui.EditMenu.Disable("Find Pre&vious`tShift+F3")
					thisGui.EditMenu.Disable("&Go To`tCtrl+G")
				} else {
					thisGui.EditMenu.Enable("&Find`tCtrl+F")
					thisGui.EditMenu.Enable("&Find Next`tF3")
					thisGui.EditMenu.Enable("Find Pre&vious`tShift+F3")
				}
				if (!thisGui.Wrap){
					thisGui.EditMenu.Enable("&Go To`tCtrl+G")
				} else {
					thisGui.EditMenu.Disable("&Go To`tCtrl+G")
				}
			}
		}
	}
}

SkinForm(Param1 := "Apply", DLL := "", SkinName := "") {
	if (Param1 = "Apply") {
		DllCall("LoadLibrary", "Str", DLL)
		DllCall(DLL . "\USkinInit", "Int", 0, "Int", 0, "AStr", SkinName)
	} else if (Param1 = 0) {
		DllCall(DLL . "\USkinExit")
	}
}

CallBack_ES_MENUSTART(hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime){
	;Enter code here to trigger on the message
	currControl := GuiCtrlFromHwnd(Hwnd)
	thisGui := ""
	if (currControl != "") {
		thisGui := currControl.Gui
	} else {
		thisGui := GuiFromHwnd(Hwnd)
	}
	if (thisGui != "") {
		try {
			CurrentCol := EditGetCurrentCol(thisGui.MainEdit)
			CurrentLine := EditGetCurrentLine(thisGui.MainEdit)
			Selected := EditGetSelectedText(thisGui.MainEdit)
			; thisGui.EditMenu.Disable("&Undo`tCtrl+Z")
			if (Selected = ""){
				thisGui.EditMenu.Disable("Cu&t`tCtrl+X")
				thisGui.EditMenu.Disable("&Copy`tCtrl+C")
				thisGui.EditMenu.Disable("De&lete`tDel")
			}
			else {
				thisGui.EditMenu.Enable("Cu&t`tCtrl+X")
				thisGui.EditMenu.Enable("&Copy`tCtrl+C")
				thisGui.EditMenu.Enable("De&lete`tDel")
			}
			if (A_Clipboard=""){
				thisGui.EditMenu.Disable("&Paste`tCtrl+P")
			} else {
				thisGui.EditMenu.Enable("&Paste`tCtrl+P")
			}
			if (thisGui.MainEdit.text=""){
				thisGui.EditMenu.Disable("&Find`tCtrl+F")
				thisGui.EditMenu.Disable("&Find Next`tF3")
				thisGui.EditMenu.Disable("Find Pre&vious`tShift+F3")
				thisGui.EditMenu.Disable("&Go To`tCtrl+G")
			} else {
				thisGui.EditMenu.Enable("&Find`tCtrl+F")
				thisGui.EditMenu.Enable("&Find Next`tF3")
				thisGui.EditMenu.Enable("Find Pre&vious`tShift+F3")
			}
			if (!thisGui.Wrap){
				thisGui.EditMenu.Enable("&Go To`tCtrl+G")
			} else {
				thisGui.EditMenu.Disable("&Go To`tCtrl+G")
			}
		}
	}
}