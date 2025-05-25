cmake_minimum_required(VERSION 3.15)
project(naos LANGUAGES C ASM)

# Multi-architecture configure
set(SUPPORTED_ARCHS x86_64 aarch64 riscv64 loongarch64)
set(ARCH "x86_64" CACHE STRING "Target architecture (${SUPPORTED_ARCHS})")

list(FIND SUPPORTED_ARCHS ${ARCH} ARCH_INDEX)
if(ARCH_INDEX EQUAL -1)
  message(FATAL_ERROR "Unsupported architecture: ${ARCH}")
endif()

# Load toolchain files
include(cmake/toolchains/${ARCH}.cmake)

# Check depends
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/freestnd-c-hdrs" OR 
   NOT EXISTS "${CMAKE_SOURCE_DIR}/src/cc-runtime" OR
   NOT EXISTS "${CMAKE_SOURCE_DIR}/src/limine.h")
  message(STATUS "Running get-deps script...")
  execute_process(COMMAND ${CMAKE_SOURCE_DIR}/kernel/get-deps)
endif()

# Add subproject
add_subdirectory(kernel)
add_subdirectory(user)

# Image generatetion configure
set(IMAGE_NAME "naos-${ARCH}")
set(QEMUFLAGS "-m 4G -smp 2 -d cpu_reset")
configure_file(cmake/qemu_flags.cmake.in qemu_flags.cmake @ONLY)

# Build image
add_custom_target(naos-image ALL
  DEPENDS kernel user limine
  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/create_image.cmake
  COMMENT "Building ${IMAGE_NAME}.hdd"
)

# Run image via QEMU
add_custom_target(run
  DEPENDS naos-image
  COMMAND ${CMAKE_COMMAND} -DARCH=${ARCH} -P ${CMAKE_BINARY_DIR}/qemu_flags.cmake
  COMMENT "Starting QEMU for ${ARCH}"
)

# Clean
add_custom_target(distclean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_SOURCE_DIR}/ovmf
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_SOURCE_DIR}/rootfs.hdd
  COMMAND ${CMAKE_MAKE_PROGRAM} -C kernel distclean
  COMMAND ${CMAKE_MAKE_PROGRAM} -C user distclean
)
