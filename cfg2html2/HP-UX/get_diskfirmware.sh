# @(#) firmware_collect.sh v1.4 07.11.2008, Martin Kalmbach
# @(#) $Id: get_diskfirmware.sh,v 4.7 2009-03-06 12:21:13 ralproth Exp $
#####################################################################
# Uebernommen von firmware_collect.sh, angepasst auf HPUX11.31
# Script, um die Firmwarerevisionen der Platten auf dem System
# und sonstige wichtige Informationen festzuhalten
# Dieses Script ist NICHT supportet, HP uebernimmt keinerlei Haftung
# fuer Schaeden, die durch dieses Script verursacht werden.
# Martin Kalmbach, HP Services, 29.10.2008
#####################################################################
# History
# -------------------------------------------------------------------
# Revision 1.0 29.10.2008, Kalmbach 
# Revision 1.1 31.10.2008, Kalmbach. Check for non-DSF file usage 
# Revision 1.2 01.11.2008, Kalmbach. Show also inactive LVM usage
# Revision 1.3 03.11.2008, Kalmbach. Check also lvmtab_p for LVM v2
# Revision 1.4 07.11.2008, Kalmbach. Minor Bugfixes
#####################################################################

PATH=/usr/sbin:$PATH
export LANG="C"
TMPFiLE_MARTiN1=$(mktemp -p fwcoll) # /tmp/firmware_collect.tmp.1
TMPFiLE_MARTiN2=$(mktemp -p fwcoll) # /tmp/firmware_collect.tmp.2
if [ -f /etc/lvmtab_p ]
then
  LVMTAB="/etc/lvmtab /etc/lvmtab_p"
else
  LVMTAB="/etc/lvmtab"
fi
PATH=$PATH:/opt/hpvm/bin:/usr/contrib/bin/:/usr/local/bin
INQ=$(which inq)                # EMC inquiry here? (/usr/local/bin?)


#####################################################################
# get the properties of the device (same for dsf and classic devices)
#####################################################################
get_properties()
{
  vendor=`  grep vendor  $TMPFiLE_MARTiN1  | head -1 | awk '{ print $2  }'`
  revision=`grep rev     $TMPFiLE_MARTiN1  | head -1 | awk '{ print $3  }'`
  size=`grep size     $TMPFiLE_MARTiN1  | head -1 | awk '{ printf "%-5.1f", ($2+0.01)/1024/1024  }'`
  scsi=`/usr/sbin/scsictl -akq /dev/r$DEVPREFIX/$device 2>/dev/null`
  sir=`echo $scsi|awk -F";" '{ print $1; }{}'`
  sqd=`echo $scsi|awk -F";" '{ print $2; }{}'`
  vendor_product=$vendor"/"$product             ## EMC/SYMMETRIX

  # Additions, Martin Kalmbach, 29.10.2008
  USAGE=""
  USAGE_EXT=""
  ##############################################################################
  # Check, if device is used in LVM. If yes, then show VG (only if VG is active)
  ##############################################################################
  if (strings $LVMTAB | grep -w $device >/dev/null 2>&1) || (strings $LVMTAB | grep $device$DIVIDER >/dev/null 2>&1)
  then
    ### device exists in lvmtab - so it the usage is LVM
    USAGE="LVM/"
    USAGE_EXT="scripterror"
    ### device is in lvmtab, but VG is not activated   
    DISKFOUND="no";VG=""
    for entry in `strings $LVMTAB`
    do
      if [ $DISKFOUND = "no" ]
      then
        if [ "`echo $entry | cut -d "/" -f 4`" = "" ]
        then
          # lvmtab line is specifying a VG and not a disk
          VG="`echo $entry | cut -d "/" -f 3`"
        else
          # lvmtab line is specifying a disk and not a VG
          if (echo $entry | grep $device >/dev/null 2>&1)
          then
            if (vgdisplay $VG>/dev/null 2>&1)
            then
              VGVERSION=$(vgdisplay $VG 2>/dev/null|grep "VG Version"|awk '{print $3;}')
              [ -n "$VGVERSION" ] || VGVERSION="1.0"
              USAGE_EXT="$VG/v$VGVERSION"        # 1.0, 2.0, 2.1
            else
              USAGE_EXT="$VG,inactive"
            fi
            DISKFOUND=yes
          fi
        fi
      fi
    done
  else
    ##############################################################################
    # Check if a filesystem has been created on the Devicefile (would be strange..)
    ##############################################################################
    if (fstyp /dev/r$DEVPREFIX/$device >/dev/null 2>&1) 
    then
      USAGE=Filesystem/
      USAGE_EXT="`fstyp /dev/r$DEVPREFIX/$device`"
    fi

    ##############################################################################
    # Check if device is used in a HPVM. If yes, then show VM name
    ##############################################################################
    if (hpvmstatus >/dev/null 2>/dev/null)
    then
      VMS=`hpvmstatus 2>/dev/null | grep -v -e "Virtual Machine" -e "=====" | awk '{print $1}'`
      for vm in $VMS
      do
        if (hpvmstatus -P $vm -d | grep disk | grep -w $device >/dev/null 2>&1 ) ||
           (hpvmstatus -P $vm -d | grep disk | grep $device$DIVIDER  >/dev/null 2>&1)
        then
          USAGE="HPVM/"
          USAGE_EXT="$vm"
        fi
      done
    fi
  fi # LVM TAB

    # EMC/Symetricx Serialnumber Diskarray, #  12.1.2009, 11:05  Ralph Roth  
    if [ -x "$INQ" -a "$vendor" = "EMC" ]
    then
        #SNR=$($INQ -dev /dev/r$DEVPREFIX/$device -no_dots | grep /dev/r | awk -F":" '{ print $5; }' )
        SNR=$($INQ -dev /dev/r$DEVPREFIX/$device -no_dots -et | grep ^/dev/r|cut -f2,11 -d":" | tr ":" " "| awk '{ printf("%s/%s", $1,$2); }' )
        #echo $SNR
        USAGE_EXT=$USAGE_EXT"/"$SNR
    fi

  
  WARNMSG="Note: Rawdevice usage is not shown in the Usage column."
}

