-- Creates a QEMU virtual machine from a NixOS qcow2 image.
-- Usage: osascript create-vm.applescript <name> <image> <memory MiB> <cpu cores> <width> <height>
on run argv
	set vmName to item 1 of argv
	set imagePath to item 2 of argv
	set memorySize to (item 3 of argv) as integer
	set cpuCount to (item 4 of argv) as integer
	set displayWidth to item 5 of argv
	set displayHeight to item 6 of argv

	tell application "UTM"
		set vm to make new virtual machine with properties {backend:qemu, configuration:{name:vmName, architecture:"aarch64", memory:memorySize, cpu cores:cpuCount, hypervisor:true, uefi:true, directory share mode:none, drives:{{interface:VirtIO, source:(POSIX file imagePath)}}, network interfaces:{{mode:shared}}, displays:{{hardware:"virtio-gpu-gl-pci", dynamic resolution:false, native resolution:true}}, qemu additional arguments:{{argument string:"-global"}, {argument string:"virtio-gpu-gl-pci.xres=" & displayWidth}, {argument string:"-global"}, {argument string:"virtio-gpu-gl-pci.yres=" & displayHeight}}}}
	end tell
end run
