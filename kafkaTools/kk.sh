#!/bin/sh

#prop set
#zk 地址
zkaddr=localhost:20081
bkaddr=localhost:9092


# 副本 lack 多少 # topic 同步状态
# 获取到所有的Topic的producer
# 获取 topic 当前的 producer consumer group

# 关键配置，各项的关键配置，比如 broker, log, producer, consumer, zookeeper, topic

# 监控速率
# 消费进度监控
# kafka-dump-log.sh

print_all_brokers() {
    echo 
    echo "# print all brokers"
    ids=`./bin/zookeeper-shell.sh $zkaddr ls /brokers/ids 2>/dev/null| tail -n 1`

    if [ "$ids" = "" ] 
    then
        echo "brokers : null"
        return
    fi

    # 所有的 broker
    echo 
    echo "+----------------- brokers : $ids"

    for line in `echo $ids | grep -o "[0-9]*[0-9]" | awk '{ print $1$2$3 }' | awk -F, '{ print $1"\n"$2"\n"$3 }'`
    do
        #echo "+---------------------------- "$line
        inf=`./bin/zookeeper-shell.sh $zkaddr get /brokers/ids/$line 2>/dev/null  | grep -o "endpoints.*," | awk -F, '{ print $1 }' | grep -o "\[.*\]"`
        echo "+ broker ["$line"] : "$inf
        #for inf0 in `./bin/zookeeper-shell.sh $zkaddr get /brokers/ids/$line`
        #do
        #    echo "%"$inf0
        #done
    done

    echo "+-------------------------------"
    echo 
}

print_all_topics() {
    echo 
    echo "# print all topics"
    echo 
    echo "+------------------------- topics"

    topics=`./bin/kafka-topics.sh --zookeeper $zkaddr --list`

    for line in $topics
    do
        echo "+ name : "$line
    done

    echo "+-------------------------------"
    echo 
}

print_all_consumers_groups() {
    echo 
    echo "# print all consumer groups"
    echo 
    echo "+------------------------- consumer groups"

    groups=`bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list`

    for line in $groups
    do
        echo "+ group : "$line
    done

    echo "+-------------------------------"
    echo 
}

topic_info() {

    read -p "> input topic name : " name

    topic_info_name $name

}

