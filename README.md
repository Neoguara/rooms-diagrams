# rooms-diagrams

Diagramas de salas gerados a partir de arquivos `.puml` usando [PlantUML](https://plantuml.com/).

## Instalação

### Dependências

- **Java** (necessário para o PlantUML)
- **PlantUML** — instale com um dos métodos abaixo:

**Arch Linux / Manjaro:**
```bash
sudo pacman -S plantuml
```

**Ubuntu / Debian:**
```bash
sudo apt install plantuml
```

**macOS (Homebrew):**
```bash
brew install plantuml
```

**Manual (qualquer sistema):**  
Baixe o `.jar` em https://plantuml.com/download e execute com:
```bash
java -jar plantuml.jar <arquivo.puml>
```

## Uso

### Gerar diagramas em PNG (padrão)

```bash
./generate.sh
```

### Gerar diagramas em SVG

```bash
./generate.sh --svg
```

As imagens geradas são salvas no diretório `out/`, mantendo a estrutura de pastas dos arquivos fonte.

## Estrutura

```
.
├── generate.sh   # Script de geração
├── out/          # Diagramas gerados (ignorado pelo git)
└── src/          # Arquivos .puml fonte
```
