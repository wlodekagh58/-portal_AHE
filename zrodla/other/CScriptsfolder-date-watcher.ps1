$Root = "C:\Users\barte\AI\Cloude Code\testy 2 - przed arch plikiow — kopia pod try 2\zrodla\merytoryczne"

Write-Host "=== START ===" -ForegroundColor Cyan
Write-Host "ROOT: $Root"
Write-Host ""

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "BLAD: ROOT NIE ISTNIEJE!" -ForegroundColor Red
    exit
}

$folders = @(
    Get-Item -LiteralPath $Root -Force
    Get-ChildItem -LiteralPath $Root -Directory -Recurse -Force -ErrorAction Stop
)

Write-Host "ZNALEZIONO FOLDEROW: $($folders.Count)" -ForegroundColor Cyan
Write-Host ""

foreach ($folder in $folders) {

    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host "FOLDER: $($folder.FullName)"

    try {
        $files = @(
            Get-ChildItem `
                -LiteralPath $folder.FullName `
                -File `
                -Recurse `
                -Force `
                -ErrorAction Stop
        )

        if ($files.Count -eq 0) {
            Write-Host "BRAK PLIKOW" -ForegroundColor Yellow
            continue
        }

        $latest = $files |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        Write-Host "PLIK: $($latest.FullName)"
        Write-Host "DATA PLIKU: $($latest.LastWriteTime)"
        Write-Host "DATA FOLDERU PRZED: $($folder.LastWriteTime)"

        [System.IO.Directory]::SetLastWriteTime(
            $folder.FullName,
            $latest.LastWriteTime
        )

        $after = [System.IO.Directory]::GetLastWriteTime(
            $folder.FullName
        )

        Write-Host "DATA FOLDERU PO: $after"

        if ($after -eq $latest.LastWriteTime) {
            Write-Host "OK - DATA ZAPISANA" -ForegroundColor Green
        }
        else {
            Write-Host "BLAD - DATA NIE ZOSTALA USTAWIONA!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "!!! BLAD !!!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== KONIEC ===" -ForegroundColor Cyan