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
In VirtualBox create a VM named Proxmox with it set to Linux and Debian 64 bit, 16 GB of Memory or 16000 MB, then 4 processors assinged. 200 GB of space or more for the VDI.  
After creation, go the settings -> then to system and uncheck floppy and have it go from optical to hard disk, enable Enable I/O APIC, Nested Paging, Nested VT/AMD and keep paravirtualization to KVM.  
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
Base Memory: 8142 MB    
Windows 11 iso    
Processors: 2-4 CPUs
Disk Size: 80 GB    
Video Memory: 128 MB    
Adapter 1: Host Only    
Adapter 2: NAT    
Windows 11 iso download: https://www.microsoft.com/en-us/software-download/windows11    
Choose the Windows 11 Pro edition, US inputs, and choose the disk that was created, and then wait a while for the Windows 11 VM to get created.    
After a long while, make sure to set it up as bare bones as you can since its being used with Proxmox and connecting with the other VM.    
Then get rid of the Windows 11 iso from the optical drive and replace it with the Vbox Guest Additions, power back on the VM, go to the C Drive and look for the VboxWindowsAdditions-amd64.exe and run it and then select the reboot option and restart to get back to the normal windows screen.    
Then, for later, go to the PowerShell command prompt as admin and type Disable BitLocker -MountPoint "C:" like below:    
<img width="926" height="173" alt="image" src="https://github.com/user-attachments/assets/50140932-bc39-4de3-bb6e-5b0d8f22b98d" />    
Then wait a few minutes and type Get-BitLockerVolume to see if the dencyption process has cmopleted:    
<img width="944" height="175" alt="image" src="https://github.com/user-attachments/assets/eea8ff9c-2894-4a72-9716-2d3ed96a8879" />    
Then followup by typing manage-bde -status C: to get the following:    
<img width="699" height="277" alt="image" src="https://github.com/user-attachments/assets/5ff7b5b7-c586-4584-9593-3ccfdef81e05" />    
Then type gpedit.msc to open up Local Group Policy Editor and look through computer configuration -> administrative templates -? windows components -> BitLocker Drive Encryption -> operating system drives
<img width="1643" height="758" alt="image" src="https://github.com/user-attachments/assets/5f31bda5-7795-467b-8da0-0f90a55f2c30" />    
Then double click on Require additional authentication at startup and set to enabled and the bitlocker option unchecked:    
<img width="683" height="629" alt="image" src="https://github.com/user-attachments/assets/adfed666-51e3-422a-a979-c7486bba99a9" />  
Then click on apply then ok.    
Next up on the Windows 11 VM is to go to settings and go to network and internet like so to the Ethernet 2 section:    
<img width="1036" height="805" alt="image" src="https://github.com/user-attachments/assets/7ceb9f45-18ad-4ffb-9003-922f23e79c9b" />    
Then click on Ethernet and scroll to the details on the first connection, till you see this section:    
<img width="858" height="307" alt="image" src="https://github.com/user-attachments/assets/d0c9bc38-d336-4d3e-b284-36a489b4b4e3" />    
Click edit on the DNS server assignment, change from automatic to manual, turn IPv4 on, set preferred DNS to 192.168.56.10 and leave alternate DNS as blank and hit Save.    

To ensure that the VMs can talk to each other, make sure to have both VM's Adapter 1's set to the first adapter and run this command in the DC01:    
<img width="1271" height="517" alt="image" src="https://github.com/user-attachments/assets/c31d81f5-c45a-4ae2-aaea-5e2b738a5734" />    
And in the client run this command so that the DC01 VM can ping the Client VM:    
<img width="1419" height="446" alt="image" src="https://github.com/user-attachments/assets/14b86af8-eaac-45c4-aa96-4b98f8a3af2c" />    
To Test to see for communication    
From Client to DC:    
<img width="512" height="204" alt="image" src="https://github.com/user-attachments/assets/d2297ae0-409a-4d4c-99e0-2a2253e4dc7f" />    
From DC to Client:    
<img width="532" height="191" alt="image" src="https://github.com/user-attachments/assets/4d08d5e3-d82b-4c7c-8e5d-4c9f5d265788" />    

