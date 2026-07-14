from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {
        "status": "running",
        "message": "Hello from FastAPI!"
    }

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }