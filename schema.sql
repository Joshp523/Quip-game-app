-- QuipRash schema. Paste into Supabase > SQL Editor > Run. Safe to re-run.
-- Tables are prefixed qp_ so they won't collide with your other apps.

create table if not exists qp_rooms (
  code text primary key,
  prompts jsonb not null default '[]',
  settings jsonb not null default '{}',
  state jsonb not null default '{"phase":"lobby"}',
  created_at timestamptz not null default now()
);

create table if not exists qp_players (
  id uuid primary key default gen_random_uuid(),
  room_code text not null references qp_rooms(code) on delete cascade,
  name text not null,
  score int not null default 0,
  joined_at timestamptz not null default now()
);

-- Profile photos (tiny JPEG data URLs). Safe to run on an existing database.
alter table qp_players add column if not exists pic text;

create table if not exists qp_answers (
  id uuid primary key default gen_random_uuid(),
  room_code text not null references qp_rooms(code) on delete cascade,
  round int not null,
  mi int not null,
  player_id uuid not null references qp_players(id) on delete cascade,
  text text not null,
  unique (room_code, round, mi, player_id)
);

create table if not exists qp_votes (
  id uuid primary key default gen_random_uuid(),
  room_code text not null references qp_rooms(code) on delete cascade,
  round int not null,
  mi int not null,
  voter_id uuid not null references qp_players(id) on delete cascade,
  for_player uuid not null,
  unique (room_code, round, mi, voter_id)
);

-- Server clock in ms, so every device's countdown agrees with the host's.
create or replace function qp_server_time() returns bigint
language sql stable as $$ select (extract(epoch from clock_timestamp()) * 1000)::bigint $$;

-- Party-game security: anyone with the anon key can read/write. Fine for friends, not for secrets.
do $$
declare t text;
begin
  foreach t in array array['qp_rooms','qp_players','qp_answers','qp_votes'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "open" on %I', t);
    execute format('create policy "open" on %I for all to anon, authenticated using (true) with check (true)', t);
    begin
      execute format('alter publication supabase_realtime add table %I', t);
    exception when duplicate_object then null;
    end;
  end loop;
end $$;
