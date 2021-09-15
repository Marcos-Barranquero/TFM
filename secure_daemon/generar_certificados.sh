set -eu

cd ~
echo "you are now in $PWD"

# Si no se tiene instalado Docker, se crea el repo
if [ ! -d ".docker/" ] 
then
    echo "Directory ./docker/ does not exist"
    echo "Creating the directory"
    mkdir .docker
fi

# Se obtiene contraseña
cd .docker/
echo "Introduce pass del certificado: "
read -p '>' -s PASSWORD

# Se obtiene servidor 
echo "Introduce nombre usado para el servidor: "
read -p '>' SERVER

# Se cifra la pass con AES de 256bit
openssl genrsa -aes256 -passout pass:$PASSWORD -out ca-key.pem 2048 

# Se firma la pass de la entidad de certificación propia para el nombre del servidor durante el periodo de un año. 
openssl req -new -x509 -days 365 -key ca-key.pem -passin pass:$PASSWORD -sha256 -out ca.pem -subj "/C=TR/ST=./L=./O=./CN=$SERVER"

# Se genera la pass del servidor 
openssl genrsa -out server-key.pem 2048

# Se genera la petición de firma del certificado para el servidor
openssl req -new -key server-key.pem -subj "/CN=$SERVER"  -out server.csr

# Se firma la pass del servidor durante el período de un año
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out server-cert.pem


# Para autenticar al cliente se crea una pass
openssl genrsa -out key.pem 2048

# Se procesa petición de firma del certificado del cliente 
openssl req -subj '/CN=client' -new -key key.pem -out client.csr


# Se crea un archivo de extensión de configuración para autenticar al cliente 
sh -c 'echo "extendedKeyUsage = clientAuth" > extfile.cnf'

# Se firma la clave pública
openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out cert.pem -extfile extfile.cnf

# Se borran archivos temporales
echo "Eliminando archivos temporales intermedios: client.csr extfile.cnf server.csr"
rm ca.srl client.csr extfile.cnf server.csr

echo "Cambiando permisos a solo lectura..."
chmod 0400 ca-key.pem key.pem server-key.pem
chmod 0444 ca.pem server-cert.pem cert.pem

