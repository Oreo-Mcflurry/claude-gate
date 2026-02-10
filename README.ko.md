<div align="center">

# Claude Gate

**Claude Code를 위한 4단계 품질 게이트 시스템**

버그를 출시하지 마세요. 모든 개발 단계에서 구조화된 리뷰를 강제합니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](pulls)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FOreo-Mcflurry%2Fclaude-gate&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=visitors&edge_flat=false)](https://hits.seeyoufarm.com)

[설치](#설치) | [사용법](#사용법) | [게이트 상세](#게이트-상세) | [English](README.md)

</div>

---

## Claude Gate란?

Claude Gate는 개발 단계 전환 시 **품질 게이트**를 적용하는 Claude Code 플러그인입니다. 다음 단계로 넘어가기 전에 체크리스트 기반의 구조화된 리뷰를 수행하여 결함을 조기에 발견합니다.

```
    기획              설계              개발               검증
 +-----------+    +-----------+    +-----------+      +-----------+
 |           |    |           |    |           |      |           |
 |  요구사항  |    |  아키텍처  |    |   구현    |      |  QA +     |
 |  정의     |--->|  설계     |--->|          |----->|  보안     |
 |           |    |           |    |           |      |           |
 +-----------+    +-----------+    +-----------+      +-----------+
       |                |                |                  |
   Spec Gate       Design Gate      Task Gate         Release Gate
```

각 게이트는 명확한 판정이 포함된 **구조화된 리포트**를 생성합니다: 통과, 수정, 또는 차단.

## 설치

```bash
git clone https://github.com/Oreo-Mcflurry/claude-gate.git
cd claude-gate
./install.sh
```

설치 시 수행되는 작업:

| 단계 | 내용 |
|------|-----|
| 1 | 5개의 전문 리뷰어 에이전트를 `~/.claude/agents/`에 복사 |
| 2 | `/gate` 슬래시 명령어를 `~/.claude/commands/`에 설치 |
| 3 | Gate System 워크플로우 문서를 `CLAUDE.md`에 추가 |

> 제거하려면 `./uninstall.sh`를 실행하세요 - 마커 기반으로 깔끔하게 제거됩니다.

## 사용법

### 빠른 시작

```bash
/gate              # 현재 단계를 자동 감지하여 적절한 게이트 실행
/gate status       # 현재 상태 확인
```

### 특정 게이트 실행

```bash
/gate spec         # 요구사항 및 기획 문서 리뷰
/gate design       # 아키텍처 및 설계 문서 리뷰
/gate code         # 코드 품질 리뷰
/gate release      # 최종 리뷰: 코드 + 보안 (병렬 실행)
```

## 게이트 상세

### Spec Gate `기획 -> 설계`

기획 및 요구사항 문서를 리뷰합니다.

| 체크리스트 항목 | 검사 내용 |
|---------------|----------|
| 요구사항 명확성 | EARS 형식 또는 동등한 구조화된 요구사항 |
| 인수 조건 | Given-When-Then 시나리오 정의 여부 |
| 비기능 요구사항 | 성능, 보안, 확장성 목표 |
| 범위 경계 | 포함/제외 항목의 명시적 정의 |
| 우선순위 정의 | Must / Should / Could (MoSCoW) |

**판정**: `Pass` | `Revise`

---

### Design Gate `설계 -> 개발`

아키텍처 및 설계 문서를 리뷰합니다.

| 체크리스트 항목 | 검사 내용 |
|---------------|----------|
| API 계약 | 엔드포인트, 요청/응답 스키마 |
| 데이터 모델 | 엔티티 정의, 관계 |
| 컴포넌트 의존성 | 서비스 간 상호작용 문서화 |
| 기술 스택 근거 | 각 기술이 선택된 이유 |
| 트레이드오프 문서화 | 고려된 대안과 선택 이유 |

**판정**: `Pass` | `Revise`

---

### Task Gate `개발 -> 검증`

구현 코드를 심각도 레벨별로 리뷰합니다.

| 심각도 | 예시 |
|--------|-----|
| **Critical** | 하드코딩된 시크릿, SQL 인젝션, XSS, 인증 우회 |
| **High** | 누락된 에러 처리, 입력 검증 부재, 안전하지 않은 의존성 |
| **Medium** | 큰 함수, 중복 코드, 누락된 테스트, 부적절한 네이밍 |
| **Performance** | N+1 쿼리, 불필요한 리렌더링, 누락된 메모이제이션 |

**판정**: `Approved` | `Conditional` | `Changes Required`

---

### Release Gate `검증 -> 배포`

최종 게이트. **코드 리뷰 + 보안 감사를 병렬로 수행**합니다.

| 리뷰 유형 | 검사 범위 |
|----------|----------|
| 코드 리뷰 | 모든 Task Gate 검사 항목 (릴리스 수준 정밀도) |
| 보안 감사 | 인증, 입력 검증(SQLi/XSS/SSRF), 데이터 보안, 의존성 감사, AI/ML 보안 |

**판정**: `Pass` | `Conditional` | `Block`

## 판정 요약

| 판정 | 의미 | 조치 |
|------|------|------|
| **Pass** | 모든 검사 통과 | 다음 단계로 진행 |
| **Revise** | 이슈 발견, 수정 가능 | 피드백 반영 후 게이트 재실행 |
| **Block** | 심각한 이슈 발견 | 배포 전 반드시 해결 (Release Gate 전용) |

## 아키텍처

```
claude-gate/
├── agents/
│   ├── gate-keeper.md         # 오케스트레이터 - 단계 감지, 리뷰어 라우팅
│   ├── spec-reviewer.md       # Spec Gate 리뷰어
│   ├── design-reviewer.md     # Design Gate 리뷰어
│   ├── code-reviewer.md       # 코드 품질 리뷰어
│   └── security-reviewer.md   # 보안 감사자
├── commands/
│   └── gate.md                # /gate 슬래시 명령어 정의
├── claude-md-snippet.md       # CLAUDE.md에 자동 추가되는 내용
├── install.sh                 # 원커맨드 설치
├── uninstall.sh               # 깔끔한 제거
├── README.md                  # 영문 문서
└── README.ko.md               # 한국어 문서 (이 파일)
```

## 호환성

| 환경 | 상태 |
|------|------|
| Claude Code (독립 실행) | 완벽 지원 |
| Sisyphus 멀티 에이전트 시스템 | 완벽 호환 |

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI 설치
- `~/.claude/` 디렉토리 존재

## 기여

기여를 환영합니다! 이슈를 열거나 풀 리퀘스트를 제출해주세요.

## 라이선스

[MIT](LICENSE)
