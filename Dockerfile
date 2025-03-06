FROM python:3.9-alpine3.13
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
    /py/bin/pip install -r /tmp/requirements.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org ; \
    fi && \
    rm -rf /tmp && \
    adduser -D -H django-user

    
ENV PATH="/py/bin:$PATH"

USER django-user

# Testing linting : << docker-compose run --rm app sh -c "/py/bin/flake8" >> OR << docker-compose run --rm app flake8 /app >> (name of the app, the service and the path to the app)
# Creating Django project : docker-compose run --rm app sh -c "/py/bin/django-admin startproject app ."
# Running tests : docker-compose run --rm app sh -c "/py/bin/python manage.py test"
