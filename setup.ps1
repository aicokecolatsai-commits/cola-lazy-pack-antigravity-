# Antigravity 專屬環境懶人包安裝與設定腳本 (Cola Lazy Pack)
# 支援功能：Git, GitHub CLI, Node.js, uv, Playwright, Firecrawl, Firebase, Obsidian MCP, 技能下載與 mcp_config.json 安全生成

[CmdletBinding()]
Param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# 美化終端機輸出
function Write-Header ($text) {
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan -Bold
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Write-Success ($text) {
    Write-Host "[v] $text" -ForegroundColor Green
}

function Write-Info ($text) {
    Write-Host "[i] $text" -ForegroundColor Yellow
}

function Write-Step ($text) {
    Write-Host "`n---> $text" -ForegroundColor Magenta -Bold
}

# 取得目前使用者與 Gemimi 設定目錄
$configDir = "$HOME\.gemini\config"
$pluginsDir = "$configDir\plugins"
$targetMcpConfig = "$configDir\mcp_config.json"

Write-Header "Cola Lazy Pack - Antigravity 環境初始化"
Write-Info "本機設定目錄: $configDir"

# ==========================================
# 步驟 1: 安裝基礎環境 (Git, GitHub CLI, Node.js, uv)
# ==========================================
Write-Step "步驟 1: 檢查與安裝基礎環境"

# 1.1 檢查 Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVer = (git --version)
    Write-Success "Git 已安裝: $gitVer"
} else {
    Write-Info "正在透過 winget 安裝 Git..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    Write-Success "Git 安裝完成！"
}

# 1.2 檢查 GitHub CLI (gh)
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghVer = (gh --version | Select-String -Pattern "gh version")
    Write-Success "GitHub CLI 已安裝: $ghVer"
} else {
    Write-Info "正在透過 winget 安裝 GitHub CLI..."
    winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements
    Write-Success "GitHub CLI 安裝完成！"
}

# 1.3 檢查 Node.js
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = (node -v)
    Write-Success "Node.js 已安裝: $nodeVer"
} else {
    Write-Info "正在透過 winget 安裝 Node.js..."
    winget install --id OpenJS.NodeJS -e --source winget --accept-package-agreements --accept-source-agreements
    Write-Success "Node.js 安裝完成！(請重啟終端機以套用環境變數，或繼續執行)"
}

# 1.4 檢查 uv (Python uv)
if (Get-Command uv -ErrorAction SilentlyContinue) {
    $uvVer = (uv --version)
    Write-Success "uv 已安裝: $uvVer"
} else {
    Write-Info "正在安裝 Astral uv..."
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    Write-Success "uv 安裝完成！"
}

# ==========================================
# 步驟 2: 確認 GitHub CLI 登入狀態
# ==========================================
Write-Step "步驟 2: 確認 GitHub 驗證狀態"
try {
    & gh auth status
    Write-Success "GitHub CLI 驗證正常！"
} catch {
    Write-Warning "GitHub CLI 尚未登入！請在稍後手動執行 'gh auth login' 進行登入。"
}

# ==========================================
# 步驟 3: 安裝與確認指定 Skills (Brainstorming, UI-UX Pro Max)
# ==========================================
Write-Step "步驟 3: 安裝專屬 Skills / Plugins"

if (-not (Test-Path $pluginsDir)) {
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
    Write-Info "已建立 plugins 目錄: $pluginsDir"
}

# 3.1 安裝 Brainstorming Skill (從 https://github.com/obra/superpowers clone)
$brainstormingPluginPath = "$pluginsDir\brainstorming"
$brainstormingSkillsPath = "$brainstormingPluginPath\skills"

