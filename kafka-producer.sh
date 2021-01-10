topic=$1
avro_file=$2
if [ -z "$topic" ]; then
  echo "Usage: kafka-produce.sh <topic_name> <optional_avro_file>"
  exit 1
fi

schema_registry_container=$(docker container ls -q --filter name='schema-registry-file-downloader')
if [ -z "$schema_registry_container" ]; then
  echo "Schema registry not running. Run 'docker-compose up -d' and try again"
  exit 1
fi

if [ "$(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed")" -eq 0 ]; then
  apt-get install jq -y
fi

value_schema=$(curl http://localhost:8081/subjects/"$topic"-value/versions/latest | jq -r .schema)
if [ "$value_schema" = "null" ]; then
  if [ -z "$avro_file" ]; then
    read -r -p "Couldn't find the schema on the registry. Please type <input|output>/<avro_file> " avro_file
  fi
  value_schema=$(jq -r . < src/main/avro/"$avro_file")
fi

docker container exec -it "$schema_registry_container" kafka-avro-console-producer \
  --broker-list kafka:29092 \
  --topic "$topic" \
  --property value.schema="$value_schema"
