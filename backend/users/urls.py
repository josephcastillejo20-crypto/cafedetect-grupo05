from django.urls import path
from . import views

urlpatterns = [
    # Auth
    path('register/',        views.register_view,        name='register'),
    path('login/',           views.login_view,          name='login'),
    path('logout/',          views.logout_view,          name='logout'),
    path('profile/',         views.profile_view,         name='profile'),
    path('update_profile/',  views.update_profile_view,  name='update_profile'),
    path('change_password/', views.change_password_view, name='change_password'),
    # IA
    path('clasificar/',      views.clasificar_hoja,      name='clasificar'),
    # Historial y stats
    path('historial/',       views.historial_view,       name='historial'),
    path('stats/',           views.stats_view,           name='stats'),
]
