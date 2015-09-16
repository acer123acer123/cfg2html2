# get LVM for TGV by Ralph Roth
# @(#) $Id: get_vg.sh,v 4.11 2008-11-13 19:53:44 ralproth Exp $
# $Log: get_vg.sh,v $
# Revision 4.11  2008-11-13 19:53:44  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2003/03/11 09:20:52  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2003/03/11 09:20:52  ralproth
# Initial 3.x stream import
#
# Revision 2.3  2003/03/11 09:20:52  ralproth
# Added options -d, -t, -A, -b
#
# Revision 2.2  2003/02/04 16:56:19  www
# Added get_vg.sh to collect TGV information
#
# Revision 2.1.1.1  2003/01/21 10:33:33  ralproth
# Import from HPUX to cygwin
#
# Revision 1.2  2003/01/13 10:08:43  ralproth
# Added cvs keywords
#
#

# fixed, sr by wpj3140 <juhas@tesco.net> 
set TMP=/tmp

get_LVM()
{

vgLIST=$TMP/vgLIST.$$
lvLIST=$TMP/lvLIST.$$
pvLIST=$TMP/pvLIST.$$
LVMLIST=$TMP/LVMLIST.$$

cp /dev/null $LVMLIST

if [ -f /etc/lvmtab ]
then
    vgdisplay -v|awk '$1 == "VG" && $2 == "Name" {print $3}'|sort -u > $vgLIST
    vgdisplay -v|awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u > $lvLIST
    vgdisplay -v|awk '$1 == "PV" && $2 == "Name" {print $3}'|sort -u > $pvLIST

        for i in "vg" "lv" "pv"
        do
                for j in `eval cat '$'${i}LIST`
                do
                eval ${i}NAME=`echo $j`
                echo "${i}display -v $j:$i`eval echo '$'${i}NAME`" >> $LVMLIST
                done
        done
        while read i
        do
                LVMCOMMAND=`echo $i|awk -F: '{print $1}'`
                LVMNAME=`echo $i|awk -F: '{print $2}'`
                echo "@@@@@@ START OF $LVMNAME"
                echo ""
                $LVMCOMMAND
                echo ""
                echo "###### END OF $LVMNAME"
                echo ""
        done < $LVMLIST
else
        echo "Not Installed on this System"
fi

rm $vgLIST $lvLIST $pvLIST

}

echo "LVM/VG Layout is stored in this document as a comment, ready to be processed by HP's TGV (LVM only, no HW)!\n<!-- "
get_LVM
echo "-->"

