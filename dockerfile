FROM node:10
ENV SECRET_WORD=TwelveFactor
WORKDIR /app
COPY quest .
WORKDIR /app/quest
RUN npm install
CMD ["npm", "start"]