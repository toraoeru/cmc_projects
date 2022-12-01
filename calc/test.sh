#!/bin/bash
#
#running tests for calc
cd tests
path="$PWD"
files=()
for entry in "$path"/* 
do
  files=( "${files[@]}" "$entry" )
done
for file in ${files[@]}; do
  cd ..
  fname=$(basename ${file})
  ./calc 0.1 2 10 < $file > "outputs/$fname"
  res="$(diff -q "outputs/$fname" "exp_res/$fname")"
  if [ "$res" != '' ]; then
     echo "ОШИБКА ПРИ ТЕСТЕ ${fname::-4}"
  fi
  cd tests
done
#clear
#exit 0
