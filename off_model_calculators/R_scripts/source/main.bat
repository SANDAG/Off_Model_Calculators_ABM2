@ECHO off
SET rPath="C:/Program Files/R/R-3.4.1/bin/x64"
SET modelPath="T:/RTP/2019RP/rp19_scen/abm_runs_bod/r scripts off-model/source"

%rPath%\Rscript.exe %modelPath%\main.R "T:/RTP/2019RP/rp19_scen/abm_runs_bod/r scripts off-model/test.properties" 
