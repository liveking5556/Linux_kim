#!/bin/bash
# 스크립트 시작
# 파일 경로 정의
#경로를 사용자의 계정정보는 임의로 /home/user/user.txt
#출석정보는 임의로 /home/user/attendance.txt에 저장한다.
# ls /home/user 로 디렉토리 확인
# sudo mkdir -p /home/user/user.txt & /home/user/attendance.txt
#회원가입은 현서 담당
# 내가 임의로 저장

# 파일 경로 정의
USER_FILE="/home/user/user.txt" #사용자 계정 정보를 USER_FILE이라는 이름의 텍스트 파일에 저장
ATTENDANCE_FILE="/home/user/attendance.txt"  # 출석 정보를 ATTENDANCE_FILE이라는 이름의 텍스트 파일에 저장
#사용자의 계정 정보는 username:password:role형태로 저장
#출석 정보는 username:ClassA:Present 형태로 저장

# 로그인 함수
login() {
    echo "로그인 아이디를 입력해주세요:"
    read -p ">>> " username  # 사용자로부터 username 입력받기
    echo "로그인 비밀번호를 입력해주세요:"
    read -p ">>> " password  # 사용자로부터 password 입력받기 
    echo  # 줄바꿈

    #user.txt에서 미리 입력된(회원가입된) usernam: user_line이라는 이름으로 명칭
    user_line=$(grep "^$username:$password:" "$USER_FILE")
    if [ -n "$user_line" ]; then #user_line이 비어 있지 않다면 즉 user.txt에 저장된 정보와 입력 받은 아이디
        role=$(echo "$user_line" | cut -d':' -f3)  # 3번째 요소인 역할(role)을 추출
        return 0  # 로그인 성공
    else
        echo "로그인 정보가 올바르지 않습니다."
        return 1  # 로그인 실패
    fi
}

# 학생 출석 함수
student_attendance() {
    echo "A수업을 출석하시겠습니까? (Y/N)"
    read -p ">>> " confirm  # 출석 여부 입력받기
    if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
        # attendance.txt에서 해당 학생의 A수업 상태를 '결석'에서 '출석'으로 변경
        sed -i "/^$username:/s/ClassA:Absent/ClassA:Present/" "$ATTENDANCE_FILE"
        echo "A수업 출석 확인 되었습니다!"
    else
        echo "출석 정보가 변경되지 않았습니다."
    fi
}

# 교수 출석 관리 함수
professor_attendance() {
    echo "출석 정보를 조회할 학생의 아이디를 입력해주세요:"
    echo "학생 정보:"
    # attendance.txt의 학생 리스트를 출력
    awk -F':' '{print NR". "$1}' "$ATTENDANCE_FILE"
    read -p ">>> " student_name  # 조회할 학생 아이디 입력받기
    student_line=$(grep "^$student_name:" "$ATTENDANCE_FILE") # 해당 번호의 학생 정보 가져오기
    
    if [ -z "$student_line" ]; then
        echo "잘못된 학생 ID입니다."
        return
    fi

    student_name=$(echo "$student_line" | cut -d':' -f1)  # 학생 이름 추출
    attendance_status=$(echo "$student_line" | grep -o "ClassA:[^:]*" | cut -d':' -f2)  # A수업 출석 상태 추출

    if [ "$attendance_status" == "Absent" ]; then
        echo "'$student_name' 의 A수업 출석정보는 결석입니다."
        echo "'$student_name' 의 A수업을 출석하시겠습니까? (Y/N)"
        read -p ">>> " confirm  # 출석 변경 여부 입력받기
        if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
            # 출석 상태를 '결석'에서 '출석'으로 변경
            sed -i "/^$student_name:/s/ClassA:Absent/ClassA:Present/" "$ATTENDANCE_FILE"
            echo "'$student_name' 의 A수업 출석 확인 되었습니다!"
        else
            echo "변경되지 않았습니다."
        fi
    elif [ "$attendance_status" == "Present" ]; then
        echo "'$student_name' 의 A수업 출석정보는 출석입니다."
        echo "'$student_name' 의 A수업을 결석처리 하시겠습니까? (Y/N)"
        read -p ">>> " confirm  # 결석 변경 여부 입력받기
        if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
            # 출석 상태를 '출석'에서 '결석'으로 변경
            sed -i "/^$student_name:/s/ClassA:Present/ClassA:Absent/" "$ATTENDANCE_FILE"
            echo "'$student_name' 의 A수업 결석 확인 되었습니다!"
        else
            echo "변경되지 않았습니다."
        fi
    else
        echo "출석 상태가 올바르지 않습니다."
    fi
}

# 메인 스크립트 실행
if login; then
    if [ "$role" == "student" ]; then
        # 학생 로그인 시
        student_attendance
    elif [ "$role" == "professor" ]; then
        # 교수 로그인 시
        professor_attendance
    else
        echo "알 수 없는 역할입니다: $role"
    fi
else
    echo "프로그램을 종료합니다."
fi

echo "---종료---"







