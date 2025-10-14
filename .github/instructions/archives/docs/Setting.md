use:

Moodle:
http://localhost:8081

JupyterHub:
http://localhost:8000

ML API:
http://localhost:8001

MLflow:
http://localhost:5000

Bitbucket:
http://localhost:7990

2. Via Domain Names (with nginx-proxy)
If you set up your hosts file to point your subdomains to 127.0.0.1, you can use your public-style domains locally:

Edit hosts (as root) and add:

NMoodle: http://localhost:8081
JupyterHub: http://localhost:8000
ML API: http://localhost:8001
MLflow: http://localhost:5000
Bitbucket: http://localhost:7990
Domain Name Access (from anywhere, if DNS and HTTPS are set up):
Moodle: https://moodle.datalabsimon.duckdns.org
JupyterHub: https://jupyter.datalabsimon.duckdns.org
ML API: https://ml-api.datalabsimon.duckdns.org
MLflow: https://mlflow.datalabsimon.duckdns.org
Bitbucket: https://bitbucket.datalabsimon.duckdns.org




CONTAINER ID	NAME	Purpose
abb6345e40f1	moodle	Moodle LMS: Web-based learning management system for courses, users, and content.
1e6a65721ab2	nginx-proxy-acme	ACME Companion: Manages SSL certificates (Let's Encrypt) for nginx-proxy automatically.
5ae9820ddbe8	bitbucket	Bitbucket Server: Git repository management for code collaboration (currently disabled/commented).
cd28c82ee2c5	moodle-db	MariaDB: Database backend for Moodle, stores all course/user/content data.
b02593f5974b	nginx-proxy	nginx-proxy: Reverse proxy that routes incoming HTTP/HTTPS traffic to the correct service container.
961362247ed6	mlflow	MLflow: Platform for managing machine learning experiments, models, and artifacts.
7c67d90f3abc	ml-api	ML API: Custom FastAPI/uvicorn service for exposing machine learning models as APIs.
9979c744e0c7	jupyterhub	JupyterHub: Multi-user Jupyter notebook server for interactive Python/data science work.

# Service URLs (Local Access)

| Service     | URL                   |
|-------------|-----------------------|
| Moodle      | http://localhost:8081 |
| JupyterHub  | http://localhost:8000 |
| ML API      | http://localhost:8001 |
| MLflow      | http://localhost:5000 |
| Bitbucket   | http://localhost:7990 |

# Domain Name Access (with nginx-proxy and DNS/HTTPS)

| Service     | Domain URL                                   |
|-------------|----------------------------------------------|
| Moodle      | https://moodle.datalabsimon.duckdns.org      |
| JupyterHub  | https://jupyter.datalabsimon.duckdns.org     |
| ML API      | https://ml-api.datalabsimon.duckdns.org      |
| MLflow      | https://mlflow.datalabsimon.duckdns.org      |
| Bitbucket   | https://bitbucket.datalabsimon.duckdns.org   |

# Hosts File Example (for local domain mapping)

Add to `/etc/hosts`:
```
127.0.0.1 moodle.datalabsimon.duckdns.org
127.0.0.1 jupyter.datalabsimon.duckdns.org
127.0.0.1 ml-api.datalabsimon.duckdns.org
127.0.0.1 mlflow.datalabsimon.duckdns.org
127.0.0.1 bitbucket.datalabsimon.duckdns.org
```

# Container Overview

| Container ID   | Name             | Purpose                                                                                                 |
|----------------|------------------|---------------------------------------------------------------------------------------------------------|
| abb6345e40f1   | moodle           | Moodle LMS: Web-based learning management system for courses, users, and content.                       |
| 1e6a65721ab2   | nginx-proxy-acme | ACME Companion: Manages SSL certificates (Let's Encrypt) for nginx-proxy automatically.                 |
| 5ae9820ddbe8   | bitbucket        | Bitbucket Server: Git repository management for code collaboration (currently disabled/commented).       |
| cd28c82ee2c5   | moodle-db        | MariaDB: Database backend for Moodle, stores all course/user/content data.                              |
| b02593f5974b   | nginx-proxy      | nginx-proxy: Reverse proxy that routes incoming HTTP/HTTPS traffic to the correct service container.    |
| 961362247ed6   | mlflow           | MLflow: Platform for managing machine learning experiments, models, and artifacts.                      |
| 7c67d90f3abc   | ml-api           | ML API: Custom FastAPI/uvicorn service for exposing machine learning models as APIs.                    |
| 9979c744e0c7   | jupyterhub       | JupyterHub: Multi-user Jupyter notebook server for interactive Python/data science work.                


~/sync_to_vm.sh