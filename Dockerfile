FROM python:alpine
LABEL maintainer="alexrothos"

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org && \
    sed -i 's/https:/http:/g' /etc/apk/repositories && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps postgresql-dev build-base musl-dev && \
    sed -i 's/http:/https:/g' /etc/apk/repositories && \
    /py/bin/pip install -r /tmp/requirements.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser -D -H django-user

    
ENV PATH="/py/bin:$PATH"

USER django-user

# Testing linting : << docker-compose run --rm app sh -c "/py/bin/flake8" >> OR << docker-compose run --rm app flake8 /app >> (name of the app, the service and the path to the app)
# Creating Django project : docker-compose run --rm app sh -c "/py/bin/django-admin startproject app ."
# Running tests : docker-compose run --rm app sh -c "/py/bin/python manage.py test"
