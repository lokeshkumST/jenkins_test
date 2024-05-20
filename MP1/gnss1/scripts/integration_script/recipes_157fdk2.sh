#!/bin/bash


#>>>>>>>>>> Define MACROS
#mention STLinux version compatible to this integration script, mulptiple supported e.g ="4.1 5.0"
COMPATIBLE_stlinux_versions="4.1"
PACKAGE_NAME="gnss1"



#>>>>>>>>>>>>>>>>>>>STAGE 1

#CHECK Script Compatibility--------STARTS----


GREP_RESULT=`grep -r "ST_OSTL_COMPATIBILITY_VERSION" layers/meta-st/meta-st-openstlinux/conf/layer.conf | grep -P '"[^"]+"'`
VERSION_MATCHED=0
for version in `echo GREP_RESULT`
do
	for compat_v in `echo ${COMPATIBLE_stlinux_versions}`
	do
		if [ "$compat_v" == "${version}" ];then
			VERSION_MATCHED=1
		fi
	done
done


if [ 0 -eq ${VERSION_MATCHED} ]; then
        echo "Non-Comatible script/package"
        exit 1
fi

#CHECK Script Compatibility--------ENDS----



#>>>>>>>>>>>>>>>>>>>STAGE 2

#Copy and directory reformation---------STARTS----

echo "cp -r files/X-LINUX-GNSS1-V1.2.0 $YOCTO_BUILD_PATH_JENKINS/"
cp -r files/X-LINUX-GNSS1-V1.2.0 $YOCTO_BUILD_PATH_JENKINS/
echo "cd $YOCTO_TOP_PATH_JENKINS"
cd $YOCTO_TOP_PATH_JENKINS
echo "cp -r  $JENKINS_RECIPE_PATH/* ./layers/meta-st"
cp -r  $JENKINS_RECIPE_PATH/* ./layers/meta-st

#Copy and directory reformation---------ENDS----

#>>>>>>>>>>>>>>>>>>>STAGE 3

#Add package Layer---------STARTS----

bitbake-layers add-layer layers/meta-st/meta-gnss1
bitbake-layers show-layers

#Add package layer---------ENDS----


#>>>>>>>>>>>>>>>>>>>STAGE 4

#Add package into Final Image---------STARTS----

GREP_RESULT=`grep -r "IMAGE_INSTALL:append" layers/meta-st/meta-st-openstlinux/conf/layer.conf`

PACKAGE_PRESENT=`echo  ${GREP_RESULT} | grep -w ${PACKAGE_NAME} `

#!!!enable below to DEBUG
#echo ${PACKAGE_PRESENT}
#echo ${GREP_RESULT}
#!!!Debug end

if [ -z "${GREP_RESULT}" ]; then
        echo "IMAGE_INSTALL:append NOT present, adding"
        echo 'IMAGE_INSTALL:append = "${PACKAGE_NAME}"' >> layers/meta-st/meta-st-openstlinux/conf/layer.conf
else
        echo "IMAGE_INSTALL:append present, adding ${PACKAGE_NAME}"
        if [ -z "${PACKAGE_PRESENT}" ];then
                echo "do SED"
                sed -i "/^IMAGE_INSTALL:append/ s/\"$/ ${PACKAGE_NAME}\"/" layers/meta-st/meta-st-openstlinux/conf/layer.conf
        else
                echo "$PACKAGE_NAME already present"
        fi
fi


echo "Add gnss1 into USERFS "
USRFS_FILE=layers/meta-st/meta-st-stm32mp/recipes-st/images/st-image-userfs.bb
cat >> ${USRFS_FILE} <<- EOM

#Add gnss1 application launch icons
PACKAGE_INSTALL += " \\
    gnss1 \\
    "

EOM

#Add package into Final Image---------ENDS----
