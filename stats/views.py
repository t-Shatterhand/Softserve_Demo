from django.shortcuts import render
from django.views.generic import View
from syt_app.models import Paste
from datetime import datetime, timedelta
from stats.forms import ModifyUserForm, SortAndSearchPasteForm
from django.shortcuts import redirect
from django.contrib.auth.models import User
from django.core.paginator import Paginator
from stats.filters import PasteFilter
from django.db.models import Q
from syt_app.utils import generate_side_panel_content


class StatsView(View):
    template_name = "stats.html"

    def get(self, request, *args, **kwargs):
        # stats for all
        pastes = Paste.objects.all()

        current_time = datetime.combine(datetime.now(), datetime.now().time(), Paste.objects.filter(expires__isnull=False)[0].expires.tzinfo)
        day_from_now = current_time + timedelta(hours=24)

        all_pastes = pastes.count()
        all_public = pastes.filter(is_private=False).count()
        all_expire_soon = pastes.filter(is_private=False, expires__range=[current_time, day_from_now]).count()
        all_permanent = pastes.filter(is_private=False, expires__isnull=True).count()
        all_available = pastes.filter(is_private=False, expires__gt=current_time).count() + all_permanent

        hour_ago = current_time - timedelta(minutes=60)
        eight_hours_ago = current_time - timedelta(hours=8)
        day_ago = current_time - timedelta(hours=24)
        three_days_ago = current_time - timedelta(days=3)
        week_ago = current_time - timedelta(days=7)
        month_ago = current_time - timedelta(days=30)
        pastes_last_hour = pastes.filter(pub_date__gt=hour_ago).count()
        pastes_last_8_hours = pastes.filter(pub_date__gt=eight_hours_ago).count()
        pastes_last_day = pastes.filter(pub_date__gt=day_ago).count()
        pastes_last_3_days = pastes.filter(pub_date__gt=three_days_ago).count()
        pastes_last_week = pastes.filter(pub_date__gt=week_ago).count()
        pastes_last_month = pastes.filter(pub_date__gt=month_ago).count()
        random_paste, random_paste_expires = generate_side_panel_content(1)

        if not request.user.is_authenticated:
            return render(request, self.template_name, context={'user_authenticated': False,
                                                                'all_pastes': all_pastes,
                                                                'all_public': all_public,
                                                                'all_private': all_pastes - all_public,
                                                                'all_available': all_available,
                                                                'all_expire_soon': all_expire_soon,
                                                                'all_permanent': all_permanent,
                                                                'all_last_day': pastes_last_day,
                                                                'all_last_hour': pastes_last_hour,
                                                                'all_last_8_hours': pastes_last_8_hours,
                                                                'all_last_3_days': pastes_last_3_days,
                                                                'all_last_week': pastes_last_week,
                                                                'all_last_month': pastes_last_month,
                                                                'random_paste': random_paste,
                                                                'random_paste_expires': random_paste_expires
                                                                } )

        # stats for user
        user_name = request.user.username
        user_pastes = Paste.objects.filter(author=request.user.id)
        user_all = user_pastes.count()
        user_public = user_pastes.filter(is_private=False).count()
        user_permanent = user_pastes.filter(is_private=False, expires__isnull=True).count()
        user_available = user_pastes.filter(is_private=False, expires__gt=current_time).count() + user_permanent

        user_expire_soon = user_pastes.filter(expires__gt=current_time,
                                              expires__lt=day_from_now).count()
        user_pastes_last_hour = user_pastes.filter(pub_date__gt=hour_ago).count()
        user_pastes_last_eight_hours = user_pastes.filter(pub_date__gt=eight_hours_ago).count()
        user_pastes_last_day = user_pastes.filter(pub_date__gt=day_ago).count()
        user_pastes_last_3_days = user_pastes.filter(pub_date__gt=three_days_ago).count()
        user_pastes_last_week = user_pastes.filter(pub_date__gt=week_ago).count()
        user_pastes_last_month = user_pastes.filter(pub_date__gt=month_ago).count()

        return render(request, self.template_name, context={'user_authenticated': True,
                                                            'user_name': user_name,
                                                            'all_pastes': all_pastes,
                                                            'all_public': all_public,
                                                            'all_private': all_pastes - all_public,
                                                            'all_available': all_available,
                                                            'all_expire_soon': all_expire_soon,
                                                            'all_permanent': all_permanent,
                                                            'all_last_hour': pastes_last_hour,
                                                            'all_last_8_hours': pastes_last_8_hours,
                                                            'all_last_day': pastes_last_day,
                                                            'all_last_3_days': pastes_last_3_days,
                                                            'all_last_week': pastes_last_week,
                                                            'all_last_month': pastes_last_month,
                                                            'user_all': user_all,
                                                            'user_public': user_public,
                                                            'user_private': user_all-user_public,
                                                            'user_available': user_available,
                                                            'user_expire_soon': user_expire_soon,
                                                            'user_permanent': user_permanent,
                                                            'user_last_hour': user_pastes_last_hour,
                                                            'user_last_8_hours': user_pastes_last_eight_hours,
                                                            'user_last_day': user_pastes_last_day,
                                                            'user_last_3_days': user_pastes_last_3_days,
                                                            'user_last_week': user_pastes_last_week,
                                                            'user_last_month': user_pastes_last_month,
                                                            'random_paste': random_paste,
                                                            'random_paste_expires': random_paste_expires
                                                            })


