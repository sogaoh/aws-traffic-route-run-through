#!/bin/bash

# デフォルト値の設定
DEFAULT_DURATION="7day"
DEFAULT_END_TIME=$(TZ='Asia/Tokyo' date "+%Y-%m-%d %H:%M")
DEFAULT_REGION="ap-northeast-1"

# 関数: ヘルプ表示
usage() {
    echo "使用方法: $0 <VPC ID> [終了時刻] [期間] [リージョン]"
    echo "例:"
    echo "  $0 vpc-01ce4b3abdf1104b1 '2024-11-11 17:00' 2hour ap-northeast-1"
    echo "  $0 vpc-01ce4b3abdf1104b1 '2024-11-01 00:00' 5day us-west-2"
    echo "  $0 vpc-01ce4b3abdf1104b1 2hour"
    echo ""
    echo "期間の単位: min, hour, day"
    exit 1
}

# 引数のチェック
[[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]] && usage

# VPC IDの取得
VPC_ID=$1
shift

# 残りの引数設定
if [[ $# -eq 0 ]]; then
    END_TIME=$DEFAULT_END_TIME
    DURATION=$DEFAULT_DURATION
    REGION=$DEFAULT_REGION
elif [[ $# -eq 1 ]]; then
    DURATION=$1
    END_TIME=$DEFAULT_END_TIME
    REGION=$DEFAULT_REGION
elif [[ $# -eq 2 ]]; then
    END_TIME=$1
    DURATION=$2
    REGION=$DEFAULT_REGION
else
    END_TIME=$1
    DURATION=$2
    REGION=$3
fi

# Pythonで時刻計算
read START_TIME_UTC END_TIME_UTC <<< $(python3 -c "
from datetime import datetime, timedelta
import pytz

try:
    end_time_str = '$END_TIME'
    duration_str = '$DURATION'

    jst = pytz.timezone('Asia/Tokyo')
    utc = pytz.UTC

    end_time_jst = jst.localize(datetime.strptime(end_time_str, '%Y-%m-%d %H:%M'))
    end_time_utc = end_time_jst.astimezone(utc)

    value = int(''.join(filter(str.isdigit, duration_str)))
    unit = ''.join(filter(str.isalpha, duration_str))

    if unit == 'hour':
        duration = timedelta(hours=value)
    elif unit == 'min':
        duration = timedelta(minutes=value)
    elif unit == 'day':
        duration = timedelta(days=value)
    else:
        raise ValueError('無効な単位です')

    start_time_utc = end_time_utc - duration
    print(start_time_utc.strftime('%Y-%m-%dT%H:%M:00Z'), end_time_utc.strftime('%Y-%m-%dT%H:%M:00Z'))

except Exception as e:
    import sys
    sys.stderr.write(str(e))
    sys.exit(1)
")

# 期間を秒に変換
PERIOD=$(( ($(date -d "$END_TIME_UTC" +%s) - $(date -d "$START_TIME_UTC" +%s)) ))

# メトリクス取得間隔の自動調整
if [[ $PERIOD -le 3600 ]]; then
    METRIC_PERIOD=60  # 1時間以内は1分間隔
elif [[ $PERIOD -le 86400 ]]; then
    METRIC_PERIOD=300  # 1日以内は5分間隔
else
    METRIC_PERIOD=3600  # それ以上は1時間間隔
fi

# 結果を格納するCSVファイル
RESULTS_CSV=$(mktemp --suffix=.csv)

# CSVヘッダー
echo "VPCエンドポイントID,サービス名,処理バイト数,新規接続数" > "$RESULTS_CSV"

# 開始・終了時刻のJST表示
START_TIME_JST=$(date -d "$START_TIME_UTC +9 hours" "+%Y-%m-%d %H:%M:%S")
END_TIME_JST=$(date -d "$END_TIME_UTC +9 hours" "+%Y-%m-%d %H:%M:%S")

echo "VPC ID: $VPC_ID のInterface型エンドポイントを確認中..."
echo "開始時刻 (JST): $START_TIME_JST"
echo "終了時刻 (JST): $END_TIME_JST"
echo "期間: $DURATION (${PERIOD}秒, ${METRIC_PERIOD}秒間隔)"

# VPC内のInterface型エンドポイントを取得
aws ec2 describe-vpc-endpoints \
    --filters "Name=vpc-id,Values=${VPC_ID}" "Name=vpc-endpoint-type,Values=Interface" \
    --query 'VpcEndpoints[*].{ID:VpcEndpointId,Service:ServiceName}' \
    --region $REGION --output json | jq -c '.[]' | while read -r endpoint; do

    VPCE_ID=$(echo $endpoint | jq -r '.ID')
    SERVICE_NAME=$(echo $endpoint | jq -r '.Service')

    # メトリクス取得関数
    get_metric_sum() {
        local METRIC_NAME=$1
        aws cloudwatch get-metric-statistics \
            --namespace AWS/PrivateLinkEndpoints \
            --metric-name "$METRIC_NAME" \
            --dimensions \
                Name="VPC Id",Value="$VPC_ID" \
                Name="VPC Endpoint Id",Value="$VPCE_ID" \
                Name="Endpoint Type",Value=Interface \
                Name="Service Name",Value="$SERVICE_NAME" \
            --start-time "$START_TIME_UTC" \
            --end-time "$END_TIME_UTC" \
            --period "$METRIC_PERIOD" \
            --statistics Sum \
            --region $REGION \
            --output json | jq -r '.Datapoints[].Sum' | awk '{sum += $1} END {print sum}'
    }

    # 各メトリクスの取得
    BYTES_PROCESSED=$(get_metric_sum "BytesProcessed")
    NEW_CONNECTIONS=$(get_metric_sum "NewConnections")

    # None や空の場合は0として扱う
    BYTES_PROCESSED=${BYTES_PROCESSED:-0}
    NEW_CONNECTIONS=${NEW_CONNECTIONS:-0}

    # CSVに結果を追記
    echo "$VPCE_ID,$SERVICE_NAME,$BYTES_PROCESSED,$NEW_CONNECTIONS" >> "$RESULTS_CSV"
done

# 結果の表示
echo "VPCエンドポイントのメトリクスレポート:"
echo "- VPC ID: $VPC_ID"
echo "- リージョン: $REGION"
echo "- 期間: $DURATION"
echo "- 開始時刻 (JST): $START_TIME_JST"
echo "- 終了時刻 (JST): $END_TIME_JST"
echo "----------------------------"

# すべての結果を表示
column -t -s, "$RESULTS_CSV"

# 一時ファイルを削除
rm "$RESULTS_CSV"
