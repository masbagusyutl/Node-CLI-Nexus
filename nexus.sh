#!/bin/bash

# Fungsi untuk menampilkan pesan selamat datang
print_welcome_message() {
    echo -e "\033[1;37m"
    echo " _  _ _   _ ____ ____ _    ____ _ ____ ___  ____ ____ ___ "
    echo "|\\ |  \\_/  |__| |__/ |    |__| | |__/ |  \\ |__/ |  | |__]"
    echo "| \\|   |   |  | |  \\ |    |  | | |  \\ |__/ |  \\ |__| |    "
    echo -e "\033[1;32m"
    echo "Nyari Airdrop Auto install Node CLI Nexus"
    echo -e "\033[1;33m"
    echo "Telegram: https://t.me/nyariairdrop"
    echo -e "\033[0m"
}

# Menampilkan pesan selamat datang
print_welcome_message

# Cek spesifikasi VPS (RAM dan Storage)
echo -e "\033[1;34mCek spesifikasi VPS:\033[0m"
RAM=$(free -m | awk '/Mem:/ {print $2}')
STORAGE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
VPS_USER=$(whoami)

echo "RAM: ${RAM}MB"
echo "Storage: ${STORAGE}GB"
echo "VPS User: ${VPS_USER}"

# Rekomendasi spesifikasi VPS
echo -e "\033[1;33mRekomendasi VPS:\033[0m"
echo "RAM: 4GB atau lebih"
echo "Storage: 16GB atau lebih"

if [[ "$RAM" -lt 4000 || "$STORAGE" -lt 16 ]]; then
    echo -e "\033[1;31mSpesifikasi VPS di bawah rekomendasi!\033[0m"
    read -p "Lanjutkan instalasi? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Instalasi dibatalkan."
        exit 1
    fi
fi

echo -e "\033[1;34m1. Install Rust...\033[0m"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

echo -e "\033[1;34m2. Install Nexus CLI...\033[0m"
curl https://cli.nexus.xyz/ | sh

echo -e "\033[1;34m3. Menentukan path Nexus secara otomatis...\033[0m"
NEXUS_PATH="/home/$VPS_USER/.nexus/network-api/clients/cli"
echo "Path yang digunakan: $NEXUS_PATH"

cd $NEXUS_PATH || { echo "Path tidak ditemukan!"; exit 1; }

echo -e "\033[1;34m4. Jalankan cargo build...\033[0m"
cargo build --release

echo -e "\033[1;34m5. Jika ada error 'optional' dan 'some', lakukan perbaikan...\033[0m"
OPTIONAL_FILE="$NEXUS_PATH/proto/orchestrator.proto"
SOME_FILE="$NEXUS_PATH/src/orchestrator_client.rs"

# Hapus 'optional' jika ada
if grep -q "optional" "$OPTIONAL_FILE"; then
    sed -i '/optional/d' "$OPTIONAL_FILE"
    echo "Kode 'optional' dihapus dari $OPTIONAL_FILE"
else
    echo "Tidak ditemukan 'optional' di $OPTIONAL_FILE"
fi

# Perbaiki 'Some' pada orchestrator_client.rs
if grep -q "node_telemetry" "$SOME_FILE"; then
    sed -i '/node_telemetry:/,/}),/c\    node_telemetry: Some(crate::nexus_orchestrator::NodeTelemetry {
        flops_per_sec: 1,
        memory_used: 1,
        memory_capacity: 1,
        location: "US".to_string(),
    }),' "$SOME_FILE"
    echo "Kode 'Some' diperbaiki di $SOME_FILE"
else
    echo "Tidak ditemukan 'Some' di $SOME_FILE"
fi

echo -e "\033[1;34m6. Menjalankan Node...\033[0m"
cargo run -r -- --start --beta

echo -e "\033[1;34m7. Masukkan Node ID Anda\033[0m"
read -p "Masukkan Node ID: " NODE_ID
echo "Node ID: $NODE_ID"

# Kesimpulan
echo -e "\033[0;32m========================================"
echo "     Nyari Airdrop Auto install Node CLI Nexus"
echo "          => Kesimpulan Proses <= "
echo -e "========================================\033[0m"
echo "VPS Name: $VPS_USER"
echo "Node ID: $NODE_ID"

echo -e "\033[1;32m8. Selesai! Node Nexus telah berjalan.\033[0m"

echo -e "\033[1;33mCopy Nexus Address\033[0m"
echo "Ambil di sini: https://app.nexus.xyz"
echo -e "\033[1;33mJangan lupa paste ke komen:\033[0m"
echo "https://x.com/NexusLabs/status/1892068785231888741"
echo -e "\033[1;31mJangan lupa save phrase-nya!\033[0m"
