#Requires -Version 5.1

<#
.SYNOPSIS
    Checks translation key consistency across all language files and identifies unused/missing keys.

.DESCRIPTION
    This script performs comprehensive analysis of Hugo i18n translation files:
    - Compares all language files to ensure they have the same translation keys
    - Scans Hugo templates and content to find which translation keys are actually used
    - Identifies missing keys in translation files
    - Identifies unused keys that could potentially be removed
    - Generates a detailed report with recommendations

.PARAMETER SitePath
    Path to the Hugo site directory. Defaults to '../site' relative to script location.

.PARAMETER OutputFormat
    Output format for the report. Options: 'Console', 'JSON', 'CSV', 'All'. Default is 'Console'.

.PARAMETER ExportPath
    Path to export detailed reports when using JSON or CSV output formats.

.EXAMPLE
    .\Check-TranslationKeys.ps1

.EXAMPLE
    .\Check-TranslationKeys.ps1 -SitePath "C:\MyHugoSite\site" -OutputFormat "All" -ExportPath "C:\Reports"

.NOTES
    Author: Generated for Open Guide to Kanban project
    Requires: PowerShell 5.1 or higher
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SitePath = (Join-Path $PSScriptRoot ".." "site"),
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Console', 'JSON', 'CSV', 'All')]
    [string]$OutputFormat = 'Console',
    
    [Parameter(Mandatory = $false)]
    [string]$ExportPath = $PSScriptRoot
)

# Ensure the site path exists
if (-not (Test-Path $SitePath)) {
    Write-Error "Site path not found: $SitePath"
    exit 1
}

$I18nPath = Join-Path $SitePath "i18n"
$LayoutsPath = Join-Path $SitePath "layouts"
$ContentPath = Join-Path $SitePath "content"

# Ensure required directories exist
@($I18nPath, $LayoutsPath, $ContentPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        Write-Error "Required directory not found: $_"
        exit 1
    }
}

function Get-TranslationFiles {
    return Get-ChildItem -Path $I18nPath -Filter "*.yaml" -File
}

function Parse-TranslationFile {
    param([string]$FilePath)
    
    $keys = @()
    $content = Get-Content -Path $FilePath -Raw
    
    # Parse YAML translation entries
    $lines = $content -split "`n"
    foreach ($line in $lines) {
        if ($line -match '^\s*-\s*id:\s*(.+)$') {
            $keys += $matches[1].Trim()
        }
    }
    
    return $keys
}

function Find-UsedTranslationKeys {
    param(
        [string[]]$SearchPaths
    )
    
    $usedKeys = @{}
    # More precise patterns that specifically look for Hugo translation functions
    $searchPatterns = @(
        '\{\{\s*i18n\s+"([^"]+)"\s*\}\}',           # {{ i18n "key" }}
        "\{\{\s*i18n\s+'([^']+)'\s*\}\}",           # {{ i18n 'key' }}
        '\{\{\s*T\s+"([^"]+)"\s*\}\}',              # {{ T "key" }}
        "\{\{\s*T\s+'([^']+)'\s*\}\}",              # {{ T 'key' }}
        '\{\{\s*i18n\s+"([^"]+)"\s*[|\s]',          # {{ i18n "key" | or {{ i18n "key" with space
        "\{\{\s*i18n\s+'([^']+)'\s*[|\s]",          # {{ i18n 'key' | or {{ i18n 'key' with space
        '\{\{\s*T\s+"([^"]+)"\s*[|\s]',             # {{ T "key" | or {{ T "key" with space
        "\{\{\s*T\s+'([^']+)'\s*[|\s]",             # {{ T 'key' | or {{ T 'key' with space
        '\(\s*i18n\s+"([^"]+)"\s*\)',               # (i18n "key") - function calls
        "\(\s*i18n\s+'([^']+)'\s*\)",               # (i18n 'key') - function calls
        'i18n\s+"([a-zA-Z_][a-zA-Z0-9_]*)"',        # i18n "valid_key_format" - more restrictive
        "i18n\s+'([a-zA-Z_][a-zA-Z0-9_]*)'",        # i18n 'valid_key_format' - more restrictive
        'T\s+"([a-zA-Z_][a-zA-Z0-9_]*)"',           # T "valid_key_format" - more restrictive  
        "T\s+'([a-zA-Z_][a-zA-Z0-9_]*)'"            # T 'valid_key_format' - more restrictive
    )
    
    foreach ($searchPath in $SearchPaths) {
        if (Test-Path $searchPath) {
            # Only scan Hugo template files and markdown files, exclude data/config files
            $files = Get-ChildItem -Path $searchPath -Recurse -Include @("*.html", "*.md") -File | 
            Where-Object { 
                $_.FullName -notlike "*\data\*" -and 
                $_.FullName -notlike "*\i18n\*" -and
                $_.FullName -notlike "*hugo*.yaml" -and
                $_.FullName -notlike "*config*" -and
                $_.FullName -notlike "*staticwebapp*" 
            }
            
            foreach ($file in $files) {
                try {
                    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
                    if ($content) {
                        foreach ($pattern in $searchPatterns) {
                            $regexMatches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                            foreach ($match in $regexMatches) {
                                $key = $match.Groups[1].Value.Trim()
                                
                                # Filter out obvious non-translation keys
                                if ($key -match '^[a-zA-Z_][a-zA-Z0-9_]*$' -and # Valid identifier format
                                    $key.Length -gt 1 -and # At least 2 characters
                                    $key -notmatch '^\d' -and # Doesn't start with number
                                    $key -notmatch '^https?://' -and # Not a URL
                                    $key -notmatch '^\d{4}-\d{2}-\d{2}' -and # Not a date
                                    $key -notmatch '^#[0-9a-fA-F]+$' -and # Not a color code
                                    $key -notlike "*.*" -and # No dots (likely file extensions)
                                    $key.Length -lt 50) {
                                    # Reasonable length
                                    
                                    if (-not $usedKeys.ContainsKey($key)) {
                                        $usedKeys[$key] = @()
                                    }
                                    $usedKeys[$key] += $file.FullName
                                }
                            }
                        }
                    }
                }
                catch {
                    Write-Warning "Could not read file: $($file.FullName) - $($_.Exception.Message)"
                }
            }
        }
    }
    
    return $usedKeys
}

