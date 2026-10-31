#!/bin/bash

# PostgreSQL configuration
CONTAINER="devops-postgres"
DB_NAME="testdb"
DB_USER="reza"

# Backup directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/../backups"

mkdir -p "$BACKUP_DIR"

# Show available commands
usage() {
    echo "Usage: $0 {backup|restore|list|delete}"
}

# Create a backup
backup() {
    DATE=$(date +"%Y-%m-%d_%H-%M-%S")
    FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz"

    echo "Starting database backup..."

    if docker exec "$CONTAINER" pg_dump --clean --if-exists -U "$DB_USER" "$DB_NAME" | gzip > "$FILE"; then
        echo "Backup created successfully: $FILE"
    else
        echo "Backup failed!"
        rm -f "$FILE"
        return 1
    fi

    # Remove backups older than 7 days
    find "$BACKUP_DIR" -type f -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete

    echo "Old backups cleaned up."
}

# List available backups
list() {
    echo "Available PostgreSQL backups:"
    echo "--------------------------------"

    find "$BACKUP_DIR" -maxdepth 1 -type f -name "${DB_NAME}_*.sql.gz" -printf '%f (%s bytes)\n' | sort

}

# Restore a backup
restore() {
    FILE="$BACKUP_DIR/$2"

    if [[ -z "$2" || "$2" == */* || ! -f "$FILE" ]]; then
        echo "Error: Backup file not found."
        echo "Usage: $0 restore BACKUP_FILENAME"
        return 1
    fi

    echo "WARNING: You are restoring into database: $DB_NAME"
    echo "Existing tables or data may conflict with the backup."

    read -r -p "Are you sure? (y/N): " CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Restore cancelled."
        return 0
    fi

    echo "Restoring database..."

    if gzip -t "$FILE" && gzip -dc "$FILE" | docker exec -i "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME"; then
        echo "Database restored successfully."
    else
        echo "Restore failed!"
        return 1
    fi
}

# Delete a backup
delete() {
    FILE="$BACKUP_DIR/$2"

    if [[ -z "$2" || "$2" == */* || ! -f "$FILE" || "$2" != "${DB_NAME}_"*.sql.gz ]]; then
        echo "Error: Backup file not found."
        echo "Usage: $0 delete BACKUP_FILENAME"
        return 1
    fi

    read -r -p "Delete $2? (y/N): " CONFIRM

    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        rm -- "$FILE"
        echo "Backup deleted successfully."
    else
        echo "Delete cancelled."
    fi
}

# Command handler
case "$1" in
    backup)
        backup
        ;;
    restore)
        restore "$@"
        ;;
    list)
        list
        ;;
    delete)
        delete "$@"
        ;;
    *)
        usage
        exit 1
        ;;
esac
