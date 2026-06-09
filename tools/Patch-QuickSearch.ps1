param(
    [string]$QuickSearchPath,
    [string]$CecilPath,
    [switch]$Restore,
    [switch]$SkipAdminCheck,
    [switch]$NoLaunch,
    [switch]$InstallShortcut,
    [switch]$RemoveShortcut,
    [switch]$Export,
    [switch]$RegisterProtocol,
    [switch]$UnregisterProtocol
)

$ScriptName = "Patch-QuickSearch.ps1"
$CecilVersion = "0.11.6"
$CecilDir = "$env:TEMP\Mono.Cecil.$CecilVersion"
$CecilDll = "$CecilDir\lib\netstandard2.0\Mono.Cecil.dll"
$CecilNupkg = "$env:TEMP\Mono.Cecil.$CecilVersion.nupkg"
$CecilUrl = "https://www.nuget.org/api/v2/package/Mono.Cecil/$CecilVersion"

$AppxBase = "$env:ProgramFiles\WindowsApps"
$BackupDir = Join-Path $env:TEMP "GalaxyBookEnabler-Backups"
$CacheDir = Join-Path $env:TEMP "GalaxyBookEnabler-QuickSearchRun"
$ExportDir = Join-Path $env:LOCALAPPDATA "GalaxyBookEnabler\QuickSearch"

$Host.UI.RawUI.WindowTitle = "GalaxyBookEnabler - QuickSearch Patcher"

function Write-Info  { Write-Host "  $($args[0])" -ForegroundColor Cyan }
function Write-Ok   { Write-Host "  $($args[0])" -ForegroundColor Green }
function Write-Warn { Write-Host "  $($args[0])" -ForegroundColor Yellow }
function Write-Err  { Write-Host "  $($args[0])" -ForegroundColor Red }

function Find-QuickSearch {
    param([string]$Path)
    if ($Path) {
        if (Test-Path $Path) { return (Resolve-Path $Path).Path }
        Write-Err "Path not found: $Path"
        return $null
    }
    $pkg = Get-AppxPackage -Name "SAMSUNGELECTRONICSCO.LTD.SamsungQuickSearch" -ErrorAction SilentlyContinue
    if (-not $pkg) {
        Write-Err "Samsung Quick Search AppX package not found."
        Write-Info  "Ensure Samsung Quick Search is installed."
        return $null
    }
    $smartDir = "$($pkg.InstallLocation)\SmartSearch"
    $exePath = "$smartDir\QuickSearch.exe"
    if (-not (Test-Path $exePath)) {
        Write-Err "QuickSearch.exe not found at: $exePath"
        return $null
    }
    Write-Ok "Found: $exePath"
    return @{Exe = $exePath; SmartDir = $smartDir}
}

function Get-MonoCecil {
    if ($CecilPath -and (Test-Path $CecilPath)) {
        Write-Ok "Using Mono.Cecil from: $CecilPath"
        return $CecilPath
    }
    if (Test-Path $CecilDll) {
        Write-Ok "Mono.Cecil already downloaded"
        return $CecilDll
    }
    Write-Info "Downloading Mono.Cecil v$CecilVersion from NuGet..."
    try {
        if (-not (Test-Path $CecilDir)) { New-Item -ItemType Directory -Path $CecilDir -Force | Out-Null }
        Invoke-WebRequest -Uri $CecilUrl -OutFile $CecilNupkg -UseBasicParsing -ErrorAction Stop
        Expand-Archive -Path $CecilNupkg -DestinationPath $CecilDir -Force
        if (-not (Test-Path $CecilDll)) {
            Write-Err "Mono.Cecil.dll not found after extraction"
            return $null
        }
        Write-Ok "Mono.Cecil ready: $CecilDll"
        return $CecilDll
    } catch {
        Write-Err "Failed to download Mono.Cecil: $_"
        return $null
    }
}

