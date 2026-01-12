# Simple single-stage Dockerfile (pas de multi-stage nécessaire)
FROM python:3.11-slim

WORKDIR /app

# Install cron and required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cron \
        && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY export-script.py /app/export-script.py
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create non-root user and setup directories
# Cron runs as root, but script executes as non-root user
RUN useradd -m -u 1000 exporter && \
    mkdir -p /app/data /mnt/export && \
    chown -R exporter:exporter /app /mnt/export && \
    chmod 755 /app/data

# Keep root user for cron (cron needs root to create PID file)
# Script will be executed as 'exporter' user via su in entrypoint.sh

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check (simple, robuste, sans Python)
HEALTHCHECK --interval=1h --timeout=10s --start-period=5m --retries=1 \
    CMD test -f /app/data/export-stats.json && \
        test $(( $(date +%s) - $(stat -c %Y /app/data/export-stats.json) )) -lt 90000 || exit 1

# Start via entrypoint (configure cron dynamiquement)
CMD ["/app/entrypoint.sh"]
