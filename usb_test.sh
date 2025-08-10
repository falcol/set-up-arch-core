#!/usr/bin/env bash

DEVICE="/dev/sda"  # Thiết bị USB cần test tốc độ
MOUNT_POINT="/media/$USER/USB"  # Mặc định, nếu không có sẽ tự tìm

# Tự động tìm mount point phân vùng đầu tiên đã mount trên DEVICE
if [ ! -d "$MOUNT_POINT" ] || [ -z "$(mount | grep $DEVICE)" ]; then
    MOUNT_POINT=$(lsblk -o NAME,MOUNTPOINT -nr | grep "^$(basename $DEVICE)[0-9]" | awk '$2!="" {print $2; exit}')
    if [ -z "$MOUNT_POINT" ]; then
        echo "❌ Không tìm thấy thư mục mount của $DEVICE, hãy mount USB trước!"
        exit 1
    fi
fi

TEST_FILE="$MOUNT_POINT/testfile"
BLOCK_SIZES=(1M 2M 4M 8M)
COUNT=256
RESULTS=()

echo "=== Kiểm tra tốc độ đọc từ $DEVICE ==="
for BS in "${BLOCK_SIZES[@]}"; do
    echo -n "Đọc với bs=$BS: "
    SPEED=$(sudo dd if=$DEVICE of=/dev/null bs=$BS count=$COUNT status=progress 2>&1 | grep -o "[0-9.]\+ [MG]B/s" | tail -1)
    echo -n "$SPEED" | tr -d '\n'
    echo
    RESULTS+=("READ,$BS,$SPEED")
done

echo ""
echo "=== Kiểm tra tốc độ ghi vào $TEST_FILE ==="
for BS in "${BLOCK_SIZES[@]}"; do
    echo -n "Ghi với bs=$BS: "
    SPEED=$(dd if=/dev/zero of=$TEST_FILE bs=$BS count=$COUNT conv=fdatasync status=progress 2>&1 | grep -o "[0-9.]\+ [MG]B/s" | tail -1)
    echo -n "$SPEED" | tr -d '\n'
    echo
    RESULTS+=("WRITE,$BS,$SPEED")
    rm -f "$TEST_FILE"
done

echo ""
echo "=== Kết quả tổng hợp ==="
printf "%-8s %-6s %-10s\n" "Loại" "BS" "Tốc_độ"
for R in "${RESULTS[@]}"; do
    IFS=',' read TYPE BS SPEED <<< "$R"
    printf "%-8s %-6s %-10s\n" "$TYPE" "$BS" "$SPEED"
done
