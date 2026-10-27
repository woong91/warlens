// Vercel 서버리스 함수: Supabase의 무기 효과 지표를 JSON으로 반환
// 예: /api/metrics?war=ru
module.exports = async function handler(req, res) {
  const url = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) return res.status(503).json({ error: 'Supabase가 아직 연결되지 않았습니다.' });
  const war = typeof req.query.war === 'string' ? req.query.war.replace(/[^a-z]/g, '') : '';
  const q = `${url}/rest/v1/weapon_metrics?select=*&order=war.asc,category.asc${war ? `&war=eq.${war}` : ''}`;
  const r = await fetch(q, { headers: { apikey: key, Authorization: `Bearer ${key}` } });
  res.setHeader('Cache-Control', 's-maxage=300');
  return res.status(r.status).json(await r.json());
}
