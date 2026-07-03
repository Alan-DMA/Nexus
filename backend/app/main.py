from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncio

from app.api.v1.auth import router as auth_router
from app.api.v1.inventory import router as inventory_router
from app.api.v1.sales import router as sales_router
from app.core.tasks import release_expired_reservations_loop

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: iniciar la tarea de liberación de stock
    cleanup_task = asyncio.create_task(release_expired_reservations_loop())
    yield
    # Shutdown: cancelar la tarea al apagar
    cleanup_task.cancel()
    try:
        await cleanup_task
    except asyncio.CancelledError:
        pass

app = FastAPI(
    title="Nexus API",
    description="Gestión Comercial Modular para el Retail Venezolano",
    version="1.0.0",
    lifespan=lifespan,
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
app.include_router(inventory_router, prefix="/api/v1/inventory", tags=["inventory"])
app.include_router(sales_router, prefix="/api/v1/sales", tags=["sales"])

@app.get("/")
def read_root():
    return {
        "name": "Nexus API",
        "version": "1.0.0",
        "status": "active",
        "message": "Bienvenido al Sistema de Gestión Comercial Nexus"
    }
