[CmdletBinding()]
param(
    [string]$WorkRoot = $(if ($env:PERSONA2_WORK_ROOT) { $env:PERSONA2_WORK_ROOT } else { Join-Path $env:TEMP 'persona2-cbctt' }),
    [string]$Gxx = 'g++.exe',
    [string]$BoostLibrary = 'boost_program_options',
    [int]$VirtualTimeout = 192,
    [switch]$SkipBuild,
    [switch]$ResetResults
)

$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$solverRoot = Join-Path $WorkRoot 'cb-ctt'
$easyLocalRoot = Join-Path $WorkRoot 'easylocal-3'
$buildRoot = Join-Path $WorkRoot 'build'
$stagedSolutions = Join-Path $WorkRoot 'solutions'
$resultsFile = Join-Path $scriptRoot 'results.csv'
$logRoot = Join-Path $scriptRoot 'logs'
$solutionRoot = Join-Path $scriptRoot 'solutions'
$solverExe = Join-Path $buildRoot 'ctt.exe'

$instances = @(
    'comp01', 'comp02', 'comp03', 'comp04', 'comp05', 'comp06', 'comp07',
    'comp08', 'comp09', 'comp10', 'comp12', 'comp13', 'comp14', 'comp16',
    'comp17', 'comp18', 'comp19', 'comp20', 'comp21'
)
$seeds = 0, 1, 2
$header = 'instance,seed,objective,violations,reported_time_s,wall_time_s,method,virtual_timeout_s,solver_commit,easylocal_commit,compiler,exit_code,log_path,solution_path'

function Convert-ToCsvField {
    param([AllowNull()][object]$Value)
    $text = if ($null -eq $Value) { '' } else { [string]$Value }
    if ($text.Contains(',') -or $text.Contains('"') -or $text.Contains("`n") -or $text.Contains("`r")) {
        return '"' + $text.Replace('"', '""') + '"'
    }
    return $text
}

function Invoke-GitClone {
    param([string]$Url, [string]$Destination)
    if (-not (Test-Path -LiteralPath (Join-Path $Destination '.git'))) {
        git clone $Url $Destination
        if ($LASTEXITCODE -ne 0) { throw "No se pudo clonar $Url" }
    }
}

New-Item -ItemType Directory -Force -Path $WorkRoot, $buildRoot, $stagedSolutions, $logRoot, $solutionRoot | Out-Null
Invoke-GitClone 'https://github.com/iolab-uniud/cb-ctt.git' $solverRoot

if (-not (Test-Path -LiteralPath (Join-Path $easyLocalRoot '.git'))) {
    git clone 'https://bitbucket.org/satt/easylocal-3.git' $easyLocalRoot
    if ($LASTEXITCODE -ne 0) {
        git clone 'https://github.com/iolab-uniud/easylocal.git' $easyLocalRoot
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo clonar EasyLocal++ 3' }
    }
}

if (-not $SkipBuild) {
    $sources = @(
        (Join-Path $solverRoot 'src/CTT_Data.cc'),
        (Join-Path $solverRoot 'src/CTT_Helpers.cc'),
        (Join-Path $solverRoot 'src/CTT_Main.cc')
    )
    $compileArgs = @(
        '-Wall', '-Wfatal-errors', '-Wno-deprecated-declarations',
        '-std=c++17', '-O3', '-DENHANCED',
        "-I$(Join-Path $easyLocalRoot 'include')"
    ) + $sources + @("-l$BoostLibrary", '-o', $solverExe)
    & $Gxx @compileArgs
    if ($LASTEXITCODE -ne 0) { throw 'La compilación del solver ha fallado' }
}

if (-not (Test-Path -LiteralPath $solverExe)) { throw "No existe el ejecutable $solverExe" }

if ($ResetResults -or -not (Test-Path -LiteralPath $resultsFile)) {
    Set-Content -LiteralPath $resultsFile -Value $header -Encoding utf8
}

$solverCommit = (git -C $solverRoot rev-parse HEAD).Trim()
$easyLocalCommit = (git -C $easyLocalRoot rev-parse HEAD).Trim()
$compiler = ((& $Gxx --version | Select-Object -First 1) -replace ',', ' ').Trim()
$existing = @(Import-Csv -LiteralPath $resultsFile)
$validExisting = @($existing | Where-Object {
    $_.exit_code -eq '0' -and
    $_.violations -eq '0' -and
    $_.objective -match '^\d+$' -and
    $_.reported_time_s -match '^\d+(\.\d+)?$' -and
    (Test-Path -LiteralPath (Join-Path $scriptRoot $_.log_path)) -and
    (Test-Path -LiteralPath (Join-Path $scriptRoot $_.solution_path))
})

