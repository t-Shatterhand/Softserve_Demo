from django.dispatch import receiver
from django.shortcuts import render, redirect, get_object_or_404
from .forms import *
from django.http import HttpResponse, HttpResponseRedirect
from .forms import CreateUserForm
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .forms import CreateUserForm as SignupForm
from django.contrib.sites.shortcuts import get_current_site
from django.utils.encoding import force_bytes, force_str
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.template.loader import render_to_string
from .token import account_activation_token
from django.contrib.auth.models import User
from django.core.mail import EmailMessage
from django.urls import reverse
from django.urls import reverse_lazy
from django.contrib.auth.views import PasswordResetView
from django.contrib.messages.views import SuccessMessageMixin
from allauth.account.utils import perform_login
from allauth.exceptions import ImmediateHttpResponse
from allauth.socialaccount.signals import pre_social_login
from django.conf import settings


@receiver(pre_social_login)
def link_to_local_user(sender, request, sociallogin, **kwargs):
    email_address = sociallogin.account.extra_data['email']
    users = User.objects.filter(email=email_address)
    if users:
        user = users[0]
        if user.is_active:
            perform_login(request, user, email_verification=False)
            raise ImmediateHttpResponse(
                redirect(settings.LOGIN_REDIRECT_URL.format(id=request.user.id)))
        else:
            raise ImmediateHttpResponse(redirect('loginpage'))


# Create your views here.


def loginPage(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            form = login(request, user)
            messages.success(request, f' wecome {username} !!')
            return redirect('create_paste')
        else:
            messages.info(request, f'account done not exit plz sign in')
    form = CreateUserForm()
    return render(request, 'accounts/loginpage.html', {'form': form, 'title': 'log in'})

def loginpage1(request):
    return redirect('accounts:loginpage')
def registerPage(request):
    if request.method == 'POST':
        form = SignupForm(request.POST)
        if form.is_valid():
            # save form in the memory not in database
            to_email = form.cleaned_data.get('email')
            users = User.objects.filter(email=to_email)
            if users:
                user = users[0]
                if user.is_active:

                    return render(request, 'accounts/already_exist.html')
                elif user.is_active == 0:

                    return render(request, 'accounts/already_exist.html')
            user = form.save(commit=False)
            user.is_active = False
            user.save()
            # to get the domain of the current site
            current_site = get_current_site(request)
            mail_subject = 'Activation link of your account'
            message = render_to_string('accounts/acc_active_email.html', {
                'user': user,
                'domain': current_site.domain,
                'uid': urlsafe_base64_encode(force_bytes(user.pk)),
                'token': account_activation_token.make_token(user),
            })

            to_email = form.cleaned_data.get('email')
            email = EmailMessage(
                mail_subject, message, to=[to_email]
            )
            email.send()

            return render(request,'accounts/please_confirm.html')
    else:
        form = SignupForm()
    return render(request, 'accounts/registerpage.html', {'form': form})


@login_required
def logoutUser(request):
    logout(request)
    messages.info(request, "Logged out successfully!")
    return redirect("create_paste")


def activate(request, uidb64, token):
    User = get_user_model()
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        user = User.objects.get(pk=uid)
    except(TypeError, ValueError, OverflowError, User.DoesNotExist):
        user = None
    if user is not None and account_activation_token.check_token(user, token):
        user.is_active = True
        user.save()
        return render(request, 'accounts/confirmed_user.html')

    else:
        return HttpResponse('Activation link is invalid!')


def signup_redirect(request):
    messages.error(request, "Something wrong here, it may be that you already have account!")
    return redirect("home.html")


def password_reset_complete(request):
    return redirect("password_reset_complete.html")


class ResetPasswordView(SuccessMessageMixin, PasswordResetView):
    template_name = 'password/password_reset.html'
    email_template_name = 'password/password_reset_email.html'
    subject_template_name = 'password/password_reset_subject.html'
    success_message = "We've emailed you instructions for setting your password, " \
                      "if an account exists with the email you entered. You should receive them shortly." \
                      " If you don't receive an email, " \
                      "please make sure you've entered the address you registered with, and check your spam folder."
    success_url = reverse_lazy('accounts:loginpage')
