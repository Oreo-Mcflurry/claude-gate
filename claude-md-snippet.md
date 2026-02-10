<!-- GATE-SYSTEM-START -->
## Gate System (4-Phase Quality Gates)

Phase 전환 시 `/gate` 커맨드로 품질 게이트 리뷰를 수행합니다.

### 워크플로우
1. 기획 완료 → `/gate spec` → Spec Gate 통과 후 설계 시작
2. 설계 완료 → `/gate design` → Design Gate 통과 후 개발 시작
3. 개발 완료 → `/gate code` → Task Gate 통과 후 검증 시작
4. 검증 완료 → `/gate release` → Release Gate 통과 후 배포/머지

### 사용법
- `/gate` — 현재 Phase 자동 감지 후 적절한 Gate 실행
- `/gate spec` — Spec Gate (요구사항 리뷰)
- `/gate design` — Design Gate (설계 리뷰)
- `/gate code` — Task Gate (코드 리뷰)
- `/gate release` — Release Gate (코드 + 보안 리뷰)
- `/gate status` — 전체 Gate 상태 확인

### Gate 결과 해석
- **Pass**: 다음 Phase로 진행
- **Revise**: 피드백 반영 후 재심사
- **Block**: 심각한 이슈 해결 필수 (Release Gate만)
<!-- GATE-SYSTEM-END -->
