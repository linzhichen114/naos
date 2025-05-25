# Create disk image
execute_process(
  COMMAND dd if=/dev/zero of=${IMAGE_NAME}.hdd bs=1M count=0 seek=128
  COMMAND sgdisk ${IMAGE_NAME}.hdd -n 1:2048 -t 1:ef00
  COMMAND mformat -i ${IMAGE_NAME}.hdd@@1M
  COMMAND mmd -i ${IMAGE_NAME}.hdd@@1M ::/EFI ::/EFI/BOOT ::/boot ::/boot/limine
  COMMAND mcopy -i ${IMAGE_NAME}.hdd@@1M ${KERNEL_BIN} ::/boot
  COMMAND mcopy -i ${IMAGE_NAME}.hdd@@1M ${CMAKE_SOURCE_DIR}/limine.conf ::/boot/limine
)

# Create ROOTFS
execute_process(
  COMMAND dd if=/dev/zero bs=1M count=2048 of=rootfs.hdd
  COMMAND mkfs.ext2 rootfs.hdd
  COMMAND sudo mount rootfs.hdd mnt
  COMMAND sudo cp -r ${CMAKE_BINARY_DIR}/rootfs-${ARCH}/* mnt/
  COMMAND sudo umount mnt
)
