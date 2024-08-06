#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
OUTPUT=''

SET_OUTPUT() {
  IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< $1
  OUTPUT="The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties FULL JOIN elements USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number = $1;")
  else
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties FULL JOIN elements USING(atomic_number) LEFT JOIN types USING(type_id) WHERE symbol = '$1';")
  fi 
  
  if [[ -z $ELEMENT ]]
  then
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties FULL JOIN elements USING(atomic_number) LEFT JOIN types USING(type_id) WHERE name = '$1';") 
  fi

  if [[ $ELEMENT ]]
  then 
    SET_OUTPUT $ELEMENT
  else
    OUTPUT="I could not find that element in the database."
  fi
else 
  OUTPUT='Please provide an element as an argument.'
fi

echo $OUTPUT