topic=$1
if [ -z "$topic" ]; then
  echo "Usage: kafka-consume.sh <topic_name>"
  exit 1
fi

schema_registry_container=$(docker container ls -q --filter name='schema-registry-file-downloader')
if [ -z "$schema_registry_container" ]; then
  echo "Schema registry not running. Run 'docker-compose up -d' and try again"
  exit 1
fi

docker container exec "$schema_registry_container" kafka-avro-console-consumer \
  --bootstrap-server kafka:29092 \
  --topic "$topic" \
  --from-beginning
