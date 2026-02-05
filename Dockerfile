FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -o reflection ./reflection

FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /app
COPY --from=builder /app/reflection .

EXPOSE 9091

ENTRYPOINT ["./reflection"]
CMD ["-r", "http://localhost:8080/", "-p", "9091"]
