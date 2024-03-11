import subprocess, json

## timezone
def timezone(region, zone):
    status = subprocess.run(f'ln -sfv /usr/share/zoneinfo/{region}/{zone} /etc/localtime' ,shell=True, executable="/bin/bash")

    if status.returncode == 0:
        status = subprocess.run('hwclock -v --systohc', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            return 1
    print("[***] timezone ERROR.")
    return 0

def locale(localeInfo):
    status = subprocess.run('tee -a /etc/locale.gen >> /dev/null', shell=True, executable="/bin/bash", input=str.encode(localeInfo))

    if status.returncode == 0:
        status = subprocess.run(f'locale-gen', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            return 1
    print("[***] locale ERROR.")
    return 0

def host(host_name):
    content = str.encode(host_name)
    status = subprocess.run('tee /etc/hostname > /dev/null', shell=True, executable="/bin/bash", input=content)
    if status.returncode == 0:
        content = str.encode(f"127.0.0.1    localhost\n::1  localhost\n127.0.0.1    {host_name}.localdomain  {host_name}")
        status = subprocess.run('tee /etc/hosts > /dev/null', shell=True, executable="/bin/bash", input = content)
        if status.returncode ==0:
            return 1
    print("[***] host ERROR.")
    return 0

def createUser(full_name, user_name, user_password, root_password):
    content = str.encode(f"{root_password}\n{root_password}")
    status = subprocess.run('passwd', shell=True, executable="/bin/bash", input=content)
    if status.returncode ==0:
        status = subprocess.run(f'useradd -m -c "{full_name}" {user_name}', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            status = subprocess.run(f'usermod -aG wheel,audio,video,optical,storage {user_name}', shell=True, executable="/bin/bash")
            if status.returncode == 0:
                content = str.encode(f"{user_password}\n{user_password}")
                status = subprocess.run(f'passwd {user_name}', shell=True, executable="/bin/bash", input=content)
                if status.returncode == 0:
                    subprocess.run('mkdir -v /etc/sudoers.d', shell=True, executable="/bin/bash")
                    content = str.encode("%wheel ALL=(ALL:ALL) ALL")
                    status = subprocess.run('tee /etc/sudoers.d/g_wheel', shell=True, executable="/bin/bash", input=content)
                    if status.returncode == 0:
                        subprocess.run('userdel -r live', shell=True, executable="/bin/bash")
                        return 1
    print("[***] Create User ERROR.")
    return 0

def initramfs():
    status = subprocess.run('rm -rv /etc/mkinitcpio.conf.d', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        status = subprocess.run('mkinitcpio -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img --microcode /boot/*-ucode.img', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            status = subprocess.run('mkinitcpio -k /boot/vmlinuz-linux -g /boot/initramfs-linux-fallback.img -S autodetect --microcode /boot/*-ucode.img', shell=True, executable="/bin/bash")
            if status.returncode == 0:
                return 1
    print("[***] initramfs ERROR.")
    return 0

def grub():
    status = subprocess.run('grub-install --target=x86_64-efi /boot/efi', shell=True, executable="/bin/bash")
    if status.returncode == 0:
        status = subprocess.run('grub-mkconfig -o /boot/grub/grub.cfg', shell=True, executable="/bin/bash")
        if status.returncode == 0:
            return 1
    print("[***] grub ERROR.")
    return 0

if __name__=="__main__":
    with open("/installer/install.json", "r") as f:
        data = json.load(f)

    region = data["LocaleInfo"]["Region"]
    zone = data["LocaleInfo"]["Zone"]
    localeInfo = data["LocaleInfo"]["Locale"] + "\n"
    host_name = data["UserInfo"]["HostName"]
    full_name = data["UserInfo"]["FullName"]
    user_name = data["UserInfo"]["UserName"]
    user_password = data["UserInfo"]["UserPassword"]
    root_password = data["UserInfo"]["RootPassword"]

    # print(region, zone, localeInfo, host_name, full_name, user_name, user_password, root_password)
        
    if(timezone(region, zone) and locale(localeInfo) and host(host_name) and createUser(full_name, user_name, user_password, root_password) and initramfs() and grub()):
        print("[****] chroot SUCCESSFUL [****]")
    else:
        print("[***] chroot UNSUCCESSFUL [***]")
