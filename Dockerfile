FROM python:3.6

WORKDIR /code

COPY rtlbs-server/requirements.txt /requirements.txt

RUN pip install --no-cache-dir -r /requirements.txt

COPY rtlbs-server server

WORKDIR server
RUN python --version
RUN python manage.py migrate
RUN echo "hello???"
RUN python manage.py showmigrations
#RUN python manage.py runserver