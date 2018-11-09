RELEASE=$(lsb_release -rs)
EXTRAPACKAGES=""
if [ "$RELEASE" = "14.04" ]; then
    EXTRAPACKAGES="linux-image-extra-$(uname -r) linux-image-extra-virtual"
fi
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common $EXTRAPACKAGES
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo apt-key add -
CODENAME=$(lsb_release -cs)
sudo apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${CODENAME} stable"
sudo apt-get update
sudo apt-get install docker-ce