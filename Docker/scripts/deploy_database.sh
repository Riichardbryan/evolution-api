#!/bin/bash

source ./Docker/scripts/env_functions.sh

if [ "$DOCKER_ENV" != "true" ]; then
    export_env_vars
fi

if [[ "$DATABASE_PROVIDER" == "postgresql" || "$DATABASE_PROVIDER" == "mysql" || "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
    export DATABASE_URL
    echo "Deploying migrations for $DATABASE_PROVIDER"
    echo "Database URL: $DATABASE_URL"
    # rm -rf ./prisma/migrations
    # cp -r ./prisma/$DATABASE_PROVIDER-migrations ./prisma/migrations
    # Tentar resolver migrações pendentes primeiro
    npx prisma migrate resolve --applied 20240609181238_init || true
    npm run db:deploy
    if [ $? -ne 0 ]; then
        echo "Migration failed, trying to resolve..."
        # Tentar novamente
        npm run db:deploy
        if [ $? -ne 0 ]; then
            echo "Migration failed again"
            exit 1
        fi
    fi
    echo "Migration succeeded"
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
