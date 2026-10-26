$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot '..\Install-GalaxyBookEnabler.ps1'

function Invoke-ConfigurationMode {
    param(
        [string]$Selector,
        [string]$CountryCode,
        [string]$RegionCode,
        [string]$ConfigurationPath
    )

    $params = @{
        ConfigurationOnly = $true
        FullyAutonomous   = $true
    }

    if ($Selector) { $params.AutonomousModel = $Selector }
    if ($CountryCode) { $params.AutonomousCountryCode = $CountryCode }
    if ($RegionCode) { $params.AutonomousRegion = $RegionCode }
    if ($ConfigurationPath) { $params.ConfigurationPath = $ConfigurationPath }

    & $scriptPath @params
}

function Invoke-AutonomousScript {
    param(
        [string[]]$Arguments
    )

    $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
    $stdoutPath = Join-Path $env:TEMP ("gbe-stdout.{0}.txt" -f [guid]::NewGuid())
    $stderrPath = Join-Path $env:TEMP ("gbe-stderr.{0}.txt" -f [guid]::NewGuid())

    try {
        $process = Start-Process -FilePath $pwsh -ArgumentList (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath) + $Arguments) -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Stdout   = if (Test-Path $stdoutPath) { Get-Content -Path $stdoutPath -Raw } else { '' }
            Stderr   = if (Test-Path $stderrPath) { Get-Content -Path $stderrPath -Raw } else { '' }
        }
    }
    finally {
        if (Test-Path $stdoutPath) { Remove-Item -Path $stdoutPath -Force -ErrorAction SilentlyContinue }
        if (Test-Path $stderrPath) { Remove-Item -Path $stderrPath -Force -ErrorAction SilentlyContinue }
    }
}

function Get-NextNonWhitespaceNode {
    param(
        [System.Xml.XmlNodeList]$Nodes,
        [int]$StartIndex
    )

    for ($i = $StartIndex; $i -lt $Nodes.Count; $i++) {
        $node = $Nodes[$i]
        if ($node.NodeType -ne [System.Xml.XmlNodeType]::Whitespace) {
            return $node
        }
    }

    return $null
}

function Get-NextNodeAfterKey {
    param(
        [System.Xml.XmlElement]$Dict,
        [string]$KeyName
    )

    for ($i = 0; $i -lt $Dict.ChildNodes.Count; $i++) {
        $node = $Dict.ChildNodes[$i]
        if ($node.Name -eq 'key' -and $node.InnerText -eq $KeyName) {
            return Get-NextNonWhitespaceNode -Nodes $Dict.ChildNodes -StartIndex ($i + 1)
        }
    }

    return $null
}

function Get-PlistValueByPath {
    param(
        [xml]$Document,
        [string[]]$Path,
        [string]$Key
    )

    $current = $Document.plist.dict
    foreach ($segment in $Path) {
        $current = Get-NextNodeAfterKey -Dict $current -KeyName $segment
        if (-not $current) {
            return $null
        }
    }

    return Get-NextNodeAfterKey -Dict $current -KeyName $Key
}