function Sync-Cache {
    param([string]$SmartDir)
    if (-not (Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
    $needsSync = $false
    if (-not (Test-Path "$CacheDir\QuickSearch.exe")) {
        $needsSync = $true
    } else {
        $srcFiles = Get-ChildItem $SmartDir -Recurse
        $changed = $srcFiles | Where-Object {
            $dst = Join-Path $CacheDir $_.Name
            (-not (Test-Path $dst)) -or ((Get-Item $dst).Length -ne $_.Length) -or ((Get-Item $dst).LastWriteTime -ne $_.LastWriteTime)
        }
        if ($changed) { $needsSync = $true }
    }
    if ($needsSync) {
        Write-Info "Syncing QuickSearch files to cache..."
        Remove-Item "$CacheDir\*" -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($file in (Get-ChildItem $SmartDir)) {
            Copy-Item -LiteralPath $file.FullName -Destination $CacheDir -ErrorAction SilentlyContinue
        }
        Write-Ok "Cache synced ($((Get-ChildItem $CacheDir).Count) files)"
    } else {
        Write-Ok "Cache already in sync"
    }
    return "$CacheDir\QuickSearch.exe"
}

function Invoke-Patch {
    param(
        [string]$ExePath,
        [string]$CecilDllPath
    )
    Write-Info "Patching QuickSearch.exe (IsSamsungPC, NeedToInstallService), CommunicationManager.dll (InitializeFileSystemAPI), and VisionAISDK.Core.dll (VisionAI..cctor)..."

    $csharpCode = @"
using System;
using Mono.Cecil;
using Mono.Cecil.Cil;

public class QuickSearchPatcher
{
    private static void PatchToReturn(AssemblyDefinition asm, string typeName, string methodName, bool returnVal)
    {
        foreach (var t in asm.MainModule.Types)
        {
            if (t.FullName != typeName) continue;
            foreach (var m in t.Methods)
            {
                if (m.Name != methodName || !m.HasBody) continue;
                m.Body.ExceptionHandlers.Clear();
                var il = m.Body.GetILProcessor();
                il.Clear();
                il.Emit(returnVal ? OpCodes.Ldc_I4_1 : OpCodes.Ldc_I4_0);
                il.Emit(OpCodes.Ret);
                m.Body.MaxStackSize = 1;
                m.Body.Variables.Clear();
                m.Body.InitLocals = true;
                return;
            }
        }
    }

    private static void PatchToEmptyVoidMethod(AssemblyDefinition asm, string typeName, string methodName)
    {
        foreach (var t in asm.MainModule.Types)
        {
            if (t.FullName != typeName) continue;
            foreach (var m in t.Methods)
            {
                if (m.Name != methodName || !m.HasBody) continue;
                m.Body.ExceptionHandlers.Clear();
                var il = m.Body.GetILProcessor();
                il.Clear();
                il.Emit(OpCodes.Ret);
                m.Body.MaxStackSize = 1;
                m.Body.Variables.Clear();
                m.Body.InitLocals = true;
                return;
            }
        }
    }

    public static string Patch(string exePath)
    {
        AssemblyDefinition asm = null;
        try
        {
            asm = AssemblyDefinition.ReadAssembly(exePath, new ReaderParameters { ReadWrite = true });

            int patchedCount = 0;

            // IsSamsungPC → return true (bypass Samsung hardware check)
            PatchToReturn(asm, "Samsung.SmartSearchApp.SmartSearch.Utils.AppUtil", "IsSamsungPC", true);

            // NeedToInstallService → return false (skip service installation UI)
            PatchToReturn(asm, "Samsung.SmartSearchApp.SmartSearch.Utils.ServiceUtil", "NeedToInstallService", false);

            // Verify patches
            foreach (var t in asm.MainModule.Types)
            {
                foreach (var m in t.Methods)
                {
                    if (!m.HasBody) continue;
                    if (t.FullName == "Samsung.SmartSearchApp.SmartSearch.Utils.AppUtil" && m.Name == "IsSamsungPC")
                    {
                        if (m.Body.Instructions.Count == 2 && m.Body.Instructions[0].OpCode == OpCodes.Ldc_I4_1 && m.Body.Instructions[1].OpCode == OpCodes.Ret)
                            patchedCount++;
                    }
                    if (t.FullName == "Samsung.SmartSearchApp.SmartSearch.Utils.ServiceUtil" && m.Name == "NeedToInstallService")
                    {
                        if (m.Body.Instructions.Count == 2 && m.Body.Instructions[0].OpCode == OpCodes.Ldc_I4_0 && m.Body.Instructions[1].OpCode == OpCodes.Ret)
                            patchedCount++;
                    }
                }
            }

            if (patchedCount == 2) { asm.Write(); return "OK"; }
            return "ERR:Only patched " + patchedCount + " of 2 methods";
        }
        catch (Exception ex)
        {
            return "ERR:" + ex.Message;
        }
        finally
        {
            if (asm != null) asm.Dispose();
        }
    }

    public static string PatchDll(string dllPath)
    {
        AssemblyDefinition asm = null;
        try
        {
            asm = AssemblyDefinition.ReadAssembly(dllPath, new ReaderParameters { ReadWrite = true });

            int patchedCount = 0;

            // InitializeFileSystemAPI → empty body (prevent COM crash when service not installed)
            PatchToEmptyVoidMethod(asm, "Samsung.SmartSearchApp.Communication.CommunicationManager.APIWrapper.FileSystemAPIWrapper", "InitializeFileSystemAPI");

            // Verify patch
            foreach (var t in asm.MainModule.Types)
            {
                foreach (var m in t.Methods)
                {
                    if (!m.HasBody) continue;
                    if (t.FullName == "Samsung.SmartSearchApp.Communication.CommunicationManager.APIWrapper.FileSystemAPIWrapper" && m.Name == "InitializeFileSystemAPI")
                    {
                        if (m.Body.Instructions.Count == 1 && m.Body.Instructions[0].OpCode == OpCodes.Ret)
                            patchedCount++;
                    }
                }
            }

            if (patchedCount == 1) { asm.Write(); return "OK"; }
            return "ERR:Only patched " + patchedCount + " of 1 method";
        }
        catch (Exception ex)
        {
            return "ERR:" + ex.Message;
        }
        finally
        {
            if (asm != null) asm.Dispose();
        }
    }

    public static string PatchDllVisionAI(string dllPath)
    {
        AssemblyDefinition asm = null;
        try
        {
            var resolver = new DefaultAssemblyResolver();
            var dllDir = System.IO.Path.GetDirectoryName(dllPath);
            resolver.AddSearchDirectory(dllDir);
            // Samsung AI Select Service ships Windows API contract .winmd files
            var samsungWinMDPath = @"C:\Program Files\Samsung\AI Select Service";
            if (System.IO.Directory.Exists(samsungWinMDPath))
                resolver.AddSearchDirectory(samsungWinMDPath);
            asm = AssemblyDefinition.ReadAssembly(dllPath, new ReaderParameters { ReadWrite = true, AssemblyResolver = resolver });

            int patchedCount = 0;

            // VisionAI..cctor → empty body (prevent ONNX Runtime crash from fire-and-forget Task.Run)
            PatchToEmptyVoidMethod(asm, "VisionAISDK.Core.VisionAI", ".cctor");

            // Verify patch
            foreach (var t in asm.MainModule.Types)
            {
                foreach (var m in t.Methods)
                {
                    if (!m.HasBody) continue;
                    if (t.FullName == "VisionAISDK.Core.VisionAI" && m.Name == ".cctor")
                    {
                        if (m.Body.Instructions.Count == 1 && m.Body.Instructions[0].OpCode == OpCodes.Ret)
                            patchedCount++;
                    }
                }
            }

            if (patchedCount == 1) { asm.Write(); return "OK"; }
            return "ERR:Only patched " + patchedCount + " of 1 method";
        }
        catch (Exception ex)
        {
            return "ERR:" + ex.Message;
        }
        finally
        {
            if (asm != null) asm.Dispose();
        }
    }
}
"@
    try {
        [System.Reflection.Assembly]::LoadFrom($CecilDllPath) | Out-Null
        $netstandardPath = Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) "netstandard.dll"
        Add-Type -ReferencedAssemblies $CecilDllPath, $netstandardPath `
                 -TypeDefinition $csharpCode -Language CSharp -ErrorAction Stop | Out-Null
    } catch {
        Write-Err "Failed to compile C# patcher: $($_.Exception.Message)"
        return $false
    }

    $exeResult = [QuickSearchPatcher]::Patch($ExePath)
    if ($exeResult -ne "OK") {
        Write-Err $exeResult
        return $false
    }

    # Also patch CommunicationManager.dll to prevent COM crash
    $commDll = Join-Path (Split-Path $ExePath -Parent) "CommunicationManager.dll"
    $totalPatched = 2  # exe patches
    if (Test-Path $commDll) {
        $dllResult = [QuickSearchPatcher]::PatchDll($commDll)
        if ($dllResult -ne "OK") {
            Write-Err $dllResult
            return $false
        }
        $totalPatched++
    } else {
        Write-Warn "CommunicationManager.dll not found at $commDll — COM crash patch skipped"
    }

    # Also patch VisionAISDK.Core.dll to prevent ONNX Runtime crash
    $visionDll = Join-Path (Split-Path $ExePath -Parent) "VisionAISDK.Core.dll"
    if (Test-Path $visionDll) {
        $visionResult = [QuickSearchPatcher]::PatchDllVisionAI($visionDll)
        if ($visionResult -ne "OK") {
            Write-Err $visionResult
            return $false
        }
        $totalPatched++
    } else {
        Write-Warn "VisionAISDK.Core.dll not found at $visionDll — ONNX crash patch skipped"
    }

    Write-Ok "Patching complete: $totalPatched methods patched (exe: 2, dll: $($totalPatched - 2))"
    return $true
}

function Backup-Source {
    param([string]$Path)
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    $backupPath = Join-Path $BackupDir "QuickSearch.exe.backup"
    if (Test-Path $backupPath) {
        $srcHash = (Get-FileHash $Path -Algorithm MD5).Hash
        $bakHash = (Get-FileHash $backupPath -Algorithm MD5).Hash
        if ($srcHash -eq $bakHash) {
            Write-Ok "Backup already exists and matches source"
            return
        }
    }
    try {
        Copy-Item $Path $backupPath -Force
        Write-Ok "Source backup created: $backupPath"
    } catch {
        Write-Err "Failed to create backup: $_"
    }
}

function Install-StartMenuShortcut {
    param([string]$TargetExe)

    $startMenu = [Environment]::GetFolderPath("StartMenu")
    $shortcutPath = Join-Path $startMenu "Programs\QuickSearch.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)

    if ($TargetExe -and (Test-Path $TargetExe)) {
        $shortcut.TargetPath = $TargetExe
        $shortcut.Arguments = ""
        $shortcut.WorkingDirectory = Split-Path $TargetExe -Parent
        $shortcut.IconLocation = "$TargetExe, 0"
    } else {
        $psExe = if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }
        $shortcut.TargetPath = $psExe
        $shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`" -SkipAdminCheck"
        $shortcut.WorkingDirectory = Split-Path $PSCommandPath -Parent

        $iconPath = $null
        $qsResult = Find-QuickSearch -ErrorAction SilentlyContinue 2>$null
        if ($qsResult) { $iconPath = $qsResult.Exe }
        if ($iconPath -and (Test-Path $iconPath)) {
            $shortcut.IconLocation = "$iconPath, 0"
        }
    }

    $shortcut.Save()

    # Clean up old subfolder shortcut
    $oldShortcut = Join-Path $startMenu "Programs\GalaxyBookEnabler\QuickSearch Launcher.lnk"
    if (Test-Path $oldShortcut) { Remove-Item $oldShortcut -Force }
    $oldDir = Join-Path $startMenu "Programs\GalaxyBookEnabler"
    if (Test-Path $oldDir) {
        $remaining = Get-ChildItem $oldDir -ErrorAction SilentlyContinue
        if (-not $remaining -or $remaining.Count -eq 0) { Remove-Item $oldDir -Force -ErrorAction SilentlyContinue }
    }

    Write-Ok "Shortcut created: $shortcutPath"
}

function Remove-StartMenuShortcut {
    $startMenu = [Environment]::GetFolderPath("StartMenu")
    $paths = @(
        Join-Path $startMenu "Programs\QuickSearch.lnk"
        Join-Path $startMenu "Programs\GalaxyBookEnabler\QuickSearch Launcher.lnk"
    )

    $removed = $false
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Remove-Item $p -Force
            Write-Ok "Removed: $p"
            $removed = $true
        }
    }

    # Clean up old directory if empty
    $oldDir = Join-Path $startMenu "Programs\GalaxyBookEnabler"
    if (Test-Path $oldDir) {
        $remaining = Get-ChildItem $oldDir -ErrorAction SilentlyContinue
        if (-not $remaining -or $remaining.Count -eq 0) {
            Remove-Item $oldDir -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not $removed) {
        Write-Warn "No shortcut found to remove."
    }
}

