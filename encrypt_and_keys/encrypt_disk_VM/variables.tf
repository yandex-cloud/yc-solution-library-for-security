variable "folder_id" {
    default = "xxxxxx" //# Указать ID своей папки
}

variable "cloud_id" {
    default = "xxxxxx" //# Указать ID своего облака
}

variable "token" {
    default = "key.json" //# Указать свой JSON для сервисной учетной записи. https://cloud.yandex.ru/docs/cli/quickstart#initialize
}

variable "device" {
    default = "/dev/vdb" //#заменить имя диска на свое (по умолчанию 2-й диск vdb)
}

variable "mapped_device" {
    default = "encrypted1" //заменить имя на желаемое
}

variable "encrypted_dek_file" {
    default = "./encrypted1_dek.enc" //заменить имя на желаемое
}

variable "plaintext_dek_file" {
    default = "/tmp/encrypted1.dek" //заменить имя на желаемое
}

variable "mount" {
    default = "/mnt/encrypted1" //заменить имя на желаемое
}

