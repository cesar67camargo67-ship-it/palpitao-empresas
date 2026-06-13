-- PALPITÃO EMPRESAS — INSTALAÇÃO BASE V1
-- Ambiente novo: Supabase Palpitao-Empresas.
-- Este script cria as tabelas principais, os jogos da fase de grupos, usuários de teste,
-- repositório de anúncios e bucket de imagens.
-- Em projeto limpo, pode rodar uma vez no SQL Editor do Supabase.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS profiles (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  apelido TEXT NOT NULL,
  email TEXT,
  cpf TEXT UNIQUE,
  whatsapp TEXT,
  role TEXT NOT NULL DEFAULT 'participante',
  senha TEXT NOT NULL DEFAULT '1234',
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS teams (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  codigo TEXT NOT NULL,
  flag_url TEXT,
  continente TEXT,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  grupo_atual TEXT
);

CREATE TABLE IF NOT EXISTS games (
  id TEXT PRIMARY KEY,
  codigo_jogo TEXT NOT NULL UNIQUE,
  fase TEXT NOT NULL,
  grupo TEXT,
  rodada INTEGER,
  data_hora TIMESTAMPTZ NOT NULL,
  time_a_id TEXT NOT NULL REFERENCES teams(id),
  time_b_id TEXT NOT NULL REFERENCES teams(id),
  gols_a INTEGER,
  gols_b INTEGER,
  status TEXT NOT NULL DEFAULT 'aberto'
);

CREATE TABLE IF NOT EXISTS predictions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  game_id TEXT NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  gols_a_palpite INTEGER NOT NULL,
  gols_b_palpite INTEGER NOT NULL,
  pontos INTEGER NOT NULL DEFAULT 0,
  acertou BOOLEAN,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS predictions_user_game_unique
ON predictions (user_id, game_id);

CREATE TABLE IF NOT EXISTS ads (
  slot_code TEXT PRIMARY KEY,
  title TEXT NOT NULL DEFAULT '',
  text TEXT NOT NULL DEFAULT '',
  image_url TEXT NOT NULL DEFAULT '',
  link_url TEXT NOT NULL DEFAULT '',
  active BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'profiles' AND policyname = 'palpitao_profiles_all'
  ) THEN
    CREATE POLICY palpitao_profiles_all ON profiles
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;


ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'teams' AND policyname = 'palpitao_teams_all'
  ) THEN
    CREATE POLICY palpitao_teams_all ON teams
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;


ALTER TABLE games ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'games' AND policyname = 'palpitao_games_all'
  ) THEN
    CREATE POLICY palpitao_games_all ON games
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;


ALTER TABLE predictions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'predictions' AND policyname = 'palpitao_predictions_all'
  ) THEN
    CREATE POLICY palpitao_predictions_all ON predictions
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;


ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'ads' AND policyname = 'palpitao_ads_all'
  ) THEN
    CREATE POLICY palpitao_ads_all ON ads
      FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;


-- Usuários iniciais. Trocar senha do administrador depois do primeiro acesso.
INSERT INTO profiles (id, nome, apelido, email, cpf, whatsapp, role, senha, ativo) VALUES ('00000000-0000-0000-0000-000000000001', 'César Camargo', 'César', 'cesar@example.com', NULL, NULL, 'admin', 'admin123', TRUE)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  apelido = EXCLUDED.apelido,
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  senha = EXCLUDED.senha,
  ativo = EXCLUDED.ativo;

INSERT INTO profiles (id, nome, apelido, email, cpf, whatsapp, role, senha, ativo) VALUES ('00000000-0000-0000-0000-000000000002', 'Ana Souza', 'Ana', 'ana@example.com', NULL, NULL, 'participante', '1234', TRUE)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  apelido = EXCLUDED.apelido,
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  senha = EXCLUDED.senha,
  ativo = EXCLUDED.ativo;

