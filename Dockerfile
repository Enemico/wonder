FROM enemico/apache2-base

COPY conf /tmp/conf
COPY ssl-setup.sh /usr/local/bin/ssl-setup.sh
COPY run.sh /usr/local/bin/run.sh
COPY build.sh /tmp/build.sh
RUN /tmp/build.sh && rm /tmp/build.sh

ENTRYPOINT ["/usr/local/bin/chaperone"]
