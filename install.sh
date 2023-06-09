#!/bin/bash

readonly SCRIPT_ALIAS="chper"
readonly SCRIPT_NAME="permission_manager.sh"
readonly BASHRC_PATH=$HOME"/.bashrc"

script_new_path=$HOME"/."$SCRIPT_NAME

# 사용자 홈 디렉터리에 스크립트를 생성하고, 퍼미션을 755로 변경한다.
cp "$SCRIPT_NAME" "$script_new_path"
chmod 755 "$script_new_path"

# chper이라는 별칭을 설정하는 명령어를 지정하고 실행한다. 
script_alias_command="alias $SCRIPT_ALIAS=\"$script_new_path \""
eval "$script_alias_command"

if [ ! -f "$BASHRC_PATH" ]; then 
	echo "설치 실패: BASH 환경 설정 파일을 찾을 수 없습니다."
	exit
fi

# bashrc 파일에 별칭 설정을 추가한다.
bashrc_tmp_file=$(mktemp)
echo "$script_alias_command" > "$bashrc_tmp_file"
cat "$BASHRC_PATH" >> "$bashrc_tmp_file"
mv "$bashrc_tmp_file" "$BASHRC_PATH"


echo "설치 완료: \"$SCRIPT_ALIAS [파일 경로]\" 형식을 입력하여 실행할 수 있습니다."
