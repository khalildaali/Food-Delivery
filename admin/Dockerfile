FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY --from=build /app/dist /app/dist
COPY --from=build /app/node_modules /app/node_modules
COPY package*.json ./

EXPOSE 5174

ENV VITE_API_URL=http://backend:5000
ENV HOST=0.0.0.0

CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "5174"]