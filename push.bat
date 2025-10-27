@echo off
REM ============================================
REM git add, commit, push 자동 실행 bat 파일
REM bat 파일을 .git 이 존재하는 폴더에 넣고 실행하세요
REM ============================================

:: 현재 bat 파일이 있는 폴더로 이동
cd /d %~dp0

:: 변경 사항 추가
git add .

:: 커밋 메시지 입력받기
set /p msg="Commit message: "

:: 커밋 실행 (입력한 메시지가 없으면 기본 메시지 사용)
if "%msg%"=="" (
    git commit -m "auto commit"
) else (
    git commit -m "%msg%"
)

:: 원격 저장소로 푸시 (기본 브랜치를 main 으로 가정)
git push origin main

pause
