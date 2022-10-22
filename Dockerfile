From enwaiax/x-ui:latest

WORKDIR /root

RUN apt update &&\
    apt install -y --no-install-recommends \
    nginx \
    openssl 
    
COPY nginx.conf /etc/nginx/
COPY entrypoint.sh .
ENTRYPOINT ["/bin/bash",  "./entrypoint.sh"]



CMD [ "./x-ui" ]
