# Define global ARGs that can be used by any stage that needs it
ARG USER=flask
ARG HOME=/home/$USER

# Image we will use to install and compile application dependencies
FROM python:3.7-slim-buster as compile-image

# Install GCC so we can compile uWSGI
# Clear /var/lib/apt/lists/ to reduce Dockerfile size
RUN apt-get update \
    && apt-get install -y gcc \
    && rm -rf /var/lib/apt/lists/*

# Install application dependencies
# We don't want a cache-dir because it will only make the docker layer larger
# and we should let docker handle the caching
COPY requirements.txt .
RUN pip install \
    --user \
    --no-cache-dir \
    --disable-pip-version-check \
    --no-warn-script-location \
    -r requirements.txt


# Image we will use to run our application
FROM python:3.7-slim-buster as run-image
ARG USER
ARG HOME

# Output print statements directly to console instead of buffering them up and
# printing them out in batches
ENV PYTHONUNBUFFERED=1 \
# Add user Python path to $PATH.
    PATH=$HOME/.local/bin:$PATH

# Remove pip and setuptools... we shouldn't install anything in this image
# If we need it installed, we should just copy it from `compile-image`
RUN pip uninstall -y --disable-pip-version-check setuptools pip \
# Create a user so we aren't just running as root
    && useradd --create-home $USER

# Copy over application libraries installed in `compile-image`, ensuring that
# the application user can actually execute these files
COPY --from=compile-image /root/.local/ $HOME/.local/
RUN chown -R :$USER $HOME/.local/ && chmod -R g+rx $HOME/.local/

# Copy source code
COPY src dockertest.ini $HOME/

# Switch to our non-root user
USER $USER
WORKDIR $HOME

CMD ["uwsgi", "--ini", "dockertest.ini"]
