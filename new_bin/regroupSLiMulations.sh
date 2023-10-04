for folder in $(ls | grep 20927_* | grep -v _);do
    echo $folder
    for source_folder in $(ls . | grep $folder);do
        mv $source_folder/* $folder
    done

done
