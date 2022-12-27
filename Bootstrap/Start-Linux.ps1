sudo apt update
sudo apt upgrade -y
sudo apt git powershell -y
pwsh

$destination = "$home/.config/powershell"
git clone https://github.com/FallenGameR/MyProfile.git $destination

"git credential manager + pgp, pass needs to be setup additionally"