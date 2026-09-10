#!/bin/bash

show_help() {
	cat << EOF
Usage:
    $(basename "$0") <body_file> <priority>

Description:
    Creates an HTML file for opening a Service Request (SR).

    The script takes the message body from the specified text file,
    appends it to the standard SR table template, and generates the
    final HTML content that can be used in the SR opening email.

Arguments:
    body_file  Path to the text file containing the SR message body.
    priority   SR priority: 1, 2, 3 or 4.

Priorities:
    P1  Critical impact - The customer is unable to perform business-critical
        functions. Immediate corrective action is required.

    P2  Major impact - The customer can perform business-critical functions,
        but operations are severely restricted.

    P3  Minor impact - Business functionality is operational, but support is
        required to resolve a minor issue.

    P4  No impact - There is no impact on business functionality. The request
        concerns information, documentation or general queries.

Configuration:
    Before running the script, update the configuration variables in the
    script, including the template path, customer details, contact details
    and product information.

Examples:
    $(basename "$0") ./sr-xyz.txt 3
EOF
exit 0
}

[[ $# -eq 0 ]] && show_help && exit 1

BODY="${1:?Usage: $0 ./paht/to/body.txt}"
TABLE="/home/bruno/Mail/scripts/table-template.html"

INDEX="/tmp/index.html"

sed '1,2d; s/$/<br>/' $BODY > $INDEX

NAME="Bruno Ribeiro"
COMPANY_NAME="Huawei"
MOBILE="+55 41 9776-0215"
EMAIL="bruno.campos@h-partners.com"
CUSTOMER_COMPANY_NAME="SERVICO FEDERAL DE PROCESSAMENTO DE DADOS (SERPRO)"
COUNTRY="Brazil"
PRODNAME="Huawei Cloud Stack"
PRODNAME_VERSION="HCS Version 8.6.1"
PRIORITY="$2"

eval "cat<<EOF
$(cat "$TABLE")
EOF
" >> $INDEX
