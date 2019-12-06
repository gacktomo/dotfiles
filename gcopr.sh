#!/bin/bash

# 標準入力を受け取る
ID=${1}

git fetch upstream pull/$ID/head:pr/$ID
git checkout pr/$ID