Describe 'Install-GalaxyBookEnabler.ps1 configuration mode' {
    It 'accepts family selections and resolves a valid concrete model' {
        $result = Invoke-ConfigurationMode -Selector Book4Pro -CountryCode US

        $result.ResolvedFamily | Should Be 'Galaxy Book4 Pro'
        (@('940XGK', '960XGK') -contains $result.ResolvedModelCode) | Should Be $true
        $result.SystemSKU | Should Match '^SCAI-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-P[A-Z0-9]{3}$'
        $result.BaseBoardProduct | Should Match '^NP(940XGK|960XGK)-KG1US$'
        $result.BIOSVersion | Should Match '^P[0-9]{2}[A-Z0-9]{3}$'
        $result.BIOSVersionFull | Should Be $null
    }

    It 'accepts exact model code selections' {
        $result = Invoke-ConfigurationMode -Selector 960XGL -CountryCode BR

        $result.ResolvedModelCode | Should Be '960XGL'
        $result.ResolvedFamily | Should Be 'Galaxy Book4 Ultra'
        $result.BaseBoardProduct | Should Be 'NP960XGL-XG2BR'
    }

    It 'resolves every shipping model code' {
        $expectedBoardProducts = @{
            '730QFG' = @{ Board = 'NP730QFG-KB1UK'; Country = 'UK' }
            '750QGK' = @{ Board = 'NP750QGK-KG2US'; Country = 'US' }
            '750QHA' = @{ Board = 'NP750QHA-KA1US'; Country = 'US' }
            '750XFG' = @{ Board = 'NP750XFG-KA3SE'; Country = 'SE' }
            '750XFH' = @{ Board = 'NP750XFH-XF1BR'; Country = 'BR' }
            '750XGK' = @{ Board = 'NP750XGK-KG1IT'; Country = 'IT' }
            '750XGL' = @{ Board = 'NP750XGL-XG1BR'; Country = 'BR' }
            '930SBE' = @{ Board = 'NT930SBE-K716'; Country = $null }
            '930XDB' = @{ Board = 'NP930XDB-KF6IT'; Country = 'IT' }
            '935QDC' = @{ Board = 'NP935QDC-KE2US'; Country = 'US' }
            '940XGK' = @{ Board = 'NP940XGK-KG1FR'; Country = 'FR' }
            '940XHA' = @{ Board = 'NP940XHA-KG3IT'; Country = 'IT' }
            '950XGK' = @{ Board = 'NP950XGK-KA2FR'; Country = 'FR' }
            '960QFG' = @{ Board = 'NP964QFG-KA1IT'; Country = 'IT' }
            '960QGK' = @{ Board = 'NP960QGK-KG1IT'; Country = 'IT' }
            '960QHA' = @{ Board = 'NP960QHA-KG2UK'; Country = 'UK' }
            '960XFG' = @{ Board = 'NP960XFG-KC2CL'; Country = 'CL' }
            '960XFH' = @{ Board = 'NP960XFH-XA2BR'; Country = 'BR' }
            '960XGK' = @{ Board = 'NP960XGK-KG1UK'; Country = 'UK' }
            '960XGL' = @{ Board = 'NP960XGL-XG2BR'; Country = 'BR' }
            '960XHA' = @{ Board = 'NP960XHA-KG2DE'; Country = 'DE' }
            # Galaxy Book6 series — real SKU format: P{BiosCode}-{model}-{platform}-0
            '760VJG' = @{ Board = 'NP760VJG-KG5DE'; Country = 'DE'; SkuPattern = '^P[A-Z]{3}-[0-9]{3}[A-Z]{3}-PTL[HU]-0$' }
            '944XJG' = @{ Board = 'NP944XJG-KG5SE'; Country = 'SE'; SkuPattern = '^P[A-Z]{3}-[0-9]{3}[A-Z]{3}-PTL[HU]-0$' }
            '960UJG' = @{ Board = 'NP960UJG-KG2CA'; Country = 'CA'; SkuPattern = '^P[A-Z]{3}-[0-9]{3}[A-Z]{3}-PTL[HU]-0$' }
            '960UJH' = @{ Board = 'NP960UJH-XG7UK'; Country = 'UK'; SkuPattern = '^P[A-Z]{3}-[0-9]{3}[A-Z]{3}-PTL[HU]-0$' }
            '960XJG' = @{ Board = 'NP960XJG-KG2CA'; Country = 'CA'; SkuPattern = '^P[A-Z]{3}-[0-9]{3}[A-Z]{3}-PTL[HU]-0$' }
        }

        foreach ($modelCode in $expectedBoardProducts.Keys) {
            $testCase = $expectedBoardProducts[$modelCode]
            $result = Invoke-ConfigurationMode -Selector $modelCode -CountryCode $testCase.Country

            $result.ResolvedModelCode | Should Be $modelCode
            $result.BaseBoardProduct | Should Be $testCase.Board
            $skuPattern = if ($testCase.SkuPattern) { $testCase.SkuPattern } else { '^SCAI-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-P[A-Z0-9]{3}$' }
            $result.SystemSKU | Should Match $skuPattern
        }
    }

    It 'maps IE to UK' {
        $result = Invoke-ConfigurationMode -Selector Book4Ultra -CountryCode IE

        $result.RegionCode | Should Be 'UK'
    }

    It 'maps US to US' {
        $result = Invoke-ConfigurationMode -Selector Book4Ultra -CountryCode US

        $result.RegionCode | Should Be 'US'
    }

    It 'accepts friendly family names' {
        $result = Invoke-ConfigurationMode -Selector 'Galaxy Book4 Pro' -CountryCode US

        $result.ResolvedFamily | Should Be 'Galaxy Book4 Pro'
        (@('940XGK', '960XGK') -contains $result.ResolvedModelCode) | Should Be $true
    }

    It 'accepts all configured family aliases' {
        $selectors = @(
            @{ Selector = 'Book6Pro'; Expected = 'Galaxy Book6 Pro' },
            @{ Selector = 'Galaxy Book6 Pro'; Expected = 'Galaxy Book6 Pro' },
            @{ Selector = 'Book6Ultra'; Expected = 'Galaxy Book6 Ultra' },
            @{ Selector = 'Galaxy Book6 Ultra'; Expected = 'Galaxy Book6 Ultra' },
            @{ Selector = 'Book6'; Expected = 'Galaxy Book6' },
            @{ Selector = 'Galaxy Book6'; Expected = 'Galaxy Book6' },
            @{ Selector = 'Book5Pro'; Expected = 'Galaxy Book5 Pro' },
            @{ Selector = 'Galaxy Book5 Pro'; Expected = 'Galaxy Book5 Pro' },
            @{ Selector = 'Book5Pro360'; Expected = 'Galaxy Book5 Pro 360' },
            @{ Selector = 'Book5360Pro'; Expected = 'Galaxy Book5 Pro 360' },
            @{ Selector = 'Galaxy Book5 Pro 360'; Expected = 'Galaxy Book5 Pro 360' },
            @{ Selector = 'Book5360'; Expected = 'Galaxy Book5 360' },
            @{ Selector = 'Galaxy Book5 360'; Expected = 'Galaxy Book5 360' },
            @{ Selector = 'Book4Ultra'; Expected = 'Galaxy Book4 Ultra' },
            @{ Selector = 'Galaxy Book4 Ultra'; Expected = 'Galaxy Book4 Ultra' },
            @{ Selector = 'Book4Pro'; Expected = 'Galaxy Book4 Pro' },
            @{ Selector = 'Galaxy Book4 Pro'; Expected = 'Galaxy Book4 Pro' },
            @{ Selector = 'Book4Pro360'; Expected = 'Galaxy Book4 Pro 360' },
            @{ Selector = 'Book4360Pro'; Expected = 'Galaxy Book4 Pro 360' },
            @{ Selector = 'Galaxy Book4 Pro 360'; Expected = 'Galaxy Book4 Pro 360' },
            @{ Selector = 'Book4'; Expected = 'Galaxy Book4' },
            @{ Selector = 'Galaxy Book4'; Expected = 'Galaxy Book4' },
            @{ Selector = 'Book4360'; Expected = 'Galaxy Book4 360' },
            @{ Selector = 'Galaxy Book4 360'; Expected = 'Galaxy Book4 360' },
            @{ Selector = 'Book3Ultra'; Expected = 'Galaxy Book3 Ultra' },
            @{ Selector = 'Galaxy Book3 Ultra'; Expected = 'Galaxy Book3 Ultra' },
            @{ Selector = 'Book3Pro'; Expected = 'Galaxy Book3 Pro' },
            @{ Selector = 'Galaxy Book3 Pro'; Expected = 'Galaxy Book3 Pro' },
            @{ Selector = 'Book3Pro360'; Expected = 'Galaxy Book3 Pro 360' },
            @{ Selector = 'Book3360Pro'; Expected = 'Galaxy Book3 Pro 360' },
            @{ Selector = 'Galaxy Book3 Pro 360'; Expected = 'Galaxy Book3 Pro 360' },
            @{ Selector = 'Book3'; Expected = 'Galaxy Book3' },
            @{ Selector = 'Galaxy Book3'; Expected = 'Galaxy Book3' },
            @{ Selector = 'Book3360'; Expected = 'Galaxy Book3 360' },
            @{ Selector = 'Galaxy Book3 360'; Expected = 'Galaxy Book3 360' },
            @{ Selector = 'Book2ProSpecialEdition'; Expected = 'Galaxy Book2 Pro Special Edition' },
            @{ Selector = 'Book2Pro'; Expected = 'Galaxy Book2 Pro Special Edition' },
            @{ Selector = 'Galaxy Book2 Pro Special Edition'; Expected = 'Galaxy Book2 Pro Special Edition' },
            @{ Selector = 'GalaxyBookSeries'; Expected = 'Galaxy Book Series' },
            @{ Selector = 'Galaxy Book Series'; Expected = 'Galaxy Book Series' },
            @{ Selector = 'Notebook9Series'; Expected = 'Notebook 9 Series' },
            @{ Selector = 'Notebook 9 Series'; Expected = 'Notebook 9 Series' }
        )

        foreach ($selector in $selectors) {
            $result = Invoke-ConfigurationMode -Selector $selector.Selector -CountryCode US
            $result.ResolvedFamily | Should Be $selector.Expected
        }
    }

    It 'accepts selector-style family keys for every configured family' {
        $familyKeys = @(
            'Book6Pro',
            'Book6Ultra',
            'Book6',
            'Book5Pro',
            'Book5Pro360',
            'Book5360',
            'Book4Ultra',
            'Book4Pro',
            'Book4Pro360',
            'Book4',
            'Book4360',
            'Book3Ultra',
            'Book3Pro',
            'Book3Pro360',
            'Book3',
            'Book3360',
            'Book2Pro',
            'GalaxyBookSeries',
            'Notebook9Series'
        )

        foreach ($familyKey in $familyKeys) {
            $result = Invoke-ConfigurationMode -Selector $familyKey -CountryCode US
            $result.ResolvedFamily | Should Not BeNullOrEmpty
        }
    }

    It 'keeps random family resolution within the allowed model set' {
        $families = @(
            @{ Selector = 'Book5Pro'; Models = @('940XHA', '960XHA') },
            @{ Selector = 'Book4Pro'; Models = @('940XGK', '960XGK') },
            @{ Selector = 'Book4'; Models = @('750XGK', '750XGL') },
            @{ Selector = 'Book3'; Models = @('750XFG', '750XFH') },
            @{ Selector = 'GalaxyBookSeries'; Models = @('930XDB', '935QDC') }
        )

        foreach ($family in $families) {
            for ($i = 0; $i -lt 20; $i++) {
                $result = Invoke-ConfigurationMode -Selector $family.Selector -CountryCode US
                ($family.Models -contains $result.ResolvedModelCode) | Should Be $true
            }
        }
    }

    It 'accepts legacy manual parameters' {
        $result = & $scriptPath -Profile Book4Ultra -CountryCode IE -IncludeFullBiosVersion

        $result.ResolvedFamily | Should Be 'Galaxy Book4 Ultra'
        $result.RegionCode | Should Be 'UK'
        $result.BIOSVersionFull | Should Match '^P\d{2}[A-Z0-9]{3}\.\d{3}\.\d{6}\.[A-Z0-9]{2}$'
    }

    It 'updates configuration data and creates a backup' {
        $fixture = Join-Path $PSScriptRoot 'fixtures\config.plist'
        $tempPath = Join-Path $env:TEMP ("config.plist.test.{0}.plist" -f [guid]::NewGuid())

        Copy-Item -Path $fixture -Destination $tempPath -Force

        $result = & $scriptPath -Profile Book4Pro -CountryCode US -WriteConfigPlist -ConfigPath $tempPath

        $result.ConfigurationUpdate | Should Not BeNullOrEmpty
        $result.ConfigurationUpdate.BackupPath | Should Not BeNullOrEmpty
        Test-Path -Path $result.ConfigurationUpdate.BackupPath | Should Be $true

        $updated = [xml](Get-Content -Path $tempPath -Raw)
        $genericProduct = (Get-PlistValueByPath -Document $updated -Path @('PlatformInfo', 'Generic') -Key 'SystemProductName').InnerText
        $smbiosProduct = (Get-PlistValueByPath -Document $updated -Path @('PlatformInfo', 'SMBIOS') -Key 'SystemProductName').InnerText

        $genericProduct | Should Be $result.SystemProductName
        $smbiosProduct | Should Be $result.SystemProductName

        Remove-Item -Path $tempPath, $result.ConfigurationUpdate.BackupPath -Force
    }
}

