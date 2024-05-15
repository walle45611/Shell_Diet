#!/bin/bash

OK=0
CANCEL=1
ESC=255
DIET_TYPE=0
TOTAL=0
Number=0
USERNUM=$(($RANDOM / 100))
checkitem=""

FOOD_ARR_NAME=("漢堡-100" "薯條-40" "雞塊-60" "雞排-120" "蘿菠糕-50" "蛋餅-40" "薯餅-20" "吐司-100")
FOOD_ARR_PRICE=(100 40 60 120 50 40 20 100)
INTERNAL_FOOD_ARR_STATUS=(0 0 0 0 0 0 0 0)
OUTSIDE_FOOD_ARR_STATUS=(0 0 0 0 0 0 0 0)

DRINK_ARR_NAME=("雪碧-30" "可樂-30" "紅茶-40" "綠茶-40" "奶茶-50" "柳橙-40" "黑咖啡-60")
DRINK_ARR_PRICE=(30 30 40 40 50 40 60)
INTERNAL_DRINK_ARR_STATUS=(0 0 0 0 0 0 0)
OUTSIDE_DRINK_ARR_STATUS=(0 0 0 0 0 0 0)

DESSERT_ARR_NAME=("冰旋風-60" "蘋果派-30" "泡芙-35" "蛋塔-70")
DESSERT_ARR_PRICE=(60 30 35 70)
INTERNAL_DESSERT_ARR_STATUS=(0 0 0 0)
OUTSIDE_DESSERT_ARR_STATUS=(0 0 0 0)

