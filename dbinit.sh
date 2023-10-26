#!/bin/bash
CURRENT=$(cd $(dirname $0);pwd)
target_dir="$CURRENT/db/backup"

rm -rf $target_dir/*

rsync -ahvz --include="*.tar.gz" --exclude="*" rik-bak01:/var/backup/shirasagi/tmp/ $target_dir 

newest_file=$(ls -t "$target_dir"/*.tar.gz 2>/dev/null | head -n1)
echo $newest_file

if [ -n "$newest_file" ]; then
    # 最新の .tar.gz ファイルを解凍
    tar -xzvf "$newest_file" -C "$target_dir"
    #tar -xzvf "$newest_file" 
else
    echo "解凍対象のファイルが見つかりません。"
fi

rm -rf $target_dir/*.tar.gz

files="${target_dir}/*"
for filepath in ${files}
do
filename=`basename ${filepath}`
directoryname=`dirname ${filepath}`
new_filename=${filename:0:9}
mv ${filepath} ${directoryname}"/"${new_filename}
done


