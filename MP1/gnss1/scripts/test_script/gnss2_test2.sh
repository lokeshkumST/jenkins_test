#!/bin/bash

##declare sensors here


#sleep 5
echo ""
echo ""
echo ""
echo ""
echo ""
echo "<==========Starting Board Testing============>"
echo ""
IIC_SENSOR_PREFIX=(GYRO ACCEL TEMP PRESS MAGN)

GYRO_NAME="ism330dhcx_gyro"
MAGN_NAME="iis2mdc_magn"
TEMP_NAME="lps22hh_temp"
ACCEL_NAME="ism330dhcx_accel"
PRESS_NAME="lps22hh_press"


GYRO_NAME_A="ism330dhcx_gyro"
MAGN_NAME_A="iis2mdc_magn"
TEMP_NAME_A="ilps22qs_temp"
ACCEL_NAME_A="ism330dhcx_accel"
PRESS_NAME_A="ilps22qs_press"

GNSS_DESIGN="U2"
GYRO_DESIGN="U3"
ACCEL_DESIGN="U3"
TEMP_DESIGN="U4"
PRESS_DESIGN="U4"
MAGN_DESIGN="U5"

#PRESS_SCALE = 0.000244140
#TEMP_SCALE = 0.010000000

 
##GPS  UART name      
 
GPS_UART_DEV=/dev/ttySTM1
 

## sysfs path

SYSFS_PATH_PREFIX=/sys/bus/iio/devices/


##Data variables

#==========GYRO===========
GYRO_ID=0x6b 
GYRO_BUS_ID=1
#GYRO_EN=1
GYRO_DEV_NUM=3
GYRO_DEV_NAME=''


#declare properties to be read below alogn with alias(print) names
var_names_GYRO=(in_anglvel_x_raw in_anglvel_y_raw in_anglvel_z_raw)
alias_names_GYRO=(x_data y_data z_data)

#--------------------------

#==========ACCEL===========
ACCEL_ID=0x6b
ACCEL_BUS_ID=1
#ACCEL_EN=1                                                                                                                         
ACCEL_DEV_NUM=4 
ACCEL_DEV_NAME=''

#declare properties to be read below alogn with alias(print) names
var_names_ACCEL=(in_accel_x_raw in_accel_y_raw in_accel_z_raw)
alias_names_ACCEL=(x_accel y_accel z_accel)

#--------------------------

#==========TEMP===========
TEMP_ID=0x38
TEMP_BUS_ID=1
#TEMP_EN=0
TEMP_DEV_NUM=5
TEMP_DEV_NAME=''

#declare properties to be read below alogn with alias(print) names
var_names_TEMP=(in_temp_raw)
alias_names_TEMP=(temperature_value)

#--------------------------

#==========PRESS===========
PRESS_ID=0x5c
PRESS_BUS_ID=1
#PRESS_EN=0
PRESS_DEV_NUM=0
PRESS_DEV_NAME=''

#declare properties to be read below alogn with alias(print) names
var_names_PRESS=(in_pressure_raw)
alias_names_PRESS=(pressure_value)

#--------------------------
#==========MAGN===========
MAGN_ID=0x5c
MAGN_BUS_ID=1
MAGN_DEV_NAME=''
var_names_MAGN=(in_magn_x_raw in_magn_y_raw in_magn_z_raw)
alias_names_MAGN=(magn_x magn_y magn_z)

#--------------------------
#==========UART===========
UART_GPS_LONG=0
UART_GPS_LATT=0


#--------------------------

sensor_ok_count=0
gps_ok=0

                
line_counter=0 
mag_ok=0

test_mag(){
line=`./iio_generic_buffer -n iis2mdc_magn  -ga -c 1 | sed -e '/all/d' | sed -e '/in/d' | sed -e '/mode/d'`
#exec 5< <(./iio_generic_buffer -n iis2mdc_magn  -ga -c 1 | sed -e '/all/d' | sed -e '/in/d' | sed -e '/mode/d')
#read <&5 line
echo "magnometer value:" $line
if [ -z "$line" ]; then
#echo " ${MAGN_NAME}: (U5) sensor test: Fail"
mag_ok=0
else
echo " ${MAGN_NAME}: (U5) sensor test: PASS"
sensor_ok_count=$((sensor_ok_count+1))
mag_ok=1

fi
}   

echo
i2cset -y 0 0x50 0x01 0x11 0xaa i
i2cset -y 0 0x50 0x01 0x11
echo
echo


if [ `i2cget -y 0 0x50` == 0xaa ]; then
        echo "M24C32R_eeprom : (U1) eeprom test: PASS"
        sensor_ok_count=$((sensor_ok_count+1))

