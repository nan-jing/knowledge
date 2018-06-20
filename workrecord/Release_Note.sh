#!/bin/bash -x
WORKSPACE=$(pwd)
RevisionHistoryAndroid=RevisionHistoryAndroid.html
RevisionHistoryAmss=RevisionHistoryAmss.html
workStaging=${WORKSPACE}/RevisionHistory
RevisionHistoryAndroidTxt=${workStaging}/RevisionHistoryAndroidTxt.txt
TestTxt=${workStaging}/ReleaseNote.txt
TempTxt=${workStaging}/TempTxt.txt
ReleaseNote=${workStaging}/TestTxt.txt
if [ ! -e "${workStaging}" ]; then
	mkdir -p ${workStaging}
fi
curVersionAndroid=${SW_VERSION_PLATFORM}.${SW_VERSION_MAJOR}.${SW_VERSION_MINOR}-\(${BUILD_NUMBER}\)
lastVersionAndroid=${lastVersionAndroid}

function getModifiedProjects()
{
	cd ${workStaging}
	if [ ! -f "lastManifest.xml" -o ! -f "currentManifest.xml" ]; then
		echo "no manifest xml file"
		exit -1
	fi
	diff lastManifest.xml currentManifest.xml | grep "^<" > modifiedProjects.xml
	sed -i 's/^.*path=//g' modifiedProjects.xml
	sed -i 's/^.*name=//g' modifiedProjects.xml
	sed -i 's/\ revision="/ /g' modifiedProjects.xml
	sed -i 's/"\ upstream.*$//g' modifiedProjects.xml
	cat modifiedProjects.xml | while read line; do
	    cd ${workStaging}
		array=($line)
		path=${array[0]}
		lastandroidcommit=${array[1]}
		if [ ! -f "currentManifest.xml" ]; then
		     echo "no manifest xml file"
	    fi
		grep ${path} currentManifest.xml > curProject.xml
		sed -i 's/.*revision="//g' curProject.xml
	    sed -i 's/".*$//g' curProject.xml
		curandroidcommit=`cat curProject.xml`
		#######Delete""#####
		path=${path##\"}
		path=${path%%\"}
		cd ${WORKSPACE}
		cd ${path}
		git log ${lastandroidcommit}...${curandroidcommit} --pretty=oneline >> ${RevisionHistoryAndroidTxt}
	done
	cd ${WORKSPACE}
}

function getAndroidCommits()
{
	cd ${workStaging}
	echo $lastVersionAndroid
	echo "currentVersion=${curVersionAndroid}" > ${RevisionHistoryAndroidTxt}
	echo "lastVersion=${lastVersionAndroid}" >> ${RevisionHistoryAndroidTxt}
	##################get lastVersionAndroid manifest##############
    echo "####Download lastVersionAndroid manifest.xml#######"
	cd ${WORKSPACE}
	mv manifest.xml ${workStaging}/currentManifest.xml
 	wget --user=readonly --password='readonly' http://artifactory.android.honeywell.com:8080/artifactory/libs-snapshot-local/Honeywell/MelbourneAndroid/pre-melbourne-release/${lastVersionAndroid}/manifest.xml -O ${workStaging}/lastManifest.xml
	getModifiedProjects
	cd ${WORKSPACE}
}
function ComSecurity()
{
    > ${ReleaseNote}
	> ${TempTxt}
	> ${TestTxt}
	cat ${RevisionHistoryAndroidTxt} | while read line; do
	     echo ${line:41} >> ${ReleaseNote}
    done
	grep -i '\[Security\]' ${ReleaseNote} >> ${TestTxt}
	sed -i '/\[Security\]/d' ${ReleaseNote}
	
}
function ComRevert()
{
    > ${TempTxt}
	sed -i '/^$/d' ${ReleaseNote}
	cat ${ReleaseNote} | while read line; do
	    if [ `echo ${line} | awk -F'Revert' '{print NF-1}'` = 1 ];then
	        echo ${line} | sed 's/Revert//g' | sed 's/"//g' | sed 's/^[ \t]*//g' >> ${TempTxt}
		fi
	done
	sed  -i '/^$/d' ${TempTxt}
    cat ${TempTxt} | while read line; do
	    a=0
	    str=`echo ${line} | sed 's/[^0-9a-zA-Z_]//g'`
		cat ${ReleaseNote} | while read line1; do
		    a=$(($a+1))
            str1=`echo ${line1} | sed 's/[^0-9a-zA-Z_]//g'`
		    if [[ $str1 =~ $str ]];then
				sed -i "$a"c/ReleaseNote_DeleteThisLine ${ReleaseNote}
				if [ `echo ${line1} | awk -F'Revert' '{print NF-1}'` = 2 ];then
				     echo ${line1} | sed 's/Revert//g' | sed 's/"//g' | sed 's/^[ \t]*//g' >> ${TestTxt}
				fi
		    fi
		done
	done
	sed -i '/ReleaseNote_DeleteThisLine/d' ${ReleaseNote}
	cat ${ReleaseNote} | while read line; do
	    echo ${line} >> ${TestTxt}
	done
	> ${TempTxt}
	> ${ReleaseNote}
}

function Com()
{
	cat ${TestTxt} | while read line; do
	    str=`echo ${line} | sed 's/[^0-9a-zA-Z_]//g'`
	    if [ ${#str} -gt 15 ];then
		    str=${str:0:15}
	    fi
	    n=0
	    a=0
	    cat ${TestTxt} | while read line1; do
		    a=$(($a+1))
		    str1=`echo ${line1} | sed 's/[^0-9a-zA-Z_]//g'`
	        if [ ${#str1} -gt 15 ];then
		        str1=${str1:0:15}
		    fi
		    if [ ${str} == ${str1} ];then
			    n=$(($n+1))
			    if [ $n -gt 1 ];then
				    sed -i "$a"c/ReleaseNote_DeleteThisLine ${TestTxt}
			    fi
		    fi
		done
	done
	sed -i '/ReleaseNote_DeleteThisLine/d' ${TestTxt}
	sed -i 's/([0-9])//g' ${TestTxt}
	sed -i 's/([0-9]\/[0-9])//g' ${TestTxt}
	sed -i 's/\[[0-9]\]//g' ${TestTxt}
	sed -i 's/\[[0-9]\/[0-9]\]//g' ${TestTxt}
	sed -i 's/[0-9]\/[0-9]//g' ${TestTxt}
}

function main()
{
	 getAndroidCommits
	 ComSecurity
	 Com
	 ComRevert
	 Com
	 rm -rf ${ReleaseNote}
	 rm -rf ${TempTxt}
}
main "$@"