INSERT INTO profiles (id, nome, apelido, email, cpf, whatsapp, role, senha, ativo) VALUES ('00000000-0000-0000-0000-000000000003', 'João Lima', 'João', 'joao@example.com', NULL, NULL, 'participante', '1234', TRUE)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  apelido = EXCLUDED.apelido,
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  senha = EXCLUDED.senha,
  ativo = EXCLUDED.ativo;


-- Seleções / times.
INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-kor', 'Coreia do Sul', 'KOR', 'https://flagcdn.com/w80/kr.png', '', TRUE, 'A')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-mex', 'México', 'MEX', 'https://flagcdn.com/w80/mx.png', '', TRUE, 'A')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-cze', 'Tchéquia', 'CZE', 'https://flagcdn.com/w80/cz.png', '', TRUE, 'A')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-rsa', 'África do Sul', 'RSA', 'https://flagcdn.com/w80/za.png', '', TRUE, 'A')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-bih', 'Bósnia e Herzegovina', 'BIH', 'https://flagcdn.com/w80/ba.png', '', TRUE, 'B')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-can', 'Canadá', 'CAN', 'https://flagcdn.com/w80/ca.png', '', TRUE, 'B')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-qat', 'Catar', 'QAT', 'https://flagcdn.com/w80/qa.png', '', TRUE, 'B')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-sui', 'Suíça', 'SUI', 'https://flagcdn.com/w80/ch.png', '', TRUE, 'B')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-bra', 'Brasil', 'BRA', 'https://flagcdn.com/w80/br.png', '', TRUE, 'C')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-sco', 'Escócia', 'SCO', 'https://flagcdn.com/w80/gb-sct.png', '', TRUE, 'C')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-hai', 'Haiti', 'HAI', 'https://flagcdn.com/w80/ht.png', '', TRUE, 'C')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-mar', 'Marrocos', 'MAR', 'https://flagcdn.com/w80/ma.png', '', TRUE, 'C')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-aus', 'Austrália', 'AUS', 'https://flagcdn.com/w80/au.png', '', TRUE, 'D')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-usa', 'Estados Unidos', 'USA', 'https://flagcdn.com/w80/us.png', '', TRUE, 'D')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-par', 'Paraguai', 'PAR', 'https://flagcdn.com/w80/py.png', '', TRUE, 'D')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-tur', 'Turquia', 'TUR', 'https://flagcdn.com/w80/tr.png', '', TRUE, 'D')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-ger', 'Alemanha', 'GER', 'https://flagcdn.com/w80/de.png', '', TRUE, 'E')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-civ', 'Costa do Marfim', 'CIV', 'https://flagcdn.com/w80/ci.png', '', TRUE, 'E')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-cuw', 'Curaçao', 'CUW', 'https://flagcdn.com/w80/cw.png', '', TRUE, 'E')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-ecu', 'Equador', 'ECU', 'https://flagcdn.com/w80/ec.png', '', TRUE, 'E')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-ned', 'Holanda', 'NED', 'https://flagcdn.com/w80/nl.png', '', TRUE, 'F')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-jpn', 'Japão', 'JPN', 'https://flagcdn.com/w80/jp.png', '', TRUE, 'F')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-swe', 'Suécia', 'SWE', 'https://flagcdn.com/w80/se.png', '', TRUE, 'F')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-tun', 'Tunísia', 'TUN', 'https://flagcdn.com/w80/tn.png', '', TRUE, 'F')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-bel', 'Bélgica', 'BEL', 'https://flagcdn.com/w80/be.png', '', TRUE, 'G')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-egy', 'Egito', 'EGY', 'https://flagcdn.com/w80/eg.png', '', TRUE, 'G')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-irn', 'Irã', 'IRN', 'https://flagcdn.com/w80/ir.png', '', TRUE, 'G')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-nzl', 'Nova Zelândia', 'NZL', 'https://flagcdn.com/w80/nz.png', '', TRUE, 'G')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-ksa', 'Arábia Saudita', 'KSA', 'https://flagcdn.com/w80/sa.png', '', TRUE, 'H')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-cpv', 'Cabo Verde', 'CPV', 'https://flagcdn.com/w80/cv.png', '', TRUE, 'H')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-esp', 'Espanha', 'ESP', 'https://flagcdn.com/w80/es.png', '', TRUE, 'H')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-uru', 'Uruguai', 'URU', 'https://flagcdn.com/w80/uy.png', '', TRUE, 'H')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-fra', 'França', 'FRA', 'https://flagcdn.com/w80/fr.png', '', TRUE, 'I')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-irq', 'Iraque', 'IRQ', 'https://flagcdn.com/w80/iq.png', '', TRUE, 'I')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-nor', 'Noruega', 'NOR', 'https://flagcdn.com/w80/no.png', '', TRUE, 'I')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-sen', 'Senegal', 'SEN', 'https://flagcdn.com/w80/sn.png', '', TRUE, 'I')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-arg', 'Argentina', 'ARG', 'https://flagcdn.com/w80/ar.png', '', TRUE, 'J')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-alg', 'Argélia', 'ALG', 'https://flagcdn.com/w80/dz.png', '', TRUE, 'J')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-jor', 'Jordânia', 'JOR', 'https://flagcdn.com/w80/jo.png', '', TRUE, 'J')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-aut', 'Áustria', 'AUT', 'https://flagcdn.com/w80/at.png', '', TRUE, 'J')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-col', 'Colômbia', 'COL', 'https://flagcdn.com/w80/co.png', '', TRUE, 'K')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-por', 'Portugal', 'POR', 'https://flagcdn.com/w80/pt.png', '', TRUE, 'K')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-cod', 'RD Congo', 'COD', 'https://flagcdn.com/w80/cd.png', '', TRUE, 'K')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-uzb', 'Uzbequistão', 'UZB', 'https://flagcdn.com/w80/uz.png', '', TRUE, 'K')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-cro', 'Croácia', 'CRO', 'https://flagcdn.com/w80/hr.png', '', TRUE, 'L')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-gha', 'Gana', 'GHA', 'https://flagcdn.com/w80/gh.png', '', TRUE, 'L')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-eng', 'Inglaterra', 'ENG', 'https://flagcdn.com/w80/gb-eng.png', '', TRUE, 'L')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;