function Compare-TranslationFiles {
    param([hashtable]$TranslationData)
    
    $allKeys = @()
    $TranslationData.Values | ForEach-Object { $allKeys += $_ }
    $uniqueKeys = $allKeys | Sort-Object | Get-Unique
    
    $comparison = @{}
    
    foreach ($language in $TranslationData.Keys) {
        $comparison[$language] = @{
            TotalKeys   = $TranslationData[$language].Count
            MissingKeys = @()
            ExtraKeys   = @()
        }
        
        # Find missing keys
        foreach ($key in $uniqueKeys) {
            if ($key -notin $TranslationData[$language]) {
                $comparison[$language].MissingKeys += $key
            }
        }
        
        # Find extra keys (keys in this language but not in others)
        foreach ($key in $TranslationData[$language]) {
            $foundInOthers = $false
            foreach ($otherLang in $TranslationData.Keys) {
                if ($otherLang -ne $language -and $key -in $TranslationData[$otherLang]) {
                    $foundInOthers = $true
                    break
                }
            }
            if (-not $foundInOthers) {
                $comparison[$language].ExtraKeys += $key
            }
        }
    }
    
    return $comparison
}

function Generate-Report {
    param(
        [hashtable]$TranslationData,
        [hashtable]$ComparisonData,
        [hashtable]$UsedKeys,
        [string]$Format,
        [string]$ExportPath
    )
    
    $report = @{
        Summary       = @{
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            TotalLanguages  = $TranslationData.Count
            Languages       = @($TranslationData.Keys | Sort-Object)
            TotalUniqueKeys = @()
            TotalUsedKeys   = $UsedKeys.Count
        }
        Languages     = @{}
        UsageAnalysis = @{
            UsedKeys                = @()
            UnusedKeys              = @()
            MissingFromAllLanguages = @()
        }
    }
    
    # Calculate total unique keys
    $allKeys = @()
    $TranslationData.Values | ForEach-Object { $allKeys += $_ }
    $uniqueKeys = $allKeys | Sort-Object | Get-Unique
    $report.Summary.TotalUniqueKeys = $uniqueKeys.Count
    
    # Language-specific analysis
    foreach ($language in $TranslationData.Keys) {
        $report.Languages[$language] = @{
            TotalKeys    = $ComparisonData[$language].TotalKeys
            MissingKeys  = $ComparisonData[$language].MissingKeys
            ExtraKeys    = $ComparisonData[$language].ExtraKeys
            MissingCount = $ComparisonData[$language].MissingKeys.Count
            ExtraCount   = $ComparisonData[$language].ExtraKeys.Count
            IsComplete   = ($ComparisonData[$language].MissingKeys.Count -eq 0 -and $ComparisonData[$language].ExtraKeys.Count -eq 0)
        }
    }
    
    # Usage analysis
    $usedKeysList = @($UsedKeys.Keys)
    $unusedKeys = @()
    $unusedEnglishKeys = @()
    
    # Get English translation keys for specific analysis
    $englishKeys = if ($TranslationData.ContainsKey('en')) { $TranslationData['en'] } else { @() }
    
    foreach ($key in $uniqueKeys) {
        if ($key -in $usedKeysList) {
            $report.UsageAnalysis.UsedKeys += @{
                Key         = $key
                UsedInFiles = $UsedKeys[$key]
                FileCount   = $UsedKeys[$key].Count
            }
        }
        else {
            $unusedKeys += $key
            # Check if this unused key is specifically from English
            if ($key -in $englishKeys) {
                $unusedEnglishKeys += $key
            }
        }
    }
    
    $report.UsageAnalysis.UnusedKeys = $unusedKeys
    $report.UsageAnalysis.UnusedEnglishKeys = $unusedEnglishKeys
    
    # Keys used but missing from all translation files
    foreach ($usedKey in $usedKeysList) {
        $foundInAnyLanguage = $false
        foreach ($language in $TranslationData.Keys) {
            if ($usedKey -in $TranslationData[$language]) {
                $foundInAnyLanguage = $true
                break
            }
        }
        if (-not $foundInAnyLanguage) {
            $report.UsageAnalysis.MissingFromAllLanguages += $usedKey
        }
    }
    
    # Output based on format
    switch ($Format) {
        'Console' { 
            Write-ConsoleReport -Report $report 
        }
        'JSON' { 
            $jsonPath = Join-Path $ExportPath "translation-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
            $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
            Write-Host "JSON report exported to: $jsonPath" -ForegroundColor Green
        }
        'CSV' { 
            Export-CsvReports -Report $report -ExportPath $ExportPath 
        }
        'All' { 
            Write-ConsoleReport -Report $report
            
            $jsonPath = Join-Path $ExportPath "translation-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
            $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
            Write-Host "JSON report exported to: $jsonPath" -ForegroundColor Green
            
            Export-CsvReports -Report $report -ExportPath $ExportPath
        }
    }
}

