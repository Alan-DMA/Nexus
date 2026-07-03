from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from app.core.config import settings

# Crear motor de base de datos asíncrono para PostgreSQL
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=True,  # Mostrar logs de consultas SQL en consola en desarrollo
)

# Creador de sesiones asíncronas
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

Base = declarative_base()

from sqlalchemy import text
from app.core.rls import get_current_tenant

# Dependencia para inyección de base de datos en endpoints FastAPI
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        # Recuperar el tenant actual del contexto
        tenant_id = get_current_tenant() or ""
        # Configurar el parámetro en la base de datos de manera local a la transacción
        await session.execute(text("SELECT set_config('app.current_tenant', :tenant_id, false)"), {"tenant_id": tenant_id})
        try:
            yield session
        finally:
            await session.close()