Describe 'Install-GalaxyBookEnabler.ps1 autonomous package resolution' {
    It 'resolves the core package profile in test mode' {
        $result = Invoke-AutonomousScript -Arguments @(
            '-TestMode',
            '-FullyAutonomous',
            '-AutonomousModel', '960XGL',
            '-AutonomousPackageProfile', 'Core',
            '-AutonomousInstallSsse:$false',
            '-AutonomousConfirmPackages:$true'
        )

        $result.ExitCode | Should Be 0
        $result.Stdout | Should Match 'Samsung Account'
        $result.Stdout | Should Match 'Samsung Settings'
        $result.Stdout | Should Not Match '9PCTGDFXVZLJ'
    }

    It 'resolves the recommended package profile in test mode' {
        $result = Invoke-AutonomousScript -Arguments @(
            '-TestMode',
            '-FullyAutonomous',
            '-AutonomousModel', '960XGL',
            '-AutonomousPackageProfile', 'Recommended',
            '-AutonomousInstallSsse:$false',
            '-AutonomousConfirmPackages:$true'
        )

        $result.ExitCode | Should Be 0
        $result.Stdout | Should Match 'Quick Share'
        $result.Stdout | Should Match '9PCTGDFXVZLJ'
        $result.Stdout | Should Match 'Samsung Notes'
        $result.Stdout | Should Not Match 'Samsung Device Care'
    }

    It 'includes extra-step packages in the full profile' {
        $result = Invoke-AutonomousScript -Arguments @(
            '-TestMode',
            '-FullyAutonomous',
            '-AutonomousModel', '960XGL',
            '-AutonomousPackageProfile', 'Full',
            '-AutonomousInstallSsse:$false',
            '-AutonomousConfirmPackages:$true'
        )

        $result.ExitCode | Should Be 0
        $result.Stdout | Should Match 'Samsung Device Care'
        $result.Stdout | Should Match 'Samsung Phone'
    }

    It 'supports custom packages by id and name' {
        $result = Invoke-AutonomousScript -Arguments @(
            '-TestMode',
            '-FullyAutonomous',
            '-AutonomousModel', '960XGL',
            '-AutonomousPackageProfile', 'Custom',
            '-AutonomousPackageNames', '9P98T77876KZ,SmartThings',
            '-AutonomousInstallSsse:$false',
            '-AutonomousConfirmPackages:$true'
        )

        $result.ExitCode | Should Be 0
        $result.Stdout | Should Match 'Simulating installation of 2 package\(s\)'
        $result.Stdout | Should Match 'Samsung Account'
        $result.Stdout | Should Match 'SmartThings'
    }

    It 'supports skipping package installation' {
        $result = Invoke-AutonomousScript -Arguments @(
            '-TestMode',
            '-FullyAutonomous',
            '-AutonomousModel', '960XGL',
            '-AutonomousPackageProfile', 'Skip',
            '-AutonomousInstallSsse:$false',
            '-AutonomousConfirmPackages:$false'
        )

        $result.ExitCode | Should Be 0
        $result.Stdout | Should Match 'Skipping package installation'
        $result.Stdout | Should Not Match 'Simulating installation of'
    }

    It 'fails on an unknown custom package' {
        $result = Invoke-AutonomousScript -Arguments @(
            '-TestMode',
            '-FullyAutonomous',
            '-AutonomousModel', '960XGL',
            '-AutonomousPackageProfile', 'Custom',
            '-AutonomousPackageNames', 'NotARealPackage',
            '-AutonomousInstallSsse:$false',
            '-AutonomousConfirmPackages:$true'
        )

        $result.ExitCode | Should Not Be 0
        ($result.Stdout + $result.Stderr) | Should Match 'Autonomous package .* was not found'
    }
}

