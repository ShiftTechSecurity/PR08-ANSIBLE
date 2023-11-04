CREATE DATABASE IF NOT EXISTS bdd_glpi;

CREATE USER IF NOT EXISTS '{{ client_username }}'@'localhost' IDENTIFIED BY '{{ client_password }}';
GRANT ALL PRIVILEGES ON bdd_glpi.* TO '{{ client_username }}'@'localhost';
FLUSH PRIVILEGES;