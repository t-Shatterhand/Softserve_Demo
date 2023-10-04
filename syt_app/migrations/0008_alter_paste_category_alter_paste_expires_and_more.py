# Generated by Django 4.2.1 on 2023-09-29 20:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('syt_app', '0007_alter_paste_pub_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='paste',
            name='category',
            field=models.CharField(choices=[('Algorithms', 'Algorithms'), ('Web-development', 'Web-development'), ('Scripts', 'Scripts'), ('Poetry', 'Poetry'), ('Programming', 'Programming'), ('Other', 'Other')], default='Other', max_length=20),
        ),
        migrations.AlterField(
            model_name='paste',
            name='expires',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='paste',
            name='language',
            field=models.CharField(choices=[('text/x-python', 'Python'), ('text/x-csharp', 'C#'), ('text/x-c++src', 'C++'), ('text/x-go', 'Go'), ('text/javascript', 'JavaScript'), ('text/x-java', 'Java'), ('text/x-php', 'PHP'), ('text/x-csrc', 'C')], max_length=20),
        ),
    ]
