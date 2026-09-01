# Dockerfile with volume

```
FROM postgres:15

# Set the default environment variable for the password
ENV POSTGRES_PASSWORD=my_secure_password

# 1. Append custom HBA rule to limit connections to the 10.9.0.0/16 subnet
RUN echo "host all all 10.9.0.0/16 scram-sha-256" >> /usr/share/postgresql/5432/pg_hba.conf.sample \
    && echo "host all all 10.9.0.0/16 scram-sha-256" >> /var/lib/postgresql/data/pg_hba.conf || true

# Ensure the entrypoint initialization appends the subnet rule
RUN echo '#!/bin/bash\necho "host all all 10.9.0.0/16 scram-sha-256" >> "$PGDATA/pg_hba.conf"' > /docker-entrypoint-initdb.d/01-restrict-ip.sh \
    && chmod +x /docker-entrypoint-initdb.d/01-restrict-ip.sh

# 2. ADD YOUR NEW SCHEMA FILE HERE:
# Copies your specific entrprise_demo.schema file into the auto-init directory
COPY entrprise_demo.schema /docker-entrypoint-initdb.d/02-myschema.sql

# 3. DEFINE PERSISTENT VOLUME PATH:
VOLUME /var/lib/postgresql/data

EXPOSE 5432
```
# 1. Build the updated image
docker build -t my-postgres-15 .

# 3. Run the container with your named volume mapping
docker run -d \
  --name postgres_db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="n3u3d4!" \
  -v pgdata_volume:/var/lib/postgresql/data \
  my-postgres-15


# verify  created 6 tables
docker exec -it postgres_db psql -U postgres -d postgres -c "\dt"

# Step to load another name os sql with same schema

# need to stop and remove 
docker stop postgres_db && docker rm postgres_db
docker volume rm pgdata_volume


# Need conatiner with name of db something for pgadmin
docker run -d \
  --name postgres_db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="n3u3d4!" \
  -e POSTGRES_DB="newpsql" \
  -v pgdata_volume:/var/lib/postgresql/data \
  my-postgres-15
# verify the new database and tables
docker exec -it postgres_db psql -U postgres -d newpsql -c "\dt"



====================

# dockefile with not hardcode path for schema
```
FROM postgres:15

# Set the default environment variable for the password
ENV POSTGRES_PASSWORD=my_secure_password

# 1. Append custom HBA rule to limit connections to the 10.9.0.0/16 subnet
RUN echo "host all all 10.9.0.0/16 scram-sha-256" >> /usr/share/postgresql/5432/pg_hba.conf.sample \
    && echo "host all all 10.9.0.0/16 scram-sha-256" >> /var/lib/postgresql/data/pg_hba.conf || true

# Ensure the entrypoint initialization appends the subnet rule
RUN echo '#!/bin/bash\necho "host all all 10.9.0.0/16 scram-sha-256" >> "$PGDATA/pg_hba.conf"' > /docker-entrypoint-initdb.d/01-restrict-ip.sh \
    && chmod +x /docker-entrypoint-initdb.d/01-restrict-ip.sh

# 2. DYNAMIC SCHEMA FILE INJECTION:
# Define a build argument variable (defaults to 'entrprise_demo.schema' if not provided)
ARG SCHEMA_PATH=entrprise_demo.schema

# Copy the file from your variable path into the container's auto-init directory
COPY ${SCHEMA_PATH} /docker-entrypoint-initdb.d/02-myschema.sql

# 3. DEFINE PERSISTENT VOLUME PATH
VOLUME /var/lib/postgresql/data

EXPOSE 5432
```
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
  # verify
  docker exec -it postgres_db psql -U postgres -d newpsql -c "\dt"