Then before exporting the VM, lets join it to the domain:    
To Test if client can nslookup the lab domain:    
<img width="469" height="292" alt="image" src="https://github.com/user-attachments/assets/2ce96008-926e-44ff-bdab-ca1817260b40" />    
Then type the command: Add-Computer -DomainName "lab.local" -Credential (Get-Credential) -Restart and then enter the admin credentials when prompted.   
After restarting, you will see other user at login screen:    
<img width="1855" height="916" alt="image" src="https://github.com/user-attachments/assets/5bdfd9e2-10cf-4759-a22f-e6544d2e301e" />
Choose one of the user accounts that was created in the DC, right click their profile and reset their password to use it to login into the client.    
In the clinet type bjohnson@lab.local and then the password that was created for the user. Then wait a couple seconds and then go the command prompt:    
<img width="1141" height="640" alt="image" src="https://github.com/user-attachments/assets/207f60b8-9fbf-460f-a355-3a5b60ea1029" />    
<img width="1472" height="640" alt="image" src="https://github.com/user-attachments/assets/fd7d90d3-72fa-45d3-bf44-7ba93037047f" />    
For a couple tests on both sides ->
DC:    
<img width="906" height="329" alt="image" src="https://github.com/user-attachments/assets/7508959d-071e-4717-a3cd-a69308b2d0cb" />    
<img width="1335" height="214" alt="image" src="https://github.com/user-attachments/assets/20792003-d4de-4aea-a2e5-9da1387b064a" />    
Client:    
<img width="901" height="266" alt="image" src="https://github.com/user-attachments/assets/657ee962-cac5-4c02-a57f-fca81ec82130" />    
<img width="836" height="506" alt="image" src="https://github.com/user-attachments/assets/f74e9e91-4e8c-4600-8dab-79010e4960b8" />    
<img width="939" height="78" alt="image" src="https://github.com/user-attachments/assets/f0d9ad70-fb3c-4410-9ae2-90fdeb0538c4" />    

