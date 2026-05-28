#!/bin/bash

set -e

VENV_DIR=".venv"

if [ ! -d "$VENV_DIR" ]; then
  echo "Criando ambiente virtual em $VENV_DIR..."
  python3 -m venv "$VENV_DIR"
fi

echo "Instalando dependências..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet -r requirements.txt

echo "Pronto. Para ativar o ambiente: source $VENV_DIR/bin/activate"
