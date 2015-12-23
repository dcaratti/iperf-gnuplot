#!/bin/sh 

if [ -f "$1" ]; then
	id=
	
	while IFS='' read -r _l ; do
		case $_l in
		*"] local "*)
			_b=${_l%%]*}
			_b=${_b##* }
			id=${id:+$id }$_b
			echo "" > /tmp/thr_$$_$_b
			continue
			;;
		*"] "*)
			_b=${_l%%]*}
			_b=${_b##* }
			[ -z "$id" -o -z "$_b" ] && continue
			case $id in
			$_b | *" $_b "*)
				_p=
				_e=
				for _t in $_l ; do
					case $_t in
					*"$_b]")
					# read timestamp stripping the leftmost number in 'Interval' assuming it
					#  s just after [ID]
						_e=${_l##*$_b]}
						_e=${_e# }
						_e=${_e%%-*}
					;;
					*"bits/sec")
						_e=${_e:+$_e $_p}
					;;
					esac
					_p=$_t
				done
				[ -n "$_e" ] && echo $_e >>/tmp/thr_$$_$_b
				;;
			*) continue ;;
			esac
		;;
		esac
	done < $1
	_c=
	for _f in $id ; do
		_c=${_c:+$_c, }"'/tmp/thr_$$_$_f' using 1:2 with lines title '$1 - flow $_f'"
	done
	
	[ ${#_c} -gt 0 ] && gnuplot -p -e "set term x11; set xlabel 'Time (s)' ; set ylabel 'Throughput (Mbit/s)'; set grid; plot $_c;"
	
else
	echo "please specify input file"
fi
