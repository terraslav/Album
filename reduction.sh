#!/bin/bash
							# Путь к папке с альбомами (мой путь. у каждого он свой)
path="/media/media/Изображения/"
plist=/tmp/$$tmp.tmp		# Временный файл
							# Поиск видефайлов
find "${path}" -regextype posix-egrep -regex '.*(AVI|avi|MKV|mkv|MP4|mp4)$' > ${plist}

exec 10<${plist}			# ffmpeg сильно мусорит в stdout, применяю такую конструкцию
while read item <&10; do	# цикл построчного чтения файла листинга
	dir="${item%/*}"		# получаю путь к файлу
	name="${item##*/}"		# получаю имя файла (без пути)
							# создаю новый путь к файлу
	ndir="$(echo "${dir}"|sed 's/Изображения/Изображения\/New/g')"
	mkdir -p "${ndir}"		# создаю директорий, если он не существует
	nname="${ndir}/${name:0:-3}mkv"	# создаю новое имя файла, изменив расширение
	echo "Updating file: ${item}"	# вывод инфорации в консоль
							# и собственно перекодиую медиафайлы
	ffmpeg -i "${item}" -c:v libx265 -c:a libvorbis -f matroska "${nname}" > /dev/null 2>&1
done
							# Далее поиск фотографий
find "${path}" -regextype posix-egrep -regex '.*(JPG|jpg|PNG|png)$' > ${plist}

exec 10<${plist}
while read item <&10; do	# тут всё то-же самое как и в первом цикле
	dir="${item%/*}"
	name="${item##*/}"
	ndir="$(echo "${dir}"|sed 's/Изображения/Изображения\/New/g')"
	mkdir -p "${ndir}"
	echo "Updating file: ${item}"
							# утилита из пакета imagemagic - convert удаляет
							# незначащую информацию на картинке, уменьшая размер файла
	convert "${item}" -quality 80 "${ndir}/${name}"
done

rm ${plist}					# удаляю временный файл