function Register-ProtocolHandler {
    param([string]$TargetExe)

    if (-not $TargetExe -or -not (Test-Path $TargetExe)) {
        Write-Err "Target executable not found. Run -Export first."
        return $false
    }

    $protocol = "ss-ffs"
    $classesRoot = "HKCU:\SOFTWARE\Classes"
    $protocolKey = Join-Path $classesRoot $protocol

    # Create protocol root
    if (-not (Test-Path $protocolKey)) {
        New-Item -Path $protocolKey -Force | Out-Null
    }
    Set-ItemProperty -Path $protocolKey -Name "(default)" -Value "URL:$protocol"
    Set-ItemProperty -Path $protocolKey -Name "URL Protocol" -Value ""

    # Create shell\open\command
    $commandKey = Join-Path $protocolKey "shell\open\command"
    if (-not (Test-Path $commandKey)) {
        New-Item -Path $commandKey -Force | Out-Null
    }

    $command = "`"$TargetExe`" `"%1`""
    Set-ItemProperty -Path $commandKey -Name "(default)" -Value $command

    Write-Ok "Protocol ss-ffs:// registered to: $TargetExe"
    Write-Info  "Galaxy Book Experience will now launch patched QuickSearch."
    return $true
}

function Unregister-ProtocolHandler {
    $protocolKey = "HKCU:\SOFTWARE\Classes\ss-ffs"
    if (Test-Path $protocolKey) {
        Remove-Item $protocolKey -Recurse -Force
        Write-Ok "Protocol ss-ffs:// unregistered"
        return $true
    }
    Write-Warn "No ss-ffs protocol registration found."
    return $false
}

