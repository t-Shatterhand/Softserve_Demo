FROM python:3.11.5-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
RUN pip install --upgrade pip
COPY requirements.txt /code/

RUN pip install -r requirements.txt
COPY . /code/

EXPOSE 8080
CMD python manage.py migrate && python manage.py runserver 0.0.0.0:8080