#####################################################################
# for HPUX < 11.31 : no DSF devices
#####################################################################
hw_disk_check_classic()
{
DEVPREFIX=dsk
DIVIDER=s

DEVICES=`ioscan -fknCdisk | grep -e /r$DEVPREFIX/ | cut -d "/" -f4 | grep -v -e $DIVIDER`  # /dev/cdrom -> dev (bug)!
# 1234567890123456789012345678901234567890123456789012345678901234567890
# 2/0/6/1/0/4/0.60.240.22.0.14.7    c104t14d7 HP/OPEN-V        119 10.0    5001   LVM/vg25
# 2/0/6/1/0/4/0.60.240.22.7.15.7    c105t15d7 HP/OPEN-9-CVS-CM 127 0.0     5001
#printf "\n%-10s%-18s%-6s%-4s%-8s%-7s%-6s%-12s\n" Device Vendor/Product SCSI LUN Cap/GB FWVer Usage 
printf "\n%-34s%-10s%-17s%-4s%-8s%-7s%-6s%-12s\n" Hardwarepath Device Vendor/Product LUN Cap/GB FWVer Usage 
echo "-----------------------------------------------------------------------------------------------" 

for device in $DEVICES
do
    if [ -c /dev/r$DEVPREFIX/$device ]          ## /dev/cdrom -> lssf: /dev/dsk/dev: No such file or directory
    then  
      (diskinfo -v /dev/r$DEVPREFIX/$device;diskinfo /dev/r$DEVPREFIX/$device) \
        2> /dev/null | grep -e product -e rev -e vendor -e size > $TMPFiLE_MARTiN1 2> /dev/null
      if [ "$(grep -e 'DVD-ROM' -e 'CD-ROM' -e 'DISK-SUBS' -e ' 0 Kbyte' $TMPFiLE_MARTiN1)" = "" ]
      then
         hw_pfad=` lssf /dev/$DEVPREFIX/$device  | awk '{ print $(NF-1) }'`
         product=` grep product $TMPFiLE_MARTiN1  | head -1 | awk '{ print $3  }'`
         if [ -n "$product"  ] 
         then
           get_properties
           ##############################################################################
           # Check the LUN Number (decimal)
           ##############################################################################
           SCSITGTLUN="t`echo $device | cut -d t -f 2`"
           SCSITGT=`echo $device| cut -d t -f 2 | cut -d d -f 1|awk '{print $1+0}'`
           SCSILUN=`echo $device| cut -d t -f 2 | cut -d d -f 2|awk '{print $1+0}'`
           ((LUNDEC1=$SCSITGT*8+$SCSILUN))
    
           printf "%-34s%-10s%-17s%-4s%-8s%-7s%-4s%-12s\n" \
                   $hw_pfad $device $vendor_product $LUNDEC1 $size $revision $USAGE $USAGE_EXT
     
         fi
      fi
fi
done
echo "-------------------------------------------------------------------------------------------------" 
echo $WARNMSG

}

