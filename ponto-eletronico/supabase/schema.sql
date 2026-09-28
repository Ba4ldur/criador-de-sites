-- Ponto Attivare — banco de dados (Supabase / PostgreSQL)
--
-- Como usar: no painel do Supabase, abra "SQL Editor", cole este arquivo
-- inteiro e clique em "Run". Pode rodar de novo sem perder dados.
--
-- Segurança: o app acessa o banco só pelas funções abaixo (RPC).
-- As tabelas ficam fechadas para a chave pública (RLS ligado, sem políticas).
-- O horário de cada marcação é o do servidor (now()), não o do celular.

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------------

create table if not exists public.funcionarios (
  id          uuid primary key default gen_random_uuid(),
  codigo      text not null unique check (codigo ~ '^[A-Za-z0-9]{1,20}$'),
  nome        text not null check (length(trim(nome)) > 0),
  pin_hash    text not null,
  admin       boolean not null default false,
  ativo       boolean not null default true,
  criado_em   timestamptz not null default now()
);

create table if not exists public.sessoes (
  token_hash      bytea primary key,
  funcionario_id  uuid not null references public.funcionarios(id) on delete cascade,
  criada_em       timestamptz not null default now(),
  expira_em       timestamptz not null
);

create table if not exists public.tentativas_login (
  codigo         text primary key,
  falhas         int not null default 0,
  bloqueado_ate  timestamptz
);

-- Marcações nunca são apagadas. Correções ficam registradas:
-- anulação (anulada_em/anulada_por/motivo) e inclusão manual (origem = 'ajuste').
-- Entrada/saída é deduzida pela ordem das marcações válidas de cada dia.
create table if not exists public.marcacoes (
  id              bigint generated always as identity primary key,
  funcionario_id  uuid not null references public.funcionarios(id),
  momento         timestamptz not null default now(),
  registrado_em   timestamptz not null default now(),
  origem          text not null default 'app' check (origem in ('app', 'ajuste')),
  distancia_m     int,
  precisao_m      int,
  registrado_por  uuid references public.funcionarios(id),
  motivo          text,
  anulada_em      timestamptz,
  anulada_por     uuid references public.funcionarios(id),
  motivo_anulacao text
);
create index if not exists marcacoes_func_momento on public.marcacoes (funcionario_id, momento);

create table if not exists public.config (
  id              int primary key default 1 check (id = 1),
  fuso            text not null default 'America/Sao_Paulo',
  nome_local      text,
  lat             double precision,
  lng             double precision,
  raio_m          int not null default 150 check (raio_m between 20 and 5000),
  precisao_max_m  int not null default 150 check (precisao_max_m between 10 and 5000)
);
insert into public.config (id) values (1) on conflict (id) do nothing;

alter table public.funcionarios      enable row level security;
alter table public.sessoes           enable row level security;
alter table public.tentativas_login  enable row level security;
alter table public.marcacoes         enable row level security;
alter table public.config            enable row level security;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on public.funcionarios, public.sessoes, public.tentativas_login,
                  public.marcacoes, public.config from anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    revoke all on public.funcionarios, public.sessoes, public.tentativas_login,
                  public.marcacoes, public.config from authenticated;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Funções internas (não expostas ao app)
-- ---------------------------------------------------------------------------

create or replace function public._fuso() returns text
language sql stable security definer set search_path = public, extensions as $$
  select fuso from public.config where id = 1
$$;

create or replace function public._sessao(p_token text)
returns public.funcionarios
language plpgsql security definer set search_path = public, extensions as $$
declare
  f public.funcionarios;
begin
  select fu.* into f
    from public.sessoes s
    join public.funcionarios fu on fu.id = s.funcionario_id
   where s.token_hash = sha256(convert_to(coalesce(p_token, ''), 'UTF8'))
     and s.expira_em > now()
     and fu.ativo;
  if f.id is null then
    raise exception 'Sessão expirada. Entre de novo com seu código e PIN.' using errcode = 'P0001';
  end if;
  return f;
end $$;

