#!/usr/bin/env bash
echo "2.2.17 Ensure rsh server is not enabled"
ensure_service_disabled rsh.socket
ensure_service_disabled rlogin.socket
ensure_service_disabled rexec.socket