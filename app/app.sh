#!/bin/sh

echo "Instalando dependências..."
pip install bottle==0.12.13 psycopg2-binary==2.7.4 redis==2.10.5

echo "Instalando netcat..."
apt-get update && apt-get install -y netcat

echo "Aguardando o Postgres iniciar"
while ! nc -z db 5432; do
  echo "Postgres ainda não está pronto, aguardando 5s..."
  sleep 5
done

echo "Postgres disponível! Iniciando aplicação..."
python -u sender.py