topic_info_name() {

    name=$1

    if [ "$name" = "" ]
    then
        echo "# topic name empty."
        return
    fi

    echo 
    echo "# $1 print all topics"
    echo 
    echo "+------------------------- topic info"

    # topic 基本
    ./bin/kafka-topics.sh --zookeeper $zkaddr --describe --topic $name

    echo 
    echo "+ [message stat]"
    earlist=()
    # 最早的消息
    stat=`bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list $bkaddr --time -2 --topic $name`
    for line in $stat
    do
        earlist+=($line)
    done

    lastst=()
    # 最早的消息
    stat1=`bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list $bkaddr --time -1 --topic $name`
    for line in $stat1
    do
        lastst+=($line)
    done

    if (( ${#earlist[@]} != ${#lastst[@]} ))
    then
        echo "topic partition number not eq : 1st : "${#earlist[@]}", 2st : "${#lastst[@]}
    fi
    cnt=${#earlist[@]}
    for (( i=0; i<$cnt; i++ ))
    do
        # newTopic:0:123
        pIndex=`echo ${earlist[$i]} | awk -F: '{ print $2 }'`
        offset0=`echo ${earlist[$i]} | awk -F: '{ print $3 }'`

        pIndex1=`echo ${lastst[$i]} | awk -F: '{ print $2 }'`
        offset1=`echo ${lastst[$i]} | awk -F: '{ print $3 }'`
        echo "+ Partition [$pIndex] / Earliest msg offset : $offset0 / Lastest msg offset : $offset1 / Total msg : "$(($offset1-$offset0))

    done

    echo "+-------------------------------"
    echo 
}

add_topic() {
    # bin/kafka-topics.sh --create --zookeeper 127.0.0.1:20081 --replication-factor 1 --partitions 1 --topic test
    read -p "> input topic name : " name
    read -p "> input topic partitions : " pn
    read -p "> input topic replication-factor : " rf

    read -p "> $name, partitions:$pn, replication-factor:$rf, yes?(y or anyother)" yes
    if [ "$yes" != "y" ]
    then
        echo "# cancel add topic"
        return
    fi

    echo 
    echo "# add topic ##################################"
    bin/kafka-topics.sh --create --zookeeper $zkaddr --partitions $pn --replication-factor $rf --topic $name 2>&1 | while read line
    do
        echo "# "$line
    done
    echo "##############################################"
}
remove_topic() {
    read -p "> input topic name : " name

    read -p "> $name, will be delete, yes?(reinput topic name)" yes
    if [ "$yes" != "$name" ]
    then
        echo "# cancel remove topic"
        return
    fi

    echo 
    echo "# remove topic ##################################"
    bin/kafka-topics.sh --delete --zookeeper $zkaddr --topic $name 2>&1 | while read line
    do
        echo "# "$line
    done
    echo "##################################################"
}
consumer_group_info() {
    read -p "> input group name : " name

    echo 
    echo "# consumer group info ####################################"
    bin/kafka-consumer-groups.sh --bootstrap-server $bkaddr --describe --group $name 2>&1 | while read line
    do
        echo "# $line"
    done
    echo "#"
    bin/kafka-consumer-groups.sh --bootstrap-server $bkaddr --describe --group $name --state 2>&1 | while read line
    do
        echo "# $line"
    done
    echo "##################################################"
}

test_produce() {
    read -p "> input topic name : " name

    echo 
    echo "# input msg ######################################"
    bin/kafka-console-producer.sh --broker-list $bkaddr --topic $name 2>&1 | while read line
    do
        echo "# "$line
    done
    echo "##################################################"
}

test_consume() {
    read -p "> input topic name : " name

    topic_info_name $name

    read -p "> input group name, can be empty : " group
    read -p "> input topic partition, can be empty : " pn

    pnopt=""
    if [ "$pn" != "" ]
    then
        pnopt="--partition $pn"
        read -p "> input $pn partition offset : offset, can be empty : " off
        if [ "$off" != "" ]
        then
            pnopt="--partition $pn --offset $off"
        fi
    else
        read -p "> --from-beginning ?(y/anyother)" beginning
        if [ "$beginning" = "y" ]
        then
            pnopt="--from-beginning"
        fi
    fi

    groupopt=""
    if [ "$group" != "" ]
    then
       groupopt="--group $group" 
    fi

    echo 
    echo "# consume msg ####################################"
    eval "bin/kafka-console-consumer.sh --bootstrap-server $bkaddr --topic $name $groupopt $pnopt 2>&1" | while read line
    do
        echo "# ["$line"]"
    done
    echo "##################################################"
}

del_consumer_group() {
    read -p "> delete consumer name : " name

    read -p "> $name, will be delete, yes?(reinput consumer group name)" yes
    if [ "$yes" != "$name" ]
    then
        echo "# cancel remove consumer group"
        return
    fi

    echo 
    echo "# delete $name ################################"
    bin/kafka-consumer-groups.sh --bootstrap-server $bkaddr --delete --group $name 2>&1 | while read line
    do
        echo "# "$line
    done
    echo "##################################################"
}

while [ 1 ] 
do
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    cmds=()
    echo "> select cmd"

    cmds+=("[Broker] --- all brokers")
    cmds+=("[Topic] ---- all topics")
    cmds+=("[Topic] ---- topic info")
    cmds+=("[Topic] ---- add topic")
    cmds+=("[Topic] ---- remove topic")
    cmds+=("[Consumer] - all consumer groups")
    cmds+=("[Consumer] - consumer group info")
    cmds+=("[Consumer] - test consumer")
    cmds+=("[Consumer] - delete consumer group")
    cmds+=("[Producer] - test produce")

    handles=()
    handles+=("print_all_brokers")
    handles+=("print_all_topics")
    handles+=("topic_info")
    handles+=("add_topic")
    handles+=("remove_topic")
    handles+=("print_all_consumers_groups")
    handles+=("consumer_group_info")
    handles+=("test_consume")
    handles+=("del_consumer_group")
    handles+=("test_produce")

    l=${#cmds[@]}

    opts=()
    opts+=("1");opts+=("2");opts+=("3");opts+=("4");opts+=("5");opts+=("6");opts+=("7");opts+=("8");opts+=("9");opts+=("0")
    opts+=("a");opts+=("b");opts+=("c");opts+=("d");opts+=("e");opts+=("f");opts+=("g");opts+=("h");opts+=("i");opts+=("j")
    opts+=("k");opts+=("l");opts+=("m");opts+=("n");opts+=("o");opts+=("p");opts+=("r");opts+=("s");opts+=("t");opts+=("u")
    opts+=("v");opts+=("w");opts+=("x");opts+=("y");opts+=("z")
    optsL=${#opts[@]}

    if (( $l > $optsL ))
    then
        echo "too many cmds"
        exit 1
    fi

    for (( i=0; i<$l; i++))
    do
        echo "> ${opts[$i]}. "${cmds[$i]}" [${opts[$i]}]"
    done

    echo "> q. quit"
    echo 
    echo "> select"

    read -p "> " slt
    echo 
    echo "# select "$slt

    cnt=0
    breakf=0
    for (( i=0; i<$l; i++))
    do
        if [ "$slt" = "${opts[$i]}" ]
        then
            eval ${handles[$i]}
            breakf=$[$breakf+1]
            break
        fi
        cnt=$[$cnt+1]
    done

    if [ "$slt" = "q" ]
    then
        exit 0
    fi

    if (( $breakf == 0 ))
    then
        echo "input error"
    fi

    echo ""
    read -n1 -p "> press any to continue on(q:quit)" q
    echo
    if [ "$q" = "q" ]
    then
        echo
        exit 0
    fi
done


