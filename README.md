# trade_report

트레이딩 일지(`journal/`)와 일간 리포트(`daily-report/`)를 관리하고, 변경 사항을 정해진 시각에 GitHub로 자동 push하는 저장소입니다.

**운영 환경: Windows 10/11**

## 디렉터리 구조

```
trade_report/
├── daily-report/              # 일간 리포트 (마크다운, 이미지 등)
├── journal/                   # 일지 (날짜별 마크다운 등)
├── scripts/
│   ├── sync-to-github.bat     # Git add / commit / push (Windows bat)
│   ├── run_scheduled_sync.py  # 스케줄러 (12:00, 16:00, 20:00)
│   └── start-scheduler.bat    # 스케줄러 실행
├── requirements.txt
└── README.md
```

## 동작 요약

| 항목 | 설명 |
|------|------|
| 대상 폴더 | `daily-report/`, `journal/` (하위 **모든 파일**) |
| push 시각 | 매일 **12:00**, **16:00**, **20:00** (PC 로컬 시계) |
| 변경 없음 | 해당 시각에 commit/push **하지 않음** |
| 인증 | Git **HTTPS** |

---

## 사전 요구 사항

- **Windows 10/11**
- [Git for Windows](https://git-scm.com/download/win) (Git Bash 포함)
- [Python 3.10+](https://www.python.org/downloads/) — 설치 시 **“Add python.exe to PATH”** 체크
- [GitHub CLI](https://cli.github.com/) (선택, HTTPS 인증에 편리)
- GitHub 계정 및 저장소 **쓰기(write)** 권한

---

## 초기 설정

### 1. 저장소 받기

**PowerShell** 또는 **명령 프롬프트**에서:

```powershell
git clone <repository-url>
cd trade_report
```

이미 로컬에 있다면:

```powershell
cd <repository-root>
git remote -v
```

`origin`이 HTTPS가 아니면:

```powershell
git remote set-url origin https://github.com/<owner>/<repository>.git
```

### 2. Git HTTPS 인증

토큰·비밀번호는 **저장소에 커밋하지 마세요.** PC에만 저장합니다.

**방법 A — GitHub CLI (권장)**

```powershell
gh auth login
```

GitHub.com → HTTPS → 브라우저 또는 토큰으로 로그인합니다.

**방법 B — Personal Access Token**

1. GitHub → Settings → Developer settings → Personal access tokens 에서 토큰 발급 (`repo` 권한)
2. `git push` 시 비밀번호 대신 **토큰** 입력
3. Windows 자격 증명 관리자에 저장되도록 Git Credential Manager 사용 (Git for Windows 기본 포함)

### 3. Python 가상환경

```powershell
cd <repository-root>

python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
```

### 4. (선택) 최초 수동 push

```cmd
scripts\sync-to-github.bat
```

`daily-report/`, `journal/`에 변경이 없으면 아무 작업도 하지 않고 종료합니다.

---

## 스케줄러 실행

매일 12:00 · 16:00 · 20:00에 `sync-to-github.bat`를 호출합니다. 창을 닫으면 스케줄러가 종료됩니다.

### 포그라운드 (테스트·확인용)

```powershell
.\scripts\start-scheduler.bat
```

종료: 창에서 `Ctrl+C`

### 로그인 시 자동 실행 (권장)

**작업 스케줄러**로 `start-scheduler.bat`을 등록합니다.

1. `Win + R` → `taskschd.msc` 실행
2. **작업 만들기** → 이름: `trade_report sync`
3. **트리거** → 새로 만들기 → **로그온할 때**
4. **동작** → 새로 만들기:
   - 프로그램: `<repository-root>\scripts\start-scheduler.bat`
   - 시작 위치: `<repository-root>`
5. **조건** 탭 → “컴퓨터의 AC 전원일 때만” 해제 (노트북인 경우)
6. 저장

로그: `<repository-root>\logs\scheduler.log`

### 수동 동기화 (즉시 1회)

```cmd
scripts\sync-to-github.bat
```

---

## 스케줄 시간 변경

`scripts/run_scheduled_sync.py`의 `SYNC_TIMES`를 수정한 뒤 스케줄러를 재시작합니다.

```python
SYNC_TIMES = ("12:00", "16:00", "20:00")
```

24시간 형식(`HH:MM`)이며, Windows **로컬 시계**를 따릅니다.

---

## 환경 변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `GIT_BRANCH` | 현재 체크아웃 브랜치 | push 대상 브랜치 |

**명령 프롬프트** 예:

```cmd
set GIT_BRANCH=main
scripts\sync-to-github.bat
```

---

## 문제 해결

| 증상 | 확인 사항 |
|------|-----------|
| `Authentication failed` | `gh auth login` 또는 PAT·Windows 자격 증명 관리자 확인 |
| `rejected` / non-fast-forward | 다른 PC에서 push 여부 확인 후 `git pull --rebase` 후 재시도 |
| 스케줄러가 안 돌아감 | 작업 스케줄러 실행 기록, `logs\scheduler.log` 확인 |
| `ModuleNotFoundError: schedule` | `.venv` 생성 및 `pip install -r requirements.txt` |
| push는 됐는데 파일이 없음 | 파일이 `daily-report\` 또는 `journal\` 안에 있는지 확인 |
| `python`을 찾을 수 없음 | Python 설치 시 PATH 추가 여부, 터미널 재시작 |

---

## 보안 · 주의사항

- **API 토큰, 비밀번호, `.env` 등은 커밋하지 마세요.**
- 자동 커밋 메시지 형식: `auto: sync YYYY-MM-DD HH:MM:SS`
- `daily-report/`, `journal/` **밖**의 파일은 자동 스크립트 대상이 아닙니다.
- 로컬에서 파일을 삭제하면, 다음 sync 시 그 삭제도 원격에 반영됩니다.

---

## 라이선스

저장소 루트의 [LICENSE](LICENSE) 파일을 참고하세요.
