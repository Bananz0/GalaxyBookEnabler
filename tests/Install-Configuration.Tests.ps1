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
        }

        foreach ($modelCode in $expectedBoardProducts.Keys) {
            $testCase = $expectedBoardProducts[$modelCode]
            $result = Invoke-ConfigurationMode -Selector $modelCode -CountryCode $testCase.Country

            $result.ResolvedModelCode | Should Be $modelCode
            $result.BaseBoardProduct | Should Be $testCase.Board
            $result.SystemSKU | Should Match '^SCAI-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-P[A-Z0-9]{3}$'
        }
    }

    It 'maps IE to UK' {
        $result = Invoke-ConfigurationMode -Selector Book4Ultra -CountryCode IE

        $result.RegionCode | Should Be 'UK'
    }

    It 'accepts friendly family names' {
        $result = Invoke-ConfigurationMode -Selector 'Galaxy Book4 Pro' -CountryCode US

        $result.ResolvedFamily | Should Be 'Galaxy Book4 Pro'
        (@('940XGK', '960XGK') -contains $result.ResolvedModelCode) | Should Be $true
    }

    It 'accepts all configured family aliases' {
        $selectors = @(
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
