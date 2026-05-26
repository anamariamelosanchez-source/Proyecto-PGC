"""
URL configuration for backend_tuli project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from tienda.views import ProductoViewSet
from rest_framework.authtoken import views
from usuarios.views import login_personalizado
from django.conf import settings
from django.conf.urls.static import static
# Router para las tablas que se queden de forma local en la app principal
router = DefaultRouter()
router.register(r'productos', ProductoViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),

    
    # 1. Rutas del router local de la raíz (Productos)
    path('api/tienda/', include(router.urls)),
    
    # 2. Inclusión de la aplicación independiente de Usuarios
    path('api/', include('usuarios.urls')), 
    
    # 3. Endpoint de Autenticación por Token
    path('api/login/', login_personalizado, name='login'),
    
    #4. Inclusión de la nueva app de productos 
    path('api/producto/', include('Producto.urls')), 
    
    #5. Inclusión de la app de carrito 
    path('api/carrito/', include('app_carrito.urls')),
    
    #6. Inclusión de la nueva app de inventario
    path('api/inventario/', include('inventario.urls')), 

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

