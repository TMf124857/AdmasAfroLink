# Simple HTML generator for PDF conversion
$markdownFile = "AdmasAfroLink_Deployment_Report.md"
$htmlFile = "AdmasAfroLink_Report.html"

Write-Host "Creating HTML version of the report..." -ForegroundColor Yellow

# Read the markdown content
$content = Get-Content $markdownFile -Raw

# Create HTML with proper styling
$htmlContent = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AdmasAfroLink Deployment Report</title>
    <style>
        @page { 
            margin: 0.75in; 
            size: A4; 
        }
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            font-size: 11px; 
            max-width: 100%;
        }
        h1 { 
            color: #2c5aa0; 
            border-bottom: 3px solid #2c5aa0; 
            padding-bottom: 10px; 
            font-size: 22px; 
            page-break-after: avoid;
        }
        h2 { 
            color: #34495e; 
            border-bottom: 1px solid #bdc3c7; 
            padding-bottom: 5px; 
            margin-top: 25px; 
            font-size: 18px; 
            page-break-after: avoid;
        }
        h3 { 
            color: #34495e; 
            font-size: 14px; 
            page-break-after: avoid;
        }
        h4 { 
            color: #34495e; 
            font-size: 12px; 
            page-break-after: avoid;
        }
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin: 15px 0; 
            font-size: 10px; 
            page-break-inside: avoid;
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 6px; 
            text-align: left; 
            vertical-align: top;
        }
        th { 
            background-color: #f2f2f2; 
            font-weight: bold; 
        }
        code { 
            background-color: #f8f9fa; 
            padding: 2px 4px; 
            border-radius: 3px; 
            font-size: 10px; 
            font-family: 'Courier New', monospace;
        }
        pre { 
            background-color: #f8f9fa; 
            padding: 10px; 
            border-radius: 5px; 
            font-size: 9px; 
            overflow-x: auto; 
            white-space: pre-wrap;
            font-family: 'Courier New', monospace;
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
            margin: 20px 0; 
        }
        ul, ol { 
            margin: 10px 0; 
            padding-left: 20px; 
        }
        li { 
            margin: 3px 0; 
        }
        p { 
            margin: 8px 0; 
        }
        .header-section {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #2c5aa0;
        }
    </style>
</head>
<body>
'@

# Process the markdown content
$processedContent = $content `
    -replace '(?m)^# (.+)$', '<h1>$1</h1>' `
    -replace '(?m)^## (.+)$', '<h2>$1</h2>' `
    -replace '(?m)^### (.+)$', '<h3>$1</h3>' `
    -replace '(?m)^#### (.+)$', '<h4>$1</h4>' `
    -replace '\*\*(.+?)\*\*', '<strong>$1</strong>' `
    -replace '(?<!\*)\*([^*\n]+?)\*(?!\*)', '<em>$1</em>' `
    -replace '`([^`\n]+?)`', '<code>$1</code>' `
    -replace '(?ms)^```[\w]*\r?\n(.*?)\r?\n```', '<pre><code>$1</code></pre>' `
    -replace '(?m)^- (.+)$', '<li>$1</li>' `
    -replace '✅', '<span class="status-complete">✅</span>' `
    -replace '🔄', '<span class="status-pending">🔄</span>' `
    -replace '(?m)^---+$', '<hr>' `
    -replace '\r?\n\r?\n', '</p><p>' `
    -replace '^(.)', '<p>$1' `
    -replace '(.+)$', '$1</p>'

# Combine HTML
$finalHtml = $htmlContent + $processedContent + @'
</body>
</html>
'@

# Write to file
$finalHtml | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host "✅ HTML file created successfully: $htmlFile" -ForegroundColor Green
Write-Host ""
Write-Host "=== NEXT STEPS TO CREATE PDF ===" -ForegroundColor Cyan
Write-Host "1. Open $htmlFile in your web browser" -ForegroundColor White
Write-Host "2. Press Ctrl+P to open print dialog" -ForegroundColor White
Write-Host "3. Select 'Save as PDF' or 'Microsoft Print to PDF'" -ForegroundColor White
Write-Host "4. Save as: AdmasAfroLink_Deployment_Report.pdf" -ForegroundColor White
Write-Host ""

# Try to open the HTML file automatically
try {
    Start-Process $htmlFile
    Write-Host "📄 Opening HTML file in default browser..." -ForegroundColor Yellow
} catch {
    Write-Host "⚠️  Please manually open $htmlFile in your browser" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ PDF conversion setup complete!" -ForegroundColor Green
