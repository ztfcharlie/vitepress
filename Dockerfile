# 构建阶段
FROM node:18 as builder

WORKDIR /app

# 首先只复制 package.json 文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 然后复制源代码文件（会遵循 .dockerignore 的设置）
COPY . .

# 构建
RUN npm run build

# 生产阶段
FROM nginx:alpine

# 复制构建产物到 nginx 目录
COPY --from=builder /app/.vitepress/dist /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# 创建上传文件目录
RUN mkdir -p /data/uploads && \
    chown -R nginx:nginx /data/uploads

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
