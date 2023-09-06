from django.urls import path

from . import views

urlpatterns = [
    path("", views.UserView.as_view(), name="user_view"),
    path("modify", views.UserModifyView.as_view(), name="user_modify"),
]