function Export-ToPermanent {
    param(
        [string]$SmartDir,
        [string]$CecilDllPath
    )

    if (-not (Test-Path $ExportDir)) {
        New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
    }

    Write-Info "Exporting QuickSearch to: $ExportDir"

    Remove-Item "$ExportDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($file in (Get-ChildItem $SmartDir)) {
        Copy-Item -LiteralPath $file.FullName -Destination $ExportDir -ErrorAction SilentlyContinue
    }
    Write-Ok "Exported $((Get-ChildItem $ExportDir).Count) files"

    $exportExe = Join-Path $ExportDir "QuickSearch.exe"

    $patchResult = Invoke-Patch -ExePath $exportExe -CecilDllPath $CecilDllPath
    if (-not $patchResult) {
        Write-Err "Patch failed during export!"
        return $false
    }

    $fi = Get-Item $exportExe
    Write-Ok "Verified: $($fi.Name) patched ($($fi.Length) bytes)"

    Install-StartMenuShortcut -TargetExe $exportExe
    Register-ProtocolHandler -TargetExe $exportExe
    Write-Ok "Export complete. QuickSearch is now installed permanently."
    Write-Info  "You can uninstall the Samsung Quick Search AppX package."
    Write-Info  "Run '$ScriptName -Export' again after AppX updates to refresh."

    return $true
}

