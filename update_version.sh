#!/bin/bash -e

#This script is used during the release process. It is not intended to be ran manually.

VERSION="$1"
VERSION="${VERSION:?"must provide version as first parameter"}"
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

updateVersion(){
    updateMixfile
    commitStagedFiles "Update version to ${VERSION}"
}

updateMixfile(){
    echo -e "\nUpdating package version"
    local mixfilePath="${SCRIPT_DIR}/mix.exs"
    sed -ri 's/^\s*@version\s+.*$/  @version "'"${VERSION}"'"/' "${mixfilePath}"
    stageFiles "${mixfilePath}"
}

stageAndCommit(){
    local msg="$1"
    shift
    local files=( "$@" )
    stageFiles "${files[@]}"
    commitStagedFiles "${msg}"
}

stageFiles(){
    local files=( "$@" )
    git add "${files[@]}"
}

commitStagedFiles(){
    local msg="$1"
    if thereAreStagedFiles; then
        git commit -m "${msg}"
    else
        echo "No changes to commit"
    fi
}

thereAreStagedFiles(){
    git update-index -q --ignore-submodules --refresh
    if git diff-index --cached --quiet HEAD --ignore-submodules -- ; then
        return 1;
    else
        return 0;
    fi
}

updateVersion
