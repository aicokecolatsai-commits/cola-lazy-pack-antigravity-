# Cola Lazy Pack - Antigravity 專屬環境懶人包

本專案是專為您量身打造的 Antigravity 安裝環境懶人包，方便您在更換電腦或重灌系統後，快速恢復您的 AI Pair Programming 軟體開發工作流。

## 📦 包含元件與安裝順序

1. **Git** - 基礎版本控制工具
2. **GitHub CLI (gh)** - 用於 GitHub 生態整合與 MCP 驗證
3. **Node.js** - 執行 MCP 伺服器的核心環境
4. **uv** - Python 套件與虛擬環境快速管理器
5. **Playwright MCP & 瀏覽器核心** - 賦予 AI 控制瀏覽器的能力
6. **Firecrawl MCP** - 網頁爬蟲與 markdown 轉換服務
7. **Firebase CLI & Firebase MCP** - Firebase 開發工具整合
8. **Obsidian MCP (mcpvault)** - 連接您在 Obsidian 中的第二大腦 (ColaBrain)
9. **Brainstorming Skill** (來自 obra/superpowers) - 輔助設計規劃的 AI Skill
10. **UI-UX Pro Max Skill** (來自 nextlevelbuilder/ui-ux-pro-max-skill) - 前端與 UI/UX 增強技能

---

## 🚀 新電腦轉移與安裝指南

在新電腦上，您只需要執行以下步驟：

1. **取得懶人包**：
   將此資料夾複製到新電腦，或直接 clone 您的個人儲存庫：
   ```powershell
   git clone https://github.com/aicokecolatsai-commits/cola-lazy-pack-antigravity-
   cd cola-lazy-pack-antigravity-
   ```

2. **執行安裝腳本**：
   開啟 PowerShell，先暫時解除執行權限限制（僅對當前視窗有效，不影響系統安全），然後執行 `setup.ps1`：
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process
   .\setup.ps1
   ```

3. **依引導輸入金鑰**：
   腳本會自動偵測您的環境與已安裝軟體，並會詢問您以下金鑰與設定（若您先前已設定過，直接按 Enter 鍵可延用舊的設定）：
   *   `GitHub Personal Access Token`
   *   `Firecrawl API Key` (可留空，若不填寫將使用預設的 keyless 免費服務)
   *   `Netlify Personal Access Token`
   *   `Obsidian Vault 絕對路徑` (預設為您的第二大腦路徑 `O:/我的雲端硬碟/AI_Project/00_colabrain/ColaBrain`)
   *   `GDrive Client ID` & `Client Secret`

4. **完成**：
   腳本執行完畢後，將自動於您的本機設定路徑 `C:\Users\<username>\.gemini\config\mcp_config.json` 寫入安全的設定檔。此時即可重啟您的 Antigravity 終端機或 AI 編輯器，所有工具與 MCP 功能便已就緒！

---

## 🔒 隱私與安全防外洩機制 (極重要)

*   **專案目錄中不包含任何真實金鑰**：專案中的 `templates/mcp_config.template.json` 僅作為設定範本，內含預留位置 `{{PLACEHOLDER}}`。
*   **.gitignore 自動封鎖**：本專案已在 `.gitignore` 檔案中加入 `mcp_config.json`、`.env` 等檔案的排除設定。即使您在本機產生成了包含真實金鑰的設定檔，這些檔案也**絕對不會**被 Git 追蹤或上傳到您的 GitHub 公開儲存庫。

---

## 🛠️ 後續補充與擴充指南

您可以隨時修改此懶人包以加入新的工具或技能：

### A. 如何新增/更新一個自訂 Skill
如果您未來想下載新的 Skill 放入懶人包：
1. 打開 [setup.ps1](file:///C:/Users/COLA/.gemini/antigravity/scratch/cola-lazy-pack-antigravity/setup.ps1)。
2. 在 **步驟 3: 安裝專屬 Skills / Plugins** 段落底端，模仿 UI-UX Pro Max 加入您的 git clone 指令：
   ```powershell
   # 範例：安裝新技能 my-new-skill
   $myNewSkillPath = "$pluginsDir\my-new-skill"
   if (-not (Test-Path $myNewSkillPath)) {
       git clone https://github.com/username/my-new-skill.git $myNewSkillPath
       Write-Success "my-new-skill 安裝成功！"
   }
   ```

### B. 如何新增新的 MCP 伺服器並使用 API Key
如果未來有新的 MCP 伺服器需要加入：
1. 打開 [templates/mcp_config.template.json](file:///C:/Users/COLA/.gemini/antigravity/scratch/cola-lazy-pack-antigravity/templates/mcp_config.template.json)。
2. 在 `mcpServers` 物件下新增您的 MCP 配置。例如：
   ```json
   "my-mcp-server": {
     "command": "npx",
     "args": ["-y", "my-mcp-package"],
     "env": {
       "MY_API_KEY": "{{MY_NEW_API_KEY}}"
     }
   }
   ```
3. 打開 [setup.ps1](file:///C:/Users/COLA/.gemini/antigravity/scratch/cola-lazy-pack-antigravity/setup.ps1)，在**步驟 5** 中加入互動提示以取得該金鑰：
   ```powershell
   $myNewKey = Read-Host -Prompt "請輸入 My New API Key: "
   ```
4. 在腳本底部的 `-replace` 鏈中，加入取代語法：
   ```powershell
   -replace "\{\{MY_NEW_API_KEY\}\}", $myNewKey
   ```
