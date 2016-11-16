#--------------------------------------------------------------------------
# INSTRUCTIONS
#--------------------------------------------------------------------------
# Read the Github documentatoin it is far better then this
# 1) Fill in the blank
# 2) Figure out which recipe you need
# 3) run 'make <recipe>'
# 3.5) Input passwords were necessary, SCP part gets tricky here

# PROTIP: The user running this script should have its id_rsa.pub key
#	included in the authorized_keys file of both participents

# Requirements: Both machines/servers must be accessable via ssh
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


#--------------------------------------------------------------------------
# Connection information for source
#--------------------------------------------------------------------------
SOURCE_SERVER		=
SOURCE_USER		=
SOURCE_MYSQL_USER	=root
# leave blank for manual entry and more security
SOURCE_MYSQL_PASS	=
SOURCE_DB		=magento2
SOURCE_TMP_DIR		=/tmp/
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#--------------------------------------------------------------------------
# Connection information for destination
# Req: openssh-server is required on all machines participating in transfer
#--------------------------------------------------------------------------
DEST_SERVER		=localhost
DEST_USER		=
DEST_MYSQL_USER		=root
# leave blank for manual entry and more security
DEST_MYSQL_PASS		=
DEST_DB			=magento2
DEST_TMP_DIR		=/tmp/
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


#--------------------------------------------------------------------------
# Auxillary information
#--------------------------------------------------------------------------
DATE			=$(shell date +'%y.%m.%d')
# File name used for transfer
FILE			=magento2_dump_$(DATE).sql
LOCAL_TMP		=/tmp/
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#--------------------------------------------------------------------------
# TARGETS
#--------------------------------------------------------------------------
# Target tables  
CATALOG_TABLES		=cache
CMS_TABLES		=
TARGETS			=transfer-catalog transfer-cms


#--------------------------------------------------------------------------
# Core Commands
#--------------------------------------------------------------------------
CONNECT_SOURCE		=ssh $(SOURCE_USER)@$(SOURCE_SERVER)
CONNECT_DEST		=ssh $(DEST_USER)@$(DEST_SERVER)
SCP_SOURCE_2_LOCAL	=scp $(SOURCE_SERVER):$(SOURCE_TMP_DIR)$(FILE) $(LOCAL_TMP)$(FILE)
SCP_LOCAL_2_DEST	=scp $(LOCAL_TMP)$(FILE) $(DEST_SERVER):$(DEST_TMP_DIR)$(FILE)
REMOVE_SOURCE_FILE	=rm $(SOURCE_TMP_DIR)$(FILE)
REMOVE_DEST_FILE	=rm $(DEST_TMP_DIR)$(FILE)
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#-------------------------------------------------------------------------------
# RECIPES									|
#-------------------------------------------------------------------------------
transfer:
	@echo Please use one of the following options:
	@echo "    $(TARGETS)"

transfer-catalog:
	@echo "Transfering catalog tables from $(SOURCE_SERVER) -> $(DEST_SERVER)"
	@echo  Dumping source DB to  $(SOURCE_TMP_DIR)$(FILE) ...
	@$(CONNECT_SOURCE) "mysqldump -u $(SOURCE_MYSQL_USER) -p$(SOURCE_MYSQL_PASS) $(DEST_DB) $(CATALOG_TABLES) >$(SOURCE_TMP_DIR)$(FILE)"
	@echo Transfering file from $(SOURCE_SERVER) to $(DEST_SERVER)
	@$(SCP_SOURCE_2_LOCAL)
	@echo Removing $(SOURCE_SERVER):$(SRC_TMP_DIR)$(FILE) ...
	@$(CONNECT_SOURCE) "$(REMOVE_SOURCE_FILE)"
ifneq ($(DEST_SERVER), localhost)
	@$(SCP_LOCAL_2_DEST)
endif

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
