from django import forms
from syt_app.models import Paste
from syt_app.utils import transform_expired_choice


class PasteForm(forms.ModelForm):
    CHOICES = [(transform_expired_choice(1), "1 hour"),
               (transform_expired_choice(6), "6 hours"),
               (transform_expired_choice(12), '12 hours'),
               (transform_expired_choice(24), '1 day'),
               (None, 'Never')]
    expires = forms.DateTimeField(input_formats=["%d/%m/%y %H:%M:%S"], widget=forms.Select(choices=CHOICES),
                                  required=False)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.initial:
            prev_choices = self.fields['expires'].widget.choices
            prev_choices.insert(0, (self.instance.expires, "Don't change"))
            self.fields['expires'] = forms.DateTimeField(input_formats=["%d/%m/%y %H:%M:%S"],
                                                         widget=forms.Select(choices=prev_choices))


class AuthorizedCreatePasteForm(PasteForm):
    as_guest = forms.BooleanField(required=False)

    class Meta:
        model = Paste
        fields = ["title", "language", "expires", "text", "as_guest", "category", "is_private"]


class AnonymousCreatePasteForm(PasteForm):
    class Meta:
        model = Paste
        fields = ["title", "language", "expires", "text", "category"]
