@echo off

set "key=HKLM\HARDWARE\DESCRIPTION\System\BIOS"
set "values=BaseBoardManufacturer BaseBoardProduct SystemProductName SystemFamily SystemManufacturer"
set "data=SAMSUNG ELECTRONICS CO., LTD. NP960XFH-XA2UK NP960XFH-XA2UK Galaxy Book3 Ultra SAMSUNG ELECTRONICS CO., LTD."

for %%a in (%values%) do (
    for /f "tokens=1,* delims= " %%b in ('echo %data%') do (
        reg add "%key%" /v %%a /t REG_SZ /d "%%b" /f
        set "data=%%c"
    )
)
