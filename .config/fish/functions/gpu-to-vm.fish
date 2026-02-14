function gpu-to-vm
    sudo rmmod nvidia_uvm
    sudo rmmod nvidia_modeset
    sudo rmmod nvidia
    echo "NVIDIA drivers removed"
    
    sudo modprobe vfio_pci
    echo "VFIO drivers loaded"
    
    sudo virsh nodedev-detach pci_0000_01_00_0
    sudo virsh nodedev-detach pci_0000_01_00_1
    echo "GPU detached (now VM ready)"
    
    echo "COMPLETED!"
end
