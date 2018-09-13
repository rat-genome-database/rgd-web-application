# This shell script is used to run the nomenclature pipeline
# Created by : Dawei Li
# Date: 06/13/2007
PATH=/usr/local/jre1.5.0_09/bin:/usr/local/bin:$PATH
export PATH
JAVA_HOME=/usr/local/jre1.5.0_09
export JAVA_HOME
cd /user/rgddata/cvs/Development/RGD/NomenclaturePipeline
java -classpath lib/classes12.jar:lib/spring.jar:lib/commons-collections-3.0.jar:lib/commons-dbcp.jar:lib/commons-logging-1.0.4.jar:lib/commons-pool.jar:lib/log4j-1.2.8.jar:lib/NomenclaturePipeline.jar NomenclatureManager >cron.log
