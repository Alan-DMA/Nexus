from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.auth import router as auth_router

app = FastAPI(
    title="Nexus API",
    description="Gestión Comercial Modular para el Retail Venezolano",
    version="1.0.0",
)

# Configuración de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Ajustar en producción según sea necesario
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registrar Routers
app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])

@app.get("/")
def read_root():
    return {
        "name": "Nexus API",
        "version": "1.0.0",
        "status": "active",
        "message": "Bienvenido al Sistema de Gestión Comercial Nexus"
    }
