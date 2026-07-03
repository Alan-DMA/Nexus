import os
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

# Cargar variables de entorno desde el archivo .env
load_dotenv()

class Settings(BaseSettings):
    PROJECT_NAME: str = "Nexus"
    API_V1_STR: str = "/api/v1"
    
    # Base de Datos (PostgreSQL RLS)
    # Por defecto apunta a base de datos sqlite en memoria para desarrollo rápido
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql+asyncpg://postgres:postgres@localhost:5432/nexus")
    
    # Seguridad
    SECRET_KEY: str = os.getenv("SECRET_KEY", "super-secret-key-change-in-production-1234567890")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15  # Regla de la Constitución (Art. 7.5)
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7    # Regla de la Constitución (Art. 7.5)

    class Config:
        case_sensitive = True

settings = Settings()