function Get-InstallerFunctionScript {
    param(
        [string[]]$Name
    )

    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $scriptPath).Path, [ref]$null, [ref]$null)
    $functions = $ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $Name -contains $node.Name
        }, $false)

    return [scriptblock]::Create(($functions | ForEach-Object { $_.Extent.Text }) -join [Environment]::NewLine)
}

Describe 'Install-GalaxyBookEnabler.ps1 non-ASCII user profile paths (#127)' {
    # "Žemaitė Ąžuolė" - a Lithuanian-style user folder with a space and non-ASCII characters
    $nonAsciiName = "$([char]0x17D)emait$([char]0x117) $([char]0x104)$([char]0x17E)uol$([char]0x117)"

    function Get-DefaultBiosValues {
        return @{
            BIOSVendor            = 'Default Vendor'
            BIOSVersion           = 'DEFAULT.100.000000.01'
            BIOSMajorRelease      = '0x01'
            BIOSMinorRelease      = '0x01'
            SystemManufacturer    = 'Default Manufacturer'
            SystemFamily          = 'Default Family'
            SystemProductName     = 'DEFAULT'
            ProductSku            = 'DEFAULT-SKU'
            EnclosureKind         = '0x0a'
            BaseBoardManufacturer = 'Default Manufacturer'
            BaseBoardProduct      = 'DEFAULT'
        }
    }

    It 'writes a UTF-8 spoof batch that round-trips from a non-ASCII folder' {
        . (Get-InstallerFunctionScript -Name 'New-RegistrySpoofBatch', 'Get-LegacyBiosValues')

        $installPath = Join-Path $TestDrive "$nonAsciiName\.galaxy-book-enabler"
        New-Item -Path $installPath -ItemType Directory -Force | Out-Null
        $batchPath = Join-Path $installPath 'GalaxyBookSpoof.bat'

        $customFamily = "Galaxy Book4 Ultra $([char]0x17D)"
        New-RegistrySpoofBatch -OutputPath $batchPath -BiosValues @{
            BIOSVendor            = 'American Megatrends International, LLC.'
            BIOSVersion           = 'P08ALX.400.250306.05'
            BIOSMajorRelease      = '0x08'
            BIOSMinorRelease      = '0x11'
            SystemManufacturer    = 'SAMSUNG ELECTRONICS CO., LTD.'
            SystemFamily          = $customFamily
            SystemProductName     = '960XGL'
            ProductSku            = 'SCAI-A5A5-ADLP-PSLP'
            EnclosureKind         = '0x1f'
            BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'
            BaseBoardProduct      = '960XGL'
        }

        Test-Path -LiteralPath $batchPath | Should Be $true

        $bytes = [System.IO.File]::ReadAllBytes($batchPath)
        ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) | Should Be $false

        $lines = [System.IO.File]::ReadAllLines($batchPath, [System.Text.Encoding]::UTF8)
        $lines[0] | Should Be '@echo off'
        $lines[1] | Should Be 'chcp 65001 >nul'

        $legacy = Get-LegacyBiosValues -OldBatchPath $batchPath
        $legacy | Should Not BeNullOrEmpty
        $legacy.Values.SystemFamily | Should Be $customFamily
        $legacy.Values.SystemProductName | Should Be '960XGL'
        # The generated batch names these SystemSKU/EnclosureType, unlike v1 QS.bat
        $legacy.Values.ProductSku | Should Be 'SCAI-A5A5-ADLP-PSLP'
        $legacy.Values.EnclosureKind | Should Be '0x1f'
        $legacy.Values.BIOSMinorRelease | Should Be '0x11'
        $legacy.Values.BIOSVersion | Should Be 'P08ALX.400.250306.05'
    }

    It 'runs a batch file from a non-ASCII folder with the scheduled task quoting' {
        $batchDir = Join-Path $TestDrive "$nonAsciiName\.galaxy-book-enabler"
        New-Item -Path $batchDir -ItemType Directory -Force | Out-Null
        $batchPath = Join-Path $batchDir 'GalaxyBookSpoof.bat'
        $markerPath = Join-Path $batchDir 'ran.txt'

        $batchContent = "@echo off`r`nchcp 65001 >nul`r`necho ok> `"%~dp0ran.txt`"`r`n"
        [System.IO.File]::WriteAllText($batchPath, $batchContent, [System.Text.UTF8Encoding]::new($false))

        # Same command line the GalaxyBookEnabler scheduled task uses
        $cmdPath = Join-Path $env:SystemRoot 'System32\cmd.exe'
        $process = Start-Process -FilePath $cmdPath -ArgumentList "/d /c `"`"$batchPath`"`"" -Wait -PassThru -WindowStyle Hidden

        $process.ExitCode | Should Be 0
        Test-Path -LiteralPath $markerPath | Should Be $true
    }

    It 'writes a Multi Control init script that parses from a non-ASCII folder' {
        . (Get-InstallerFunctionScript -Name 'New-MultiControlInitScript')

        $installPath = Join-Path $TestDrive "$nonAsciiName\.galaxy-book-enabler"
        New-Item -Path $installPath -ItemType Directory -Force | Out-Null
        $initScriptPath = Join-Path $installPath 'Init-SamsungMultiControlOnLogin.ps1'

        New-MultiControlInitScript -OutputPath $initScriptPath

        Test-Path -LiteralPath $initScriptPath | Should Be $true

        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($initScriptPath, [ref]$null, [ref]$parseErrors)
        $parseErrors.Count | Should Be 0
    }

    It 'updates config.plist inside a non-ASCII folder' {
        $fixture = Join-Path $PSScriptRoot 'fixtures\config.plist'
        $plistDir = Join-Path $TestDrive "$nonAsciiName\EFI\OC"
        New-Item -Path $plistDir -ItemType Directory -Force | Out-Null
        $plistPath = Join-Path $plistDir 'config.plist'
        Copy-Item -LiteralPath $fixture -Destination $plistPath -Force

        $result = & $scriptPath -Profile Book4Pro -CountryCode US -WriteConfigPlist -ConfigPath $plistPath

        $result.ConfigurationUpdate | Should Not BeNullOrEmpty
        Test-Path -LiteralPath $result.ConfigurationUpdate.BackupPath | Should Be $true

        $updated = [xml](Get-Content -LiteralPath $plistPath -Raw -Encoding utf8)
        $smbiosProduct = (Get-PlistValueByPath -Document $updated -Path @('PlatformInfo', 'SMBIOS') -Key 'SystemProductName').InnerText
        $smbiosProduct | Should Be $result.SystemProductName
    }
}

