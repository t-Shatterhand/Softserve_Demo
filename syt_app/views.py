from django.shortcuts import render, redirect
from django.http import HttpResponseForbidden, HttpResponse
from django.views.generic import View
from syt_app.forms import AnonymousCreatePasteForm, AuthorizedCreatePasteForm
from syt_app.utils import generate_short_url, generate_side_panel_content
from syt_app.models import Paste
from django.contrib.auth.models import User
from django.views.decorators.csrf import csrf_exempt
from datetime import datetime
from django.utils.timezone import make_aware


@csrf_exempt
def console_paste_creation(request, *args, **kwargs):
    if request.method == 'POST':
        short_url = generate_short_url(8)
        text = request.POST.get('text', False)
        if text:
            new_paste = Paste(author=None,
                              title=request.POST.get('title', "console_created_paste"),
                              language=request.POST.get('language', "text/x-python"),
                              text=request.POST.get('text'),
                              category="Other",
                              short_url=short_url,
                              is_private=False)
            new_paste.save()
            return HttpResponse(f"{short_url}")
        return HttpResponse("text field should be filled")
    elif request.method == 'GET':
        short_url = kwargs.get('short_url', False)
        if short_url:
            return HttpResponse(f"{Paste.objects.get(short_url=kwargs['short_url']).text}")
        return HttpResponse("help text")


class PasteCreateView(View):
    template_name = "create_paste.html"

    def get(self, request, *args, **kwargs):
        random_paste, random_paste_expires = generate_side_panel_content(1)
        if request.user.is_authenticated:
            form = AuthorizedCreatePasteForm()
            return render(request, self.template_name, context={"form": form,
                                                                "random_paste": random_paste,
                                                                "random_paste_expires": random_paste_expires})

        form = AnonymousCreatePasteForm()
        return render(request, self.template_name, context={"form": form,
                                                            "random_paste": random_paste,
                                                            "random_paste_expires": random_paste_expires})

    def post(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            form = AuthorizedCreatePasteForm(request.POST)
        else:
            form = AnonymousCreatePasteForm(request.POST)

        short_url = generate_short_url(8)

        if form.is_valid():
            user_id = request.user.id
            if user_id is not None and not form.cleaned_data['as_guest']:
                user = User.objects.get(id=user_id)
            else:
                user = None  # Anonymous user

            new_paste = Paste(author=user,
                              title=form.cleaned_data['title'],
                              language=form.cleaned_data['language'],
                              expires=form.cleaned_data['expires'],
                              text=form.cleaned_data['text'],
                              category=form.cleaned_data['category'],
                              short_url=short_url,
                              is_private=form.cleaned_data.get('is_private', False))

            new_paste.save()
            return redirect('display_user_paste', short_url=f"{short_url}")
        return HttpResponseForbidden()


class DisplayPasteView(View):
    template_name = 'display_paste.html'

    def get(self, request, short_url=None, *args, **kwargs):
        if short_url is not None:
            paste = Paste.objects.get(short_url=short_url)
            user = request.user
            if ((paste.is_private and user.id == paste.author.id) or not paste.is_private) and (paste.expires is None or paste.expires > make_aware(datetime.now())):
                random_paste, random_paste_expires = generate_side_panel_content(1)
                #random_paste, random_paste_expires = 1, 1
                return render(request, self.template_name, context={"paste": paste,
                                                                    "random_paste": random_paste,
                                                                    "random_paste_expires": random_paste_expires})
            return HttpResponseForbidden()


class EditPasteView(View):
    template_name = 'edit_paste.html'

    def get(self, request, short_url=None, *args, **kwargs):
        paste = Paste.objects.get(short_url=short_url)
        user = request.user
        if user is not None and paste.author is not None:
            if user.id == paste.author.id and user.id is not None and (paste.expires is None or paste.expires > make_aware(datetime.now())):
                random_paste, random_paste_expires = generate_side_panel_content(1)
                form = AuthorizedCreatePasteForm(instance=paste)
                return render(request, self.template_name, context={"form": form,
                                                                    "random_paste": random_paste,
                                                                    "random_paste_expires": random_paste_expires,
                                                                    'short_url': paste.short_url})
        return HttpResponseForbidden()

    def post(self, request, short_url=None, *args, **kwargs):
        user_id = request.user.id
        form = AuthorizedCreatePasteForm(request.POST)
        if form.is_valid() and user_id == Paste.objects.get(short_url=short_url).author.id:
            Paste.objects.filter(short_url=short_url).update(title=form.cleaned_data['title'],
                                                             language=form.cleaned_data['language'],
                                                             expires=form.cleaned_data['expires'],
                                                             category=form.cleaned_data['category'],
                                                             text=form.cleaned_data['text'],
                                                             is_private=form.cleaned_data.get('is_private', False))
            return redirect('display_user_paste', short_url=f"{short_url}")
        return HttpResponseForbidden()


class DeletePasteView(View):

    def delete(self, request, id, *args, **kwargs):
        user_id = request.user.id
        paste = Paste.objects.get(id=id)
        if not request.user.is_anonymous and user_id == paste.author.id:
            paste.delete()
            return redirect('user_view')
        return HttpResponseForbidden()

