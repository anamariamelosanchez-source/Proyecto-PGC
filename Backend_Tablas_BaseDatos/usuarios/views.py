from django.db.models import Max, Q
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model
from django.db import transaction
from .models import Usuarios, Rol, UsuariosHasRol
from .serializers import UsuariosSerializer

# ==========================================
# 1. VISTA DE AUTENTICACIÓN (LOGIN)
# ==========================================
@api_view(['POST'])
def login_personalizado(request):
    username_input = request.data.get('username')
    password_input = request.data.get('password')
    print(f"--> Flutter está intentando loguearse con el usuario: '{username_input}'")
    
    if not username_input or not password_input:
        return Response({"error": "Por favor proporcione usuario y contraseña"}, 
                        status=status.HTTP_400_BAD_REQUEST)
    
    try:

        usuario_db = Usuarios.objects.filter(
            Q(email__iexact=username_input) | Q(nombre__iexact=username_input)
        ).first()
        
        if not usuario_db:
            return Response({"error": "El usuario no existe en la base de datos."}, 
                            status=status.HTTP_400_BAD_REQUEST)
        
        if str(usuario_db.contraseña).strip() == str(password_input).strip():
            User = get_user_model()
            username_limpio = usuario_db.email if usuario_db.email else f"user_{usuario_db.idusuario}"
            
            user_espejo, _ = User.objects.get_or_create(username=username_limpio, 
                                                        defaults={'email': usuario_db.email})
            token, _ = Token.objects.get_or_create(user=user_espejo)
            
            # Usamos el serializador para incluir la data estructurada junto con su rol
            serializer = UsuariosSerializer(usuario_db)
            return Response({
                "token": token.key,
                "user": serializer.data
            }, status=status.HTTP_200_OK)
            
        return Response({"error": "Contraseña incorrecta."}, 
                        status=status.HTTP_400_BAD_REQUEST)
                        
    except Exception as e:
        return Response({"error": f"Error operativo: {str(e)}"}, 
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# ==========================================
# 2. CRUD DEL RECURSO USUARIOS
# ==========================================
class UsuariosViewSet(viewsets.ModelViewSet):
    """
    CRUD completo y optimizado para la gestión de Usuarios y asignación de Roles por 
    rangos de IDs.
    """
    queryset = Usuarios.objects.all()
    serializer_class = UsuariosSerializer
    lookup_field = 'idusuario'

    def get_queryset(self):
        queryset = Usuarios.objects.all()
        nombre = self.request.query_params.get('nombre', None)
        email = self.request.query_params.get('email', None)
        
        if nombre:
            queryset = queryset.filter(
                Q(nombre__iexact=nombre) | Q(email__iexact=nombre)
            )
        if email:
            queryset = queryset.filter(email__iexact=email)
        return queryset

    def create(self, request, *args, **kwargs):
        """POST: Crea un usuario asignándole un ID manual según su rol y su tabla intermedia."""
        data = request.data
        data.pop('idusuario', None)
        id_rol_input = data.get('idrol')
        identificador = data.get('email', '').strip()
        
        if not identificador:
            return Response({"error": "El campo de correo o usuario es requerido."}, 
                            status=status.HTTP_400_BAD_REQUEST)
        
        if '@' not in identificador:

            data['email'] = f"{identificador}@tulimarket.local"
        else:
            data['email'] = identificador

        if Usuarios.objects.filter(email=data.get('email')).exists():
            return Response(
                {"error": "El usuario o correo electrónico ya se encuentra registrado."},
                status=status.HTTP_400_BAD_REQUEST
            )

        rol_instancia = None
        if id_rol_input:
            rol_instancia = Rol.objects.filter(idrol=id_rol_input).first()
            if not rol_instancia:
                return Response({"error": "El ID de rol proporcionado no existe."}, 
                                status=status.HTTP_400_BAD_REQUEST)

        # 3. LÓGICA DE RANGOS DE IDS ESTRICTOS PARA EL USUARIO
        min_id = 1
        max_id = 29

        if rol_instancia:
            nombre_rol_limpio = rol_instancia.nombre_rol.lower().strip()
            if rol_instancia.idrol == 2 or nombre_rol_limpio == 'comprador':
                min_id = 1
                max_id = 200
            elif rol_instancia.idrol == 3 or nombre_rol_limpio == 'emprendedor':
                min_id = 201
                max_id = 500
            elif rol_instancia.idrol == 4 or nombre_rol_limpio == 'proveedor':
                min_id = 501
                max_id = 800
            elif rol_instancia.idrol == 5 or nombre_rol_limpio == 'asesor':
                min_id = 801
                max_id = 1100
            elif rol_instancia.idrol == 6 or nombre_rol_limpio in ('prestador de servicios', 'prestador servicios'):
                min_id = 1101
                max_id = 1400

        max_id_actual = Usuarios.objects.filter(
            idusuario__gte=min_id,
            idusuario__lte=max_id
        ).aggregate(Max('idusuario'))['idusuario__max']

        if max_id_actual is not None:
            nuevo_idusuario = int(max_id_actual) + 1
        else:
            nuevo_idusuario = int(min_id)

        if nuevo_idusuario > max_id:
            return Response(
                {"error": f"Se ha alcanzado el límite máximo de IDs ({max_id}) para este tipo de rol."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if 'telefono' in data:
            try:
                tel_str = str(data['telefono']).strip()
                if len(tel_str) > 9:
                    tel_str = tel_str[-8:]
                data['telefono'] = int(tel_str)
            except ValueError:
                return Response(
                    {"error": "El campo teléfono debe ser un valor puramente numérico entero."},
                    status=status.HTTP_400_BAD_REQUEST
                )

        data['idusuario'] = str(nuevo_idusuario)
        data['estado'] = '1'

        # 4. Guardado en Base de Datos con transacciones atómicas
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            usuario_creado = serializer.save()
            if rol_instancia:
                UsuariosHasRol.objects.create(
                    usuarios_idusuario=usuario_creado,
                    rol_idrol=rol_instancia
                )
        serializer_actualizado = self.get_serializer(usuario_creado)
        return Response(serializer_actualizado.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        """PUT/PATCH: Actualiza los datos del usuario y cambia su rol si es necesario."""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        data = request.data.copy()
        
        data.pop('idusuario', None)
        id_rol_input = data.get('idrol')

        if 'telefono' in data:
            try:
                data['telefono'] = int(str(data['telefono']).strip())
            except ValueError:
                return Response({"error": "El teléfono debe ser numérico."}, 
                                status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(instance, data=data, partial=partial)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            usuario_actualizado = serializer.save()
            if id_rol_input:
                rol_instancia = Rol.objects.filter(idrol=id_rol_input).first()
                if not rol_instancia:
                    return Response({"error": "El ID de rol proporcionado no existe."}, 
                                    status=status.HTTP_400_BAD_REQUEST)
                
                relacion, created = UsuariosHasRol.objects.get_or_create(
                    usuarios_idusuario=usuario_actualizado,
                    defaults={'rol_idrol': rol_instancia}
                )
                if not created:
                    relacion.rol_idrol = rol_instancia
                    relacion.save()

        serializer_actualizado = self.get_serializer(usuario_actualizado)
        return Response(serializer_actualizado.data, status=status.HTTP_200_OK)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.estado = '0'
        instance.save()
        return Response(
            {"message": f"Usuario {instance.idusuario} desactivado correctamente."},
            status=status.HTTP_200_OK
        )
