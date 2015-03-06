# Remove items used for building, since they aren't needed anymore

BASEURL="/root"

rm $BASEURL/.veewee_params
rm $BASEURL/.veewee_version
rm $BASEURL/base.sh
rm $BASEURL/key.sh
rm $BASEURL/create-akanda-raw-image.sh
rm -rf $BASEURL/akanda-appliance
rm $BASEURL/cleanup.sh
