﻿Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
Write-Output "Cloning lab materials"
git clone -q --branch=master https://github.com/sqlcollaborative/appveyor-lab.git C:\github\appveyor-lab