Then go and create shared Folders in the DC like so:    
<img width="866" height="699" alt="image" src="https://github.com/user-attachments/assets/03f0d3f0-2e8f-4dd6-a519-efa142073aa3" />    
Then create company share folders:    
<img width="1085" height="462" alt="image" src="https://github.com/user-attachments/assets/e581b957-e991-4014-923a-0f33ad8a88f1" />    
*Mistyped for IT*    
Then set permissions:    
<img width="1027" height="288" alt="image" src="https://github.com/user-attachments/assets/5f95a104-7808-4989-8ea6-9b6805beb78c" />    
Then in the client through one of the users:    
<img width="1495" height="798" alt="image" src="https://github.com/user-attachments/assets/8e9443d7-987f-4596-b78c-e3e7746fbfac" />    
Then in the DC, go to Group Policy Management and create a new GPO by expanding the lab.local domain.    
Then right click on Group Policy Objects and select new like so:    
<img width="761" height="517" alt="image" src="https://github.com/user-attachments/assets/396651b0-16d5-41d6-9bca-f3f9015507a0" />    
Then click on edit for the Desktop Wallpaper Policy like so:    
<img width="805" height="585" alt="image" src="https://github.com/user-attachments/assets/cb7a9f7e-211e-4d0e-85b5-d1d45defeceb" />    
<img width="791" height="582" alt="image" src="https://github.com/user-attachments/assets/bf443459-539b-4442-9dd9-c688351371e4" />    
Double click on Desktop Wallpaper and select Enabled and enter a wallpaper path when prompted.    
Then go back to the main Group Policy and right click on Workstations OU and select Link an Existing GPO and select the Desktop policy and hit ok.    
Then go the Client and in the command prompt type gpupdate /force
Then sign out and back in to see the result.    
Next for the home folders:    
<img width="879" height="166" alt="image" src="https://github.com/user-attachments/assets/4f563d5e-cf5d-486e-ad1a-b5a20dd6b6ca" />    
<img width="1023" height="386" alt="image" src="https://github.com/user-attachments/assets/ca5b1e42-a159-4403-b1a8-94906dd8079c" />    
<img width="955" height="35" alt="image" src="https://github.com/user-attachments/assets/d2cff0f7-51d0-41e4-bdfd-24f5719c9c9d" />    
<img width="1039" height="70" alt="image" src="https://github.com/user-attachments/assets/dc5fe1fc-a261-4ee4-ad4e-cca75a5ab44d" />    
<img width="715" height="235" alt="image" src="https://github.com/user-attachments/assets/c4d7ce42-ee18-41bf-aeef-27aba8489a1a" />   
Then in the client user type net use Z: \\dc01.lab.local\Company and run it to see this:    
<img width="1074" height="372" alt="image" src="https://github.com/user-attachments/assets/f8d19613-45b7-43e0-873b-0eee37ab7470" />    

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
<img width="415" height="237" alt="image" src="https://github.com/user-attachments/assets/6aa7bdb8-18bf-4751-a173-b4cff3a9703f" />    
*Using the Windows 11 iso as an example*    
Then for the Virtio:    
<img width="402" height="240" alt="image" src="https://github.com/user-attachments/assets/0c109589-b22d-4f37-9d39-e762bf4bbcb6" />    
After waiting a few minutes it should be up:    
<img width="1598" height="635" alt="image" src="https://github.com/user-attachments/assets/471b5934-a9fc-4219-ba4f-3807c33a8d31" />    
Then click on the console button to get it into a more manageable screen:    
<img width="1017" height="762" alt="image" src="https://github.com/user-attachments/assets/103077f5-3f86-468e-9628-cece2ff95021" />    
To press control, alt, delete, click on the last option and it will get you to the screen to login. After waiting for a few minutes the main screen will pop up after you get it up:    
<img width="1021" height="831" alt="image" src="https://github.com/user-attachments/assets/91d40e98-d5d7-4281-a2ff-6da775d3a386" />    
After waiting a couple minutes you see the Server Manager pop up with a couple spots saying red. Click on the flag icon and select the option of promoting to the Domain Controler:    
<img width="1029" height="782" alt="image" src="https://github.com/user-attachments/assets/dd185248-7f24-4f81-b8b6-02eae1289787" />    
After either a couple minutes or restarting it will show this:    
<img width="837" height="619" alt="image" src="https://github.com/user-attachments/assets/cde0c38c-bd7d-4750-b1be-a5a6c1050f16" />    
The next step is in Powershell to run slmgr /rearm which will change it to this:    
<img width="741" height="66" alt="image" src="https://github.com/user-attachments/assets/60edbc88-c8bd-4c7e-bd98-2968303ed829" />    
Then run: Get-WinEvent -LogName "Directory Service" -MaxEvents 20 | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap to get the last 20 events:    
<img width="785" height="356" alt="image" src="https://github.com/user-attachments/assets/748d02a2-8ccf-4899-9dff-77d3fdf5117d" />    
Then in Command Prompt run set devmgr_show_nonpresentdevices=1 and then type devmgmt.msc -> in Device Manager click on View -> then show hidden devices:    
<img width="251" height="196" alt="image" src="https://github.com/user-attachments/assets/df18a2ef-a2f3-4718-88e7-9cff4645414f" />    
Then delete the first Desktop Adapter and possibly #2, then in PowerShell run Restart-Computer -Force and then you will see this:    
<img width="1009" height="729" alt="image" src="https://github.com/user-attachments/assets/1b5d8681-75f3-4fce-85bc-6c64ae208f0d" />    

