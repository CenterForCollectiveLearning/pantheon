#!/bin/bash
# onlyBundle.sh: A script to only rebundle

echo "Removing old bundle"
rm -r ../pantheon_bundle_temp/bundle
rm ../pantheon_bundle_temp/bundle.tgz

echo "Bundling Pantheon application"
meteor --release 0.7.0.1 bundle pantheon_bundle_temp/bundle.tgz
cd pantheon_bundle_temp
tar -zxvf bundle.tgz