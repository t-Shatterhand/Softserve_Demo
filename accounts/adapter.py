from django.contrib.auth.models import User

from allauth.exceptions import ImmediateHttpResponse
from allauth.socialaccount.adapter import DefaultSocialAccountAdapter


class MyAdapter(DefaultSocialAccountAdapter):
    def pre_social_login(self, request, sociallogin):
        # This isn't tested, but should work
        print('ssss', sociallogin.user)
        try:
            user = User.objects.get(email=sociallogin.email)
            sociallogin.connect(request, user)
            # Create a response object
            raise ImmediateHttpResponse('Login in to existing user')
        except User.DoesNotExist:
            pass
