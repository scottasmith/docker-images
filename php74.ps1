[CmdletBinding()]
Param (
    [bool] $XDebug = $false,
    [String[]] $Ports,
    [String[]] $Networks
)

$ContainerName = ('php74-' + (-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})))

$DockerOptions = @(
    'docker',
    'run',
    ('--name ' + $ContainerName)
    '--rm',
    '-itd',
    '-vcomposer-cache:/home/.composer',
    '-vnpm-cache:/home/.npm',
    ('-v' + (Resolve-Path .\).Path.Trim(' ') + ':/var/www')
);

if ($XDebug) {
    $DockerOptions += ("-e XDEBUG_ENABLED=true")
}

foreach ($PortBinding in $Ports) {
    $DockerOptions += ("-p" + $PortBinding)
}

$DockerOptions += 'docker-registry.dev.onecall.local:444/onecall-php/onecall-php:7.4-stretch-devtools'
$DockerOptions += 'sh'
​
Invoke-Expression -Command ($DockerOptions -join ' ')

foreach ($Network in $Networks) {
    docker network connect $Network $ContainerName
}

docker start -ai $ContainerName
docker stop $ContainerName >$null 2>&1
