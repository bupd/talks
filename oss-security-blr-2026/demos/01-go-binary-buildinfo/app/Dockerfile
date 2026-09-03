FROM golang:1.27-alpine AS build
WORKDIR /src
COPY go.mod go.sum main.go ./
RUN CGO_ENABLED=0 go build -o /app .

FROM alpine:3.20
COPY --from=build /app /usr/local/bin/app
CMD ["app"]
