# scripts
pushd $(OSDRV_DIR)/pub/$(PUB_ROOTFS); sed -i 's/::respawn:\/sbin\/getty -L ttyS000 115200 vt100 -n root -I \"Auto login as root ...\"/#::respawn:\/sbin\/getty -L ttyS000 115200 vt100 -n root -I \"Auto login as root ...\"/' ./etc/inittab; popd