create or replace function public._admin(p_token text)
returns public.funcionarios
language plpgsql security definer set search_path = public, extensions as $$
declare
  f public.funcionarios := public._sessao(p_token);
begin
  if not f.admin then
    raise exception 'Apenas administradores podem fazer isso.' using errcode = 'P0001';
  end if;
  return f;
end $$;

-- Marcações válidas de um funcionário num intervalo, com tipo deduzido por dia.
create or replace function public._marcacoes_json(p_func uuid, p_ini timestamptz, p_fim timestamptz)
returns json
language sql stable security definer set search_path = public, extensions as $$
  with z as (select public._fuso() as tz),
  base as (
    select m.*,
           (m.momento at time zone z.tz)::date as dia,
           row_number() over (partition by (m.momento at time zone z.tz)::date order by m.momento, m.id) as ordem
      from public.marcacoes m, z
     where m.funcionario_id = p_func
       and m.anulada_em is null
       and m.momento >= p_ini and m.momento < p_fim
  )
  select coalesce(json_agg(json_build_object(
           'id', id,
           'momento', momento,
           'dia', dia,
           'tipo', case when ordem % 2 = 1 then 'entrada' else 'saida' end,
           'origem', origem,
           'motivo', motivo,
           'distancia_m', distancia_m
         ) order by momento, id), '[]'::json)
    from base
$$;

create or replace function public._hoje(p_func uuid) returns json
language sql stable security definer set search_path = public, extensions as $$
  select public._marcacoes_json(
    p_func,
    (date_trunc('day', now() at time zone public._fuso())) at time zone public._fuso(),
    (date_trunc('day', now() at time zone public._fuso()) + interval '1 day') at time zone public._fuso()
  )
$$;

create or replace function public._mes_intervalo(p_mes text, out ini timestamptz, out fim timestamptz)
language plpgsql stable security definer set search_path = public, extensions as $$
declare
  d date;
begin
  if p_mes !~ '^\d{4}-\d{2}$' then
    raise exception 'Mês inválido. Use o formato AAAA-MM.' using errcode = 'P0001';
  end if;
  d := to_date(p_mes || '-01', 'YYYY-MM-DD');
  ini := d::timestamp at time zone public._fuso();
  fim := (d + interval '1 month')::timestamp at time zone public._fuso();
end $$;

-- Cria ou troca o PIN de um funcionário. Uso no SQL Editor (primeiro admin).
create or replace function public.criar_funcionario(p_codigo text, p_nome text, p_pin text, p_admin boolean default false)
returns uuid
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_id uuid;
begin
  if p_pin !~ '^\d{4,8}$' then
    raise exception 'O PIN deve ter de 4 a 8 números.' using errcode = 'P0001';
  end if;
  insert into public.funcionarios (codigo, nome, pin_hash, admin)
  values (upper(trim(p_codigo)), trim(p_nome), crypt(p_pin, gen_salt('bf')), p_admin)
  on conflict (codigo) do update
    set nome = excluded.nome, pin_hash = excluded.pin_hash, admin = excluded.admin, ativo = true
  returning id into v_id;
  return v_id;
end $$;

-- ---------------------------------------------------------------------------
-- Funções do app (chamadas pela chave pública)
-- ---------------------------------------------------------------------------

