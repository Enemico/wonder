FROM enemico/apache2-base

COPY conf /tmp/conf
COPY build.sh /tmp/build.sh
RUN /tmp/build.sh && rm /tmp/build.sh

ENTRYPOINT ["/usr/local/bin/chaperone"]
