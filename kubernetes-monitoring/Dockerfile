FROM nginx:stable

RUN apt update && apt install -y curl && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