function Write-ConsoleReport {
    param([hashtable]$Report)
    
    Write-Host "`n" + "="*80 -ForegroundColor Cyan
    Write-Host "TRANSLATION KEY ANALYSIS REPORT" -ForegroundColor Cyan
    Write-Host "="*80 -ForegroundColor Cyan
    Write-Host "Generated: $($Report.Summary.Timestamp)" -ForegroundColor Gray
    
    # Summary
    Write-Host "`nSUMMARY:" -ForegroundColor Yellow
    Write-Host "  Total Languages: $($Report.Summary.TotalLanguages)"
    Write-Host "  Languages: $($Report.Summary.Languages -join ', ')"
    Write-Host "  Total Unique Translation Keys: $($Report.Summary.TotalUniqueKeys)"
    Write-Host "  Total Used Keys Found: $($Report.Summary.TotalUsedKeys)"
    
    # Language Status
    Write-Host "`nLANGUAGE STATUS:" -ForegroundColor Yellow
    foreach ($language in $Report.Summary.Languages) {
        $langData = $Report.Languages[$language]
        $status = if ($langData.IsComplete) { "✓ COMPLETE" } else { "⚠ ISSUES" }
        $statusColor = if ($langData.IsComplete) { "Green" } else { "Yellow" }
        
        Write-Host "  $language " -NoNewline
        Write-Host "$status" -ForegroundColor $statusColor
        Write-Host "    Total Keys: $($langData.TotalKeys)"
        
        if ($langData.MissingCount -gt 0) {
            Write-Host "    Missing Keys: $($langData.MissingCount)" -ForegroundColor Red
            $langData.MissingKeys | ForEach-Object { Write-Host "      - $_" -ForegroundColor Red }
        }
        
        if ($langData.ExtraCount -gt 0) {
            Write-Host "    Extra Keys: $($langData.ExtraCount)" -ForegroundColor Magenta
            $langData.ExtraKeys | ForEach-Object { Write-Host "      + $_" -ForegroundColor Magenta }
        }
        Write-Host ""
    }
    
    # Usage Analysis
    Write-Host "USAGE ANALYSIS:" -ForegroundColor Yellow
    Write-Host "  Used Keys: $($Report.UsageAnalysis.UsedKeys.Count)"
    Write-Host "  Unused Keys: $($Report.UsageAnalysis.UnusedKeys.Count)"
    
    if ($Report.UsageAnalysis.UnusedEnglishKeys.Count -gt 0) {
        Write-Host "  Unused English Keys: $($Report.UsageAnalysis.UnusedEnglishKeys.Count)" -ForegroundColor Magenta
    }

    if ($Report.UsageAnalysis.MissingFromAllLanguages.Count -gt 0) {
        Write-Host "`n  🚨 CRITICAL: Keys used in templates but missing from ALL translation files:" -ForegroundColor Red
        $Report.UsageAnalysis.MissingFromAllLanguages | ForEach-Object {
            Write-Host "    - $_" -ForegroundColor Red
        }
    }
    
    if ($Report.UsageAnalysis.UnusedEnglishKeys.Count -gt 0) {
        Write-Host "`n  🧹 UNUSED ENGLISH KEYS (en.yaml) - Consider removing:" -ForegroundColor Magenta
        $Report.UsageAnalysis.UnusedEnglishKeys | ForEach-Object {
            Write-Host "    - $_" -ForegroundColor Magenta
        }
        if ($Report.UsageAnalysis.UnusedEnglishKeys.Count -gt 20) {
            Write-Host "`n    💡 TIP: $($Report.UsageAnalysis.UnusedEnglishKeys.Count) unused English keys found. Consider exporting to CSV for detailed review." -ForegroundColor Yellow
        }
    }
    
    if ($Report.UsageAnalysis.UnusedKeys.Count -gt $Report.UsageAnalysis.UnusedEnglishKeys.Count) {
        $otherUnusedCount = $Report.UsageAnalysis.UnusedKeys.Count - $Report.UsageAnalysis.UnusedEnglishKeys.Count
        Write-Host "`n  📋 Other potentially unused keys (from all languages): $otherUnusedCount" -ForegroundColor Gray
        $Report.UsageAnalysis.UnusedKeys | Where-Object { $_ -notin $Report.UsageAnalysis.UnusedEnglishKeys } | Select-Object -First 5 | ForEach-Object {
            Write-Host "    - $_" -ForegroundColor Gray
        }
        if ($otherUnusedCount -gt 5) {
            Write-Host "    ... and $($otherUnusedCount - 5) more (export to CSV for full list)" -ForegroundColor Gray
        }
    }
    
    # Recommendations
    Write-Host "`nRECOMMENDATIONS:" -ForegroundColor Yellow
    
    $hasIssues = $false
    foreach ($language in $Report.Summary.Languages) {
        $langData = $Report.Languages[$language]
        if (-not $langData.IsComplete) {
            $hasIssues = $true
            break
        }
    }
    
    if ($hasIssues) {
        Write-Host "  1. ⚠ Fix missing/extra keys in language files" -ForegroundColor Yellow
    }
    else {
        Write-Host "  1. ✓ All language files are synchronized" -ForegroundColor Green
    }
    
    if ($Report.UsageAnalysis.MissingFromAllLanguages.Count -gt 0) {
        Write-Host "  2. 🚨 Add missing translation keys used in templates" -ForegroundColor Red
    }
    else {
        Write-Host "  2. ✓ All used keys are present in translation files" -ForegroundColor Green
    }
    
    if ($Report.UsageAnalysis.UnusedEnglishKeys.Count -gt 0) {
        Write-Host "  3. 🧹 Consider removing $($Report.UsageAnalysis.UnusedEnglishKeys.Count) unused English keys" -ForegroundColor Magenta
    }
    else {
        Write-Host "  3. ✓ No unused English keys detected" -ForegroundColor Green
    }
    
    if ($Report.UsageAnalysis.UnusedKeys.Count -gt $Report.UsageAnalysis.UnusedEnglishKeys.Count) {
        $otherUnusedCount = $Report.UsageAnalysis.UnusedKeys.Count - $Report.UsageAnalysis.UnusedEnglishKeys.Count
        Write-Host "  4. 📋 Review $otherUnusedCount other potentially unused keys" -ForegroundColor Gray
    }
    
    Write-Host "`n💡 TIP: Use -OutputFormat 'CSV' or 'All' to export detailed lists for easier review" -ForegroundColor Cyan
    
    Write-Host "`n" + "="*80 -ForegroundColor Cyan
}

