
FROM python:3.9-slim-buster AS base
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1


ARG port 
ARG subject
ARG sender_mails
ARG service_account_file

WORKDIR /usr/local 
COPY gmail_smtp_proxy ./gmail_smtp_proxy 
COPY pyproject.toml .
COPY poetry.lock .

COPY $service_account_file ./service_file.json

ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VERSION=1.1.10
RUN pip install "poetry==$POETRY_VERSION"
COPY pyproject.toml poetry.lock ./
RUN poetry export --without-hashes -n --no-ansi -f requirements.txt -o requirements.txt
RUN pip install --force-reinstall -r requirements.txt
RUN ls


ENV SUBJECT=$subject
ENV PORT=$port
ENV SERVICE_ACCOUNT_FILE=$service_account_file
ENV SENDER_EMAILS=$sender_mails
EXPOSE $PORT
CMD python3 -m gmail_smtp_proxy.main --host 0.0.0.0 --port $PORT --service-account-file ./service_file.json --subject $SUBJECT --sender-emails $SENDER_EMAILS
