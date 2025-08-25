# Email Worker com Docker Compose

Este projeto demonstra a implementação de um sistema de microserviços para enfileirar e processar o envio de e-mails de forma assíncrona, utilizando Docker e Docker Compose para orquestrar os contêineres.

O objetivo é desacoplar o recebimento da requisição do processamento pesado (o envio do e-mail), proporcionando uma resposta rápida ao usuário e garantindo que as tarefas sejam executadas em segundo plano por um ou mais *workers*.

## Arquitetura

O ambiente é composto por cinco serviços principais, cada um rodando em seu próprio contêiner e se comunicando através de redes Docker dedicadas. A configuração de cada serviço é gerenciada por variáveis de ambiente, garantindo portabilidade e segurança.

  * **`frontend` (Nginx)**: Um servidor web Nginx que atua como *Reverse Proxy*. É responsável por servir a página HTML estática para o usuário e por redirecionar as chamadas de API (`/api`) para o serviço `app`.
  * **`app` (Python/Bottle)**: A aplicação web backend que recebe os dados do formulário, persiste uma cópia da mensagem no banco de dados PostgreSQL e enfileira a mensagem no Redis para ser processada pelo *worker*.
  * **`db` (PostgreSQL)**: O banco de dados relacional onde todas as solicitações de envio de e-mail são armazenadas permanentemente.
  * **`queue` (Redis)**: Um servidor Redis que funciona como um *message broker* (fila), armazenando temporariamente as mensagens que precisam ser processadas.
  * **`worker` (Python)**: Um serviço de background que consome as mensagens da fila no Redis e simula o processo de envio do e-mail.

## Tecnologias Utilizadas

  * **Orquestração:** Docker e Docker Compose
  * **Servidor Web / Proxy Reverso:** Nginx
  * **Backend (API):** Python 3.6 com framework Bottle
  * **Backend (Worker):** Python 3.6
  * **Banco de Dados:** PostgreSQL 9.6
  * **Fila / Message Broker:** Redis 3.2

## Como Executar o Projeto

### 1\. Configuração do Ambiente

Este projeto utiliza um arquivo `.env` para gerenciar as variáveis de ambiente, como senhas e nomes de hosts. Isso evita a exposição de dados sensíveis no controle de versão.

Primeiro, crie uma cópia do arquivo de exemplo `.env.example` e renomeie-a para `.env`:

```bash
# No Linux ou macOS
cp .env.example .env

# No Windows (Command Prompt)
copy .env.example .env
```

**Importante:** O arquivo `.env` já está incluído no `.gitignore` para garantir que ele nunca seja enviado para o repositório.

### Entendendo e Preenchendo o Arquivo `.env`

Abaixo está um guia detalhado sobre cada variável no seu arquivo `.env` para que você entenda a função de cada uma e como preenchê-la corretamente.

```env
# =========================================================
#      EXEMPLO DE ARQUIVO .ENV - PREENCHA COM SEUS DADOS
# =========================================================

# ----------------------------------------------------
# Variáveis de Ambiente para o Banco de Dados PostgreSQL
# ----------------------------------------------------

# Define o nome de usuário para o banco de dados PostgreSQL.
# O serviço 'app' usará este usuário para se conectar.
POSTGRES_USER=USER

# ATENÇÃO: Define a senha para o usuário do banco de dados.
# Para desenvolvimento, 'postgres' é aceitável, mas em um ambiente
# de produção, substitua por uma senha forte e secreta.
# Exemplo: POSTGRES_PASSWORD=P@ssw0rdS3gur@2025!
POSTGRES_PASSWORD=PASSWORD

# Define o nome do banco de dados que será criado automaticamente.
# O serviço 'app' se conectará a este banco de dados.
POSTGRES_DB=email_sender

# Define o nome do host do banco de dados na rede Docker.
# Este valor DEVE ser igual ao nome do serviço do banco de dados
# no arquivo 'docker-compose.yml' (neste caso, 'db').
# Geralmente, você não precisa mudar este valor.
DB_HOST=db

# ----------------------------------
# Variáveis de Ambiente para o Redis
# ----------------------------------

# Define o nome do host do Redis na rede Docker.
# Este valor DEVE ser igual ao nome do serviço do Redis (queue)
# no arquivo 'docker-compose.yml'.
# Geralmente, você não precisa mudar este valor.
REDIS_HOST=queue

# Define a porta em que o serviço Redis estará escutando.
# O valor padrão '6379' é o padrão do Redis e raramente precisa ser alterado.
REDIS_PORT=6379
```

### 2\. Execução

Com o arquivo `.env` configurado, você pode construir as imagens e iniciar os contêineres.

1.  **Clone o repositório (se ainda não o fez):**

    ```bash
    git clone <URL-DO-SEU-REPOSITORIO>
    cd nome-do-repositorio
    ```

2.  **Construa as imagens e inicie os serviços:**
    O comando a seguir irá ler seu `docker-compose.yml` e o arquivo `.env`, construir a imagem do `worker` e iniciar todos os serviços em modo `detached` (-d).

    ```bash
    docker-compose up -d --build
    ```

3.  **Acesse a aplicação:**
    Abra seu navegador e acesse **http://localhost**.

4.  **Acompanhe os logs:**
    Para ver os serviços funcionando em tempo real, execute:

    ```bash
    # Para ver os logs de todos os serviços
    docker-compose logs -f

    # Para ver os logs apenas do worker
    docker-compose logs -f worker
    ```

5.  **Para parar a aplicação:**
    Para encerrar todos os contêineres, execute:

    ```bash
    docker-compose down
    ```

## Estrutura de Diretórios

```
.
├── app/                # Contém a aplicação backend (API) em Python/Bottle
├── worker/             # Contém o worker que consome a fila
├── nginx/              # Arquivos de configuração do Nginx
├── scripts/            # Scripts de inicialização do banco de dados
├── web/                # Arquivos estáticos servidos pelo Nginx
├── .env.example        # Arquivo de exemplo para as variáveis de ambiente
├── .gitignore          # Especifica arquivos a serem ignorados pelo Git (inclui .env)
└── docker-compose.yml  # Arquivo principal que orquestra todos os serviços
```