INSERT INTO teams (id, nome, codigo, flag_url, continente, ativo, grupo_atual) VALUES ('team-pan', 'Panamá', 'PAN', 'https://flagcdn.com/w80/pa.png', '', TRUE, 'L')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  flag_url = EXCLUDED.flag_url,
  continente = EXCLUDED.continente,
  ativo = EXCLUDED.ativo,
  grupo_atual = EXCLUDED.grupo_atual;


-- Jogos da fase de grupos.
INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-001', 'G01', 'GRUPOS', 'A', 1, '2026-06-11T16:00:00-03:00', 'team-mex', 'team-rsa', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-002', 'G02', 'GRUPOS', 'A', 1, '2026-06-11T23:00:00-03:00', 'team-kor', 'team-cze', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-003', 'G03', 'GRUPOS', 'B', 1, '2026-06-12T16:00:00-03:00', 'team-can', 'team-bih', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-004', 'G04', 'GRUPOS', 'D', 1, '2026-06-12T22:00:00-03:00', 'team-usa', 'team-par', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-005', 'G05', 'GRUPOS', 'B', 1, '2026-06-13T16:00:00-03:00', 'team-qat', 'team-sui', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-006', 'G06', 'GRUPOS', 'C', 1, '2026-06-13T19:00:00-03:00', 'team-bra', 'team-mar', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-007', 'G07', 'GRUPOS', 'C', 1, '2026-06-13T22:00:00-03:00', 'team-hai', 'team-sco', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-008', 'G08', 'GRUPOS', 'D', 1, '2026-06-14T01:00:00-03:00', 'team-aus', 'team-tur', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-009', 'G09', 'GRUPOS', 'E', 1, '2026-06-14T14:00:00-03:00', 'team-ger', 'team-cuw', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-010', 'G10', 'GRUPOS', 'F', 1, '2026-06-14T17:00:00-03:00', 'team-ned', 'team-jpn', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-011', 'G11', 'GRUPOS', 'E', 1, '2026-06-14T20:00:00-03:00', 'team-civ', 'team-ecu', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-012', 'G12', 'GRUPOS', 'F', 1, '2026-06-14T23:00:00-03:00', 'team-swe', 'team-tun', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-013', 'G13', 'GRUPOS', 'H', 1, '2026-06-15T13:00:00-03:00', 'team-esp', 'team-cpv', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-014', 'G14', 'GRUPOS', 'G', 1, '2026-06-15T16:00:00-03:00', 'team-bel', 'team-egy', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-015', 'G15', 'GRUPOS', 'H', 1, '2026-06-15T19:00:00-03:00', 'team-ksa', 'team-uru', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-016', 'G16', 'GRUPOS', 'G', 1, '2026-06-15T22:00:00-03:00', 'team-irn', 'team-nzl', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-017', 'G17', 'GRUPOS', 'I', 1, '2026-06-16T16:00:00-03:00', 'team-fra', 'team-sen', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-018', 'G18', 'GRUPOS', 'I', 1, '2026-06-16T19:00:00-03:00', 'team-irq', 'team-nor', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-019', 'G19', 'GRUPOS', 'J', 1, '2026-06-16T22:00:00-03:00', 'team-arg', 'team-alg', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-020', 'G20', 'GRUPOS', 'J', 1, '2026-06-17T01:00:00-03:00', 'team-aut', 'team-jor', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-021', 'G21', 'GRUPOS', 'K', 1, '2026-06-17T14:00:00-03:00', 'team-por', 'team-cod', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-022', 'G22', 'GRUPOS', 'L', 1, '2026-06-17T17:00:00-03:00', 'team-eng', 'team-cro', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-023', 'G23', 'GRUPOS', 'L', 1, '2026-06-17T20:00:00-03:00', 'team-gha', 'team-pan', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-024', 'G24', 'GRUPOS', 'K', 1, '2026-06-17T23:00:00-03:00', 'team-uzb', 'team-col', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-025', 'G25', 'GRUPOS', 'A', 2, '2026-06-18T13:00:00-03:00', 'team-cze', 'team-rsa', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-026', 'G26', 'GRUPOS', 'B', 2, '2026-06-18T16:00:00-03:00', 'team-sui', 'team-bih', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-027', 'G27', 'GRUPOS', 'B', 2, '2026-06-18T19:00:00-03:00', 'team-can', 'team-qat', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-028', 'G28', 'GRUPOS', 'A', 2, '2026-06-18T22:00:00-03:00', 'team-mex', 'team-kor', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-029', 'G29', 'GRUPOS', 'D', 2, '2026-06-19T16:00:00-03:00', 'team-usa', 'team-aus', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-030', 'G30', 'GRUPOS', 'C', 2, '2026-06-19T19:00:00-03:00', 'team-sco', 'team-mar', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-031', 'G31', 'GRUPOS', 'C', 2, '2026-06-19T21:30:00-03:00', 'team-bra', 'team-hai', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-032', 'G32', 'GRUPOS', 'D', 2, '2026-06-20T00:00:00-03:00', 'team-tur', 'team-par', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-033', 'G33', 'GRUPOS', 'F', 2, '2026-06-20T14:00:00-03:00', 'team-ned', 'team-swe', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-034', 'G34', 'GRUPOS', 'E', 2, '2026-06-20T17:00:00-03:00', 'team-ger', 'team-civ', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-035', 'G35', 'GRUPOS', 'E', 2, '2026-06-20T21:00:00-03:00', 'team-ecu', 'team-cuw', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-036', 'G36', 'GRUPOS', 'F', 2, '2026-06-21T01:00:00-03:00', 'team-tun', 'team-jpn', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-037', 'G37', 'GRUPOS', 'H', 2, '2026-06-21T13:00:00-03:00', 'team-esp', 'team-ksa', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-038', 'G38', 'GRUPOS', 'G', 2, '2026-06-21T16:00:00-03:00', 'team-bel', 'team-irn', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-039', 'G39', 'GRUPOS', 'H', 2, '2026-06-21T19:00:00-03:00', 'team-uru', 'team-cpv', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-040', 'G40', 'GRUPOS', 'G', 2, '2026-06-21T22:00:00-03:00', 'team-nzl', 'team-egy', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-041', 'G41', 'GRUPOS', 'J', 2, '2026-06-22T14:00:00-03:00', 'team-arg', 'team-aut', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-042', 'G42', 'GRUPOS', 'I', 2, '2026-06-22T18:00:00-03:00', 'team-fra', 'team-irq', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-043', 'G43', 'GRUPOS', 'I', 2, '2026-06-22T21:00:00-03:00', 'team-nor', 'team-sen', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-044', 'G44', 'GRUPOS', 'J', 2, '2026-06-23T00:00:00-03:00', 'team-jor', 'team-alg', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-045', 'G45', 'GRUPOS', 'K', 2, '2026-06-23T14:00:00-03:00', 'team-por', 'team-uzb', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-046', 'G46', 'GRUPOS', 'L', 2, '2026-06-23T17:00:00-03:00', 'team-eng', 'team-gha', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-047', 'G47', 'GRUPOS', 'L', 2, '2026-06-23T20:00:00-03:00', 'team-pan', 'team-cro', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-048', 'G48', 'GRUPOS', 'K', 2, '2026-06-23T23:00:00-03:00', 'team-col', 'team-cod', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-049', 'G49', 'GRUPOS', 'B', 3, '2026-06-24T16:00:00-03:00', 'team-sui', 'team-can', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-050', 'G50', 'GRUPOS', 'B', 3, '2026-06-24T16:00:00-03:00', 'team-bih', 'team-qat', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-051', 'G51', 'GRUPOS', 'C', 3, '2026-06-24T19:00:00-03:00', 'team-mar', 'team-hai', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-052', 'G52', 'GRUPOS', 'C', 3, '2026-06-24T19:00:00-03:00', 'team-sco', 'team-bra', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-053', 'G53', 'GRUPOS', 'A', 3, '2026-06-24T22:00:00-03:00', 'team-rsa', 'team-kor', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-054', 'G54', 'GRUPOS', 'A', 3, '2026-06-24T22:00:00-03:00', 'team-cze', 'team-mex', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-055', 'G55', 'GRUPOS', 'E', 3, '2026-06-25T17:00:00-03:00', 'team-cuw', 'team-civ', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-056', 'G56', 'GRUPOS', 'E', 3, '2026-06-25T17:00:00-03:00', 'team-ecu', 'team-ger', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-057', 'G57', 'GRUPOS', 'F', 3, '2026-06-25T20:00:00-03:00', 'team-tun', 'team-ned', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-058', 'G58', 'GRUPOS', 'F', 3, '2026-06-25T20:00:00-03:00', 'team-jpn', 'team-swe', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-059', 'G59', 'GRUPOS', 'D', 3, '2026-06-25T23:00:00-03:00', 'team-tur', 'team-usa', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-060', 'G60', 'GRUPOS', 'D', 3, '2026-06-25T23:00:00-03:00', 'team-par', 'team-aus', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-061', 'G61', 'GRUPOS', 'I', 3, '2026-06-26T16:00:00-03:00', 'team-nor', 'team-fra', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-062', 'G62', 'GRUPOS', 'I', 3, '2026-06-26T16:00:00-03:00', 'team-sen', 'team-irq', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-063', 'G63', 'GRUPOS', 'H', 3, '2026-06-26T21:00:00-03:00', 'team-cpv', 'team-ksa', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-064', 'G64', 'GRUPOS', 'H', 3, '2026-06-26T21:00:00-03:00', 'team-uru', 'team-esp', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-065', 'G65', 'GRUPOS', 'G', 3, '2026-06-27T00:00:00-03:00', 'team-nzl', 'team-bel', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-066', 'G66', 'GRUPOS', 'G', 3, '2026-06-27T00:00:00-03:00', 'team-egy', 'team-irn', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-067', 'G67', 'GRUPOS', 'L', 3, '2026-06-27T18:00:00-03:00', 'team-pan', 'team-eng', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-068', 'G68', 'GRUPOS', 'L', 3, '2026-06-27T18:00:00-03:00', 'team-cro', 'team-gha', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-069', 'G69', 'GRUPOS', 'K', 3, '2026-06-27T20:30:00-03:00', 'team-col', 'team-por', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-070', 'G70', 'GRUPOS', 'K', 3, '2026-06-27T20:30:00-03:00', 'team-cod', 'team-uzb', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-071', 'G71', 'GRUPOS', 'J', 3, '2026-06-27T23:00:00-03:00', 'team-alg', 'team-aut', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;

