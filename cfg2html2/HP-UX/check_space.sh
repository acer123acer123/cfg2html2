# Initial version provided 25-Jul-2003 by Martin Kalmbach, ASO SW, HP
# ---------------------------------------------------------------------------
# Seems to have problems under HP-UX 11.31?
# @(#) $Id: check_space.sh,v 4.12 2008-11-13 20:22:56 ralproth Exp $
# $Log: check_space.sh,v $
# Revision 4.12  2008-11-13 20:22:56  ralproth
# cfg4.13: fixes for mywhat utility
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2008/10/24 11:48:18  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.11  2008/10/24 10:48:17  ralproth
# cfg3.72: Fixes for HP-UX 11.31
#
# Revision 3.10.1.1  2004/02/16 09:32:02  ralproth
# Initial 3.x stream import
#
# Revision 2.7  2004/02/16 09:32:02  ralproth
# Updated version provided by martin kalmbach
#
# Revision 2.4  2003/03/11 17:36:07  www
# Latest fixes by Martin Kalmbach
#
# Revision 2.2  2003/03/11 08:09:47  ralproth
# Fixes from Martin Kalmbach
#
# Revision 2.1  2003/03/11 07:59:46  ralproth
# Initial import from Martin's sources
#
FILTER="-v -E 'byte|^DevFS|Filesystem'"
export LANG=C 
PATH=/sbin:/usr/sbin:/usr/bin:$PATH
# set -vx

echo "================================================================"
for vg in `vgdisplay -v 2>/dev/null|awk '$1 == "VG" && $2 == "Name" {print $3}'|sort -u | cut -d "/dev/" -f 3`
do
    vgexport -p -s -m $vg.maps.temp $vg 1>/dev/null 2>&1
    VGID=`head -1 $vg.maps.temp`
    rm $vg.maps.temp
    PESIZE=`  vgdisplay $vg | grep "PE Size"   | awk '{print $4}' `
    MAXPE=`   vgdisplay $vg | grep "Max PE"    | awk '{print $5}' `
    MAXPV=`   vgdisplay $vg | grep "Max PV"    | awk '{print $3}' `
    CURPV=`   vgdisplay $vg | grep "Cur PV"    | awk '{print $3}' `
    ALLPE=`   vgdisplay $vg | grep "Alloc PE"  | awk '{print $3}' `
    FREEPE=`  vgdisplay $vg | grep "Free PE"   | awk '{print $3}' `
    TOTALPE=` vgdisplay $vg | grep "Total PE"  | awk '{print $3}' `
    ((ALLOCMB=$PESIZE*$ALLPE))
    ((TOTALMB=$PESIZE*$TOTALPE))
    ((FREEMB=$PESIZE*$FREEPE))
    ((MAXDISKSIZE=$PESIZE*$MAXPE))
    echo "Volumegroup Informations for $vg ($VGID)"
    echo "PESize=$PESIZE MaxPE=$MAXPE MaxPV=$MAXPV CurPV=$CURPV MaxDiskSize=$MAXDISKSIZE MB"
    echo "----------------------------------------------------------------"
    
    echo "Total capacity in Volumegroup $vg               : $TOTALMB MB"
    echo "Allocated capacity in Volumegroup $vg           : $ALLOCMB MB"
    echo "Unallocated capac. in Volumegroup $vg           : $FREEMB MB"
    erg=0
    for i in `bdf \`vgdisplay -v $vg |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u\` 2>/dev/null|grep $FILTER|grep "%" |grep ^/    |awk '{printf "%ld", $2+0}'; \
              bdf \`vgdisplay -v $vg |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u\` 2>/dev/null|grep $FILTER|grep "%" |grep -v ^/ |awk '{printf "%ld", $1+0}'`
    do
    #    /opt/cfg2html/plugins/check_space.sh[55]: erg=33488896+DevFS: Die angegebene Zahl ist bei diesem Befehl ungültig. 
            ((erg=$erg+$i))
    done
    
    ((erg=$erg/1024))
    ((UNMOUNTEDMB=$ALLOCMB-$erg))
    # echo "Capac. not mounted in Volumegroup $vg           : $UNMOUNTEDMB MB" # doesnt work because of rounding error
    echo "Filesystemcapacity in Volumegroup $vg total     : $erg MB"
    
    
    erg=0
    for i in `bdf \`vgdisplay -v $vg |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u\` 2>/dev/null|grep $FILTER|grep "%" |grep ^/    |awk '{printf "%ld", $3+0}'; \
              bdf \`vgdisplay -v $vg |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u\` 2>/dev/null|grep $FILTER|grep "%" |grep -v ^/ |awk '{printf "%ld", $2+0}'`
    do
            ((erg=$erg+$i))
    done
    ((erg=$erg/1024))
    echo "Filesystemcapacity in Volumegroup $vg used      : $erg MB"
    
    erg=0
    for i in `bdf \`vgdisplay -v $vg |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u\` 2>/dev/null|grep $FILTER|grep "%" |grep ^/    |awk '{printf "%ld", $4+0}'; \
              bdf \`vgdisplay -v $vg |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u\` 2>/dev/null|grep $FILTER|grep "%" |grep -v ^/ |awk '{printf "%ld", $3+0}'`
    do
            ((erg=$erg+$i))
    done
    ((erg=$erg/1024))
    echo "Filesystemcapacity in Volumegroup $vg available : $erg MB"
    echo "================================================================"

done
