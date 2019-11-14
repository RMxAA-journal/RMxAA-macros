#! /bin/bash
## Sanitize EPS files by converting any instance of bop-hook to BOP-hook
## so that if we set bop-hook in dvips, it doesn't get run in these included
## figures

FILELIST="*[0-9].ps *[0-9].eps"

for file in $FILELIST; do
    grep bop-hook $file > /dev/null \
	&& echo "$file has a bop-hook" \
	&& cp $file $file.BCK \
	&& sed -e's/bop-hook/BOP-hook/g' $file.BCK > $file \
 	&& echo "Successfully sanitized $file" 
done