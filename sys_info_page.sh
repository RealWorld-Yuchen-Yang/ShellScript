#!/bin/bash
# sys_info_page: program to output a system information page

PROGRAM=$(basename $0)
TITLE="System Information Report For $HOSTNAME"
CURRENT_TIME=$(date +"%x %r %Z")
TIMESTAMP="Generated $CURRENT_TIME, by $USER"

report_uptime(){
  cat<<-_EOF_
    <h2>System Uptime</h2>
    <pre>$(Uptime)</pre>
_EOF_
  return
}

report_disk_space(){
  cat<<-_EOF_
    <H2>Disk Space Utilization</H2>
    <PRE>$(df -h)</PRE>
_EOF_
  return
}

report_home_space(){
  if [[ $(id -u) -eq 0 ]]; then
    cat<<-_EOF_
      <h2>Home Space Utilization (All users)</h2>
      <pre>$(du -sh /Users/*)</pre>
_EOF_
  else
    cat<<-_EOF_
      <h2>Home Space Utilization ($USER)</h2>
      <pre>$(du -sh $HOME)</pre>
_EOF_
  fi
  return
}

usage(){
  echo "$PROGNAME: usage: $PROGNAME [-f file | -i]"
  return
}

write_html_page(){
  cat<<-_EOF_
  <html>
    <head>
      <title>$TITLE</title>
    </head>
    <body>
      <h1>$TITLE</h1>
      <p>$TIMESTAMP</p>
      $(report_uptime)
      $(report_disk_space)
      $(report_home_space)
    </body>
  </html>
_EOF_
  return
}


#process command line options
interactive=
filename=
while [[ -n $1 ]]; do
  case $1 in
    -f | --file)
      shift
      filename=$1
      ;;
    -i | --interactive)
      interactive=1
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
  shift
done

# interactive mode
if [[ -n $interactive ]]; then
  while [[ true ]]; do
    read -p "Enter name of output file: " filename
    echo $filename
    if [[ -e $filename ]]; then
      read -p "'$filename' exists. Overwrite? [y/n/q] > "
      case $REPLY in #$REPLY is a shell built-in variable
        Y|y)
          break
          ;;
        Q|q)
          echo "Program terminated"
          exit
          ;;
        *)
          continue
          ;;
      esac
    fi
  done
fi

# output html page
if [[ -n $filename ]]; then
  if touch $filename && [[ -f $filename ]] ; then
    write_html_page > $filename
    while [[ true ]]; do
      read -p "Open Generated System Info in Safari? [y/n/q] > "
      case $REPLY in
        Y|y)
          open -a Safari $filename
          break
          ;;
        Q|q)
          echo "Program terminated"
          exit
          ;;
        *)
          continue
          ;;
      esac
    done
  else
      echo "$PROGNAME: Cannot write file '$filename'" >&2
      exit 1
  fi
else
  write_html_page
fi
