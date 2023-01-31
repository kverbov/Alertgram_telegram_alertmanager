#!/usr/bin/env bash
##
#$(date +%d-%m-%Y-%H:%M:%S)
debug=true
if [[ "${debug}" ]]; then
  echo "Time: '$(date +%d-%m-%Y-%H:%M:%S)'" >> dbg.log
fi
if [[ "${debug}" ]]; then
  echo "input: '${1}\n'" >> dbg.log
fi
if [[ "${debug}" ]]; then
  echo "CHAT_ID: '${CHAT_ID}'" >> dbg.log
fi
if [[ "${debug}" ]]; then
  echo "BOT_TOKEN: '${BOT_TOKEN}'" >> dbg.log
fi
status="$(jq -r '.status' <<< "${1}")"
if [[ "${debug}" ]]; then
  echo "status: '${status}'" >> dbg.log
fi
severity="$(jq -r '.labels.severity' <<< "${1}")"
if [[ "${debug}" ]]; then
  echo "severity: '${severity}'" >> dbg.log
fi
alertname="$(jq -r '.labels.alertname' <<< "${1}")"
if [[ "${debug}" ]]; then
  echo "alertname: '${alertname}'" >> dbg.log
fi
labels="$(jq -r 'del(.labels|.job,.severity,.alertname).labels | to_entries[] | "\(.key): \(.value)"' <<< "${1}")"
if [[ "${debug}" ]]; then
  echo "labels: '${labels}'" >> dbg.log
fi
annotations="$(jq -r '.annotations | to_entries[] | "\(.key): \(.value)"' <<< "${1}")"
if [[ "${debug}" ]]; then
  echo "annotations: '${annotations}'" >> dbg.log
fi
if [[ "${status}" == 'firing' ]]; then
  case "${severity}" in
    low)
      status="🔥"
    ;;
    medium)
      status="🔥🔥"
    ;;
    normal)
      status="🔥🔥"
    ;;
    high)
      status="🔥🔥🔥"
    ;;
    *)
      status="🔥"
    ;;
  esac
else
  status="👌"
fi
if [[ "${debug}" ]]; then
  echo "severity: '${severity}'" >> dbg.log
fi
tg_alert="${status} [${severity}] ${alertname}
${labels}

${annotations}"
if [[ "${debug}" ]]; then
  echo "tg_alert: '${tg_alert}'" >> dbg.log
fi
payload="$(jq -nc --arg tg_alert "${tg_alert}" --arg chat_id "${CHAT_ID}" --arg bot_token "${BOT_TOKEN}" '{token: $bot_token, id: $chat_id, text: $tg_alert}')"
if [[ "${debug}" ]]; then
  echo "payload: '${payload}'" >> dbg.log
fi
curl -skXPOST -H 'Content-Type: application/json' -d "${payload}" "https://wso2ei.rrr.dmz.rrr.vip-clients:443/telegram/v1.0/sendmessage"
result="${?}"
if [[ "${debug}" ]]; then
  echo "result: '${result}'" >> dbg.log
fi
#
