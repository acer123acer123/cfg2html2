# @(#) $Id: get_mirror_missmatch.sh,v 4.12 2008-11-13 20:22:56 ralproth Exp $
###########################################################################
# Mirror/UX Missmatch detection utility
# 18.08.2005, 14:18 modified by Ralph Roth
###########################################################################
# $Log: get_mirror_missmatch.sh,v $
# Revision 4.12  2008-11-13 20:22:56  ralproth
# cfg4.13: fixes for mywhat utility
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2008/07/22 18:01:02  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.14  2008/07/22 17:01:01  ralproth
# added sas and mpt plugins
#
# Revision 3.13  2008/07/21 16:54:54  ralproth
# cfg3.68: svn stream: update (check_errors, sgcc etc.)
#
# Revision 3.12  2007/07/02 14:56:29  ralproth
# fixes for HPUX11i v3
#
# Revision 3.11  2005/08/31 13:53:06  ralproth
# added get_lvm_info.sh
#
# Revision 3.10.1.1  2005/08/19 08:31:27  ralproth
# Initial 3.x stream import
#
# Revision 2.1  2005/08/19 08:31:27  ralproth
# added get_mirror_missmatch.sh, last 2.xx stream
#
###########################################################################
# root@hpul80:/samba30/cfg2html/release/plugins> ./get_mirror_missmatch.sh
# Example:
#
# /dev/vg00/lvol1	\
# /dev/vg00/lvol2	|
# /dev/vg00/lvol3	|
# /dev/vg00/lvol5	|
# /dev/vg00/lvol6	|->  perfectly 1:1 mirrored
# /dev/vg00/lvol7	|
# /dev/vg00/lvol8	|
# /dev/vg00/lvol9	/

#  vvvvvv---- LV		vvvvv---- disks		vvvv--- used PEs
# /dev/vg_a400/lvol1
#                               /dev/dsk/c9t0d2        9744
#                               /dev/dsk/c9t0d1        7579
#                                     No Mirror       17323
# /dev/vgfc30l0/lvol1
#                               /dev/dsk/c8t3d0        8502
#                               /dev/dsk/c8t3d1        8502
#                               /dev/dsk/c8t3d2        8502
#                               /dev/dsk/c8t3d3        8502
#                                     No Mirror       34008
# /dev/vgfc30l2/lvol1
#                               /dev/dsk/c8t3d4        6376
#                               /dev/dsk/c8t3d5        6376
#                                     No Mirror       12752
#

# ---------------------------------------------------------------------------
# HP-UX 11 v3 new layout
# ---------------------------------------------------------------------------

# /dev/vgsapk32b/lvmnt
#                            /dev/disk/disk1242          94
#                                     No Mirror          94
# /dev/vgsapk32b/lvsaptrans
#                            /dev/disk/disk1242          32
#                                     No Mirror          32
# /dev/vgsapk32b/lvusr
#                            /dev/disk/disk1242          63
#                                     No Mirror          63
#

if [ "$1" = "vg00" ]                    # 21.07.2008, 10:43, rr
then
        VGS="/dev/vg00/lv*"
else
        VGS="/dev/vg*/lv*"
fi        
echo "VolumeGroup/Logical Volume    Disk Device    # Physical Extends"

for i in $VGS
do
   lvdisplay $i 2> /dev/null > /dev/null
   if [ $? -eq 0 ]
   then
        echo $i
#        lvdisplay -v $i | grep stale
        lvdisplay -v $i | grep -e /dev/dsk/c -e /dev/disk/disk |grep  current | awk ' {

                if ($3 != $6) {
                        a1[$2] ++;
                        if (length($5) < 8) { $5 = "No Mirror"; }
                        a2[$5] ++;
#                       print($2, $3, $5, $6);
                }

        }

        END {
                for (i in a1) { printf ("%45s\t%9d\n",i, a1[i]) };
                for (i in a2) { printf ("%45s\t%9d\n",i, a2[i]) };
        }'
   fi
done
