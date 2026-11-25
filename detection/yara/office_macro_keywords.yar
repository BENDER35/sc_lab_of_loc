/*
  Educational YARA rule: flags common VBA macro keywords often seen in suspicious documents.
  This is NOT proof of malice. Use only on files you own or are authorized to analyze.
*/
rule Office_Macro_Suspicious_Keywords
{
    meta:
        description = "Educational indicator: suspicious VBA macro keywords"
        author = "SC Lab of LOC"
        date = "2026-11-25"
        scope = "defensive education"

    strings:
        $a1 = "AutoOpen" nocase ascii wide
        $a2 = "Document_Open" nocase ascii wide
        $a3 = "Workbook_Open" nocase ascii wide
        $a4 = "Shell(" nocase ascii wide
        $a5 = "CreateObject(" nocase ascii wide
        $a6 = "WScript.Shell" nocase ascii wide
        $a7 = "PowerShell" nocase ascii wide
        $a8 = "cmd.exe" nocase ascii wide
        $a9 = "Base64" nocase ascii wide

    condition:
        uint32(0) == 0xE011CFD0 or // OLE Compound File header
        (2 of ($a*))
}
