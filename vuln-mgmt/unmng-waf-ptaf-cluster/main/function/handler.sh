#!/bin/bash

#folderid=b1ghen4foi7mbm59jb7f
#tgwafid=enpvfc4sa8e4u83bsbu1
#tgvmid=enpodd6db5pcqjrrdu50
#elb=nlb-577f3-f98
#ilb=ilbvm

function ptaf() {
        if [[ $1 == "active" ]]; then
                if [[ $elbtg != $tgwafid ]] || [[ $ilbtg != $tgvmid ]]
                then
                        #echo 'DO elb - tgwaf, ilb - tgvm'
                        yc logging write --group-name=default --message="DO elb - tgwaf, ilb - tgvm" --timestamp="$(date)" --level=INFO 
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $elbtg --name $elb)
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $ilbtg --name $elb)
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $ilbtg --name $ilb)
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $elbtg --name $ilb)
                        varX=$(yc lb network-load-balancer attach-target-group --folder-id $folderid $elb --target-group target-group-id=$tgwafid,healthcheck-tcp-port=22013,healthcheck-name=ilbcheck)
                        varX=$(yc lb network-load-balancer attach-target-group --folder-id $folderid $ilb --target-group target-group-id=$tgvmid,healthcheck-tcp-port=80,healthcheck-name=elbcheck)
                fi
        fi
        if [ $1 == "passive" ]; then
                if [[ $elbtg != $tgvmid ]] || [[ $ilbtg != $tgwafid ]]
                then
                        #echo 'DO elb - tgvm, ilb - tgwaf'
                        yc logging write --group-name=default --message="DO elb - tgvm, ilb - tgwaf" --timestamp="$(date)" --level=INFO 
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $elbtg --name $elb)
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $ilbtg --name $ilb)
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $elbtg --name $ilb)
                        varX=$(yc lb network-load-balancer detach-target-group --folder-id $folderid --target-group-id $ilbtg --name $elb)
                        varX=$(yc lb network-load-balancer attach-target-group --folder-id $folderid $elb --target-group target-group-id=$tgvmid,healthcheck-tcp-port=80,healthcheck-name=ilbcheck)
                        varX=$(yc lb network-load-balancer attach-target-group --folder-id $folderid $ilb --target-group target-group-id=$tgwafid,healthcheck-tcp-port=22013,healthcheck-name=elbcheck)
                fi
        fi
        #echo 'done.'
        yc logging write --group-name=default --message="Done" --timestamp="$(date)" --level=INFO
}

elbtg=$(yc --format json lb network-load-balancer get --folder-id $folderid $elb | jq '.attached_target_groups' | jq '.[].target_group_id' 2>&1 | sed 's/"//g')
ilbtg=$(yc --format json lb network-load-balancer get --folder-id $folderid $ilb | jq '.attached_target_groups' | jq '.[].target_group_id' 2>&1 | sed 's/"//g')
if [[ $elbtg == *"error"* ]] || [[ $ilbtg == *"error"* ]]; then
        ptaf 'active'
        #echo 'resetting defaults'
        yc logging write --group-name=default --message="resetting defaults" --timestamp="$(date)" --level=INFO
        exit 0
fi
if [[ $elbtg == $tgwafid ]]; then
        allwaf=$(yc --format json lb network-load-balancer target-states --folder-id $folderid --target-group-id $tgwafid --name $elb | jq '. | length')
        unhealthywaf=$(yc lb network-load-balancer target-states  --folder-id $folderid --target-group-id $tgwafid --name $elb | grep -c UNHEALTHY)

fi
if [[ $ilbtg == $tgwafid ]]; then
        allwaf=$(yc --format json lb network-load-balancer target-states --folder-id $folderid --target-group-id $tgwafid --name $ilb | jq '. | length')
        unhealthywaf=$(yc lb network-load-balancer target-states  --folder-id $folderid --target-group-id $tgwafid --name $ilb | grep -c UNHEALTHY)
fi
if [[ $ilbtg == $tgvmid ]]; then
        allvm=$(yc --format json lb network-load-balancer target-states --folder-id $folderid  --target-group-id $tgvmid --name $ilb | jq '. | length')
        unhealthyvm=$(yc lb network-load-balancer target-states --folder-id $folderid --target-group-id $tgvmid --name $ilb | grep -c UNHEALTHY)
fi
if [[ $elbtg == $tgvmid ]]; then
        allvm=$(yc --format json lb network-load-balancer target-states --folder-id $folderid  --target-group-id $tgvmid --name $elb | jq '. | length')
        unhealthyvm=$(yc lb network-load-balancer target-states --folder-id $folderid --target-group-id $tgvmid --name $elb | grep -c UNHEALTHY)
fi

if [[ $allwaf == $unhealthywaf ]]; then tgwaf=unhealthy ; else tgwaf=healthy ; fi
if [[ $allvm == $unhealthyvm ]]; then tgvm=unhealthy ; else tgvm=healthy ; fi

#echo 'allwaf '$allwaf
yc logging write --group-name=default --message="unhealthywaf - $unhealthywaf" --timestamp="$(date)" --level=INFO
#echo 'unhealthywaf '$unhealthywaf
yc logging write --group-name=default --message="unhealthywaf - $unhealthywaf" --timestamp="$(date)" --level=INFO
echo 'allvm '$allwaf
echo 'unhealthyvm '$unhealthyvm
echo 'elbtg '$elbtg
echo 'ilbtg '$ilbtg
echo 'tgwafid '$tgwafid
echo 'tgvmid '$tgvmid
echo 'vm ' $tgvm
echo 'waf ' $tgwaf


if [[ $tgwaf == 'healthy' ]] && [[ $tgvm == 'healthy' ]]; then ptaf 'active' ; fi
if [[ $tgwaf == 'unhealthy' ]] && [[ $tgvm == 'healthy' ]]; then ptaf 'passive' ; fi
if [[ $tgwaf == 'healthy' ]] && [[ $tgvm == 'unhealthy' ]]; then ptaf 'active' ; fi
if [[ $tgwaf == 'unhealthy' ]] && [[ $tgvm == 'unhealthy' ]]; then ptaf 'active' ; fi