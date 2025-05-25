# 收集源文件
file(GLOB_RECURSE KERNEL_SOURCES 
  ${CMAKE_SOURCE_DIR}/src/arch/${ARCH_DIR}/*.[cS]
  ${CMAKE_SOURCE_DIR}/src/drivers/*.c
  ${CMAKE_SOURCE_DIR}/src/fs/*.c
  ${CMAKE_SOURCE_DIR}/src/interrupt/*.c
  ${CMAKE_SOURCE_DIR}/src/mm/*.c
)

# Generate kernel object library
add_library(kernel_obj OBJECT ${KERNEL_SOURCES})

# Prosess kallsyms (x86_64 only)
if(ARCH STREQUAL "x86_64")
  add_executable(kallsyms ${CMAKE_SOURCE_DIR}/kallsyms.c)
  add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/kallsyms.S
    COMMAND nm -n $<TARGET_FILE:kernel_obj> | ./kallsyms > kallsyms.S
    DEPENDS kernel_obj kallsyms
  )
  add_library(kallsyms_obj OBJECT ${CMAKE_BINARY_DIR}/kallsyms.S)
  set(EXTRA_OBJS $<TARGET_OBJECTS:kallsyms_obj>)
endif()

# Link kernel
add_executable(naos_kernel
  $<TARGET_OBJECTS:kernel_obj>
  ${EXTRA_OBJS}
)

# Rule of installation
install(TARGETS naos_kernel
  DESTINATION share/naos
  RENAME naos-${ARCH}
)
