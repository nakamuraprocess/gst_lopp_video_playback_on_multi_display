#!/bin/bash

# --- 安全終了トラップ ---
trap "echo 'Stopping video loops...'; pkill -P $$; exit 0" SIGINT SIGTERM

# --- 動画ディレクトリ ---
VIDEO_DIR="Timeline"

# --- 各ディスプレイ用の動画番号セット ---
# 例: Display 0 は 1,3 / Display 1 は 2,4 を交互に再生
VIDEOS_A=(1 3)
VIDEOS_B=(2 4)

# --- ディスプレイ0用ループ ---
(
    i=0
    while true; do
        # 配列長を使って剰余で番号を循環
        index=$(( i % ${#VIDEOS_A[@]} ))
        num=${VIDEOS_A[$index]}
        video="$VIDEO_DIR/Timeline_${num}.mov"

        echo "Display 0: Playing $video"
        gst-launch-1.0 filesrc location="$video" ! \
            qtdemux ! h264parse ! nvv4l2decoder ! \
            nvvidconv flip-method=1 ! \
            nvoverlaysink display-id=0 sync=false

        ((i++))
    done
) &

# --- ディスプレイ1用ループ ---
(
    j=0
    while true; do
        index=$(( j % ${#VIDEOS_B[@]} ))
        num=${VIDEOS_B[$index]}
        video="$VIDEO_DIR/Timeline_${num}.mov"

        echo "Display 1: Playing $video"
        gst-launch-1.0 filesrc location="$video" ! \
            qtdemux ! h264parse ! nvv4l2decoder ! \
            nvvidconv flip-method=1 ! \
            nvoverlaysink display-id=1 sync=false

        ((j++))
    done
) &

# --- バックグラウンドジョブを待機 ---
wait
