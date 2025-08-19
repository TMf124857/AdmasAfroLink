# PowerShell script to convert Markdown to PDF
# AdmasAfroLink Deployment Report PDF Generator

param(
    [string]$InputFile = "AdmasAfroLink_Deployment_Report.md",
    [string]$OutputFile = "AdmasAfroLink_Deployment_Report.pdf"
)

Write-Host "=== AdmasAfroLink PDF Generator ===" -ForegroundColor Green
Write-Host "Converting: $InputFile to $OutputFile" -ForegroundColor Yellow

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Error "Input file '$InputFile' not found!"
    exit 1
}

# Method 1: Try using pandoc (if available)
$pandocPath = Get-Command pandoc -ErrorAction SilentlyContinue
if ($pandocPath) {
    Write-Host "Using Pandoc for conversion..." -ForegroundColor Blue
    try {
        pandoc $InputFile -o $OutputFile --pdf-engine=wkhtmltopdf --css="report-style.css"
        if (Test-Path $OutputFile) {
            Write-Host "✅ PDF created successfully using Pandoc!" -ForegroundColor Green
            Write-Host "Output: $OutputFile" -ForegroundColor Cyan
            exit 0
        }
    }
    catch {
        Write-Warning "Pandoc conversion failed: $($_.Exception.Message)"
    }
}

