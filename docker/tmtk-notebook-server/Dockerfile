FROM python:3.7-slim

ARG TMTK_VERSION="0.5.6"
ARG TRANSMART_API_CLIENT_PY_VERSION="0.2.6"
ARG TRANSMART_VERSION="17.2.4"

ENV PYTHONUNBUFFERED 1
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV TRANSMART_COPY_JAR_URL "https://repo.thehyve.nl/service/local/repositories/releases/content/org/transmartproject/transmart-copy/${TRANSMART_VERSION}/transmart-copy-${TRANSMART_VERSION}.jar"
ENV TRANSMART_COPY_JAR_FILE "/transmart-copy.jar"

EXPOSE 8888

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Install OpenJDK 8
RUN mkdir -p /usr/share/man/man1 &&\
    apt-get update && apt-get install -y --no-install-recommends curl software-properties-common gnupg unzip &&\
	curl https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - &&\
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ &&\
    apt-get update && apt-get install -y --no-install-recommends adoptopenjdk-8-hotspot-jre &&\
	rm -rf /var/lib/apt/lists/* &&\
    export JAVA_HOME;

RUN	curl -L -o "${TRANSMART_COPY_JAR_FILE}" "${TRANSMART_COPY_JAR_URL}"

RUN pip install --no-cache-dir --upgrade jupyter &&\
    pip install --no-cache-dir --upgrade "pandas == 0.23.4" &&\
    pip install --no-cache-dir --upgrade "transmart[full] == ${TRANSMART_API_CLIENT_PY_VERSION}" &&\
    pip install --no-cache-dir --upgrade tqdm &&\
    pip install --no-cache-dir --upgrade "tmtk == ${TMTK_VERSION}" &&\
    pip install --no-cache-dir --upgrade bokeh &&\
    pip install --no-cache-dir --upgrade transmart-loader &&\
    jupyter-nbextension install --py tmtk.arborist &&\
    jupyter-serverextension enable tmtk.arborist &&\
    groupadd -r jupyter && useradd -r -g jupyter jupyter &&\
    sed -i 's/\r//' /docker-entrypoint.sh &&\
    chmod +x /docker-entrypoint.sh &&\
    mkdir -p /home/jupyter &&\
    chown -R jupyter:jupyter /home/jupyter &&\
    rm -rf /tmp/* /var/tmp/* && sync

USER jupyter

WORKDIR /home/jupyter

ENTRYPOINT ["/docker-entrypoint.sh"]