function Export-CsvReports {
    param(
        [hashtable]$Report,
        [string]$ExportPath
    )
    
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    
    # Language comparison CSV
    $languageData = @()
    foreach ($language in $Report.Summary.Languages) {
        $langData = $Report.Languages[$language]
        $languageData += [PSCustomObject]@{
            Language     = $language
            TotalKeys    = $langData.TotalKeys
            MissingCount = $langData.MissingCount
            ExtraCount   = $langData.ExtraCount
            IsComplete   = $langData.IsComplete
            MissingKeys  = ($langData.MissingKeys -join '; ')
            ExtraKeys    = ($langData.ExtraKeys -join '; ')
        }
    }
    
    $langCsvPath = Join-Path $ExportPath "translation-languages-$timestamp.csv"
    $languageData | Export-Csv -Path $langCsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Language comparison CSV exported to: $langCsvPath" -ForegroundColor Green
    
    # Usage analysis CSV
    $usageData = @()
    foreach ($usedKey in $Report.UsageAnalysis.UsedKeys) {
        $usageData += [PSCustomObject]@{
            TranslationKey = $usedKey.Key
            Status         = 'Used'
            FileCount      = $usedKey.FileCount
            UsedInFiles    = ($usedKey.UsedInFiles -join '; ')
            IsEnglishKey   = 'N/A'
        }
    }
    
    foreach ($unusedKey in $Report.UsageAnalysis.UnusedEnglishKeys) {
        $usageData += [PSCustomObject]@{
            TranslationKey = $unusedKey
            Status         = 'Unused (English)'
            FileCount      = 0
            UsedInFiles    = ''
            IsEnglishKey   = 'Yes'
        }
    }
    
    foreach ($unusedKey in $Report.UsageAnalysis.UnusedKeys) {
        if ($unusedKey -notin $Report.UsageAnalysis.UnusedEnglishKeys) {
            $usageData += [PSCustomObject]@{
                TranslationKey = $unusedKey
                Status         = 'Unused (Other)'
                FileCount      = 0
                UsedInFiles    = ''
                IsEnglishKey   = 'No'
            }
        }
    }
    
    foreach ($missingKey in $Report.UsageAnalysis.MissingFromAllLanguages) {
        $usageData += [PSCustomObject]@{
            TranslationKey = $missingKey
            Status         = 'Missing'
            FileCount      = 'N/A'
            UsedInFiles    = 'Used but not defined'
            IsEnglishKey   = 'N/A'
        }
    }
    
    $usageCsvPath = Join-Path $ExportPath "translation-usage-$timestamp.csv"
    $usageData | Export-Csv -Path $usageCsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Usage analysis CSV exported to: $usageCsvPath" -ForegroundColor Green
}

