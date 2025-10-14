from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import os

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "ML API is running"}

# Serve ACME challenge files for Let's Encrypt
if os.path.exists("/usr/share/nginx/html/.well-known"):
    app.mount("/.well-known", StaticFiles(directory="/usr/share/nginx/html/.well-known"), name="well-known")