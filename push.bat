@echo off
chcp 65001 >nul
setlocal EnableExtensions

REM ─────────────────────────────────────────────
REM 현재 bat 파일이 있는 폴더(= .git 루트)로 이동
cd /d "%~dp0"

REM 현재 브랜치명 얻기
for /f "usebackq delims=" %%i in (`git rev-parse --abbrev-ref HEAD 2^>nul`) do set "BRANCH=%%i"
if not defined BRANCH (
  echo [.ERR] Git 저장소가 아니거나 git 이 설치되지 않았습니다.
  echo        이 파일은 .git 이 있는 폴더에서 실행해야 합니다.
  goto :PAUSE_END
)

echo.
echo ================== GIT AUTO PUSH (safe rebase) ==================
echo Repo  : %CD%
echo Branch: %BRANCH%
echo =================================================================
echo.

REM 변경사항 스테이징
git add .
if errorlevel 1 goto :ERR_ADD

REM 커밋(변경 없으면 계속 진행). ! / % 등 특수문자 안전하게 처리
setlocal DisableDelayedExpansion
set /p "MSG=Commit message (엔터시 'auto commit'): "
if "%MSG%"=="" set "MSG=auto commit"
git commit -m "%MSG%"
endlocal
if errorlevel 1 (
  echo [info] 커밋할 변경이 없거나 commit 실패. 계속 진행합니다.
)

echo.
echo [1/2] Pull --rebase from origin/%BRANCH% ...
git -c rebase.autoStash=true pull --rebase origin "%BRANCH%"
if errorlevel 1 goto :ERR_PULL

echo.
echo [2/2] Push to origin/%BRANCH% ...
git push origin "%BRANCH%"
if errorlevel 1 goto :ERR_PUSH

echo.
echo === 완료되었습니다. ===
goto :PAUSE_END

:ERR_ADD
echo.
echo [.ERR] git add 실패
goto :PAUSE_END

:ERR_PULL
echo.
echo !!! 충돌 발생 또는 pull 실패 !!!
echo   1^) ^> git status
echo   2^) ^> 충돌 파일 수정
echo   3^) ^> git add ^<file^>
echo   4^) ^> rebase 계속: git rebase --continue
echo        ^  중단:       git rebase --abort
goto :PAUSE_END

:ERR_PUSH
echo.
echo !!! push 거절됨 (non-fast-forward 등) !!!
echo 원격이 다시 앞섰거나, 보호 브랜치 정책일 수 있습니다.
goto :PAUSE_END

:PAUSE_END
echo.
pause
endlocal
