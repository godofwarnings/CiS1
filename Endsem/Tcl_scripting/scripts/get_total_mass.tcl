proc get_total_mass {{molid top}} {
	eval "vecadd [[atomselect $molid all] get mass]"
}