#####################################################################
# for HPUX >= 11.31 : with DSF devices
#####################################################################
hw_disk_check_dsf()
{
DEVPREFIX=disk
DIVIDER=_
DEVICES=`ioscan -fkNnCdisk | grep -e /r$DEVPREFIX/ | cut -d "/" -f4 | grep -v $DIVIDER `

printf "\n%-10s%-18s%-6s%-4s%-8s%-7s%-6s%-4s%-12s\n" Device Vendor/Product SCSI LUN Cap/GB FWVer Paths Usage 
echo "------------------------------------------------------------------------------------" 

for device in $DEVICES
do 
  (diskinfo -v /dev/r$DEVPREFIX/$device;diskinfo /dev/r$DEVPREFIX/$device) \
    2> /dev/null | grep -e product -e rev -e vendor -e size > $TMPFiLE_MARTiN1 2> /dev/null
  if [ "$(grep -e 'DVD-ROM' -e 'CD-ROM' -e 'DISK-SUBS' -e ' 0 Kbyte' $TMPFiLE_MARTiN1)" = "" ]
  then
     hw_pfad=` lssf /dev/$DEVPREFIX/$device  | awk '{ print $(NF-1) }'`
     product=` grep product $TMPFiLE_MARTiN1  | head -1 | awk '{ print $3  }'`
     if [ -n "$product"  ] 
     then
       get_properties
       ##############################################################################
       # Check the LUN Number (decimal)
       ##############################################################################
       SCSITGTLUN="t`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep $device | awk '{print $2}' | cut -d t -f 2`"
       SCSITGT=`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep $device | awk '{print $2}' | cut -d t -f 2 | cut -d d -f 1|awk '{printf "%d", $1+0.0}'`
       SCSILUN=`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep $device | awk '{print $2}' | cut -d t -f 2 | cut -d d -f 2|awk '{printf "%d", $1+0.0}'`
       if [ -z "$SCSITGT" -o -z "$SCSILUN" ]
       then
                LUNDEC2="--"
                SCSITGTLUN="!LDSF"
       else         
                ((LUNDEC2=$SCSITGT*8+$SCSILUN))
       fi         
       ##############################################################################
       # Check how many pathes the DSF device has
       ##############################################################################
       PATHES=`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep -v -e "Persis" -e "=====" | wc -l`

       printf "%-10s%-18s%-6s%-4s%-8s%-7s%-6s%-4s%-12s\n" \
               $device $vendor_product $SCSITGTLUN $LUNDEC2 $size $revision $PATHES $USAGE $USAGE_EXT
 
     fi
  fi 
done
echo "------------------------------------------------------------------------------------" 
echo $WARNMSG

}


UX=`uname -r | cut -d "." -f 3`

if [ $UX -ge 31 ]
then
  ### 11.31 and higher #########################################################
  hw_disk_check_dsf
  hw_disk_check_classic > $TMPFiLE_MARTiN2
  if [ `grep -e LVM/ -e HPVM/ -e Filesystem/ $TMPFiLE_MARTiN2 | wc -l` -ne 0 ]
  then
    echo "\nWARNING!!! The following non-DSF Devices are in use. You should rather use DSF devices!"
    printf "%-34s%-10s%-17s%-4s%-8s%-7s%-6s%-12s\n" Hardwarepath Device Vendor/Product LUN Cap/GB FWVer Usage 
    echo "--------------------------------------------------------------------------------------------" 
    grep -e LVM/ -e HPVM/ -e Filesystem/ $TMPFiLE_MARTiN2
    #rm $TMPFiLE_MARTiN2
  fi
else
  ### 11.23 and lower  #########################################################
  hw_disk_check_classic
fi

# Clear temp. Files
rm -f $TMPFiLE_MARTiN1 $TMPFiLE_MARTiN2 2>/dev/null


#####################################################################
# Ralph Roth, ASO, 18-Aug-1999, major fixes (HPFL etc.)
# Ralph Roth, ASO, 14-Sept-1999, version for cfg2html.sh
# Ralph Roth, 28-March-2000, fixes: /rdsk/, QD+IR added
# Ralph/Martin, 24-July-2000 added disk size in GB
# Martin Kalmbach, 28-July-2000, beautyfied
# Ralph Roth, 9-Nov-2000, fixes for XP256 DISK SUBSYSTEM hangs
# Ralph, 10-Nov-2000, Hopefully the last XP256 fixes?
# Ralph, 14-Nov-2000, XP512 fixes....
#####################################################################

