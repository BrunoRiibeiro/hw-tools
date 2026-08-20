#!/bin/bash

show_help() {
	cat << EOF
Usage: $0 [OPTIONS] <SUBJECT> <mail> <mailinglist> <ccmailinglist>

Options:
  -h, --help             Show this help message and exit
  -a, --attachment FILE  Specify attachment file (converts path for WSL)
      --foreach          Execute an action for each item (example of an option without an argument)

Example:
  $0 -a file.txt --foreach "Subject" mail.txt "mail1;mail2" "ccmail1;ccmail2"
EOF
exit 0
}

create_powersheel() {
	local file=$1

	cat > $file <<EOF
\$Outlook = New-Object -ComObject Outlook.Application
\$Mail = \$Outlook.CreateItem(0)
\$Mail.To = "${TO}"
\$Mail.Cc = "${CC}"
\$Mail.Subject = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("${SUBJECT}"))

\$attachmentPath = "${ATTACHMENT}"
if (-not [string]::IsNullOrEmpty(\$attachmentPath)) {
	\$Mail.Attachments.Add(\$attachmentPath)
}

\$signaturesPath = "\$env:APPDATA\Microsoft\Signatures\"
\$filePath = "$(wslpath -w $mail)"
\$fileContent = Get-Content -Path \$filePath -Raw -Encoding UTF8

\$BODY = @"
\$fileContent
"@

\$fileExtension = [System.IO.Path]::GetExtension(\$filePath).ToLower()
if (\$fileExtension -eq ".html") {
	\$signatureFiles = Get-ChildItem -Path \$signaturesPath -Filter '*.htm'
	\$defaultSignature = Get-Content -Path \$signatureFiles[0].FullName -Raw -Encoding UTF8
	\$Mail.HTMLBody = \$fileContent + "<br>" + "\$defaultSignature"
} else {
	\$signatureFiles = Get-ChildItem -Path \$signaturesPath -Filter '*.txt'
	\$defaultSignature = Get-Content -Path \$signatureFiles[0].FullName -Raw -Encoding UTF8
	\$Mail.Body = \$fileContent + "\`n" + "\$defaultSignature"
}

\$Mail.Send()
EOF
}

format_list() {
	local list_input="$1"
	if [[ "$list_input" == *";"* ]]; then
		echo "$list_input"
	elif [ -f "$list_input" ]; then
		paste -sd';' "$list_input"
	else
		echo "$list_input" | tr ', ' ';'
	fi
}

foreach=false;
ATTACHMENT=""
while getopts "ha:-:" opt; do
	case "$opt" in
		h) show_help;;
		a) ATTACHMENT=$(wslpath -w $OPTARG);;
		-)	case "${OPTARG}" in
				help) show_help;;
				foreach) foreach=true;;
				attachment) ATTACHMENT=$(wslpath -w $OPTARG);;
			esac ;;
		\?)	echo "Invalid option: -${OPTARG}" >&2; exit 1;;
	esac
done
shift $((OPTIND-1))

SUBJECT=$1
mail=$2
maillist=$3
cclist=$4

[[ "$#" -eq 0 ]] && show_help && exit 1

[[ $foreach == false ]] && TO=$(format_list "$maillist")
CC=""
[[ -n $cclist ]] && CC=$(format_list "$cclist")

BASEDIR=$(mktemp -d)
if $foreach; then
	i=0
	for TO in $(cat $maillist); do
		target="$BASEDIR/mailto$((i++))-$TO.ps1"
		create_powersheel $target
		powershell.exe -File $target &
		echo "-> sending to $TO"
	done
else
	target="$BASEDIR/mailto-${TO:0:100}.ps1"
	echo $target
	create_powersheel $target
	powershell.exe -File "$target" &
	echo "-> sending to $TO"
fi

wait
