#!/bin/sh
#
# install $HOME/bin/checkdistnoted
# setup crontab to run every minute
# 
# MWR Apr 2016
#

INSTALLCMD=bin/checkdistnoted
cd "$HOME"
[ ! -d bin ] && mkdir bin
[ -f $INSTALLCMD ] || {
    cat > $INSTALLCMD <<-"!!"
#!/bin/sh
#
# check for runaway distnoted, kill if necessary
#

PATH=/bin:/usr/bin
export PATH

ps -reo '%cpu,uid,pid,command' | 
    awk -v UID=$UID '
    /distnoted agent$/ && $1 >= 100.0 && $2 == UID { 
        # kill distnoted agent with >= 100% CPU and owned by me
        system("kill -9 " $3) 
    }
    '
!!
    chmod +x $INSTALLCMD 
    echo installed $INSTALLCMD
}

INSTALLCRON="# check for runaway distnoted every minute:
* * * * * sh \"\$HOME/$INSTALLCMD\""
crontab -l | grep -q '$HOME'/$INSTALLCMD || {
    crontab -l > mycron
    echo "$INSTALLCRON" >> mycron
    crontab mycron
    rm mycron
    echo updated crontab
}
