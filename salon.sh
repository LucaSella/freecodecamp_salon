#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  echo "Please select the number of the service you would like:"

  SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter one of the options below"
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      MAIN_MENU "Please enter one of the options below"
    else
      SERVICE_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/^ *| *$//')
      
      echo -e "\nPlease enter your phone number."
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "We don't have you on our system, please provide your name so we can add you."
        read CUSTOMER_NAME

        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
      fi
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//')
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

      echo "Please select a time for your appointment."
      read SERVICE_TIME

      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")
      echo "I have put you down for a $SERVICE_SELECTED_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi
}

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~~\n"

MAIN_MENU