Write-Info "正在設定 brainstorming skill..."
if (-not (Test-Path $brainstormingSkillsPath)) {
    # 建立目錄
    New-Item -ItemType Directory -Path $brainstormingSkillsPath -Force | Out-Null
    
    # 暫存 clone 整個 repo
    $tempRepoDir = "$env:TEMP\superpowers_temp"
    if (Test-Path $tempRepoDir) {
        Remove-Item -Recurse -Force $tempRepoDir
    }
    
    Write-Info "正在從 GitHub 複製 superpowers 專案..."
    git clone --depth 1 https://github.com/obra/superpowers.git $tempRepoDir
    
    # 複製 brainstorming skill 內容
    Copy-Item -Path "$tempRepoDir\skills\brainstorming\*" -Destination $brainstormingSkillsPath -Recurse -Force
    
    # 建立 plugin.json
    $pluginJsonContent = @"
{
  "name": "brainstorming",
  "version": "1.0.0",
  "description": "Custom migrated skill brainstorming",
  "author": {
    "name": "COLA"
  },
  "license": "Apache-2.0"
}
"@
    Set-Content -Path "$brainstormingPluginPath\plugin.json" -Value $pluginJsonContent -Encoding utf8
    
    # 清除暫存
    Remove-Item -Recurse -Force $tempRepoDir
    Write-Success "brainstorming skill 安裝成功！"
} else {
    Write-Success "brainstorming skill 已存在，跳過安裝。"
}

# 3.2 安裝 UI-UX Pro Max Skill (從 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
$uiUxPluginPath = "$pluginsDir\ui-ux-pro-max"
Write-Info "正在設定 ui-ux-pro-max skill..."

function Configure-UiUxPluginForAntigravity {
    param (
        [string]$pluginPath
    )
    $targetSkillsPath = "$pluginPath\skills\ui-ux-pro-max"
    $sourceSkillsPath = "$pluginPath\.claude\skills\ui-ux-pro-max"
    
    if (Test-Path $sourceSkillsPath) {
        Write-Info "正在配置 ui-ux-pro-max 為 Antigravity 相容格式..."
        
        # 建立 skills 目錄
        if (-not (Test-Path $targetSkillsPath)) {
            New-Item -ItemType Directory -Path $targetSkillsPath -Force | Out-Null
        }
        
        # 複製技能內容
        Copy-Item -Path "$sourceSkillsPath\*" -Destination $targetSkillsPath -Recurse -Force | Out-Null
        
        # 建立 plugin.json
        $pluginJsonContent = @"
{
  "name": "ui-ux-pro-max",
  "version": "2.11.0",
  "description": "AI-powered design intelligence with 84 UI styles, 161 color palettes, 73 font pairings, 99 UX guidelines, and 25 chart types across 17 tech stacks.",
  "author": {
    "name": "NextLevelBuilder"
  },
  "license": "MIT"
}
"@
        Set-Content -Path "$pluginPath\plugin.json" -Value $pluginJsonContent -Encoding utf8
        Write-Success "ui-ux-pro-max Antigravity 相容格式配置完成！"
    } else {
        Write-Warning "未找到 ui-ux-pro-max 的 .claude/skills/ui-ux-pro-max 來源目錄，無法進行 Antigravity 配置。"
    }
}

if (-not (Test-Path $uiUxPluginPath)) {
    git clone https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git $uiUxPluginPath
    Configure-UiUxPluginForAntigravity $uiUxPluginPath
    Write-Success "ui-ux-pro-max skill 安裝與配置成功！"
} else {
    # 檢查是否為 Git 專案
    $isGit = $false
    if (Test-Path "$uiUxPluginPath\.git") {
        Push-Location $uiUxPluginPath
        try {
            $check = git rev-parse --is-inside-work-tree 2>$null
            if ($check -eq "true") { $isGit = $true }
        } catch {}
        Pop-Location
    }
    
    if (-not $isGit) {
        Write-Info "偵測到 ui-ux-pro-max 不是有效的 Git 儲存庫，正在重新安裝..."
        Remove-Item -Recurse -Force $uiUxPluginPath -ErrorAction SilentlyContinue
        git clone https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git $uiUxPluginPath
        Configure-UiUxPluginForAntigravity $uiUxPluginPath
        Write-Success "ui-ux-pro-max skill 重新安裝與配置成功！"
    } else {
        Write-Info "ui-ux-pro-max skill 已存在，正在進行更新..."
        Push-Location $uiUxPluginPath
        try {
            git pull
            Write-Success "ui-ux-pro-max skill 更新成功！"
        } catch {
            Write-Warning "ui-ux-pro-max skill 更新失敗，請檢查網路連線。"
        }
        Pop-Location
        # 即使已存在也重新配置，以確保結構完整性
        Configure-UiUxPluginForAntigravity $uiUxPluginPath
    }
}