#================================================================
INPUTNUM() {
    INTERNAL_DRINK_ARR_STATUS=(0 0 0 0 0 0 0)
    OUTSIDE_DRINK_ARR_STATUS=(0 0 0 0 0 0 0)
    INTERNAL_DESSERT_ARR_STATUS=(0 0 0 0)
    OUTSIDE_DESSERT_ARR_STATUS=(0 0 0 0)
    INTERNAL_FOOD_ARR_STATUS=(0 0 0 0 0 0 0 0)
    OUTSIDE_FOOD_ARR_STATUS=(0 0 0 0 0 0 0 0)
#================================================================
    inputNUM=$(
        dialog \
            --title "使用者代號" \
            --ok-label "確定" \
            --msgbox "$USERNUM" 10 50 \
            2>&1 >/dev/tty
    )
    result=$?

    case "${result}" in
    $OK)
        $USERNUM=$inputNUM
        MENU
        ;;
    $CANCEL | $ESC)
        exit
        ;;
    esac

}
#================================================================
MENU() {
    while :; do
        Selection=$(
            dialog \
                --title "$USERNUM" \
                --backtitle "點餐機" \
                --ok-label "繼續" \
                --cancel-label "上一步" \
                --clear \
                --menu "Choose one" 12 45 5 \
                1 "外帶" \
                2 "內用" \
                2>&1 >/dev/tty
        )
        result=$?
        [[ $Selection == 1 ]] && DIET_TYPE=1 || DIET_TYPE=2

        case "${result}" in
        $OK)
            SELECT_TYPEPAGE
            ;;
        $CANCEL | $ESC)
            INPUTNUM
            ;;
        esac

    done
}
#================================================================
SELECT_TYPEPAGE() {
    Selection=$(
        dialog \
            --title "$USERNUM" \
            --backtitle "點餐機" \
            --ok-label "繼續" \
            --cancel-label "上一步" \
            --extra-button --extra-label "結帳" \
            --menu "Choose one" 12 45 5 \
            1 "食物" \
            2 "飲料" \
            3 "甜點" \
            2>&1 >/dev/tty
    )
    result=$?

    case "$result" in
    1)
        MENU
        ;;
    3)
        SUM_CHECK
        exit
        ;;
    esac

    ALLFOOD "$Selection"
}
#================================================================
SUM_CHECK() {
    TOTAL=""
    OUTSIDE_Str=""
    INTERNAL_Str=""
    for i in ${!OUTSIDE_FOOD_ARR_STATUS[@]}; do
        if [ "${OUTSIDE_FOOD_ARR_STATUS[$i]}" -eq 1 ]; then
            TOTAL+="${FOOD_ARR_PRICE[$i]}+0"
            OUTSIDE_Str+=$(printf '%s' "${FOOD_ARR_NAME[$i]}")$'\n'
        fi
    done

    for i in ${!OUTSIDE_DRINK_ARR_STATUS[@]}; do
        if [ ${OUTSIDE_DRINK_ARR_STATUS[$i]} -eq 1 ]; then
            TOTAL+="${DRINK_ARR_PRICE[$i]}+0"
            OUTSIDE_Str+=$(printf '%s' "${DRINK_ARR_NAME[$i]}")$'\n'
        fi
    done

    for i in ${!OUTSIDE_DESSERT_ARR_STATUS[@]}; do
        if [ ${OUTSIDE_DESSERT_ARR_STATUS[$i]} -eq 1 ]; then
            TOTAL+="${DESSERT_ARR_PRICE[$i]}+0"
            OUTSIDE_Str+=$(printf '%s' "${DESSERT_ARR_NAME[$i]}")$'\n'
        fi
    done
    #=============================================================================
    for i in ${!INTERNAL_FOOD_ARR_STATUS[@]}; do
        if [ ${INTERNAL_FOOD_ARR_STATUS[$i]} -eq 1 ]; then
            TOTAL+="${FOOD_ARR_PRICE[$i]}+0"
            INTERNAL_Str+=$(printf '%s' "${FOOD_ARR_NAME[$i]}")$'\n'
        fi
    done

    for i in ${!INTERNAL_DRINK_ARR_STATUS[@]}; do
        if [ ${INTERNAL_DRINK_ARR_STATUS[$i]} -eq 1 ]; then
            TOTAL+="${DRINK_ARR_PRICE[$i]}+0"
            INTERNAL_Str+=$(printf '%s' "${DRINK_ARR_NAME[$i]}")$'\n'
        fi
    done

    for i in ${!INTERNAL_DESSERT_ARR_STATUS[@]}; do
        if [ ${INTERNAL_DESSERT_ARR_STATUS[$i]} -eq 1 ]; then
            TOTAL+="${DESSERT_ARR_PRICE[$i]}+0"
            INTERNAL_Str+=$(printf '%s' "${DESSERT_ARR_NAME[$i]}")$'\n'
        fi
    done
#==================================================================================
    TOTAL=$(echo $TOTAL | bc)

    dialog --title "點餐內容" \
        --backtitle "點餐機" \
        --extra-button --extra-label "退出不買了" \
        --cancel-label "更改項目" \
        --yesno "編號為$USERNUM的顧客\n\n外帶\n$OUTSIDE_Str\n\n內用\n$INTERNAL_Str\n\n總金額:$TOTAL\n" 15 60
    YESNO=$?

    case "${YESNO}" in
    0)
        qrencode -o "QRcode/$USERNUM.png" "訂單編號為$USERNUM 需要付的金額為$TOTAL"
        gio open "QRcode/$USERNUM.png"
        exit
        ;;
    1)
        SELECT_TYPEPAGE
        ;;
    3)
        exit
        ;;
    esac
}
#================================================================
GEN_CHECKLIST() {
    checkitem=""
    case "${DIET_TYPE}" in
    1)
        case "$1" in
        1)
            for i in ${!OUTSIDE_FOOD_ARR_STATUS[@]}; do
                if [ ${OUTSIDE_FOOD_ARR_STATUS[i]} -eq 1 ]; then
                    checkitem+=$(printf '%s' "$(($i + 1)) ${FOOD_ARR_NAME[$i]} on")$'\n'
                else
                    checkitem+=$(printf '%s' "$(($i + 1)) ${FOOD_ARR_NAME[$i]} off")$'\n'
                fi
            done
            ;;
        2)
            for i in ${!OUTSIDE_DRINK_ARR_STATUS[@]}; do
                if [ ${OUTSIDE_DRINK_ARR_STATUS[i]} -eq 1 ]; then
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DRINK_ARR_NAME[$i]} on")$'\n'
                else
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DRINK_ARR_NAME[$i]} off")$'\n'
                fi
            done
            ;;
        3)
            for i in ${!OUTSIDE_DESSERT_ARR_STATUS[@]}; do
                if [ ${OUTSIDE_DESSERT_ARR_STATUS[i]} -eq 1 ]; then
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DESSERT_ARR_NAME[$i]} on")$'\n'
                else
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DESSERT_ARR_NAME[$i]} off")$'\n'
                fi
            done
            ;;
        esac
        ;;
    2)
        case "$1" in
        1)
            for i in ${!INTERNAL_FOOD_ARR_STATUS[@]}; do
                if [ ${INTERNAL_FOOD_ARR_STATUS[i]} -eq 1 ]; then
                    checkitem+=$(printf '%s' "$(($i + 1)) ${FOOD_ARR_NAME[$i]} on")$'\n'
                else
                    checkitem+=$(printf '%s' "$(($i + 1)) ${FOOD_ARR_NAME[$i]} off")$'\n'
                fi
            done
            ;;
        2)
            for i in ${!INTERNAL_DRINK_ARR_STATUS[@]}; do
                if [ ${INTERNAL_DRINK_ARR_STATUS[i]} -eq 1 ]; then
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DRINK_ARR_NAME[$i]} on")$'\n'
                else
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DRINK_ARR_NAME[$i]} off")$'\n'
                fi
            done
            ;;
        3)
            for i in ${!INTERNAL_DESSERT_ARR_STATUS[@]}; do
                if [ ${INTERNAL_DESSERT_ARR_STATUS[i]} -eq 1 ]; then
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DESSERT_ARR_NAME[$i]} on")$'\n'
                else
                    checkitem+=$(printf '%s' "$(($i + 1)) ${DESSERT_ARR_NAME[$i]} off")$'\n'
                fi
            done
            ;;
        esac
        ;;
    esac

}
#================================================================
IS_PUSH() {
    case "${DIET_TYPE}" in
    1)

        case $1 in
        1)
            if [ -n "$Number" ]; then
                for i in "${!OUTSIDE_FOOD_ARR_STATUS[@]}"; do
                    for j in $Number; do
                        if [ $i -eq $(($j - 1)) ]; then
                            OUTSIDE_FOOD_ARR_STATUS[$i]=1
                            break
                        else
                            OUTSIDE_FOOD_ARR_STATUS[$i]=0
                        fi
                    done
                done
            else
                OUTSIDE_FOOD_ARR_STATUS=("${OUTSIDE_FOOD_ARR_STATUS[@]/*/0}")

            fi
            ;;

        2)
            if [ -n "$Number" ]; then
                for i in "${!OUTSIDE_DRINK_ARR_STATUS[@]}"; do
                    for j in $Number; do
                        if [ $i -eq $(($j - 1)) ]; then
                            OUTSIDE_DRINK_ARR_STATUS[$i]=1
                            break
                        else
                            OUTSIDE_DRINK_ARR_STATUS[$i]=0
                        fi
                    done
                done
            else
                OUTSIDE_DRINK_ARR_STATUS=("${OUTSIDE_DRINK_ARR_STATUS[@]/*/0}")

            fi
            ;;

        3)
            if [ -n "$Number" ]; then
                for i in "${!OUTSIDE_DESSERT_ARR_STATUS[@]}"; do
                    for j in $Number; do
                        if [ $i -eq $(($j - 1)) ]; then
                            OUTSIDE_DESSERT_ARR_STATUS[$i]=1
                            break
                        else
                            OUTSIDE_DESSERT_ARR_STATUS[$i]=0
                        fi
                    done
                done
            else
                OUTSIDE_DESSERT_ARR_STATUS=("${OUTSIDE_DESSERT_ARR_STATUS[@]/*/0}")
            fi
            ;;
        esac
        ;;
    2)
        case $1 in
        1)
            if [ -n "$Number" ]; then
                for i in "${!INTERNAL_FOOD_ARR_STATUS[@]}"; do
                    for j in $Number; do
                        if [ $i -eq $(($j - 1)) ]; then
                            INTERNAL_FOOD_ARR_STATUS[$i]=1
                            break
                        else
                            INTERNAL_FOOD_ARR_STATUS[$i]=0
                        fi
                    done
                done
            else
                INTERNAL_FOOD_ARR_STATUS=("${INTERNAL_FOOD_ARR_STATUS[@]/*/0}")
            fi
            ;;

        2)
            if [ -n "$Number" ]; then
                for i in "${!INTERNAL_DRINK_ARR_STATUS[@]}"; do
                    for j in $Number; do
                        if [ $i -eq $(($j - 1)) ]; then
                            INTERNAL_DRINK_ARR_STATUS[$i]=1
                            break
                        else
                            INTERNAL_DRINK_ARR_STATUS[$i]=0
                        fi
                    done
                done
            else
                INTERNAL_DRINK_ARR_STATUS=("${INTERNAL_DRINK_ARR_STATUS[@]/*/0}")
            fi
            ;;

        3)
            if [ -n "$Number" ]; then
                for i in "${!INTERNAL_DESSERT_ARR_STATUS[@]}"; do
                    for j in $Number; do
                        if [ $i -eq $(($j - 1)) ]; then
                            INTERNAL_DESSERT_ARR_STATUS[$i]=1
                            break
                        else
                            INTERNAL_DESSERT_ARR_STATUS[$i]=0
                        fi
                    done
                done
            else
                INTERNAL_DESSERT_ARR_STATUS=("${INTERNAL_DESSERT_ARR_STATUS[@]/*/0}")
            fi
            ;;
        esac
        ;;
    esac
}
#================================================================
CHANGE_PAGE() {
    if [ $1 -eq $CANCEL ] || [ $1 -eq $ESC ] || [ $1 -eq $OK ]; then
        SELECT_TYPEPAGE
        break
    fi
}
#================================================================
ALLFOOD() {
    TYPE_NAME=('食物區' '飲料區' '甜點區')

    GEN_CHECKLIST $1
    Number=$(
        dialog --title "${TYPE_NAME[(($1 - 1))]}" --clear \
            --title "${TYPE_NAME[(($1 - 1))]}" \
            --backtitle "點餐機" \
            --ok-label "確定選項並上一步" \
            --cancel-label "取消選項並上一步" \
            --checklist 'Select Item:' 15 70 10 \
            $checkitem 2>&1 >/dev/tty
    )
    IS_PUSH $1 Number

    result=$?
    CHANGE_PAGE $result
}
#================================================================
INPUTNUM