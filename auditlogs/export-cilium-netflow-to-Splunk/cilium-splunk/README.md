# cilium-splunk

Подключается по gRPC к hubble-relay и пересылает netflow события в Object Storage

## Сборка

```bash
make build
```

## Конфигурация

Через `config.yaml`:
```yaml
s3:
  bucket: "k8s-logs"
  prefix: "k8s/b1gnusj8glj1pkr3ru0e/b1gpl1hi60t84gv7gg8o/catfr1ki8briuhgra3qm"
  access-key-id: "..." # Can be set using S3_ACCESS_KEY_ID env
  secret-access-key: "..." # Can be set using S3_SECRET_ACCESS_KEY env

hubble-relay-url: "localhost:4245" # Defaults to "hubble-relay.kube-system.svc.cluster.local:80"
```

Через переменные окружения:
```
S3_REGION
S3_ENDPOINT
S3_BUCKET
S3_PREFIX
S3_ACCESS_KEY_ID
S3_SECRET_ACCESS_KEY
```

