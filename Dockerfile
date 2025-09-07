# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# package.json만 먼저 복사 → 캐시 최적화
COPY package*.json ./
RUN npm ci

# 나머지 코드 복사
COPY . .

# 빌드
RUN npm run build

# Production stage
FROM nginx:1.29-alpine AS runtime
# Nginx 설정 복사
COPY nginx.conf /etc/nginx/conf.d/default.conf
# 빌드 산출물만 복사
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD wget -qO- http://localhost/healthz || exit 1
CMD ["nginx", "-g", "daemon off;"]
