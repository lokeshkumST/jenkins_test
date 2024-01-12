#!/bin/bash
echo "cp -r files/X-LINUX-GNSS1-V1.2.0 $YOCTO_BUILD_PATH_JENKINS/"
echo "cp -r files/X-LINUX-GNSS1-V1.2.0 env.$YOCTO_BUILD_PATH_JENKINS/"
echo "cd $YOCTO_TOP_PATH_JENKINS"
echo "cd env.$YOCTO_TOP_PATH_JENKINS"
echo "cp -r  $JENKINS_RECIPE_PATH ./layers/meta-st"
echo "cp -r  env.$JENKINS_RECIPE_PATH ./layers/meta-st"

#bitbake-layers add-layer layers/meta-st/meta-gnss1
#echo 'IMAGE_INSTALL:append = "gnss1"' >> layers/meta-st/meta-st-openstlinux/conf/layer.conf
#bitbake-layers show-layers
