#!/bin/bash

# デフォルト値の設定
DEFAULT_DURATION="7day"
DEFAULT_END_TIME=$(TZ='Asia/Tokyo' date "+%Y-%m-%d %H:%M")
DEFAULT_REGION="ap-northeast-1"

# 関数: ヘルプ表示
usage() {
    echo "使用方法: $0 [終了時刻] [期間] [リージョン]"
    echo "例:"
    echo "  $0 '2024-11-11 17:00' 2hour ap-northeast-1"
    echo "  $0 '2024-11-01 00:00' 5day us-west-2"
    echo "  $0 2hour"
    echo ""
    echo "期間の単位: min, hour, day"
    exit 1
}

# 引数のチェック
[[ "$1" == "-h" || "$1" == "--help" ]] && usage

# 引数設定
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

    # タイムゾーンを設定
    jst = pytz.timezone('Asia/Tokyo')
    utc = pytz.UTC

    # 終了時刻をJSTでパース
    end_time_jst = jst.localize(datetime.strptime(end_time_str, '%Y-%m-%d %H:%M'))

    # UTCに変換
    end_time_utc = end_time_jst.astimezone(utc)

    # 期間の解析
    value = int(''.join(filter(str.isdigit, duration_str)))
    unit = ''.join(filter(str.isalpha, duration_str))

    # 期間をtimedeltaに変換
    if unit == 'hour':
        duration = timedelta(hours=value)
    elif unit == 'min':
        duration = timedelta(minutes=value)
    elif unit == 'day':
        duration = timedelta(days=value)
    else:
        raise ValueError('無効な単位です')

    # 開始時刻を計算（UTCで）
    start_time_utc = end_time_utc - duration

    print(start_time_utc.strftime('%Y-%m-%dT%H:%M:00Z'), end_time_utc.strftime('%Y-%m-%dT%H:%M:00Z'))

except Exception as e:
    import sys
    sys.stderr.write(str(e))
    sys.exit(1)
")

# エラーチェック
if [[ $? -ne 0 ]]; then
    echo "時刻計算中にエラーが発生しました"
    exit 1
fi

# 期間を秒に変換
PERIOD=$(( ($(date -d "$END_TIME_UTC" +%s) - $(date -d "$START_TIME_UTC" +%s)) ))

# メトリクス取得間隔の決定
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
echo "NAT Gateway ID,バイト数(送信),バイト数(受信),パケット数(送信),パケット数(受信)" > "$RESULTS_CSV"

# 開始・終了時刻のJST表示
START_TIME_JST=$(date -d "$START_TIME_UTC +9 hours" "+%Y-%m-%d %H:%M:%S")
END_TIME_JST=$(date -d "$END_TIME_UTC +9 hours" "+%Y-%m-%d %H:%M:%S")

echo "リージョン: $REGION を確認中..."
echo "開始時刻 (JST): $START_TIME_JST"
echo "終了時刻 (JST): $END_TIME_JST"
echo "期間: $DURATION ($PERIOD 秒)"

# リージョン内のNAT Gatewayを取得
aws ec2 describe-nat-gateways --region $REGION --query 'NatGateways[*].NatGatewayId' --output json | jq -r '.[]' | while read -r NAT_GATEWAY_ID; do
    # メトリクス取得関数
    get_metric_sum() {
        local METRIC_NAME=$1
        aws cloudwatch get-metric-statistics \
            --namespace AWS/NATGateway \
            --metric-name "$METRIC_NAME" \
            --dimensions Name=NatGatewayId,Value="$NAT_GATEWAY_ID" \
            --start-time "$START_TIME_UTC" \
            --end-time "$END_TIME_UTC" \
            --period "$METRIC_PERIOD" \
            --statistics Sum \
            --region $REGION \
            --query 'Datapoints[*].Sum | sum(@)' \
            --output text 2>/dev/null
    }

    # メトリクス取得関数（アクティブ接続数用）
    get_metric_avg() {
        local METRIC_NAME=$1
        aws cloudwatch get-metric-statistics \
            --namespace AWS/NATGateway \
            --metric-name "$METRIC_NAME" \
            --dimensions Name=NatGatewayId,Value="$NAT_GATEWAY_ID" \
            --start-time "$START_TIME_UTC" \
            --end-time "$END_TIME_UTC" \
            --period "$METRIC_PERIOD" \
            --statistics Average \
            --region $REGION \
            --query 'Datapoints[*].Average | avg(@)' \
            --output text 2>/dev/null
    }

    # メトリクス取得
    BYTES_OUT=$(printf "%.0f" $(get_metric_sum BytesOutToDestination))
    BYTES_IN=$(printf "%.0f" $(get_metric_sum BytesInFromDestination))
    PACKETS_OUT=$(printf "%.0f" $(get_metric_sum PacketsOutToDestination))
    PACKETS_IN=$(printf "%.0f" $(get_metric_sum PacketsInFromDestination))

    # 0や"None"の場合は0として扱う
    BYTES_OUT=${BYTES_OUT:-0}
    BYTES_IN=${BYTES_IN:-0}
    PACKETS_OUT=${PACKETS_OUT:-0}
    PACKETS_IN=${PACKETS_IN:-0}

    # CSVに結果を追記
    echo "$NAT_GATEWAY_ID,$BYTES_OUT,$BYTES_IN,$PACKETS_OUT,$PACKETS_IN" >> "$RESULTS_CSV"
done

# 結果の表示
echo "NAT Gatewayのメトリクスレポート:"
echo "- リージョン: $REGION"
echo "- 期間: $DURATION"
echo "- 開始時刻 (JST): $START_TIME_JST"
echo "- 終了時刻 (JST): $END_TIME_JST"
echo "----------------------------"

# 結果をコンソールに表示
column -t -s, "$RESULTS_CSV"

# 一時ファイルを削除
rm "$RESULTS_CSV"
