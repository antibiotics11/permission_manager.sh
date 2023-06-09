#!/bin/bash

filename=$1;

echo -e "\n permission_manager.sh v1.0 \n";

if [ -z $filename ]; then
	echo -e " ERROR: 파일이 존재하지 않습니다. ";
	exit;
else
	if [ ! -e $filename ]; then
		echo -e " ERROR: 파일 경로나 이름을 확인해주세요.";
		exit;
	fi;
fi;

current_permissions=$(stat -L -c "%a" $filename);
i=1;
t=0;

while [ $i -lt $current_permissions ]; do
	i=$(($i * 10));
	t=$(($t + 1));
	arr[$t]=$(($(($current_permissions % $i)) / $(($i / 10))));
done

PrintCurrentPermissions() {
	if [ ${arr[$i]} == 7 ]; then
		echo " -- 읽기(r), 쓰기(w), 실행(x)";
	elif [ ${arr[$i]} == 6 ]; then
		echo " -- 읽기(r), 쓰기(w)";
	elif [ ${arr[$i]} == 4 ]; then
		echo " -- 읽기(r)";
	elif [ ${arr[$i]} == 3 ]; then
		echo " -- 쓰기(w), 실행(x)";
	elif [ ${arr[$i]} == 2 ]; then
		echo " -- 쓰기(w)";
	elif [ ${arr[$i]} == 1 ]; then
		echo " -- 실행(x)";
	elif [ ${arr[$i]} == 0 ]; then
		echo " -- 부여된 권한 없음";
	fi;
}

GetPermissionSum() {
	permission_sum[$i]=$(($read_num + $write_num + $execute_num));
}

ReadPermissions() {
	read -p " >> " select_permission;
	case $select_permission in
        y | Y | yes | Yes | YES | ok)
			if [ $permission_num == 4 ]; then
				read_num=$permission_num;
			elif [ $permission_num == 2 ]; then
				write_num=$permission_num;
			elif [ $permission_num == 1 ]; then
				execute_num=$permission_num;
			fi;;
		*)
			if [ $permission_num == 4 ]; then
				read_num=0;
			elif [ $permission_num == 2 ]; then
				write_num=0;
			elif [ $permission_num == 1 ]; then
				execute_num=0;
			fi;;
	esac;
}

ChangePermissions() {
	for((k=1;k<4;k++)) do
		if [ $k == 1 ]; then
			echo -e "\n -- 읽기 권한을 부여하시겠습니까? (y, n)";
			permission_num=4;
		elif [ $k == 2 ]; then
			echo -e "\n -- 쓰기 권한을 부여하시겠습니까? (y, n)";
			permission_num=2;
		elif [ $k == 3 ]; then
			echo -e "\n -- 실행 권한을 부여하시겠습니까? (y, n)";
			permission_num=1;
		fi;
		ReadPermissions;
	done;
	GetPermissionSum;
}

PrintUsers() {
	for((i=1;i<4;i++)) do
		if [ $i == 1 ]; then
			echo -e "\n => 기타 사용자 권한";
		elif [ $i == 2 ]; then
			echo -e "\n => 그룹 사용자 권한";
		elif [ $i == 3 ]; then
			echo -e "\n => 파일 소유자 권한";
		fi;
		$1;
	done;
}

echo -e "\n ------ 파일의 현재 퍼미션 ------ \n";
PrintUsers PrintCurrentPermissions;

echo -e "\n\n ---- 파일 퍼미션을 변경합니다. ---- \n";
PrintUsers ChangePermissions;

new_permissions=${permission_sum[3]}${permission_sum[2]}${permission_sum[1]};

echo -e "\n 디렉터리인 경우, 하위 파일 및 디렉터리를 모두 동일한 퍼미션으로 변경하시겠습니까? (y, n)\n";
read -p " >> " sub_permissions;

case $sub_permissions in
	y | Y | yes | Yes | YES | ok)
		chmod -R $new_permissions $filename;;
	*)
		chmod $new_permissions $filename;;
esac;

echo -e "\n 파일 퍼미션이 변경되었습니다. \n";
