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

### Atualizar pasta no Google Drive

Gera os SVGs e envia para uma pasta no Google Drive, apagando o conteúdo anterior.

```bash
./generate.sh --update-drive
```

#### Configuração (primeira vez)

**1. Instalar dependências Python:**

```bash
./setup_venv.sh
```

O script cria um `.venv` local e instala as dependências automaticamente. O `generate.sh` usa esse ambiente quando disponível.

**2. Obter credenciais OAuth2 do Google:**

- Acesse o [Google Cloud Console](https://console.cloud.google.com/)
- Crie ou selecione um projeto
- Vá em **APIs & Services > Library** e ative a **Google Drive API**
- Vá em **APIs & Services > Credentials > Create Credentials > OAuth 2.0 Client ID**
- Tipo: **Desktop app**
- Baixe o arquivo JSON e salve como `credentials.json` na raiz do projeto

**3. Configurar o ID da pasta do Drive:**

```bash
cp .env.example .env
```

Edite o `.env` e preencha o `DRIVE_FOLDER_ID` com o ID da pasta de destino.
O ID está na URL da pasta: `https://drive.google.com/drive/folders/FOLDER_ID_AQUI`

**4. Autenticar (apenas na primeira execução):**

Na primeira vez, o script abre o navegador para autorizar o acesso ao Drive.
Após autorizar, um `token.json` é salvo localmente e as próximas execuções são automáticas.

> `credentials.json`, `token.json` e `.env` são ignorados pelo git.

## Estrutura

```
.
├── generate.sh      # Script de geração
├── setup_venv.sh    # Cria .venv e instala dependências Python
├── upload_drive.py  # Script de upload para o Google Drive
├── requirements.txt # Dependências Python
├── .env.example     # Modelo de configuração
├── out/             # Diagramas gerados (ignorado pelo git)
└── src/             # Arquivos .puml fonte
```
