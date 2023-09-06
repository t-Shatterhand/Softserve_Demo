import django_filters
from syt_app.models import Paste


class PasteFilter(django_filters.FilterSet):

    class Meta:
        model = Paste
        fields = ['language', 'category', 'is_private']