FROM nginx:1.31.3-alpine

# Install Node.js and NPM on Alpine
RUN apk add --no-cache nodejs npm

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Copy package.json to install production dependencies
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

# Copy the pre-built files from the workspace
COPY .next ./.next
COPY public ./public
# Copy Next.config.ts configuration file
COPY next.config.ts ./

# Copy the Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 (Nginx port)
EXPOSE 80

# Start both the Next.js app (background) and Nginx (foreground)
CMD ["sh", "-c", "npx next start -p 3000 & nginx -g 'daemon off;'"]


