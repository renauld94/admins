# Moodle Docker Environment

## Services Included
- **Moodle** (web server)
- **MariaDB** (database)
- **Redis** (cache, optional for performance)
- **Mailhog** (SMTP testing, web UI at :8025)
- **phpMyAdmin** (DB admin, web UI at :8081)

## Usage
1. Start all services:
   ```bash
   docker-compose up -d
   ```
2. Access Moodle at: http://localhost:8080
3. Access Mailhog (SMTP test inbox) at: http://localhost:8025
4. Access phpMyAdmin at: http://localhost:8081

## Persistent Data
- `moodledata/` for Moodle file storage
- `dbdata/` for MariaDB data

## Customization
- Place custom config in `config/`
- Place plugins in `plugins/`

## Notes
- Default DB credentials: user `moodle`, password `moodle`
- For production, configure real SMTP and secure passwords
