FROM nginx:alpine
COPY final-banking-chatbot.html /usr/share/nginx/html/index.html
COPY final-banking-chatbot.html /usr/share/nginx/html/banking-chatbot.html
EXPOSE 80
