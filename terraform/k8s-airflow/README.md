# Airflow Data Warehouse module

## Airflow configuration
For the setup we need to create a secret-manager
Format: `{ENVIRONMENT}/airflow`

### GitSync

For git sync we need to pre-generate personal access token for `ops@yourcompany.co.uk`
Unfortunately we can only setup git sync with user with personal access tokens.
For PAT we need `packages -> read`

Required keys
```
GITSYNC_REPO=https://github.com/yourcompany/data-pipelines
GITSYNC_BRANCH=master
GITSYNC_USERNAME=ops@yourcompany.co.uk
GITSYNC_PASSWORD={PAT}
```

### Postgres

For the db setup a new role with permissions

```sql
CREATE DATABASE airflow;
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;
GRANT ALL ON SCHEMA public TO airflow;
```

in secret manager:

```
POSTGRESQL_USERNAME=airflow
POSTGRESQL_PASSWORD={PASSWORD}
```

## Airflow DAG user

DAGs pulling credentials from secret manager which we need to create manually,
for database access we only need to provide `SELECT` as we only need read only access to the source databases
Secret key name: `{ENVIRONMENT}/airflow-dag`

```json
{
  "NEW_DB_USER": "airflow",
  "NEW_DB_PASSWORD": "",
  "NEW_DB_HOST": "new-db.yourcompany.co.uk",
  "NEW_DB_PORT": "3306",
  "LEGACY_DB_USER": "airflow",
  "LEGACY_DB_PASSWORD": "",
  "LEGACY_DB_HOST": "old-db.yourcompany.co.uk",
  "LEGACY_DB_PORT": "3306",
  "S3_BUCKET": "data-reports",
  "AWS_ACCESS_KEY": "AKIA...T3MY",
  "AWS_SECRET_KEY": "/nC4D188SGuarlXPQ2"
}
```
