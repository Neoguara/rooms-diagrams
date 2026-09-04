# CLAUDE.md

Contexto do projeto para o Claude Code.

## Fluxo de build (`generate.sh`)

1. **PlantUML** — lê todos os `.puml` em `src/` e gera imagens em `out/src/plantuml/` (PNG por padrão, SVG com `--svg`).
2. **`out/drive-links.tex`** — quando `--latex` é passado, antes de compilar qualquer `.tex` o script roda um bloco Python que lê `src/data/diagramas-drive.json` e gera `out/drive-links.tex` com macros LaTeX.
3. **pdflatex** — cada `.tex` com `\documentclass` é compilado com `pdflatex` a partir do seu próprio diretório (`cd "$src_dir"`); o PDF vai para `out/<caminho-do-tex>/`.

Comandos úteis:

```bash
./generate.sh               # gera PNGs
./generate.sh --svg         # gera SVGs
./generate.sh --latex       # gera PNGs + compila PDFs
./generate.sh --update-drive  # gera SVGs + faz upload no Drive
./generate.sh --fetch-links   # atualiza src/data/diagramas-drive.json com os links do Drive
```

## Leitura de imagens PlantUML

Sempre que um arquivo (`.tex`, `.md`, ou qualquer outro) referenciar uma imagem gerada pelo PlantUML (ex: `out/src/plantuml/<nome>.png` ou `out/src/plantuml/<nome>.svg`), **leia o arquivo fonte `.puml` correspondente** em `src/<nome>.puml` em vez da imagem gerada. A imagem é um artefato binário; o `.puml` é a fonte legível que contém a informação útil.

## Convenções dos arquivos `.tex`

O `pdflatex` é executado a partir do diretório do próprio `.tex` (ex: `src/documentos/diagrama-caso-de-uso/`), portanto os caminhos relativos partem daí:

| Recurso | Caminho relativo no `.tex` |
|---|---|
| Imagem PlantUML | `../../../out/src/plantuml/<nome>.png` |
| Macros de links do Drive | `\input{../../../out/drive-links.tex}` |

## Links do Google Drive

Os links ficam em `src/data/diagramas-drive.json`. O `generate.sh --latex` converte esse JSON em `out/drive-links.tex` com macros `\def\link<Nome>{<url>}`.

**Regra de naming da macro:**
- Remove a extensão (`usecasediagram.svg` → `usecasediagram`)
- Divide em palavras por `_` e `-`, capitaliza cada uma, junta
- Prefixo `\link`

Exemplos:

| Arquivo no JSON | Macro LaTeX |
|---|---|
| `usecasediagram.svg` | `\linkUsecasediagram` |
| `der.svg` | `\linkDer` |
| `update_user_status.svg` | `\linkUpdateUserStatus` |

**Nunca hardcodar URLs do Drive nos `.tex`.** Sempre usar:

```latex
\input{../../../out/drive-links.tex}  % no preâmbulo

\href{\linkNomeMacro}{Texto do link}  % no corpo
```

## Estilo de escrita

**Nunca usar travessão (—).** Vale para tudo: respostas no chat, comentários de
código, notas dos diagramas PlantUML, texto dos `.tex` e mensagens de commit.

Em vez do travessão, use vírgula, dois-pontos, parênteses ou ponto final.

| Em vez de | Escreva |
|---|---|
| `ACTIVE e COMPLETED seguram a sala — ele de fato aconteceu` | `ACTIVE e COMPLETED seguram a sala: ele de fato aconteceu` |
| `Event — Ciclo de Vida do Status` | `Event: Ciclo de Vida do Status` |
| `Estado terminal — nenhuma transição` | `Estado terminal. Nenhuma transição` |
