# HP-UX SAS Collector , 21.07.2008, 11:57, rr
# HP-UX Serial Attached SCSI (SAS) Mass Storage I/O cards / HBAs
# @(#) $Id: get_sasinfo.sh,v 4.11 2008-11-13 20:22:57 ralproth Exp $
# ---------------------------------------------------------------------------
# $Log: get_sasinfo.sh,v $
# Revision 4.11  2008-11-13 20:22:57  ralproth
# cfg4.13: fixes for mywhat utility
#
# Revision 4.10.1.1  2008/10/24 11:48:18  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.2  2008/10/24 10:48:18  ralproth
# cfg3.72: Fixes for HP-UX 11.31
#
# Revision 3.1  2008/07/22 17:01:02  ralproth
# added sas and mpt plugins
#

if [ -x /opt/sas/bin/sasmgr ]
then
    ioscan -fnkd sasd
    for dev in /dev/sasd*
    do
        if [ -c "$dev" ]
        then
            echo "---= $dev ==="
            /opt/sas/bin/sasmgr get_info -D $dev
            for i in vpd smp_addr raid "lun=all -q lun_locate" # reg=all
            do
                echo "\n-----= $i ($dev)"
		# -N for HPUX 11.31, agile view -> use $1 = -D
                /opt/sas/bin/sasmgr $1 get_info -D $dev -q $i
            done
            echo ""
        fi     
    done # for
fi

###