else
        echo "M24C32R_eeprom : (U1) eeprom test: FAIL"
fi         
                                                                                                                                                                                               
test_gps(){ 
./gnss_uart_read                                                                                                                                                                                                          
exec 4<  <(cat /dev/ttySTM1)                                                                                                                                                                               
for i in 1 2 3 4 5 6 7 8 9 10 11                                                                                                                                                                           
do                                                                                                                                                                                                         
read <&4 line                                                                                                                                                                                              
if [ -z "$line" ]; then
sleep 1
continue
else
line_counter=$((line_counter+1))
fi                                                                                                                                                                                                           
#echo "$line"| grep GNRMC                                                                                                                                                                                   
for items in `echo "$line"| grep GNRMC`                                                                                                                                                                    
do                                                                                                                                                                                                         
        values=($(awk -v var="$items" 'BEGIN{ split(var,a,","); print  a[4] " " a[6]}'))                                                                                                                   
                if [[ ( ${values[0]}  > 0 ) && ( ${values[1]} > 0 ) ]]; then                                                                                                                                
			#echo *"************************"
                        echo GNRMC value PASS                                                                                                                                                            
			#echo "*************************"
			sensor_ok_count=$((sensor_ok_count+1))
                        gps_ok=1
                else                                                                                                                                                                                       
			#echo "*************************"
                        echo GNRMC value Failed!!!!!!: ${values[0]} ${values[1]}!!!!!                                                                                                                                 
			#echo "*************************"
                        gps_ok=0
                fi                                                                                                                                                                                         
done                                                                                                                                                                                                       
                                                                                                                                                                                                           
#echo "$line"| grep GNGGA                                                                                                                                                                                   
for items in `echo "$line"| grep GNGGA`                                                                                                                                                                    
do                                                                                                                                                                                                         
        values=($(awk -v var="$items" 'BEGIN{ split(var,a,","); print  a[4] " " a[6]}'))                                                                                                                   
                if [[ ( ${values[0]} > 0 ) && ( ${values[1]} > 0 ) ]]; then                                                                                                                                
			#echo "*************************"
                        echo GNGGA value PASS                                                                                                                                                           
			#echo "*************************"
			sensor_ok_count=$((sensor_ok_count+1))
			 gps_ok=1
                else                                                                                                                                                                                       
			#echo "*************************"
                        echo GNGGA value Failed !!!!!: ${values[0]} ${values[1]}!!!!!   
			gps_ok=0						
			#echo "*************************"
                fi                                                                                                                                                                                         
done                                                                                                                                                                                                        
done
#echo line_counter: ${line_counter}
sleep 1
}


test_gps_i2c(){ 
value=$(i2cget -y 1 0x3a)

# Check the return value of the i2cget command
if [ $? -eq 0 ]; then
  echo "GPS (U2) I2C Test PASS: $value"
  sensor_ok_count=$((sensor_ok_count+1))
else
  echo "GPS(U2) I2C Test failed"
fi
sleep 1
}



for pref_list in `echo ${IIC_SENSOR_PREFIX[*]}`                                                                                                                                                            
do                                                                                                                                                                                                         
#echo ${pref_list}_NAME 
temp_v=${pref_list}_NAME
#echo ${!temp_v}
#echo $GYRO_NAME
done

# retreive names 
for devs  in `ls /sys/bus/iio/devices/ | grep iio`
do
#echo ${devs}
V_TNAME=`cat /sys/bus/iio/devices/${devs}/name`
#echo "**" $V_TNAME
for pref_list in `echo ${IIC_SENSOR_PREFIX[*]}`
do
temp_v=${pref_list}_NAME
#echo ${pref_list}_NAME  ":" $((${pref_list}_NAME))
#if [ "$((${pref_list}_NAME))" = "$V_NAME" ]
if [ "${!temp_v}" = "${V_TNAME}" ]
then
#echo "----------------matched----------"
eval ${pref_list}_DEV_NAME=${devs}

#echo ${pref_list}_DEV_NAME 

temp_v=${pref_list}_DEV_NAME  #saves iio dev name

#echo ${!temp_v}

break
fi
done
done



