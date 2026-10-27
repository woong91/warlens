-- WarLens 데이터베이스 스키마 (Supabase SQL Editor에서 실행)
create table if not exists conflicts (
  id text primary key,
  name_ko text not null,
  started_on date,
  status text,
  summary text
);

create table if not exists weapon_metrics (
  id bigint generated always as identity primary key,
  war text references conflicts(id),
  category text not null,          -- ad(방공) dr(드론) ar(포병·정밀유도) ms(미사일·기갑)
  metric text not null,
  value numeric,
  unit text,
  period text,
  claimant text,                   -- 발표 주체
  verified boolean default false,  -- 독립 검증 여부
  source_url text,
  created_at timestamptz default now()
);

create table if not exists military_strength (
  id bigint generated always as identity primary key,
  war text references conflicts(id),
  party text not null,
  defense_budget_usd_bn numeric,
  budget_gdp_pct numeric,
  active_personnel integer,
  note text,
  source_url text
);

alter table conflicts enable row level security;
alter table weapon_metrics enable row level security;
alter table military_strength enable row level security;
drop policy if exists "public read" on conflicts;
drop policy if exists "public read" on weapon_metrics;
drop policy if exists "public read" on military_strength;
create policy "public read" on conflicts for select using (true);
create policy "public read" on weapon_metrics for select using (true);
create policy "public read" on military_strength for select using (true);

insert into conflicts (id, name_ko, started_on, status, summary) values
 ('ru','러시아–우크라이나 전쟁','2022-02-24','고강도 교전','러시아의 전면 침공 이후 소모전 지속'),
 ('ir','이란 전쟁 (미국·이스라엘–이란)','2026-02-28','휴전 붕괴·저강도 교전','4.8 휴전, 7.8 붕괴'),
 ('hm','이스라엘–하마스·헤즈볼라','2023-10-07','장기화','하마스 기습 이후 장기화')
on conflict (id) do nothing;

insert into weapon_metrics (war, category, metric, value, unit, period, claimant, verified, source_url)
select * from (values
 ('ru','ad','탄도미사일 요격률 (누적)',24,'%','2022.9–2025.10','RUSI',true,'https://www.rusi.org/explore-our-research/publications/commentary/iskander-improved-russian-missile-tests-ukraines-air-defence'),
 ('ru','ad','탄도미사일 요격률',15,'%','2025.1–여름','RUSI',true,'https://www.rusi.org/explore-our-research/publications/commentary/iskander-improved-russian-missile-tests-ukraines-air-defence'),
 ('ru','ad','탄도미사일 요격률',37,'%','2025.6–9','RUSI',true,'https://www.rusi.org/explore-our-research/publications/commentary/iskander-improved-russian-missile-tests-ukraines-air-defence'),
 ('ru','ad','탄도미사일 요격률',0,'%','2026.8.5','우크라이나 공군',false,'https://www.internazionale.it/ultime-notizie-reuters/2026/08/05/ukraine-says-missile-interceptor-deliveries-have-fallen-to-third-of-2025-level'),
 ('ru','dr','샤헤드형 드론 발사',54538,'기','2025','우크라이나 공군 / ISIS',false,'https://isis-online.org/isis-reports/a-comprehensive-analytical-review-of-russian-shahed-type-uavs-deployment-against-ukraine-in-2025'),
 ('ru','dr','드론에 의한 러군 사상 비중 (최대)',75,'%','2025','Inside Stories',false,'https://www.kyivpost.com/post/49712'),
 ('ru','ar','러시아 포탄 사용',27000,'발/일','2025.7','우크라이나군',false,'https://news.liga.net/en/politics/news/russians-use-27-000-artillery-shells-every-day-a-year-ago-it-was-one-and-a-half-times-more'),
 ('ru','ar','엑스칼리버 유효율 (전자전 이후)',6,'%','2024.3','허드슨연구소',true,'https://www.defenseone.com/threats/2024/04/another-us-precision-guided-weapon-falls-prey-russian-electronic-warfare-us-says/396141/'),
 ('ru','ms','러 전차 손실 (영상 확인)',4000,'대','~2025.5','Oryx',true,'https://united24media.com/es/latest-news/rusia-ha-perdido-mas-de-4000-tanques-en-ucrania-confirma-oryx-con-evidencia-visual-8746'),
 ('ir','ad','이란 드론 요격률',99,'%','2025.6','이스라엘 국방당국',false,'https://www.calcalistech.com/ctechnews/article/r1z2xjzbge'),
 ('ir','ad','이란 탄도미사일 요격률',86,'%','2025.6','이스라엘 국방당국',false,'https://www.calcalistech.com/ctechnews/article/r1z2xjzbge'),
 ('ir','ad','이란 탄도미사일 요격률 (추산)',90,'%','2026.2–4','IDF·Times of Israel 집계',false,'https://en.wikipedia.org/wiki/2026_Iranian_strikes_on_Israel'),
 ('ir','ms','이스라엘 향 탄도미사일',650,'발','2026.2.28–4.8','IDF·Times of Israel 집계',false,'https://en.wikipedia.org/wiki/2026_Iranian_strikes_on_Israel'),
 ('hm','ad','아이언돔 요격률 (주장)',98,'%','2023.10–2026.5','라파엘 회장',false,'https://www.al-monitor.com/originals/2026/05/iron-dome-nearly-99-effective-against-incoming-missiles-maker-rafaels-chairman')
) as v(war, category, metric, value, unit, period, claimant, verified, source_url)
where not exists (select 1 from weapon_metrics);

insert into military_strength (war, party, defense_budget_usd_bn, budget_gdp_pct, active_personnel, note, source_url)
select * from (values
 ('ru','러시아',190,7.5,1134000,'SIPRI 추정 / IISS','https://www.sipri.org/sites/default/files/2026-04/2604_milex_2025.pdf'),
 ('ru','우크라이나',84.1,40,800000,'SIPRI 추정 / 젤렌스키','https://www.sipri.org/sites/default/files/2026-04/2604_milex_2025.pdf'),
 ('ir','미국',954,3.1,1285084,'SIPRI / DMDC','https://www.sipri.org/sites/default/files/2026-04/2604_milex_2025.pdf'),
 ('ir','이스라엘',48.3,7.8,169500,'SIPRI / IISS','https://www.sipri.org/sites/default/files/2026-04/2604_milex_2025.pdf'),
 ('ir','이란',7.4,2.1,610000,'SIPRI 공식 예산 / IISS','https://www.sipri.org/sites/default/files/2026-04/2604_milex_2025.pdf'),
 ('hm','하마스',null,null,25000,'CRS 추정','https://www.congress.gov/crs_external_products/IF/PDF/IF12549/IF12549.6.pdf')
) as v(war, party, defense_budget_usd_bn, budget_gdp_pct, active_personnel, note, source_url)
where not exists (select 1 from military_strength);
