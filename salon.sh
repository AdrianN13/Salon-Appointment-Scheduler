#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -A -t -c "
echo "~~~~ MY SALON ~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

#get services for main menu
SHOW_SERVICES=$(while IFS='|' read SERVICE_ID SERVICE_NAME; do
echo "\n$SERVICE_ID) $SERVICE_NAME"
done < <($PSQL "SELECT service_id, name FROM services"))

#main menu screen
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e $SHOW_SERVICES
  read SERVICE_ID_SELECTED
  if [ -z $($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'") ]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}
#get customer phone
GET_CUSTOMER_INFO(){
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  if [ -z $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") ]
    then
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      ($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
}

#book time
BOOK_TIME(){
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  echo "What time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  ($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  echo "I have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

#APP
MAIN_MENU
GET_CUSTOMER_INFO
BOOK_TIME
