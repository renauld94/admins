import os
from tornado.web import StaticFileHandler

c = get_config()

# Basic configuration
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.port = 8000

# Configure for subpath
c.JupyterHub.bind_url = "http://0.0.0.0:8000/"
c.JupyterHub.base_url = "/"

# Default spawner configuration
c.Spawner.default_url = '/lab'
c.Spawner.cmd = ['jupyter-labhub']

# Authentication
c.Authenticator.admin_users = {'admin'}
c.JupyterHub.admin_access = True

# Security
c.JupyterHub.cookie_secret = os.urandom(32)

# Use LTI Authenticator for Moodle integration
c.JupyterHub.authenticator_class = 'ltiauthenticator.LTIAuthenticator'
c.LTIAuthenticator.consumers = {
    "mylti-key": "mylti-secret"
}
c.LTIAuthenticator.username_key = 'custom_username'  # Optional: use 'lis_person_sourcedid' or 'email' if preferred

# Serve ACME challenge files for Let's Encrypt validation
def load_jupyter_server_extension(nbapp):
    """
    Serve ACME challenge files for Let's Encrypt validation.
    """
    acme_path = "/usr/share/nginx/html/.well-known"
    if os.path.exists(acme_path):
        nbapp.web_app.add_handlers(
            ".*",
            [
                (
                    r"/.well-known/(.*)",
                    StaticFileHandler,
                    {"path": acme_path},
                )
            ],
        )
