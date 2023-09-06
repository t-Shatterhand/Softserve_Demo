from django import forms


class ModifyUserForm(forms.Form):
    email = forms.EmailField(required=True)
    password = forms.CharField(required=True, widget=forms.PasswordInput())

    class Meta:
        fields = ["email", "password"]


class SortAndSearchPasteForm(forms.Form):
    CHOICES = [("title", "Title"),
               ("text", "Text"),
               ("pub_date", "Publication Date"),
               ("expires", "Expiration Date"),
               ("language", "Language"),
               ("category", "Category")]
    sorting_choice = forms.ChoiceField(choices=CHOICES)
    reverse_sorting = forms.BooleanField(required=False)
    search_string = forms.CharField(required=False)
