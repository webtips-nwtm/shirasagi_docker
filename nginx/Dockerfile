FROM --platform=linux/x86_64 nginx:latest

RUN rm -f /etc/nginx/conf.d/*

COPY conf.d /etc/nginx/conf.d

CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
