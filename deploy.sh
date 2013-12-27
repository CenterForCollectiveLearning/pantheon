echo Bundling meteor project
meteor bundle ../bundle.tgz
echo Untarring bundle
tar -zxvf ../bundle.tgz
# PORT=80 MONGO_URL=mongodb://localhost:27017/localhost ROOT_URL=http://localhost node ../bundle/main.js