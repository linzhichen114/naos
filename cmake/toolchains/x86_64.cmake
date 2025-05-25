# Cross-compile configure
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER x86_64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER x86_64-linux-gnu-g++)
set(CMAKE_ASM_COMPILER nasm)

# Global compile flags
add_compile_options(
  -m64
  -march=x86-64
  -mno-red-zone
  -mcmodel=kernel
  -D__x86_64__
  -ffreestanding
  -fno-stack-protector
  -nostdinc
)

# Linker flags
set(CMAKE_EXE_LINKER_FLAGS
  "-nostdlib -static -z max-page-size=0x1000 -Wl,--gc-sections -T ${CMAKE_SOURCE_DIR}/linker-x86_64.ld"
)

# NASM assembly configure
enable_language(ASM_NASM)
set(CMAKE_ASM_NASM_FLAGS "-F dwarf -g -f elf64")
