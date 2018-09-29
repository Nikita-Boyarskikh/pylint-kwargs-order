#!/bin/bash

PROJECT_DIR=pylint_args

function has_bit {
    local mask=$((1 << ($2 - 1)))
    echo $(($1 & $mask != 0))
}

function pylint_success {
    local no_error=$(($1 == 0))
    local fatal=$(has_bit $1 1)
    local error=$(has_bit $1 2)
    local warning=$(has_bit $1 3)
    local refactor=$(has_bit $1 4)
    local convention=$(has_bit $1 5)
    local usage=$(has_bit $1 6)

    echo $((!$fatal && !$error && !$usage))
}

function lint {
    yapf -pir $PROJECT_DIR &&\
    flake8 2>/dev/null

    local error=$?
    if [ $error != 0 ]; then
        return $error
    fi

    pylint $PROJECT_DIR

    local pylint_result=$?
    if (( $(pylint_success $pylint_result) == 0 )); then
        return $pylint_result
    fi

    bandit -r $PROJECT_DIR 2>/dev/null
}

lint
