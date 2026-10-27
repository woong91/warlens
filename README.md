# WarLens

최근 전쟁 현황, 무기별 효과, 전쟁의 변화, 전쟁의 역사를 정리한 전쟁 분석 사이트.

- **GitHub**: 이 저장소의 `main` 브랜치에 커밋하면
- **Vercel**: 자동으로 다시 배포되고 (`index.html` + `api/` 서버리스 함수)
- **Supabase**: `schema.sql`의 테이블(`conflicts`, `weapon_metrics`, `military_strength`)을 `/api/health`, `/api/metrics`가 읽습니다.

Supabase 접속 정보(`SUPABASE_URL`, `SUPABASE_ANON_KEY`)는 Vercel–Supabase 연동이 환경 변수로 자동 설정합니다. 코드에 키를 넣지 마세요.
