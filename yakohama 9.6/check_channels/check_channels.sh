#!/bin/sh

XML_PATH=./country-list.xml
COUNTRY_SET=./countries

if [ ! -e ${XML_PATH} ]; then
  echo "The XML file does NOT exist !!!"
  exit 1
fi

if [ ! -e ${COUNTRY_SET} ]; then
  echo "The Country Set file does NOT exist !!!"
  exit 1
fi

#The string constants relative to field name
field_name_full_name="(Full-Name) "
field_name_name="(Name) "
field_name_code="(Code) "
field_name_bg_channels="(2.4GHz) "
field_name_non_dfs_channels_11a="(5GHz NON-DFS) "
field_name_dfs_channels_11a="(5GHz DFS) "
field_name_allow_dfs_channels="(Allowed 5GHz DFS)"

show_message=1
show_detail_mismatch_message=1
found_mismatch=0
mismatch_counter=0
mismatch_message=""
mismatch_detail_message_full_name=""
mismatch_detail_message_name=""
mismatch_detail_message_code=""
mismatch_detail_message_bg_channels=""
mismatch_detail_message_non_dfs_channels_11a=""
mismatch_detail_message_dfs_channels_11a=""
mismatch_country_list=""

countries=$(cut -d ',' -f1 ${COUNTRY_SET})
for country in ${countries}
do
# Get parameters from Utililty
  res_utility=$(./regdomain -F -c "${country}")
# Get parameters from XML
  res_xml=$(grep "${country}" ${XML_PATH} | awk -F"\"" '{print toupper($6)","$4","$8":"$10":"$12":"$14}')

  found_mismatch=0
  mismatch_message=""
  if [ "$show_detail_mismatch_message" != "0" ]; then
    mismatch_detail_message_full_name=""
    mismatch_detail_message_name=""
    mismatch_detail_message_code=""
    mismatch_detail_message_bg_channels=""
    mismatch_detail_message_non_dfs_channels_11a=""
    mismatch_detail_message_dfs_channels_11a=""
  fi

# Row 2
  res_utility_bg_channels=$(echo $res_utility | sed 's/^.*2\.4GHz: //g' | sed 's/5GHz.*$//g')
# For the special case in "I5"
  if [ "$res_utility_bg_channels" != "" ]; then
    res_utility_bg_channels=$(echo $res_utility_bg_channels | sed 's/ $//g')
  fi
  res_xml_bg_channels=$(echo ${res_xml} | cut -d':' -f2)

# Check both data in Row 2
  if [ "$res_utility_bg_channels" != "$res_xml_bg_channels" ]; then
    if [ "$found_mismatch" == 0 ]; then
      found_mismatch=1
      mismatch_counter=$(($mismatch_counter+1))
    fi

    if [ "$res_utility_bg_channels" != "$res_xml_bg_channels" ]; then
      mismatch_message="${mismatch_message}${field_name_bg_channels}"
      if [ "$show_detail_mismatch_message" != "0" ]; then
        mismatch_detail_message_bg_channels=$(echo " ${field_name_bg_channels} untility: ${res_utility_bg_channels} ; xml: ${res_xml_bg_channels}")
      fi
    fi
  fi

# Row 4
  res_utility_dfs_channels_11a=$(echo $res_utility | sed 's/^.*5GHz DFS://g' | sed 's/^ //g' | sed 's/ 5GHz CBAND DFS:.*$//g')
  if [ "$res_utility_dfs_channels_11a" == "None" ]; then
    res_utility_dfs_channels_11a=""
  fi
  res_xml_dfs_channels_11a=$(echo ${res_xml} | cut -d':' -f4)
# Check both data in Row 4
  if [ "$res_utility_dfs_channels_11a" != "$res_xml_dfs_channels_11a" ]; then
    if [ "$found_mismatch" == 0 ]; then
      found_mismatch=1
      mismatch_counter=$(($mismatch_counter+1))
    fi

    mismatch_message="${mismatch_message}${field_name_dfs_channels_11a}"
    if [ "$show_detail_mismatch_message" != "0" ]; then
      mismatch_detail_message_dfs_channels_11a=$(echo " ${field_name_dfs_channels_11a} untility: ${res_utility_dfs_channels_11a} ; xml: ${res_xml_dfs_channels_11a}")
    fi     
  fi

