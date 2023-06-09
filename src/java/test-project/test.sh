#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Prep
echo -e "\nGetting Maven wrapper..."
curl -sSL https://github.com/takari/maven-wrapper/archive/maven-wrapper-0.5.5.tar.gz| tar -xzf - 
mv maven-wrapper-maven-wrapper-0.5.5/mvnw mvnw
mv maven-wrapper-maven-wrapper-0.5.5/.mvn .mvn
rm -rf mv maven-wrapper-maven-wrapper-0.5.5

# Image specific tests
check "java" java -version
check "build-and-test-jar" ./mvnw -q package
check "test-project" java -jar target/my-app-1.0-SNAPSHOT.jar
check "nvm" bash -c ". /usr/local/share/nvm/nvm.sh && nvm install 10"
check "nvm-node" bash -c ". /usr/local/share/nvm/nvm.sh && node --version"
check "yarn" bash -c ". /usr/local/share/nvm/nvm.sh && yarn --version"

check "git" git --version

git_version_satisfied=false
if (echo a version 2.38.1; git --version) | sort -Vk3 | tail -1 | grep -q git; then
    git_version_satisfied=true
fi

check "git version satisfies requirement" echo $git_version_satisfied | grep "true"

# Clean up
rm -f mvnw
rm -rf .mvn

# Report result
reportResults