class UserView(View):
    template_names = ["user.html", "noUser.html"]

    def get(self, request, *args, **kwargs):
        # if not logged in
        if not request.user.is_authenticated:
            return render(request, self.template_names[1], context={})

        user_name = request.user.username

        sorting_choice = request.GET.get('sorting_choice')
        reverse_sorting = request.GET.get('reverse_sorting')
        search_string = request.GET.get('search_string')
        if not sorting_choice:
            sorting_choice = "title"
        sort_form = SortAndSearchPasteForm(initial={'sorting_choice': sorting_choice,
                                                    'reverse_sorting': reverse_sorting,
                                                    'search_string': search_string})

        if reverse_sorting:
            sorting_choice = "-" + sorting_choice

        pastes = Paste.objects.filter(author=request.user.id)
        pastes_filter = PasteFilter(request.GET, queryset=pastes)
        pastes = pastes_filter.qs

        if search_string:
            pastes = pastes.filter(Q(title__contains=f'{search_string}') |
                                   Q(short_url__contains=f'{search_string}') |
                                   Q(text__contains=f'{search_string}'))

        ordered_pastes = pastes.order_by(sorting_choice)
        paginator = Paginator(ordered_pastes, 5)
        paginated_pastes = paginator.get_page(request.GET.get('page'))
        random_paste, random_paste_expires = generate_side_panel_content(1)
        return render(request, self.template_names[0], context={'user_name': user_name,
                                                                'form': pastes_filter.form,
                                                                'sort_form': sort_form,
                                                                'paginated_pastes': paginated_pastes,
                                                                'random_paste': random_paste,
                                                                'random_paste_expires': random_paste_expires
                                                                })


class UserModifyView(View):
    template_names = ["userModify.html", "formAccepted.html"]

    def get(self, request, **kwargs):
        # if not logged in
        if not request.user.is_authenticated:
            return redirect('accounts:loginpage')

        error_text = request.session.pop("error", "")
        user_name = request.user.username
        form = ModifyUserForm(initial={'username': request.user.username,
                                       'email': request.user.email})
        random_paste, random_paste_expires = generate_side_panel_content(1)
        return render(request, self.template_names[0], context={'user_name': user_name,
                                                                'form': form,
                                                                'error_text': error_text,
                                                                'random_paste': random_paste,
                                                                'random_paste_expires': random_paste_expires
                                                                })

    def post(self, request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('accounts:loginpage')  # here redir to login page better

        form = ModifyUserForm(request.POST)
        if not form.is_valid():
            request.session["error"] = "Nickname you entered is invalid"
            return redirect("/user/modify")

        email = form.cleaned_data['email']
        password = form.cleaned_data['password']

        if not request.user.check_password(password):
            request.session["error"] = "Wrong password"
            return redirect('/user/modify')

        if request.user.email != email:
            users_with_email = User.objects.filter(email=email)
            if users_with_email.count()  > 0:
                request.session["error"] = "E-mail already exists"
                return redirect('/user/modify')
            elif email != "":
                request.user.email = email
                request.user.save()

        return redirect('user_modify')
