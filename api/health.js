// Vercel 서버리스 함수: Supabase 연결 상태 확인
// 환경 변수는 Vercel–Supabase 연동이 자동으로 넣어 줍니다.
module.exports = async function handler(req, res) {
  const url = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) return res.status(200).json({ ok: false, reason: 'missing_env' });
  try {
    const r = await fetch(`${url}/rest/v1/weapon_metrics?select=id`, {
      headers: { apikey: key, Authorization: `Bearer ${key}`, Prefer: 'count=exact', Range: '0-0' },
    });
    const range = r.headers.get('content-range') || '';
    const total = Number(range.split('/')[1]) || 0;
    res.setHeader('Cache-Control', 's-maxage=60');
    return res.status(200).json({ ok: r.ok, weapon_metrics: total });
  } catch (e) {
    return res.status(200).json({ ok: false, reason: 'fetch_failed' });
  }
}
