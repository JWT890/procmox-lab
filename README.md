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
Choose the Windows 11 Pro edition, US inputs, and choose the disk that was created, and then wait a while for the Windows 11 VM to get created.    
After a long while, make sure to set it up as bare bones as you can since its being used with Proxmox and connecting with the other VM.    
Then get rid of the Windows 11 iso from the optical drive and replace it with the Vbox Guest Additions, power back on the VM, go to the C Drive and look for the VboxWindowsAdditions-amd64.exe and run it and then select the reboot option and restart to get back to the normal windows screen.    
Next up on the Windows 11 VM is to go to settings and go to network and internet like so to the Ethernet l section:    
<img width="1037" height="777" alt="image" src="https://github.com/user-attachments/assets/48c95ba1-2370-4d86-9c1f-609c8e4638cf" />    
Then click on Ethernet and scroll to the details on the first connection, till you see this section:    
<img width="858" height="307" alt="image" src="https://github.com/user-attachments/assets/d0c9bc38-d336-4d3e-b284-36a489b4b4e3" />    
Click edit on the DNS server assignment, change from automatic to manual, turn IPv4 on, set preferred DNS to 192.168.56.10 and leave alternate DNS as blank and hit Save.    

To ensure that the VMs can talk to each other, make sure to have both VM's Adapter 1's set to the first adapter and run this command in the DC01:    
<img width="1271" height="517" alt="image" src="https://github.com/user-attachments/assets/c31d81f5-c45a-4ae2-aaea-5e2b738a5734" />    
And in the client run this command so that the DC01 VM can ping the Client VM:    
<img width="1259" height="428" alt="image" src="https://github.com/user-attachments/assets/26096d61-2d44-4f22-b86a-ccfc10a66b16" />    

# VM Exporting
To export a VM, click on the File tab and click on export appliance:    
<img width="502" height="89" alt="image" src="https://github.com/user-attachments/assets/b3944238-1a4f-4e53-ac44-a566b6ef7165" />    
After clicking on export appliance you will see this:    
<img width="626" height="673" alt="image" src="https://github.com/user-attachments/assets/46eff37f-31a9-4cf3-984d-ce07836f844b" />    
Select the DC01 VM and move on to the next section. Have it look like this:    
<img width="621" height="670" alt="image" src="https://github.com/user-attachments/assets/4c99056c-22e2-42d4-bd96-5b5a7f8d927d" />    
Then move on to the Appliance Settings:    
<img width="627" height="668" alt="image" src="https://github.com/user-attachments/assets/51c46fd4-75d0-4e46-afaa-7a1e64b30831" />    
Then click on finish and wait for a while. Then repeat the process for the other VM.    

# Proxmox File Transfer
To upload ovas into Proxmox, download WinSCP: https://winscp.net/eng/download.php
To do so, boot up the VM and login into the website and create a directory for the OVAs
To create a directory, go the pve that was created and select the option to open up the bash shell.    
Type mkdir -p /var/lib/lib/vz/template/ova/ then ls -lh /var/lib/vz/template/ to confirm creation. Then type chmod 755 /var/lib/vz/template/ova/.    
Then to set proper permission type chmod 755 /var/lib/vz/template/ova/ then type ls -ld /var/lib/vz/template/ova/. Output should look like this:    
<img width="673" height="222" alt="image" src="https://github.com/user-attachments/assets/5bbfc82e-5dac-49ef-aa95-3636397645eb" />    
Then get WinSCP up and login using the SCP protocol, Proxmox server host name, ie 10.0.0.0, port number 22, username and password set and should ook like this afterwards:    
<img width="1464" height="433" alt="image" src="https://github.com/user-attachments/assets/46a7e49e-f443-442d-813d-871934f910a0" />    
Click on the three dots on the right side to go further into the Proxmox host, then go to the folder of var, then lib, then template, then ova.    
Then select the ova files from the host and drag it over to the right and then wait for the transfer to carry over. 

Then to verify type ls -lh /var/lib/vz/template/ova/ and see this output:    
<img width="579" height="67" alt="image" src="https://github.com/user-attachments/assets/55e869c2-2f6d-485b-ac1d-f85650c1a9ea" />    


# Importing into Proxmox
After confirming its time to import the first ova. First cd into /var/lib/vz/template/ova/ then type tar -xvf DC01-WindowsServer.ova, after which it will create the vmdk and ovf files.    
Then go to the web gui website for proxmox and find the button that says Create a VM and click on it.    
<img width="752" height="554" alt="image" src="https://github.com/user-attachments/assets/2f213ef1-b94c-428b-8cd6-0c7e0124b5a4" />    
You will see this, set the ID to 100 and name it DC01-WindowsServer and hit next, on the next screen select do not use any media, keep everything default on systems, then in disks delete the default disk, in CPU/Memory set cores to 2-4 and memory to 8142 MB. Then hit finish.    
Result:    
<img width="1424" height="175" alt="image" src="https://github.com/user-attachments/assets/79b85aed-2e86-432f-988e-10d1311cfbe1" />    
Now its time to import by typing the qm importdisk 100 /var/lib/vz/template/ova/DC01-WindowsServer-disk001.vmdk local-lvm.    
After waiting for a while. Go to the 100 ID that was created previously and go to its hardware tab:    
<img width="1889" height="655" alt="image" src="https://github.com/user-attachments/assets/c814b9a1-d46c-4439-b86f-38f2a4c411dc" />    
Then click on the unused disk part, select SATA for the Bus/Device, click add. Then go to the options tab and double click on boot order.    
<img width="1608" height="662" alt="image" src="https://github.com/user-attachments/assets/70575968-cc06-41b6-af05-cf815c64687e" />    
After double clicking, enable sata0 and drag sata0 to the top and click OK.    
Then go to the console tab and open it up but it will likely fail, so go to the options tab and look for KVM and double click on it and press the disable button to turn it off.    
Then make sure to change the boot order by enabling sata0 and moving it to the first place. 