# Row 3
  res_utility_non_dfs_channels_11a="$(echo $res_utility | sed 's/^.*5GHz NON-DFS://g' | sed 's/^ //g' | sed 's/5GHz DFS:.*$//g' | sed 's/ $//g')"
  if [ "$res_utility_non_dfs_channels_11a" == "None" ]; then
    res_utility_non_dfs_channels_11a=""
  fi

  res_xml_non_dfs_channels_11a=$(echo ${res_xml} | cut -d':' -f3)
  if [ "$res_xml_dfs_channels_11a" != "" ]; then
    res_xml_non_dfs_channels_11a=$(echo ${res_xml_non_dfs_channels_11a} | sed -e "s/${res_xml_dfs_channels_11a}//g")
    res_xml_non_dfs_channels_11a=$(echo ${res_xml_non_dfs_channels_11a} | sed 's/,$//g')
    res_xml_non_dfs_channels_11a=$(echo ${res_xml_non_dfs_channels_11a} | sed 's/,,/,/g')
  fi

# Check both data in Row 3
  if [ "$res_utility_non_dfs_channels_11a" != "$res_xml_non_dfs_channels_11a" ]; then
    if [ "$found_mismatch" == 0 ]; then
      found_mismatch=1
      mismatch_counter=$(($mismatch_counter+1))
    fi

    mismatch_message="${mismatch_message}${field_name_non_dfs_channels_11a}"
    if [ "$show_detail_mismatch_message" != "0" ]; then
      mismatch_detail_message_non_dfs_channels_11a=$(echo " ${field_name_non_dfs_channels_11a} untility: ${res_utility_non_dfs_channels_11a} ; xml: ${res_xml_non_dfs_channels_11a}")
    fi       
  fi

# Row 1
  res_utility_country_id=$(echo $res_utility | cut -d':' -f1 | sed 's/2\.4GHz.*$//g' | sed 's/ *$//g')
  res_xml_country_id=$(echo ${res_xml} | cut -d':' -f1)

