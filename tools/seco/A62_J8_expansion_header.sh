#!/bin/bash


#------------------------------------------------------#
#			   PARAMETRI   			#
#------------------------------------------------------#

CROSS_COMPILER="/opt/yocto/fsl-release-bsp/build_seco_5.2/tmp/sysroots/x86_64-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-"

OUTPUT_DTS="imx6qdl-seco_SBC_A62_J8.dtsi"		# file che creerà lo script (solo filename, senza il path)

# Valori di default per i menù contestuali dell'utilizzo dei vari gruppi di PIN (Port_Number)
DEFAULT_GROUP_1=1	
DEFAULT_GROUP_2=1
DEFAULT_GROUP_3=1
DEFAULT_GROUP_4=1
DEFAULT_GROUP_5=1
DEFAULT_GROUP_6=2
DEFAULT_GROUP_7=1
DEFAULT_GROUP_8=1
DEFAULT_GROUP_9=1


#------------------------------------------------------#
#			   COSTANTI   			#
#------------------------------------------------------#

KERNEL_BASE_DIR="../../"					
OUTPUT_DIR="arch/arm/boot/dts"	

A62_DL_DTS="imx6dl-seco_SBC_A62.dts"	
A62_DL_DTB="imx6dl-seco_SBC_A62.dtb"	

A62_QUAD_DTS="imx6q-seco_SBC_A62.dts"	
A62_QUAD_DTB="imx6q-seco_SBC_A62.dtb"	

# Controllo parametri