INSERT INTO games (id, codigo_jogo, fase, grupo, rodada, data_hora, time_a_id, time_b_id, gols_a, gols_b, status) VALUES ('game-072', 'G72', 'GRUPOS', 'J', 3, '2026-06-27T23:00:00-03:00', 'team-jor', 'team-arg', NULL, NULL, 'aberto')
ON CONFLICT (codigo_jogo) DO UPDATE SET
  fase = EXCLUDED.fase,
  grupo = EXCLUDED.grupo,
  rodada = EXCLUDED.rodada,
  data_hora = EXCLUDED.data_hora,
  time_a_id = EXCLUDED.time_a_id,
  time_b_id = EXCLUDED.time_b_id,
  gols_a = EXCLUDED.gols_a,
  gols_b = EXCLUDED.gols_b,
  status = EXCLUDED.status;


-- Slots fixos de anúncios.
INSERT INTO ads (slot_code, title, text, active)
VALUES
  ('banner_palpitar', '', '', FALSE),
  ('banner_palpites', '', '', FALSE),
  ('banner_parceiros', '', '', FALSE),
  ('banner_brasil', '', '', FALSE),
  ('banner_jogos', '', '', FALSE),
  ('banner_tabelas', '', '', FALSE),
  ('banner_ranking', '', '', FALSE)
