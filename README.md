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
Network Adapter 1: Host only    
Network Adapter 2: NAT    
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
And change the password to something more secure and write it down. Then wait for a few minutes.    
After waiting for a few minutes, go back to the PowerShell admin and type Get-ADDomain to check for lab.local configuration. Type Get-ADDomain.   
<img width="953" height="558" alt="image" src="https://github.com/user-attachments/assets/74726c87-cc24-4997-b54f-b11a6dc29e63" />    
Then type Get-ADDomainController: 
<img width="959" height="496" alt="image" src="https://github.com/user-attachments/assets/ecb1e738-9c65-49b0-8749-04226152586b" />   
Then type Get-AD0rganizationalUnit -Filter *:    
<img width="876" height="257" alt="image" src="https://github.com/user-attachments/assets/c81f223c-85c8-42de-b658-b3136d2cf381" />    
Then to test the DNS type nslookup lab.local and nslookup dc01.lab.local:    
<img width="445" height="276" alt="image" src="https://github.com/user-attachments/assets/b88646d9-2e2d-4fc3-bf9d-49ceaadf48ca" />    
Then go to the start menu and click on Windows Administrative Tools and click on Active Directory Users and Computers and expand the lab.local.    
Then in PoweShell Admin type New-ADOrganizationalUnit -Name "Departments" -Path "DC=lab,DC=local".    
Then type New-ADOrganizationalUnit -Name "IT" -Path "OU=Departments,DC=lab,DC=local".    
Then type New-ADOrganizationalUnit -Name "HR" -Path "OU=Departments,DC=lab,DC=local".    
Then type New-ADOrganizationalUnit -Name "Sales" -Path "OU=Departments,DC=lab,DC=local".    
Then type New-ADOrganizationalUnit -Name "Finance" -Path "Ou=Departments,DC=lab,DC=local".    
Then type New-ADOrganizationalUnit -name "Workstations" -Path "DC=Lab,DC=local".    
Then type Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistingguishedName to verify and the expected result:    
<img width="850" height="190" alt="image" src="https://github.com/user-attachments/assets/77560213-cce7-430e-b53a-0d834f3cfc2a" />    
Then go into the Powershell ISE and run the lab.ps1 script by looking in the code repo for this.   
Users created should be cbrown, dprince, bjohnson, jsmith, and awilliams.    
Then go and create the security groups for the first security group:    
<img width="479" height="81" alt="image" src="https://github.com/user-attachments/assets/19ad1dd3-be99-4ae5-b69f-fd4cffce93c4" />    
For the second group:    
<img width="453" height="87" alt="image" src="https://github.com/user-attachments/assets/7a142645-76d3-4c7b-966f-ecad5c443e38" />    
For the third group:    
<img width="485" height="83" alt="image" src="https://github.com/user-attachments/assets/fb5f7f19-07bc-4093-891d-f814c9217f73" />    
And the fourth group:    
<img width="493" height="83" alt="image" src="https://github.com/user-attachments/assets/a97473ec-ee6a-4436-a07e-db86774da567" />    
Then add the users to the respective groups:    
<img width="763" height="53" alt="image" src="https://github.com/user-attachments/assets/06b69a21-92a7-4afb-abfe-a3cb02b7e0d3" />    
<img width="694" height="20" alt="image" src="https://github.com/user-attachments/assets/df4e54ee-9d6c-4035-a282-7ba5a53b7998" />    
Then to verify the groups type this command with the IT-Admins group as on example:    
<img width="838" height="110" alt="image" src="https://github.com/user-attachments/assets/741d594e-d303-456b-83cb-c7539a6c4dbf" />    

# Windows 11 Client VM
Base Memory: 4096 MB    
Windows 11 iso    
Processors: 2-4 CPUs
Disk Size: 64 GB    
Video Memory: 128 MB    
Adapter 1: Host Only    
Adapter 2: NAT    
Windows 11 iso download: https://www.microsoft.com/en-us/software-download/windows11    
Choose the Windows 11 Home edition, US inputs, and choose the disk that was created, and then wait a while for the Windows 11 VM to get created.    

































