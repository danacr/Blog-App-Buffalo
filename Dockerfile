FROM gobuffalo/buffalo:development as builder

RUN go version
RUN which go
RUN echo $PATH
ENV GOPROXY="https://proxy.golang.org"
ENV GO111MODULE="on"

# this will cache the npm install step, unless package.json changes
ADD package.json .
ADD yarn.lock .
RUN yarn install --no-progress
ADD . .
RUN buffalo build --static -o /bin/app -v --skip-template-validation

FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /bin/app .
ENV ADDR=0.0.0.0
EXPOSE 3000
ENTRYPOINT ["/app"]