TOOLCHAIN_PREFIX = $(abspath toolchain/$(TARGET))
export PATH := $(TOOLCHAIN_PREFIX)/bin:$(PATH)

toolchain: toolchain_binutils toolchain_gcc
clean: clean-toolchain

BINUTILS_BUILD = toolchain/binutils-build-2.37


toolchain_binutils:
	mkdir -p toolchain
	cd toolchain && wget $(BINUTILS_URL)
	cd toolchain && tar -xf binutils-2.37.tar.xz
	mkdir -p toolchain/binutils-build-2.37
	cd toolchain/binutils-build-2.37 && ../binutils-2.37/configure \
		--prefix="$(TOOLCHAIN_PREFIX)" \
		--target=$(TARGET) \
		--with-sysroot \
		--disable-nls \
		--disable-werror
	$(MAKE) -j24 -C $(BINUTILS_BUILD)
	$(MAKE) -C toolchain/binutils-build-2.37 install

toolchain_gcc: toolchain_binutils
	mkdir -p toolchain
	cd toolchain && wget $(GCC_URL)
	cd toolchain && tar -xf gcc-11.2.0.tar.xz
	cd toolchain/gcc-11.2.0 && ./contrib/download_prerequisites
	mkdir -p toolchain/gcc-build
	cd toolchain/gcc-build && ../gcc-11.2.0/configure \
		--prefix="$(TOOLCHAIN_PREFIX)" \
		--target=$(TARGET) \
		--disable-nls \
		--enable-languages=c,c++ \
		--without-headers
	$(MAKE) -j24 -C toolchain/gcc-build all-gcc all-target-libgcc
	$(MAKE) -C toolchain/gcc-build install-gcc install-target-libgcc

clean-toolchain:
	rm -rf toolchain/*

.PHONY: toolchain toolchain_binutils toolchain_gcc clean-toolchain clean
