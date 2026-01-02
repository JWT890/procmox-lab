# procmox-lab
This project demonstrates the deployment of a full virtualized Windows domain environment using Proxmox VE as the hypervisor. It involves installing Proxmox on a USB-bootable host, creating and configuring Windows Server and Windows 11 virtual machines, building an Active Directory domain, and joining a client workstation to that domain. The project showcases skills in virtualization, Windows Server administration, Active Directory, DNS configuration, and enterprise client integration within a controlled lab environment.

For this setup, you will need a 16 gig USB stick, two VMs a client Windows VM, a Windows Domain Controller, Proxomx for the USB stick, and Active Directory on the VMs.  
Link to download Proxmox: https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso  
Link to download Balena Etcher: https://etcher.balena.io/

# Proxox Flash section
After downloading Proxmox, pull up the Balena Etcher app and you will greeted by this screen:  
<img width="796" height="510" alt="image" src="https://github.com/user-attachments/assets/7c1b1933-a3ba-4acd-9b67-2438f1a8ac91" />  
Click on flash from file and find the iso for the Proxmox file. After selecting the iso it will move on to select a target drive to flash too.  
After selecting select target:  
<img width="803" height="513" alt="image" src="https://github.com/user-attachments/assets/a2dc2ec0-0573-45c5-a556-38b66b2cb3a6" />
Select the flash drive option and you see this screen pop up:  
<img width="806" height="508" alt="image" src="https://github.com/user-attachments/assets/d125667b-fea5-452f-abd4-945d8ca12f9e" />  
Click on flash and wait a couple minutes.  

# Procmox VM Setup
In VirtualBox create a VM named Proxmox with it set to Linux and Debian 64 bit, 8 GB of Memory or 8142, then 4 processors assinged. 100 GB of space or more for the VDI.  
After creation, go the settings -> then to system and uncheck floppy and have it go from optical to hard disk, enable Enable I/O APIC and keep paravirtualization to default.  
Have the adapter 1 as a bridged adapter, then for storage select the proxmox iso and put it there. After getting it set up start the vm and you will greeted by this screen:  
<img width="1016" height="806" alt="image" src="https://github.com/user-attachments/assets/878ce2a1-c263-4989-9077-e5ddb8194814" />  
After clicking on the first option, after a few minutes you will see the EULA screen and click I agree and then you will see this screen:  
<img width="1275" height="800" alt="image" src="https://github.com/user-attachments/assets/9d6f17fe-6425-4485-8de4-c2212040e581" />  
Make sure the hard disk is the VDI that was created and click on next.  
Up next is the location and time zoon selection, make sure to select the create timezone, country, and keyboard layout.  
Then you have to create your password and use a email address, then click next and set the network hostname to pve.local, then hit next to install and then wait a few minutes.  
After waiting a few minutes, it will give you the ip address you can sign in with and write it down or take a picture with it. Then click reboot.  
After hitting reboot, go to devices -> then optical drives -> and click remove disk from drive. After that let it run and boot up for a few minutes. Then you will see this screen:  
<img width="1292" height="799" alt="image" src="https://github.com/user-attachments/assets/dfcb5654-d874-4069-8609-d0eab3d7ebb2" />  
Type the address in your browser and press enter and you will see a screen that says your connection is not private, click advanced and click on the link below it to proceed.  
After click on it you see this page to login:  
<img width="1912" height="911" alt="image" src="https://github.com/user-attachments/assets/7875dcd0-334c-41ca-9213-e7ae809a9929" />  
Sign in with the user name and password to login you set.  
After signing in:  
<img width="1909" height="911" alt="image" src="https://github.com/user-attachments/assets/1aef893d-4238-4c4e-9602-768da22fb399" />  
With Proxmox setup, it is time to setup the other VMs for this.  

# Windows Server VM Setup
Base Memory: 4096 MB  
Processors: 2-4 CPUs
Disk Size: 60 GB  
Windows Server 2022 ISO  
Network Adapter 1: NAT
Network Adapter 2: Bridged Adapter
Windows Server 2022 Standard Evaluation (Desktop Experience)  
Installation Type: Custom  
Disk Selection: Drive 0  

After installing, create a strong admin password for the VM. After the server gets up go set a static IP address by opening up PowerShell as Administrator by right clicking on the start button and going to Windows PowerShell (Admin).  
First type Get-NetAdapter and you will see this:  
<img width="974" height="505" alt="image" src="https://github.com/user-attachments/assets/1ae6be01-b683-4983-b415-d4686dec6188" />  
Then type Rename-NetAdapter -Name "Ethernet" -NewName "Internal" and then Rename-NetAdapter -Name "Ethernet 2" -NewName "Internet"  
Then type New-NetIPAddress -InterfaceAlias "Internal" -IPAddress 192.168.56.10 -PrefixLength 24 and you will see this:  
<img width="902" height="493" alt="image" src="https://github.com/user-attachments/assets/87fcde8f-0b0e-4948-8682-bd87c1ba0797" />  
Then Type Set-DndsClientServerAddress -InterfaceAlias "Internal" -ServerAddress 127.0.0.1  
Then type Get-NetIPAddress -InterfaceAlias "Internal" and see this:  
<img width="820" height="506" alt="image" src="https://github.com/user-attachments/assets/2d65ddc2-e792-4cb1-b5fc-1ff24b6804e4" />  
Then type Get-DnsClientServerAddress -InterfaceAlias 'Internal" and see this:  
<img width="662" height="129" alt="image" src="https://github.com/user-attachments/assets/c7fe9254-687e-4ce7-954e-7c879b8df500" />  
Then type Test-Connection google.com -Count 2 and see this:  
<img width="855" height="109" alt="image" src="https://github.com/user-attachments/assets/b6566556-1197-443a-8abc-e97a39ba2540" />  
Then type Rename-Computer -NewName "DC01" -Restart to rename the Computer and restart for it to take affect.  
After restarting go to PowerShell as Admin and type Install-WindowsFeature AD-Domain-Services -IncludeManagementTools and then wait for a few minutes.  
Then go back to PowerShell Admin and copy and paste this:  
Install-ADDSForest `  
    -DomainName "lab.local" `  
    -DomainNetbiosName "LAB" `  
    -InstallDns `  
    -SafeModeAdministratorPassword (ConvertTo-SecureString "YourDSRM_Password123!" -AsPlainText -Force) `  
    -Force  

