# ============================================================
# MAIN
# ============================================================
Write-Info "======================================"
Write-Info " GalaxyBookEnabler - QuickSearch Launcher"
Write-Info "======================================"
Write-Info ""

if ($RemoveShortcut) {
    Unregister-ProtocolHandler
    Remove-StartMenuShortcut
    exit 0
}

if ($InstallShortcut) {
    $exportExe = Join-Path $ExportDir "QuickSearch.exe"
    if (Test-Path $exportExe) {
        Install-StartMenuShortcut -TargetExe $exportExe
        Register-ProtocolHandler -TargetExe $exportExe
    } else {
        Install-StartMenuShortcut
    }
    exit 0
}

if ($Restore) {
    $backupPath = Join-Path $BackupDir "QuickSearch.exe.backup"
    if (Test-Path $backupPath) {
        Write-Ok "Backup found: $backupPath ($((Get-Item $backupPath).Length) bytes)"
        Write-Info "To restore, run: Copy-Item `"$backupPath`" `"<QuickSearch.exe path>`" -Force"
        Write-Info "This will restore the original file in the AppX package."
        exit 0
    }
    Write-Err "No backup found at $backupPath"
    exit 1
}

if ($RegisterProtocol) {
    $exportExe = Join-Path $ExportDir "QuickSearch.exe"
    if (-not (Test-Path $exportExe)) {
        Write-Err "No exported QuickSearch found. Run -Export first."
        exit 1
    }
    Register-ProtocolHandler -TargetExe $exportExe
    exit 0
}

