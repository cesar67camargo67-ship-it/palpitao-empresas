# HOTFIX V11 — Anúncios em tamanho vendável

## Objetivo

Corrigir a exibição dos anúncios para ficarem com presença comercial real, sem alterar regras de jogo, ranking, login, usuários, palpites, resultados ou banco.

## O que muda

### 1. Anúncio principal quadrado

O slot **Tela Palpitar** passa a funcionar como anúncio principal no topo/cabeçalho, no espaço visual do antigo logo/imagem da Copa.

Formato recomendado:
- 1200 x 1200 px
- JPG, PNG ou WEBP
- até 2 MB

Quando estiver ativo, aparece no cabeçalho como imagem quadrada, com título/chamada abaixo.

### 2. Anúncios retangulares nas demais telas

Os demais slots ficam em formato retangular, com imagem maior e título/chamada abaixo.

Formato recomendado:
- 1200 x 400 px
- JPG, PNG ou WEBP
- até 2 MB

### 3. Admin com orientação visual

O painel de anúncios agora indica:
- quadrado para o anúncio principal;
- retangular para os demais anúncios.

## Cerca elétrica

Este hotfix NÃO altera:

- Supabase;
- SQL;
- usuários;
- senhas;
- palpites;
- resultados;
- ranking;
- regras de pontuação;
- importação de participantes;
- storage/bucket;
- políticas RLS.

Substitui apenas:

- `src/main.js`
- `src/styles.css`

## Como aplicar

1. Fechar o servidor local se estiver rodando.
2. Substituir na pasta do projeto:
   - `src/main.js`
   - `src/styles.css`
3. Rodar:

```bash
npm run dev
```

4. Testar:
   - Admin → Repositório de anúncios
   - Tela Palpitar: subir imagem quadrada
   - Marcar Ativo
   - Salvar anúncio
   - Voltar para a tela Palpitar e conferir no topo
   - Testar uma tela retangular, como Ranking ou Jogos

## Comando de segurança antes de publicar

```bash
git status
```

Devem aparecer somente os arquivos:

```text
src/main.js
src/styles.css
```

## Publicação

```bash
git add src/main.js src/styles.css docs/HOTFIX_V11_ANUNCIOS_VENDAVEIS.md
git commit -m "Hotfix V11 anuncios vendaveis"
git push
```