Describe 'Install-GalaxyBookEnabler.ps1 Store package install fallback' {
    function Start-Sleep { }
    function Write-GbeLog {
        param([string]$Message, [string]$Level)
        $script:gbeLog += "$Level $Message"
    }

    It 'pins the msstore source and retries a failed install once' {
        . (Get-InstallerFunctionScript -Name 'Test-WingetInstallSucceeded', 'Invoke-StorePackageInstall')

        $script:wingetCalls = @()
        function Invoke-WingetCommand {
            param([string[]]$Arguments, [int]$TimeoutSeconds)
            $script:wingetCalls += , $Arguments
            if ($script:wingetCalls.Count -eq 1) {
                return @{ TimedOut = $false; ExitCode = -2147009247; Output = 'Agreements failed' }
            }
            return @{ TimedOut = $false; ExitCode = 0; Output = 'Successfully installed' }
        }

        $result = Invoke-StorePackageInstall -PackageId '9NFWHCHM52HQ' -PackageName 'Samsung Cloud'

        $result.Attempts | Should Be 2
        $script:wingetCalls.Count | Should Be 2
        ($script:wingetCalls[0] -join ' ') | Should Match '--source msstore'
        Test-WingetInstallSucceeded -Result $result | Should Be $true
    }

    It 'does not retry when the package is not in the Store source' {
        . (Get-InstallerFunctionScript -Name 'Test-WingetInstallSucceeded', 'Invoke-StorePackageInstall')

        $script:wingetCalls = @()
        function Invoke-WingetCommand {
            param([string[]]$Arguments, [int]$TimeoutSeconds)
            $script:wingetCalls += , $Arguments
            return @{ TimedOut = $false; ExitCode = 1; Output = 'No package found matching input criteria.' }
        }

        $result = Invoke-StorePackageInstall -PackageId '9ZZZZZZZZZZZ'

        $result.Attempts | Should Be 1
        Test-WingetInstallSucceeded -Result $result | Should Be $false
    }

    It 'logs a browser link per failed package and opens nothing in autonomous runs' {
        . (Get-InstallerFunctionScript -Name 'Open-StorePackagePages')

        $script:gbeLog = @()
        $script:opened = @()
        function Start-Process { param($FilePath, $ArgumentList) $script:opened += $ArgumentList }

        $script:IsAutonomous = $true
        Open-StorePackagePages -Packages @(
            [pscustomobject]@{ Name = 'Samsung Cloud'; Id = '9NFWHCHM52HQ' },
            [pscustomobject]@{ Name = 'Samsung Settings'; Id = '9P2TBWSHK6HJ' }
        )

        $script:opened.Count | Should Be 0
        ($script:gbeLog -join "`n") | Should Match 'apps\.microsoft\.com/detail/9NFWHCHM52HQ'
        ($script:gbeLog -join "`n") | Should Match 'apps\.microsoft\.com/detail/9P2TBWSHK6HJ'
    }

    It 'opens one browser tab per failed package in interactive runs' {
        . (Get-InstallerFunctionScript -Name 'Open-StorePackagePages')

        $script:gbeLog = @()
        $script:opened = @()
        function Start-Process { param($FilePath, $ArgumentList) $script:opened += $ArgumentList }

        $script:IsAutonomous = $false
        Open-StorePackagePages -Packages @(
            [pscustomobject]@{ Name = 'Samsung Cloud'; Id = '9NFWHCHM52HQ' },
            [pscustomobject]@{ Name = 'Samsung Settings'; Id = '9P2TBWSHK6HJ' }
        )

        $script:opened.Count | Should Be 2
        $script:opened[1] | Should Be 'https://apps.microsoft.com/detail/9P2TBWSHK6HJ'
    }
}

