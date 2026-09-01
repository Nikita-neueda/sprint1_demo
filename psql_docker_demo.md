# Dockerfile with volume

```
FROM postgres:15

ENV POSTGRES_PASSWORD=my_secure_password

RUN echo "host all all 10.9.0.0/16 scram-sha-256" >> /usr/share/postgresql/5432/pg_hba.conf.sample \
    && echo "host all all 10.9.0.0/16 scram-sha-256" >> /var/lib/postgresql/data/pg_hba.conf || true

RUN echo '#!/bin/bash\necho "host all all 10.9.0.0/16 scram-sha-256" >> "$PGDATA/pg_hba.conf"' > /docker-entrypoint-initdb.d/01-restrict-ip.sh \
    && chmod +x /docker-entrypoint-initdb.d/01-restrict-ip.sh

COPY entrprise_demo.schema /docker-entrypoint-initdb.d/02-myschema.sql

VOLUME /var/lib/postgresql/data

EXPOSE 5432
```
# 1. Build the updated image
```
docker build -t my-postgres-15 .
```
# 2. Run the container with your named volume mapping
```
docker run -d \
  --name postgres_db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="n3u3d4!" \
  -v pgdata_volume:/var/lib/postgresql/data \
  my-postgres-15
````

# 3. verify  created 6 tables
```
docker exec -it postgres_db psql -U postgres -d postgres -c "\dt"
````
================================================
# 2 Step to load another name os sql with same schema

# need to stop and remove 
```
docker stop postgres_db && docker rm postgres_db
docker volume rm pgdata_volume
```

# Need conatiner with name of db something for pgadmin
```
docker run -d \
  --name postgres_db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="n3u3d4!" \
  -e POSTGRES_DB="newpsql" \
  -v pgdata_volume:/var/lib/postgresql/data \
  my-postgres-15
```
# verify the new database and tables
```
docker exec -it postgres_db psql -U postgres -d newpsql -c "\dt"
```

====================

# dockefile with not hardcode path for schema
```
FROM postgres:15

ENV POSTGRES_PASSWORD=my_secure_password

RUN echo "host all all 10.9.0.0/16 scram-sha-256" >> /usr/share/postgresql/5432/pg_hba.conf.sample \
    && echo "host all all 10.9.0.0/16 scram-sha-256" >> /var/lib/postgresql/data/pg_hba.conf || true

RUN echo '#!/bin/bash\necho "host all all 10.9.0.0/16 scram-sha-256" >> "$PGDATA/pg_hba.conf"' > /docker-entrypoint-initdb.d/01-restrict-ip.sh \
    && chmod +x /docker-entrypoint-initdb.d/01-restrict-ip.sh

ARG SCHEMA_PATH=entrprise_demo.schema

COPY ${SCHEMA_PATH} /docker-entrypoint-initdb.d/02-myschema.sql

VOLUME /var/lib/postgresql/data

EXPOSE 5432
```
# 1. Docker build command
```
docker build --build-arg SCHEMA_PATH="entrprise_demo.schema" -t my-postgres-15 .
```
# 2. Launch the new container with the custom DB name
```
docker run -d \
  --name postgres_db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="n3u3d4!" \
  -e POSTGRES_DB="newpsql" \
  -v pgdata_volume:/var/lib/postgresql/data \
  my-postgres-15
```
  # 3. verify
  docker exec -it postgres_db psql -U postgres -d newpsql -c "\dt"
