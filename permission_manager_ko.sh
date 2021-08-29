#!/bin/bash

FileName=$1;

if [ -z $FileName ]; then
        echo "파일이 없습니다";
        exit;
else
        if [ ! -e $FileName ]; then
                echo "파일 경로나 이름을 확인해주세요.";
                exit;
        fi
fi

FilePer=$(stat -L -c "%a" $FileName);
i=1;
t=0;

while [ $i -lt $FilePer ]; do
        i=$(($i * 10));
        t=$(($t + 1));
        arr[$t]=$(($(($FilePer % $i)) / $(($i / 10))));
done

CheckPer() {
        if [ ${arr[$i]} == 7 ]; then
                echo "-- 읽기(r), 쓰기(w), 실행(x)";
        elif [ ${arr[$i]} == 6 ]; then
                echo "-- 읽기(r), 쓰기(w)";
        elif [ ${arr[$i]} == 4 ]; then
                echo "-- 읽기(r)";
        elif [ ${arr[$i]} == 3 ]; then
                echo "-- 쓰기(w), 실행(x)";
        elif [ ${arr[$i]} == 2 ]; then
                echo "-- 쓰기(w)";
        elif [ ${arr[$i]} == 1 ]; then
                echo "-- 실행(x)";
        elif [ ${arr[$i]} == 0 ]; then
                echo "-- 부여된 권한 없음";
        fi
}

SumPerAll() {
        SumPerNumAll[$i]=$(($PerNumRead + $PerNumWri + $PerNumExe));
}

ReadPer() {
        read -p ">> " SelPerNumUser;
        case $SelPerNumUser in
        y | Y | yes | Yes | YES | ok)
                if [ $PerNumAll == 4 ]; then
                        PerNumRead=$PerNumAll;
                elif [ $PerNumAll == 2 ]; then
                        PerNumWri=$PerNumAll;
                elif [ $PerNumAll == 1 ]; then
                        PerNumExe=$PerNumAll;
                fi;;
        *)
                if [ $PerNumAll == 4 ]; then
                        PerNumRead=0;
                elif [ $PerNumAll == 2 ]; then
                        PerNumWri=0;
                elif [ $PerNumAll == 1 ]; then
                        PerNumExe=0;
                fi;;
        esac;
}

ChangePer() {
        for((k=1;k<4;k++)) do
                if [ $k == 1 ]; then
                        echo -e "\n읽기 권한을 부여하시겠습니까? (y, n)";
                        PerNumAll=4;
                elif [ $k == 2 ]; then
                        echo -e "\n쓰기 권한을 부여하시겠습니까? (y, n)";
                        PerNumAll=2;
                elif [ $k == 3 ]; then
                        echo -e "\n실행 권한을 부여하시겠습니까? (y, n)";
                        PerNumAll=1;
                fi
                NumAdd=0;
                ReadPer;
        done
        SumPerAll;
}

PerUser() {
        for((i=1;i<4;i++)) do
                if [ $i == 1 ]; then
                        echo -e "\n### 기타 사용자 권한";
                elif [ $i == 2 ]; then
                        echo -e "\n### 그룹 사용자 권한";
                elif [ $i == 3 ]; then
                        echo -e "\n### 파일 소유자 권한";
                fi
                $1;
        done
}

echo -e "\n### 파일의 현재 퍼미션 ###\n";
PerUser CheckPer;

echo -e "\n### 파일 퍼미션을 변경합니다.###\n";
PerUser ChangePer;

echo -e "\n디렉터리일 경우 하위 파일 및 디렉터리를 모두 동일한 퍼미션으로 변경하시겠습니까? (y, n)\n";
read -p ">> " DirPer;
LastPer=${SumPerNumAll[3]}${SumPerNumAll[2]}${SumPerNumAll[1]}
PerConfirm="퍼미션이 정상적으로 변경되었습니다.";
case $DirPer in
        y | Y | yes | Yes | YES | ok)
                chmod -R $LastPer $FileName;
                echo $PerConfirm;;
        *)
                chmod $LastPer $FileName;
                echo $PerConfirm;;
esac