if ($validExisting.Count -ne $existing.Count) {
    Write-Host 'Se eliminarán las filas incompletas antes de reanudarse la campaña'
    $lines = @($header)
    foreach ($saved in $validExisting) {
        $line = @(
            $saved.instance, $saved.seed, $saved.objective, $saved.violations,
            $saved.reported_time_s, $saved.wall_time_s, $saved.method,
            $saved.virtual_timeout_s, $saved.solver_commit, $saved.easylocal_commit,
            $saved.compiler, $saved.exit_code, $saved.log_path, $saved.solution_path
        ) | ForEach-Object { Convert-ToCsvField $_ }
        $lines += ($line -join ',')
    }
    Set-Content -LiteralPath $resultsFile -Value $lines -Encoding utf8
}
$existing = $validExisting

Push-Location $WorkRoot
try {
    foreach ($instance in $instances) {
        foreach ($seed in $seeds) {
            if ($existing | Where-Object { $_.instance -eq $instance -and [int]$_.seed -eq $seed }) {
                Write-Host "Omitida $instance semilla $seed porque ya existe en results.csv"
                continue
            }

            $logRelative = "logs/${instance}_seed${seed}.log"
            $solutionRelative = "solutions/${instance}_seed${seed}.sol"
            $logFile = Join-Path $scriptRoot $logRelative
            $finalSolution = Join-Path $scriptRoot $solutionRelative
            $stagedSolution = Join-Path $stagedSolutions "${instance}_seed${seed}.sol"
            $instancePath = "cb-ctt/instances/comp/${instance}.ectt"
            $solverArgs = @(
                '--main::instance', $instancePath,
                '--main::method', 'BHC-KSA',
                '--main::seed', [string]$seed,
                '--main::output_file', $stagedSolution,
                '--main::virtual_timeout', [string]$VirtualTimeout,
                '--main::mwd_bias', '0.202',
                '--main::critical_course_bias', '0.122',
                '--main::critical_course_threshold', '3',
                '--main::stability_bias', '0.146',
                '--main::swap_bias', '0.803',
                '--KSA::start_temperature', '5.394',
                '--KSA::min_temperature', '0.069',
                '--KSA::cooling_rate', '0.988',
                '--KSA::neighbors_accepted_ratio', '0.133'
            )

            $timer = [Diagnostics.Stopwatch]::StartNew()
            $output = & $solverExe @solverArgs 2>&1
            $exitCode = $LASTEXITCODE
            $timer.Stop()
            $output | Set-Content -LiteralPath $logFile -Encoding utf8

            $summary = $output | Where-Object { $_ -match "^${instance};" } | Select-Object -Last 1
            $fields = if ($summary) { @($summary -split ';\s*') } else { @() }
            $objective = if ($fields.Count -gt 5 -and $fields[5] -match '^\d+$') { $fields[5] } else { '' }
            $violations = if ($fields.Count -gt 4 -and $fields[4] -match '^\d+$') { $fields[4] } else { '' }
            $reportedTime = if ($fields.Count -gt 7 -and $fields[7] -match '^\d+(\.\d+)?$') { $fields[7] } else { '' }
            $wallTime = $timer.Elapsed.TotalSeconds.ToString('F6', [Globalization.CultureInfo]::InvariantCulture)

            if (Test-Path -LiteralPath $stagedSolution) {
                Copy-Item -LiteralPath $stagedSolution -Destination $finalSolution -Force
            }

            $row = @(
                $instance, $seed, $objective, $violations, $reportedTime, $wallTime,
                'BHC-KSA', $VirtualTimeout, $solverCommit, $easyLocalCommit,
                $compiler, $exitCode, $logRelative, $solutionRelative
            ) | ForEach-Object { Convert-ToCsvField $_ }
            Add-Content -LiteralPath $resultsFile -Value ($row -join ',') -Encoding utf8

            Write-Host "$instance semilla $seed coste=$objective violaciones=$violations salida=$exitCode"
        }
    }
}
finally {
    Pop-Location
}