Describe 'Install-GalaxyBookEnabler.ps1 PowerShell host selection (#124)' {
    It 'skips Microsoft Store PowerShell when picking pwsh.exe' {
        . (Get-InstallerFunctionScript -Name 'Get-ClassicPwshPath')

        $storePwsh = Join-Path $TestDrive 'Program Files\WindowsApps\Microsoft.PowerShell_7.6.6.0_x64__8wekyb3d8bbwe\pwsh.exe'
        $classicPwsh = Join-Path $TestDrive 'Program Files\PowerShell\7\pwsh.exe'
        foreach ($path in @($storePwsh, $classicPwsh)) {
            New-Item -Path (Split-Path $path -Parent) -ItemType Directory -Force | Out-Null
            Set-Content -LiteralPath $path -Value '' -Encoding utf8
        }

        Get-ClassicPwshPath -Candidates @($storePwsh, $classicPwsh) | Should Be $classicPwsh
    }

    It 'returns nothing when only Microsoft Store PowerShell is installed' {
        . (Get-InstallerFunctionScript -Name 'Get-ClassicPwshPath')

        $storePwsh = Join-Path $TestDrive 'Program Files\WindowsApps\Microsoft.PowerShell_7.6.6.0_x64__8wekyb3d8bbwe\pwsh.exe'
        $missingPwsh = Join-Path $TestDrive 'Program Files\PowerShell\7-missing\pwsh.exe'
        New-Item -Path (Split-Path $storePwsh -Parent) -ItemType Directory -Force | Out-Null
        Set-Content -LiteralPath $storePwsh -Value '' -Encoding utf8

        Get-ClassicPwshPath -Candidates @($storePwsh, $missingPwsh) | Should BeNullOrEmpty
    }
}

Describe 'Install-GalaxyBookEnabler.ps1 installation health check' {
    It 'looks for the config in the .galaxy-book-enabler folder by default' {
        . (Get-InstallerFunctionScript -Name 'Test-InstallationHealth')

        $command = Get-Command Test-InstallationHealth
        $defaultValue = $command.ScriptBlock.Ast.Body.ParamBlock.Parameters |
            Where-Object { $_.Name.VariablePath.UserPath -eq 'ConfigPath' } |
            ForEach-Object { $_.DefaultValue.Extent.Text }

        $defaultValue | Should Not BeNullOrEmpty
        $defaultValue.Contains('.galaxy-book-enabler\gbe-config.json') | Should Be $true
    }
}
