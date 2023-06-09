#!/bin/bash

readonly PERMISSION_R="읽기(r)"
readonly PERMISSION_W="쓰기(w)"
readonly PERMISSION_X="실행(x)"
readonly PERMISSION_N="권한없음"

readonly USER_OWNER="파일 소유자"
readonly USER_GROUP="그룹 사용자"
readonly USER_ALL="기타 사용자"

<< COMMENT
 파일의 현재 퍼미션을 가져온다.
 @param 파일 경로
 @return 8진수 퍼미션
COMMENT
function get_current_permissions {
	echo $(stat -L -c "%a" $1)
}

<< COMMENT 
 퍼미션을 배열 형태로 반환한다.
 @param 8진수 퍼미션
 @return permissions_digits=(소유자 권한, 그룹 권한, 전체 권한) 퍼미션 배열
COMMENT
function parse_permissions {
	
	local permissions=$1
	local permissions_digits=()

	permissions_digits[0]=$((permissions / 100))         # R
	permissions_digits[1]=$((permissions % 100 / 10))    # W
	permissions_digits[2]=$((permissions % 10))          # X
	
	echo "${permissions_digits[@]}"

}

<< COMMENT
 배열의 퍼미션을 모두 더해 8진수로 반환한다
 @param permissions_digits 퍼미션 배열
 @return 8진수 퍼미션
COMMENT
function get_permissions_sum {
	
	local permissions_digits=("$@")
	local permissions_sum=0
	
	permissions_sum=$((permissions_digits[0] * 100))                       # R
	permissions_sum=$((permissions_sum + permissions_digits[1] * 10))      # W
	permissions_sum=$((permissions_sum + permissions_digits[2]))           # X
	
	echo $permissions_sum

}

<< COMMENT
 퍼미션을 8진수로 입력받아 문자열로 반환한다.
 @param 8진수 퍼미션 (7, 6, 4, 3, 2, 1, 0)
 @return 퍼미션 문자열
COMMENT
function get_permission_type {

	local permission_digit=$1
	case $permission_digit in
		7)
			echo $PERMISSION_R", "$PERMISSION_W","$PERMISSION_X;;
		6)
			echo $PERMISSION_R", "$PERMISSION_W;;
		5)
			echo $PERMISSION_R", "$PERMISSION_X;;
		4)
			echo $PERMISSION_R;;
		3)
			echo $PERMISSION_W", "$PERMISSION_X;;
		2)
			echo $PERMISSION_W;;
		1)
			echo $PERMISSION_X;;
		*)
			echo $PERMISSION_N;;
	esac

}

<< COMMENT
 퍼미션 배열을 입력받아 사용자별 권한을 출력한다
 @param permissions_digits 퍼미션 배열
COMMENT
function print_permissions {

	local permissions_digits=("$@")
	echo -n "  "$USER_OWNER" 권한 -> "
	print_message "$(get_permission_type ${permissions_digits[0]})"
	echo -n "  "$USER_GROUP" 권한 -> "
	print_message "$(get_permission_type ${permissions_digits[1]})"
	echo -n "  "$USER_ALL" 권한 -> "
	print_message "$(get_permission_type ${permissions_digits[2]})"
	
}

<< COMMENT
 읽기, 쓰기, 실행 권한을 입력받아 8진수로 반환한다
 @return 8진수 퍼미션
COMMENT
function read_user_permissions {
	
	local permissions=0
	local input_yn="n"
	
	read -p "    읽기(r) 권한을 부여하시겠습니까? (y, n) " input_yn
	local read=$(verify_input_yn $input_yn)
	read -p "    쓰기(w) 권한을 부여하시겠습니까? (y, n) " input_yn
	local write=$(verify_input_yn $input_yn)
	read -p "    실행(x) 권한을 부여하시겠습니까? (y, n) " input_yn
	local execute=$(verify_input_yn $input_yn)
	
	if [ $read -eq 1 ]; then
		permissions=$((permissions + 4))
	fi
	if [ $write -eq 1 ]; then
		permissions=$((permissions + 2))
	fi
	if [ $execute -eq 1 ]; then
		permissions=$((permissions + 1))
	fi
	
	echo $permissions

}

