#!/bin/bash

test_success()
{
  echo -n "test_success: $@"
  eval "$@ >/dev/null" || {
    echo -e "  \e[31mfailure\e[0m"
    exit 1
  }
  echo -e "  \e[32mok\e[0m"
}

test_failure()
{
  echo -n "test_failure: $@"
  eval "$@ >/dev/null" && {
    echo -e "  \e[31mfailure\e[0m"
    exit 1
  }
  echo -e "  \e[32mok\e[0m"
}


cd premake5
test_success 'premake5 | grep Wall'
test_failure 'premake5 | grep Weverything'
test_success 'premake5 --cc=gcc | grep Wall'
test_success 'premake5 --cc=clang | grep Weverything'
test_failure 'premake5 | grep lto'
test_success 'premake5 --jln-lto=on | grep lto'
