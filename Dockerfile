FROM python:3.9-alpine3.13
LABEL maintainer="mbolafydev.com"

ENV PYTHONUNBUFFERED=1
ARG DEV=false

# Dépendances système minimales
RUN apk add --no-cache bash

# --- Créer l'utilisateur d'abord (sans home) ---
# (-H => pas de /home/django-user, donc on n'essaiera pas de chown ce répertoire)
RUN adduser -D -H -s /sbin/nologin django-user

# --- Préparer l'environnement Python ---
RUN python -m venv /py \
 && /py/bin/pip install --upgrade pip

# Copier les requirements et installer
COPY --chown=django-user:django-user ./requirements.txt /tmp/requirements.txt
COPY --chown=django-user:django-user ./requirements.dev.txt /tmp/requirements.dev.txt
RUN /py/bin/pip install -r /tmp/requirements.txt \
 && if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi \
 && rm -rf /root/.cache/pip /tmp/*

# Copier l'app avec le bon propriétaire tout de suite
COPY --chown=django-user:django-user ./app /app

WORKDIR /app
EXPOSE 8000

# Venv dans le PATH
ENV PATH="/py/bin:$PATH"

# Exécuter en user non-root
USER django-user
