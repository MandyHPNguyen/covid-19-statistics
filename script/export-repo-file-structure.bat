@echo off
setlocal

rem Define source directory of tree
set tree_dir="%cd:~0,2%\GitHub_Repos\covid-19-stats"

rem Set temporary initial result directory
set temp_result="%cd:~0,2%\GitHub_Repos\covid-19-stats\pages\repo-file-structure.txt"

rem Set final cleaned result directory
set final_result="%cd:~0,2%\GitHub_Repos\covid-19-stats\pages\repo-file-structure.md"

rem Set timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "fullstamp=%YYYY%/%MM%/%DD% %HH%:%Min%:%Sec%"

rem Export temporary result
tree "%tree_dir%" /a > "%temp_result%"

rem Create final file with timestamp and text
echo --------- COVID-19 3-Year Look Back by Mandy HP Nguyen --------- > "%final_result%"
echo: >> "%final_result%"
echo GitHub's Repository File Structure >> "%final_result%"
echo Updated by %fullstamp% >> "%final_result%"
echo: >> "%final_result%"
echo:
echo covid-19-stats >> "%final_result%"
echo ``` >> "%final_result%"
more +3 "%temp_result%" >> "%final_result%"
echo ``` >> "%final_result%"

rem Delete temporary file
del "%temp_result%"

pause
