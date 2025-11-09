#!/bin/bash

source ./Docker/scripts/env_functions.sh

if [ "$DOCKER_ENV" != "true" ]; then
    export_env_vars
fi

if [[ "$DATABASE_PROVIDER" == "postgresql" || "$DATABASE_PROVIDER" == "mysql" || "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
    export DATABASE_URL
    echo "Deploying migrations for $DATABASE_PROVIDER"
    echo "Database URL: $DATABASE_URL"

    if [ "$DOCKER_ENV" = "true" ]; then
        # Em produção (Docker/Render), usar migrate deploy diretamente
        echo "Running in production mode - using direct migrate deploy"

        # Primeiro, tentar resetar o banco se houver migrações falhadas
        echo "Resetting database state..."
        npx prisma migrate reset --force --schema ./prisma/$DATABASE_PROVIDER-schema.prisma || true

        # Depois executar deploy normalmente
        npx prisma migrate deploy --schema ./prisma/$DATABASE_PROVIDER-schema.prisma
    else
        # Em desenvolvimento, usar o script normal
        npm run db:deploy
    fi

    if [ $? -ne 0 ]; then
        echo "Migration failed"
        exit 1
    else
        echo "Migration succeeded"
    fi

    npm run db:generate
    if [ $? -ne 0 ]; then
        echo "Prisma generate failed"
        exit 1
    else
        echo "Prisma generate succeeded"
    fi
else
    echo "Error: Database provider $DATABASE_PROVIDER invalid."
    exit 1
fi