Now its time to do the network installation for the first VM, go to the file manager and find the C Drive with Virtio and install it, then reboot the VM.    
After installation, you will see the Virtio info in the side, then click on it and scroll down till you see the QEMU Guest agent info and click on it to install:    
<img width="799" height="473" alt="image" src="https://github.com/user-attachments/assets/62b32188-e00b-4e31-957f-8e26595b59d1" />    
Install it, then go check services.msc to see if QEMU Guest Agent is running:    
<img width="460" height="24" alt="image" src="https://github.com/user-attachments/assets/049c0a7e-bf0c-4bc1-b390-798e11ff62cb" />  
Or go to Device Manager, expand on Other Devices and right click on Ethernet Controller    
<img width="311" height="96" alt="image" src="https://github.com/user-attachments/assets/2d0c5d3f-a2c8-4fd4-b5d5-b6a7fe142d81" />    
Then select the update driver option -> browse my computer for drivers -> select the Virtio CD drive:    
<img width="326" height="333" alt="image" src="https://github.com/user-attachments/assets/1cfe1142-1251-473f-8071-7eca610b2f4a" />    
Expand upon it and scroll down till you see the NetKVM option and select the 2k22 option -> amdb64 folder -> click ok and then next. It should get installed from there.    
After a couple seconds the Red Hat option should pop up:    
<img width="302" height="226" alt="image" src="https://github.com/user-attachments/assets/727d4a81-fd22-4655-abcc-53329e89d6be" />   
Then go to PowerShell to confirm that the port 389 is listening by typing up netstat -ano | findstr :389 like so:    
<img width="986" height="515" alt="image" src="https://github.com/user-attachments/assets/6dee57bb-aa6a-4225-bfc0-10221fce7b99" />    

Then its time to configure the network access:    
Type Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddress 127.0.0.1 then Get-DnsClientServerAddress -InterfaceAlias "Ethernet"    
Then type ipconfig /flushdns.    
For the rest to work and connect, go to the Proxmox GUI or Shell and add a second network adapter and get rid of net0 which will get rid of one of the Ethernets that spawn.    
Then go to the DNS manager and or delete any residual VirtualBox addresses like so:    
<img width="555" height="357" alt="image" src="https://github.com/user-attachments/assets/6dc70d5f-3b51-4e8d-87c6-e62810809b4e" />    
Delete the 10.0.0.x addresses and the Win11-Client VM address since it has been moved to Proxmox.    
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
Start by importing using WinSCP, then go and check to see if its there by typing ls -lh /var/lib/vz/template/ova/.    
Then for space reasons type: rm /var/lib/vz/template/ova/DC01-WindowsServer.mf /var/lib/vz/template/ova/DC01-WindowsServer.ova /var/lib/vz/template/ova/DC01-WindowsServer.ovf.    
To free up some space. Then type tar -xvf Win11-Client01.ova Win11-Client01-disk001.vmdk. Then type qm importdisk 101 Win11-Client01-disk001.vmdk local-lvm and wait a while.  

