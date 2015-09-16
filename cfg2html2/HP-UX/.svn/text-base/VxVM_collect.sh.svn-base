############################################################################
# Veritas Volume Manager (VxVM) Collector for cfg2html
############################################################################
# @(#) $Id: VxVM_collect.sh,v 4.12 2008-11-13 19:53:43 ralproth Exp $
############################################################################
# $Log: VxVM_collect.sh,v $
# Revision 4.12  2008-11-13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2004/07/15 12:07:40  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2004/07/15 11:07:40  ralproth
# Initial 3.x stream import
#
# Revision 2.2  2004/07/15 11:07:40  ralproth
# Changed paths to documentation
#
# Revision 2.1.1.1  2003/01/21 10:33:32  ralproth
# Import from HPUX to cygwin
#
# Revision 1.2  2002/02/06 09:10:17  ralproth
# VxVM collector added
#
# Revision 1.1  2002/02/05 12:41:33  ralproth
# Initial CVS import
# Initial VxVM collector
############################################################################
# (C)opyright 04.02.2002-2004 by ROSE SWE, Ralph Roth, All Rights Reserved!
############################################################################
PATH=/usr/sbin:$PATH

#for i in `vxdg list |awk '{print ($1)}'|grep -v DEVICE`
#	do
#	echo "Volumegroup $i\n"
#	vxdg list $i
#	done

echo "VxPrint\n"
vxprint -rth

echo "\n"
echo "VxStat"

	vxstat -d 2>&1 | tail +3 | awk '
	    BEGIN { 
		printf ("                                OPERATIONS             BLOCKS       AVG TIME(ms)\n");
		printf ("TYP NAME                      READ     WRITE       READ      WRITE  READ  WRITE\n");
	     }
    		{
		    v  = $1
		    n  = $2
		    or = $3
		    ow = $4
		    br = $5
		    bw = $6
		    ar = $7
		    aw = $8
		    printf ("%s %-20s %9s %9s %10s %10s %5.1f  %5.1f\n", v,n,or,ow,br,bw,ar,aw)

		}'                             

