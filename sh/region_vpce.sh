#!/bin/bash

# デフォルト値の設定
DEFAULT_REGION="ap-northeast-1"
DEFAULT_DURATION="7day"
DEFAULT_END_TIME=$(TZ='Asia/Tokyo' date "+%Y-%m-%d %H:%M")

# ヘルプ関数
usage() {
    echo "使用方法: $0 [オプション]"
    echo "オプション:"
    echo "  -r, --region リージョン (デフォルト: ap-northeast-1)"
    echo "  -d, --duration 期間 (デフォルト: 7day)"
    echo "  -e, --end-time 終了時刻 (デフォルト: 現在時刻)"
    echo "  -h, --help ヘルプを表示"
    exit 1
}

# 引数解析
REGION=$DEFAULT_REGION
DURATION=$DEFAULT_DURATION
END_TIME=$DEFAULT_END_TIME

OPTS=$(getopt -o r:d:e:h --long region:,duration:,end-time:,help -n "$0" -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -r | --region ) REGION="$2"; shift 2 ;;
        -d | --duration ) DURATION="$2"; shift 2 ;;
        -e | --end-time ) END_TIME="$2"; shift 2 ;;
        -h | --help ) usage; shift ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

# VPCエンドポイント解析関数
analyze_vpc_endpoints() {
    local VPC_ID=$1

    # Interface型のVPCエンドポイントを確認
    INTERFACE_ENDPOINTS=$(aws ec2 describe-vpc-endpoints \
        --filters "Name=vpc-id,Values=${VPC_ID}" "Name=vpc-endpoint-type,Values=Interface" \
        --query 'length(VpcEndpoints)' \
        --region "$REGION")

    if [[ $INTERFACE_ENDPOINTS -eq 0 ]]; then
        echo "VPC $VPC_ID: インターフェース型エンドポイントはありません。スキップします。"
        return
    fi

    echo "VPC $VPC_ID: インターフェース型エンドポイントが見つかりました。メトリクス解析を実行します。"

    # 元のスクリプトの解析処理を呼び出し
    ./vpc_endpoint.sh "$VPC_ID" "$END_TIME" "$DURATION" "$REGION"
}

# メイン処理
main() {
    echo "リージョン $REGION のVPCを検索中..."

    # すべてのVPC IDを取得
    VPC_IDS=$(aws ec2 describe-vpcs \
        --query 'Vpcs[*].VpcId' \
        --output text \
        --region "$REGION")

    # 各VPCを処理
    for VPC_ID in $VPC_IDS; do
        echo "******************************"
        analyze_vpc_endpoints "$VPC_ID"
        echo
    done
}

# スクリプト実行
main
