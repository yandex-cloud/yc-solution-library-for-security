#!/usr/bin/env bash

#
# Клиентское шифрование диска на ключе из YC KMS
#

set -e -x

DEVICE="/dev/vdb" #заменить имя диска на свое (по умолчанию 2-й диск vdb)
MAPPED_DEVICE="encrypted1"
KMS_KEY_ID="abjhdahmqnxxxxxxxxxx" #заменить на свой KMS key id
ENCRYPTED_DEK_FILE="./encrypted1_dek.enc" # persistent FS
PLAINTEXT_DEK_FILE="/tmp/encrypted1.dek" # in-memory FS
MOUNT="/mnt/${MAPPED_DEVICE}"
BUCKET_NAME="bucket-enc" #заменить на свой

YC=~/yandex-cloud/bin/yc
CMD="$1"

case "$CMD" in
    create)
      #Создание ключа с высокой энтропией метод generateDataKey (https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey)
      #Необходимо выполнить 1 раз и хранить ENCRYPTED_DEK_FILE в защищенном удаленном месте
      mkdir $MOUNT
      $YC kms symmetric-crypto generate-data-key --id ${KMS_KEY_ID} --data-key-spec=aes-256 --data-key-ciphertext-file=${ENCRYPTED_DEK_FILE} --data-key-plaintext-file=${PLAINTEXT_DEK_FILE}
      cryptsetup -v --type luks --cipher aes-xts-plain64 --key-size 512 --hash sha256 --iter-time 2000 --use-urandom -q luksFormat "${DEVICE}" "${PLAINTEXT_DEK_FILE}"
      cat "${PLAINTEXT_DEK_FILE}" | cryptsetup open "${DEVICE}" "${MAPPED_DEVICE}" -d -
      mkfs -t ext4 "/dev/mapper/${MAPPED_DEVICE}"
      aws --endpoint-url=https://storage.yandexcloud.net s3 cp ${ENCRYPTED_DEK_FILE} s3://${BUCKET_NAME}/encrypted1_dek.enc #копируем ключ в S3
      rm ${PLAINTEXT_DEK_FILE} # удаляем расшифрованный ключ
      rm ${ENCRYPTED_DEK_FILE} # удаляем зашифрованный ключ
      ;;
    #Монтирование зашифрованного диска в расшифрованный объект
    #Можно выполнять, например при старте ОС
    open)
      aws --endpoint-url=https://storage.yandexcloud.net s3 cp s3://${BUCKET_NAME}/encrypted1_dek.enc ${ENCRYPTED_DEK_FILE}
      #Вывод plaintext-file для расшифровки 
      $YC kms symmetric-crypto decrypt --id ${KMS_KEY_ID} --ciphertext-file=${ENCRYPTED_DEK_FILE} --plaintext-file=${PLAINTEXT_DEK_FILE}
      cat "${PLAINTEXT_DEK_FILE}" | cryptsetup open "${DEVICE}" "${MAPPED_DEVICE}" -d -
      rm ${PLAINTEXT_DEK_FILE} # удаляем расшифрованный ключ
      rm ${ENCRYPTED_DEK_FILE} # удаляем зашифрованный ключ
      mount -t ext4 "/dev/mapper/${MAPPED_DEVICE}" $MOUNT
      mount /dev/mapper/$MAPPED_DEVICE $MOUNT
      ;;
    #Размонтирование зашифрованного устройства
    close)
      umount ${MOUNT}
      cryptsetup close ${MAPPED_DEVICE}
      rm "${PLAINTEXT_DEK_FILE}"
      ;;
    #Удаление исходного устройства
    erase)
      cryptsetup luksErase ${DEVICE}
      ;;
    *)
      echo "Usage: ${NAME} {create|open|close|erase}" >&2
      exit 3
      ;;
esac