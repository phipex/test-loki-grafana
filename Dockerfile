FROM grafana/fluent-bit-plugin-loki:main-285143d

COPY ./configs/fluentbit/fluent-bit.extra.conf /fluent-bit/etc/fluent-bit.conf

COPY ./configs/fluentbit/parsers/ /fluent-bit/etc/parsers/

EXPOSE 24224