from fastapi import FastAPI
from backend.controllers.vocabulary_controller import router as vocabulary_router

app = FastAPI(
    title="DutchA2Quiz API",
    description="Backend API for the Dutch A2 Vocabulary Learning App",
    version="1.0.0"
)
app.include_router(vocabulary_router)


@app.get("/")
def root():
    return {
        "success": True,
        "message": "DutchA2Quiz API is running!"
    }


@app.get("/api/health")
def health_check():
    return {
        "success": True,
        "status": "healthy"
    }