create or replace function public.entrar(p_codigo text, p_pin text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_cod text := upper(trim(coalesce(p_codigo, '')));
  t public.tentativas_login;
  f public.funcionarios;
  v_token text;
begin
  select * into t from public.tentativas_login where codigo = v_cod;
  if t.bloqueado_ate is not null and t.bloqueado_ate > now() then
    raise exception 'Muitas tentativas erradas. Tente de novo às %.',
      to_char(t.bloqueado_ate at time zone public._fuso(), 'HH24:MI') using errcode = 'P0001';
  end if;

  select * into f from public.funcionarios where codigo = v_cod and ativo;
  if f.id is null or f.pin_hash <> crypt(coalesce(p_pin, ''), f.pin_hash) then
    insert into public.tentativas_login (codigo, falhas) values (v_cod, 1)
    on conflict (codigo) do update
      set falhas = case when tentativas_login.bloqueado_ate is not null
                             and tentativas_login.bloqueado_ate <= now()
                        then 1 else tentativas_login.falhas + 1 end,
          bloqueado_ate = case when (case when tentativas_login.bloqueado_ate is not null
                                              and tentativas_login.bloqueado_ate <= now()
                                         then 1 else tentativas_login.falhas + 1 end) >= 5
                               then now() + interval '15 minutes' else null end;
    -- Sem "raise": a exceção desfaria o registro da tentativa.
    return json_build_object('erro', 'Código ou PIN incorreto.');
  end if;

  delete from public.tentativas_login where codigo = v_cod;
  delete from public.sessoes where funcionario_id = f.id and expira_em < now();

  v_token := encode(gen_random_bytes(32), 'hex');
  insert into public.sessoes (token_hash, funcionario_id, expira_em)
  values (sha256(convert_to(v_token, 'UTF8')), f.id, now() + interval '90 days');

  return json_build_object('token', v_token, 'nome', f.nome, 'admin', f.admin);
end $$;

create or replace function public.sair(p_token text)
returns void
language sql security definer set search_path = public, extensions as $$
  delete from public.sessoes where token_hash = sha256(convert_to(coalesce(p_token, ''), 'UTF8'))
$$;

create or replace function public.situacao(p_token text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  f public.funcionarios := public._sessao(p_token);
  c public.config;
begin
  select * into c from public.config where id = 1;
  return json_build_object(
    'nome', f.nome,
    'codigo', f.codigo,
    'admin', f.admin,
    'agora', now(),
    'fuso', c.fuso,
    'cerca', c.lat is not null,
    'nome_local', c.nome_local,
    'raio_m', c.raio_m,
    'hoje', public._hoje(f.id)
  );
end $$;

create or replace function public.registrar(p_token text, p_lat double precision, p_lng double precision, p_precisao double precision)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  f public.funcionarios := public._sessao(p_token);
  c public.config;
  v_ultima timestamptz;
  v_dist double precision;
  v_hoje json;
begin
  select * into c from public.config where id = 1;

  if c.lat is not null then
    if p_lat is null or p_lng is null then
      raise exception 'Não foi possível obter sua localização. Permita o acesso à localização e tente de novo.' using errcode = 'P0001';
    end if;
    if p_precisao is not null and p_precisao > c.precisao_max_m then
      raise exception 'Sinal de localização fraco (precisão de % m). Vá para perto de uma janela ou área aberta e tente de novo.',
        round(p_precisao) using errcode = 'P0001';
    end if;
    -- Distância pela fórmula de haversine (raio médio da Terra: 6.371 km).
    v_dist := 2 * 6371000 * asin(sqrt(
        power(sin(radians(p_lat - c.lat) / 2), 2)
      + cos(radians(c.lat)) * cos(radians(p_lat)) * power(sin(radians(p_lng - c.lng) / 2), 2)
    ));
    if v_dist > c.raio_m then
      raise exception 'Você está a % m do local de trabalho. O ponto só pode ser registrado a até % m.',
        round(v_dist), c.raio_m using errcode = 'P0001';
    end if;
  end if;

  select max(momento) into v_ultima
    from public.marcacoes
   where funcionario_id = f.id and anulada_em is null;
  if v_ultima is not null and now() - v_ultima < interval '1 minute' then
    raise exception 'Você registrou há menos de 1 minuto. Se foi engano, use "Desfazer".' using errcode = 'P0001';
  end if;

  insert into public.marcacoes (funcionario_id, distancia_m, precisao_m, registrado_por)
  values (f.id, round(v_dist), round(p_precisao), f.id);

  v_hoje := public._hoje(f.id);
  return json_build_object('agora', now(), 'hoje', v_hoje);
end $$;

-- O funcionário pode desfazer a própria marcação feita há menos de 2 minutos.
create or replace function public.desfazer(p_token text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  f public.funcionarios := public._sessao(p_token);
  v_id bigint;
begin
  select id into v_id
    from public.marcacoes
   where funcionario_id = f.id and anulada_em is null and origem = 'app'
     and registrado_em > now() - interval '2 minutes'
   order by momento desc, id desc
   limit 1;
  if v_id is null then
    raise exception 'Só é possível desfazer uma marcação feita há menos de 2 minutos.' using errcode = 'P0001';
  end if;
  update public.marcacoes
     set anulada_em = now(), anulada_por = f.id, motivo_anulacao = 'Desfeita pelo funcionário'
   where id = v_id;
  return json_build_object('agora', now(), 'hoje', public._hoje(f.id));
end $$;

create or replace function public.meus_horarios(p_token text, p_mes text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  f public.funcionarios := public._sessao(p_token);
  i record;
begin
  select * into i from public._mes_intervalo(p_mes);
  return public._marcacoes_json(f.id, i.ini, i.fim);
end $$;

-- ---------------------------------------------------------------------------
-- Funções de administração
-- ---------------------------------------------------------------------------

create or replace function public.admin_funcionarios(p_token text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform public._admin(p_token);
  return (
    select coalesce(json_agg(json_build_object(
             'id', id, 'codigo', codigo, 'nome', nome, 'admin', admin, 'ativo', ativo
           ) order by ativo desc, nome), '[]'::json)
      from public.funcionarios
  );
end $$;

create or replace function public.admin_salvar_funcionario(
  p_token text, p_id uuid, p_codigo text, p_nome text, p_pin text, p_admin boolean, p_ativo boolean)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  me public.funcionarios := public._admin(p_token);
  v_cod text := upper(trim(coalesce(p_codigo, '')));
  v_id uuid;
begin
  if v_cod !~ '^[A-Z0-9]{1,20}$' then
    raise exception 'O código deve ter só letras e números (até 20).' using errcode = 'P0001';
  end if;
  if length(trim(coalesce(p_nome, ''))) = 0 then
    raise exception 'Informe o nome.' using errcode = 'P0001';
  end if;
  if p_pin is not null and p_pin <> '' and p_pin !~ '^\d{4,8}$' then
    raise exception 'O PIN deve ter de 4 a 8 números.' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.funcionarios where codigo = v_cod and id is distinct from p_id) then
    raise exception 'Já existe alguém com o código %.', v_cod using errcode = 'P0001';
  end if;
  if p_id = me.id and (not p_admin or not p_ativo) then
    raise exception 'Você não pode tirar o seu próprio acesso de administrador.' using errcode = 'P0001';
  end if;

  if p_id is null then
    if p_pin is null or p_pin = '' then
      raise exception 'Defina um PIN para o novo funcionário.' using errcode = 'P0001';
    end if;
    insert into public.funcionarios (codigo, nome, pin_hash, admin, ativo)
    values (v_cod, trim(p_nome), crypt(p_pin, gen_salt('bf')), coalesce(p_admin, false), coalesce(p_ativo, true))
    returning id into v_id;
  else
    update public.funcionarios
       set codigo = v_cod,
           nome = trim(p_nome),
           admin = coalesce(p_admin, false),
           ativo = coalesce(p_ativo, true),
           pin_hash = case when p_pin is not null and p_pin <> '' then crypt(p_pin, gen_salt('bf')) else pin_hash end
     where id = p_id
    returning id into v_id;
    if v_id is null then
      raise exception 'Funcionário não encontrado.' using errcode = 'P0001';
    end if;
    -- Troca de PIN ou desativação derruba as sessões abertas.
    if (p_pin is not null and p_pin <> '') or not coalesce(p_ativo, true) then
      delete from public.sessoes where funcionario_id = v_id;
    end if;
  end if;
  delete from public.tentativas_login where codigo = v_cod;
  return json_build_object('id', v_id);
end $$;

create or replace function public.admin_marcacoes(p_token text, p_funcionario uuid, p_mes text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  i record;
begin
  perform public._admin(p_token);
  select * into i from public._mes_intervalo(p_mes);
  return public._marcacoes_json(p_funcionario, i.ini, i.fim);
end $$;

-- Inclui uma marcação esquecida. p_momento no formato 'AAAA-MM-DD HH:MM', no fuso da empresa.
create or replace function public.admin_incluir(p_token text, p_funcionario uuid, p_momento text, p_motivo text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  me public.funcionarios := public._admin(p_token);
  v_momento timestamptz;
begin
  if length(trim(coalesce(p_motivo, ''))) < 3 then
    raise exception 'Informe o motivo da inclusão.' using errcode = 'P0001';
  end if;
  begin
    v_momento := (p_momento::timestamp) at time zone public._fuso();
  exception when others then
    raise exception 'Data e hora inválidas.' using errcode = 'P0001';
  end;
  if v_momento > now() then
    raise exception 'Não é possível incluir marcação no futuro.' using errcode = 'P0001';
  end if;
  insert into public.marcacoes (funcionario_id, momento, origem, registrado_por, motivo)
  values (p_funcionario, v_momento, 'ajuste', me.id, trim(p_motivo));
  return json_build_object('ok', true);
end $$;

create or replace function public.admin_anular(p_token text, p_marcacao bigint, p_motivo text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare
  me public.funcionarios := public._admin(p_token);
begin
  if length(trim(coalesce(p_motivo, ''))) < 3 then
    raise exception 'Informe o motivo da anulação.' using errcode = 'P0001';
  end if;
  update public.marcacoes
     set anulada_em = now(), anulada_por = me.id, motivo_anulacao = trim(p_motivo)
   where id = p_marcacao and anulada_em is null;
  if not found then
    raise exception 'Marcação não encontrada ou já anulada.' using errcode = 'P0001';
  end if;
  return json_build_object('ok', true);
end $$;

create or replace function public.admin_config(p_token text)
returns json
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform public._admin(p_token);
  return (select row_to_json(c) from public.config c where id = 1);
end $$;

-- p_lat/p_lng nulos desligam a cerca virtual.
create or replace function public.admin_salvar_config(
  p_token text, p_nome_local text, p_lat double precision, p_lng double precision, p_raio_m int)
returns json
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform public._admin(p_token);
  if (p_lat is null) <> (p_lng is null) then
    raise exception 'Informe latitude e longitude juntas.' using errcode = 'P0001';
  end if;
  if p_lat is not null and (p_lat not between -90 and 90 or p_lng not between -180 and 180) then
    raise exception 'Coordenadas inválidas.' using errcode = 'P0001';
  end if;
  if p_raio_m is null or p_raio_m not between 20 and 5000 then
    raise exception 'O raio deve ficar entre 20 e 5000 metros.' using errcode = 'P0001';
  end if;
  update public.config
     set nome_local = nullif(trim(coalesce(p_nome_local, '')), ''),
         lat = p_lat, lng = p_lng, raio_m = p_raio_m
   where id = 1;
  return public.admin_config(p_token);
end $$;

-- ---------------------------------------------------------------------------
-- Permissões: só as funções do app ficam acessíveis pela chave pública.
-- ---------------------------------------------------------------------------

revoke all on all functions in schema public from public;

do $$
declare
  fn text;
  papeis text[] := array[]::text[];
  papel text;
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then papeis := papeis || 'anon'::text; end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then papeis := papeis || 'authenticated'::text; end if;
  foreach papel in array papeis loop
    execute format('revoke all on all functions in schema public from %I', papel);
    foreach fn in array array[
      'entrar(text,text)',
      'sair(text)',
      'situacao(text)',
      'registrar(text,double precision,double precision,double precision)',
      'desfazer(text)',
      'meus_horarios(text,text)',
      'admin_funcionarios(text)',
      'admin_salvar_funcionario(text,uuid,text,text,text,boolean,boolean)',
      'admin_marcacoes(text,uuid,text)',
      'admin_incluir(text,uuid,text,text)',
      'admin_anular(text,bigint,text)',
      'admin_config(text)',
      'admin_salvar_config(text,text,double precision,double precision,int)'
    ] loop
      execute format('grant execute on function public.%s to %I', fn, papel);
    end loop;
  end loop;
end $$;
