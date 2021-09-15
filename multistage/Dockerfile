# Imagen base, con el tag de builder ya que es la que compila 
FROM golang:1.8 as contenedor_sdk
WORKDIR /go/src/app

# Se copia el código de la app al contenedor
COPY server.go . 

# Se compila 
RUN go build -o servidor . 

# Ahora, se define la imagen base del segundo contenedor
FROM alpine
WORKDIR /app
# Se copia el contenido del contenedor de compilación al contenedor de ejecución
COPY --from=contenedor_sdk /go/src/app/ /app


# Y se ejecuta
CMD ["./servidor"]