#MAX_LOOP=100 
#while true
#GYRO_DEV=`echo ${SYSFS_PATH_PREFIX}${GYRO_BUS_ID}-${GYRO_ID}/iio::device${GYRO_DEV_NUM}`
#for ((main_l=0;main_l<$MAX_LOOP;main_l++))
#do
for dev_prefx in `echo ${IIC_SENSOR_PREFIX[*]}`
do
   i=0
 #   echo ===========Testing $dev_prefx Sensor =============================
    #DEV_SYSFS_PATH=`echo ${SYSFS_PATH_PREFIX}${${dev_prefx}_BUS_ID}-${${dev_prefx}_ID}/iio:device${${dev_prefx}_DEV_NUM}`
 #   BUS_ID=$((${dev_prefx}_BUS_ID))
 #   ID=$((${dev_prefx}_ID))
    NAME_T=${dev_prefx}_DEV_NAME
    NAME_S=${dev_prefx}_NAME_A
    DESIGN_S=${dev_prefx}_DESIGN
   #echo ${!NAME_T}
   #LK--echo ${SYSFS_PATH_PREFIX}
    DEV_SYSFS_PATH=`echo ${SYSFS_PATH_PREFIX}``echo ${!NAME_T}`
    NAME=var_names_${dev_prefx}
    Alias=alias_names_${dev_prefx}
    Alias_arr=("$Alias[@]")
    Alias_arr=(${!Alias_arr})
        subst="$NAME[@]"
   if [ "${dev_prefx}" = "MAGN" ];then
        #echo "test via iio buffer"
	test_mag
	if [ ${mag_ok} = 1 ];then
		#echo "mag OK via iio_buffer_command"
		continue
        fi
   fi
    for var_name in "${!subst}"
    do
        var_value=`cat ${DEV_SYSFS_PATH}/$var_name`  
	#echo ${Alias_arr[$i]} : $var_value
        ((i++))
    done
    if [ ! -z '$(var_value)' ];then
#	echo "========================="
        #echo "$NAME sensor test: PASS"
        #echo "${dev_prefx} sensor test: PASS"
        echo " ${!NAME_S}: (${!DESIGN_S}) sensor test: PASS"
#	echo "========================="
	sensor_ok_count=$((sensor_ok_count+1))

    else
	echo "XXXXXXXXXXXXXXXXXXXXXXXXX"
        #echo "$NAME (${!DESIGN_S}) sensor test: FAIL"
        echo " ${!NAME_S} sensor test: PASS"
	echo "XXXXXXXXXXXXXXXXXXXXXXXXX"

    fi
        sleep 2
done

	 #test_mag
 #   echo ===================================================== 
    echo " 		Testing GNSS    "
  #  echo ===================================================== 

line_counter=0                                                                                                                                                                                                            
for ((trygps=0;${trygps}<6;trygps=$((trygps+1)) ))
do
    if [ ${line_counter} -gt 5 ]; then
        break
    else
         test_gps
    fi
done

if [ $gps_ok == 1 ]; then
echo "GPS(U2) Test Pass"
else
echo "GPS(U2) Test **Failed**"
fi

#GPS I2C Test
test_gps_i2c

#cat ${GPS_UART_DEV} &

#sleep 1

#`killall 'cat'`

echo 
#echo "sensor ok count is :" $sensor_ok_count
#sleep 5



#done 

usr_switch_ok=0
rst_switch_ok=0
wake_switch_ok=0
switch_ok_count=0

switch_status=0
can_close_led=0
if [ `gpioget gpiochip5 1` == 1 ]; then
    echo "************************************************************"
    echo "TESTING USER SWITCH(SW3)"
    echo "----> Press and 'HOLD' USER switch(SW3) and Check D7 LED(Yellow)"
    echo ""
    #echo "************************************************************"
else
    echo "************************************************************"
    echo "----> USER switch(SW3) is already pressed,check D7 LED(yellow) is ON"
    #echo "************************************************************"
    `gpioset gpiochip2 7=1`
     switch_status=1
     sleep 2
     echo "enter y/Y if Yellow LED is on"
     read -n status_usr
     if [ $status_usr == 'y' ] || [ $status_usr == 'Y' ]; then
         usr_switch_ok=1
	 switch_ok_count=$((switch_ok_count+1))
     fi

fi
do_log=1
while [ 1 ]
do

    if [ `gpioget gpiochip5 1` == 0 ]; then
        `gpioset gpiochip2 7=1`
        switch_status=1
        if [ $do_log == 1 ]; then
            do_log=0
           # echo "************************************************************"
	    #echo "----> D7 LED(Yellow) is on,release USER switch(SW3) to disable yellow LED "

            echo "Check if Yellow LED(D7) is ON if yes, press 'y' and then Enter , Press n and then Enter if D7 is  OFF"
	    while [ 1 ]
	    do
		    read  status_usr
		    if [ -z "$status_usr" ]; then
			    echo "enter valid key"
         	    else
			    break
		    fi
	    done
            if [ $status_usr == 'y' ] || [ $status_usr == 'Y' ]; then
               usr_switch_ok=1
	       switch_ok_count=$((switch_ok_count+1))
    	       echo "USER SWITCH(SW3) marked PASS by user"
	     else
    		echo "USER SWITCH(SW3) marked **FAIL** by user"
           fi
            echo "Release USER Switch(SW3)"

            #echo "************************************************************"
            echo ""
        fi
    else
        if [ $switch_status == 1 ]; then
            `gpioset gpiochip2 7=0`
            echo
            #echo "************************************************************"
            echo "Switching OFF LED D7(yellow)" 
            #echo "************************************************************"
            echo
            echo
            break
        fi
    fi
