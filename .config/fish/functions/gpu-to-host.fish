function gpu-to-host
    sudo virsh nodedev-reattach pci_0000_01_00_0
    sudo virsh nodedev-reattach pci_0000_01_00_1
    echo "GPU reattached (now host ready)"
    
    sudo rmmod vfio_pci
    sudo rmmod vfio_pci_core
    sudo rmmod vfio_iommu_type1
    sudo rmmod vfio
    echo "VFIO drivers removed"
    
    sudo modprobe nvidia
    sudo modprobe nvidia_modeset
    sudo modprobe nvidia_uvm
    echo "NVIDIA drivers added"
    
    echo "COMPLETED!"
end
