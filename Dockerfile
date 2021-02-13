FROM golang:1.15-alpine as compiler

ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct


# 新增upx 设置时区为上海
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add tzdata upx \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
ENV TZ=Asia/Shanghai

WORKDIR /app

# 先添加依赖
COPY go.mod .
COPY go.sum .
# 下载依赖
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o transfer .

RUN mkdir publish && cp transfer publish && \
    cp app.yml publish && cp -r web/statics publish

# 压缩一下 1到9 速度依次变慢
RUN upx -5 transfer


# 第二阶段
FROM busybox
COPY --from=compiler /etc/ssl/certs /etc/ssl/certs
COPY --from=compiler /usr/share/zoneinfo /usr/share/zoneinfo
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" >  /etc/timezone
WORKDIR /app
RUN chmod -R 777 /app
COPY --from=compiler /app/publish .
EXPOSE 8060

# 运行容器执行时的口令
ENTRYPOINT ["./transfer"]
