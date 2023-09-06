"""knu_tech_prac URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
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
from accounts.views import ResetPasswordView
urlpatterns = [
    path("", include("syt_app.urls")),
    path("statistics/", include("stats.urls")),
    path("user/", include("stats.userUrls")),
    path('admin/', admin.site.urls),
    path('', include('accounts.urls')),
    path("accounts/", include("allauth.urls")),
    path('password-reset/', ResetPasswordView.as_view(), name='password_reset'),
    path('accounts/', include('social_django.urls', namespace="social")),

]

