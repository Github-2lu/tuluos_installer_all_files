import subprocess, json

## format partition
def format_boot_partition(boot_partition):
    status = subprocess.run(f'printf "y" | sudo mkfs.fat -F32 {boot_partition}', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        return 1

    print("[***] Boot Format ERROR.")
    return 0

def format_root_partition(root_partition):
    status = subprocess.run(f'printf "y" | sudo mkfs.ext4 {root_partition}', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        return 1
    print("[***] Root Format Error")
    return 0
        
## mount partitions
def mount_root_partition(root_partition):
    status = subprocess.run(f'sudo mount -v {root_partition} /mnt', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        return 1
    print("[***] Root Mount ERROR: ")
    return 0

def mount_boot_partition(boot_partition):
    status = subprocess.run('sudo mkdir -pv /mnt/boot/efi', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        status = subprocess.run(f'sudo mount -v {boot_partition} /mnt/boot/efi', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            return 1
    print("[***] Boot Mount ERROR: ")
    return 0

def unpack():
    status = subprocess.run('sudo unsquashfs -d /mnt /run/archiso/bootmnt/arch/x86_64/airootfs.sfs', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        # in newer version can't generate ucodes so copy check is removed
        status = subprocess.run('sudo cp -rv /run/archiso/bootmnt/arch/boot/*-ucode.img /mnt/boot', shell=True, executable="/bin/bash")
        status = subprocess.run('sudo cp -v /run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux /mnt/boot', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            return 1
    print("[***] unpack ERROR: ")
    return 0

## generate fstab
def fstab():
    res = subprocess.check_output('sudo genfstab -U /mnt', shell=True, executable="/bin/bash")
    status = subprocess.run(f'sudo genfstab -U /mnt | sudo tee -a /mnt/etc/fstab >> /dev/null', shell=True, executable="/bin/bash", input=res)
    if status.returncode == 0:
        return 1
    print("[***] fstab ERROR with error code: ", status.returncode)
    return 0

## run chroot environ
def chroot():
    status = subprocess.run('sudo mkdir -v /mnt/installer', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        status = subprocess.run('sudo cp -rv ./chroot_files/* ./install.json /mnt/installer', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            status = subprocess.run('sudo arch-chroot /mnt /installer/run2.sh', shell=True, executable="/bin/bash")
            if status.returncode == 0:
                return 1

    print("[***] chroot ERROR")
    return 0

def finish_up():
    subprocess.run('sudo rm -rv /mnt/installer', shell=True, executable="/bin/bash")
    subprocess.run("sudo rm -rv /mnt/etc/skel", shell=True, executable="/bin/bash")
    subprocess.run('sudo umount -a', shell=True, executable="/bin/bash")
    return 1

if __name__=="__main__":

    with open("./install.json", "r") as f:
        data = json.load(f)

    boot_partition = "/dev/" + data["bootInfo"]["name"]
    is_boot_format = data["bootInfo"]["isFormat"]
    root_partition = "/dev/" + data["rootInfo"]["name"]
    is_root_format = data["rootInfo"]["isFormat"]

    format_status = 1

    if(is_boot_format == "Y"):
        if(format_boot_partition(boot_partition)):
            format_status = 1
        else:
            format_status = 0

    if(format_status and is_root_format == "Y"):
        if(format_root_partition(root_partition)):
            format_status = 1
        else:
            format_status = 0

    if (format_status and mount_root_partition(root_partition) and unpack() and mount_boot_partition(boot_partition) and fstab() and chroot() and finish_up()):
        print("[****] INSTALLATION SUCCESSFUL [****]")
    else:
        print("[***] INSTALLATION UNSUCCESSFUL [***]")
