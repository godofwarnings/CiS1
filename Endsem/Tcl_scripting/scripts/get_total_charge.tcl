proc get_total_charge {{molid top}} {
	eval "vecadd [[atomselect $molid all] get charge]"
}
