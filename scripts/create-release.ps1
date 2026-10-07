param(
    [string]$AssetsDir = "$env:GITHUB_WORKSPACE\HelloNet48\bin\Release"
)

$ErrorActionPreference = 'Stop'

$sha   = $env:GITHUB_SHA
$short = $sha.Substring(0, 7)
$tag   = "build-$short"
$api   = $env:GITHUB_API_URL
$repo  = $env:GITHUB_REPOSITORY
$headers = @{ Authorization = "token $env:GITEA_TOKEN" }

try {
    $existing = Invoke-RestMethod -Method Get -Uri "$api/repos/$repo/releases/tags/$tag" -Headers $headers
    Invoke-RestMethod -Method Delete -Uri "$api/repos/$repo/releases/$($existing.id)" -Headers $headers | Out-Null
    Write-Host "Removed existing release $tag"
} catch {
    Write-Host "No existing release for $tag"
}

$body = @{
    tag_name         = $tag
    target_commitish = $sha
    name             = "Build $short"
    body             = "Automated build of commit $sha."
    draft            = $false
    prerelease       = $false
} | ConvertTo-Json

$release = Invoke-RestMethod -Method Post -Uri "$api/repos/$repo/releases" `
    -Headers $headers -ContentType 'application/json' -Body $body
Write-Host "Created release $($release.tag_name) (id $($release.id))"

Get-ChildItem -Path $AssetsDir -File | ForEach-Object {
    $url = "$api/repos/$repo/releases/$($release.id)/assets?name=$($_.Name)"
    Invoke-RestMethod -Method Post -Uri $url -Headers $headers -InFile $_.FullName -ContentType 'application/octet-stream' | Out-Null
    Write-Host "Uploaded asset $($_.Name)"
}