aux=${KERNEL_BASE_DIR:${#KERNEL_BASE_DIR}-1}
if [ $aux == '/' ]; then
    KERNEL_BASE_DIR=${KERNEL_BASE_DIR:0:${#KERNEL_BASE_DIR}-1}
fi

aux=${OUTPUT_DIR:${#OUTPUT_DIR}-1}
if [ $aux == '/' ]; then
    OUTPUT_DIR=${OUTPUT_DIR:0:${#OUTPUT_DIR}-1}
fi

OUTPUT_DIR="${KERNEL_BASE_DIR}/${OUTPUT_DIR}"

#------------------------------------------------------#
#			   FUNZIONI   			#
#------------------------------------------------------#





include_dts(){ 
	path=$1
	inserimento="#include \"${OUTPUT_DTS}\" "
	ricerca="#include \"imx6qdl-seco_SBC_A62.dtsi\""

	exist=$(grep -Fn "$inserimento" $path | wc -l ) 
	if [ "$exist" -eq 0 ]; then
		last_line=$(grep "$ricerca" ${path} )
		new_line="${last_line} \n${inserimento}"
		sed -i  "/imx6qdl-seco_SBC_A62.dtsi/c\ $new_line" $path
	fi	
}



create_dts(){
	path=${OUTPUT_DIR}/${OUTPUT_DTS}	
	
pinmux ${path}
echo "
/*  __________________________________________________________________________
 * |________________________________ UART ____________________________________|
 */
 

	&uart1 {status=\"${UART1}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_uart1>;};
">> $path




if [ "$UART4" == "okay" ]; then
	echo -e "
	&uart4 {status=\"${UART4}\";
		pinctrl-names = \"default\";
		pinctrl-0 =<&pinctrl_uart4_1>; };\n
	">> $path
fi
if [ "$UART4_FLOW_CONTROL" == "okay" ]; then
	echo -e "
	&uart4 {status=\"${UART4_FLOW_CONTROL}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_uart4_2>; 
		fsl,uart-has-rtscts; };\n
	">> $path
fi


if [ "$UART5" == "okay" ]; then
	echo -e "
	&uart5 {status=\"${UART5}\";
		pinctrl-names = \"default\";
		pinctrl-0 =<&pinctrl_uart5_1>; };\n
	">> $path
fi
if [ "$UART5_FLOW_CONTROL" == "okay" ]; then
	echo -e "
	&uart5 {status=\"${UART5_FLOW_CONTROL}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_uart5_2>; 
		fsl,uart-has-rtscts;};\n
	">> $path
fi
	


echo -e "	

/*  __________________________________________________________________________
 * |_________________________________ I2C ____________________________________|
 */
	&i2c1 {status=\"${I2C1}\";
		clock-frequency = <100000>;
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_i2c1>;};\n
	&i2c3 {status=\"${I2C3}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_i2c3>; };

/*  __________________________________________________________________________
 * |_________________________________ SPI ____________________________________|
 */
	
	&ecspi2 {status=\"${SPI2}\";
		fsl,spi-num-chipselects = <1>;
		cs-gpios = <&gpio3 24  0>;
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_ecspi2>; };

/*  __________________________________________________________________________
 * |_________________________________ CAN ____________________________________|
 */

	&can1 { status=\"${CAN1}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_flexcan1>; };	/* CAN1 */\n
	&can2 { status=\"${CAN2}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_flexcan2>; };	/* CAN2 */

/*  __________________________________________________________________________
 * |_________________________________ SDIO ___________________________________|
 */
	&usdhc1 { status=\"${SDIO1}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_usdhc1>; };
/*  __________________________________________________________________________
 * |________________________________ SPDIF ___________________________________|
 */
	&spdif { status=\"${SPDIF}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_spdif>; };
/*  __________________________________________________________________________
 * |_________________________________ PWM ____________________________________|
 */
	&pwm2 {pinctrl-names = \"default\";
		status=\"${PWM_2}\"; 
		pinctrl-0 = <&pinctrl_pwm2>; };\n
	&pwm3 { status=\"${PWM_3}\";
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_pwm3>; };\n		
	&pwm4 { status=\"${PWM_4}\"; 
		pinctrl-names = \"default\";
		pinctrl-0 = <&pinctrl_pwm4>; };


/*  __________________________________________________________________________
 * |_________________________________ GPIO ___________________________________|
 */

/*
	/ {
	GPIO1_09 {gpios=<&gpio1 9 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_09}\";};\n
	GPIO2_25 {gpios=<&gpio2 25 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO2_25}\"; };\n
	GPIO2_23 {gpios=<&gpio2 23 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO2_23}\"; };\n
	GPIO2_24 {gpios=<&gpio2 24 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO2_24}\"; };\n
	GPIO3_24 {gpios=<&gpio3 24 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO3_24}\"; };\n
	GPIO1_07 {gpios=<&gpio1 7 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_07}\"; };\n
	GPIO1_08 {gpios=<&gpio1 8 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_08}\"; };\n
	GPIO6_03 {gpios=<&gpio6 3 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO6_03}\"; };\n
	GPIO5_30 {gpios=<&gpio5 30 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO5_30}\"; };\n
	GPIO6_02 {gpios=<&gpio6 2 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO6_02}\"; };\n
	GPIO5_31 {gpios=<&gpio5 31 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO5_31}\"; };\n
	GPIO3_28 {gpios=<&gpio3 28 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO3_28}\"; };\n
	GPIO3_21 {gpios=<&gpio3 21 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO3_21}\"; };\n
	GPIO4_05 {gpios=<&gpio4 5 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO4_05}\"; };\n
	GPIO1_18 {gpios=<&gpio1 18 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_18}\"; };\n
	GPIO1_20 {gpios=<&gpio1 20 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_20}\"; };\n
	GPIO1_16 {gpios=<&gpio1 16 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_16}\"; };\n
	GPIO1_17 {gpios=<&gpio1 17 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_17}\"; };\n
	GPIO1_19 {gpios=<&gpio1 19 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_19}\"; };\n
	GPIO1_21 {gpios=<&gpio1 21 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_21}\"; };\n
	GPIO7_11 {gpios=<&gpio7 11 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_03}\"; };\n
	GPIO1_03 {gpios=<&gpio1 3 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO1_03}\"; };\n
	GPIO5_29 {gpios=<&gpio5 29 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO5_29}\"; };\n
	GPIO5_28 {gpios=<&gpio5 28 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO5_28}\"; };\n
	GPIO6_01 {gpios=<&gpio6 1 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO6_01}\"; };\n
	GPIO6_00 {gpios=<&gpio6 0 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO6_00}\"; };\n
	GPIO4_14 {gpios=<&gpio4 14 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO4_14}\"; };\n
	GPIO4_15 {gpios=<&gpio4 15 GPIO_ACTIVE_HIGH>;
		   status=\"${GPIO4_15}\"; };\n
	};
*/
" >> $path

}


pinmux() {

echo "
/*  __________________________________________________________________________
 * |_______________________________ IOMUXC ___________________________________|
 */


&iomuxc {
//		pinctrl-names = \"default\";
//		pinctrl-0 = <&pinctrl_hog>;
	imx6qdl-SBC_A62 {
		/* UART */
		pinctrl_uart1: uart1grp
			{
			 fsl,pins = <
				MX6QDL_PAD_CSI0_DAT11__UART1_RX_DATA	0x1b0b1
				MX6QDL_PAD_CSI0_DAT10__UART1_TX_DATA	0x1b0b1
				//MX6QDL_PAD_EIM_D20__GPIO3_IO20	0x4000b0b1	// @@@@@@@ per RS-485
				>;
			};

		pinctrl_uart4_1: uart4grp-1
			{
			 fsl,pins = <
				MX6QDL_PAD_CSI0_DAT13__UART4_RX_DATA	0x1b0b1
				MX6QDL_PAD_CSI0_DAT12__UART4_TX_DATA	0x1b0b1
				>;
			};
		pinctrl_uart4_2: uart4grp-2
			{
			fsl,pins = <
				MX6QDL_PAD_CSI0_DAT17__UART4_CTS_B		0x1b0b1
				MX6QDL_PAD_CSI0_DAT16__UART4_RTS_B		0x1b0b1
				MX6QDL_PAD_CSI0_DAT13__UART4_RX_DATA	0x1b0b1
				MX6QDL_PAD_CSI0_DAT12__UART4_TX_DATA	0x1b0b1
				>;
			};				

		pinctrl_uart5_1: uart5grp-1
			{
			 fsl,pins = <
				MX6QDL_PAD_CSI0_DAT15__UART5_RX_DATA	0x1b0b1
				MX6QDL_PAD_CSI0_DAT14__UART5_TX_DATA	0x1b0b1
				>;
			};
		pinctrl_uart5_2: uart5grp-2
			{
			 fsl,pins = <
				MX6QDL_PAD_KEY_ROW4__UART5_CTS_B	0x1b0b1  /* UART5_CTS */
				MX6QDL_PAD_KEY_COL4__UART5_RTS_B	0x1b0b1  /* UART5_RTS */
				MX6QDL_PAD_CSI0_DAT15__UART5_RX_DATA	0x1b0b1
				MX6QDL_PAD_CSI0_DAT14__UART5_TX_DATA	0x1b0b1
				>;
			};				
			
		/* PWM */
		pinctrl_pwm2: pwm2grp
			{
			fsl,pins = <
				MX6QDL_PAD_SD1_DAT2__PWM2_OUT	0x1b0b1
				>;
			};

		pinctrl_pwm3: pwm3grp 
			{
			fsl,pins = <
				MX6QDL_PAD_SD1_DAT1__PWM3_OUT	0x1b0b1
				>;
			};

		pinctrl_pwm4: pwm4grp {
			fsl,pins = <
				MX6QDL_PAD_SD1_CMD__PWM4_OUT	0x1b0b1
				>;
			};
			
		/* SPI2 */
		pinctrl_ecspi2: ecspi2grp {
			fsl,pins = <
				MX6QDL_PAD_EIM_OE__ECSPI2_MISO	0x100b1
				MX6QDL_PAD_EIM_CS1__ECSPI2_MOSI	0x100b1
				MX6QDL_PAD_EIM_CS0__ECSPI2_SCLK	0x100b1
				MX6QDL_PAD_EIM_D24__GPIO3_IO24	0x80000000 //  CS SPI
				
				>;
			};

		/* CAN */
		pinctrl_flexcan1: flexcan1grp {
			fsl,pins = <
				MX6QDL_PAD_GPIO_8__FLEXCAN1_RX	0x80000000
				MX6QDL_PAD_GPIO_7__FLEXCAN1_TX	0x80000000
				>;
			};

		pinctrl_flexcan2: flexcan2grp {
			fsl,pins = <
				MX6QDL_PAD_KEY_COL4__FLEXCAN2_TX	0x80000000 // 0x1b0b1
				MX6QDL_PAD_KEY_ROW4__FLEXCAN2_RX	0x80000000 // 0x1b0b1
				>;
			};
			
		/* I2C */
		pinctrl_i2c1: i2c1grp
			{
			fsl,pins = <
				MX6QDL_PAD_EIM_D21__I2C1_SCL	0x4001b8b1
				MX6QDL_PAD_EIM_D28__I2C1_SDA	0x4001b8b1
				>;
			};

		pinctrl_i2c3: i2c3grp
			{
			fsl,pins = <
				MX6QDL_PAD_GPIO_3__I2C3_SCL		0x4001b8b1
				MX6QDL_PAD_GPIO_16__I2C3_SDA	0x4001b8b1
				>;
			};	
			
		/* SPDIF */
		pinctrl_spdif: spdifgrp
			{
			fsl,pins = <
				MX6QDL_PAD_EIM_D21__SPDIF_IN	0x1b0b0
				MX6QDL_PAD_GPIO_19__SPDIF_OUT	0x1b0b0
				>;
			};
			
		/* SDIO1 */
		pinctrl_usdhc1: usdhc1grp
			{
			fsl,pins = <
				MX6QDL_PAD_SD1_CMD__SD1_CMD		0x17059
				MX6QDL_PAD_SD1_CLK__SD1_CLK		0x17059
				MX6QDL_PAD_SD1_DAT0__SD1_DATA0	0x17059
				MX6QDL_PAD_SD1_DAT1__SD1_DATA1	0x17059
				MX6QDL_PAD_SD1_DAT2__SD1_DATA2	0x17059
				MX6QDL_PAD_SD1_DAT3__SD1_DATA3	0x17059	
				>;
			};
	
		pinctrl_hog: hoggrp {
			fsl,pins = <
				/*  Enable  */
				MX6QDL_PAD_CSI0_DAT18__GPIO6_IO04	0x1f071
			
				/*  Reset  */
				MX6QDL_PAD_CSI0_DAT19__GPIO6_IO05	0x1f071
			
				/*  PWR CONTROLLER  */
				MX6QDL_PAD_NANDF_D4__GPIO2_IO04	0x1f071
				MX6QDL_PAD_CSI0_MCLK__CCM_CLKO1	0x130b0
				
				/*  LVDS  */
				MX6QDL_PAD_GPIO_4__GPIO1_IO04	0x1f071
				MX6QDL_PAD_GPIO_2__GPIO1_IO02	0x1f071

		/* GPIO */
" > $path

if [ "$GPIO1_09" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_GPIO_9__GPIO1_IO09\t0x4000b0b1" >> $path
fi 
if [ "$GPIO2_25" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_EIM_OE__GPIO2_IO25\t0x4000b0b1" >> $path
fi 
if [ "$GPIO2_23" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_EIM_CS0__GPIO2_IO23\t0x4000b0b1" >> $path
fi 
if [ "$GPIO2_24" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_EIM_CS1__GPIO2_IO24\t0x4000b0b1" >> $path	
fi
if [ "$GPIO3_24" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_EIM_D24__GPIO3_IO24\t0x4000b0b1" >> $path		# revA
	echo -e "\t\t\t MX6QDL_PAD_EIM_D29__GPIO3_IO29\t0x4000b0b1" >> $path		# revB
fi
if [ "$GPIO1_07" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_GPIO_7__GPIO1_IO07\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_08" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_GPIO_8__GPIO1_IO08\t0x4000b0b1" >> $path
fi
if [ "$GPIO6_03" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT17__GPIO6_IO03\t0x4000b0b1" >> $path
fi
if [ "$GPIO5_30" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT12__GPIO5_IO30\t0x4000b0b1" >> $path
fi
if [ "$GPIO6_02" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT16__GPIO6_IO02\t0x4000b0b1" >> $path
fi
if [ "$GPIO5_31" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT13__GPIO5_IO31\t0x4000b0b1" >> $path
fi
if [ "$GPIO3_28" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_EIM_D28__GPIO3_IO28\t0x4000b0b1" >> $path
fi
if [ "$GPIO3_21" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_EIM_D21__GPIO3_IO21\t0x4000b0b1" >> $path
fi
if [ "$GPIO4_05" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_GPIO_19__GPIO4_IO05\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_18" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_SD1_CMD__GPIO1_IO18\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_20" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_SD1_CLK__GPIO1_IO20\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_16" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_SD1_DAT0__GPIO1_IO16\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_17" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_SD1_DAT1__GPIO1_IO17\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_19" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_SD1_DAT2__GPIO1_IO19\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_21" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_SD1_DAT3__GPIO1_IO21\t0x4000b0b1" >> $path
fi
if [ "$GPIO7_11" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_GPIO_16__GPIO7_IO11\t0x4000b0b1" >> $path
fi
if [ "$GPIO1_03" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_GPIO_3__GPIO1_IO03\t0x4000b0b1" >> $path
fi
if [ "$GPIO5_29" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT11__GPIO5_IO29\t0x4000b0b1" >> $path
fi
if [ "$GPIO5_28" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT10__GPIO5_IO28\t0x4000b0b1" >> $path
fi
if [ "$GPIO6_01" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_CSI0_DAT15__GPIO6_IO01\t0x4000b0b1" >> $path
fi
if [ "$GPIO6_00" == "okay" ]; then
	echo -e "\t\t MX6QDL_PAD_CSI0_DAT14__GPIO6_IO00\t0x4000b0b1" >> $path
fi
if [ "$GPIO4_14" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_KEY_COL4__GPIO4_IO14\t0x4000b0b1" >> $path
fi
if [ "$GPIO4_15" == "okay" ]; then
	echo -e "\t\t\t MX6QDL_PAD_KEY_ROW4__GPIO4_IO15\t0x4000b0b1" >> $path
fi

echo "				>;
			};	
		};	// di imx6qdl-SBC_A62
	};	// di iomuxc

" >> $path

}




#------------------------------------------------------#
#	SELEZIONE DELLA CONFIGURAZIONE DESIDERATA	#
#------------------------------------------------------#


Group_1=${DEFAULT_GROUP_1}		# inizializzo a default value
Group_2=${DEFAULT_GROUP_2}		# inizializzo a default value
Group_3=${DEFAULT_GROUP_3}		# inizializzo a default value
Group_4=${DEFAULT_GROUP_4}		# inizializzo a default value
Group_5=${DEFAULT_GROUP_5}		# inizializzo a default value
Group_6=${DEFAULT_GROUP_6}		# inizializzo a default value
Group_7=${DEFAULT_GROUP_7}		# inizializzo a default value
Group_8=${DEFAULT_GROUP_8}		# inizializzo a default value
Group_9=${DEFAULT_GROUP_9}		# inizializzo a default value



top_menu=0	

	top_menu_exitstatus=0
	while [ "$top_menu_exitstatus" -eq 0 ]; do
		top_menu=$(whiptail --title " J8's Port Group Configuration" \
			--default-item "$top_menu" \
			--menu "Press <ESC> to quit without save" 21 60 9 \
			--ok-button "ENTER" \
			--cancel-button "NEXT" \
			"1" "Port 1" \
			"2" "Port 2" \
			"3" "Port 3" \
			"4" "Port 4" \
			"5" "Port 5" \
			"6" "Port 6" \
			"7" "Port 7" \
			"8" "Port 8" \
			"9" "Port 9-10"  3>&1 1>&2 2>&3)
		top_menu_exitstatus=$?
		if [ $top_menu_exitstatus -eq 0 ]; then
			case $top_menu in
				1)
					declare -a value=("1 x GPIO")


					declare -a stato=()

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do

						if [ "$Group_1" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi

						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
					
					Group_1=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_1=${DEFAULT_GROUP_1}	
					fi
				;;

				2)	
					declare -a value=("4 x GPIO" "1 x SPI")

					
					declare -a stato=()		

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						
						if [ "$Group_2" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi
						
						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_2=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then		
						Group_2=${DEFAULT_GROUP_2}		
					fi
				;;

				3)
					declare -a value=("2 x GPIO" "1 x CAN")


					declare -a stato=()	

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do

						if [ "$Group_3" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi

						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_3=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_3=${DEFAULT_GROUP_3}		
					fi
				;;
	
				4)	
					declare -a value=("4 x GPIO" "1 x UART CTS/RTS" "2 x GPIO + 1 x UART")	


					declare -a stato=()	

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						if [ "$Group_4" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi
						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_4=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_4=${DEFAULT_GROUP_4}	
					fi
				;;
			
				5)	
					declare -a value=("3 x GPIO" "1 x GPIO + 1 x I2C" "1 x GPIO + 1 x SPDIF")

					
					declare -a stato=()	

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						
						if [ "$Group_5" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi

						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_5=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then		
						Group_5=${DEFAULT_GROUP_5}	
					fi
				;;
				
				6)	
					declare -a value=("1 x SDIO" "6 x GPIO" "5 x GPIO + 1 x PWM" "4 x GPIO + 2 x PWM" "3 x GPIO + 3 x PWM")

					declare -a stato=()	

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						if [ "$Group_6" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi
						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_6=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_6=${DEFAULT_GROUP_6}		
					fi
				;;
				
				7)	
					declare -a value=("2 x GPIO" "1 x I2C")	
					
					declare -a stato=()		

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						
						if [ "$Group_7" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi
						
						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_7=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_7=${DEFAULT_GROUP_7}	
					fi
				;;
				
				8)	
					declare -a value=("2 x GPIO" "1 x UART")	

					
					declare -a stato=()	

					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						if [ "$Group_8" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi
						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_8=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_8=${DEFAULT_GROUP_8}	
					fi
				;;
				
				9)	
					declare -a value=("4 x GPIO" "2 x GPIO + 1 x CAN" "2 x GPIO + UART" "1 x UART CTS/RTS" "1 x CAN + 1 x UART")

					declare -a stato=()	
					lunghezza=${#value[@]}
					RADIOLIST=()
					for ((i=0; i<${lunghezza}; i++))
					do
						if [ "$Group_9" == "$(($i + 1 ))" ];then 
							stato[${i}]="ON"
						else
							stato[${i}]="OFF"
						fi
						RADIOLIST+=("$(($i + 1 ))" "${value[$i]}" "${stato[$i]}")
					done
				
					Group_9=$(whiptail --title " J8's option for Group ${top_menu} " --radiolist "Choose configuration for Pin Group ${top_menu}\n<ESC> will reset default value" 15 60 $lunghezza \
					--nocancel \
					"${RADIOLIST[@]}" 3>&1 1>&2 2>&3)
					exitstatus=$?
					if [ "$exitstatus" -eq 255 ]; then	
						Group_9=${DEFAULT_GROUP_9}	
					fi
				;;

			esac

		else
			if [ "$top_menu_exitstatus" -eq 255 ]; then	
				clear
				echo ""
				echo "---------------------"
				echo " Exit without saving"
				echo "---------------------"
				echo ""
				exit 1
			else
				break
			fi
		fi
	done


#------------------------------------------------------#
#		PREPARAZIONE DELLE VARIABILI		#
#------------------------------------------------------#


# Gruppo 1
case $Group_1 in
	1)	# 1x GPIO
		GPIO1_09="okay"
	;;
esac

# Gruppo 2
case $Group_2 in	# ("4 x GPIO" "1 x SPI")	
	1)	# "4 x GPIO"
		GPIO2_25="okay"
		GPIO2_23="okay"
		GPIO2_24="okay"
		GPIO3_24="okay"
		SPI2="disabled"		
	;;
	2)	# "1 x SPI"
		GPIO2_25="disabled"
		GPIO2_23="disabled"
		GPIO2_24="disabled"
		GPIO3_24="disabled"
		SPI2="okay"
	;;
esac

# Gruppo 3
case $Group_3 in
	1)	# "2 x GPIO"
		GPIO1_07="okay"
		GPIO1_08="okay"
		CAN1="disabled"
	;;
	2)	# "1 x CAN"
		GPIO1_07="disabled"
		GPIO1_08="disabled"
		CAN1="okay"
	;;
esac

# Gruppo 4
case $Group_4 in
	1)	# "4 x GPIO"
		GPIO6_03="okay"
		GPIO5_30="okay"
		GPIO6_02="okay"
		GPIO5_31="okay"
		UART4="disabled"
		UART4_FLOW_CONTROL="disabled"
	;;
	2)	# "1 x UART CTS/RTS"
		GPIO6_03="disabled"
		GPIO5_30="disabled"
		GPIO6_02="disabled"
		GPIO5_31="disabled"
		UART4="disabled"
		UART4_FLOW_CONTROL="okay"
	;;
	3)	# "2 x GPIO + 1 x UART"
		GPIO6_03="okay"
		GPIO5_30="disabled"
		GPIO6_02="okay"
		GPIO5_31="disabled"
		UART4="okay"
		UART4_FLOW_CONTROL="disabled"
	;;
esac

# Gruppo 5
case $Group_5 in
	1)	# "3 x GPIO"
		GPIO3_28="okay"
		GPIO3_21="okay"
		GPIO4_05="okay"
		SPDIF="disabled"
		I2C1="disabled"
	;;
	2)	#  "1 x GPIO + 1 x I2C"
		GPIO3_28="disabled"
		GPIO3_21="disabled"
		GPIO4_05="okay"
		SPDIF="disabled"
		I2C1="okay"
	;;
	3)	#  "1 x GPIO + 1 x SPDIF"
		GPIO3_28="okay"
		GPIO3_21="disabled"
		GPIO4_05="disabled"
		SPDIF="okay"
		I2C1="disabled"
	;;
esac

# Gruppo 6
case $Group_6 in
	1)	# "1 x SDIO" 
		GPIO1_18="disabled"
		GPIO1_20="disabled"
		GPIO1_16="disabled"
		GPIO1_17="disabled"
		GPIO1_19="disabled"
		GPIO1_21="disabled"
		PWM_4="disabled"
		PWM_3="disabled"
		PWM_2="disabled"
		SDIO1="okay"
	;;
	2)	# "6 x GPIO" 
		GPIO1_18="okay"
		GPIO1_20="okay"
		GPIO1_16="okay"
		GPIO1_17="okay"
		GPIO1_19="okay"
		GPIO1_21="okay"
		PWM_4="disabled"
		PWM_3="disabled"
		PWM_2="disabled"
		SDIO1="disabled"
	;;
	3)	# "5 x GPIO + 1 x PWM" 
		GPIO1_18="okay"
		GPIO1_20="okay"
		GPIO1_16="okay"
		GPIO1_17="okay"
		GPIO1_19="disabled"
		GPIO1_21="okay"
		PWM_4="disabled"
		PWM_3="disabled"
		PWM_2="okay"
		SDIO1="disabled"
	;;
	4)	# "4 x GPIO + 2 x PWM"
		GPIO1_18="okay"
		GPIO1_20="okay"
		GPIO1_16="okay"
		GPIO1_17="disabled"
		GPIO1_19="disabled"
		GPIO1_21="okay"
		PWM_4="disabled"
		PWM_3="okay"
		PWM_2="okay"
		SDIO1="disabled"
	;;
	5)	# "3 x GPIO + 3 x PWM"
		GPIO1_18="disabled"
		GPIO1_20="okay"
		GPIO1_16="okay"
		GPIO1_17="disabled"
		GPIO1_19="disabled"
		GPIO1_21="okay"
		PWM_4="okay"
		PWM_3="okay"
		PWM_2="okay"
		SDIO1="disabled"
	;;
esac

# Gruppo 7
case $Group_7 in
	1)	# "2 x GPIO" 
		GPIO7_11="okay"
		GPIO1_03="okay"
		I2C3="disabled"
	;;
	2)	# "1 x I2C"
		GPIO7_11="disabled"
		GPIO1_03="disabled"
		I2C3="okay"
	;;
esac

# Gruppo 8
case $Group_8 in
	1)	# "2 x GPIO"
		GPIO5_29="okay"
		GPIO5_28="okay"
		UART1="disabled"
	;;
	2)	# "1 x UART"
		GPIO5_29="disabled"
		GPIO5_28="disabled"
		UART1="okay"
	;;
esac

# Gruppo 9-10
case $Group_9 in
	1)	# "4 x GPIO"
		GPIO6_01="okay"
		GPIO6_00="okay"
		GPIO4_14="okay"
		GPIO4_15="okay"
		CAN2="disabled"
		UART5="disabled"
		UART5_FLOW_CONTROL="disabled"
	;;
	2)	#  "2 x GPIO + 1 x CAN"
		GPIO6_01="okay"
		GPIO6_00="okay"
		GPIO4_14="disabled"
		GPIO4_15="disabled"
		CAN2="okay"
		UART5="disabled"
		UART5_FLOW_CONTROL="disabled"
	;;
	3)	# "2 x GPIO + UART" 
		GPIO6_01="disabled"
		GPIO6_00="disabled"
		GPIO4_14="okay"
		GPIO4_15="okay"
		CAN2="disabled"
		UART5="okay"
		UART5_FLOW_CONTROL="disabled"
	;;
	4)	# "1 x UART CTS/RTS"
		GPIO6_01="disabled"
		GPIO6_00="disabled"
		GPIO4_14="disabled"
		GPIO4_15="disabled"
		CAN2="disabled"
		UART5="disabled"
		UART5_FLOW_CONTROL="okay"		
	;;
	5)	
		GPIO6_01="disabled"
		GPIO6_00="disabled"
		GPIO4_14="disabled"
		GPIO4_15="disabled"
		CAN2="okay"
		UART5="okay"
		UART5_FLOW_CONTROL="disabled"	
	;;
	
esac




#------------------------------------------------------#
#	CREAZIONE DEI FILE DI OUTPUT .dts e .dtb		#
#------------------------------------------------------#



# Creazione dts
#if [ -f "${OUTPUT_DIR}/${OUTPUT_DTS}" ]; then
#	Messaggio1="A backup will be stored in \n${OUTPUT_DIR}/${OUTPUT_DTS}_backup"
#	Sovrascritto1="=> ${OUTPUT_DIR}/${OUTPUT_DTS}"
#fi

Sovrascritto2=""
Messaggio2=""

if (whiptail --title "Saving the .dts?" --yes-button "NEXT" --no-button "EXIT"  --yesno "Save the .dts destination file?\n Note that the following file will be overwritted: \n  ${Sovrascritto1}\n  ${Sovrascritto2} \n\n${Messaggio1}\n\n${Messaggio2}" 20 60) then

#	if [ -f "${OUTPUT_DIR}/${OUTPUT_DTS}" ]; then
#		#cp -rf ${OUTPUT_DIR}/${OUTPUT_DTS} ${OUTPUT_DIR}/${OUTPUT_DTS}_backup
#		if [ "$?" -ne "0" ];then
#			echo ""
#			echo "----------------------------------"
#			echo " Cannot create a backup copy of"
#			echo "${OUTPUT_DIR}/${OUTPUT_DTS}"
#			echo "Exit in order to prevent data lost"
#			echo "----------------------------------"
#			echo ""
#			exit 1
#		fi
#	fi

	create_dts	
	include_dts ${OUTPUT_DIR}/${A62_QUAD_DTS}	
	include_dts ${OUTPUT_DIR}/${A62_DL_DTS}	
	
	whiptail --title "Files Successfully Created!" --msgbox "\nFiles Successfully Created!" 10 60
else
	clear
	echo ""
	echo "---------------------"
	echo " Exit without saving"
	echo "---------------------"
	echo ""
	exit 1
fi



if (whiptail --title "Compiling the .dtb?" --yes-button "Yes" --no-button "No"  --yesno "Compiling the .dtb file?" 10 60) then
	clear
	echo "Compiling .dtb file . . ."	
	make -C ${KERNEL_BASE_DIR} ARCH=arm CROSS_COMPILE=${CROSS_COMPILER} ${A62_QUAD_DTB} > /dev/null
	make -C ${KERNEL_BASE_DIR} ARCH=arm CROSS_COMPILE=${CROSS_COMPILER} ${A62_DL_DTB} > /dev/null
	
	if [ "$?" -ne "0" ];then
		echo ""
		echo "------------------------------------------"
		echo " Error while compiling .dtb file"
		echo "------------------------------------------"
		echo ""
	else
		echo ""
		echo "------------------------------------------"
		echo " output .dtb file in ${OUTPUT_DIR}/${A62_QUAD_DTB}"
		echo " output .dtb file in ${OUTPUT_DIR}/${A62_DL_DTB}"
		echo "------------------------------------------"
		echo ""
	fi
fi

exit 0

