
Получить токен:
TOKEN=$(curl -H Metadata-Flavor:Google 169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token | jq -r '.access_token')

Зашифровать данные
curl -vX POST https://kms.yandex/kms/v1/keys/abjulftcuh1p66lfdmpg:encrypt -d '{"versionId": "abj24us9a9gl3d28f8kt","plaintext": "password"}' --header "Accept: application/json" --header "Authorization: Bearer ${TOKEN}"


Расшифровать данные
curl -X POST https://kms.yandex/kms/v1/keys/abjulftcuh1p66lfdmpg:decrypt -d '{"ciphertext": "AAAAAQAAABRhYmoyNHVzOWE5Z2wzZDI4ZjhrdAAAABCs8pwmY0EXt4Z93jl2bXyKAAAADNsHbqFdoUZZG6hx38ES7Jal90aYsxU1VZUPP3309i1/Bf4="}' --header "Accept: application/json" --header "Authorization: Bearer ${TOKEN}" | jq '.plaintext' | sed 's/"//g'