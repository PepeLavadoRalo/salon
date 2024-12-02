#!/bin/bash

# Mostrar bienvenida y servicios
echo "~~~~~ MY SALON ~~~~~"
echo "Welcome to My Salon, how can I help you?"

# Función para mostrar los servicios disponibles
function display_services() {
  echo "Here are the services we offer:"
  # Usamos psql con el delimitador adecuado para evitar el formato no deseado
  psql --username=freecodecamp --dbname=salon -t -A -F" " -c "SELECT service_id, name FROM services" | while read SERVICE_ID SERVICE_NAME
  do
    # Mostrar el servicio en el formato correcto
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Mostrar los servicios disponibles inicialmente
display_services

# Solicitar al usuario que elija un servicio
while true; do
  echo "Please pick a service by entering the corresponding number:"
  read SERVICE_ID_SELECTED
  
  # Comprobar si el servicio seleccionado es válido
  VALID_SERVICE=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ $VALID_SERVICE -eq 0 ]]; then
    # Si el servicio no existe, mostrar un mensaje y volver a mostrar la lista
    echo "I could not find that service. What would you like today?"
    display_services
  else
    # Si el servicio es válido, salir del bucle
    break
  fi
done

# Solicitar el número de teléfono del cliente
echo "What's your phone number?"
read CUSTOMER_PHONE

# Comprobar si el número de teléfono ya está registrado
CUSTOMER_EXISTS=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ $CUSTOMER_EXISTS -eq 0 ]]; then
  # Si el número no existe, pedir el nombre y agregarlo a la base de datos
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # Insertar el nuevo cliente en la tabla de customers
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  echo "Hello, $CUSTOMER_NAME."
else
  # Si el cliente ya existe, obtener su nombre
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Pedir la hora de la cita
echo "What time would you like your service, $CUSTOMER_NAME?"
read SERVICE_TIME

# Crear una nueva cita en la tabla de appointments
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirmación de la cita
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
