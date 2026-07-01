create table habit_logs (
  id bigint generated always as identity primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  status text not null,
  message text
);
-- 誰でも認証なしでインサートできるようにRLSを一時オフにする（デモ用割り切り）
alter table habit_logs disable row level security;