To properly install Windows 11 on Proxmox:    
<img width="1601" height="499" alt="image" src="https://github.com/user-attachments/assets/a93e0c4f-1212-422b-9bcd-8dcf7a75c0bf" />    
*Or do Skyline-Client to speed it up a little bit and access other things.*    
Then upload the Windows 11 iso and put it ide2 in CD/DVD:    
<img width="1595" height="634" alt="image" src="https://github.com/user-attachments/assets/a6902ba8-be8a-46fd-99d6-7a4c4bfb1bbb" />    
The sata0 should be the imported vmdk and the ide2 should be the Windows 11 iso needed in a few minutes.    
Then click on start and wait for the Windows 11 installation wizard to pop up, click next till you see the install or repair my PC options.    
Make sure to click on the Repair my PC option and then wait a couple minutes.    
After waiting a couple minutes, you will see a screen with keyboard options and select the US one, then you will see this screen:       
<img width="754" height="459" alt="image" src="https://github.com/user-attachments/assets/c7d01b47-a44a-460b-bded-2a35f8e33dd4" />    
Click on troubleshoot, then click on the command prompt and you will be taken to command prompt.    
In command prompt, type diskpart to access diskpart, then list disk to see the disks, then select 0, then list volume, then list disk:    
<img width="1008" height="631" alt="image" src="https://github.com/user-attachments/assets/aa339b60-527f-4fbe-8c67-4c233be58556" />    
The alternative is to just reimport the vmdk and get turn the console back on. After waiting for a few minutes on the Proxmox screen you should see the Windows logon:    
<img width="1008" height="628" alt="image" src="https://github.com/user-attachments/assets/0fbb58dd-f970-4feb-80bf-47490233b2f5" />    
Then enter the password and wait a few minutes for the Windows normal screen to pop up.    
<img width="1292" height="862" alt="image" src="https://github.com/user-attachments/assets/6681916f-0245-417e-b565-092939ef536a" />    
Then click on File Explorer and go to the drive that says virtio-win like so and navigate to the guest agent folder:    
<img width="794" height="602" alt="image" src="https://github.com/user-attachments/assets/fd38ba07-868e-47b1-a6cc-7e0e05bb390e" />    
Then click on the second option to begin the installation. 
*Make sure to have QEMU checked to enable in options to proceed, and or you can skip it for now and test network connectivity with the DC*    
Then go to Device Manager, click on view and then click on show hidden devices, then click on Unknown device and click on update driver:    
<img width="532" height="511" alt="image" src="https://github.com/user-attachments/assets/9ca295d3-fbd9-4782-9fbf-0b14c2f6d2e5" />    
Then click on browse my computer for drivers:    
<img width="625" height="454" alt="image" src="https://github.com/user-attachments/assets/4ee923b6-411c-4c51-b197-c055d5a8a0c0" />    
Then click on browse and find the virtio driver, then find NetKVM, then w11, then amd64, then save. Or go to the file folder drive with it in there and install it then restart.    
After restarting, type Get-NetAdapter and see this result:    
<img width="1090" height="186" alt="image" src="https://github.com/user-attachments/assets/efec0c6b-dfe9-4153-94c7-9326e7d5d47b" />    
Make sure to get rid of the second network device and one the first one, set the bridge to vmbr1 and potentially keep the Model to Virtio or change it to either Intel.    
Then its time to set up the network configuration between the VMs.    
Type qm set 100 --net0 virtio,bridge=vmbr0 and same with 101.    
Then go to the DC VM and type Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false.    
Then type New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.56.10 -PrefixLength 24 to set it once more.    
Then type Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddress 127.0.0.1, then ipconfig /all.    
Then its time to go back to the Windows 11 Client VM in Proxmox.   
Type Get-NetAdapter to see the Interface Description like below:    
<img width="1092" height="127" alt="image" src="https://github.com/user-attachments/assets/8a19766b-8f9e-4ea2-aa31-7b4fc9390e87" />    
Then type New-NetIPAddress -InterfaceAlias "Ethernet 3" -IPAddress 192.168.56.20 -PrefixLength 24 to set the IP Address of the VM.    
Then type Set-DnsClientServerAddress -InterfaceAlias "Ethernet 3" -ServerAddresses 192.168.56.10 and then ping 192.168.56.10:    
<img width="980" height="254" alt="image" src="https://github.com/user-attachments/assets/2fcefd39-b309-470d-a1b9-5af2995bdee8" />    
Then type nslookup lab.local to see if it can connect:    
<img width="577" height="213" alt="image" src="https://github.com/user-attachments/assets/953dfeeb-8752-4c6e-98f1-facd3f23eb94" />    
Then on the DC type ping 192.168.56.20 to see if can talk with the Client VM:    
<img width="534" height="196" alt="image" src="https://github.com/user-attachments/assets/c0537fe3-b709-40d0-a4aa-b072085c6f35" />    














































































































