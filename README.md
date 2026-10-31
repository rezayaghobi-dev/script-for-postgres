# PostgreSQL Backup & Restore Script

## Usage

```bash
./scripts/backup.sh backup                      # Create a new backup
./scripts/backup.sh list                        # List available backups
./scripts/backup.sh restore <backup_filename>   # Restore a backup
./scripts/backup.sh delete <backup_filename>    # Delete a backup





What --clean --if-exists Fixed
The line docker exec "$CONTAINER" pg_dump --clean --if-exists -U "$DB_USER" "$DB_NAME" | gzip > "$FILE" fixes the ERROR: relation "employees" already exists failure during restore.

Without --clean --if-exists, pg_dump only emits CREATE TABLE statements, so restoring into a database that already has those tables fails immediately. With --clean --if-exists, every backup now includes DROP TABLE IF EXISTS ... (and drops for sequences, views, functions, etc.) at the top of the dump, so a restore cleanly wipes conflicting objects before recreating them.

Note: This only affects backups taken after the change. Backups made before it do not contain the DROP statements and will still fail on restore unless the schema is cleared first with:






docker exec -i devops-postgres psql -U reza -d testdb -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

