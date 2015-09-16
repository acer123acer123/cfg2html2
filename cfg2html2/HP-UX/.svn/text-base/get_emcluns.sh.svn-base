# @(#) $Id: get_emcluns.sh,v 4.12 2008-11-13 19:53:43 ralproth Exp $
#  /home/CVS/cfg2html/release/plugins/get_emcluns.sh 2005/08/09 Steveriley
##### Initial creation:  steve.riley@hp.com, C&I UK       ##################

######################################
#	EXAMPLE OUTPUT FROM SYMPD LIST
######################################

EmcInfo()
{	
	#Symmetrix ID: 000287970866
	#
	#        Device Name           Directors                  Device
	#--------------------------- ------------- -------------------------------------
	#                                                                           Cap
	#Physical               Sym  SA :P DA :IT  Config        Attribute    Sts   (MB)
	#--------------------------- ------------- -------------------------------------
	#    1		        2    3     4       5             6            7    8
	#/dev/rdsk/c16t0d0      0083 01C:0 16B:C8  2-Way Mir     Grp'd    (M) RW   34890
	#/dev/rdsk/c16t0d1      0087 01C:0 16A:C9  2-Way Mir     Grp'd    (M) RW   34890
	#/dev/rdsk/c16t0d2      008B 01C:0 16B:CA  2-Way Mir     Grp'd    (M) RW   34890
	#/dev/rdsk/c16t0d3      008F 01C:0 16A:CB  2-Way Mir     Grp'd    (M) RW   34890
	#
	# and on
	# and on
	# and on...
	
	sympd list
	
	######################################
	#	EXAMPLE OUTPUT FROM SYMDG LIST
	######################################
	
	#                          D E V I C E      G R O U P S
	#
	#                                                             Number of
	#    Name               Type     Valid  Symmetrix ID  Devs   GKs  BCVs  VDEVs
	#
	#    PUKE               REGULAR  Yes    000287979999     4     0     4      0
	#    QUKE               RDF2     Yes    000287979999     0     0    14      0
	#    TUKE               RDF2     Yes    000287979999     0     0    14      0
	#    PMS01              REGULAR  Yes    000287979999     3     0     3      0
	
	symdg list >/tmp/symdg.out
	cat /tmp/symdg.out
	
	grep "No Symmetrix" /tmp/symdg.out 2>&1 >/dev/null
	[[ $? -eq 0 ]] && rm /tmp/symdg.out && exit
	
	###########################################
	#	EXAMPLE OUTPUT FROM SYMDG SHOW PUKE
	###########################################
	
	#Group Name:  PUKE
	#
	#    Group Type                                   : REGULAR
	#    Valid                                        : Yes
	#    Symmetrix ID                                 : 000287979999
	#    Group Creation Time                          : Sat Jul  9 14:38:45 2005
	#    Vendor ID                                    : EMC Corp
	#    Application ID                               : SYMCLI
	#
	#    Number of STD Devices in Group               :    4
	#    Number of Associated GK's                    :    0
	#    Number of Locally-associated BCV's           :    4
	#    Number of Locally-associated VDEV's          :    0
	#    Number of Remotely-associated BCV's (STD RDF):    0
	#    Number of Remotely-associated BCV's (BCV RDF):    0
	#    Number of Remotely-assoc'd RBCV's (RBCV RDF) :    0
	#
	#    Standard (STD) Devices (4):
	#        {
	#        --------------------------------------------------------------------
	#                                                      Sym               Cap
	#        LdevName              PdevName                Dev  Att. Sts     (MB)
	#        --------------------------------------------------------------------
	#        DEV001                /dev/rdsk/c16t0d0       0083 (M)  RW     34890
	#        DEV002                /dev/rdsk/c16t0d1       0087 (M)  RW     34890
	#        DEV003                /dev/rdsk/c16t0d2       008B (M)  RW     34890
	#        DEV004                /dev/rdsk/c16t0d3       008F (M)  RW     34890
	#        }
	#
	#    BCV Devices Locally-associated (4):
	#        {
	#        --------------------------------------------------------------------
	#                                                      Sym               Cap
	#        LdevName              PdevName                Dev  Att. Sts     (MB)
	#        --------------------------------------------------------------------
	#        BCV001                /dev/rdsk/c16t1d2       0163 (M)  RW     34890
	#        BCV002                /dev/rdsk/c16t1d3       0167 (M)  RW     34890
	#        BCV003                /dev/rdsk/c16t1d4       016B (M)  RW     34890
	#        BCV004                /dev/rdsk/c16t1d5       016F (M)  RW     34890
	
	for DG in `awk '{ \
	if (NR>6){
		print $1}
	}' /tmp/symdg.out`
	do
		symdg show $DG
	done
	
	rm /tmp/symdg.out
}
if [ -z "$CFG2HTML" ] 		# only execute if not called from
then				# cfg2html directly!
	EmcInfo
fi 
