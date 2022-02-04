# Base image for quest app
FROM node:10
# Inject the secret word
ENV SECRET_WORD=TwelveFactor
WORKDIR /app
# copy the quest app files dir to /app
COPY quest .
WORKDIR /app/quest
#install and start npm
RUN npm install
CMD ["npm", "start"]