ON CONFLICT (slot_code) DO NOTHING;

-- Bucket público para banners.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'palpitao-ads',
  'palpitao-ads',
  true,
  2097152,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'palpitao_ads_storage_select') THEN
    CREATE POLICY palpitao_ads_storage_select ON storage.objects
      FOR SELECT USING (bucket_id = 'palpitao-ads');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'palpitao_ads_storage_insert') THEN
    CREATE POLICY palpitao_ads_storage_insert ON storage.objects
      FOR INSERT WITH CHECK (bucket_id = 'palpitao-ads');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'palpitao_ads_storage_update') THEN
    CREATE POLICY palpitao_ads_storage_update ON storage.objects
      FOR UPDATE USING (bucket_id = 'palpitao-ads') WITH CHECK (bucket_id = 'palpitao-ads');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'palpitao_ads_storage_delete') THEN
    CREATE POLICY palpitao_ads_storage_delete ON storage.objects
      FOR DELETE USING (bucket_id = 'palpitao-ads');
  END IF;
END $$;

SELECT 'profiles' AS tabela, COUNT(*) AS registros FROM profiles
UNION ALL SELECT 'teams', COUNT(*) FROM teams
UNION ALL SELECT 'games', COUNT(*) FROM games
UNION ALL SELECT 'ads', COUNT(*) FROM ads;
