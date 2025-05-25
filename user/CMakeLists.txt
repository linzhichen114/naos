# Create ROOTFS directory
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/rootfs-${ARCH}/usr/bin)

# Execute port.sh
add_custom_command(
  OUTPUT ${CMAKE_BINARY_DIR}/ports.done
  COMMAND sh ${CMAKE_SOURCE_DIR}/user/ports/ports.sh
  COMMAND touch ports.done
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Buid userspace programs
add_custom_target(user ALL
  DEPENDS ${CMAKE_BINARY_DIR}/ports.done
  COMMENT "Building user programs"
)

# Cleaning
add_custom_target(user_clean
  COMMAND rm -rf ${CMAKE_BINARY_DIR}/rootfs-${ARCH}
)