# Method 2: Try using wkhtmltopdf directly
$wkhtmltopdfPath = Get-Command wkhtmltopdf -ErrorAction SilentlyContinue
if ($wkhtmltopdfPath) {
    Write-Host "Using wkhtmltopdf for conversion..." -ForegroundColor Blue
    try {
        # First convert markdown to HTML
        $htmlFile = $InputFile.Replace(".md", ".html")
        $markdownContent = Get-Content $InputFile -Raw
        
        # Simple markdown to HTML conversion (basic)
        $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AdmasAfroLink Deployment Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        h1 { color: #2c5aa0; border-bottom: 3px solid #2c5aa0; padding-bottom: 10px; }
        h2 { color: #34495e; border-bottom: 1px solid #bdc3c7; padding-bottom: 5px; }
        h3 { color: #34495e; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f2f2f2; font-weight: bold; }
        code { background-color: #f8f9fa; padding: 2px 4px; border-radius: 3px; }
        pre { background-color: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .status-complete { color: #27ae60; font-weight: bold; }
        .status-pending { color: #f39c12; font-weight: bold; }
        hr { border: none; border-top: 2px solid #ecf0f1; margin: 30px 0; }
    </style>
</head>
<body>
$($markdownContent -replace '#####\s+(.+)', '<h5>$1</h5>' -replace '####\s+(.+)', '<h4>$1</h4>' -replace '###\s+(.+)', '<h3>$1</h3>' -replace '##\s+(.+)', '<h2>$1</h2>' -replace '#\s+(.+)', '<h1>$1</h1>' -replace '\*\*(.+?)\*\*', '<strong>$1</strong>' -replace '\*(.+?)\*', '<em>$1</em>' -replace '`(.+?)`', '<code>$1</code>' -replace '^-\s+(.+)', '<li>$1</li>' -replace '✅', '<span class="status-complete">✅</span>' -replace '🔄', '<span class="status-pending">🔄</span>' -replace '^---$', '<hr>' -replace '\n', '<br>')
</body>
</html>
"@
        
        $htmlContent | Out-File -FilePath $htmlFile -Encoding UTF8
        
        # Convert HTML to PDF
        wkhtmltopdf --page-size A4 --margin-top 0.75in --margin-right 0.75in --margin-bottom 0.75in --margin-left 0.75in $htmlFile $OutputFile
        
        # Clean up HTML file
        Remove-Item $htmlFile -ErrorAction SilentlyContinue
        
        if (Test-Path $OutputFile) {
            Write-Host "✅ PDF created successfully using wkhtmltopdf!" -ForegroundColor Green
            Write-Host "Output: $OutputFile" -ForegroundColor Cyan
            exit 0
        }
    }
    catch {
        Write-Warning "wkhtmltopdf conversion failed: $($_.Exception.Message)"
    }
}

# Method 3: Use PowerShell with Word COM object (if Microsoft Word is installed)
Write-Host "Trying Microsoft Word COM object..." -ForegroundColor Blue
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    
    # Read markdown content
    $content = Get-Content $InputFile -Raw
    
    # Create new document
    $doc = $word.Documents.Add()
    $selection = $word.Selection
    
    # Add content (simplified conversion)
    $selection.TypeText($content)
    
    # Save as PDF
    $pdfPath = (Resolve-Path .).Path + "\" + $OutputFile
    $doc.SaveAs([ref]$pdfPath, [ref]17) # 17 = PDF format
    
    # Close and cleanup
    $doc.Close()
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    
    if (Test-Path $OutputFile) {
        Write-Host "✅ PDF created successfully using Microsoft Word!" -ForegroundColor Green
        Write-Host "Output: $OutputFile" -ForegroundColor Cyan
        exit 0
    }
}
catch {
    Write-Warning "Microsoft Word COM conversion failed: $($_.Exception.Message)"
}

# Method 4: Simple HTML conversion and browser printing (fallback)
Write-Host "Creating HTML version for manual PDF conversion..." -ForegroundColor Blue
try {
    $htmlFile = $InputFile.Replace(".md", "_PRINT.html")
    $markdownContent = Get-Content $InputFile -Raw
    
    # Enhanced HTML template with better styling
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AdmasAfroLink Deployment Report</title>
    <style>
        @page { margin: 1in; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 20px; 
            line-height: 1.6; 
            color: #333;
            font-size: 12px;
        }
        h1 { 
            color: #2c5aa0; 
            border-bottom: 3px solid #2c5aa0; 
            padding-bottom: 10px; 
            page-break-after: avoid;
            font-size: 24px;
        }
        h2 { 
            color: #34495e; 
            border-bottom: 1px solid #bdc3c7; 
            padding-bottom: 5px; 
            page-break-after: avoid;
            margin-top: 30px;
            font-size: 20px;
        }
        h3 { 
            color: #34495e; 
            page-break-after: avoid;
            font-size: 16px;
        }
        h4 { 
            color: #34495e; 
            page-break-after: avoid;
            font-size: 14px;
        }
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin: 20px 0; 
            page-break-inside: avoid;
            font-size: 11px;
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 8px; 
            text-align: left; 
        }
        th { 
            background-color: #f2f2f2; 
            font-weight: bold; 
        }
        code { 
            background-color: #f8f9fa; 
            padding: 2px 4px; 
            border-radius: 3px; 
            font-family: 'Courier New', monospace;
            font-size: 11px;
        }
        pre { 
            background-color: #f8f9fa; 
            padding: 15px; 
            border-radius: 5px; 
            overflow-x: auto; 
            white-space: pre-wrap;
            font-family: 'Courier New', monospace;
            font-size: 10px;
            page-break-inside: avoid;
        }
        .status-complete { 
            color: #27ae60; 
            font-weight: bold; 
        }
        .status-pending { 
            color: #f39c12; 
            font-weight: bold; 
        }
        hr { 
            border: none; 
            border-top: 2px solid #ecf0f1; 
            margin: 30px 0; 
        }
        .page-break { 
            page-break-before: always; 
        }
        ul, ol { 
            margin: 10px 0; 
            padding-left: 30px; 
        }
        li { 
            margin: 5px 0; 
        }
        .header-info {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 30px;
        }
        .header-info p {
            margin: 5px 0;
            font-weight: bold;
        }
    </style>
    <script>
        function printToPDF() {
            window.print();
        }
        window.onload = function() {
            // Auto-print dialog
            setTimeout(printToPDF, 1000);
        }
    </script>
</head>
<body>
$(
    $markdownContent `
        -replace '(?m)^# (.+)$', '<h1>$1</h1>' `
        -replace '(?m)^## (.+)$', '<h2>$1</h2>' `
        -replace '(?m)^### (.+)$', '<h3>$1</h3>' `
        -replace '(?m)^#### (.+)$', '<h4>$1</h4>' `
        -replace '(?m)^##### (.+)$', '<h5>$1</h5>' `
        -replace '\*\*(.+?)\*\*', '<strong>$1</strong>' `
        -replace '(?<!\*)\*([^*]+?)\*(?!\*)', '<em>$1</em>' `
        -replace '`([^`]+?)`', '<code>$1</code>' `
        -replace '(?m)^```(\w+)?$(.*?)^```$', '<pre><code>$2</code></pre>' `
        -replace '(?m)^- (.+)$', '<li>$1</li>' `
        -replace '(?m)^(\d+\.) (.+)$', '<li>$2</li>' `
        -replace '✅', '<span class="status-complete">✅</span>' `
        -replace '🔄', '<span class="status-pending">🔄</span>' `
        -replace '(?m)^---$', '<hr>' `
        -replace '\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|', '<tr><td>$1</td><td>$2</td><td>$3</td></tr>' `
        -replace '(?m)^\|(.+)\|$', '<table>$1</table>' `
        -replace '\n\n', '</p><p>' `
        -replace '(?m)^([^<\n].+)$', '<p>$1</p>'
)
</body>
</html>
"@
    
    $htmlContent | Out-File -FilePath $htmlFile -Encoding UTF8
    
    Write-Host "✅ HTML file created: $htmlFile" -ForegroundColor Green
    Write-Host "📄 Opening in browser for PDF printing..." -ForegroundColor Yellow
    
    # Open in default browser
    Start-Process $htmlFile
    
    Write-Host ""
    Write-Host "=== INSTRUCTIONS ===" -ForegroundColor Magenta
    Write-Host "1. The HTML file will open in your browser" -ForegroundColor White
    Write-Host "2. Press Ctrl+P (or Cmd+P on Mac) to print" -ForegroundColor White
    Write-Host "3. Select 'Save as PDF' as the destination" -ForegroundColor White
    Write-Host "4. Save as: $OutputFile" -ForegroundColor White
    Write-Host "5. The print dialog may open automatically" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ Fallback HTML method completed!" -ForegroundColor Green
    
    return $htmlFile
}
catch {
    Write-Error "All conversion methods failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "=== MANUAL CONVERSION STEPS ===" -ForegroundColor Red
    Write-Host "1. Open the markdown file in VS Code" -ForegroundColor White
    Write-Host "2. Install 'Markdown PDF' extension" -ForegroundColor White
    Write-Host "3. Right-click in the markdown file" -ForegroundColor White
    Write-Host "4. Select 'Markdown PDF: Export (pdf)'" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "=== Conversion Complete ===" -ForegroundColor Green
Write-Host "Check the output file: $OutputFile" -ForegroundColor Cyan
