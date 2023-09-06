from django.urls import path, include, reverse_lazy
from . import views
from django.contrib.auth import views as auth_views

app_name = 'accounts'

urlpatterns = [
    path('loginpage/', views.loginPage, name="loginpage"),
    path('loginpage1/', views.loginpage1, name="loginpage1"),
    path('registerpage/', views.registerPage, name="registerpage"),
    path('logout/', views.logoutUser, name="logout"),
   # path('', views.home, name='home'),
    path('activate/<slug:uidb64>/<slug:token>',
         views.activate, name='activate'),
    #path('accounts/', views.signup_redirect, name='signup_redirect'),
    path('password-reset-confirm/<uidb64>/<token>/',
         auth_views.PasswordResetConfirmView.as_view(template_name='password/password_reset_confirm.html'),
         name='password_reset_confirm'),
    path('password-reset-complete/',
         auth_views.PasswordResetCompleteView.as_view(template_name='password/password_reset_complete.html'),
         name='password_reset_complete'),

]
