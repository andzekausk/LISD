@echo off
cd /d "%~dp0backend"
start cmd /k "node server.js"

cd /d "%~dp0frontend"
start cmd /k "npm run dev"

start chrome http://localhost:5173/
