#!/usr/bin/env bash
# Point ghewareunigps.com at GitHub Pages (Cloudflare zone ghewareunigps.com). Run by the owner.
#   - deletes apex A 52.66.20.41 and the www CNAME to unigps.in
#   - creates apex A 185.199.108-111.153 and www CNAME brainupgrade-in.github.io, all DNS only (proxied=false),
#     so GitHub can issue the HTTPS certificate
#   - leaves MX and TXT records alone (Google Workspace mail)
# Idempotent: safe to run again. Reads the Cloudflare key with grep; never sources the env file or prints secrets.
set -euo pipefail
ENVF=/home/rajesh/ai-business-agents/.env
getv() { grep -E "^(export )?$1=" "$ENVF" | tail -1 | cut -d= -f2- | sed -E 's/^["'\'']//; s/["'\'']\s*$//'; }
E=$(getv CLOUDFLARE_EMAIL); K=$(getv CLOUDFLARE_GLOBAL_API_KEY)
Z=c0e8cf8b40d68a67be6877f37f6b3e02
APEX=ghewareunigps.com
WWW=www.ghewareunigps.com
API="https://api.cloudflare.com/client/v4/zones/$Z/dns_records"
H=(-H "X-Auth-Email: $E" -H "X-Auth-Key: $K" -H "Content-Type: application/json")
ok() { python3 -c 'import sys,json; d=json.load(sys.stdin); sys.exit(0) if d["success"] else (print(d["errors"]), sys.exit(1))'; }

# ids of records of TYPE at NAME, optionally only those whose content equals CONTENT
ids() {
  curl -s "${H[@]}" "$API?type=$1&name=$2&per_page=100" | python3 -c '
import sys,json
d=json.load(sys.stdin); want=sys.argv[1] if len(sys.argv)>1 else None
if not d["success"]: print(d["errors"], file=sys.stderr); sys.exit(1)
for r in d["result"]:
    if want is None or r["content"].rstrip(".")==want: print(r["id"])' ${3:+"$3"}
}

del() { # TYPE NAME CONTENT
  for id in $(ids "$1" "$2" "$3"); do
    curl -s "${H[@]}" -X DELETE "$API/$id" | ok && echo "== deleted $1 $2 -> $3"
  done
}

add() { # TYPE NAME CONTENT
  if [ -n "$(ids "$1" "$2" "$3")" ]; then
    echo "== $1 $2 -> $3 already there"
  else
    curl -s "${H[@]}" -X POST "$API" \
      -d "{\"type\":\"$1\",\"name\":\"$2\",\"content\":\"$3\",\"proxied\":false,\"ttl\":300,\"comment\":\"GitHub Pages\"}" \
      | ok && echo "== added $1 $2 -> $3"
  fi
}

del A "$APEX" 52.66.20.41
del CNAME "$WWW" unigps.in
for ip in 185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153; do add A "$APEX" "$ip"; done
add CNAME "$WWW" brainupgrade-in.github.io

sleep 5
echo "== dig @1.1.1.1"
echo "-- A $APEX";     dig +short A "$APEX" @1.1.1.1
echo "-- CNAME $WWW";  dig +short CNAME "$WWW" @1.1.1.1
echo "-- MX $APEX";    dig +short MX "$APEX" @1.1.1.1
echo "-- TXT $APEX";   dig +short TXT "$APEX" @1.1.1.1
