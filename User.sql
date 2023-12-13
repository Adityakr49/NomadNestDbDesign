psql -U postgres -h localhost

CREATE USER user2 WITH PASSWORD 'your_password';

GRANT CREATE, CONNECT ON DATABASE "NomadNest" TO user1;

psql -U user1 -d NomadNest

REVOKE CREATE, CONNECT ON DATABASE "NomadNest" FROM user1;

