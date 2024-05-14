FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-devel
ARG DEBIAN_FRONTEND=noninteractive

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.21.1

COPY /xinference/deploy/docker/ubuntu.sources.list /etc/apt/sources.list
RUN apt-get -y update \
  && apt install -y curl procps git libgl1 vim net-tools iputils-ping libglib2.0-0\
  && mkdir -p $NVM_DIR \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && apt-get -yq clean

ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

COPY /xinference/deploy/docker/dev.requirements.txt /tmp/dev.requirements.txt
# ARG PIP_INDEX=https://pypi.org/simple
ENV PIP_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple
RUN python -m pip install --upgrade -i "$PIP_INDEX" pip && \
    pip install -i "$PIP_INDEX" -r /tmp/dev.requirements.txt && \
    CMAKE_ARGS="-DGGML_CUBLAS=ON" pip install -i "$PIP_INDEX" -U chatglm-cpp && \
    CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install -i "$PIP_INDEX" -U llama-cpp-python && \
    pip uninstall -y opencv-contrib-python && \
    pip install -i "$PIP_INDEX" opencv-contrib-python-headless
