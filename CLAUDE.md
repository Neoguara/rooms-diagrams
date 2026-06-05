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

## Template de slides (`src/documentos/slides/`)

Template baseado em [pmichaillat/latex-presentation](https://github.com/pmichaillat/latex-presentation). Compilado com `pdflatex` como qualquer outro `.tex` do projeto via `./generate.sh --latex`.

Arquivos principais:
- `presentation.tex` — slides no formato 4:3
- `wide.tex` — slides no formato 16:9 (`aspectratio=169`)
- `presentation.sty` — estilos e pacotes do template (não editar)

O template usa `\newcommand{\pdf}{figures.pdf}` para referenciar figuras; o arquivo `figures.pdf` deve estar na mesma pasta que o `.tex`.

### Dependências do sistema

#### Arch Linux

```bash
sudo pacman -S texlive-latex texlive-latexextra texlive-fontsextra
```

#### Ubuntu / Debian

```bash
sudo apt install texlive-latex-extra texlive-fonts-extra
```

### Pacotes LaTeX usados pelo `presentation.sty`

| Pacote | Fornecido por |
|---|---|
| `beamer` (classe) | `texlive-latex` / `texlive-latexextra` |
| `sourcesanspro`, `sourcecodepro` | `texlive-fontsextra` |
| `MnSymbol` | `texlive-fontsextra` |
| `mathalpha` | `texlive-fontsextra` |
| `mathastext` | `texlive-latexextra` |
| `bm` | `texlive-latex` |
| `setspace`, `microtype` | `texlive-latexextra` |
| `etoolbox`, `booktabs`, `multirow` | `texlive-latexextra` |
| `fontenc` | `texlive-latex` |
