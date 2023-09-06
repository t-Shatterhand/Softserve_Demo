import random
import string
from syt_app.models import Paste
from datetime import datetime, timedelta, timezone
from django.db.models import Q
from django.utils.timezone import make_aware


def pub_time():
    return make_aware(datetime.now())


def generate_short_url(length):
    short_url = [random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(length)]
    short_url = ''.join(short_url)
    while Paste.objects.filter(short_url=short_url).exists():
        short_url = [random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(length)]
        short_url = ''.join(short_url)

    return short_url


def generate_side_panel_content(period):
    td = timedelta(hours=period)
    rand_pub_pst = Paste.objects.filter(Q(is_private=False) &
                                        (Q(expires__gt=make_aware(datetime.now() + td)) | Q(expires=None)))

    if rand_pub_pst.count() != 0:
        rand_pub_pst = rand_pub_pst.order_by('?')[0]
    else:
        rand_pub_pst = Paste.objects.create(author=None,
                                            title="Random paste",
                                            language="text/x-php",
                                            expires=None,
                                            text="Random text in the random paste",
                                            category="Other",
                                            short_url=generate_short_url(8),
                                            is_private=False)

    curr_aw_t = datetime.combine(datetime.now(), datetime.now().time(),
                                 rand_pub_pst.pub_date.tzinfo)  # current aware time
    rand_pub_pst_exp_in = Paste.objects.filter(is_private=False, expires__range=[curr_aw_t, curr_aw_t + td]).order_by(
        '?')

    if rand_pub_pst_exp_in.count() == 0:
        rand_pub_pst_exp_in = Paste.objects.create(author=None,
                                                   title="Random burning paste",
                                                   language="text/x-php",
                                                   expires=transform_expired_choice(1),
                                                   text="A random paste that is going to burn in an hour",
                                                   category="Other",
                                                   short_url=generate_short_url(8),
                                                   is_private=False)
    else:
        rand_pub_pst_exp_in = rand_pub_pst_exp_in[0]
    return rand_pub_pst, rand_pub_pst_exp_in


def transform_expired_choice(period):
    curr_aw_t = datetime.combine(datetime.now(), datetime.now().time(), timezone.utc)
    curr_aw_t += timedelta(hours=period)
    return curr_aw_t