# 3.3 安裝 Antigravity 全域技能 (00-install-all 至 06-obsidian，含專案初始化技能 05-workflow)
$globalSkillsDir = "$configDir\skills"
Write-Info "正在設定 Antigravity 全域技能..."
if (-not (Test-Path $globalSkillsDir)) {
    New-Item -ItemType Directory -Path $globalSkillsDir -Force | Out-Null
}

$localSkillsSource = "$PSScriptRoot\skills"
if (Test-Path $localSkillsSource) {
    Write-Info "正在將全域技能複製到: $globalSkillsDir"
    
    # 取得本地複製過來的 00- 至 06- 開頭的子目錄，並複製到全域技能目錄下
    Get-ChildItem -Path $localSkillsSource -Directory | Where-Object { $_.Name -like "0*" } | ForEach-Object {
        $destPath = "$globalSkillsDir\$($_.Name)"
        Write-Info "正在複製技能 $($_.Name) 到 $destPath..."
        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
        Copy-Item -Path "$($_.FullName)\*" -Destination $destPath -Recurse -Force | Out-Null
    }
    Write-Success "Antigravity 全域技能 (包含 05-workflow 專案初始化技能) 安裝完成！"
} else {
    Write-Warning "未找到本地的 skills 目錄，無法安裝全域技能。"
}

# ==========================================
# 步驟 4: 安裝全域 NPM 工具與元件
# ==========================================
Write-Step "步驟 4: 安裝全域 NPM 工具"

# 4.1 安裝 Playwright 瀏覽器二進位檔 (確保 npx @playwright/mcp 能正常運作)
Write-Info "正在安裝 Playwright 瀏覽器核心..."
npx -y playwright install chromium firefox webkit
Write-Success "Playwright 核心安裝完成！"

# 4.2 安裝 Firebase Tools
if (Get-Command firebase -ErrorAction SilentlyContinue) {
    Write-Success "Firebase Tools 已安裝"
} else {
    Write-Info "正在全域安裝 firebase-tools..."
    npm install -g firebase-tools
    Write-Success "firebase-tools 安裝完成！"
}

# 4.3 安裝 Obsidian mcpvault
$mcpvaultPath = ""
# 檢查是否有 mcpvault 全域指令
if (Get-Command mcpvault -ErrorAction SilentlyContinue) {
    Write-Success "Obsidian mcpvault 已安裝"
    $mcpvaultPath = (Get-Command mcpvault).Source
} else {
    Write-Info "正在全域安裝 mcpvault..."
    npm install -g mcpvault
    # 嘗試重新獲取路徑
    if (Get-Command mcpvault -ErrorAction SilentlyContinue) {
        $mcpvaultPath = (Get-Command mcpvault).Source
    } else {
        # 預設 Windows 全域 npm cmd 路徑
        $mcpvaultPath = "$env:APPDATA\npm\mcpvault.cmd"
    }
    Write-Success "mcpvault 安裝完成！"
}

# ==========================================
# 步驟 5: 產生安全的 mcp_config.json 設定檔
# ==========================================
Write-Step "步驟 5: 產生安全的 mcp_config.json 設定檔"

