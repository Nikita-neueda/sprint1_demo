# PostgreSQL Setup and Configuration Guide (Linux EC2 & Windows pgAdmin)

This guide outlines the steps to configure a PostgreSQL instance on a Linux VM (EC2) to accept network connections from a Windows VM running pgAdmin, and how to import an existing database schema file.

---
# Installation step:
```
sudo dnf install -y postgresql15 postsql15-server
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql
psql --version
sudo -i - u postgres psql
------- optional steps
- check it will run but locally
suso ss -tulpn | grep postgres
sudo systemctl status postgresql
```

## 1. Configure PostgreSQL Network Settings (Linux VM)
# command to find the file 
```
sudo find / -name "postgresql.conf" 2>/dev/null
```
- was 3 file to find which one to modify
- steps did
```
sudo -i -u postgres psql
show config_file
\q
```
### Step 1: Open Global IP Listening
Open the main configuration file with admin privileges:
```bash
sudo nano /var/lib/pgsql/data/postgresql.conf
```
Find line 60 (or search for `listen_addresses`). **Remove the `#` symbol** from the beginning of the line and set it to listen on all interfaces:
```text
listen_addresses = '*'
```
*Save and exit (`Ctrl + O`, `Enter`, `Ctrl + X`).*

### Step 2: Configure Client Authentication (`pg_hba.conf`)
Open the host-based authentication rules file:
```bash
sudo nano /var/lib/pgsql/data/pg_hba.conf
```
Scroll to the bottom and ensure your local loopback and internal networks use secure password authentication (`scram-sha-256`) instead of `peer` or `ident`:
```text
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     scram-sha-256
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             10.9.0.0/16             scram-sha-256
```
*Save and exit (`Ctrl + O`, `Enter`, `Ctrl + X`).*

### Step 3: Hard-Restart the Service
Apply the configuration changes by restarting the system daemon:
```bash
sudo systemctl restart postgresql
```

### Step 4: Verify Network Binding
Verify that the database engine is successfully listening on all interfaces (`*` or `0.0.0.0`) rather than just `localhost`:
```bash
sudo lsof -iTCP:5432 -sTCP:LISTEN
```
*Expected output line: `postgres ... TCP *:postgres (LISTEN)`*

---

## 2. Set Up Database Password Authentication

### Step 1: Access the Native Postgres Console
Log into the database server using the default admin system wrapper:
```bash
sudo su - postgres -c "psql"
```

### Step 2: Set the Password
Assign a secure password to the default administrative database role:
```sql
ALTER USER postgres WITH PASSWORD 'your_secure_password_here';
```
# run psql on linux with port and ip (replace with app ip)
```
psql -U postgres -h 10.x.x.x -p 5432

```
### Step 3: Exit the Prompt
```text
\q
```

---

## 3. Connect from Windows VM pgAdmin

### Step 1: Check Windows Network Setup
Open Command Prompt (`cmd`) inside your **Windows VM** and find its IP network assignment:
```cmd
ipconfig
```
*(Ensure your IPv4 address falls within the allowed subnet `10.9.0.0/16` configured in your `pg_hba.conf`).*

### Step 2: Register Server in pgAdmin
1. Open **pgAdmin** on the Windows VM.
2. Right-click **Servers** > **Register** > **Server...**
3. **General Tab:** Set Name to `Linux-EC2-PostgreSQL`.
4. **Connection Tab:** Fill out the following parameters:
   * **Host name/address:** `10.x.x.x` *(Linux VM IP)*
   * **Port:** `5432`
   * **Maintenance database:** `postgres`
   * **Username:** `postgres`
   * **Password:** `your_secure_password_here`
   * **Save password?:** Check this box.
5. **SSH Tunnel Tab:** Ensure **Use SSH Tunneling** is set to **No**.
6. Click **Save**.

---

## 4. Initialize Database and Import Schema (Linux VM)

### Step 1: Create the Target Database
Run this command from your regular Linux terminal to create the blank database container:
```bash
sudo su - postgres -c "createdb paysprint_wealth_demo"
```

### Step 2: Execute the SQL Schema File
Run the `.sql` script located in the `ec2-user` home folder directly into the new target database container:
```bash
psql -U postgres -d paysprint_wealth_demo -f /home/ec2-user/leap-sprint3/shared/enterprise-schema.sql
```
*(Enter your database password when prompted. The terminal will output `CREATE TABLE` and `ALTER TABLE` statements as the schema generates).*
