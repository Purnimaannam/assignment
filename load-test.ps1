# Load testing script for Wallet API on Windows
# Usage: .\load-test.ps1 -NumRequests 100 -NumConcurrent 10

param(
    [int]$NumRequests = 100,
    [int]$NumConcurrent = 10
)

$BaseUrl = "http://localhost:8080/api/v1"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Wallet API - Load Testing" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl"
Write-Host "Total Requests: $NumRequests"
Write-Host "Concurrent: $NumConcurrent"
Write-Host ""

# Create a wallet for testing
$WalletId = [guid]::NewGuid().ToString()
Write-Host "Creating test wallet: $WalletId" -ForegroundColor Yellow

$body = @{
    walletId = $WalletId
    operationType = "DEPOSIT"
    amount = 10000.00
} | ConvertTo-Json

Invoke-RestMethod -Uri "$BaseUrl/wallet" `
    -Method Post `
    -Headers @{"Content-Type"="application/json"} `
    -Body $body | ConvertTo-Json | Write-Host

Write-Host ""
Write-Host "Starting load test..." -ForegroundColor Yellow
Write-Host ""

$StartTime = Get-Date
$jobs = @()

for ($i = 1; $i -le $NumRequests; $i++) {
    $amount = Get-Random -Minimum 1 -Maximum 100
    $operation = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { "DEPOSIT" } else { "WITHDRAW" }
    
    $scriptBlock = {
        param($BaseUrl, $WalletId, $Operation, $Amount, $RequestNum)
        
        $body = @{
            walletId = $WalletId
            operationType = $Operation
            amount = [decimal]$Amount
        } | ConvertTo-Json
        
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl/wallet" `
                -Method Post `
                -Headers @{"Content-Type"="application/json"} `
                -Body $body
            Write-Host "Request $RequestNum`: $Operation $Amount - Success" -ForegroundColor Green
        }
        catch {
            Write-Host "Request $RequestNum`: $Operation $Amount - Failed" -ForegroundColor Red
        }
    }
    
    $job = Start-Job -ScriptBlock $scriptBlock `
        -ArgumentList $BaseUrl, $WalletId, $operation, $amount, $i
    
    $jobs += $job
    
    # Control concurrency
    if ($jobs.Count -ge $NumConcurrent) {
        $jobs | Wait-Job | Remove-Job
        $jobs = @()
    }
}

# Wait for remaining jobs
if ($jobs.Count -gt 0) {
    $jobs | Wait-Job | Remove-Job
}

$EndTime = Get-Date
$Duration = ($EndTime - $StartTime).TotalSeconds

Write-Host ""
Write-Host "Load test completed in $Duration seconds" -ForegroundColor Cyan
Write-Host ""

# Get final balance
Write-Host "Final wallet balance:" -ForegroundColor Yellow
$response = Invoke-RestMethod -Uri "$BaseUrl/wallets/$WalletId" `
    -Method Get
$response | ConvertTo-Json | Write-Host

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