# 讀取現有設定 (如有)，以避免重複詢問
$existingConfig = @{}
if (Test-Path $targetMcpConfig) {
    Write-Info "偵測到本機已存在 mcp_config.json，將自動擷取現有金鑰與設定..."
    try {
        $json = Get-Content -Raw -Encoding utf8 -Path $targetMcpConfig | ConvertFrom-Json
        
        # 擷取金鑰
        if ($json.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN) {
            $existingConfig["GITHUB_TOKEN"] = $json.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
        }
        if ($json.mcpServers.firecrawl.env.FIRECRAWL_API_KEY) {
            $existingConfig["FIRECRAWL_KEY"] = $json.mcpServers.firecrawl.env.FIRECRAWL_API_KEY
        }
        if ($json.mcpServers.netlify.env.NETLIFY_PERSONAL_ACCESS_TOKEN) {
            $existingConfig["NETLIFY_TOKEN"] = $json.mcpServers.netlify.env.NETLIFY_PERSONAL_ACCESS_TOKEN
        }
        if ($json.mcpServers.obsidian.args -and $json.mcpServers.obsidian.args.Count -gt 0) {
            $existingConfig["OBSIDIAN_VAULT"] = $json.mcpServers.obsidian.args[0]
        }
        # GDrive
        if ($json.mcpServers.gdrive.env.GDRIVE_CLIENT_ID) {
            $existingConfig["GDRIVE_CLIENT_ID"] = $json.mcpServers.gdrive.env.GDRIVE_CLIENT_ID
        }
        if ($json.mcpServers.gdrive.env.GDRIVE_CLIENT_SECRET) {
            $existingConfig["GDRIVE_CLIENT_SECRET"] = $json.mcpServers.gdrive.env.GDRIVE_CLIENT_SECRET
        }
    } catch {
        Write-Warning "讀取現有 mcp_config.json 失敗，將重新建立設定。"
    }
}

# 取得各設定的預設或現有值
$defaultGithub = $existingConfig["GITHUB_TOKEN"]
$defaultFirecrawl = $existingConfig["FIRECRAWL_KEY"]
$defaultNetlify = $existingConfig["NETLIFY_TOKEN"]
$defaultVault = if ($existingConfig["OBSIDIAN_VAULT"]) { $existingConfig["OBSIDIAN_VAULT"] } else { "O:/我的雲端硬碟/AI_Project/00_colabrain/ColaBrain" }
$defaultGDriveID = $existingConfig["GDRIVE_CLIENT_ID"]
$defaultGDriveSecret = $existingConfig["GDRIVE_CLIENT_SECRET"]

if ($Silent) {
    Write-Info "偵測到靜默模式，將自動使用預設/現有值進行配置..."
    $githubToken = $defaultGithub
    $firecrawlKey = $defaultFirecrawl
    $netlifyToken = $defaultNetlify
    $vaultPath = $defaultVault
    $gdriveClientID = $defaultGDriveID
    $gdriveClientSecret = $defaultGDriveSecret
} else {
    # 互動取得使用者金鑰與變數
    Write-Host "`n[請輸入以下設定值，按 Enter 鍵可使用預設值或現有設定]" -ForegroundColor Cyan

    # 1. GitHub Token
    $githubPrompt = if ($defaultGithub) { "GitHub Personal Access Token (已有現有設定, 直接 Enter 延用): " } else { "GitHub Personal Access Token: " }
    $githubToken = Read-Host -Prompt $githubPrompt
    if ([string]::IsNullOrWhiteSpace($githubToken)) { $githubToken = $defaultGithub }

    # 2. Firecrawl Key
    $firecrawlPrompt = if ($defaultFirecrawl) { "Firecrawl API Key (已有現有設定, 直接 Enter 延用): " } else { "Firecrawl API Key (可選): " }
    $firecrawlKey = Read-Host -Prompt $firecrawlPrompt
    if ([string]::IsNullOrWhiteSpace($firecrawlKey)) { $firecrawlKey = $defaultFirecrawl }

    # 3. Netlify Token
    $netlifyPrompt = if ($defaultNetlify) { "Netlify Personal Access Token (已有現有設定, 直接 Enter 延用): " } else { "Netlify Personal Access Token (可選): " }
    $netlifyToken = Read-Host -Prompt $netlifyPrompt
    if ([string]::IsNullOrWhiteSpace($netlifyToken)) { $netlifyToken = $defaultNetlify }

    # 4. Obsidian Vault Path
    $vaultPath = Read-Host -Prompt "Obsidian Vault 絕對路徑 (預設: $defaultVault)"
    if ([string]::IsNullOrWhiteSpace($vaultPath)) { $vaultPath = $defaultVault }

    # 5. GDrive Client ID
    $gdriveIDPrompt = if ($defaultGDriveID) { "GDrive Client ID (已有現有設定, 直接 Enter 延用): " } else { "GDrive Client ID (可選): " }
    $gdriveClientID = Read-Host -Prompt $gdriveIDPrompt
    if ([string]::IsNullOrWhiteSpace($gdriveClientID)) { $gdriveClientID = $defaultGDriveID }

    # 6. GDrive Client Secret
    $gdriveSecretPrompt = if ($defaultGDriveSecret) { "GDrive Client Secret (已有現有設定, 直接 Enter 延用): " } else { "GDrive Client Secret (可選): " }
    $gdriveClientSecret = Read-Host -Prompt $gdriveSecretPrompt
    if ([string]::IsNullOrWhiteSpace($gdriveClientSecret)) { $gdriveClientSecret = $defaultGDriveSecret }
}

