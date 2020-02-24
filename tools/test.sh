#!/bin/bash

# Run tests
docker build -t unit-tests --target unit-tests .
echo -e '\e[1mWaiting for unit tests to finish...\e[0m'
docker run --name unit-tests unit-tests
docker wait unit-tests

# Copy unit test results
echo -e '\e[1mCopying test results from container...\e[0m'
full_path=$(realpath $0)
tools_dir_path=$(dirname $full_path)
solution_dir_path=$(dirname $tools_dir_path)
[[ -d $solution_dir_path/TestResults ]] || mkdir $solution_dir_path/TestResults

# Fix path for Windows FS
if [[ "$OSTYPE" == "msys" ]]; then
  solution_dir_path=$(echo "$solution_dir_path" | sed 's/^\///' | sed 's/\//\\/g' | sed 's/^./\0:/')      
fi

docker cp unit-tests:/TestResults $solution_dir_path/

# Clean container
echo -e '\e[1mRemoving unit tests container...\e[0m'
docker rm unit-tests