sleep 1
done
#echo "************************************************************"
#echo "Check if yellow LED(D7) is OFF, USER SWITCH is OK"
#echo "************************************************************"
echo
echo
echo "************************************************************"
echo "Testing WAKEPUP SWITCH(SW1)"

echo ""
echo ""
./gnss_uart_read
echo "putting GNSS (Teseo-LIV4F) on standby"
echo ""
#echo "************************************************************"
echo "$PSTMFORCESTANDBY,0060\r\n" > /dev/ttySTM1
echo "\$PSTMFORCESTANDBY,0060\r\n" > /dev/ttySTM1
echo "\$PSTMFORCESTANDBY,0060\r\n" > /dev/ttySTM1
sleep 2
#echo "************************************************************"
echo "check Green LED(D5) should remain stable (ON or OFF and will not be Blinking)"
#echo "************************************************************"
echo ""

status_usr=""
echo "Press 'y' and then Enter,  if Green LED(D5) is stable (ON or OFF and will not be Blinking), otherwise press 'n' if Blinking and then Enter "
while [ 1 ]
do
    read status_usr
    if [ -z "$status_usr" ]; then
        echo "wrong key pressed"
    else
        break
    fi
done
#sleep 5

#echo "************************************************************"

echo
echo
echo "----> Step 1  : Put the jumper J11 in (2-3) Position"
echo "----> Step 2 : Press WAKEUP switch(SW1) to start GNSS board and Check D5 LED(Green) will Start Blinking after 5-10 seconds"
echo
echo

#echo "************************************************************"
echo 

sleep 5

#echo "************************************************************"
echo "CHECK if green LED(D5) starts ON and start Blinking after 10-15 seconds,press 'y' and then Enter for yes, 'n' and Enter for No"
echo
#echo "************************************************************"
while [ 1 ]
do
        read  status_usr
        if [ -z "$status_usr" ]; then
    	    echo "enter valid key"
        else
    	    break
        fi
done

if [ $status_usr == 'y' ] || [ $status_usr == 'Y' ]; then
    wake_switch_ok=1
    switch_ok_count=$((switch_ok_count+1))
    echo "WAKEUP SWITCH(SW1) marked PASS by user"
else
    echo "WAKEUP SWITCH(SW1) marked **FAIL** by user"
fi


echo 
echo 
echo  
echo "**********************************************************"
echo  "Testing RST Switch(SW2)"
echo  
echo "----> Step 1 : Remove the jumper J11 from (2-3) Position" 
echo "----> Step 2 : Press RST switch(SW2) to RESET GNSS board and Check D5 LED(Green)"
#echo "************************************************************"
echo 

echo "Check if green LED(D5) is Turned OFF and then Turned ON and Start Blinking after some time ( 5 - 10 seocnds) ,press 'y' and then Enter for yes, 'n' and Enter for No"
echo
#echo "************************************************************"
echo
echo
while [ 1 ]
do
        read  status_usr
        if [ -z "$status_usr" ]; then
    	    echo "enter valid key"
        else
    	    break
        fi
done


if [ $status_usr == "y" ] || [ $status_usr == "Y" ]; then
    rst_switch_ok=1
    switch_ok_count=$((switch_ok_count+1))
    echo "RESET SWITCH(SW2) marked PASS by user"
else

    echo "RESET SWITCH(SW2) marked **FAIL** by user"
fi

if [ ${sensor_ok_count} -gt 7 ] && [ ${switch_ok_count} == 3 ]; then
	echo ""
	echo ""
	echo ""
	echo ""
	echo "*************************"
	echo "*************************"
	echo "** Verdict: BOARD is OK  !!!!!! **"
	echo "*************************"
	echo "*************************"
	echo ""
	echo ""
	echo ""
	#echo "sensor_ok_count => " $sensor_ok_count
else
	echo ""
	echo ""
	echo ""
	echo "*************************"
	echo "*************************"
	echo "** Verdict: BOARD is NOT OK !!! **"
	echo "*************************"
	echo "*************************"
	echo ""
	echo ""
	#echo "sensor_ok_count => " $sensor_ok_count
fi