# 自動填寫 mcpvault 執行檔路徑 (Windows 斜線轉換為正斜線以相容 json)
if (-not $mcpvaultPath) {
    $mcpvaultPath = "$env:APPDATA\npm\mcpvault.cmd"
}
$mcpvaultPathJson = $mcpvaultPath.Replace("\", "/")
$vaultPathJson = $vaultPath.Replace("\", "/")
$gdriveOauthPath = "$configDir\gcp-oauth.keys.json".Replace("\", "/")
$gdriveCredsPath = "$configDir\.gdrive-server-credentials.json".Replace("\", "/")

# 讀取模板檔案並取代變數
$templatePath = "$PSScriptRoot\templates\mcp_config.template.json"
if (-not (Test-Path $templatePath)) {
    Write-Error "找不到設定檔模板: $templatePath"
}

$templateContent = Get-Content -Raw -Path $templatePath
$configContent = $templateContent `
    -replace "\{\{GITHUB_PERSONAL_ACCESS_TOKEN\}\}", $githubToken `
    -replace "\{\{FIRECRAWL_API_KEY\}\}", $firecrawlKey `
    -replace "\{\{NETLIFY_PERSONAL_ACCESS_TOKEN\}\}", $netlifyToken `
    -replace "\{\{OBSIDIAN_MCPVAULT_PATH\}\}", $mcpvaultPathJson `
    -replace "\{\{OBSIDIAN_VAULT_PATH\}\}", $vaultPathJson `
    -replace "\{\{GDRIVE_CLIENT_ID\}\}", $gdriveClientID `
    -replace "\{\{GDRIVE_CLIENT_SECRET\}\}", $gdriveClientSecret `
    -replace "\{\{GDRIVE_OAUTH_PATH\}\}", $gdriveOauthPath `
    -replace "\{\{GDRIVE_CREDENTIALS_PATH\}\}", $gdriveCredsPath

# 寫入本機實際 config 目錄下
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}
Set-Content -Path $targetMcpConfig -Value $configContent -Encoding utf8
Write-Success "成功生成/更新本機 MCP 設定檔: $targetMcpConfig"

Write-Header "Antigravity 環境初始化完成！"
Write-Host "所有指定工具、專屬技能已下載就緒，並成功生成安全且不洩漏的 MCP 設定檔。" -ForegroundColor Green
Write-Host "您現在可以啟動 Antigravity 並開始使用全新的環境了！`n" -ForegroundColor Green
