# Docker pulls the specified image and sets it as the working image
ARG BASE_IMAGE="ubuntu:20.04"
FROM ${BASE_IMAGE}

# Allow log messages to be dumped in the stream (not buffer)
ENV PYTHONUNBUFFERED TRUE

# Install the Ubuntu dependencies and Python 3
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    python3-dev \
    # python3-distutils \
    python3-venv \
    curl \
    wget \
    unzip \
    gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp \
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && rm get-pip.py

# Create a new Python env and include it in the PATH
RUN python3 -m venv /home/venv
ENV PATH="/home/venv/bin:$PATH"

# Update the default system Python version to Python3/PIP3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3 1

# Create a new Ubuntu user
RUN useradd -m model-server

# Upgrade PIP and installs setuptools
RUN pip install pip --upgrade
RUN pip install -U pip setuptools

# Move the requirements.txt file to the container
RUN mkdir /tfserving_streamlit
COPY . /tfserving_streamlit
WORKDIR /tfserving_streamlit

# Install the requirements
RUN pip install -r requirements.txt
RUN echo "deb [arch=amd64] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | tee /etc/apt/sources.list.d/tensorflow-serving.list && \
    curl https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | apt-key add -
RUN apt-get update && apt-get install tensorflow-model-server -y

# Download the trained model(in SavedModel format)
RUN cd /home \
    && wget -nv "https://www.dropbox.com/s/twjjatywbr0wyat/monet_gen.zip" \
    && unzip monet_gen.zip \
    && rm monet_gen.zip \
    && mkdir /home/saved_models \
    && mv monet_gen /home/saved_models/

# Install tini
ENV TINI_VERSION v0.19.0
# Set proper ownership on /tini 
ADD --chown=model-server https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini
# Set permission for the entrypoint.sh
RUN chmod +x /tfserving_streamlit/entrypoint.sh

# Set the proper rights to the /home/saved_models dir and the created Python env
RUN chown -R model-server /home/saved_models \
    && chown -R model-server /home/venv

# Create a directory for the logs and set permissions to it
RUN mkdir /home/logs \
    && chown -R model-server /home/logs

# Define the model_path environment variable and the model name
ENV MODEL_PATH=/home/saved_models/monet_gen
ENV MODEL_NAME=monet_gen

ENV REST_PORT=8501
EXPOSE $REST_PORT
 
USER model-server
ENTRYPOINT ["/tini", "--", "/tfserving_streamlit/entrypoint.sh"]