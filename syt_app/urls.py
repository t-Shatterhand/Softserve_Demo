from django.urls import path

from . import views

urlpatterns = [
    path("", views.PasteCreateView.as_view(), name="create_paste"),
    path("<slug:short_url>", views.DisplayPasteView.as_view(), name='display_user_paste'),
    path("edit/<slug:short_url>", views.EditPasteView.as_view(), name='edit_user_paste'),
    path("clipaste/<slug:short_url>", views.console_paste_creation, name="console_get_paste"),
    path("clipaste/", views.console_paste_creation, name="console_create_paste"),
    path("delete/<int:id>", views.DeletePasteView.as_view(), name='delete_paste')
]
