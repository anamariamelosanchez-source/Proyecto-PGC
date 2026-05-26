from django.contrib import admin
from .models import Usuarios, Rol, UsuariosHasRol

class UsuariosHasRolInline(admin.TabularInline):
    model = UsuariosHasRol
    extra = 1

@admin.register(Usuarios)
class UsuariosAdmin(admin.ModelAdmin):
    list_display = ('idusuario', 'nombre', 'email', 'estado')
    search_fields = ('nombre', 'email')
    list_filter = ('estado',)
    inlines = [UsuariosHasRolInline] 

@admin.register(Rol)
class RolAdmin(admin.ModelAdmin):
    list_display = ('idrol', 'nombre_rol')
    search_fields = ('nombre_rol',)