if ($UnregisterProtocol) {
    Unregister-ProtocolHandler
    exit 0
}

# -------------------------------------------------------
# Export mode: copy from AppX → permanent location + patch
# -------------------------------------------------------
if ($Export) {
    $qs = Find-QuickSearch -Path $QuickSearchPath
    if (-not $qs) { exit 1 }

    $cecilDll = Get-MonoCecil
    if (-not $cecilDll) { exit 1 }

    Export-ToPermanent -SmartDir $qs.SmartDir -CecilDllPath $cecilDll
    exit 0
}

# -------------------------------------------------------
# Check for existing export (no AppX needed)
# -------------------------------------------------------
$exportExe = Join-Path $ExportDir "QuickSearch.exe"
if (Test-Path $exportExe) {
    Write-Info "Found exported QuickSearch at $ExportDir"
    Write-Info "Launching..."

    Start-Process -FilePath $exportExe -WorkingDirectory $ExportDir
    Write-Ok "QuickSearch launched (PID unknown, process detached)."
    exit 0
}

# -------------------------------------------------------
# Cache-based launch (requires AppX)
# -------------------------------------------------------
$qs = Find-QuickSearch -Path $QuickSearchPath
if (-not $qs) { exit 1 }

$cecilDll = Get-MonoCecil
if (-not $cecilDll) { exit 1 }

Backup-Source -Path $qs.Exe

$cacheExe = Sync-Cache -SmartDir $qs.SmartDir

$patchResult = Invoke-Patch -ExePath $cacheExe -CecilDllPath $cecilDll
if (-not $patchResult) {
    Write-Err "Patch failed!"
    exit 1
}

$fi = Get-Item $cacheExe
Write-Ok "Verified: QuickSearch.exe patched ($($fi.Length) bytes)"

if (-not $NoLaunch) {
    Write-Info ""
    Write-Info "Launching QuickSearch (patched)..."
    Write-Info "Cache dir: $CacheDir"
    Write-Info "Close QuickSearch to clean up cache."
    Write-Info ""

    $p = [System.Diagnostics.Process]::Start(@{
        FileName = $cacheExe
        WorkingDirectory = $CacheDir
    })

    Write-Ok "QuickSearch running (PID: $($p.Id))"
    $p.WaitForExit()

    Write-Info "QuickSearch closed. Cleaning up cache..."
    Remove-Item $CacheDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Ok "Cache cleaned up"
} else {
    Write-Info ""
    Write-Info "Patched file ready at: $cacheExe"
    Write-Info "Use -NoLaunch to disable automatic launch."
}

Write-Info ""
Write-Ok "======================================"
Write-Ok " Done!"
Write-Ok "======================================"
exit 0
