# PALPITÃO EMPRESAS — Base V1

Versão comercial separada do Palpitão original.

## O que esta base contém

- App PALPITÃO EMPRESAS.
- Repositório de anúncios com 7 espaços fixos.
- Importação de participantes por CSV.
- Login por CPF para participantes importados.
- Ranking geral e por rodada.
- Palpites travados no horário do jogo.
- Painel administrativo.
- SQL completo para instalação no novo Supabase.

## Instalação rápida

1. Criar pasta nova no computador:
   `C:\Users\Cesar Camargo\Desktop\PALPITAO-EMPRESAS`

2. Copiar estes arquivos para a pasta.

3. Criar o arquivo `.env` a partir do `.env.example`.

4. Rodar no terminal:

```bash
npm install
npm run dev
```

5. No Supabase, rodar:
   `supabase/install_palpitao_empresas_v1.sql`

6. Testar login inicial:
   - usuário: César
   - senha: admin123

Depois do primeiro acesso, trocar a senha do administrador no painel.