<< COMMENT
 (y, n) 형식의 입력을 받아 검증한다.
 @param input  입력
 @return y면 1, 아니면 0
COMMENT
function verify_input_yn {

	local input=$1
	case $input in 
		y | Y | yes | Yes | YES | ok)
			echo 1;;
		*)
			echo 0;;
	esac

}

<< COMMENT
 파일명의 길이와 파일이 존재하는지 검증한다.
 @param path 파일 경로
 @return 검증에 성공했으면 1, 아니면 0
COMMENT
function verify_path {
	
	local path=$1
	if [ -z $path ]; then
		echo 0
	else 
		if [ ! -e $path ]; then 
			echo 0
		else 
			echo 1
		fi
	fi

}

# 스크립트의 정보를 출력
function print_script_info {
	
	local repository="https://github.com/antibiotics11/permission_manager.sh"
	echo -e "\e[99m\e[44mpermission_manager.sh v2.0                            \e[0m"
	echo -e "\e[99m\e[44m\e]8;;"$repository"\a"$repository"\e]8;;\a\e[0m"
	echo -e ""
	
}

# 퍼미션 출력시 출력 형식 지정
function print_message {
	local message=$1
	echo -e "\e[1m\e[34m"$message"\e[0m"
}

# 오류 메시지 출력시 출력 형식 지정
function print_error_message {
	local message=$1
	echo -e "\e[91mERROR: "$message"\e[0m"
}

# 인터럽트 발생시 스크립트 종료
function handle_interrupt {
	local message="퍼미션이 변경되지 않았습니다. 실행을 종료합니다.";
	print_error_message "$message"
	exit
}

function main {
	
	# 스크립트를 정보를 출력한다.
	print_script_info
	
	# 파일 경로가 올바르지 않으면 실행을 종료한다.
	local input_path=$1
	local path_verification_result=$(verify_path $input_path)
	if [ $path_verification_result -eq 0 ]; then
		print_error_message "파일 경로를 정확하게 입력해주세요."
		exit
	fi
	
	# 파일 경로를 출력한다.
	echo -e "### 파일 경로 \e[4m"$input_path"\e[0m"
	echo -e ""
	
	# 현재 퍼미션을 출력한다.
	local current_permissions=$(get_current_permissions $input_path)
	local current_permissions_digits=$(parse_permissions $current_permissions)
	echo -e "### 파일의 현재 퍼미션"
	print_permissions $current_permissions_digits
	echo -e ""
	
	# 새 퍼미션을 입력받는다.
	echo -e "### 퍼미션을 변경합니다."
	local new_permissions_digits=()
	local new_permissions=0

	echo -e "\n  $USER_OWNER 권한 -> "
	new_permissions_digits[0]=$(read_user_permissions)
	echo -e "\n  $USER_GROUP 권한 -> "
	new_permissions_digits[1]=$(read_user_permissions)
	echo -e "\n  $USER_ALL 권한 -> "
	new_permissions_digits[2]=$(read_user_permissions)
	new_permissions=$(get_permissions_sum ${new_permissions_digits[@]})
	echo -e ""

	# 새 퍼미션을 출력한다.
	echo -e "### 파일의 새 퍼미션"
	new_permissions_digits=$(parse_permissions $new_permissions)
	print_permissions $new_permissions_digits
	echo -e ""
	
	local recursive=0
	if [ ! -f "$input_path" ]; then
		read -p " 하위 디렉토리 및 파일에 동일하게 적용하시겠습니까? (y, n) " input_yn;
		recursive=$(verify_input_yn $input_yn);
	fi
	
	if [ $recursive -eq 1 ]; then
		chmod -R "$new_permissions" "$input_path"
	else
		chmod "$new_permissions" "$input_path"
	fi
	
	print_message "퍼미션이 변경되었습니다."
	
	return 0

}

trap handle_interrupt SIGINT
main $1

