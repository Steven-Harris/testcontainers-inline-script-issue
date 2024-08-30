# syntax=docker/dockerfile:1
FROM google/cloud-sdk:slim
ENV SPANNER_EMULATOR_HOST=127.0.0.1:9010

RUN apt-get install -y google-cloud-sdk-spanner-emulator

COPY <<-"EOF" start.sh
    #!/bin/bash
    set -m
    gcloud beta emulators spanner start --host-port=0.0.0.0:9010 &
    gcloud config configurations create emulator
    gcloud config set auth/disable_credentials true
    gcloud config set project emulator
    gcloud config set api_endpoint_overrides/spanner http://localhost:9020/
    gcloud spanner instances create example-instance --config=emulator-config --description=Emulator --nodes=1
    gcloud spanner databases create example-db --instance=example-instance
    gcloud config configurations activate emulator
    fg %1
EOF

# convert windows to linux line endings. only required on windows if the file is CRLF
RUN sed -i 's/\r$//' start.sh

EXPOSE 9010
EXPOSE 9020

HEALTHCHECK --interval=30s --start-period=10s --start-interval=5s --retries=3 \
    CMD curl --http2 --fail http://127.0.0.1:9020/v1/projects/emulator/instances/example-instance/databases/example-db || exit 1

CMD ["/bin/bash", "start.sh"]