# Main execution
try {
    Write-Host "Analyzing translation files..." -ForegroundColor Cyan
    
    # Get all translation files
    $translationFiles = Get-TranslationFiles
    if ($translationFiles.Count -eq 0) {
        Write-Error "No translation files found in $I18nPath"
        exit 1
    }
    
    Write-Host "Found $($translationFiles.Count) translation file(s): $($translationFiles.BaseName -join ', ')" -ForegroundColor Green
    
    # Parse translation files
    $translationData = @{}
    foreach ($file in $translationFiles) {
        $language = $file.BaseName
        Write-Host "Parsing $language..." -ForegroundColor Gray
        $translationData[$language] = Parse-TranslationFile -FilePath $file.FullName
    }
    
    # Find used translation keys
    Write-Host "Scanning templates and content for used translation keys..." -ForegroundColor Cyan
    $searchPaths = @($LayoutsPath, $ContentPath)
    $usedKeys = Find-UsedTranslationKeys -SearchPaths $searchPaths
    Write-Host "Found $($usedKeys.Count) unique translation keys in use" -ForegroundColor Green
    
    # Compare translation files
    Write-Host "Comparing translation files..." -ForegroundColor Cyan
    $comparisonData = Compare-TranslationFiles -TranslationData $translationData
    
    # Generate report
    Write-Host "Generating report..." -ForegroundColor Cyan
    Generate-Report -TranslationData $translationData -ComparisonData $comparisonData -UsedKeys $usedKeys -Format $OutputFormat -ExportPath $ExportPath
    
    Write-Host "`nAnalysis complete!" -ForegroundColor Green
}
catch {
    Write-Error "An error occurred during analysis: $($_.Exception.Message)"
    Write-Error $_.ScriptStackTrace
    exit 1
}