# Check both data in Row 1
  if [ "$res_utility_country_id" != "$res_xml_country_id" ] || [ "$found_mismatch" != "0" ]; then
    if [ "$found_mismatch" == "0" ]; then
      found_mismatch=1
      mismatch_counter=$(($mismatch_counter+1))
    fi

    res_utility_full_name=$(echo ${res_utility_country_id} | cut -d',' -f1)
    res_utility_name=$(echo ${res_utility_country_id} | cut -d',' -f2)
    res_utility_code=$(echo ${res_utility_country_id} | cut -d',' -f3)
    res_xml_full_name=$(echo ${res_xml_country_id} | cut -d',' -f1)
    res_xml_name=$(echo ${res_xml_country_id} | cut -d',' -f2)
    res_xml_code=$(echo ${res_xml_country_id} | cut -d',' -f3)

    if [ "$res_utility_full_name" != "$res_xml_full_name" ]; then
      mismatch_message="${mismatch_message}${field_name_full_name}"
      if [ "$show_detail_mismatch_message" != "0" ]; then
        mismatch_detail_message_full_name=$(echo " ${field_name_full_name} untility: ${res_utility_full_name} ; xml: ${res_xml_full_name}")
      fi
    fi
    if [ "$res_utility_name" != "$res_xml_name" ]; then
      mismatch_message="${mismatch_message}${field_name_name}"
      if [ "$show_detail_mismatch_message" != "0" ]; then
        mismatch_detail_message_name=$(echo " ${field_name_name} untility: ${res_utility_name} ; xml: ${res_xml_name}")
      fi
    fi
    if [ "$res_utility_code" != "$res_xml_code" ]; then
      mismatch_message="${mismatch_message}${field_name_code}"
      if [ "$show_detail_mismatch_message" != "0" ]; then
        mismatch_detail_message_code=$(echo " ${field_name_code} untility: ${res_utility_code} ; xml: ${res_xml_code}")
      fi
    fi
  fi

  if [ "$show_message" == "1" ]; then
    echo " ${field_name_full_name},${field_name_name},${field_name_code}"
    echo " untility: ${res_utility_country_id}"
    echo " xml:      ${res_xml_country_id}"
    echo " ${field_name_bg_channels}"
    echo " untility: ${res_utility_bg_channels}"
    echo " xml:      ${res_xml_bg_channels}"
    echo " ${field_name_non_dfs_channels_11a}" 
    echo " untility: ${res_utility_non_dfs_channels_11a}"
    echo " xml:      ${res_xml_non_dfs_channels_11a}"
    echo " ${field_name_dfs_channels_11a}"
    echo " untility: ${res_utility_dfs_channels_11a}"
    echo " xml:      ${res_xml_dfs_channels_11a}"
    res_utility_allow_dfs_channels="FALSE"
    if [ "${res_utility_non_dfs_channels_11a}" != "" ] || [ "${res_utility_dfs_channels_11a}" != "" ]; then
      res_utility_allow_dfs_channels="TRUE"
    fi
    res_xml_allow_dfs_channels="FALSE"
    if [ "${res_xml_non_dfs_channels_11a}" != "" ] || [ "${res_xml_dfs_channels_11a}" != "" ]; then
      res_xml_allow_dfs_channels="TRUE"
    fi
    echo " ${field_name_allow_dfs_channels}"
    echo " untility: ${res_utility_allow_dfs_channels}"
    echo " xml:      ${res_xml_allow_dfs_channels}"
    if [ "$found_mismatch" == "1" ]; then
      mismatch_country_list="${mismatch_country_list}${res_utility_name} "
    fi
    echo "=================================================="

#    echo "$res_utility_country_id"
#    echo "$res_xml_country_id"
#    echo "$res_utility_bg_channels"
#    echo "$res_xml_bg_channels"
#    echo "$res_utility_non_dfs_channels_11a"
#    echo "$res_xml_non_dfs_channels_11a"
#    echo "$res_utility_dfs_channels_11a"
#    echo "$res_xml_dfs_channels_11a"
  elif [ "$found_mismatch" == "1" ]; then
    echo ""
    echo "Mismatch in ${res_utility_full_name}. Different field: ${mismatch_message}"
    if [ "$show_detail_mismatch_message" != "0" ]; then
      if [ "$mismatch_detail_message_full_name" != "" ]; then
        echo "$mismatch_detail_message_full_name"
      fi
      if [ "$mismatch_detail_message_name" != "" ]; then
        echo "$mismatch_detail_message_name"
      fi
      if [ "$mismatch_detail_message_code" != "" ]; then
        echo "$mismatch_detail_message_code"
      fi
      if [ "$mismatch_detail_message_bg_channels" != "" ]; then
        echo "$mismatch_detail_message_bg_channels"
      fi
      if [ "$mismatch_detail_message_non_dfs_channels_11a" != "" ]; then
        echo "$mismatch_detail_message_non_dfs_channels_11a"
      fi
      if [ "$mismatch_detail_message_dfs_channels_11a" != "" ]; then
        echo "$mismatch_detail_message_dfs_channels_11a"
      fi
    fi
  fi
  
done

echo ""
echo "*****************************************************************************"
if [ "$mismatch_counter" == 0 ]; then
  echo "No mismatch found !!!"
else
  echo "There are totally ${mismatch_counter} mismatch(es) found !!!"
  echo "The mismatch(es) country list: ${mismatch_country_list}"
fi
echo "*****************************************************************************"
echo ""

# Used for creating input countries
#cat ${XML_PATH} | grep id | awk -F"\"" '{print $4","}' > countries

exit 0
