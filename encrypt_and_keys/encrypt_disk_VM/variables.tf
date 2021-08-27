variable "folder_id" {
    default = "b1g35l8msdsaf20p5iue"
}

variable "cloud_id" {
    default = "b1g3o4minpkuh10pd2rj"
}

variable "token" {
    default = "/Users/mirtov8/Documents/terraform-play/enc-test/key.json"
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

