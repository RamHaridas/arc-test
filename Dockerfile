FROM nginx:1.31.3-alpine

RUN apk add --no-cache nodejs

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Copy pre-built artifacts from pipeline workspace
COPY .next ./.next
COPY public ./public
COPY next.config.ts ./
COPY package.json ./
COPY node_modules ./node_modules

# Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Start Next.js on port 3000 (background) and Nginx on port 80 (foreground)
CMD ["sh", "-c", "node_modules/.bin/next start -p 3000 & nginx -g 'daemon off;'"]
