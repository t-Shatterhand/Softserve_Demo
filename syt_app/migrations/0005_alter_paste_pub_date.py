# Generated by Django 4.1.8 on 2023-05-02 20:51

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('syt_app', '0004_alter_paste_pub_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='paste',
            name='pub_date',
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
    ]
