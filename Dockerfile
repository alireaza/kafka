FROM openjdk:17.0.2-jdk-slim-buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
wget ca-certificates gnupg2 build-essential \
tzdata \
kafkacat \
&& apt-get update \
&& apt-get upgrade -y \
&& apt-get remove -fy \
&& apt-get autoclean -y \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN mkdir /kafka \
&& wget -O - https://downloads.apache.org/kafka/3.3.1/kafka_2.13-3.3.1.tgz | tar xzf - -C "/kafka" --strip-components=1

ARG UNAME=udocker
ARG UID=1000
ARG GNAME=$UNAME
ARG GID=1000
ARG GROUPS=$GNAME

RUN groupadd -g $GID $GNAME \
&& useradd --create-home -d /home/$UNAME -g $GID -u $UID $UNAME \
&& usermod -a -G $GROUPS $UNAME

RUN chown --recursive $UNAME:$GNAME /kafka

USER $UNAME
WORKDIR /home/$UNAME

RUN set -x \
&& cp /kafka/config/kraft/server.properties /home/$UNAME/server.properties \
&& sed -i "s/^log\.dirs=.*/log\.dirs=\/home\/$UNAME\/kraft-combined-logs/g" /home/$UNAME/server.properties \
&& sed -i "/^advertised\.listeners=.*/s/^/#/g" /home/$UNAME/server.properties

ENV UNAME=$UNAME

HEALTHCHECK --start-period=10s --timeout=10s --interval=10s --retries=10 CMD kafkacat -b localhost:9092 -L || exit -1

EXPOSE 9092

ENTRYPOINT ["/bin/sh", "-c", "\
UUID=$(/kafka/bin/kafka-storage.sh random-uuid) \
&& /kafka/bin/kafka-storage.sh format --ignore-formatted --cluster-id ${UUID} --config /home/${UNAME}/server.properties \
&& /kafka/bin/kafka-server-start.sh /home/${UNAME}/server.properties \
"]

