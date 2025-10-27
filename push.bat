@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM bat 파일이 있는 폴더(= .git 있는 루트)로 이동
cd /d "%~dp0"

REM 현재 브랜치명 얻기
for /f "usebackq delims=" %%i in (`git rev-parse --abbrev-ref HEAD`) do set BRANCH=%%i

echo.
echo ==== GIT AUTO PUSH (safe rebase) ====
echo Repo: %CD%
echo Branch: %BRANCH%
echo ================================

REM 변경사항 스테이징
git add .

REM 커밋 메시지 입력 (엔터만 치면 auto commit)
set /p MSG=Commit message (leave empty for "auto commit"): 
if "%MSG%"=="" set MSG=auto commit
git commit -m "%MSG%" 2>nul
REM (변경이 없으면 "nothing to commit"이라도 계속 진행)

echo.
echo [1/2] Pull --rebase from origin/%BRANCH% ...
REM rebase 시 로컬 변경이 있으면 자동 스태시 후 복원
git -c rebase.autoStash=true pull --rebase origin %BRANCH%
if errorlevel 1 (
  echo.
  echo !!! 충돌 발생 또는 pull 실패 !!!
  echo 아래 명령으로 충돌을 해결한 뒤 다시 실행하세요:
  echo   - git status
  echo   - 충돌 파일 수정 후: git add <file>
  echo   - rebase 계속:      git rebase --continue
  echo   - 필요시 중단:      git rebase --abort
  echo 완료 후 bat를 다시 실행하세요.
  pause
  exit /b 1
)

echo.
echo [2/2] Push to origin/%BRANCH% ...
git push origin %BRANCH%
if errorlevel 1 (
  echo.
  echo !!! push 거절됨 (non-fast-forward 등) !!!
  echo 원격이 다시 앞섰거나, 보호 브랜치 정책일 수 있습니다.
  echo 필요 시 강제 갱신은 'push_force.bat' 사용을 검토하세요. (주의)
  pause
  exit /b 1
)

echo.
echo === 완료되었습니다. ===
pause
endlocal