While waiting for the VM to get set up, go download VirtIO Win by running the command wget -P /var/lib/vz/template/iso/ https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso in the proxmox shell.    
Then go to the Hardware tab select on the CD/DVD Drive and edit it like so:    
<img width="407" height="238" alt="image" src="https://github.com/user-attachments/assets/257e82af-ce04-4554-b64d-43602b36552a" />    
After waiting a few minutes it should be up:    
<img width="1598" height="635" alt="image" src="https://github.com/user-attachments/assets/471b5934-a9fc-4219-ba4f-3807c33a8d31" />    
Then click on the console button to get it into a more manageable screen:    
<img width="1017" height="762" alt="image" src="https://github.com/user-attachments/assets/103077f5-3f86-468e-9628-cece2ff95021" />    
To press control, alt, delete, click on the last option and it will get you to the screen to login. After waiting for a few minutes the main screen will pop up after you get it up:    
<img width="1021" height="831" alt="image" src="https://github.com/user-attachments/assets/91d40e98-d5d7-4281-a2ff-6da775d3a386" />    
Now its time to do the network installation for the first VM, go to the file manager and find the C Drive with Virtio and install it, then reboot the VM.    
After installation, you will see the Virtio info in the side, then click on it and scroll down till you see the QEMU Guest agent info and click on it to install:    
<img width="799" height="473" alt="image" src="https://github.com/user-attachments/assets/62b32188-e00b-4e31-957f-8e26595b59d1" />    
Install it, then go check services.msc to see if QEMU Guest Agent is running:    
<img width="460" height="24" alt="image" src="https://github.com/user-attachments/assets/049c0a7e-bf0c-4bc1-b390-798e11ff62cb" />    
Then its time to configure the network access:    
Type Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddress 127.0.0.1 then Get-DnsClientServerAddress -InterfaceAlias "Ethernet"    
Then type ipconfig /flushdns.    
For the rest to work and connect, go to the Proxmox GUI or Shell and add a second network adapter.    
Go to the Hardware Tab for the first VM and click on add:    
<img width="1471" height="294" alt="image" src="https://github.com/user-attachments/assets/0fa2b92a-1186-4186-bab2-45299a37d925" />    
Then click on network device to see this screen:    
<img width="603" height="177" alt="image" src="https://github.com/user-attachments/assets/6e119479-0921-4386-8327-3733b8339474" />    
Click on add and get back into the VM to verify.    
Then type Get-NetAdapter to get the result, if Test-Connection google.com and 8.8.8.8 still don't work, then go to the Proxmox shell and do this:    
Type ip addr show to see the results, then ip route to see this:    
<img width="593" height="53" alt="image" src="https://github.com/user-attachments/assets/b7e8c659-995a-410b-b361-09de0b328af7" />    
Then type ping 8.8.8.8 for this:    
<img width="634" height="294" alt="image" src="https://github.com/user-attachments/assets/3eb79874-61d5-44c5-92bd-dc6b4ed33c0e" />    
Then type cat /etc/network/interfaces and see this:    
<img width="571" height="275" alt="image" src="https://github.com/user-attachments/assets/f1e3e182-80f9-4016-b4a3-0be55048154f" />    
Then type nano /etc/network/interfaces and add this info:    
<img width="774" height="187" alt="image" src="https://github.com/user-attachments/assets/b5fa99f6-545a-463d-8e7d-570dc7e976e0" />    
Then save and exit and type systemctl restart networking and then type ip addr show vmbr1 to verify:    
<img width="787" height="141" alt="image" src="https://github.com/user-attachments/assets/20a26f01-d6d9-4723-8cae-79574c72300c" />    
Then qm set 100 --net1 virtio,bridge=vmbr1 and then qm reboot 100 to reboot the VM.    
After waiting a while go back to PowerShell and type Get-NetAdapter to verify.    
Then type New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress 10.0.2.10 -PrefixLength 24 -DefaultGateway 10.0.2.1.    
Then type Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 8.8.8.8, 8.8.4.4.    
Then type ipconfig /flushdns and then ping 8.8.8.8 and then Test-Connection google.com to see if it worked:    
<img width="937" height="343" alt="image" src="https://github.com/user-attachments/assets/63f8d629-1a51-4322-b552-a1acf42896d9" />    
Then to verify Active Directory:    
<img width="780" height="132" alt="image" src="https://github.com/user-attachments/assets/ebe7835e-2798-4645-aecb-ee47a02c2841" />    
To verify the domain:    
<img width="781" height="104" alt="image" src="https://github.com/user-attachments/assets/600f91b0-da63-4e1d-b9e7-f661a809f90f" />    
To verify users:    
<img width="863" height="206" alt="image" src="https://github.com/user-attachments/assets/33910697-0bfa-4a50-a135-4900603730de" />    
Then to verify DNS connection:    
<img width="558" height="293" alt="image" src="https://github.com/user-attachments/assets/3d88a0bd-9958-40d4-a15f-2100860f46f9" />    

Now that the DC is set up, it is now time to set up the Client VM by following the above sequence.    








































































