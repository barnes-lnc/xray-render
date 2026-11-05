FROM ghcr.io/xtls/xray-core:latest AS xray

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV PORT=10000
EXPOSE 10000
CMD ["/entrypoint.sh"]
