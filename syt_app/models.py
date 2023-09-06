from django.db import models
from django.contrib.auth.models import User
from datetime import datetime


class Paste(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE, null=True)
    title = models.CharField(max_length=300)
    pub_date = models.DateTimeField(default=datetime.now)
    expires = models.DateTimeField(null=True, blank=True)
    text = models.TextField()

    LANGUAFE_CHOICES = [
        ("text/x-python", "Python"),
        ("text/x-csharp", "C#"),
        ("text/x-c++src", "C++"),
        ("text/x-go", "Go"),
        ("text/javascript", "JavaScript"),
        ("text/x-java", "Java"),
        ("text/x-php", "PHP"),
        ("text/x-csrc", "C")
    ]
    language = models.CharField(max_length=20, choices=LANGUAFE_CHOICES)
    CATEGORY_CHOICES = [
        ("Algorithms", "Algorithms"),
        ("Web-development", "Web-development"),
        ("Scripts", "Scripts"),
        ("Poetry", "Poetry"),
        ("Programming", "Programming"),
        ("Other", "Other")
    ]
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default="Other")
    is_private = models.BooleanField(default=False)
    short_url = models.CharField(max_length=8, default="", unique=True)

    objects = models.Manager()

    def __str__(self):
        return f"{self.title}:{self.author}:{self.is_private}"
