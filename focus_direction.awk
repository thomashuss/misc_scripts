#!/usr/bin/awk -f
function list_window(distance) {
	if (min_distance == "" || distance < min_distance) {
		min_distance = distance
		closest_window = window
	}
}
function in_range(left1, right1, left2, right2, top1, bottom1, top2, bottom2) {
	return ((left2 >= left1 && left2 <= right1) || (right2 >= left1 && right2 <= right1) || (left1 >= left2 && left <= right2) || (right1 >= left2 && right1 <= right2)) && !((top1 > top2 && bottom1 < bottom2) || (top2 > top1 && bottom2 < bottom1))
}
function check_window() {
	bottom_edge = y + height
	right_edge = x + width
	x_mid = x + width / 2
	y_mid = y + height / 2
	if (direction == "left") {
		if ((right_edge <= active_x_mid || active_x >= x_mid) && in_range(active_y, active_bottom_edge, y, bottom_edge, active_x, active_right_edge, x, right_edge)) {
			list_window(sqrt((active_x - right_edge)^2 + (active_y - y)^2))
		}
	} else if (direction == "right") {
		if ((x >= active_x_mid || active_right_edge <= x_mid) && in_range(active_y, active_bottom_edge, y, bottom_edge, active_x, active_right_edge, x, right_edge)) {
			list_window(sqrt((x - active_right_edge)^2 + (active_y - y)^2))
		}
	} else if (direction == "up") {
		if ((bottom_edge <= active_y_mid || active_y >= y_mid) && in_range(active_x, active_right_edge, x, right_edge, active_y, active_bottom_edge, y, bottom_edge)) {
			list_window(sqrt((active_x - x)^2 + (active_y - bottom_edge)^2))
		}
	} else if (direction == "down") {
		if ((y >= active_y_mid || active_bottom_edge <= y_mid) && in_range(active_x, active_right_edge, x, right_edge, active_y, active_bottom_edge, y, bottom_edge)) {
			list_window(sqrt((active_x - x)^2 + (y - active_bottom_edge)^2))
		}
	}
}
{
	split($0, a, "=")
	if (NR == 1)
		delim = a[1]
	else if (a[1] == delim) {
		if (window)
			check_window()
		else {
			active_bottom_edge = active_y + active_height
			active_right_edge = active_x + active_width
			active_x_mid = active_x + active_width / 2
			active_y_mid = active_y + active_height / 2
		}
	}

	if (a[1] == "WINDOW") {
		if (!active_window)
			active_window = a[2]
		else
			window = a[2]
	} else if (a[1] == "X") {
		if (!active_x)
			active_x = a[2]
		else
			x = a[2]
	} else if (a[1] == "Y") {
		if (!active_y)
			active_y = a[2]
		else
			y = a[2]
	} else if (a[1] == "WIDTH") {
		if (!active_width)
			active_width = a[2]
		else
			width = a[2]
	} else if (a[1] == "HEIGHT") {
		if (!active_height)
			active_height = a[2]
		else
			height = a[2]
	}
}
END {
	if (!closest_window)
		closest_window = window
	print "windowactivate " closest_window
}
